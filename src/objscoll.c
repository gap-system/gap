/****************************************************************************
**
*W  objscoll.c                  GAP source                       Frank Celler
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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

SYS_CONST char * Revision_objscoll_c =
   "@(#)$Id$";

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

#include        "objfgelm.h"            /* objects of free groups          */

#define INCLUDE_DECLARATION_PART
#include        "objscoll.h"            /* single collector                */
#undef  INCLUDE_DECLARATION_PART


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

/****************************************************************************
**

*F  C8Bits_WordVectorAndClear( <kind>, <vv>, <num> )
*/
Obj C8Bits_WordVectorAndClear ( Obj kind, Obj vv, Int num )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         j;              /* loop variable for exponent vector       */
    Int *       qtr;            /* pointer into the collect vector         */
    UInt1 *     ptr;            /* pointer into the data area of <obj>     */
    Obj         obj;            /* result                                  */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    NEW_WORD( obj, kind, num );

    /* use UInt1 pointer for eight bits, clear <vv>                        */
    ptr = (UInt1*)DATA_WORD(obj);
    qtr = (Int*)(ADDR_OBJ(vv)+1);
    for ( i = 1, j = 0;  i <= num;  i++,  qtr++ ) {
        if ( *qtr != 0 ) {
            *ptr++ = ((i-1) << ebits) | (*qtr & expm);
            *qtr = 0;
            j++;
        }
    }

    /* correct the size of <obj>                                           */
    RESIZE_WORD( obj, 8L, j );
    return obj;
}


/****************************************************************************
**
*F  C8Bits_VectorWord( <vv>, <v>, <num> )
**
**  WARNING: This function assumes that <vv> is cleared!
*/
Int C8Bits_VectorWord ( Obj vv, Obj v, Int num )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    UInt        exps;           /* sign exponent mask                      */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         pos;            /* generator number                        */
    Int *       qtr;            /* pointer into the collect vector         */
    UInt1 *     ptr;            /* pointer into the data area of <obj>     */

    /* <vv> must be a string                                               */
    if ( TNUM_OBJ(vv) != T_STRING ) {
        if ( TNUM_OBJ(vv) == IMMUTABLE_TNUM(T_STRING) ) {
            RetypeBag( vv, T_STRING );
        }
        else {
            ErrorQuit( "collect vector must be a string not a %s", 
                       (Int)TNAM_OBJ(vv), 0L );
            return -1;
        }
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(vv) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        ResizeBag( vv, num*sizeof(Int)+sizeof(Obj)+1 );
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vv)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
    }

    /* if <v> is zero, return                                              */
    if ( v == 0 )
        return 0;

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(v);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* unfold <v> into <vv>                                                */
    ptr = (UInt1*)DATA_WORD(v);
    qtr = (Int*)ADDR_OBJ(vv);
    for ( i = NPAIRS_WORD(v);  0 < i;  i--, ptr++ ) {
        pos = ((*ptr) >> ebits)+1;
        if ( pos > num ) {
           ErrorQuit( "word contains illegal generators %d", (Int)i, 0L );
           return 0;
        }
        if ( (*ptr) & exps )
            qtr[pos] = ((*ptr)&expm)-exps;
        else
            qtr[pos] = (*ptr)&expm;
    }
    return 0;
}


/****************************************************************************
**
*F  C8Bits_SingleCollectWord( <sc>, <vv>, <w> )
**
**  If a stack overflow occurs, we simply stop and return false.
**
**  SC_PUSH_WORD( word, exp )
**    push <word>  with global exponent <exp>  into the stack, the macro uses
**    <word> and <exp> only once.
**
**  SC_POP_WORD()
**    remove topmost word from stack
*/
#define SC_PUSH_WORD( word, exp ) \
    if ( ++sp == max ) { \
        SC_SET_MAX_STACK_SIZE( sc, 2 * SC_MAX_STACK_SIZE(sc) ); \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(word); \
    *++lw = *nw + (INT_INTOBJ((((Obj*)(*nw))[-1])) - 1); \
    *++pw = *nw; \
    *++ew = (**pw) & expm; \
    *++ge = exp

#define SC_POP_WORD() \
    sp--;  nw--;  lw--;  pw--;  ew--;  ge--


Int C8Bits_SingleCollectWord ( Obj sc, Obj vv, Obj w )
{
    Int         ebits;      /* number of bits in the exponent              */
    UInt        expm;       /* unsigned exponent mask                      */
    UInt        exps;       /* sign exponent mask                          */

    Obj         vnw;        /* word stack                                  */
    UInt1 **    nw;         /* address of <vnw>                            */
    Obj         vlw;        /* last syllable stack                         */
    UInt1 **    lw;         /* address of <vlw>                            */
    Obj         vpw;        /* current syllable stack                      */
    UInt1 **    pw;         /* address of <vpw>                            */
    Obj         vew;        /* unprocessed exponent stack                  */
    UInt1 *     ew;         /* address of <vew>                            */
    Obj         vge;        /* global exponent stack                       */
    Int *       ge;         /* address of <vge>                            */

    Obj         vpow;       /* rhs of power relations                      */
    Int         lpow;       /* length of <vpow>                            */
    Obj *       pow;        /* address of <vpow>                           */

    Obj         vcnj;       /* rhs of conjugate relations                  */
    Int         lcnj;       /* length of <vcnj>                            */
    Obj *       cnj;        /* address of <vcnj>                           */

    Obj *       avc;        /* address of the avector                      */
    Obj *       gns;        /* address of the list of generators           */
    Obj *       ro;         /* address of the list of relative orders      */
    Obj *       inv;        /* address of the list of inverses             */

    Int *       v;          /* address of <vv>                             */

    Int         max;        /* maximal stack size                          */
    Int         sp;         /* stack pointer                               */
    Int         i;          /* loop variable                               */
    Int         gn;         /* current generator number                    */
    Int         ex;         /* current exponent                            */
    Int         start;      /* last non-trivial entry                      */

    Obj         tmp;        /* temporary obj for power                     */

    /* <start> is the first non-trivial entry in <v>                       */
    start = SC_NUMBER_RWS_GENERATORS(sc);

    /* if <w> is the identity return now                                   */
    if ( NPAIRS_WORD(w) == 0 ) {
        return start;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE( SC_DEFAULT_TYPE(sc) );

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* get the exponent sign masks                                         */
    exps = 1UL << (ebits-1);

    /* <nw> contains the stack of words to insert                          */
    vnw = SC_NW_STACK(sc);

    /* <lw> contains the word end of the word in <nw>                      */
    vlw = SC_LW_STACK(sc);

    /* <pw> contains the position of the word in <nw> to look at           */
    vpw = SC_PW_STACK(sc);

    /* <ew> contains the unprocessed exponents at position <pw>            */
    vew = SC_EW_STACK(sc);

    /* <ge> contains the global exponent of the word                       */
    vge = SC_GE_STACK(sc);

    /* get the maximal stack size                                          */
    max = SC_MAX_STACK_SIZE(sc);

    /* ensure that the stacks are large enough                             */
    if ( SIZE_OBJ(vnw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vnw, sizeof(Obj)*(max+1) );
        RetypeBag( vnw, T_STRING );
    }
    if ( SIZE_OBJ(vlw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vlw, sizeof(Obj)*(max+1) );
        RetypeBag( vlw, T_STRING );
    }
    if ( SIZE_OBJ(vpw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vpw, sizeof(Obj)*(max+1) );
        RetypeBag( vpw, T_STRING );
    }
    if ( SIZE_OBJ(vew)/sizeof(Obj) < max+1 ) {
        ResizeBag( vew, sizeof(Obj)*(max+1) );
        RetypeBag( vew, T_STRING );
    }
    if ( SIZE_OBJ(vge)/sizeof(Obj) < max+1 ) {
        ResizeBag( vge, sizeof(Obj)*(max+1) );
        RetypeBag( vge, T_STRING );
    }

    /* from now on we use addresses instead of handles most of the time    */
    v  = (Int*)ADDR_OBJ(vv);
    nw = (UInt1**)ADDR_OBJ(vnw);
    lw = (UInt1**)ADDR_OBJ(vlw);
    pw = (UInt1**)ADDR_OBJ(vpw);
    ew = (UInt1*)ADDR_OBJ(vew);
    ge = (Int*)ADDR_OBJ(vge);

    /* conjujagtes, powers, order, generators, avector, inverses           */
    vpow = SC_POWERS(sc);
    lpow = LEN_PLIST(vpow);
    pow  = ADDR_OBJ(vpow);

    vcnj = SC_CONJUGATES(sc);
    lcnj = LEN_PLIST(vcnj);
    cnj  = ADDR_OBJ(vcnj);

    avc = ADDR_OBJ( SC_AVECTOR(sc) );
    gns = ADDR_OBJ( SC_RWS_GENERATORS(sc) );

    ro  = ADDR_OBJ( SC_RELATIVE_ORDERS(sc) );
    inv = ADDR_OBJ( SC_INVERSES(sc) );

    /* initalize the stack with <w>                                        */
    sp = 0;
    SC_PUSH_WORD( w, 1 );

    /* run until the stack is empty                                        */
    while ( 0 < sp ) {

        /* if <ew> is negative use inverse                                 */
        if ( *ew & exps ) {
            gn = ((**pw) >> ebits) + 1;
            ex = ( *ew & (exps-1) ) - exps;
            *ew = 0;
            SC_PUSH_WORD( inv[gn], -ex );
        }

        /* if <ew> is zero get next syllable                               */
        else if ( 0 == *ew ) {

            /* if <pw> has reached <lw> get next & reduce globale exponent */
            if ( *pw == *lw ) {

                /* if the globale exponent is greater one reduce it        */
                if ( 1 < *ge ) {
                    (*ge)--;
                    *pw = *nw;
                    *ew = (**pw) & expm;
                }

                /* otherwise get the next word from the stack              */
                else {
                    SC_POP_WORD();
                }
            }

            /* otherwise set <ew> to exponent of next syllable             */
            else {
                (*pw)++;
                *ew = (**pw) & expm;
            }
        }

        /* now move the next generator to the correct position             */
        else {

            /* get generator number                                        */
            gn = ((**pw) >> ebits) + 1;

            /* we can move <gn> directly to the correct position           */
            if ( INT_INTOBJ(avc[gn]) == gn ) {
                v[gn] += *ew;
                *ew = 0;
                if ( start <= gn )
                    start = gn;
            }

            /* we have to move <gn> step by step                           */
            else {
                (*ew)--;
                i = INT_INTOBJ(avc[gn]);
                if ( start < i )
                    i = start;
                for ( ;  gn < i;  i-- ) {
                    if ( v[i] ) {
                        if ( LEN_PLIST(cnj[i]) < gn )
                            tmp = gns[i];
                        else {
                            tmp = ELM_PLIST( cnj[i], gn );
                            if ( tmp == 0 || NPAIRS_WORD(tmp) == 0 )
                                tmp = gns[i];
                        }
                        SC_PUSH_WORD( tmp, v[i] );
                        v[i] = 0;
                    }
                }
                v[gn]++;
                if ( start <= INT_INTOBJ(avc[gn]) )
                    start = gn;
            }

            /* check that the exponent is not too big                      */
            if ( INT_INTOBJ(ro[gn]) <= v[gn] ) {
                i = v[gn] / INT_INTOBJ(ro[gn]);
                v[gn] -= i * INT_INTOBJ(ro[gn]);
                if ( gn <= lpow && pow[gn] && 0 < NPAIRS_WORD(pow[gn]) ) {
                    SC_PUSH_WORD( pow[gn], i );
                }
            }
        }
    }
    return start;
}
#undef SC_PUSH_WORD
#undef SC_POP_WORD


/****************************************************************************
**
*F  C8Bits_Solution( <sc>, <ww>, <uu>, <func> )
*/
Int C8Bits_Solution( 
    Obj         sc,
    Obj         ww,
    Obj         uu,
    FuncIOOO    func )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         ro;             /* relative order                          */
    Obj         rod;            /* relative orders                         */
    Obj         g;              /* one generator word                      */
    UInt1 *     gtr;            /* pointer into the data area of <g>       */
    Int *       ptr;            /* pointer into the collect vector         */
    Int *       qtr;            /* pointer into the collect vector         */

    /* get the number of generators                                        */
    num = SC_NUMBER_RWS_GENERATORS(sc);
    rod = SC_RELATIVE_ORDERS(sc);

    /* <ww> must be a string                                               */
    if ( TNUM_OBJ(ww) != T_STRING ) {
        if ( TNUM_OBJ(ww) == IMMUTABLE_TNUM(T_STRING) ) {
            RetypeBag( ww, T_STRING );
        }
        else {
            ErrorQuit( "collect vector must be a string not a %s", 
                       (Int)TNAM_OBJ(ww), 0L );
            return -1;
        }
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(ww) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        i = (SIZE_OBJ(ww)-sizeof(Obj)-1) / sizeof(Int);
        ResizeBag( ww, num*sizeof(Int)+sizeof(Obj)+1 );
        qtr = (Int*)(ADDR_OBJ(ww)+1);
        for ( i = i+1;  i <= num;  i++ )
            qtr[i] = 0;
    }

    /* <uu> must be a string                                               */
    if ( TNUM_OBJ(uu) != T_STRING ) {
        if ( TNUM_OBJ(uu) == IMMUTABLE_TNUM(T_STRING) ) {
            RetypeBag( ww, T_STRING );
        } else {
            ErrorQuit( "collect vector must be a string not a %s", 
                       (Int)TNAM_OBJ(uu), 0L );
            return -1;
        }
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(uu) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        i = (SIZE_OBJ(uu)-sizeof(Obj)-1) / sizeof(Int);
        ResizeBag( uu, num*sizeof(Int)+sizeof(Obj)+1 );
        qtr = (Int*)(ADDR_OBJ(uu)+1);
        for ( i = i+1;  i <= num;  i++ )
            qtr[i] = 0;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE( SC_DEFAULT_TYPE(sc) );

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* use <g> as right argument for the collector                         */
    NEW_WORD( g, SC_DEFAULT_TYPE(sc), 1 );

    /* start clearing <ww>, storing the result in <uu>                     */
    ptr = (Int*)(ADDR_OBJ(ww)+1);
    qtr = (Int*)(ADDR_OBJ(uu)+1);
    gtr = (UInt1*)DATA_WORD(g);
    for ( i = num;  0 < i;  i--, ptr++, qtr++ ) {
        ro = INT_INTOBJ(ELMW_LIST(rod,num-i+1));
        *qtr = ( *qtr - *ptr ) % ro;
        if ( *qtr < 0 )  *qtr += ro;
        if ( *qtr != 0 ) {
            *gtr = ( (num-i) << ebits ) | ( *qtr & expm );
            if ( func(sc,ww,g) == -1 )
                return -1;
        }
        *ptr = 0;
    }
    return 0;
}


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


/****************************************************************************
**

*F  C16Bits_WordVectorAndClear( <kind>, <vv>, <num> )
*/
Obj C16Bits_WordVectorAndClear ( Obj kind, Obj vv, Int num )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         j;              /* loop variable for exponent vector       */
    Int *       qtr;            /* pointer into the collect vector         */
    UInt2 *     ptr;            /* pointer into the data area of <obj>     */
    Obj         obj;            /* result                                  */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    NEW_WORD( obj, kind, num );

    /* use UInt2 pointer for sixteen bits, clear <vv>                      */
    ptr = (UInt2*)DATA_WORD(obj);
    qtr = (Int*)(ADDR_OBJ(vv)+1);
    for ( i = 1, j = 0;  i <= num;  i++,  qtr++ ) {
        if ( *qtr != 0 ) {
            *ptr++ = ((i-1) << ebits) | (*qtr & expm);
            *qtr = 0;
            j++;
        }
    }

    /* correct the size of <obj>                                           */
    RESIZE_WORD( obj, 16L, j );
    return obj;
}


/****************************************************************************
**
*F  C16Bits_VectorWord( <vv>, <v>, <num> )
**
**  WARNING: This function assumes that <vv> is cleared!
*/
Int C16Bits_VectorWord ( Obj vv, Obj v, Int num )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    UInt        exps;           /* sign exponent mask                      */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         pos;            /* generator number                        */
    Int *       qtr;            /* pointer into the collect vector         */
    UInt2 *     ptr;            /* pointer into the data area of <obj>     */

    /* <vv> must be a string                                               */
    if ( TNUM_OBJ(vv) != T_STRING ) {
        if ( TNUM_OBJ(vv) == IMMUTABLE_TNUM(T_STRING) ) {
            RetypeBag( vv, T_STRING );
        }
        else {
            ErrorQuit( "collect vector must be a string not a %s", 
                       (Int)TNAM_OBJ(vv), 0L );
            return -1;
        }
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(vv) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        ResizeBag( vv, num*sizeof(Int)+sizeof(Obj)+1 );
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vv)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
    }

    /* if <v> is zero, return                                              */
    if ( v == 0 )
        return 0;

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(v);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* unfold <v> into <vv>                                                */
    ptr = (UInt2*)DATA_WORD(v);
    qtr = (Int*)ADDR_OBJ(vv);
    for ( i = NPAIRS_WORD(v);  0 < i;  i--, ptr++ ) {
        pos = ((*ptr) >> ebits)+1;
        if ( pos > num ) {
           ErrorQuit( "word contains illegal generators %d", (Int)i, 0L );
           return 0;
        }
        if ( (*ptr) & exps )
            qtr[pos] = ((*ptr)&expm)-exps;
        else
            qtr[pos] = (*ptr)&expm;
    }
    return 0;
}


/****************************************************************************
**
*F  C16Bits_SingleCollectWord( <sc>, <vv>, <w> )
**
**  If a stack overflow occurs, we simply stop and return false.
**
**  SC_PUSH_WORD( word, exp )
**    push <word>  with global exponent <exp>  into the stack, the macro uses
**    <word> and <exp> only once.
**
**  SC_POP_WORD()
**    remove topmost word from stack
*/
#define SC_PUSH_WORD( word, exp ) \
    if ( ++sp == max ) { \
        SC_SET_MAX_STACK_SIZE( sc, 2 * SC_MAX_STACK_SIZE(sc) ); \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(word); \
    *++lw = *nw + (INT_INTOBJ((((Obj*)(*nw))[-1])) - 1); \
    *++pw = *nw; \
    *++ew = (**pw) & expm; \
    *++ge = exp

#define SC_POP_WORD() \
    sp--;  nw--;  lw--;  pw--;  ew--;  ge--


Int C16Bits_SingleCollectWord ( Obj sc, Obj vv, Obj w )
{
    Int         ebits;      /* number of bits in the exponent              */
    UInt        expm;       /* unsigned exponent mask                      */
    UInt        exps;       /* sign exponent mask                          */

    Obj         vnw;        /* word stack                                  */
    UInt2 **    nw;         /* address of <vnw>                            */
    Obj         vlw;        /* last syllable stack                         */
    UInt2 **    lw;         /* address of <vlw>                            */
    Obj         vpw;        /* current syllable stack                      */
    UInt2 **    pw;         /* address of <vpw>                            */
    Obj         vew;        /* unprocessed exponent stack                  */
    UInt2 *     ew;         /* address of <vew>                            */
    Obj         vge;        /* global exponent stack                       */
    Int *       ge;         /* address of <vge>                            */

    Obj         vpow;       /* rhs of power relations                      */
    Int         lpow;       /* length of <vpow>                            */
    Obj *       pow;        /* address of <vpow>                           */

    Obj         vcnj;       /* rhs of conjugate relations                  */
    Int         lcnj;       /* length of <vcnj>                            */
    Obj *       cnj;        /* address of <vcnj>                           */

    Obj *       avc;        /* address of the avector                      */
    Obj *       gns;        /* address of the list of generators           */
    Obj *       ro;         /* address of the list of relative orders      */
    Obj *       inv;        /* address of the list of inverses             */

    Int *       v;          /* address of <vv>                             */

    Int         max;        /* maximal stack size                          */
    Int         sp;         /* stack pointer                               */
    Int         i;          /* loop variable                               */
    Int         gn;         /* current generator number                    */
    Int         ex;         /* current exponent                            */
    Int         start;      /* last non-trivial entry                      */

    Obj         tmp;        /* temporary obj for power                     */

    /* <start> is the first non-trivial entry in <v>                       */
    start = SC_NUMBER_RWS_GENERATORS(sc);

    /* if <w> is the identity return now                                   */
    if ( NPAIRS_WORD(w) == 0 ) {
        return start;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE( SC_DEFAULT_TYPE(sc) );

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* get the exponent sign masks                                         */
    exps = 1UL << (ebits-1);

    /* <nw> contains the stack of words to insert                          */
    vnw = SC_NW_STACK(sc);

    /* <lw> contains the word end of the word in <nw>                      */
    vlw = SC_LW_STACK(sc);

    /* <pw> contains the position of the word in <nw> to look at           */
    vpw = SC_PW_STACK(sc);

    /* <ew> contains the unprocessed exponents at position <pw>            */
    vew = SC_EW_STACK(sc);

    /* <ge> contains the global exponent of the word                       */
    vge = SC_GE_STACK(sc);

    /* get the maximal stack size                                          */
    max = SC_MAX_STACK_SIZE(sc);

    /* ensure that the stacks are large enough                             */
    if ( SIZE_OBJ(vnw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vnw, sizeof(Obj)*(max+1) );
        RetypeBag( vnw, T_STRING );
    }
    if ( SIZE_OBJ(vlw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vlw, sizeof(Obj)*(max+1) );
        RetypeBag( vlw, T_STRING );
    }
    if ( SIZE_OBJ(vpw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vpw, sizeof(Obj)*(max+1) );
        RetypeBag( vpw, T_STRING );
    }
    if ( SIZE_OBJ(vew)/sizeof(Obj) < max+1 ) {
        ResizeBag( vew, sizeof(Obj)*(max+1) );
        RetypeBag( vew, T_STRING );
    }
    if ( SIZE_OBJ(vge)/sizeof(Obj) < max+1 ) {
        ResizeBag( vge, sizeof(Obj)*(max+1) );
        RetypeBag( vge, T_STRING );
    }

    /* from now on we use addresses instead of handles most of the time    */
    v  = (Int*)ADDR_OBJ(vv);
    nw = (UInt2**)ADDR_OBJ(vnw);
    lw = (UInt2**)ADDR_OBJ(vlw);
    pw = (UInt2**)ADDR_OBJ(vpw);
    ew = (UInt2*)ADDR_OBJ(vew);
    ge = (Int*)ADDR_OBJ(vge);

    /* conjujagtes, powers, order, generators, avector, inverses           */
    vpow = SC_POWERS(sc);
    lpow = LEN_PLIST(vpow);
    pow  = ADDR_OBJ(vpow);

    vcnj = SC_CONJUGATES(sc);
    lcnj = LEN_PLIST(vcnj);
    cnj  = ADDR_OBJ(vcnj);

    avc = ADDR_OBJ( SC_AVECTOR(sc) );
    gns = ADDR_OBJ( SC_RWS_GENERATORS(sc) );

    ro  = ADDR_OBJ( SC_RELATIVE_ORDERS(sc) );
    inv = ADDR_OBJ( SC_INVERSES(sc) );

    /* initalize the stack with <w>                                        */
    sp = 0;
    SC_PUSH_WORD( w, 1 );

    /* run until the stack is empty                                        */
    while ( 0 < sp ) {

        /* if <ew> is negative use inverse                                 */
        if ( *ew & exps ) {
            gn = ((**pw) >> ebits) + 1;
            ex = ( *ew & (exps-1) ) - exps;
            *ew = 0;
            SC_PUSH_WORD( inv[gn], -ex );
        }

        /* if <ew> is zero get next syllable                               */
        else if ( 0 == *ew ) {

            /* if <pw> has reached <lw> get next & reduce globale exponent */
            if ( *pw == *lw ) {

                /* if the globale exponent is greater one reduce it        */
                if ( 1 < *ge ) {
                    (*ge)--;
                    *pw = *nw;
                    *ew = (**pw) & expm;
                }

                /* otherwise get the next word from the stack              */
                else {
                    SC_POP_WORD();
                }
            }

            /* otherwise set <ew> to exponent of next syllable             */
            else {
                (*pw)++;
                *ew = (**pw) & expm;
            }
        }

        /* now move the next generator to the correct position             */
        else {

            /* get generator number                                        */
            gn = ((**pw) >> ebits) + 1;

            /* we can move <gn> directly to the correct position           */
            if ( INT_INTOBJ(avc[gn]) == gn ) {
                v[gn] += *ew;
                *ew = 0;
                if ( start <= gn )
                    start = gn;
            }

            /* we have to move <gn> step by step                           */
            else {
                (*ew)--;
                i = INT_INTOBJ(avc[gn]);
                if ( start < i )
                    i = start;
                for ( ;  gn < i;  i-- ) {
                    if ( v[i] ) {
                        if ( LEN_PLIST(cnj[i]) < gn )
                            tmp = gns[i];
                        else {
                            tmp = ELM_PLIST( cnj[i], gn );
                            if ( tmp == 0 || NPAIRS_WORD(tmp) == 0 )
                                tmp = gns[i];
                        }
                        SC_PUSH_WORD( tmp, v[i] );
                        v[i] = 0;
                    }
                }
                v[gn]++;
                if ( start <= INT_INTOBJ(avc[gn]) )
                    start = gn;
            }

            /* check that the exponent is not too big                      */
            if ( INT_INTOBJ(ro[gn]) <= v[gn] ) {
                i = v[gn] / INT_INTOBJ(ro[gn]);
                v[gn] -= i * INT_INTOBJ(ro[gn]);
                if ( gn <= lpow && pow[gn] && 0 < NPAIRS_WORD(pow[gn]) ) {
                    SC_PUSH_WORD( pow[gn], i );
                }
            }
        }
    }
    return start;
}
#undef SC_PUSH_WORD
#undef SC_POP_WORD


/****************************************************************************
**
*F  C16Bits_Solution( <sc>, <ww>, <uu>, <func> )
*/
Int C16Bits_Solution( 
    Obj         sc,
    Obj         ww,
    Obj         uu,
    FuncIOOO    func )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         ro;             /* relative order                          */
    Obj         rod;            /* relative orders                         */
    Obj         g;              /* one generator word                      */
    UInt2 *     gtr;            /* pointer into the data area of <g>       */
    Int *       ptr;            /* pointer into the collect vector         */
    Int *       qtr;            /* pointer into the collect vector         */

    /* get the number of generators                                        */
    num = SC_NUMBER_RWS_GENERATORS(sc);
    rod = SC_RELATIVE_ORDERS(sc);

    /* <ww> must be a string                                               */
    if ( TNUM_OBJ(ww) != T_STRING ) {
        if ( TNUM_OBJ(ww) == IMMUTABLE_TNUM(T_STRING) ) {
            RetypeBag( ww, T_STRING );
        }
        else {
            ErrorQuit( "collect vector must be a string not a %s", 
                       (Int)TNAM_OBJ(ww), 0L );
            return -1;
        }
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(ww) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        i = (SIZE_OBJ(ww)-sizeof(Obj)-1) / sizeof(Int);
        ResizeBag( ww, num*sizeof(Int)+sizeof(Obj)+1 );
        qtr = (Int*)(ADDR_OBJ(ww)+1);
        for ( i = i+1;  i <= num;  i++ )
            qtr[i] = 0;
    }

    /* <uu> must be a string                                               */
    if ( TNUM_OBJ(uu) != T_STRING ) {
        if ( TNUM_OBJ(uu) == IMMUTABLE_TNUM(T_STRING) ) {
            RetypeBag( uu, T_STRING );
        }
        else {
            ErrorQuit( "collect vector must be a string not a %s", 
                       (Int)TNAM_OBJ(uu), 0L );
            return -1;
        }
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(uu) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        i = (SIZE_OBJ(uu)-sizeof(Obj)-1) / sizeof(Int);
        ResizeBag( uu, num*sizeof(Int)+sizeof(Obj)+1 );
        qtr = (Int*)(ADDR_OBJ(uu)+1);
        for ( i = i+1;  i <= num;  i++ )
            qtr[i] = 0;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE( SC_DEFAULT_TYPE(sc) );

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* use <g> as right argument for the collector                         */
    NEW_WORD( g, SC_DEFAULT_TYPE(sc), 1 );

    /* start clearing <ww>, storing the result in <uu>                     */
    ptr = (Int*)(ADDR_OBJ(ww)+1);
    qtr = (Int*)(ADDR_OBJ(uu)+1);
    gtr = (UInt2*)DATA_WORD(g);
    for ( i = num;  0 < i;  i--, ptr++, qtr++ ) {
        ro = INT_INTOBJ(ELMW_LIST(rod,num-i+1));
        *qtr = ( *qtr - *ptr ) % ro;
        if ( *qtr < 0 )  *qtr += ro;
        if ( *qtr != 0 ) {
            *gtr = ( (num-i) << ebits ) | ( *qtr & expm );
            if ( func(sc,ww,g) == -1 )
                return -1;
        }
        *ptr = 0;
    }
    return 0;
}


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


/****************************************************************************
**

*F  C32Bits_WordVectorAndClear( <kind>, <vv>, <num> )
*/
Obj C32Bits_WordVectorAndClear ( Obj kind, Obj vv, Int num )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         j;              /* loop variable for exponent vector       */
    Int *       qtr;            /* pointer into the collect vector         */
    UInt4 *     ptr;            /* pointer into the data area of <obj>     */
    Obj         obj;            /* result                                  */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    NEW_WORD( obj, kind, num );

    /* use UInt4 pointer for 32 bits, clear <vv>                           */
    ptr = (UInt4*)DATA_WORD(obj);
    qtr = (Int*)(ADDR_OBJ(vv)+1);
    for ( i = 1, j = 0;  i <= num;  i++,  qtr++ ) {
        if ( *qtr != 0 ) {
            *ptr++ = ((i-1) << ebits) | (*qtr & expm);
            *qtr = 0;
            j++;
        }
    }

    /* correct the size of <obj>                                           */
    RESIZE_WORD( obj, 32L, j );
    return obj;
}


/****************************************************************************
**
*F  C32Bits_VectorWord( <vv>, <v>, <num> )
**
**  WARNING: This function assumes that <vv> is cleared!
*/
Int C32Bits_VectorWord ( Obj vv, Obj v, Int num )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    UInt        exps;           /* sign exponent mask                      */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         pos;            /* generator number                        */
    Int *       qtr;            /* pointer into the collect vector         */
    UInt4 *     ptr;            /* pointer into the data area of <obj>     */

    /* <vv> must be a string                                               */
    if ( TNUM_OBJ(vv) != T_STRING ) {
        if ( TNUM_OBJ(vv) == IMMUTABLE_TNUM(T_STRING) ) {
            RetypeBag( vv, T_STRING );
        }
        else {
            ErrorQuit( "collect vector must be a string not a %s", 
                       (Int)TNAM_OBJ(vv), 0L );
            return -1;
        }
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(vv) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        ResizeBag( vv, num*sizeof(Int)+sizeof(Obj)+1 );
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vv)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
    }

    /* if <v> is zero, return                                              */
    if ( v == 0 )
        return 0;

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(v);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* unfold <v> into <vv>                                                */
    ptr = (UInt4*)DATA_WORD(v);
    qtr = (Int*)ADDR_OBJ(vv);
    for ( i = NPAIRS_WORD(v);  0 < i;  i--, ptr++ ) {
        pos = ((*ptr) >> ebits)+1;
        if ( pos > num ) {
           ErrorQuit( "word contains illegal generators %d", (Int)i, 0L );
           return 0;
        }
        if ( (*ptr) & exps )
            qtr[pos] = ((*ptr)&expm)-exps;
        else
            qtr[pos] = (*ptr)&expm;
    }
    return 0;
}


/****************************************************************************
**
*F  C32Bits_SingleCollectWord( <sc>, <vv>, <w> )
**
**  If a stack overflow occurs, we simply stop and return false.
**
**  SC_PUSH_WORD( word, exp )
**    push <word>  with global exponent <exp>  into the stack, the macro uses
**    <word> and <exp> only once.
**
**  SC_POP_WORD()
**    remove topmost word from stack
*/
#define SC_PUSH_WORD( word, exp ) \
    if ( ++sp == max ) { \
        SC_SET_MAX_STACK_SIZE( sc, 2 * SC_MAX_STACK_SIZE(sc) ); \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(word); \
    *++lw = *nw + (INT_INTOBJ((((Obj*)(*nw))[-1])) - 1); \
    *++pw = *nw; \
    *++ew = (**pw) & expm; \
    *++ge = exp

#define SC_POP_WORD() \
    sp--;  nw--;  lw--;  pw--;  ew--;  ge--


Int C32Bits_SingleCollectWord ( Obj sc, Obj vv, Obj w )
{
    Int         ebits;      /* number of bits in the exponent              */
    UInt        expm;       /* unsigned exponent mask                      */
    UInt        exps;       /* sign exponent mask                          */

    Obj         vnw;        /* word stack                                  */
    UInt4 **    nw;         /* address of <vnw>                            */
    Obj         vlw;        /* last syllable stack                         */
    UInt4 **    lw;         /* address of <vlw>                            */
    Obj         vpw;        /* current syllable stack                      */
    UInt4 **    pw;         /* address of <vpw>                            */
    Obj         vew;        /* unprocessed exponent stack                  */
    UInt4 *     ew;         /* address of <vew>                            */
    Obj         vge;        /* global exponent stack                       */
    Int *       ge;         /* address of <vge>                            */

    Obj         vpow;       /* rhs of power relations                      */
    Int         lpow;       /* length of <vpow>                            */
    Obj *       pow;        /* address of <vpow>                           */

    Obj         vcnj;       /* rhs of conjugate relations                  */
    Int         lcnj;       /* length of <vcnj>                            */
    Obj *       cnj;        /* address of <vcnj>                           */

    Obj *       avc;        /* address of the avector                      */
    Obj *       gns;        /* address of the list of generators           */
    Obj *       ro;         /* address of the list of relative orders      */
    Obj *       inv;        /* address of the list of inverses             */

    Int *       v;          /* address of <vv>                             */

    Int         max;        /* maximal stack size                          */
    Int         sp;         /* stack pointer                               */
    Int         i;          /* loop variable                               */
    Int         gn;         /* current generator number                    */
    Int         ex;         /* current exponent                            */
    Int         start;      /* last non-trivial entry                      */

    Obj         tmp;        /* temporary obj for power                     */

    /* <start> is the first non-trivial entry in <v>                       */
    start = SC_NUMBER_RWS_GENERATORS(sc);

    /* if <w> is the identity return now                                   */
    if ( NPAIRS_WORD(w) == 0 ) {
        return start;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE( SC_DEFAULT_TYPE(sc) );
    if ( 28 < ebits ) {
        ErrorQuit( "number of exponent bits must be less than 29", 0L, 0L );
        return 0;
    }

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* get the exponent sign masks                                         */
    exps = 1UL << (ebits-1);

    /* <nw> contains the stack of words to insert                          */
    vnw = SC_NW_STACK(sc);

    /* <lw> contains the word end of the word in <nw>                      */
    vlw = SC_LW_STACK(sc);

    /* <pw> contains the position of the word in <nw> to look at           */
    vpw = SC_PW_STACK(sc);

    /* <ew> contains the unprocessed exponents at position <pw>            */
    vew = SC_EW_STACK(sc);

    /* <ge> contains the global exponent of the word                       */
    vge = SC_GE_STACK(sc);

    /* get the maximal stack size                                          */
    max = SC_MAX_STACK_SIZE(sc);

    /* ensure that the stacks are large enough                             */
    if ( SIZE_OBJ(vnw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vnw, sizeof(Obj)*(max+1) );
        RetypeBag( vnw, T_STRING );
    }
    if ( SIZE_OBJ(vlw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vlw, sizeof(Obj)*(max+1) );
        RetypeBag( vlw, T_STRING );
    }
    if ( SIZE_OBJ(vpw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vpw, sizeof(Obj)*(max+1) );
        RetypeBag( vpw, T_STRING );
    }
    if ( SIZE_OBJ(vew)/sizeof(Obj) < max+1 ) {
        ResizeBag( vew, sizeof(Obj)*(max+1) );
        RetypeBag( vew, T_STRING );
    }
    if ( SIZE_OBJ(vge)/sizeof(Obj) < max+1 ) {
        ResizeBag( vge, sizeof(Obj)*(max+1) );
        RetypeBag( vge, T_STRING );
    }

    /* from now on we use addresses instead of handles most of the time    */
    v  = (Int*)ADDR_OBJ(vv);
    nw = (UInt4**)ADDR_OBJ(vnw);
    lw = (UInt4**)ADDR_OBJ(vlw);
    pw = (UInt4**)ADDR_OBJ(vpw);
    ew = (UInt4*)ADDR_OBJ(vew);
    ge = (Int*)ADDR_OBJ(vge);

    /* conjujagtes, powers, order, generators, avector, inverses           */
    vpow = SC_POWERS(sc);
    lpow = LEN_PLIST(vpow);
    pow  = ADDR_OBJ(vpow);

    vcnj = SC_CONJUGATES(sc);
    lcnj = LEN_PLIST(vcnj);
    cnj  = ADDR_OBJ(vcnj);

    avc = ADDR_OBJ( SC_AVECTOR(sc) );
    gns = ADDR_OBJ( SC_RWS_GENERATORS(sc) );

    ro  = ADDR_OBJ( SC_RELATIVE_ORDERS(sc) );
    inv = ADDR_OBJ( SC_INVERSES(sc) );

    /* initalize the stack with <w>                                        */
    sp = 0;
    SC_PUSH_WORD( w, 1 );

    /* run until the stack is empty                                        */
    while ( 0 < sp ) {

        /* if <ew> is negative use inverse                                 */
        if ( *ew & exps ) {
            gn = ((**pw) >> ebits) + 1;
            ex = ( *ew & (exps-1) ) - exps;
            *ew = 0;
            SC_PUSH_WORD( inv[gn], -ex );
        }

        /* if <ew> is zero get next syllable                               */
        else if ( 0 == *ew ) {

            /* if <pw> has reached <lw> get next & reduce globale exponent */
            if ( *pw == *lw ) {

                /* if the globale exponent is greater one reduce it        */
                if ( 1 < *ge ) {
                    (*ge)--;
                    *pw = *nw;
                    *ew = (**pw) & expm;
                }

                /* otherwise get the next word from the stack              */
                else {
                    SC_POP_WORD();
                }
            }

            /* otherwise set <ew> to exponent of next syllable             */
            else {
                (*pw)++;
                *ew = (**pw) & expm;
            }
        }

        /* now move the next generator to the correct position             */
        else {

            /* get generator number                                        */
            gn = ((**pw) >> ebits) + 1;

            /* we can move <gn> directly to the correct position           */
            if ( INT_INTOBJ(avc[gn]) == gn ) {
                v[gn] += *ew;
                *ew = 0;
                if ( start <= gn )
                    start = gn;
            }

            /* we have to move <gn> step by step                           */
            else {
                (*ew)--;
                i = INT_INTOBJ(avc[gn]);
                if ( start < i )
                    i = start;
                for ( ;  gn < i;  i-- ) {
                    if ( v[i] ) {
                        if ( LEN_PLIST(cnj[i]) < gn )
                            tmp = gns[i];
                        else {
                            tmp = ELM_PLIST( cnj[i], gn );
                            if ( tmp == 0 || NPAIRS_WORD(tmp) == 0 )
                                tmp = gns[i];
                        }
                        SC_PUSH_WORD( tmp, v[i] );
                        v[i] = 0;
                    }
                }
                v[gn]++;
                if ( start <= INT_INTOBJ(avc[gn]) )
                    start = gn;
            }

            /* check that the exponent is not too big                      */
            if ( INT_INTOBJ(ro[gn]) <= v[gn] ) {
                i = v[gn] / INT_INTOBJ(ro[gn]);
                v[gn] -= i * INT_INTOBJ(ro[gn]);
                if ( gn <= lpow && pow[gn] && 0 < NPAIRS_WORD(pow[gn]) ) {
                    SC_PUSH_WORD( pow[gn], i );
                }
            }
        }
    }
    return start;
}
#undef SC_PUSH_WORD
#undef SC_POP_WORD


/****************************************************************************
**
*F  C32Bits_Solution( <sc>, <ww>, <uu>, <func> )
*/
Int C32Bits_Solution( 
    Obj         sc,
    Obj         ww,
    Obj         uu,
    FuncIOOO    func )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         ro;             /* relative order                          */
    Obj         rod;            /* relative orders                         */
    Obj         g;              /* one generator word                      */
    UInt4 *     gtr;            /* pointer into the data area of <g>       */
    Int *       ptr;            /* pointer into the collect vector         */
    Int *       qtr;            /* pointer into the collect vector         */

    /* get the number of generators                                        */
    num = SC_NUMBER_RWS_GENERATORS(sc);
    rod = SC_RELATIVE_ORDERS(sc);

    /* <ww> must be a string                                               */
    if ( TNUM_OBJ(ww) != T_STRING ) {
        if ( TNUM_OBJ(ww) == IMMUTABLE_TNUM(T_STRING) ) {
            RetypeBag( ww, T_STRING );
        }
        else {
            ErrorQuit( "collect vector must be a string not a %s", 
                       (Int)TNAM_OBJ(ww), 0L );
            return -1;
        }
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(ww) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        i = (SIZE_OBJ(ww)-sizeof(Obj)-1) / sizeof(Int);
        ResizeBag( ww, num*sizeof(Int)+sizeof(Obj)+1 );
        qtr = (Int*)(ADDR_OBJ(ww)+1);
        for ( i = i+1;  i <= num;  i++ )
            qtr[i] = 0;
    }

    /* <uu> must be a string                                               */
    if ( TNUM_OBJ(uu) != T_STRING ) {
        if ( TNUM_OBJ(uu) == IMMUTABLE_TNUM(T_STRING) ) {
            RetypeBag( uu, T_STRING );
        }
        else {
            ErrorQuit( "collect vector must be a string not a %s", 
                       (Int)TNAM_OBJ(uu), 0L );
            return -1;
        }
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(uu) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        i = (SIZE_OBJ(uu)-sizeof(Obj)-1) / sizeof(Int);
        ResizeBag( uu, num*sizeof(Int)+sizeof(Obj)+1 );
        qtr = (Int*)(ADDR_OBJ(uu)+1);
        for ( i = i+1;  i <= num;  i++ )
            qtr[i] = 0;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE( SC_DEFAULT_TYPE(sc) );

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* use <g> as right argument for the collector                         */
    NEW_WORD( g, SC_DEFAULT_TYPE(sc), 1 );

    /* start clearing <ww>, storing the result in <uu>                     */
    ptr = (Int*)(ADDR_OBJ(ww)+1);
    qtr = (Int*)(ADDR_OBJ(uu)+1);
    gtr = (UInt4*)DATA_WORD(g);
    for ( i = num;  0 < i;  i--, ptr++, qtr++ ) {
        ro = INT_INTOBJ(ELMW_LIST(rod,num-i+1));
        *qtr = ( *qtr - *ptr ) % ro;
        if ( *qtr < 0 )  *qtr += ro;
        if ( *qtr != 0 ) {
            *gtr = ( (num-i) << ebits ) | ( *qtr & expm );
            if ( func(sc,ww,g) == -1 )
                return -1;
        }
        *ptr = 0;
    }
    return 0;
}


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

*V  FinPowConjCollectors
*/
FinPowConjCol * FinPowConjCollectors [3] =
{
#define C8Bits_SingleCollectorNo        0
       &C8Bits_SingleCollector,
#define C16Bits_SingleCollectorNo       1
       &C16Bits_SingleCollector,
#define C32Bits_SingleCollectorNo       2
       &C32Bits_SingleCollector
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
    if ( fc->collectWord( sc, vv, w ) == -1 )
        return Fail;

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
    Obj                 kind;       /* kind of the returned object         */
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
    kind = SC_DEFAULT_TYPE(sc);
    return fc->wordVectorAndClear( kind, vc2, num );
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
    Obj                 kind;   /* kind of the return objue                */
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

    /* get the default kind                                                */
    kind = SC_DEFAULT_TYPE(sc);

    /* convert the vector <cvw> into a word and clear <vcw>                */
    return fc->wordVectorAndClear( kind, vcw, num );
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
    Obj                 kind;       /* kind of the return objue            */
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
    kind = SC_DEFAULT_TYPE(sc);
    return fc->wordVectorAndClear( kind, vc2, num );
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
    Obj                 kind;       /* kind of the return objue            */
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
    kind = SC_DEFAULT_TYPE(sc);
    return fc->wordVectorAndClear( kind, vcw, num );
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
    Obj                 kind;       /* kind of the return objue            */
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
    kind = SC_DEFAULT_TYPE(sc);

    /* return the trivial word if <pow> is zero                            */
    if ( pow == 0 ) {
        NEW_WORD( res, kind, 0 );
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
        w    = fc->wordVectorAndClear( kind, vc2, num );

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
        return fc->wordVectorAndClear( kind, vcw, num );

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
    Obj                 kind;       /* kind of the return objue            */
    Int                 num;        /* number of gen/exp pairs in <data>   */
    Int                 i;          /* loop variable for gen/exp pairs     */
    Obj                 vcw;        /* collect vector                      */
    Obj                 vc2;        /* collect vector                      */
    Int *               qtr;        /* pointer into the collect vector     */

    /* use 'cwVector' to collect word <w> to                               */
    vcw  = SC_CW_VECTOR(sc);
    vc2  = SC_CW2_VECTOR(sc);
    num  = SC_NUMBER_RWS_GENERATORS(sc);
    kind = SC_DEFAULT_TYPE(sc);

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
    u = fc->wordVectorAndClear( kind, vc2, num );

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
    return fc->wordVectorAndClear( kind, vcw, num );
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

*F  SetupSingleCollector()  . . . . . . . . .  initalize the single collector
*/
void SetupSingleCollector ( void )
{
}


/****************************************************************************
**
*F  InitSingleCollector() . . . . . . . . . .  initalize the single collector
*/
void InitSingleCollector ( void )
{
    /* export position numbers 'SCP_SOMETHING'                             */
    if ( ! SyRestoring ) {
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
    }

    /* export collector number                                             */
    if ( ! SyRestoring ) {
        AssGVar( GVarName( "8Bits_SingleCollector" ),
                INTOBJ_INT(C8Bits_SingleCollectorNo) );
        AssGVar( GVarName( "16Bits_SingleCollector" ),
                INTOBJ_INT(C16Bits_SingleCollectorNo) );
        AssGVar( GVarName( "32Bits_SingleCollector" ),
                INTOBJ_INT(C32Bits_SingleCollectorNo) );
    }

    /* collector methods                                                   */
    C_NEW_GVAR_FUNC( "FinPowConjCol_CollectWordOrFail", 3, "sc, list, word",
                  FuncFinPowConjCol_CollectWordOrFail,
      "src/objscoll.c:FinPowConjCol_CollectWordOrFail" );

    C_NEW_GVAR_FUNC( "FinPowConjCol_ReducedComm", 3, "sc, word, word",
                  FuncFinPowConjCol_ReducedComm,
      "src/objscoll.c:FinPowConjCol_ReducedComm" );

    C_NEW_GVAR_FUNC( "FinPowConjCol_ReducedForm", 2, "sc, word",
                  FuncFinPowConjCol_ReducedForm,
      "src/objscoll.c:FinPowConjCol_ReducedForm" );

    C_NEW_GVAR_FUNC( "FinPowConjCol_ReducedLeftQuotient", 3, "sc, word, word",
                  FuncFinPowConjCol_ReducedLeftQuotient,
      "src/objscoll.c:FinPowConjCol_ReducedLeftQuotient" );

    C_NEW_GVAR_FUNC( "FinPowConjCol_ReducedPowerSmallInt", 3, "sc, word, int",
                  FuncFinPowConjCol_ReducedPowerSmallInt,
      "src/objscoll.c:FinPowConjCol_ReducedPowerSmallInt" );

    C_NEW_GVAR_FUNC( "FinPowConjCol_ReducedProduct", 3, "sc, word, word",
                  FuncFinPowConjCol_ReducedProduct,
      "src/objscoll.c:FinPowConjCol_ReducedProduct" );

    C_NEW_GVAR_FUNC( "FinPowConjCol_ReducedQuotient", 3, "sc, word, word",
                  FuncFinPowConjCol_ReducedQuotient,
      "src/objscoll.c:FinPowConjCol_ReducedQuotient" );
}


/****************************************************************************
**
*F  CheckSingleCollector()   check the initialisation of the single collector
*/
void CheckSingleCollector ( void )
{
    SET_REVISION( "objscoll_c", Revision_objscoll_c );
    SET_REVISION( "objscoll_h", Revision_objscoll_h );
}


/****************************************************************************
**

*E  objscoll.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
