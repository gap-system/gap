/****************************************************************************
**
*W  objccoll.c                  GAP source                      Werner Nickel
**
**
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file  contains  the collection functions of  combinatorial collectors
**  for finite p-groups.  The code in this file  is an extension to the single
**  collector module.  All necessary initialisations  are done in that module.
**  The interface to a combinatorial collection function is identical with the
**  interface to the corresponding single collector function.
**
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

#include        "objfgelm.h"            /* objects of free groups          */

#include        "objscoll.h"            /* single collector                */

#include        "objccoll.h"            /* combinatorial collector         */

/****************************************************************************
**
*F  C8Bits_CombiCollectWord( <sc>, <vv>, <w> )
**
**  If a stack overflow occurs, we simply stop and return false.
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
        SC_SET_MAX_STACK_SIZE( sc, 2 * SC_MAX_STACK_SIZE(sc) ); \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(word); \
    *++lw = *nw + (INT_INTOBJ((((Obj*)(*nw))[-1])) - 1); \
    *++pw = *nw; \
    *++ew = (**pw) & expm; \
    *++ge = exp

#define SC_PUSH_GEN( gen, exp ) \
    if ( ++sp == max ) { \
        SC_SET_MAX_STACK_SIZE( sc, 2 * SC_MAX_STACK_SIZE(sc) ); \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(gen); \
    *++lw = *nw; \
    *++pw = *nw; \
    *++ew = exp; \
    *++ge = 1

#define SC_POP_WORD() \
    sp--;  nw--;  lw--;  pw--;  ew--;  ge--

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
static void C8Bits_AddWordIntoExpVec( Int *v, UInt1 *w, Int e, 
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    UInt1 *    wend = w + (INT_INTOBJ((((Obj*)(w))[-1])) - 1);
    Int        i;
    Int        ex;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1; 
        v[ i ] += ((*w) & expm) * e;      /* overflow check necessary? */
        if ( p <= v[i] ) {
            ex = v[i] / p;
            v[i] -= ex * p;
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                C8Bits_AddWordIntoExpVec( 
                    v, (UInt1*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

static void C8Bits_AddCommIntoExpVec( Int *v, UInt1 *w, Int e, 
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    UInt1 *    wend = w + (INT_INTOBJ((((Obj*)(w))[-1])) - 1);
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
                C8Bits_AddWordIntoExpVec( 
                    v, (UInt1*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

static void C8Bits_AddPartIntoExpVec( Int *v, UInt1 *w, UInt1 *wend,
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    Int        i;
    Int        ex;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1; 
        v[ i ] += ((*w) & expm);     /* overflow check necessary? */
        if ( p <= v[i] ) {
            ex = v[i] / p;
            v[i] -= ex * p;
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                C8Bits_AddWordIntoExpVec( 
                    v, (UInt1*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

Int C8Bits_CombiCollectWord ( Obj sc, Obj vv, Obj w )
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
    Obj *       avc2;       /* address of the avector 2                    */
    Obj *       wt;         /* address of the weights array                */
    Obj *       gns;        /* address of the list of generators           */
    Obj *       ro;         /* address of the list of relative orders      */
    Obj *       inv;        /* address of the list of inverses             */

    Int *       v;          /* address of <vv>                             */

    Int         max;        /* maximal stack size                          */
    Int         sp;         /* stack pointer                               */
    Int         i, j;       /* loop variable                               */
    Int         gn;         /* current generator number                    */
    Int         ex;         /* current exponent                            */
    Int         cl;         /* p-class of the collector                    */
    Int         p;          /* the prime                                   */

    Obj         tmp;        /* temporary obj for power                     */

    Int         resized = 0;/* indicates whether a Resize() happend        */

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
        resized = 1;
    }
    if ( SIZE_OBJ(vlw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vlw, sizeof(Obj)*(max+1) );
        RetypeBag( vlw, T_STRING );
        resized = 1;
    }
    if ( SIZE_OBJ(vpw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vpw, sizeof(Obj)*(max+1) );
        RetypeBag( vpw, T_STRING );
        resized = 1;
    }
    if ( SIZE_OBJ(vew)/sizeof(Obj) < max+1 ) {
        ResizeBag( vew, sizeof(Obj)*(max+1) );
        RetypeBag( vew, T_STRING );
        resized = 1;
    }
    if ( SIZE_OBJ(vge)/sizeof(Obj) < max+1 ) {
        ResizeBag( vge, sizeof(Obj)*(max+1) );
        RetypeBag( vge, T_STRING );
        resized = 1;
    }
    if( resized ) return -1;

    /* from now on we use addresses instead of handles most of the time    */
    v  = (Int*)ADDR_OBJ(vv);
    nw = (UInt1**)ADDR_OBJ(vnw);
    lw = (UInt1**)ADDR_OBJ(vlw);
    pw = (UInt1**)ADDR_OBJ(vpw);
    ew = (UInt1*)ADDR_OBJ(vew);
    ge = (Int*)ADDR_OBJ(vge);

    /* conjugates, powers, order, generators, avector, inverses            */
    vpow = SC_POWERS(sc);
    lpow = LEN_PLIST(vpow);
    pow  = ADDR_OBJ(vpow);

    vcnj = SC_CONJUGATES(sc);
    lcnj = LEN_PLIST(vcnj);
    (void) lcnj; /* please compiler -- lcnj not actually used */
    cnj  = ADDR_OBJ(vcnj);

    avc = ADDR_OBJ( SC_AVECTOR(sc) );
    gns = ADDR_OBJ( SC_RWS_GENERATORS(sc) );

    cl   = INT_INTOBJ( SC_CLASS(sc) );
    wt   = ADDR_OBJ( SC_WEIGHTS(sc) );
    avc2 = ADDR_OBJ( SC_AVECTOR2(sc) );

    ro  = ADDR_OBJ( SC_RELATIVE_ORDERS(sc) );
    p   = INT_INTOBJ(ro[1]);
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
                    C8Bits_AddWordIntoExpVec( 
                      v, (UInt1*)DATA_WORD(pow[gn]), ex, 
                      ebits, expm, p, pow, lpow  );
                }
              }

              continue;
            }

            /* collect a whole word exponent pair                          */
            else if( sp > 1 && *pw == *nw && INT_INTOBJ(avc[gn]) == gn ) {
              C8Bits_AddWordIntoExpVec( 
                   v, *pw, *ge, ebits, expm, p, pow, lpow  );
              *pw = *lw;
              *ew = *ge = 0;

              continue;
            }

            /* collect the rest of a word                                  */
            else if( sp > 1 && INT_INTOBJ(avc[gn]) == gn ) {
              C8Bits_AddPartIntoExpVec( 
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
                            C8Bits_AddCommIntoExpVec( 
                                v, (UInt1*)DATA_WORD(tmp), v[i] * (*ew),
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
                        C8Bits_AddWordIntoExpVec( 
                             v, (UInt1*)DATA_WORD(pow[i]), ex,
                             ebits, expm, p, pow, lpow  );
                    }
                }
            }
            /* we have to move <gn> step by step                           */
            else {
              
              (*ew)--;
              v[gn]++;

              i = INT_INTOBJ(avc[gn]);
              j = INT_INTOBJ(avc2[gn]);
              if( sp > 1 ) {
                  /* Do combinatorial collection as far as possible.       */
                  for( ; j < i; i-- )
                      if( v[i] && gn <= LEN_PLIST(cnj[i]) ) {
                          tmp = ELM_PLIST( cnj[i], gn );
                          if ( tmp != 0 && 0 < NPAIRS_WORD(tmp) )
                              C8Bits_AddCommIntoExpVec( 
                                  v, (UInt1*)DATA_WORD(tmp), v[i],
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
#undef SC_PUSH_WORD
#undef SC_PUSH_GEN
#undef SC_POP_WORD

/****************************************************************************
**
*F  C16Bits_CombiCollectWord( <sc>, <vv>, <w> )
**
**  If a stack overflow occurs, we simply stop and return false.
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
        SC_SET_MAX_STACK_SIZE( sc, 2 * SC_MAX_STACK_SIZE(sc) ); \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(word); \
    *++lw = *nw + (INT_INTOBJ((((Obj*)(*nw))[-1])) - 1); \
    *++pw = *nw; \
    *++ew = (**pw) & expm; \
    *++ge = exp

#define SC_PUSH_GEN( gen, exp ) \
    if ( ++sp == max ) { \
        SC_SET_MAX_STACK_SIZE( sc, 2 * SC_MAX_STACK_SIZE(sc) ); \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(gen); \
    *++lw = *nw; \
    *++pw = *nw; \
    *++ew = exp; \
    *++ge = 1

#define SC_POP_WORD() \
    sp--;  nw--;  lw--;  pw--;  ew--;  ge--

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
static void C16Bits_AddWordIntoExpVec( Int *v, UInt2 *w, Int e, 
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    UInt2 *    wend = w + (INT_INTOBJ((((Obj*)(w))[-1])) - 1);
    Int        i;
    Int        ex;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1; 
        v[ i ] += ((*w) & expm) * e;      /* overflow check necessary? */
        if ( p <= v[i] ) {
            ex = v[i] / p;
            v[i] -= ex * p;
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                C16Bits_AddWordIntoExpVec( 
                    v, (UInt2*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

static void C16Bits_AddCommIntoExpVec( Int *v, UInt2 *w, Int e, 
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    UInt2 *    wend = w + (INT_INTOBJ((((Obj*)(w))[-1])) - 1);
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
                C16Bits_AddWordIntoExpVec( 
                    v, (UInt2*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

static void C16Bits_AddPartIntoExpVec( Int *v, UInt2 *w, UInt2 *wend,
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    Int        i;
    Int        ex;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1; 
        v[ i ] += ((*w) & expm);     /* overflow check necessary? */
        if ( p <= v[i] ) {
            ex = v[i] / p;
            v[i] -= ex * p;
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                C16Bits_AddWordIntoExpVec( 
                    v, (UInt2*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

Int C16Bits_CombiCollectWord ( Obj sc, Obj vv, Obj w )
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
    Obj *       avc2;       /* address of the avector 2                    */
    Obj *       wt;         /* address of the weights array                */
    Obj *       gns;        /* address of the list of generators           */
    Obj *       ro;         /* address of the list of relative orders      */
    Obj *       inv;        /* address of the list of inverses             */

    Int *       v;          /* address of <vv>                             */

    Int         max;        /* maximal stack size                          */
    Int         sp;         /* stack pointer                               */
    Int         i, j;       /* loop variable                               */
    Int         gn;         /* current generator number                    */
    Int         ex;         /* current exponent                            */
    Int         cl;         /* p-class of the collector                    */
    Int         p;          /* the prime                                   */

    Obj         tmp;        /* temporary obj for power                     */

    Int         resized = 0;/* indicates whether a Resize() happend        */

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
        resized = 1;
    }
    if ( SIZE_OBJ(vlw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vlw, sizeof(Obj)*(max+1) );
        RetypeBag( vlw, T_STRING );
        resized = 1;
    }
    if ( SIZE_OBJ(vpw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vpw, sizeof(Obj)*(max+1) );
        RetypeBag( vpw, T_STRING );
        resized = 1;
    }
    if ( SIZE_OBJ(vew)/sizeof(Obj) < max+1 ) {
        ResizeBag( vew, sizeof(Obj)*(max+1) );
        RetypeBag( vew, T_STRING );
        resized = 1;
    }
    if ( SIZE_OBJ(vge)/sizeof(Obj) < max+1 ) {
        ResizeBag( vge, sizeof(Obj)*(max+1) );
        RetypeBag( vge, T_STRING );
        resized = 1;
    }
    if( resized ) return -1;

    /* from now on we use addresses instead of handles most of the time    */
    v  = (Int*)ADDR_OBJ(vv);
    nw = (UInt2**)ADDR_OBJ(vnw);
    lw = (UInt2**)ADDR_OBJ(vlw);
    pw = (UInt2**)ADDR_OBJ(vpw);
    ew = (UInt2*)ADDR_OBJ(vew);
    ge = (Int*)ADDR_OBJ(vge);

    /* conjugates, powers, order, generators, avector, inverses            */
    vpow = SC_POWERS(sc);
    lpow = LEN_PLIST(vpow);
    pow  = ADDR_OBJ(vpow);

    vcnj = SC_CONJUGATES(sc);
    lcnj = LEN_PLIST(vcnj);
    (void) lcnj; /* please compiler -- lcnj not actually used */
    cnj  = ADDR_OBJ(vcnj);

    avc = ADDR_OBJ( SC_AVECTOR(sc) );
    gns = ADDR_OBJ( SC_RWS_GENERATORS(sc) );

    cl   = INT_INTOBJ( SC_CLASS(sc) );
    wt   = ADDR_OBJ( SC_WEIGHTS(sc) );
    avc2 = ADDR_OBJ( SC_AVECTOR2(sc) );

    ro  = ADDR_OBJ( SC_RELATIVE_ORDERS(sc) );
    p   = INT_INTOBJ(ro[1]);
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
                    C16Bits_AddWordIntoExpVec( 
                      v, (UInt2*)DATA_WORD(pow[gn]), ex, 
                      ebits, expm, p, pow, lpow  );
                }
              }

              continue;
            }

            /* collect a whole word exponent pair                          */
            else if( sp > 1 && *pw == *nw && INT_INTOBJ(avc[gn]) == gn ) {
              C16Bits_AddWordIntoExpVec( 
                   v, *pw, *ge, ebits, expm, p, pow, lpow  );
              *pw = *lw;
              *ew = *ge = 0;

              continue;
            }

            /* collect the rest of a word                                  */
            else if( sp > 1 && INT_INTOBJ(avc[gn]) == gn ) {
              C16Bits_AddPartIntoExpVec( 
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
                            C16Bits_AddCommIntoExpVec( 
                                v, (UInt2*)DATA_WORD(tmp), v[i] * (*ew),
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
                        C16Bits_AddWordIntoExpVec( 
                             v, (UInt2*)DATA_WORD(pow[i]), ex,
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
                              C16Bits_AddCommIntoExpVec( 
                                  v, (UInt2*)DATA_WORD(tmp), v[i],
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
#undef SC_PUSH_WORD
#undef SC_PUSH_GEN
#undef SC_POP_WORD

/****************************************************************************
**
*F  C32Bits_CombiCollectWord( <sc>, <vv>, <w> )
**
**  If a stack overflow occurs, we simply stop and return false.
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
        SC_SET_MAX_STACK_SIZE( sc, 2 * SC_MAX_STACK_SIZE(sc) ); \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(word); \
    *++lw = *nw + (INT_INTOBJ((((Obj*)(*nw))[-1])) - 1); \
    *++pw = *nw; \
    *++ew = (**pw) & expm; \
    *++ge = exp

#define SC_PUSH_GEN( gen, exp ) \
    if ( ++sp == max ) { \
        SC_SET_MAX_STACK_SIZE( sc, 2 * SC_MAX_STACK_SIZE(sc) ); \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(gen); \
    *++lw = *nw; \
    *++pw = *nw; \
    *++ew = exp; \
    *++ge = 1

#define SC_POP_WORD() \
    sp--;  nw--;  lw--;  pw--;  ew--;  ge--

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
static void C32Bits_AddWordIntoExpVec( Int *v, UInt4 *w, Int e, 
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    UInt4 *    wend = w + (INT_INTOBJ((((Obj*)(w))[-1])) - 1);
    Int        i;
    Int        ex;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1; 
        v[ i ] += ((*w) & expm) * e;      /* overflow check necessary? */
        if ( p <= v[i] ) {
            ex = v[i] / p;
            v[i] -= ex * p;
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                C32Bits_AddWordIntoExpVec( 
                    v, (UInt4*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

static void C32Bits_AddPartIntoExpVec( Int *v, UInt4 *w, UInt4 *wend,
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    Int        i;
    Int        ex;

    for( ; w <= wend; w++ ) {
        i = ((*w) >> ebits) + 1; 
        v[ i ] += ((*w) & expm);     /* overflow check necessary? */
        if ( p <= v[i] ) {
            ex = v[i] / p;
            v[i] -= ex * p;
            if ( i <= lpow && pow[i] && 0 < NPAIRS_WORD(pow[i]) ) {
                C32Bits_AddWordIntoExpVec( 
                    v, (UInt4*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

static void C32Bits_AddCommIntoExpVec( Int *v, UInt4 *w, Int e, 
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    UInt4 *    wend = w + (INT_INTOBJ((((Obj*)(w))[-1])) - 1);
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
                C32Bits_AddWordIntoExpVec( 
                    v, (UInt4*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

Int C32Bits_CombiCollectWord ( Obj sc, Obj vv, Obj w )
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
    Obj *       avc2;       /* address of the avector 2                    */
    Obj *       wt;         /* address of the weights array                */
    Obj *       gns;        /* address of the list of generators           */
    Obj *       ro;         /* address of the list of relative orders      */
    Obj *       inv;        /* address of the list of inverses             */

    Int *       v;          /* address of <vv>                             */

    Int         max;        /* maximal stack size                          */
    Int         sp;         /* stack pointer                               */
    Int         i, j;       /* loop variable                               */
    Int         gn;         /* current generator number                    */
    Int         ex;         /* current exponent                            */
    Int         cl;         /* p-class of the collector                    */
    Int         p;          /* the prime                                   */

    Obj         tmp;        /* temporary obj for power                     */

    Int         resized = 0;/* indicates whether a Resize() happend        */

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
        resized = 1;
    }
    if ( SIZE_OBJ(vlw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vlw, sizeof(Obj)*(max+1) );
        RetypeBag( vlw, T_STRING );
        resized = 1;
    }
    if ( SIZE_OBJ(vpw)/sizeof(Obj) < max+1 ) {
        ResizeBag( vpw, sizeof(Obj)*(max+1) );
        RetypeBag( vpw, T_STRING );
        resized = 1;
    }
    if ( SIZE_OBJ(vew)/sizeof(Obj) < max+1 ) {
        ResizeBag( vew, sizeof(Obj)*(max+1) );
        RetypeBag( vew, T_STRING );
        resized = 1;
    }
    if ( SIZE_OBJ(vge)/sizeof(Obj) < max+1 ) {
        ResizeBag( vge, sizeof(Obj)*(max+1) );
        RetypeBag( vge, T_STRING );
        resized = 1;
    }
    if( resized ) return -1;

    /* from now on we use addresses instead of handles most of the time    */
    v  = (Int*)ADDR_OBJ(vv);
    nw = (UInt4**)ADDR_OBJ(vnw);
    lw = (UInt4**)ADDR_OBJ(vlw);
    pw = (UInt4**)ADDR_OBJ(vpw);
    ew = (UInt4*)ADDR_OBJ(vew);
    ge = (Int*)ADDR_OBJ(vge);

    /* conjugates, powers, order, generators, avector, inverses            */
    vpow = SC_POWERS(sc);
    lpow = LEN_PLIST(vpow);
    pow  = ADDR_OBJ(vpow);

    vcnj = SC_CONJUGATES(sc);
    lcnj = LEN_PLIST(vcnj);
    (void) lcnj; /* please compiler -- lcnj not actually used */
    cnj  = ADDR_OBJ(vcnj);

    avc = ADDR_OBJ( SC_AVECTOR(sc) );
    gns = ADDR_OBJ( SC_RWS_GENERATORS(sc) );

    cl   = INT_INTOBJ( SC_CLASS(sc) );
    wt   = ADDR_OBJ( SC_WEIGHTS(sc) );
    avc2 = ADDR_OBJ( SC_AVECTOR2(sc) );

    ro  = ADDR_OBJ( SC_RELATIVE_ORDERS(sc) );
    p   = INT_INTOBJ(ro[1]);
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
                    C32Bits_AddWordIntoExpVec( 
                      v, (UInt4*)DATA_WORD(pow[gn]), ex, 
                      ebits, expm, p, pow, lpow  );
                }
              }

              continue;
            }

            /* collect a whole word exponent pair                          */
            else if( sp > 1 && *pw == *nw && INT_INTOBJ(avc[gn]) == gn ) {
              C32Bits_AddWordIntoExpVec( 
                   v, *pw, *ge, ebits, expm, p, pow, lpow  );
              *pw = *lw;
              *ew = *ge = 0;

              continue;
            }

            /* collect the rest of a word                                  */
            else if( sp > 1 && INT_INTOBJ(avc[gn]) == gn ) {
              C32Bits_AddPartIntoExpVec( 
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
                            C32Bits_AddCommIntoExpVec( 
                                v, (UInt4*)DATA_WORD(tmp), (Int)(v[i] * (*ew)),
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
                        C32Bits_AddWordIntoExpVec( 
                             v, (UInt4*)DATA_WORD(pow[i]), ex,
                             ebits, expm, p, pow, lpow  );
                    }
                }
            }
            /* we have to move <gn> step by step                           */
            else {
              
              (*ew)--;
              v[gn]++;

              i = INT_INTOBJ(avc[gn]);
              j = INT_INTOBJ(avc2[gn]);
              if( sp > 1 ) {
                  /* Do combinatorial collection as far as possible.       */
                  for( ; j < i; i-- )
                      if( v[i] && gn <= LEN_PLIST(cnj[i]) ) {
                          tmp = ELM_PLIST( cnj[i], gn );
                          if ( tmp != 0 && 0 < NPAIRS_WORD(tmp) )
                              C32Bits_AddCommIntoExpVec( 
                                 v, (UInt4*)DATA_WORD(tmp), v[i],
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
#undef SC_PUSH_WORD
#undef SC_PUSH_GEN
#undef SC_POP_WORD


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
**
**  This module does  not   need much initialisation  because  all  necessary
**  initialisations are done in the single collector module.
*/


/****************************************************************************
**
*F  InitInfoCombiCollector()  . . . . . . . . . . . . table of init functions
**
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "objccoll",                         /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    0,                                  /* initKernel                     */
    0,                                  /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoCombiCollector ( void )
{
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  objccoll.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
