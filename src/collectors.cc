/****************************************************************************
**
*W  collectors.cc               GAP source                       Frank Celler
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

extern "C" {

#include "collectors.h"

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

}


/****************************************************************************
**
*F * * * * * * * * * * * * * module specific state  * * * * * * * * * * * * *
*/

struct CollectorsState_ {
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

extern inline struct CollectorsState_ * CollectorsState(void)
{
    return (struct CollectorsState_ *)StateSlotsAtOffset(CollectorsStateOffset);
}


/****************************************************************************
**
*F * * * * * * * * * * * * local defines and typedefs * * * * * * * * * * * *
*/

static Obj TYPE_KERNEL_OBJECT;


/****************************************************************************
**
**  SC_PUSH_GEN( gen, exp )
**    push a generator <gen>  with exponent <exp> onto the stack.
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
        CollectorsState()->SC_MAX_STACK_SIZE *= 2; \
        return -1; \
    } \
    *++nw = CONST_DATA_WORD(word); \
    *++lw = *nw + (INT_INTOBJ((((const Obj*)(*nw))[-1])) - 1); \
    *++pw = *nw; \
    *++ew = (**pw) & expm; \
    *++ge = exp

#define SC_PUSH_GEN( gen, exp ) \
    if ( ++sp == max ) { \
        CollectorsState()->SC_MAX_STACK_SIZE *= 2; \
        return -1; \
    } \
    *++nw = CONST_DATA_WORD(gen); \
    *++lw = *nw; \
    *++pw = *nw; \
    *++ew = exp; \
    *++ge = 1

#define SC_POP_WORD() \
    sp--;  nw--;  lw--;  pw--;  ew--;  ge--



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
*F  WordVectorAndClear( <type>, <vv>, <num> )
*/
template <typename UIntN>
Obj WordVectorAndClear(Obj type, Obj vv, Int num)
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         j;              /* loop variable for exponent vector       */
    Int *       qtr;            /* pointer into the collect vector         */
    UIntN *     ptr;            /* pointer into the data area of <obj>     */
    Obj         obj;            /* result                                  */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(type);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    obj = NewWord(type, num);

    /* clear <vv>                                                          */
    ptr = DATA_WORD(obj);
    qtr = (Int*)(ADDR_OBJ(vv)+1);
    for ( i = 1, j = 0;  i <= num;  i++,  qtr++ ) {
        if ( *qtr != 0 ) {
            *ptr++ = ((i-1) << ebits) | (*qtr & expm);
            *qtr = 0;
            j++;
        }
    }

    /* correct the size of <obj>                                           */
    ResizeBag( obj, 2*sizeof(Obj) + j * BITS_WORD(obj)/8 );
    ADDR_OBJ(obj)[1] = INTOBJ_INT(j);

    return obj;
}


/****************************************************************************
**
*F  VectorWord( <vv>, <v>, <num> )
**
**  WARNING: This function assumes that <vv> is cleared!
*/
template <typename UIntN>
Int VectorWord(Obj vv, Obj v, Int num)
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    UInt        exps;           /* sign exponent mask                      */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         pos;            /* generator number                        */
    Int *       qtr;            /* pointer into the collect vector         */
    const UIntN * ptr;          /* pointer into the data area of <obj>     */

    /* <vv> must be a string                                               */
    if ( TNUM_OBJ(vv) != T_STRING ) {
        ErrorQuit( "collect vector must be a mutable string not a %s",
                   (Int)TNAM_OBJ(vv), 0L );
        return -1;
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
    ptr = CONST_DATA_WORD(v);
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
**  The following functions are  used to add  a word into the exponent vector
**  without collection.  Two different cases occur:
**
**  Add   a word  into  the exponent  vector.   Here we   can  use the global
**  exponent.
**
**  Add part  of a word  into the  exponent vector.   Here  we cannot use the
**  global exponent because the beginning of  the word might not commute with
**  the rest.
**/
template <typename UIntN>
static Int SAddWordIntoExpVec(Int *         v,
                              const UIntN * w,
                              Int           e,
                              Int           ebits,
                              UInt          expm,
                              const Obj *   ro,
                              const Obj *   pow,
                              Int           lpow)
{

    const UIntN * wend = w + (INT_INTOBJ((((const Obj*)(w))[-1])) - 1);
    Int        i;
    Int        ex;
    Int        start = 0;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1;
        v[ i ] += ((*w) & expm) * e;      /* overflow check necessary? */
        if ( INT_INTOBJ(ro[i]) <= v[i] ) {
            ex = v[i] / INT_INTOBJ(ro[i]);
            v[i] -= ex * INT_INTOBJ(ro[i]);
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                start = SAddWordIntoExpVec(
                    v, CONST_DATA_WORD(pow[i]), ex,
                    ebits, expm, ro, pow, lpow  );
            }
        }
        if( start < i && v[i] ) start = i;
    }
    return start;
}

template <typename UIntN>
static Int SAddPartIntoExpVec(Int *         v,
                              const UIntN * w,
                              const UIntN * wend,
                              Int           ebits,
                              UInt          expm,
                              const Obj *   ro,
                              const Obj *   pow,
                              Int           lpow)
{

    Int        i;
    Int        ex;
    Int        start = 0;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1;
        v[ i ] += ((*w) & expm);     /* overflow check necessary? */
        if ( INT_INTOBJ(ro[i]) <= v[i] ) {
            ex = v[i] / INT_INTOBJ(ro[i]);
            v[i] -= ex * INT_INTOBJ(ro[i]);
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                start = SAddWordIntoExpVec(
                    v, CONST_DATA_WORD(pow[i]), ex,
                    ebits, expm, ro, pow, lpow  );
            }
        }
        if( start < i && v[i] ) start = i;
    }
    return start;
}


/****************************************************************************
**
*F  SingleCollectWord( <sc>, <vv>, <w> )
**
**  If a stack overflow occurs, we simply stop and return false.
*/
template <typename UIntN>
Int SingleCollectWord(Obj sc, Obj vv, Obj w)
{
    Int         ebits;      /* number of bits in the exponent              */
    UInt        expm;       /* unsigned exponent mask                      */
    UInt        exps;       /* sign exponent mask                          */

    Obj         vnw;        /* word stack                                  */
    const UIntN ** nw;      /* address of <vnw>                            */
    Obj         vlw;        /* last syllable stack                         */
    const UIntN ** lw;      /* address of <vlw>                            */
    Obj         vpw;        /* current syllable stack                      */
    const UIntN ** pw;      /* address of <vpw>                            */
    Obj         vew;        /* unprocessed exponent stack                  */
    UIntN *     ew;         /* address of <vew>                            */
    Obj         vge;        /* global exponent stack                       */
    Int *       ge;         /* address of <vge>                            */

    Obj         vpow;       /* rhs of power relations                      */
    Int         lpow;       /* length of <vpow>                            */
    const Obj * pow;        /* address of <vpow>                           */

    Obj         vcnj;       /* rhs of conjugate relations                  */
    Int         lcnj;       /* length of <vcnj>                            */
    const Obj * cnj;        /* address of <vcnj>                           */

    const Obj * avc;        /* address of the avector                      */
    const Obj * gns;        /* address of the list of generators           */
    const Obj * ro;         /* address of the list of relative orders      */
    const Obj * inv;        /* address of the list of inverses             */

    Int *       v;          /* address of <vv>                             */

    Int         max;        /* maximal stack size                          */
    Int         sp;         /* stack pointer                               */
    Int         i, j;       /* loop variable                               */
    Int         gn;         /* current generator number                    */
    Int         ex;         /* current exponent                            */
    Int         start;      /* last non-trivial entry                      */

    Obj         tmp;        /* temporary obj for power                     */

    Int         resized = 0;/* indicates whether a Resize() happened       */

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
    vnw = CollectorsState()->SC_NW_STACK;

    /* <lw> contains the word end of the word in <nw>                      */
    vlw = CollectorsState()->SC_LW_STACK;

    /* <pw> contains the position of the word in <nw> to look at           */
    vpw = CollectorsState()->SC_PW_STACK;

    /* <ew> contains the unprocessed exponents at position <pw>            */
    vew = CollectorsState()->SC_EW_STACK;

    /* <ge> contains the global exponent of the word                       */
    vge = CollectorsState()->SC_GE_STACK;

    /* get the maximal stack size                                          */
    max = CollectorsState()->SC_MAX_STACK_SIZE;

    /* ensure that the stacks are large enough                             */
    const UInt desiredStackSize = sizeof(Obj) * (max + 2);
    if ( SIZE_OBJ(vnw) < desiredStackSize ) {
        ResizeBag( vnw, desiredStackSize );
        resized = 1;
    }
    if ( SIZE_OBJ(vlw) < desiredStackSize ) {
        ResizeBag( vlw, desiredStackSize );
        resized = 1;
    }
    if ( SIZE_OBJ(vpw) < desiredStackSize ) {
        ResizeBag( vpw, desiredStackSize );
        resized = 1;
    }
    if ( SIZE_OBJ(vew) < desiredStackSize ) {
        ResizeBag( vew, desiredStackSize );
        resized = 1;
    }
    if ( SIZE_OBJ(vge) < desiredStackSize ) {
        ResizeBag( vge, desiredStackSize );
        resized = 1;
    }
    if( resized ) return -1;

    /* from now on we use addresses instead of handles most of the time    */
    v  = (Int*)ADDR_OBJ(vv);
    nw = (const UIntN**)(CONST_ADDR_OBJ(vnw)+1);
    lw = (const UIntN**)(CONST_ADDR_OBJ(vlw)+1);
    pw = (const UIntN**)(CONST_ADDR_OBJ(vpw)+1);
    ew = (UIntN*)(ADDR_OBJ(vew)+1);
    ge = (Int*)(ADDR_OBJ(vge)+1);

    /* conjugates, powers, order, generators, avector, inverses            */
    vpow = SC_POWERS(sc);
    lpow = LEN_PLIST(vpow);
    pow  = CONST_ADDR_OBJ(vpow);

    vcnj = SC_CONJUGATES(sc);
    lcnj = LEN_PLIST(vcnj);
    (void) lcnj; /* please compiler -- lcnj not actually used */
    cnj  = CONST_ADDR_OBJ(vcnj);

    avc = CONST_ADDR_OBJ( SC_AVECTOR(sc) );
    gns = CONST_ADDR_OBJ( SC_RWS_GENERATORS(sc) );

    ro  = CONST_ADDR_OBJ( SC_RELATIVE_ORDERS(sc) );
    inv = CONST_ADDR_OBJ( SC_INVERSES(sc) );

    /* initialize the stack with <w>                                        */
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
              /*
              *T  This if-statement implies that the next two cases are never
              *T  executed.  This is intended for the time being because we
              *T  need the single collector to work with pc-presentations
              *T  whose rhs are not reduced while the next two if-case need
              *T  reduced rhs.  This will be fixed at a later stage.
              */
                v[gn] += *ew;
                *ew = 0;
                if ( start <= gn )
                    start = gn;
            }

            /* collect a whole word exponent pair                          */
            else if( *pw == *nw && INT_INTOBJ(avc[gn]) == gn ) {
              gn = SAddWordIntoExpVec(
                   v, *pw, *ge, ebits, expm, ro, pow, lpow  );
              *pw = *lw;
              *ew = *ge = 0;

              if( start <= gn ) start = gn;
              continue;
            }

            /* move the rest of a word directly into the correct positions */
            else if( INT_INTOBJ(avc[gn]) == gn ) {
              gn = SAddPartIntoExpVec(
                   v, *pw, *lw, ebits, expm, ro, pow, lpow  );
              *pw = *lw;
              *ew = 0;

              if( start <= gn ) start = gn;
              continue;
            }

            /* we have to move <gn> step by step                           */
            else {
                (*ew)--; v[gn]++;

                i = INT_INTOBJ(avc[gn]);
                if ( start < i )
                    i = start;

                /* Find the first position in v from where on ordinary
                   collection  has to be applied.                          */
                for( ; gn < i; i-- )
                    if( v[i] && gn <= LEN_PLIST(cnj[i]) ) {
                        tmp = ELM_PLIST( cnj[i], gn );
                        if ( tmp != 0 && 0 < NPAIRS_WORD(tmp) )
                            break;
                    }

                /* Stack up this part of v if we run through the next
                   for-loop or if a power relation will be applied         */
                if( gn < i || (INT_INTOBJ(ro[gn]) <= v[gn] &&
                    gn <= lpow && pow[gn] && 0 < NPAIRS_WORD(pow[gn])) ) {
                    j = INT_INTOBJ(avc[gn]);
                    for( ; i < j; j-- )
                        if( v[j] ) {
                            SC_PUSH_WORD( gns[j], v[j] );
                            v[j] = 0;
                        }
                }

                if( gn < i ) {
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
                  if ( start <= INT_INTOBJ(avc[gn]) )
                    start = gn;
                }
                if( start <= gn ) start = gn;
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


/****************************************************************************
**
*F  Solution( <sc>, <ww>, <uu>, <func> )
*/
template <typename UIntN>
Int Solution(Obj sc, Obj ww, Obj uu, FuncIOOO func)
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         ro;             /* relative order                          */
    Obj         rod;            /* relative orders                         */
    Obj         g;              /* one generator word                      */
    UIntN *     gtr;            /* pointer into the data area of <g>       */
    Int *       ptr;            /* pointer into the collect vector         */
    Int *       qtr;            /* pointer into the collect vector         */

    /* get the number of generators                                        */
    num = SC_NUMBER_RWS_GENERATORS(sc);
    rod = SC_RELATIVE_ORDERS(sc);

    /* <ww> must be a string                                               */
    if ( TNUM_OBJ(ww) != T_STRING ) {
        ErrorQuit( "collect vector must be a mutable string not a %s",
                   (Int)TNAM_OBJ(ww), 0L );
        return -1;
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(ww) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        i = (SIZE_OBJ(ww)-sizeof(Obj)-1) / sizeof(Int);
        ResizeBag( ww, num*sizeof(Int)+sizeof(Obj)+1 );
        qtr = (Int*)(ADDR_OBJ(ww)+1);
        for ( i = i+1;  i < num;  i++ )
            qtr[i] = 0;
    }

    /* <uu> must be a string                                               */
    if ( TNUM_OBJ(uu) != T_STRING ) {
        ErrorQuit( "collect vector must be a mutable string not a %s",
                   (Int)TNAM_OBJ(uu), 0L );
        return -1;
    }

    /* fix the length                                                      */
    if ( SIZE_OBJ(uu) != num*sizeof(Int)+sizeof(Obj)+1 ) {
        i = (SIZE_OBJ(uu)-sizeof(Obj)-1) / sizeof(Int);
        ResizeBag( uu, num*sizeof(Int)+sizeof(Obj)+1 );
        qtr = (Int*)(ADDR_OBJ(uu)+1);
        for ( i = i+1;  i < num;  i++ )
            qtr[i] = 0;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE( SC_DEFAULT_TYPE(sc) );

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* use <g> as right argument for the collector                         */
    g = NewWord(SC_DEFAULT_TYPE(sc), 1);

    /* start clearing <ww>, storing the result in <uu>                     */
    ptr = (Int*)(ADDR_OBJ(ww)+1);
    qtr = (Int*)(ADDR_OBJ(uu)+1);
    gtr = DATA_WORD(g);
    for ( i = 0;  i < num; i++, ptr++, qtr++ ) {
        ro = INT_INTOBJ(ELMW_LIST(rod,i+1));
        *qtr = ( *qtr - *ptr ) % ro;
        if ( *qtr < 0 )  *qtr += ro;
        if ( *qtr != 0 ) {
            *gtr = ( i << ebits ) | ( *qtr & expm );
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
    WordVectorAndClear<UInt1>,
    VectorWord<UInt1>,
    SingleCollectWord<UInt1>,
    Solution<UInt1>,
};

/****************************************************************************
**
*V  C16Bits_SingleCollector
*/
FinPowConjCol C16Bits_SingleCollector = {
    WordVectorAndClear<UInt2>,
    VectorWord<UInt2>,
    SingleCollectWord<UInt2>,
    Solution<UInt2>,
};

/****************************************************************************
**
*V  C32Bits_SingleCollector
*/
FinPowConjCol C32Bits_SingleCollector = {
    WordVectorAndClear<UInt4>,
    VectorWord<UInt4>,
    SingleCollectWord<UInt4>,
    Solution<UInt4>,
};

/****************************************************************************
**
*F * * * * * * * * * * *  combinatorial collectors  * * * * * * * * * * * * *
**
**  Here the combinatorial collectors are set up.  They behave like single
**  collectors and therefore can be used in the same way.
*/

/****************************************************************************
**
**  The following functions are  used to add  a word into the exponent vector
**  without collection.  There are three different cases that can occur:
**
**  Add   a word  into  the exponent  vector.   Here we   can  use the global
**  exponent.
**
**  Add  a commutator   into the exponent  vector.   In  this  case the first
**  generator in the conjugate has to be skipped.  Here we can use the global
**  exponent.
**
**  Add part  of a word  into the  exponent vector.   Here  we cannot use the
**  global exponent because the beginning of  the word might not commute with
**  the rest.
**/
template <typename UIntN>
static void AddWordIntoExpVec(Int *         v,
                              const UIntN * w,
                              Int           e,
                              Int           ebits,
                              UInt          expm,
                              Int           p,
                              const Obj *   pow,
                              Int           lpow)
{

    const UIntN * wend = w + (INT_INTOBJ((((const Obj*)(w))[-1])) - 1);
    Int        i;
    Int        ex;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1;
        v[ i ] += ((*w) & expm) * e;      /* overflow check necessary? */
        if ( p <= v[i] ) {
            ex = v[i] / p;
            v[i] -= ex * p;
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                AddWordIntoExpVec(
                    v, CONST_DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

template <typename UIntN>
static void AddCommIntoExpVec(Int *         v,
                              const UIntN * w,
                              Int           e,
                              Int           ebits,
                              UInt          expm,
                              Int           p,
                              const Obj *   pow,
                              Int           lpow)
{

    const UIntN * wend = w + (INT_INTOBJ((((const Obj*)(w))[-1])) - 1);
    Int        i;
    Int        ex;

    /* Skip the first generator because we need the commutator here.  */
    w++;
    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1;
        v[ i ] += ((*w) & expm) * e;      /* overflow check necessary? */
        if ( p <= v[i] ) {
            ex = v[i] / p;
            v[i] -= ex * p;
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                AddWordIntoExpVec(
                    v, CONST_DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

template <typename UIntN>
static void AddPartIntoExpVec(Int *         v,
                              const UIntN * w,
                              const UIntN * wend,
                              Int           ebits,
                              UInt          expm,
                              Int           p,
                              const Obj *   pow,
                              Int           lpow)
{

    Int        i;
    Int        ex;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1;
        v[ i ] += ((*w) & expm);     /* overflow check necessary? */
        if ( p <= v[i] ) {
            ex = v[i] / p;
            v[i] -= ex * p;
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                AddWordIntoExpVec(
                    v, CONST_DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

/****************************************************************************
**
*F  CombiCollectWord( <sc>, <vv>, <w> )
**
**  If a stack overflow occurs, we simply stop and return false.
*/
template <typename UIntN>
Int CombiCollectWord(Obj sc, Obj vv, Obj w)
{
    Int         ebits;      /* number of bits in the exponent              */
    UInt        expm;       /* unsigned exponent mask                      */
    UInt        exps;       /* sign exponent mask                          */

    Obj         vnw;        /* word stack                                  */
    const UIntN ** nw;      /* address of <vnw>                            */
    Obj         vlw;        /* last syllable stack                         */
    const UIntN ** lw;      /* address of <vlw>                            */
    Obj         vpw;        /* current syllable stack                      */
    const UIntN ** pw;      /* address of <vpw>                            */
    Obj         vew;        /* unprocessed exponent stack                  */
    UIntN *     ew;         /* address of <vew>                            */
    Obj         vge;        /* global exponent stack                       */
    Int *       ge;         /* address of <vge>                            */

    Obj         vpow;       /* rhs of power relations                      */
    Int         lpow;       /* length of <vpow>                            */
    const Obj * pow;        /* address of <vpow>                           */

    Obj         vcnj;       /* rhs of conjugate relations                  */
    Int         lcnj;       /* length of <vcnj>                            */
    const Obj * cnj;        /* address of <vcnj>                           */

    const Obj * avc;        /* address of the avector                      */
    const Obj * avc2;       /* address of the avector 2                    */
    const Obj * wt;         /* address of the weights array                */
    const Obj * gns;        /* address of the list of generators           */
    const Obj * ro;         /* address of the list of relative orders      */
    const Obj * inv;        /* address of the list of inverses             */

    Int *       v;          /* address of <vv>                             */

    Int         max;        /* maximal stack size                          */
    Int         sp;         /* stack pointer                               */
    Int         i, j;       /* loop variable                               */
    Int         gn;         /* current generator number                    */
    Int         ex;         /* current exponent                            */
    Int         cl;         /* p-class of the collector                    */
    Int         p;          /* the prime                                   */

    Obj         tmp;        /* temporary obj for power                     */

    Int         resized = 0;/* indicates whether a Resize() happened       */

    /* if <w> is the identity return now                                   */
    if ( NPAIRS_WORD(w) == 0 ) {
        return SC_NUMBER_RWS_GENERATORS(sc);
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE( SC_DEFAULT_TYPE(sc) );

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* get the exponent sign masks                                         */
    exps = 1UL << (ebits-1);

    /* <nw> contains the stack of words to insert                          */
    vnw = CollectorsState()->SC_NW_STACK;

    /* <lw> contains the word end of the word in <nw>                      */
    vlw = CollectorsState()->SC_LW_STACK;

    /* <pw> contains the position of the word in <nw> to look at           */
    vpw = CollectorsState()->SC_PW_STACK;

    /* <ew> contains the unprocessed exponents at position <pw>            */
    vew = CollectorsState()->SC_EW_STACK;

    /* <ge> contains the global exponent of the word                       */
    vge = CollectorsState()->SC_GE_STACK;

    /* get the maximal stack size                                          */
    max = CollectorsState()->SC_MAX_STACK_SIZE;

    /* ensure that the stacks are large enough                             */
    const UInt desiredStackSize = sizeof(Obj) * (max + 2);
    if ( SIZE_OBJ(vnw) < desiredStackSize ) {
        ResizeBag( vnw, desiredStackSize );
        resized = 1;
    }
    if ( SIZE_OBJ(vlw) < desiredStackSize ) {
        ResizeBag( vlw, desiredStackSize );
        resized = 1;
    }
    if ( SIZE_OBJ(vpw) < desiredStackSize ) {
        ResizeBag( vpw, desiredStackSize );
        resized = 1;
    }
    if ( SIZE_OBJ(vew) < desiredStackSize ) {
        ResizeBag( vew, desiredStackSize );
        resized = 1;
    }
    if ( SIZE_OBJ(vge) < desiredStackSize ) {
        ResizeBag( vge, desiredStackSize );
        resized = 1;
    }
    if( resized ) return -1;

    /* from now on we use addresses instead of handles most of the time    */
    v  = (Int*)ADDR_OBJ(vv);
    nw = (const UIntN**)(CONST_ADDR_OBJ(vnw)+1);
    lw = (const UIntN**)(CONST_ADDR_OBJ(vlw)+1);
    pw = (const UIntN**)(CONST_ADDR_OBJ(vpw)+1);
    ew = (UIntN*)(ADDR_OBJ(vew)+1);
    ge = (Int*)(ADDR_OBJ(vge)+1);

    /* conjugates, powers, order, generators, avector, inverses            */
    vpow = SC_POWERS(sc);
    lpow = LEN_PLIST(vpow);
    pow  = CONST_ADDR_OBJ(vpow);

    vcnj = SC_CONJUGATES(sc);
    lcnj = LEN_PLIST(vcnj);
    (void) lcnj; /* please compiler -- lcnj not actually used */
    cnj  = CONST_ADDR_OBJ(vcnj);

    avc = CONST_ADDR_OBJ( SC_AVECTOR(sc) );
    gns = CONST_ADDR_OBJ( SC_RWS_GENERATORS(sc) );

    cl   = INT_INTOBJ( SC_CLASS(sc) );
    wt   = CONST_ADDR_OBJ( SC_WEIGHTS(sc) );
    avc2 = CONST_ADDR_OBJ( SC_AVECTOR2(sc) );

    ro  = CONST_ADDR_OBJ( SC_RELATIVE_ORDERS(sc) );
    p   = INT_INTOBJ(ro[1]);
    inv = CONST_ADDR_OBJ( SC_INVERSES(sc) );

    /* initialize the stack with <w>                                        */
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

        /* now move the next generator/word to the correct position        */
        else {

            /* get generator number                                        */
            gn = ((**pw) >> ebits) + 1;

            /* collect a single generator on the stack                     */
            if( *lw == *nw && INT_INTOBJ(avc[gn]) == gn ) {
              v[gn] += *ew * *ge;
              *ew = *ge = 0;
              if ( p <= v[gn] ) {
                ex = v[gn] / p;
                v[gn] -= ex * p;
                if ( gn <= lpow && pow[gn] && 0 < NPAIRS_WORD(pow[gn]) ) {
                    AddWordIntoExpVec(
                      v, CONST_DATA_WORD(pow[gn]), ex,
                      ebits, expm, p, pow, lpow  );
                }
              }

              continue;
            }

            /* collect a whole word exponent pair                          */
            else if( sp > 1 && *pw == *nw && INT_INTOBJ(avc[gn]) == gn ) {
              AddWordIntoExpVec(
                   v, *pw, *ge, ebits, expm, p, pow, lpow  );
              *pw = *lw;
              *ew = *ge = 0;

              continue;
            }

            /* collect the rest of a word                                  */
            else if( sp > 1 && INT_INTOBJ(avc[gn]) == gn ) {
              AddPartIntoExpVec(
                   v, *pw, *lw, ebits, expm, p, pow, lpow  );
              *pw = *lw;
              *ew = 0;

              continue;
            }

            else if( sp > 1 && 3*INT_INTOBJ(wt[gn]) > cl ) {
                /* Collect <gn>^<ew> without stacking commutators.
                   This is step 6 in (Vaughan-Lee 1990).                   */
                i = INT_INTOBJ(avc[gn]);
                for ( ;  gn < i;  i-- ) {
                    if ( v[i] && gn <= LEN_PLIST(cnj[i]) ) {
                        tmp = ELM_PLIST( cnj[i], gn );
                        if ( tmp != 0 && 0 < NPAIRS_WORD(tmp) ) {
                            AddCommIntoExpVec(
                                v, CONST_DATA_WORD(tmp), v[i] * (*ew),
                                ebits, expm, p, pow, lpow );
                        }
                    }
                }

                v[gn] += (*ew);
                (*ew) = 0;

                /* If the exponent is too big, we have to stack up the
                   entries in the exponent vector.                         */
                if ( p <= v[gn] ) {
                    ex  = v[gn] / p;
                    v[gn] -= ex * p;
                    if ( gn <= lpow && pow[gn] && 0 < NPAIRS_WORD(pow[gn]) ) {
                        /* stack the exponent vector first. */
                        i = INT_INTOBJ(avc[gn]);
                        for ( ; gn < i;  i-- ) {
                            if ( v[i] ) {
                                SC_PUSH_GEN( gns[i], v[i] );
                                v[i] = 0;
                            }
                        }
                        AddWordIntoExpVec(
                             v, CONST_DATA_WORD(pow[i]), ex,
                             ebits, expm, p, pow, lpow  );
                    }
                }
            }
            /* we have to move <gn> step by step                           */
            else {

              (*ew)--;
              v[gn]++;

              i = INT_INTOBJ(avc[gn]);
              if( sp > 1 ) {
                  /* Do combinatorial collection as far as possible.       */
                  j = INT_INTOBJ(avc2[gn]);
                  for( ; j < i; i-- )
                      if( v[i] && gn <= LEN_PLIST(cnj[i]) ) {
                          tmp = ELM_PLIST( cnj[i], gn );
                          if ( tmp != 0 && 0 < NPAIRS_WORD(tmp) )
                              AddCommIntoExpVec(
                                  v, CONST_DATA_WORD(tmp), v[i],
                                  ebits, expm, p, pow, lpow );
                      }
              }

              /* Find the first position in v from where on ordinary
                 collection  has to be applied.                            */
              for( ; gn < i; i-- )
                  if( v[i] && gn <= LEN_PLIST(cnj[i]) ) {
                      tmp = ELM_PLIST( cnj[i], gn );
                      if ( tmp != 0 && 0 < NPAIRS_WORD(tmp) )
                        break;
                  }

              /* Stack up this part of v if we run through the next
                 for-loop or if a power relation will be applied           */
              if( gn < i || (p <= v[gn] &&
                  gn <= lpow && pow[gn] && 0 < NPAIRS_WORD(pow[gn])) ) {
                j = INT_INTOBJ(avc[gn]);
                for( ; i < j; j-- )
                  if( v[j] ) {
                    SC_PUSH_GEN( gns[j], v[j] );
                    v[j] = 0;
                  }
              }

                /* We finish with ordinary collection from the left        */
                for ( ;  gn < i;  i-- ) {
                    if ( v[i] ) {
                      if ( LEN_PLIST(cnj[i]) < gn ) {
                        SC_PUSH_GEN( gns[i], v[i] );
                      }
                      else {
                        tmp = ELM_PLIST( cnj[i], gn );
                        if ( tmp == 0 || NPAIRS_WORD(tmp) == 0 ) {
                          SC_PUSH_GEN( gns[i], v[i] );
                        }
                        else {
                          SC_PUSH_WORD( tmp, v[i] );
                        }
                      }
                      v[i] = 0;
                    }
                }
            }

            /* check that the exponent is not too big                      */
            if ( p <= v[gn] ) {
                i = v[gn] / p;
                v[gn] -= i * p;
                if ( gn <= lpow && pow[gn] && 0 < NPAIRS_WORD(pow[gn]) ) {
                    SC_PUSH_WORD( pow[gn], i );
                }
            }
        }
    }
    return SC_NUMBER_RWS_GENERATORS(sc);
}

/****************************************************************************
**
*V  C8Bits_CombiCollector
*/
FinPowConjCol C8Bits_CombiCollector = {
    WordVectorAndClear<UInt1>,
    VectorWord<UInt1>,
    CombiCollectWord<UInt1>,
    Solution<UInt1>,
};

/****************************************************************************
**
*V  C16Bits_CombiCollector
*/
FinPowConjCol C16Bits_CombiCollector = {
    WordVectorAndClear<UInt2>,
    VectorWord<UInt2>,
    CombiCollectWord<UInt2>,
    Solution<UInt2>,
};

/****************************************************************************
**
*V  C32Bits_CombiCollector
*/
FinPowConjCol C32Bits_CombiCollector = {
    WordVectorAndClear<UInt4>,
    VectorWord<UInt4>,
    CombiCollectWord<UInt4>,
    Solution<UInt4>,
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
        res = NewWord(type, 0);
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
    RequirePositiveSmallInt("SET_SCOBJ_MAX_STACK_SIZE", size, "size");
    CollectorsState()->SC_MAX_STACK_SIZE = INT_INTOBJ(size);
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
 /* type        = */ MODULE_BUILTIN,
 /* name        = */ "collectors",
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
 /* moduleStateSize      = */ sizeof(CollectorsState_),
 /* moduleStateOffsetPtr = */ &CollectorsStateOffset,
 /* initModuleState      = */ InitModuleState,
 /* destroyModuleState   = */ 0,
};

StructInitInfo * InitInfoCollectors ( void )
{
    return &module;
}
