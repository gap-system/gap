/****************************************************************************
**
*F  CombiCollectWord( <sc>, <vv>, <w> )
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
        TLS(SC_MAX_STACK_SIZE) *= 2; \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(word); \
    *++lw = *nw + (INT_INTOBJ((((Obj*)(*nw))[-1])) - 1); \
    *++pw = *nw; \
    *++ew = (**pw) & expm; \
    *++ge = exp

#define SC_PUSH_GEN( gen, exp ) \
    if ( ++sp == max ) { \
        TLS(SC_MAX_STACK_SIZE) *= 2; \
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
static void AddWordIntoExpVec( Int *v, UIntN *w, Int e, 
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    UIntN *    wend = w + (INT_INTOBJ((((Obj*)(w))[-1])) - 1);
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
                    v, (UIntN*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

static void AddCommIntoExpVec( Int *v, UIntN *w, Int e, 
                           Int ebits, UInt expm, 
                           Int p, Obj *pow, Int lpow ) {

    UIntN *    wend = w + (INT_INTOBJ((((Obj*)(w))[-1])) - 1);
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
                    v, (UIntN*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

static void AddPartIntoExpVec( Int *v, UIntN *w, UIntN *wend,
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
                AddWordIntoExpVec( 
                    v, (UIntN*)DATA_WORD(pow[i]), ex,
                    ebits, expm, p, pow, lpow  );
            }
        }
    }
}

Int CombiCollectWord ( Obj sc, Obj vv, Obj w )
{
    Int         ebits;      /* number of bits in the exponent              */
    UInt        expm;       /* unsigned exponent mask                      */
    UInt        exps;       /* sign exponent mask                          */

    Obj         vnw;        /* word stack                                  */
    UIntN **    nw;         /* address of <vnw>                            */
    Obj         vlw;        /* last syllable stack                         */
    UIntN **    lw;         /* address of <vlw>                            */
    Obj         vpw;        /* current syllable stack                      */
    UIntN **    pw;         /* address of <vpw>                            */
    Obj         vew;        /* unprocessed exponent stack                  */
    UIntN *     ew;         /* address of <vew>                            */
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
    vnw = TLS(SC_NW_STACK);

    /* <lw> contains the word end of the word in <nw>                      */
    vlw = TLS(SC_LW_STACK);

    /* <pw> contains the position of the word in <nw> to look at           */
    vpw = TLS(SC_PW_STACK);

    /* <ew> contains the unprocessed exponents at position <pw>            */
    vew = TLS(SC_EW_STACK);

    /* <ge> contains the global exponent of the word                       */
    vge = TLS(SC_GE_STACK);

    /* get the maximal stack size                                          */
    max = TLS(SC_MAX_STACK_SIZE);

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
    nw = (UIntN**)ADDR_OBJ(vnw);
    lw = (UIntN**)ADDR_OBJ(vlw);
    pw = (UIntN**)ADDR_OBJ(vpw);
    ew = (UIntN*)ADDR_OBJ(vew);
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
                      v, (UIntN*)DATA_WORD(pow[gn]), ex, 
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
                                v, (UIntN*)DATA_WORD(tmp), v[i] * (*ew),
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
                             v, (UIntN*)DATA_WORD(pow[i]), ex,
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
                                  v, (UIntN*)DATA_WORD(tmp), v[i],
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

#undef AddWordIntoExpVec
#undef AddCommIntoExpVec
#undef AddPartIntoExpVec
#undef CombiCollectWord
#undef UIntN
