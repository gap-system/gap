/****************************************************************************
**
*F  WordVectorAndClear( <type>, <vv>, <num> )
*/
Obj WordVectorAndClear ( Obj type, Obj vv, Int num )
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
    NEW_WORD_READ_WRITE( obj, type, num );


    /* clear <vv>                                                          */
    ptr = (UIntN*)DATA_WORD(obj);
    qtr = (Int*)(ADDR_OBJ(vv)+1);
    for ( i = 1, j = 0;  i <= num;  i++,  qtr++ ) {
        if ( *qtr != 0 ) {
            *ptr++ = ((i-1) << ebits) | (*qtr & expm);
            *qtr = 0;
            j++;
        }
    }

    /* correct the size of <obj>                                           */
    (void) RESIZE_WORD( obj, j );

    MakeBagReadOnly( obj );

    return obj;
}


/****************************************************************************
**
*F  VectorWord( <vv>, <v>, <num> )
**
**  WARNING: This function assumes that <vv> is cleared!
*/
Int VectorWord ( Obj vv, Obj v, Int num )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    UInt        exps;           /* sign exponent mask                      */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         pos;            /* generator number                        */
    Int *       qtr;            /* pointer into the collect vector         */
    UIntN *     ptr;            /* pointer into the data area of <obj>     */

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
    ptr = (UIntN*)DATA_WORD(v);
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
*F  SingleCollectWord( <sc>, <vv>, <w> )
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
        TLS(SC_MAX_STACK_SIZE) *= 2; \
        return -1; \
    } \
    *++nw = (void*)DATA_WORD(word); \
    *++lw = *nw + (INT_INTOBJ((((Obj*)(*nw))[-1])) - 1); \
    *++pw = *nw; \
    *++ew = (**pw) & expm; \
    *++ge = exp

#define SC_POP_WORD() \
    sp--;  nw--;  lw--;  pw--;  ew--;  ge--


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
static Int SAddWordIntoExpVec( Int *v, UIntN *w, Int e, 
                           Int ebits, UInt expm, 
                           Obj *ro, Obj *pow, Int lpow ) {

    UIntN *    wend = w + (INT_INTOBJ((((Obj*)(w))[-1])) - 1);
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
                    v, (UIntN*)DATA_WORD(pow[i]), ex,
                    ebits, expm, ro, pow, lpow  );
            }
        }
        if( start < i && v[i] ) start = i;
    }
    return start;
}

static Int SAddPartIntoExpVec( Int *v, UIntN *w, UIntN *wend,
                           Int ebits, UInt expm, 
                           Obj* ro, Obj *pow, Int lpow ) {

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
                    v, (UIntN*)DATA_WORD(pow[i]), ex,
                    ebits, expm, ro, pow, lpow  );
            }
        }
        if( start < i && v[i] ) start = i;
    }
    return start;
}

Int SingleCollectWord ( Obj sc, Obj vv, Obj w )
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
    Obj *       gns;        /* address of the list of generators           */
    Obj *       ro;         /* address of the list of relative orders      */
    Obj *       inv;        /* address of the list of inverses             */

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

    /* conjujagtes, powers, order, generators, avector, inverses           */
    vpow = SC_POWERS(sc);
    lpow = LEN_PLIST(vpow);
    pow  = ADDR_OBJ(vpow);

    vcnj = SC_CONJUGATES(sc);
    lcnj = LEN_PLIST(vcnj);
    (void) lcnj; /* please compiler -- lcnj not actually used */
    cnj  = ADDR_OBJ(vcnj);

    avc = ADDR_OBJ( SC_AVECTOR(sc) );
    gns = ADDR_OBJ( SC_RWS_GENERATORS(sc) );

    ro  = ADDR_OBJ( SC_RELATIVE_ORDERS(sc) );
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
#undef SC_PUSH_WORD
#undef SC_POP_WORD


/****************************************************************************
**
*F  Solution( <sc>, <ww>, <uu>, <func> )
*/
Int Solution( 
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
    UIntN *     gtr;            /* pointer into the data area of <g>       */
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
    gtr = (UIntN*)DATA_WORD(g);
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

#undef WordVectorAndClear
#undef VectorWord
#undef SingleCollectWord
#undef SAddWordIntoExpVec
#undef SAddPartIntoExpVec
#undef SingleCollectWord
#undef Solution
#undef UIntN
