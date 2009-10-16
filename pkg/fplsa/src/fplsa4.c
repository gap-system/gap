/************************************************************************/
/*      File fplsa4.c   Last touch January 5, 1999                      */
/*      Calculation of finitely presented Lie superalgebras             */
/*      Version 4 of April 15, 1997.                                    */
/*      e-mail: kornyak@jinr.ru, gerdt@jinr.ru                          */
/*                      Contents                                        */
/*_0    Choice of compilation                                           */
/*_1    System constants                                                */
/*_2    Type definitions                                                */
/*_3    Constants and enumerations                                      */
/*_4    Macrodefinitions                                                */
/*_5    Global variables and arrays                                     */
/*_6    Function descriptions                                           */
/*_6_0    Main and top level functions                                  */
/*_6_1    Pairing functions                                             */
/*_6_2    Substitution (replacing) functions                            */
/*_6_3    Lie and scalar algebra functions                              */
/*_6_4    Scalar polynomial algebraic functions                         */
/*_6_5    Big number functions                                          */
/*_6_6    Copy and delete functions                                     */
/*_6_7    Technical functions                                           */
/*_6_8    Input functions                                               */
/*_6_9    Output functions                                              */
/*_6_10   Debugging functions                                           */
/************************************************************************/
/*_0    Choice of compilation============================================*/

#define RATIONAL_FIELD  /*  Working over the field R ??
                            otherwise over the ring Z */
#define ECHO_TO_SCREEN        /* Echo session to screen ?? */
#define RELATION_N_TO_SCREEN  /* Watch increasing RelationN ?? */
/*#define SPP_2000  /* Big ending computer ?? */
#define SPACE_STATISTICS  /* Space statistics ?? */
/*#define INTEGER_MAX_SIZE  /* Multiprecision number maximum size ?? */
/*#define INTEGER_ALLOCATION_CHECK  /* Control of integer allocations ?? */
/*#define POLY_ARRAY_ALLOCATION_CHECK /* Control of allocations of ??
                                       polynomial arrays in stack */

/* GAP output ?? */
/* Avoid message file, session file,                              */
/*       compulsory suffix '.in' for input file,                  */
/*       and printing comments to the screen ?                    */
#define GAP
/**/

/*#define DEBUG /* Debugging ?? */
/*#define MEMORY /* Check memory balance ?? */

#if defined(DEBUG)  /* Debug definitions ===============================*/

/* Set condition for debug output ??
*/
#define D_CONDITION   if(Debug>=5873)
/*            Examples of D_CONDITION
      `empty' if(Debug>=11951211) current!!
      if(Debug>=25283LU)*e7* *e70*
      if(Debug%10 == 0)  if(Debug>=17566)    */
/* Set condition to stop debugging ??
*/
#define D_EXIT  if(Debug > 5882) EXIT;
/*            Examples of D_EXIT
      `empty' if(Debug > 21420LU) EXIT;
       if(Debug > 26969LU) EXIT;*e7* if(Debug > 21420LU) EXIT;*e70*
       if(Debug > 30881LU) EXIT; if(Debug >= 18399) EXIT;
*/

/* Switches for debugging particular functions ?? */

#define D_CHECK_EXACTNESS_OF_DIVISION      /**/
/*#define D_ADD_PAIR_TO_LIE_MONOMIAL         /**/
#define D_GENERATE_RELATIONS               /**/
/*#if defined(D_GENERATE_RELATIONS)  /* Put tables ?? */
/*#define D_PUT_RELATIONS                    /**/
/*#define D_PUT_LIE_MONOMIAL                 /**/
/*#define D_GET_LIE_MONOMIAL                 /**/
/*#define D_GET_LIE_SUM                      /**/
/*#define D_GET_LIE_TERM                     /**/
#define D_INTEGER_CANCELLATION             /**/
#define D_INTEGER_GCD                      /**/
#define D_INTEGER_PRODUCT                  /**/
#define D_INTEGER_QUOTIENT                 /**/
#define D_INTEGER_SUM                      /**/
#define D_LIE_SUM_ADDITION                 /**/
#define D_LIE_SUM_DIV_INTEGER              /**/
/*#define D_LIE_SUM_DIV_SCALAR_SUM           /**/
#define D_LIE_SUM_MULT_INTEGER             /**/
/*#define D_LIE_SUM_MULT_SCALAR_SUM          /**/
#define D_MAKE_RELATION_RHS                /**/
/*#define D_NEW_JACOBI_RELATION              /**/
#define D_NORMALIZE_RELATION               /**/
/*#define D_PAIR_MONOMIAL_MONOMIAL           /**/
/*#define D_PAIR_MONOMIAL_SUM                /**/
/*#define D_PAIR_SUM_MONOMIAL                /**/
/*#define D_PAIR_SUM_SUM                     /**/
/*#define D_POLY_CONTENT                     /**/
/*#define D_POLY_GCD                         /**/
/*#define D_POLY_QUOTIENT                    /**/
/*#define D_POLY_PSEUDO_REMAINDER            /**/
/*#define D_SCALAR_SUM_CANCELLATION          /**/
#define D_SUBSTITUTE_RELATION_IN_RELATION  /**/
#define D_IN_SET     U debug=Debug;\
                     D_CONDITION\
                       PutDebugHeader(debug, f_name, "in"),
#define D_IN_CLOSE   Debug++; D_EXIT

#define D_OUT_OPEN   D_CONDITION PutDebugHeader(debug, f_name, "out"),

#else      /* Empty definitions for DEBUG off */

#define D_IN_SET
#define D_IN_CLOSE
#define D_OUT_OPEN

#endif

/* Check memory balance definitions */

#if defined(MEMORY)              /* `n_...' are unique */
#define IN_SET_N_LT      I n_lt  = -CurrentNLT;
#define IN_SET_N_INT     I n_int = -CurrentNINT;
#define IN_SET_N_ST      I n_st  = -CurrentNST;
#define IN_SET_N_SF      I n_sf  = -CurrentNSF;

#define OUT_SET_N_LT     n_lt  += CurrentNLT;
#define OUT_SET_N_INT    n_int += CurrentNINT;
#define OUT_SET_N_ST     n_st  += CurrentNST;
#define OUT_SET_N_SF     n_sf  += CurrentNSF;

#define ADD_LIE_SUM_NS(a) \
    AddLieSumNs(a, PLUS, &n_lt, &n_int, &n_st, &n_sf);

#define SUBTRACT_LIE_SUM_NS(a) \
    AddLieSumNs(a, MINUS, &n_lt, &n_int, &n_st, &n_sf);

#define ADD_SCALAR_SUM_NS(a) \
    AddScalarSumNs(a, PLUS, &n_int, &n_st, &n_sf);

#define SUBTRACT_SCALAR_SUM_NS(a) \
    AddScalarSumNs(a, MINUS, &n_int, &n_st, &n_sf);

#define CHECK_NS \
  if(n_lt != 0) {PutNodeBalance("\nNodeLT (Lie terms)",\
                                f_name, n_lt); EXIT;}\
  if(n_int != 0) {PutIntegerBalance(f_name, n_int); EXIT;}\
  if(n_st != 0) {PutNodeBalance("\nNodeST (scalar terms)",\
                                f_name, n_st); EXIT;}\
  if(n_sf != 0) {PutNodeBalance("\nNodeSF (scalar factors)",\
                                f_name, n_sf); EXIT;}

/* Particular functions */
/*----------------------------------------------------------*/
#define M_OUT_GET_LIE_MONOMIAL \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(a)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_OUT_GET_LIE_SUM \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(lsum)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_OUT_GET_LIE_TERM \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(lterm)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_LIE_SUM_ADDITION  \
  ADD_LIE_SUM_NS(a)\
  ADD_LIE_SUM_NS(b)
#define M_OUT_LIE_SUM_ADDITION  \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(sum)\
  CHECK_NS
/*----------------------------------------------------------*/
/*   No sense to print debug information, memory check only */
#define IN_LIE_SUM_COPY  \
    IN_SET_FUNCTION_NAME("LieSumCopy...")\
    IN_SET_NS
#define OUT_LIE_SUM_COPY  \
    OUT_SET_NS\
    SUBTRACT_LIE_SUM_NS(ca)\
    CHECK_NS
/*----------------------------------------------------------*/
/*   No sense to print debug information, memory check only */
#define IN_LIE_SUM_KILL  \
    IN_SET_FUNCTION_NAME("LieSumKill...")\
    IN_SET_NS\
    ADD_LIE_SUM_NS(a)
#define OUT_LIE_SUM_KILL \
    OUT_SET_NS\
    CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_LIE_SUM_DIV_INTEGER  \
  ADD_LIE_SUM_NS(b)
#define M_OUT_LIE_SUM_DIV_INTEGER  \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(b)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_LIE_SUM_DIV_SCALAR_SUM  \
  ADD_LIE_SUM_NS(b)\
  ADD_SCALAR_SUM_NS(den)
#define M_OUT_LIE_SUM_DIV_SCALAR_SUM  \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(b)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_LIE_SUM_MULT_SCALAR_SUM  \
  ADD_LIE_SUM_NS(b)\
  ADD_SCALAR_SUM_NS(num)
#define M_OUT_LIE_SUM_MULT_SCALAR_SUM  \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(b)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_LIE_SUM_MULT_INTEGER  \
  ADD_LIE_SUM_NS(b)
#define M_OUT_LIE_SUM_MULT_INTEGER  M_OUT_LIE_SUM_DIV_INTEGER
/*----------------------------------------------------------*/
#define M_OUT_MAKE_RELATION_RHS    M_OUT_GET_LIE_MONOMIAL
/*----------------------------------------------------------*/
#define M_OUT_NEW_JACOBI_RELATION  M_OUT_GET_LIE_MONOMIAL
/*----------------------------------------------------------*/
#define M_IN_NORMALIZE_RELATION  \
  ADD_LIE_SUM_NS(a)
#define M_OUT_NORMALIZE_RELATION   M_OUT_GET_LIE_MONOMIAL
/*----------------------------------------------------------*/
#define M_OUT_PAIR_MONOMIAL_MONOMIAL  M_OUT_GET_LIE_MONOMIAL
/*----------------------------------------------------------*/
#define M_IN_PAIR_MONOMIAL_SUM  \
  ADD_LIE_SUM_NS(a)
#define M_OUT_PAIR_MONOMIAL_SUM  \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(s)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_PAIR_SUM_MONOMIAL  \
  ADD_LIE_SUM_NS(a)
#define M_OUT_PAIR_SUM_MONOMIAL  \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(s)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_PAIR_SUM_SUM  \
  ADD_LIE_SUM_NS(a)\
  ADD_LIE_SUM_NS(b)
#define M_OUT_PAIR_SUM_SUM  \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(a)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_POLY_CONTENT
#define M_OUT_POLY_CONTENT  \
  OUT_SET_NS\
  SUBTRACT_SCALAR_SUM_NS(b)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_POLY_GCD
#define M_OUT_POLY_GCD  \
  OUT_SET_NS\
  SUBTRACT_SCALAR_SUM_NS(b)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_POLY_QUOTIENT  \
  ADD_SCALAR_SUM_NS(a)\
  ADD_SCALAR_SUM_NS(b)
#define M_OUT_POLY_QUOTIENT  \
  OUT_SET_NS\
  SUBTRACT_SCALAR_SUM_NS(c)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_POLY_PSEUDO_REMAINDER  \
  ADD_SCALAR_SUM_NS(a)\
  ADD_SCALAR_SUM_NS(b)
#define M_OUT_POLY_PSEUDO_REMAINDER  \
  OUT_SET_NS\
  SUBTRACT_SCALAR_SUM_NS(a)\
  CHECK_NS
/*----------------------------------------------------------*/
/*   No sense to print debug information, memory check only */
#define IN_REDUCE_RELATIONS  \
    IN_SET_FUNCTION_NAME("ReduceRelations")\
    IN_SET_NS\
    {\
      I o;\
      for(o = 0; o < RelationN; o++)\
        ADD_LIE_SUM_NS(RELATION_LIE_SUM(o))\
    }
#define OUT_REDUCE_RELATIONS  \
    OUT_SET_NS\
    {\
      I o;\
      for(o = 0; o < RelationN; o++)\
        SUBTRACT_LIE_SUM_NS(RELATION_LIE_SUM(o))\
    }\
    CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_SCALAR_SUM_CANCELLATION  \
  ADD_SCALAR_SUM_NS(*pnum)\
  ADD_SCALAR_SUM_NS(*pden)
#define M_OUT_SCALAR_SUM_CANCELLATION  \
  OUT_SET_NS\
  SUBTRACT_SCALAR_SUM_NS(*pnum)\
  SUBTRACT_SCALAR_SUM_NS(*pden)\
  CHECK_NS
/*----------------------------------------------------------*/
#define M_IN_SUBSTITUTE_RELATION_IN_RELATION  \
  ADD_LIE_SUM_NS(a)
#define M_OUT_SUBSTITUTE_RELATION_IN_RELATION  \
  OUT_SET_NS\
  SUBTRACT_LIE_SUM_NS(a)\
  CHECK_NS

#define  MM_CURRENT_N_LT    ,--CurrentNLT
#define  PP_CURRENT_N_LT    ++CurrentNLT;

#define  MM_CURRENT_N_SF    ,--CurrentNSF
#define  PP_CURRENT_N_SF    ++CurrentNSF;

#define  MM_CURRENT_N_ST    ,--CurrentNST
#define  PP_CURRENT_N_ST    ++CurrentNST;

#define  MM_CURRENT_N_INT   ,--CurrentNINT
#define  PP_CURRENT_N_INT   ;++CurrentNINT

#else       /* MEMORY off */

#define  MM_CURRENT_N_LT
#define  PP_CURRENT_N_LT
#define  MM_CURRENT_N_SF
#define  PP_CURRENT_N_SF
#define  MM_CURRENT_N_ST
#define  PP_CURRENT_N_ST
#define  MM_CURRENT_N_INT
#define  PP_CURRENT_N_INT

#define IN_SET_N_LT
#define IN_SET_N_INT
#define IN_SET_N_ST
#define IN_SET_N_SF

#define OUT_SET_N_LT
#define OUT_SET_N_INT
#define OUT_SET_N_ST
#define OUT_SET_N_SF

#define M_OUT_GET_LIE_MONOMIAL
#define M_OUT_GET_LIE_SUM
#define M_OUT_GET_LIE_TERM
#define M_IN_LIE_SUM_ADDITION
#define M_OUT_LIE_SUM_ADDITION
#define IN_LIE_SUM_COPY
#define OUT_LIE_SUM_COPY
#define IN_LIE_SUM_KILL
#define OUT_LIE_SUM_KILL
#define M_IN_LIE_SUM_DIV_INTEGER
#define M_OUT_LIE_SUM_DIV_INTEGER
#define M_IN_LIE_SUM_DIV_SCALAR_SUM
#define M_OUT_LIE_SUM_DIV_SCALAR_SUM
#define M_IN_LIE_SUM_MULT_SCALAR_SUM
#define M_OUT_LIE_SUM_MULT_SCALAR_SUM
#define M_IN_LIE_SUM_MULT_INTEGER
#define M_OUT_LIE_SUM_MULT_INTEGER
#define M_OUT_MAKE_RELATION_RHS
#define M_OUT_NEW_JACOBI_RELATION
#define M_IN_NORMALIZE_RELATION
#define M_OUT_NORMALIZE_RELATION
#define M_OUT_PAIR_MONOMIAL_MONOMIAL
#define M_IN_PAIR_MONOMIAL_SUM
#define M_OUT_PAIR_MONOMIAL_SUM
#define M_IN_PAIR_SUM_MONOMIAL
#define M_OUT_PAIR_SUM_MONOMIAL
#define M_IN_PAIR_SUM_SUM
#define M_OUT_PAIR_SUM_SUM
#define M_IN_POLY_CONTENT
#define M_OUT_POLY_CONTENT
#define M_IN_POLY_GCD
#define M_OUT_POLY_GCD
#define M_IN_POLY_QUOTIENT
#define M_OUT_POLY_QUOTIENT
#define M_IN_POLY_PSEUDO_REMAINDER
#define M_OUT_POLY_PSEUDO_REMAINDER
#define IN_REDUCE_RELATIONS
#define OUT_REDUCE_RELATIONS
#define M_IN_SCALAR_SUM_CANCELLATION
#define M_OUT_SCALAR_SUM_CANCELLATION
#define M_IN_SUBSTITUTE_RELATION_IN_RELATION
#define M_OUT_SUBSTITUTE_RELATION_IN_RELATION
#endif

#define IN_SET_NS IN_SET_N_LT IN_SET_N_INT IN_SET_N_ST IN_SET_N_SF
#define OUT_SET_NS OUT_SET_N_LT OUT_SET_N_INT OUT_SET_N_ST OUT_SET_N_SF


#if defined(DEBUG) || defined(MEMORY)             /* `f_name' is unique */
#define IN_SET_FUNCTION_NAME(fname) S f_name = fname;
#else
#define IN_SET_FUNCTION_NAME(fname)
#endif

#if defined(D_ADD_PAIR_TO_LIE_MONOMIAL) /*------------------------------*/
                                        /*   Only debugging makes sense */
#define IN_ADD_PAIR_TO_LIE_MONOMIAL \
    IN_SET_FUNCTION_NAME("AddPairToLieMonomial")\
    D_IN_SET\
      PutDebugLieMonomial("i", i),\
      PutDebugLieMonomial("j", j),\
      PutDebugLieMonomialTable(-1);\
    D_IN_CLOSE

#define OUT_ADD_PAIR_TO_LIE_MONOMIAL_OLD \
    D_OUT_OPEN\
      PutDebugLieMonomial("Old monomial", ijp);
#define OUT_ADD_PAIR_TO_LIE_MONOMIAL_NEW  \
    D_OUT_OPEN\
      PutDebugLieMonomialTable(ijp);
#else
#define IN_ADD_PAIR_TO_LIE_MONOMIAL     D_IN_CLOSE
#define OUT_ADD_PAIR_TO_LIE_MONOMIAL_OLD
#define OUT_ADD_PAIR_TO_LIE_MONOMIAL_NEW
#endif
#if defined(D_GENERATE_RELATIONS) /*-----------------------------------*/
                                       /*   Only debugging makes sense */
#define IN_GENERATE_RELATIONS  \
    IN_SET_FUNCTION_NAME("GenerateRelations")\
    D_IN_SET\
      IN_PUT_RELATIONS\
      IN_PUT_LIE_MONOMIAL\
      PutDebugLieSum("rel", a),\
      PutDebugLieMonomial("gen", gen);\
    D_IN_CLOSE

#define OUT_GENERATE_RELATIONS \
    D_OUT_OPEN\
      PutDebugLieSum("d_rel", a);
#else
#define  IN_GENERATE_RELATIONS     D_IN_CLOSE
#define  OUT_GENERATE_RELATIONS
#endif
#if defined(D_INTEGER_CANCELLATION) /*----- (k*n)/(k*d) -> n/d --------*/
                                    /* Only debugging makes sense      */
#define IN_INTEGER_CANCELLATION \
    IN_SET_FUNCTION_NAME("IntegerCancellation")\
    D_IN_SET\
      PutDebugInteger("num", num),\
      PutDebugInteger("den", den);\
    D_IN_CLOSE
#define OUT_INTEGER_CANCELLATION \
    D_OUT_OPEN\
      PutDebugInteger("num", num),\
      PutDebugInteger("den", den);
#else
#define IN_INTEGER_CANCELLATION    D_IN_CLOSE
#define OUT_INTEGER_CANCELLATION
#endif
#if defined(D_INTEGER_GCD) /*------------------------------------------*/
                                    /* Only debugging makes sense      */
#define IN_INTEGER_GCD  \
    IN_SET_FUNCTION_NAME("IntegerGCD")\
    D_IN_SET\
      PutDebugInteger("u", u),\
      PutDebugInteger("v", v);\
    D_IN_CLOSE
#define OUT_INTEGER_GCD  \
    D_OUT_OPEN\
      PutDebugInteger("GCD", u);
#else
#define IN_INTEGER_GCD       D_IN_CLOSE
#define OUT_INTEGER_GCD
#endif
#if defined(D_INTEGER_PRODUCT)  /*------------- n*m -------------------*/
                                    /* Only debugging makes sense      */
#define IN_INTEGER_PRODUCT  \
    IN_SET_FUNCTION_NAME("IntegerProduct")\
    D_IN_SET\
      PutDebugInteger("u", u),\
      PutDebugInteger("v", v);\
    D_IN_CLOSE
#define OUT_INTEGER_PRODUCT  \
    D_OUT_OPEN\
      PutDebugInteger("u*v", w0);
#else
#define IN_INTEGER_PRODUCT    D_IN_CLOSE
#define OUT_INTEGER_PRODUCT
#endif
#if defined(D_INTEGER_QUOTIENT)  /*------------------------------------*/
                                    /* Only debugging makes sense      */
#define IN_INTEGER_QUOTIENT  \
    IN_SET_FUNCTION_NAME("IntegerQuotient")\
    D_IN_SET\
      PutDebugInteger("a", a),\
      PutDebugInteger("b", b);\
    D_IN_CLOSE
#define OUT_INTEGER_QUOTIENT  \
    D_OUT_OPEN\
      PutDebugInteger("a/b", pm);
#else
#define IN_INTEGER_QUOTIENT    D_IN_CLOSE
#define OUT_INTEGER_QUOTIENT
#endif
#if defined(D_INTEGER_SUM)       /*------------------------------------*/
                                    /* Only debugging makes sense      */
#define IN_INTEGER_SUM  \
    IN_SET_FUNCTION_NAME("IntegerSum")\
    D_IN_SET\
      PutDebugInteger("a", a),\
      PutDebugInteger("b", b);\
    D_IN_CLOSE
#define OUT_INTEGER_SUM  \
    D_OUT_OPEN\
      PutDebugInteger("c", c);
#else
#define IN_INTEGER_SUM    D_IN_CLOSE
#define OUT_INTEGER_SUM
#endif

#if defined(D_GET_LIE_MONOMIAL) /*-------------------------------------*/
#define D_IN_GET_LIE_MONOMIAL   D_IN_SET\
                                  PutDebugString("*pstr", *pstr);\
                                D_IN_CLOSE
#define D_OUT_GET_LIE_MONOMIAL  D_OUT_OPEN\
                                  PutDebugLieSum("a", a);
#else
#define D_IN_GET_LIE_MONOMIAL   D_IN_CLOSE
#define D_OUT_GET_LIE_MONOMIAL
#endif
#if defined(D_GET_LIE_SUM) /*------------------------------------------*/
#define D_IN_GET_LIE_SUM     D_IN_SET\
                               PutDebugString("*pstr", *pstr);\
                             D_IN_CLOSE
#define D_OUT_GET_LIE_SUM    D_OUT_OPEN\
                               PutDebugLieSum("lsum", lsum);
#else
#define D_IN_GET_LIE_SUM     D_IN_CLOSE
#define D_OUT_GET_LIE_SUM
#endif
#if defined(D_GET_LIE_TERM) /*-----------------------------------------*/
#define D_IN_GET_LIE_TERM  D_IN_SET\
                             PutDebugString("*pstr", *pstr);\
                           D_IN_CLOSE
#define D_OUT_GET_LIE_TERM D_OUT_OPEN\
                             PutDebugLieSum("lterm", lterm);
#else
#define D_IN_GET_LIE_TERM  D_IN_CLOSE
#define D_OUT_GET_LIE_TERM
#endif
#if defined(D_LIE_SUM_ADDITION) /*---------- a + b (Lie) --------------*/
#define D_IN_LIE_SUM_ADDITION  D_IN_SET\
                                 PutDebugLieSum("a", a),\
                                 PutDebugLieSum("b", b);\
                               D_IN_CLOSE
#define D_OUT_LIE_SUM_ADDITION D_OUT_OPEN\
                                 PutDebugLieSum("sum", sum);
#else
#define D_IN_LIE_SUM_ADDITION  D_IN_CLOSE
#define D_OUT_LIE_SUM_ADDITION
#endif
#if defined(D_LIE_SUM_DIV_INTEGER)  /*--------- U/INT ----------------*/
#define D_IN_LIE_SUM_DIV_INTEGER   D_IN_SET\
                                     PutDebugLieSum("lsum", b),\
                                     PutDebugInteger("den", den);\
                                   D_IN_CLOSE
#define D_OUT_LIE_SUM_DIV_INTEGER  D_OUT_OPEN\
                                     PutDebugLieSum("lsum", b);
#else
#define D_IN_LIE_SUM_DIV_INTEGER   D_IN_CLOSE
#define D_OUT_LIE_SUM_DIV_INTEGER
#endif
#if defined(D_LIE_SUM_DIV_SCALAR_SUM)  /*--------- U/U --------------*/
#define D_IN_LIE_SUM_DIV_SCALAR_SUM   D_IN_SET\
                                        PutDebugLieSum("lsum", b),\
                                        PutDebugScalarSum("den", den);\
                                      D_IN_CLOSE
#define D_OUT_LIE_SUM_DIV_SCALAR_SUM  D_OUT_OPEN\
                                        PutDebugLieSum("lsum", b);
#else
#define D_IN_LIE_SUM_DIV_SCALAR_SUM   D_IN_CLOSE
#define D_OUT_LIE_SUM_DIV_SCALAR_SUM
#endif
#if defined(D_LIE_SUM_MULT_SCALAR_SUM)  /*--------- U*U --------------*/
#define D_IN_LIE_SUM_MULT_SCALAR_SUM   D_IN_SET\
                                         PutDebugLieSum("lsum", b),\
                                         PutDebugScalarSum("num", num);\
                                       D_IN_CLOSE
#define D_OUT_LIE_SUM_MULT_SCALAR_SUM  D_OUT_OPEN\
                                         PutDebugLieSum("lsum", b);
#else
#define D_IN_LIE_SUM_MULT_SCALAR_SUM   D_IN_CLOSE
#define D_OUT_LIE_SUM_MULT_SCALAR_SUM
#endif
#if defined(D_LIE_SUM_MULT_INTEGER)  /*------- U*INT -----------------*/
#define D_IN_LIE_SUM_MULT_INTEGER   D_IN_SET\
                                      PutDebugLieSum("lsum", b),\
                                      PutDebugInteger("num", num);\
                                    D_IN_CLOSE
#define D_OUT_LIE_SUM_MULT_INTEGER  D_OUT_OPEN\
                                      PutDebugLieSum("lsum", b);
#else
#define D_IN_LIE_SUM_MULT_INTEGER   D_IN_CLOSE
#define D_OUT_LIE_SUM_MULT_INTEGER
#endif
#if defined(D_MAKE_RELATION_RHS)   /*----------------------------------*/
#define D_IN_MAKE_RELATION_RHS     D_IN_SET\
                                     PutDebugLieSum("rel",\
                                         RELATION_LIE_SUM(i));\
                                   D_IN_CLOSE
#define D_OUT_MAKE_RELATION_RHS    D_OUT_OPEN\
                                     PutDebugLieSum("r.h.s", a);
#else
#define D_IN_MAKE_RELATION_RHS     D_IN_CLOSE
#define D_OUT_MAKE_RELATION_RHS
#endif
#if defined(D_NEW_JACOBI_RELATION) /*----------------------------------*/
#define D_IN_NEW_JACOBI_RELATION   D_IN_SET\
                                     PutDebugLieMonomial("l", l);\
                                   D_IN_CLOSE
#define D_OUT_NEW_JACOBI_RELATION  D_OUT_OPEN\
                                     PutDebugLieSum("a", a);
#else
#define D_IN_NEW_JACOBI_RELATION   D_IN_CLOSE
#define D_OUT_NEW_JACOBI_RELATION
#endif
#if defined(D_NORMALIZE_RELATION) /*-----------------------------------*/
#define D_IN_NORMALIZE_RELATION    D_IN_SET\
                                     PutDebugLieSum("a", a);\
                                   D_IN_CLOSE
#define D_OUT_NORMALIZE_RELATION   D_OUT_OPEN\
                                     PutDebugLieSum("a", a);
#else
#define D_IN_NORMALIZE_RELATION    D_IN_CLOSE
#define D_OUT_NORMALIZE_RELATION
#endif
#if defined(D_PAIR_MONOMIAL_MONOMIAL) /*---------[mona, monb]----------*/
#define D_IN_PAIR_MONOMIAL_MONOMIAL    D_IN_SET\
                                         PutDebugLieMonomial("i", i),\
                                         PutDebugLieMonomial("j", j);\
                                       D_IN_CLOSE
#define D_OUT_PAIR_MONOMIAL_MONOMIAL   D_OUT_OPEN\
                                         PutDebugLieSum("a", a);
#else
#define D_IN_PAIR_MONOMIAL_MONOMIAL    D_IN_CLOSE
#define D_OUT_PAIR_MONOMIAL_MONOMIAL
#endif
#if defined(D_PAIR_MONOMIAL_SUM) /*-----------[mon, a]-----------------*/
#define D_IN_PAIR_MONOMIAL_SUM  D_IN_SET\
                                  PutDebugLieMonomial("mon", mon),\
                                  PutDebugLieSum("a", a);\
                                D_IN_CLOSE
#define D_OUT_PAIR_MONOMIAL_SUM D_OUT_OPEN\
                                  PutDebugLieSum("s", s);
#else
#define D_IN_PAIR_MONOMIAL_SUM  D_IN_CLOSE
#define D_OUT_PAIR_MONOMIAL_SUM
#endif
#if defined(D_PAIR_SUM_MONOMIAL) /*-----------[a, mon]-----------------*/
#define D_IN_PAIR_SUM_MONOMIAL  D_IN_SET\
                                  PutDebugLieSum("a", a),\
                                  PutDebugLieMonomial("mon", mon);\
                                D_IN_CLOSE
#define D_OUT_PAIR_SUM_MONOMIAL D_OUT_OPEN\
                                  PutDebugLieSum("s", s);
#else
#define D_IN_PAIR_SUM_MONOMIAL  D_IN_CLOSE
#define D_OUT_PAIR_SUM_MONOMIAL
#endif
#if defined(D_PAIR_SUM_SUM)    /*----------------[a, b]---------------*/
#define D_IN_PAIR_SUM_SUM  D_IN_SET\
                             PutDebugLieSum("a", a),\
                             PutDebugLieSum("b", b);\
                           D_IN_CLOSE
#define D_OUT_PAIR_SUM_SUM D_OUT_OPEN\
                             PutDebugLieSum("a", a);
#else
#define D_IN_PAIR_SUM_SUM    D_IN_CLOSE
#define D_OUT_PAIR_SUM_SUM
#endif
#if defined(D_POLY_CONTENT) /*--------------------------------------------*/
#define D_IN_POLY_CONTENT  D_IN_SET\
                             PutDebugScalarSum("a", a),\
                             PutDebugString("mp", \
                                ParameterName + mp*NameLength1);\
                           D_IN_CLOSE
#define D_OUT_POLY_CONTENT D_OUT_OPEN\
                             PutDebugScalarSum("b", b);
#else
#define D_IN_POLY_CONTENT  D_IN_CLOSE
#define D_OUT_POLY_CONTENT
#endif
#if defined(D_POLY_GCD) /*--------------------------------------------*/
#define D_IN_POLY_GCD  D_IN_SET\
                         PutDebugScalarSum("a", a),\
                         PutDebugScalarSum("b", b);\
                       D_IN_CLOSE
#define D_OUT_POLY_GCD D_OUT_OPEN\
                         PutDebugScalarSum("b", b);
#else
#define D_IN_POLY_GCD    D_IN_CLOSE
#define D_OUT_POLY_GCD
#endif
#if defined(D_POLY_QUOTIENT) /*--------------------------------------------*/
#define D_IN_POLY_QUOTIENT  D_IN_SET\
                              PutDebugScalarSum("a", a),\
                              PutDebugScalarSum("b", b);\
                            D_IN_CLOSE
#define D_OUT_POLY_QUOTIENT D_OUT_OPEN\
                              PutDebugScalarSum("c", c);
#else
#define D_IN_POLY_QUOTIENT    D_IN_CLOSE
#define D_OUT_POLY_QUOTIENT
#endif
#if defined(D_POLY_PSEUDO_REMAINDER) /*------------------------------------*/
#define D_IN_POLY_PSEUDO_REMAINDER  D_IN_SET\
                                      PutDebugScalarSum("a", a),\
                                      PutDebugScalarSum("b", b);\
                                    D_IN_CLOSE
#define D_OUT_POLY_PSEUDO_REMAINDER D_OUT_OPEN\
                                      PutDebugScalarSum("a", a);
#else
#define D_IN_POLY_PSEUDO_REMAINDER  D_IN_CLOSE
#define D_OUT_POLY_PSEUDO_REMAINDER
#endif
#if defined(D_SCALAR_SUM_CANCELLATION) /*----- (k*n)/(k*d) -> n/d ----*/
#define D_IN_SCALAR_SUM_CANCELLATION  D_IN_SET\
                                        PutDebugScalarSum("*pnum", *pnum),\
                                        PutDebugScalarSum("*pden", *pden);\
                                      D_IN_CLOSE
#define D_OUT_SCALAR_SUM_CANCELLATION D_OUT_OPEN\
                                        PutDebugScalarSum("*pnum", *pnum),\
                                        PutDebugScalarSum("*pden", *pden);
#else
#define D_IN_SCALAR_SUM_CANCELLATION    D_IN_CLOSE
#define D_OUT_SCALAR_SUM_CANCELLATION
#endif
#if defined(D_SUBSTITUTE_RELATION_IN_RELATION)  /*--------------------*/
#define D_IN_SUBSTITUTE_RELATION_IN_RELATION  D_IN_SET\
                                                PutDebugLieSum("r", r),\
                                                PutDebugLieSum("a", a);\
                                              D_IN_CLOSE
#define D_OUT_SUBSTITUTE_RELATION_IN_RELATION  D_OUT_OPEN\
                                                 PutDebugLieSum("a", a);
#else
#define D_IN_SUBSTITUTE_RELATION_IN_RELATION  D_IN_CLOSE
#define D_OUT_SUBSTITUTE_RELATION_IN_RELATION
#endif

/* Set INs and OUTs for particular functions */

/*--------------------------------------------------------------------*/
#define IN_GET_LIE_MONOMIAL \
    IN_SET_FUNCTION_NAME("GetLieMonomial")\
    IN_SET_NS\
    D_IN_GET_LIE_MONOMIAL
#define OUT_GET_LIE_MONOMIAL \
    D_OUT_GET_LIE_MONOMIAL\
    M_OUT_GET_LIE_MONOMIAL
/*--------------------------------------------------------------------*/
#define IN_GET_LIE_SUM \
    IN_SET_FUNCTION_NAME("GetLieSum")\
    IN_SET_NS\
    D_IN_GET_LIE_SUM
#define OUT_GET_LIE_SUM \
    D_OUT_GET_LIE_SUM\
    M_OUT_GET_LIE_SUM
/*--------------------------------------------------------------------*/
#define IN_GET_LIE_TERM \
    IN_SET_FUNCTION_NAME("GetLieTerm")\
    IN_SET_NS\
    D_IN_GET_LIE_TERM
#define OUT_GET_LIE_TERM \
    D_OUT_GET_LIE_TERM\
    M_OUT_GET_LIE_TERM
/*--------------------------------------------------------------------*/
#define IN_LIE_SUM_ADDITION  \
    IN_SET_FUNCTION_NAME("LieSumAddition")\
    IN_SET_NS\
    D_IN_LIE_SUM_ADDITION\
    M_IN_LIE_SUM_ADDITION
#define OUT_LIE_SUM_ADDITION  \
    D_OUT_LIE_SUM_ADDITION\
    M_OUT_LIE_SUM_ADDITION
/*--------------------------------------------------------------------*/
#define IN_LIE_SUM_DIV_INTEGER  \
    LS_B_LSUM_DIV_INT\
    IN_SET_FUNCTION_NAME("LieSumDivInteger")\
    IN_SET_NS\
    D_IN_LIE_SUM_DIV_INTEGER\
    M_IN_LIE_SUM_DIV_INTEGER
#define OUT_LIE_SUM_DIV_INTEGER  \
    D_OUT_LIE_SUM_DIV_INTEGER\
    M_OUT_LIE_SUM_DIV_INTEGER
/*--------------------------------------------------------------------*/
#define IN_LIE_SUM_DIV_SCALAR_SUM  \
    LS_B_LSUM_DIV_SS\
    IN_SET_FUNCTION_NAME("LieSumDivScalarSum")\
    IN_SET_NS\
    D_IN_LIE_SUM_DIV_SCALAR_SUM\
    M_IN_LIE_SUM_DIV_SCALAR_SUM
#define OUT_LIE_SUM_DIV_SCALAR_SUM  \
    D_OUT_LIE_SUM_DIV_SCALAR_SUM\
    M_OUT_LIE_SUM_DIV_SCALAR_SUM
/*--------------------------------------------------------------------*/
#define IN_LIE_SUM_MULT_SCALAR_SUM  \
    LS_B_LSUM_MULT_SS\
    IN_SET_FUNCTION_NAME("LieSumMultScalarSum")\
    IN_SET_NS\
    D_IN_LIE_SUM_MULT_SCALAR_SUM\
    M_IN_LIE_SUM_MULT_SCALAR_SUM
#define OUT_LIE_SUM_MULT_SCALAR_SUM  \
    D_OUT_LIE_SUM_MULT_SCALAR_SUM\
    M_OUT_LIE_SUM_MULT_SCALAR_SUM
/*--------------------------------------------------------------------*/
#define IN_LIE_SUM_MULT_INTEGER  \
    LS_B_LSUM_MULT_INT\
    IN_SET_FUNCTION_NAME("LieSumMultInteger")\
    IN_SET_NS\
    D_IN_LIE_SUM_MULT_INTEGER\
    M_IN_LIE_SUM_MULT_INTEGER
#define OUT_LIE_SUM_MULT_INTEGER  \
    D_OUT_LIE_SUM_MULT_INTEGER\
    M_OUT_LIE_SUM_MULT_INTEGER
/*--------------------------------------------------------------------*/
#define IN_MAKE_RELATION_RHS \
    IN_SET_FUNCTION_NAME("MakeRelationRHS...")\
    IN_SET_NS\
    D_IN_MAKE_RELATION_RHS
#define OUT_MAKE_RELATION_RHS \
    D_OUT_MAKE_RELATION_RHS\
    M_OUT_MAKE_RELATION_RHS
/*--------------------------------------------------------------------*/
#define IN_NEW_JACOBI_RELATION  \
    IN_SET_FUNCTION_NAME("NewJacobiRelation")\
    IN_SET_NS\
    D_IN_NEW_JACOBI_RELATION
#define OUT_NEW_JACOBI_RELATION  \
    D_OUT_NEW_JACOBI_RELATION\
    M_OUT_NEW_JACOBI_RELATION
/*--------------------------------------------------------------------*/
#define IN_NORMALIZE_RELATION  \
    IN_SET_FUNCTION_NAME("NormalizeRelation...")\
    IN_SET_NS\
    D_IN_NORMALIZE_RELATION\
    M_IN_NORMALIZE_RELATION
#define OUT_NORMALIZE_RELATION  \
    D_OUT_NORMALIZE_RELATION\
    M_OUT_NORMALIZE_RELATION
/*--------------------------------------------------------------------*/
#define IN_PAIR_MONOMIAL_MONOMIAL  \
    IN_SET_FUNCTION_NAME("PairMonomialMonomial...")\
    IN_SET_NS\
    D_IN_PAIR_MONOMIAL_MONOMIAL
#define OUT_PAIR_MONOMIAL_MONOMIAL  \
    D_OUT_PAIR_MONOMIAL_MONOMIAL\
    M_OUT_PAIR_MONOMIAL_MONOMIAL
/*--------------------------------------------------------------------*/
#define IN_PAIR_MONOMIAL_SUM  \
    IN_SET_FUNCTION_NAME("PairMonomialSum...")\
    IN_SET_NS\
    D_IN_PAIR_MONOMIAL_SUM\
    M_IN_PAIR_MONOMIAL_SUM
#define OUT_PAIR_MONOMIAL_SUM  \
    D_OUT_PAIR_MONOMIAL_SUM\
    M_OUT_PAIR_MONOMIAL_SUM
/*--------------------------------------------------------------------*/
#define IN_PAIR_SUM_MONOMIAL  \
    IN_SET_FUNCTION_NAME("PairSumMonomial...")\
    IN_SET_NS\
    D_IN_PAIR_SUM_MONOMIAL\
    M_IN_PAIR_SUM_MONOMIAL
#define OUT_PAIR_SUM_MONOMIAL  \
    D_OUT_PAIR_SUM_MONOMIAL\
    M_OUT_PAIR_SUM_MONOMIAL
/*--------------------------------------------------------------------*/
#define IN_PAIR_SUM_SUM  \
    IN_SET_FUNCTION_NAME("PairSumSum...")\
    IN_SET_NS\
    D_IN_PAIR_SUM_SUM\
    M_IN_PAIR_SUM_SUM
#define OUT_PAIR_SUM_SUM  \
    D_OUT_PAIR_SUM_SUM\
    M_OUT_PAIR_SUM_SUM
/*--------------------------------------------------------------------*/
#define IN_POLY_CONTENT  \
    IN_SET_FUNCTION_NAME("PolyContent")\
    IN_SET_NS\
    D_IN_POLY_CONTENT\
    M_IN_POLY_CONTENT
#define OUT_POLY_CONTENT  \
    D_OUT_POLY_CONTENT\
    M_OUT_POLY_CONTENT
/*--------------------------------------------------------------------*/
#define IN_POLY_GCD  \
    IN_SET_FUNCTION_NAME("PolyGCD")\
    IN_SET_NS\
    D_IN_POLY_GCD\
    M_IN_POLY_GCD
#define OUT_POLY_GCD  \
    D_OUT_POLY_GCD\
    M_OUT_POLY_GCD
/*--------------------------------------------------------------------*/
#define IN_POLY_QUOTIENT  \
    IN_SET_FUNCTION_NAME("PolyQuotient")\
    IN_SET_NS\
    D_IN_POLY_QUOTIENT\
    M_IN_POLY_QUOTIENT
#define OUT_POLY_QUOTIENT  \
    D_OUT_POLY_QUOTIENT\
    M_OUT_POLY_QUOTIENT
/*--------------------------------------------------------------------*/
#define IN_POLY_PSEUDO_REMAINDER  \
    IN_SET_FUNCTION_NAME("PolyPseudoRemainder")\
    IN_SET_NS\
    D_IN_POLY_PSEUDO_REMAINDER\
    M_IN_POLY_PSEUDO_REMAINDER
#define OUT_POLY_PSEUDO_REMAINDER  \
    D_OUT_POLY_PSEUDO_REMAINDER\
    M_OUT_POLY_PSEUDO_REMAINDER
/*--------------------------------------------------------------------*/
#define IN_SCALAR_SUM_CANCELLATION  \
    IN_SET_FUNCTION_NAME("ScalarSumCancellation")\
    IN_SET_NS\
    D_IN_SCALAR_SUM_CANCELLATION\
    M_IN_SCALAR_SUM_CANCELLATION
#define OUT_SCALAR_SUM_CANCELLATION  \
    D_OUT_SCALAR_SUM_CANCELLATION\
    M_OUT_SCALAR_SUM_CANCELLATION
/*--------------------------------------------------------------------*/
#define IN_SUBSTITUTE_RELATION_IN_RELATION  \
    IN_SET_FUNCTION_NAME("SubstituteRelationInRelation...")\
    IN_SET_NS\
    D_IN_SUBSTITUTE_RELATION_IN_RELATION\
    M_IN_SUBSTITUTE_RELATION_IN_RELATION
#define OUT_SUBSTITUTE_RELATION_IN_RELATION  \
    D_OUT_SUBSTITUTE_RELATION_IN_RELATION\
    M_OUT_SUBSTITUTE_RELATION_IN_RELATION
/* Conditional print of Relation and Monomial tables */

#if defined(D_PUT_RELATIONS)   /*-------------------------------------*/
#define IN_PUT_RELATIONS       PutDebugRelations(),
#define OUT_PUT_RELATIONS      D_CONDITION PutDebugRelations();
#else
#define IN_PUT_RELATIONS
#define OUT_PUT_RELATIONS
#endif

#if defined(D_PUT_LIE_MONOMIAL)   /*-------------------------------------*/
#define IN_PUT_LIE_MONOMIAL       PutDebugLieMonomialTable(-1),
#define OUT_PUT_LIE_MONOMIAL      D_CONDITION PutDebugLieMonomialTable(-1);
#else
#define IN_PUT_LIE_MONOMIAL
#define OUT_PUT_LIE_MONOMIAL
#endif

#if defined(D_LIE_SUM_DIV_INTEGER) || defined(MEMORY)
#define LS_B_LSUM_DIV_INT  U b = lsum; /* For "LieSumDivInteger" */
#else
#define LS_B_LSUM_DIV_INT
#endif
#if defined(D_LIE_SUM_MULT_INTEGER) || defined(MEMORY)
#define LS_B_LSUM_MULT_INT  U b = lsum; /* For "LieSumMultInteger" */
#else
#define LS_B_LSUM_MULT_INT
#endif
#if defined(D_LIE_SUM_DIV_SCALAR_SUM) || defined(MEMORY)
#define LS_B_LSUM_DIV_SS  U b = lsum; /* For "LieSumDivScalarSum" */
#else
#define LS_B_LSUM_DIV_SS
#endif
#if defined(D_LIE_SUM_MULT_SCALAR_SUM) || defined(MEMORY)
#define LS_B_LSUM_MULT_SS  U b = lsum; /* For "LieSumMultScalarSum" */
#else
#define LS_B_LSUM_MULT_SS
#endif

/* Test of C functions ?? */
/*#define TEST_FUNCTION
/**/

/* Include files	*/

#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <ctype.h>
#include <malloc.h>
#if defined(SPP_2000)
#include <alloca.h>  /* This file the genuine SPP compiler requires */
#endif

#if defined(INTEGER_ALLOCATION_CHECK)
#define INTEGER_IN_STACK(n) ;if((n)==NULL) Error(E_A_STACK_INTEGER)
#define INTEGER_IN_HEAP(n)  ;if((n)==NULL) Error(E_A_HEAP_INTEGER) \
                            PP_CURRENT_N_INT
#else
#define INTEGER_IN_STACK(n)
#define INTEGER_IN_HEAP(n)  PP_CURRENT_N_INT
#endif

#if defined(POLY_ARRAY_ALLOCATION_CHECK)
#define POLY_ARRAY_IN_STACK(a) ;if((a)==NULL) Error(E_A_STACK_POLY_ARRAY)
#else
#define POLY_ARRAY_IN_STACK(a)
#endif

/*_1    System constants=================================================*/

#define NIL                                           (0u)
#define NOTHING                                     (~NIL)

#define INTEGER_SIGN_MASK                   ((LIMB)0x8000)
                      /* 1 << 15 or 0000 0000 0000 0001 */
#define INTEGER_N_LIMBS_MASK  ((LIMB)(~INTEGER_SIGN_MASK))
                                 /* 1111 1111 1111 1110 */
#define BITS_PER_LIMB                                 (16)
#define BASE_LIMB                              (0x10000lu)
#define MAX_LIMB                                 (0xFFFFu)
#define FIRST_GENUINE_PARAMETER  1 /* Skip i number */

/*_2    Type definitions================================================*/

typedef void V;
typedef char C;
typedef unsigned char CU;
typedef short int SHI;
typedef unsigned short int SHU,
  LIMB; /* Limb of big integer */
typedef LIMB * INT;  /* (Pointer to) big integer array */
typedef int I;
typedef unsigned U;
typedef char * S;

/* Element of LieMonomial table */

typedef struct
{
  I order;       /* Order of this position element */
  I position;    /* Position of this order */
  I left;        /* (Position of) left submonomial of Lie bracket */
                   /* or ~(index of generator) if not commutator */
  I right;       /* (Position of) right submonomial of Lie bracket  */
                   /* or 1 for 1st generator and 0 for nexts */
  struct
  {
    U parity : 1;
    I index : 23;  /* Index if basis element or */
                   /* ~(index of relation with leading ordinal) */
                   /* Number of relations < 4194303 */
    U weight : 8;  /* Weight of Lie monomial < 256 */
  } info;
} LIE_MON;

/* Element of NodeLT pool for Lie terms */

typedef struct
{
  I monomial;   /* (Position of) Lie monomial in LieMonomial table */
  union
  {
    U  scalar_sum;
    INT integer;
  } numerator;
  union
  {
    U  scalar_sum;
    INT integer;
  } denominator;  /* Pointer to next Lie term */
  U rptr;
} NODE_LT;

/* Element of NodeSF pool for scalar factors */

typedef struct
{
#if defined(SPP_2000)
  CU parameter; /* Parameter ordinal   */
  CU degree;    /* Degree of parameter */
#else
  CU degree;    /* Degree of parameter */  
  CU parameter; /* Parameter ordinal   */
#endif
  U   rptr;      /* Pointer to next parametric factor */
} NODE_SF;

/* Element of NodeST pool for scalar terms */

typedef struct
{
  U  monomial;  /* Scalar monomial */
  INT numerator; /* Integer coefficient */
  U  rptr;      /* Pointer to next parametric term */
} NODE_ST;

/* Element of Relation table */

typedef struct
{
  U    lie_sum;           /* Expression of relation (Lie sum) */
  CU  min_generator;     /* Minimal generator for differentiation */
  CU to_be_substituted; /* YES if relation must be substituted */
} REL;                     /* into higher relations */

/*_3    Constants and enumerations======================================*/

/* Enumeration constants */

enum boolean {NO = 0, YES = 1};
enum signs {PLUS = 0, MINUS = 1};
enum parity {EVEN = 0, ODD = 1};
enum orders {ORDER12 = -1, ORDER11 = 0, ORDER21 = 1};
enum scalar_types   /* Types of scalar factors */
{
  I_NUMBER  =  0
};
enum init_file_cases   /* Initiating file fplsa4.ini (fplsa416.ini) */
{
  COEFFICIENT_SUM_TABLE_SIZE =  0,
  CRUDE_TIME                 =  1,
  ECHO_INPUT_FILE            =  2,
  EVEN_BASIS_SYMBOL          =  3,
  GAP_ALGEBRA_NAME           =  4,
  GAP_BASIS_NAME             =  5,
  GAP_RELATIONS_NAME         =  6,
  GAP_OUTPUT_BASIS           =  7,
  GAP_OUTPUT_COMMUTATORS     =  8,
  GAP_OUTPUT_RELATIONS       =  9,
  GENERATOR_MAX_N            = 10,
  INPUT_DIRECTORY            = 11,
  INPUT_INTEGER_SIZE         = 12,
  INPUT_STRING_SIZE          = 13,
  LEFT_NORMED_OUTPUT         = 14,
  LIE_MONOMIAL_SIZE          = 15,
  LINE_LENGTH                = 16,
  NAME_LENGTH                = 17,
  NODE_LT_SIZE               = 18,
  NODE_SF_SIZE               = 19,
  NODE_ST_SIZE               = 20,
  ODD_BASIS_SYMBOL           = 21,
  OUT_LINE_SIZE              = 22,
  PARAMETER_MAX_N            = 23,
  PUT_BASIS_ELEMENTS         = 24,
  PUT_COMMUTATORS            = 25,
  PUT_HILBERT_SERIES         = 26,
  PUT_INITIAL_RELATIONS      = 27,
  PUT_NON_ZERO_COEFFICIENTS  = 28,
  PUT_PROGRAM_HEADING        = 29,
  PUT_REDUCED_RELATIONS      = 30,
  PUT_STATISTICS             = 31,
  RELATION_SIZE              = 32,
  N_INIT_CASES               = 33
};
enum input_file_cases   /* Items of input files */
{
  GENERATORS      = 0,
  LIMITING_WEIGHT = 1,
  PARAMETERS      = 2,
  RELATIONS       = 3,
  WEIGHTS         = 4,
  N_INPUT_CASES   = 5
};
enum messages
{
  /* Head messages */

  H_PROGRAM               =  0,
  H_ENTER_FILE            =  1,
  H_INPUT_FILE            =  2,
  H_CREATE_NEW_FILE       =  3,
  H_ENTER_GENERATORS      =  4,
  H_ENTER_WEIGHTS_IN_FILE =  5,
  H_ENTER_LIMITING_WEIGHT =  6,
  H_ENTER_PARAMETERS      =  7,
  H_ENTER_RELATIONS       =  8,
  H_SHOW_INPUT            =  9,
  H_IN_RELATIONS          = 10,
  H_NON_ZERO_COEFFICIENTS = 11,
  H_REDUCED_RELATIONS     = 12,
  H_BASIS_ELEMENTS        = 13,
  H_HILBERT_SERIES        = 14,
  H_COMMUTATORS           = 15,
  H_NO_PUT_COMMUTATORS    = 16,

  /* Error messages */

  ERROR                            = 17,
  E_WRONG_INI_CASE                 = 18,
  E_WRONG_INPUT_CASE               = 19,
  E_CANCEL_PROGRAM                 = 20,
  E_UNEXPECTED_EOF                 = 21,
  E_A_GENERATOR_NAME               = 22,
  E_A_PARAMETER_NAME               = 23,
  E_A_OUT_LINE                     = 24,
  E_A_RELATION                     = 25,
  E_A_LIE_MONOMIAL                 = 26,
  E_A_NODE_LT                      = 27,
  E_A_NODE_ST                      = 28,
  E_A_NODE_SF                      = 29,
  E_A_HEAP_INTEGER                 = 30,
  E_A_COEFF_PARA_TABLE             = 31,
  E_A_COEFF_SUM_TABLE              = 32,
  E_ALLOC                          = 33,
  E_A_STACK_INPUT_STRING           = 34,
  E_A_STACK_INTEGER                = 35,
  E_A_STACK_INTEGER_DECIMAL_STRING = 36,
  E_A_STACK_POLY_ARRAY             = 37,
  E_INPUT_STRING_SIZE              = 38,
  E_OUT_LINE_SIZE                  = 39,
  E_LIE_MONOMIAL_SIZE              = 40,
  E_RELATION_SIZE                  = 41,
  E_NODE_LT_SIZE                   = 42,
  E_NODE_SF_SIZE                   = 43,
  E_NODE_ST_SIZE                   = 44,
  E_COEFF_SUM_TABLE_SIZE           = 45,
  E_GENERATOR_MAX_N                = 46,
  E_PARAMETER_MAX_N                = 47,
  E_TOO_MUCH_INPUT_WEIGHTS         = 48,
  E_NON_NUM_INPUT_WEIGHT           = 49,
  E_NO_R_PARENTHESIS               = 50,
  E_NO_GENERAL_POWER               = 51,
  E_UNDECLARED_GENERATOR           = 52,
  E_NO_COMMUTATOR_COMMA            = 53,
  E_NO_COMMUTATOR_BRACKET          = 54,
  E_INVALID_CHARACTER              = 55,
  E_MESSAGE                        = 56
};

/* Constants for input and output */

#define LEFT_COMMENT              '<'  /* In *.ini and input files */
#define RIGHT_COMMENT             '>'
#define SUBSCRIPT_INPUT_SIGN	  '_'
#define ODD_GENERATOR_INPUT_SIGN  '-'  /* At input */

#define LEVEL                   '\xFF'
#define MAIN_LEVEL              '\x2'
#define MARGIN                  (LEVEL-1)

#define CASE_STRING_SIZE      256    /* Size of string to match case */
#define GAP_NAME_SIZE          64    /* Including ending '\0' */ 
#define GAP_WIDTH              79    /* Width of GAP page */

/*_4    Macrodefinitions==================================================*/
#define COUNT_LEADING_ZERO_BITS_IN_LIMB(n,w) n=CountLeadingZeroBitsInLimb((LIMB)(w))
#if 0 /* ?? Exclude the macro: the above function is slightly faster */
#define COUNT_LEADING_ZERO_BITS_IN_LIMB(n, w)  (n) = (w);\
                                          if((n) >= 0x100) \
                                            if((n) >= 0x1000) \
                                              if((n) >= 0x4000) \
                                                if((n) >= 0x8000) \
                                                  (n) = 0; \
                                                else \
                                                  (n) = 1; \
                                              else \
                                                if((n) >= 0x2000) \
                                                  (n) = 2; \
                                                else \
                                                  (n) = 3; \
                                            else \
                                              if((n) >= 0x400) \
                                                if((n) >= 0x800) \
                                                  (n) = 4; \
                                                else \
                                                  (n) = 5; \
                                              else \
                                                if((n) >= 0x200) \
                                                  (n) = 6; \
                                                else \
                                                  (n) = 7; \
                                          else \
                                            if((n) >= 0x10) \
                                              if((n) >= 0x40) \
                                                if((n) >= 0x80) \
                                                  (n) = 8; \
                                                else \
                                                  (n) = 9; \
                                              else \
                                                if((n) >= 0x20) \
                                                  (n) = 10; \
                                                else \
                                                  (n) = 11; \
                                            else \
                                              if((n) >= 0x4) \
                                                if((n) >= 0x8) \
                                                  (n) = 12; \
                                                else \
                                                  (n) = 13; \
                                              else \
                                                if((n) >= 0x2) \
                                                  (n) = 14; \
                                                else \
                                                  if((n)) \
                                                    (n) = 15; \
                                                  else \
                                                    (n) = 16
#endif

#define CUT_ARRAY(arr, type, n) (arr)=(type *)realloc(arr,sizeof(type)*(n))

#define EXIT     TIME_OFF, PutStatistics(), exit(1)

#define IN_LINE_MARGIN    OutLine[++PosOutLine]=MARGIN

#define INTEGER_MINUS(ia)  if(INTEGER_IS_NEGATIVE(ia))\
                                   (ia)[0] &= INTEGER_N_LIMBS_MASK;\
                                 else\
                                   (ia)[0] |= INTEGER_SIGN_MASK
#define INTEGER_IS_NEGATIVE(ia)  (((ia)[0]&INTEGER_SIGN_MASK)!=0)
#define INTEGER_IS_POSITIVE(ia)  (((ia)[0]&INTEGER_SIGN_MASK)==0)

#define INTEGER_IS_UNIT(ia)  (((ia)[0]==1) && ((ia)[1]==1))
#define INTEGER_IS_UNIT_ABS(ia)  ((((ia)[0]&INTEGER_N_LIMBS_MASK)==1) &&\
                              ((ia)[1]==1))
#define INTEGER_IS_NOT_UNIT(ia)  (((ia)[0]!=1) || ((ia)[1]!=1))
#define INTEGER_IS_NOT_UNIT_ABS(ia)  ((((ia)[0]&INTEGER_N_LIMBS_MASK)!=1) ||\
                                  ((ia)[1]!=1))
#define INTEGER_N_LIMBS(ia)  ((ia)[0]&INTEGER_N_LIMBS_MASK)

#define INTEGER_SET_MINUS(ia)       (ia)[0] |= INTEGER_SIGN_MASK
#define INTEGER_SET_PLUS(ia)        (ia)[0] &= INTEGER_N_LIMBS_MASK
#define INTEGER_SIGN(ia)            ((ia)[0]&INTEGER_SIGN_MASK)

#define INTEGER_HEAP_NEW(n,i)       (n)=(INT)malloc(sizeof(LIMB)*(i))\
                                    INTEGER_IN_HEAP(n)
#define INTEGER_HEAP_COPY(n,o,i)    (i)=INTEGER_N_LIMBS(o);\
                                    INTEGER_HEAP_NEW(n,++(i));\
                                    do{(i)--; (n)[i] = (o)[i];}while(i)
#define INTEGER_HEAP_COPY_DOUBLE_1(n1,n2,o,i) \
                                    (i)=INTEGER_N_LIMBS(o);\
                                    INTEGER_HEAP_NEW(n1,++(i)+1);\
                                    INTEGER_HEAP_NEW(n2,i);\
                                    do{(i)--; (n1)[i] = (n2)[i] = (o)[i];}\
                                    while(i)
#define INTEGER_KILL(bn)            free(bn) MM_CURRENT_N_INT


#define INTEGER_STACK_NEW(n,i)      (n)=(INT)alloca(sizeof(LIMB)*(i))\
                                    INTEGER_IN_STACK(n)

#define INTEGER_STACK_COPY(n,o,i)   (i)=INTEGER_N_LIMBS(o);\
                                    INTEGER_STACK_NEW(n,++(i));\
                                    do{(i)--; (n)[i] = (o)[i];}while(i)

#define INTEGER_STACK_COPY_1(n,o,i) (i)=INTEGER_N_LIMBS(o);\
                                    INTEGER_STACK_NEW(n,++(i)+1);\
                                    do{(i)--; (n)[i] = (o)[i];}while(i)

#define LIE_MONOMIAL_I_RELATION(pos)    (~LIE_MONOMIAL_INDEX(pos))
#define LIE_MONOMIAL_INDEX_BY_ORDER(ord) \
                         LIE_MONOMIAL_INDEX(LIE_MONOMIAL_POSITION(ord))
#define LIE_MONOMIAL_IS_EVEN(pos)       (LIE_MONOMIAL_PARITY(pos)==EVEN)
#define LIE_MONOMIAL_IS_LEADING_BY_ORDER(ord) \
                    LIE_MONOMIAL_IS_LEADING(LIE_MONOMIAL_POSITION(ord))
#define LIE_MONOMIAL_IS_OCCUPIED(pos)   LIE_MONOMIAL_WEIGHT(pos)
#define LIE_MONOMIAL_IS_GENERATOR(pos)  ((pos) < GeneratorN)
#define LIE_MONOMIAL_IS_GENERATOR_BY_ORDER(ord) \
                              (LIE_MONOMIAL_POSITION(ord) < GeneratorN)
#define LIE_MONOMIAL_IS_COMMUTATOR(pos) ((pos) >= GeneratorN)
#define LIE_MONOMIAL_IS_ODD(pos)        LIE_MONOMIAL_PARITY(pos)
#define LIE_MONOMIAL_IS_SQUARE(pos)     (LIE_MONOMIAL_LEFT(pos)==\
                                         LIE_MONOMIAL_RIGHT(pos))
#define LIE_MONOMIAL_IS_NOT_SQUARE(pos)  (LIE_MONOMIAL_LEFT(pos)!=\
                                          LIE_MONOMIAL_RIGHT(pos))
#define LIE_MONOMIAL_LEFT(pos)          (LieMonomial[pos].left)
#define LIE_MONOMIAL_RIGHT(pos)         (LieMonomial[pos].right)
#define LIE_MONOMIAL_ORDER(pos)         (LieMonomial[pos].order)
#define LIE_MONOMIAL_LEFT_ORDER(pos)   \
                      LIE_MONOMIAL_ORDER(LIE_MONOMIAL_LEFT(pos))
#define LIE_MONOMIAL_RIGHT_ORDER(pos)   \
                      LIE_MONOMIAL_ORDER(LIE_MONOMIAL_RIGHT(pos))
#define LIE_MONOMIAL_POSITION(ord)      (LieMonomial[ord].position)
#define LIE_MONOMIAL_WEIGHT_BY_ORDER(ord) \
                      LIE_MONOMIAL_WEIGHT(LIE_MONOMIAL_POSITION(ord))
#define LIE_MONOMIAL_INDEX(pos)         (LieMonomial[pos].info.index)
#define LIE_MONOMIAL_IS_BASIS(pos)      (LieMonomial[pos].info.index >= 0)
#define LIE_MONOMIAL_IS_LEADING(pos)    (LieMonomial[pos].info.index < 0)
#define LIE_MONOMIAL_PARITY(pos)        (LieMonomial[pos].info.parity)
#define LIE_MONOMIAL_WEIGHT(pos)        (LieMonomial[pos].info.weight)

#define LIE_TERM_MONOMIAL(a)               (NodeLT[a].monomial)
#define LIE_TERM_MONOMIAL_ORDER(a)         LIE_MONOMIAL_ORDER(\
                                             (NodeLT[a].monomial))
#define LIE_TERM_R(a)                      (NodeLT[a].rptr)
#define LIE_TERM_NUMERATOR_INTEGER(a)      (NodeLT[a].numerator.integer)
#define LIE_TERM_MINUS_INTEGER(a) \
                        INTEGER_MINUS(NodeLT[a].numerator.integer)
#define LIE_TERM_NUMERATOR_SCALAR_SUM(a)   (NodeLT[a].numerator.scalar_sum)
#define LIE_TERM_DENOMINATOR_INTEGER(a)    (NodeLT[a].denominator.integer)
#define LIE_TERM_DENOMINATOR_SCALAR_SUM(a) (NodeLT[a].denominator.scalar_sum)

#define MAX(a,b)    (((a) > (b)) ? (a) : (b))

#define NODE_LT_KILL(a)    LIE_TERM_R(a)=NodeLTTop,NodeLTTop=(a)\
                                                     MM_CURRENT_N_LT
#define NODE_SF_KILL(a)    SCALAR_FACTOR_R(a)=NodeSFTop,NodeSFTop=(a)\
                                                        MM_CURRENT_N_SF
#define NODE_ST_KILL(a)    SCALAR_TERM_R(a)=NodeSTTop,NodeSTTop=(a)\
                                                      MM_CURRENT_N_ST

#define RELATION_LIE_SUM(i)           (Relation[i].lie_sum)
#define RELATION_MIN_GENERATOR(i)     (Relation[i].min_generator)
#define RELATION_TO_BE_SUBSTITUTED(i) (Relation[i].to_be_substituted)

#define SCALAR_SUM_IS_UNIT(a)  (SCALAR_TERM_MONOMIAL(a)==NIL&&\
                                INTEGER_IS_UNIT(SCALAR_TERM_NUMERATOR(a)))

#define SCALAR_SUM_IS_UNIT_ABS(a)  (SCALAR_TERM_MONOMIAL(a)==NIL&&\
                              INTEGER_IS_UNIT_ABS(SCALAR_TERM_NUMERATOR(a)))

#define SCALAR_SUM_IS_NOT_UNIT(a)  (SCALAR_TERM_MONOMIAL(a)!=NIL||\
                                    INTEGER_IS_NOT_UNIT(\
                                          SCALAR_TERM_NUMERATOR(a)))

#define SCALAR_TERM_MONOMIAL(a)  (NodeST[a].monomial)
#define SCALAR_TERM_NUMERATOR(a) (NodeST[a].numerator)
#define SCALAR_TERM_R(a)         (NodeST[a].rptr)

#define SCALAR_FACTOR_PARAMETER(a)    (NodeSF[a].parameter)
#define SCALAR_FACTOR_IS_I_NUMBER(a)  (NodeSF[a].parameter==I_NUMBER)
#define SCALAR_FACTOR_DEGREE(a)       (NodeSF[a].degree)
#define SCALAR_FACTOR_WORD(a)         (*(SHU *)(NodeSF+(a)))
#define SCALAR_FACTOR_R(a)            (NodeSF[a].rptr)

#define SCALAR_TERM_MINUS(a)  INTEGER_MINUS(NodeST[a].numerator)
#define SCALAR_TERM_MAIN_PARAMETER(a) \
                           SCALAR_FACTOR_PARAMETER(SCALAR_TERM_MONOMIAL(a))
#define SCALAR_TERM_MAIN_PARAMETER_WORD(a) \
                                SCALAR_FACTOR_WORD(SCALAR_TERM_MONOMIAL(a))
#define SCALAR_TERM_MAIN_DEGREE(a) \
                              SCALAR_FACTOR_DEGREE(SCALAR_TERM_MONOMIAL(a))
#define POLY_MAIN_PARAMETER(a) ((SCALAR_TERM_MONOMIAL(a)==NIL) ? -1 :\
                          SCALAR_FACTOR_PARAMETER(SCALAR_TERM_MONOMIAL(a)))
#define POLY_ARRAY_STACK_NEW(a,n)   (a)=(U*)alloca(sizeof(U)*(n))\
                                    POLY_ARRAY_IN_STACK(a)

#define TIME_OFF  TimeC += (CrudeTime ? time(NULL) : clock()) - TimeA
#define TIME_ON   TimeA = (CrudeTime ? time(NULL) : clock())

/*_5    Global variables and arrays=====================================*/

/* Files */

#if !defined(GAP)
FILE *MessageFile;
FILE *SessionFile;
#endif

/* Single variables */

I IncompletedBasis;
I IncompletedRelations;
I IsParametric;
I LieMonomialIsNew;
I SubstitutionIsDone;
U LimitingWeight;
I GeneratorN;
I ParameterN;

/* Arrays */

LIE_MON *LieMonomial;    /* Set of Lie monomials */
I LieMonomialSize;
I LieMonomialN;
I LieMonomialFreePosition; /* Start search of free position */
#if defined(SPACE_STATISTICS)
I LieMonomialMaxN;
#endif


NODE_LT *NodeLT;         /* Pool of nodes for Lie terms */
U NodeLTSize;
U NodeLTTop = 1;
#if defined(SPACE_STATISTICS)
U NodeLTTopMax;
#endif

NODE_SF *NodeSF;         /* Pool of nodes for scalar factors */
U NodeSFSize;
U NodeSFTop = 1;
#if defined(SPACE_STATISTICS)
U NodeSFTopMax;
#endif

NODE_ST *NodeST;         /* Pool of nodes for scalar terms */
U NodeSTSize;
U NodeSTTop = 1;
#if defined(SPACE_STATISTICS)
U NodeSTTopMax;
#endif

REL *Relation;           /* Ordered set of relations */
I RelationSize;
I RelationN;
#if defined(SPACE_STATISTICS)
I MaxNRelation;
#endif
#if defined(INTEGER_MAX_SIZE)
LIMB IntegerMaxSize;
#endif

I CoeffSumTableSize; /* Non-zero coefficient tables variables */
I CoeffSumTableN;
U *CoeffSumTable;     /* Non-zero parametric sums */
I *CoeffParamTable;   /* Table for memorizing single */
                         /* non-zero parameters */

/* Input and output variables */

C BasisSymbolEven;
C BasisSymbolOdd;
I CurrentLevel;
S GeneratorName;     /* Input names */
S ParameterName;
I GeneratorMaxN;     /* Maximum number of input generators */
U InputIntegerSize;  /* Maximum size of input integer in LIMBs */
I InputStringSize;   /* Size of string for reading input */
I LastItemEnd;
I LineLength;
I Margin;
I MaxLevel;
I MinLevel;
I NameLength1;       /* Maximum length of input name (with ending '\0') */
I NewMargin;
I ParameterMaxN = 1; /* Maximum number of input parameters (i at least) */
I BasisElementsPut;
I CommutatorsPut;
I CrudeTime;         /* Prevent time variable wrapping for large tasks */
I EchoInput;
I GAPOutputCommutators;
I GAPOutputBasis;
I GAPOutputRelations;
C GAPAlgebraName[GAP_NAME_SIZE];
C GAPBasisName[GAP_NAME_SIZE];
C GAPRelationsName[GAP_NAME_SIZE];
I HeadingPut;
I HilbertSeriesPut;
I InitialRelationsPut;
I NonZeroCoefficientsPut;
I ReducedRelationsPut;
I StatisticsPut;
S OutLine;           /* String for preparation of output block */
I OutLineSize;
I PosOutLine;
I PreviousEnd;
I PrintEnd;

U TimeA, TimeC;

#if defined(DEBUG)
U Debug;
#endif
#if defined(MEMORY)
I CurrentNLT;
I CurrentNSF;
I CurrentNST;
I CurrentNINT;

#endif

/*_6    Function descriptions===========================================*/

/*_6_0          Main and top level functions============================*/

V ConstructFreeAlgebraBasis(V);       /* 1 call! */
I FindNewPositionInRelation(I lmo);
V GenerateRelations(V);               /* 1 call! */
U NewJacobiRelation(I l);           /* 1 call! */
I ReduceRelations(I i);

/*_6_1          Pairing functions=======================================*/

I AddPairToLieMonomial(I i, I j);
U MakeRelationRHSInteger(I i);             /* 1 call!! */
U MakeRelationRHSParametric(I i);          /* 1 call!! */
U PairMonomialMonomialInteger(I i, I j);
U PairMonomialMonomialParametric(I i, I j);
U PairMonomialSumInteger(I mon, U a);
U PairMonomialSumParametric(I mon, U a);
U PairSumMonomialInteger(U a, I mon);
U PairSumMonomialParametric(U a, I mon);
U PairSumSumInteger(U a, U b);
U PairSumSumParametric(U a, U b);

/*_6_2          Substitution (replacing) functions======================*/

I IsMonomialInMonomial(I submon, I mon);
U SubstituteRelationInRelationInteger(U r, U a);
U SubstituteRelationInRelationParametric(U r, U a);
U SubstituteRHSInMonomialInteger(I mon, I lmonr, U r);
U SubstituteRHSInMonomialParametric(I mon, I lmonr, U r);

/*_6_3          Lie and scalar algebra functions========================*/

I LieLikeTermsCollectionInteger(U a, U b);
I LieLikeTermsCollectionParametric(U a, U b);
U LieSumAddition(U a, U b);
V LieSumDivInteger(U lsum, INT den);
V LieSumDivScalarSum(U lsum, U den);
V LieSumMinusInteger(U a);
V LieSumMinusParametric(U a);
V LieSumMultInteger(U lsum, INT num);
#if defined(RATIONAL_FIELD)
V LieSumMultRationalInteger(I a, INT num, INT den);
#endif
V LieSumMultScalarSum(U lsum, U num);
V NormalizeRelationInteger(U a);
V NormalizeRelationParametric(U a);
U ScalarMonomialMultiplication(I *pchange_sign, U ma, U mb);
U ScalarSumAddition(U a, U b);
V ScalarSumCancellation(U *pnum, U *pden);
V ScalarSumMinus(U a);
U ScalarSumMultiplication(U a, U b);
V ScalarTermMultiplication(U a, U b);     /* 1 call! */

/*_6_4          Scalar polynomial algebraic functions===================*/

U ContentOfScalarSum(U cont, U a);
V InCoeffParamTable(U cont);
V InCoeffSumTable(U sum);
V InCoeffTable(U coe);
U PolyCoeffAtMainParameter(U *pa, I mp);
U PolyContent(U a, I mp);
U PolyGCD(U a, U b);
U PolyMainParameterTerm(U *pa, I mp, I mpdeg);
I PolynomialsAreEqual(U a, U b);
U PolyPseudoRemainder(U a, U b, I mp);  /* 1 call! */
U PolyTermGCD(U a, U b);
V PolyTermQuotient(U a, U b);
U PolyQuotient(U a, U b);

/*_6_5          Big number functions====================================*/

I BigNMinusBigN(INT a, I na, INT b, I nb);
LIMB BigNShiftLeft(INT bign, I n, I cnt);
I BigNShiftRight(INT bign, I n, I cnt);
I CountLeadingZeroBitsInLimb(LIMB w);
V IntegerCancellation(INT num, INT den);
INT IntegerGCD(INT u, INT v);
V IntegerProduct(INT w, INT u, INT v);
V IntegerQuotient(INT c, INT a, INT b);
V IntegerSum(INT c, INT a, INT b);

/*_6_6          Copy and delete functions===============================*/

U LieSumCopyInteger(U a);
U LieSumCopyIntegerNegative(U a);
U LieSumCopyParametric(U a);
V LieSumKillInteger(U a);
V LieSumKillParametric(U a);
U LieTermFromMonomialInteger(I mon);
U LieTermFromMonomialParametric(I mon);
U ScalarSumCopy(U a);
V ScalarSumKill(U a);
U ScalarTermCopy(U a);

/*_6_7          Technical functions=====================================*/

V Error(I i_message);
V Initialization(V);
V *NewArray(U n, U size, I i_message);
U NodeLTNew(V);
U NodeSFNew(V);
U NodeSTNew(V);
FILE *OpenFile(S file_name, S file_type);

/*_6_8          Input functions=========================================*/

I BinaryQuestion(I i_message);
I FindNameInTable(S name, S nametab, I n_nametab);
V GetGenerator(S str);
V GetInput(I n, S fin);
V GetInteger(INT a, S *pstr);
U GetLieMonomial(S *pstr);
U GetLieSum(S *pstr);
U GetLieTerm(S *pstr);
U GetUInteger(S *pstr);
V GetParameter(S str);
V GetRelation(S str);
U GetScalarSum(S *pstr);
U GetScalarTerm(S *pstr);
V GetWeight(S str);
I KeyBoardBytesToString(S str);
I KeyBoardStringToFile(I i_m, S prefix, S str, FILE *file);
V ReadAndProcessStringsFromFile(V (*proc_func)(S str), FILE *inf,
                                                        C sep, C end);
I ReadBooleanFromFile(FILE *file);
I ReadCaseFromFile(FILE * file, S case_str[], I n_cases);
U ReadDecimalFromFile(FILE *file);
SHI ReadStringFromFile(S str, FILE *file);
SHI SkipCommentInFile(FILE *file);
V SkipName(S *pstr);
V SkipSpaces(S *pstr);
SHI SkipSpacesInFile(FILE *file);

/*_6_9          Output functions========================================*/

V AddSymbolToOutLine(C c, I position);
V InLineLevel(I level);
V InLineNumberInBrackets(U n);
V InLineString(S str);
V InLineSubscript(S s);
V InLineSymbol(C symbol);
V InLineTableName(S name);
S UToString(U n);
V PutBasis(V);
#if defined(GAP)
V PutBasisGAP(V);
#endif
V PutBlock(V);
V PutCharacter(C c);
#if defined(GAP)
V PutCharacterGAP(C c);
#endif
V PutCoefficientTable(V);
V PutCommutators(V);
#if defined(GAP)
V PutCommutatorsGAP(V);
#endif
V PutDegree(U deg);
V PutDimensions(V);
V PutDots(V);
V PutEnd(V);
V PutFormattedU(S format, U i);
V PutIntegerUnsigned(INT bn);
#if defined(GAP)
V PutIntegerUnsignedGAP(INT bn);
#endif
V PutLieBareTerm(V (*put_lie_mon)(I a), U a);
V PutLieBasisElement(I pos);
V PutLieMonomialLeftNormed(I pos);
V PutLieMonomialStandard(I pos);
#if defined(GAP)
V PutLieMonomialGAP(I pos);
#endif
V PutLieSum(V (*put_lie_mon)(I a), U a);
V PutMessage(I i_message);
V PutRelations(I i);
#if defined(GAP)
V PutRelationsGAP(V);
#endif
V PutScalarBareTerm(U a);
V PutScalarFactor(U a);
V PutScalarSum(U a);
V PutStart(V);
V PutStatistics(V);
V PutString(S str);
#if defined(GAP)
V PutStringGAP(S str);
#endif
V PutStringStandard(S str);
V PutSymbol(C c);

/* Global function variables */

I (*LieLikeTermsCollection)(U a, U b) = LieLikeTermsCollectionInteger;
U (*LieSumCopy)(U a) = LieSumCopyInteger;
V (*LieSumKill)(U a) = LieSumKillInteger;
V (*LieSumMinus)(U a) = LieSumMinusInteger;
U (*LieTermFromMonomial)(I mon) = LieTermFromMonomialInteger;
V (*NormalizeRelation)(U a) = NormalizeRelationInteger;
U (*PairMonomialMonomial)(I i, I j) = PairMonomialMonomialInteger;
U (*PairMonomialSum)(I mon, U a) = PairMonomialSumInteger;
U (*PairSumMonomial)(U a, I mon) = PairSumMonomialInteger;
U (*PairSumSum)(U a, U b) = PairSumSumInteger;
V (*PutLieMonomial)(I pos) = PutLieMonomialStandard;
U (*SubstituteRelationInRelation)(U r, U a) =
SubstituteRelationInRelationInteger;

/*_6_10   Debugging functions===========================================*/

#if defined(DEBUG)
V PutDebugHeader(U debug, S f_name, S in_out);
V PutDebugInteger(S name, INT u);
V PutDebugLieMonomial(S name, I a);
V PutDebugLieMonomialTable(I newmon);
V PutDebugLieSum(S name, U a);
V PutDebugLieTerm(S name, U a);
V PutDebugU(S name, U i);
#if defined(D_PUT_RELATIONS)
V PutDebugRelations(V);
#endif
V PutDebugScalarSum(S name, U a);
V PutDebugString(S strname, S str);
#endif
#if defined(MEMORY)
V AddLieSumNs(U a, I minus_or_plus,
              I *pn_lt, I *pn_int, I *pn_st, I *pn_sf);
V AddScalarSumNs(U a, I minus_or_plus, I *pn_int, I *pn_st, I *pn_sf);
V PutIntegerBalance(S fname, I dn);
V PutNodeBalance(S type, S fname, I dn);
#endif

/*_6_0          Main and top level functions============================*/

#if !defined(TEST_FUNCTION)
/*=main======================================
*/
V main(I narg, S * fin)
{
  Initialization();
  GetInput(narg, fin[1]);
  if(RelationN)
  {
    if(InitialRelationsPut)
      PutRelations(H_IN_RELATIONS);
    GenerateRelations();
    if(NonZeroCoefficientsPut)
      PutCoefficientTable();
  }
  if(RelationN)
  {
    if(ReducedRelationsPut)
      PutRelations(H_REDUCED_RELATIONS);
  }
  else /* Free algebra */
    ConstructFreeAlgebraBasis();
  PutBasis();
  if(HilbertSeriesPut)
    PutDimensions();
  if(CommutatorsPut)
    PutCommutators();
#if defined(DEBUG)
  PutDebugU("Top Debug", Debug);
#endif
  if(StatisticsPut)
  {
    TIME_OFF;
    PutStatistics();
  }
#if defined(GAP)
  if(!IsParametric && !IncompletedRelations && !IncompletedBasis)
  {
/*    if(GAPOutputCommutators || GAPOutputBasis || GAPOutputRelations) */
/*    {                                                                */
/*      fclose(SessionFile);                                           */
/*#if defined(SPP_2000)                                                */
/*      SessionFile = OpenFile("fplsa4.gap", "w");                     */
/*#else                                                                */
/*      SessionFile = OpenFile("fplsa4.gap", "wt");                    */
/*#endif                                                               */
/*    }                                                                */
    if(GAPOutputCommutators) 
      PutCommutatorsGAP();
    if(GAPOutputBasis)
      PutBasisGAP();
    if(GAPOutputRelations)
      PutRelationsGAP();
  }
#endif
  exit(0);
}
#endif
/*=ConstructFreeAlgebraBasis==========================================
 Make all regular monomials up to LimitingWeight
*/
V ConstructFreeAlgebraBasis(V)
{
  I i = 0, j, moni, monj;
  while(YES)
  {
    moni = LIE_MONOMIAL_POSITION(i);
    if(LIE_MONOMIAL_IS_NOT_SQUARE(moni)) /* ?? Not so for non-standard */
    {
      j = 0;
      while(j < i)
      {
        monj = LIE_MONOMIAL_POSITION(j);
        if(LIE_MONOMIAL_IS_NOT_SQUARE(monj))
          if(LIE_MONOMIAL_IS_GENERATOR(moni) ||
             j >= LIE_MONOMIAL_RIGHT_ORDER(moni))
          {
            if(LIE_MONOMIAL_WEIGHT(moni) + LIE_MONOMIAL_WEIGHT(0) >
               LimitingWeight) /* Out of weight for all consequent i & j */
              goto incompleted;
            if(LIE_MONOMIAL_WEIGHT(moni) + LIE_MONOMIAL_WEIGHT(monj) >
               LimitingWeight) /* Out of weight for all consequent j */
              goto next_i;  
            AddPairToLieMonomial(moni, monj);
          }
        j++;
      }
      if(LIE_MONOMIAL_IS_ODD(moni))
      {                           /* Add square */
        if(LIE_MONOMIAL_WEIGHT(moni) + LIE_MONOMIAL_WEIGHT(0) >
           LimitingWeight) /* Out of weight for all consequent i & j */
          goto incompleted;
        if(2*LIE_MONOMIAL_WEIGHT(moni) > LimitingWeight)
          goto next_i;         /* Out of weight for all consequent j */
        AddPairToLieMonomial(moni, moni);
      }
    }
    next_i:
    if(++i >= LieMonomialN)
      return;            /* One generator case */
  }
  incompleted:
  IncompletedBasis = YES;
}
/*=FindNewPositionInRelation======================================
 Find position of first relation with leading monomial order > lmo
 among 0, 1,..., RelationN - 1
*/
I FindNewPositionInRelation(I lmo)
{
  I left = 0;
  if(RelationN)                                /* Binary search */
  {                           /* `right' must be of signed type */
    I m, right = RelationN-1;
    do
    {
      m = (left + right)/2;
      if(lmo < LIE_TERM_MONOMIAL_ORDER(RELATION_LIE_SUM(m)))
        right = --m;
      else
        left = ++m;
    }while(left <= right);
  }
  return left;
}
/*=GenerateRelations=======================================================
 Generate and process new relations
*/
V GenerateRelations(V)
{
  I i, k, l, mon, mona,
      gen;    /* LieMonomial table position of differentiating generator */
  U a, lim_weight_i;
  i = 0;
  while(i < RelationN)                           /* Differentiation loop */
    if(RELATION_MIN_GENERATOR(i) < GeneratorN)
      if(LIE_MONOMIAL_IS_BASIS(gen = RELATION_MIN_GENERATOR(i)))
      {
        /* Program assures the ban of differentiation OF leading generators
           in the process of new relation adding by setting negation of the
           first IF predicate */
        a = RELATION_LIE_SUM(i);
        mona = LIE_TERM_MONOMIAL(a);   /* Irregular triple criterion */
        if(LIE_MONOMIAL_IS_SQUARE(mona) ||
           LIE_MONOMIAL_ORDER(gen) < LIE_MONOMIAL_RIGHT_ORDER(mona))
        {
IN_GENERATE_RELATIONS  /*------------------------------------------------*/
          if(LIE_MONOMIAL_WEIGHT(gen) +                 /* Out of weight */
             LIE_MONOMIAL_WEIGHT(LIE_TERM_MONOMIAL(a)) > LimitingWeight)
          {
            RELATION_MIN_GENERATOR(i++) = GeneratorN;
            continue;     /* There might be lower weight next generators */
          }
          RELATION_MIN_GENERATOR(i)++;       /* For next differentiation */
          if((a = (*PairSumMonomial)((*LieSumCopy)(a), gen)) != NIL)
          {
            add_new_relation:
            if(RelationN == RelationSize)
              Error(E_RELATION_SIZE);
            gen = LIE_TERM_MONOMIAL(a);
            l = FindNewPositionInRelation(k = LIE_MONOMIAL_ORDER(gen));
#if defined(SPACE_STATISTICS)
            if(RelationN >= MaxNRelation)
              MaxNRelation = RelationN + 1;
#endif
            (*NormalizeRelation)(a);
OUT_GENERATE_RELATIONS /*------------------------------------------------*/
            LIE_MONOMIAL_INDEX(gen) = ~l;    /* Set position of relation */

            /* Shift positions of higher  relations in LieMonomial */

            while(++k < LieMonomialN)
              if(LIE_MONOMIAL_IS_LEADING_BY_ORDER(k))
                --LIE_MONOMIAL_INDEX_BY_ORDER(k);

            /* Make room for new relation */

            for(k = RelationN; k > l; k--)
              Relation[k] = Relation[k-1];

            if(LIE_MONOMIAL_IS_GENERATOR(gen))    /* Ban differentiating */
              RELATION_MIN_GENERATOR(l) = GeneratorN;  /* lead. generat. */
            else
            {
              RELATION_MIN_GENERATOR(l) = 0;
              if(l <= i)                       /* Shift min. diff. index */
                i = l;
            }
            RELATION_LIE_SUM(l) = a;                 /* Set new relation */
            if(LIE_MONOMIAL_WEIGHT(gen) + 1 > LimitingWeight)
              RELATION_MIN_GENERATOR(l) = GeneratorN;
            if(l == RelationN++)
              RELATION_TO_BE_SUBSTITUTED(l) = NO;
            else
            {                           /* New relation inside the table */
              RELATION_TO_BE_SUBSTITUTED(l) = YES;
              l = ReduceRelations(l);
              if(l <= i)
                i = l;
            }
	    /* #if defined(RELATION_N_TO_SCREEN)
            TIME_OFF;
            printf("\n%10d", RelationN);
            TIME_ON;
	    #endif*/
OUT_PUT_LIE_MONOMIAL /*--------------------------------------------------*/
OUT_PUT_RELATIONS /*-----------------------------------------------------*/
          }
        }
        else                   /* Any next generator >= right of leading */
          RELATION_MIN_GENERATOR(i++) = GeneratorN;
      }
      else                  /* Skip differentiation BY leading generator */
        RELATION_MIN_GENERATOR(i)++;
    else
      i++;                    /* Skip completely differentiated relation */
  IncompletedBasis =                       /* Limiting weight is reached */
  IncompletedRelations =
    (LIE_MONOMIAL_WEIGHT(LIE_TERM_MONOMIAL(RELATION_LIE_SUM(RelationN-1)))
     >= LimitingWeight);

/*??#if 0 vvvvvvvvvvvvvvvvv Off checking vvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
  /* Check regular pairs */

  k = 0;
  while(k < LieMonomialN)
  {
    gen = LIE_MONOMIAL_POSITION(k);
    if(LIE_MONOMIAL_IS_BASIS(gen))
    {
#if 0 /*?? Experiment with individual basis elements vvvvvvvvvvvvvvvv */
      if(LIE_MONOMIAL_IS_COMMUTATOR(gen))
      {
                             /* Old pairs */
        a = NewJacobiRelation(gen);
        if(a != NIL)
/*??*/{
/*??*/PutDebugLieSum("\n***New Jacobi Relation from Old Basis", a);
          goto add_new_relation;
/*??*/}
      }
#endif /*??  Experiment ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ */
      if(LIE_MONOMIAL_WEIGHT(gen) + LIE_MONOMIAL_WEIGHT(0)
         > LimitingWeight)
      {
        IncompletedBasis = YES;
        goto loops_out;
      }
      if(LIE_MONOMIAL_IS_NOT_SQUARE(gen)) /* ?? non-standard square */
      {
        lim_weight_i = LimitingWeight - LIE_MONOMIAL_WEIGHT(gen);
        i = 0;
        do
        {
          mon = LIE_MONOMIAL_POSITION(i);
          if(LIE_MONOMIAL_IS_BASIS(mon) &&
             LIE_MONOMIAL_IS_NOT_SQUARE(mon) &&
             (i != k || LIE_MONOMIAL_IS_ODD(mon)) &&
             (LIE_MONOMIAL_IS_GENERATOR(gen) ||
              i >= LIE_MONOMIAL_RIGHT_ORDER(gen)))
          {
            if(LIE_MONOMIAL_WEIGHT(mon) > lim_weight_i)
              break; /* Stop considering next right monomials */ 
            mon = AddPairToLieMonomial(gen, mon);
            if(LieMonomialIsNew)
            {                              /* New pairs */
#if 0
/*??*/PutDebugLieMonomial("\n***New Lie Monomial", mon);
#endif
              a = NewJacobiRelation(mon);
              if(a != NIL)
#if 0
/*??*/{
/*??*/PutDebugLieSum("\n***New Jacobi Relation", a);
#endif
                goto add_new_relation;
#if 0
/*??*/}
#endif
            }
          }
        }while(++i <= k);
      }
    }
    ++k;
  }
  loops_out: ;
/*??#endif ^^^^^^^^^^^^^^^^^^^^ Off checking ^^^^^^^^^^^^^^^^^^^^*/
}
/*=NewJacobiRelation===================================================
  Construct independent Jacobi relation containing leading commutator L
*/
U NewJacobiRelation(I l)
{
  U a, b;
  I x, y, z;
IN_NEW_JACOBI_RELATION /*--------------------------------------------*/
  /* Try left pair in l = [[x,y],z] to make relation:  */
  /*                             p(x)p(y)              */
  /* [[x,y],z] - [x,[y,z]] + (-1)        [y,[x,z]] = 0 */

  x = LIE_MONOMIAL_LEFT(l);
  if(LIE_MONOMIAL_IS_COMMUTATOR(x))
  {
    z = LIE_MONOMIAL_RIGHT(l);
    y = LIE_MONOMIAL_RIGHT(x);
    x = LIE_MONOMIAL_LEFT(x);

    /* 1st of triple */

    a = (*LieTermFromMonomial)(l);

    /* 2nd of triple */

    if((b = (*PairMonomialMonomial)(z, y)) != NIL)
    {
      if(LIE_MONOMIAL_IS_ODD(y) && LIE_MONOMIAL_IS_ODD(z))
        b = (*PairSumMonomial)(b, x);
      else
        b = (*PairMonomialSum)(x, b);
      a = LieSumAddition(a, b);
    }

    /* 3d of triple */

    if(LIE_MONOMIAL_ORDER(x) > LIE_MONOMIAL_ORDER(z))
    {
      if((b = (*PairMonomialMonomial)(x, z)) != NIL)
      {
        if(LIE_MONOMIAL_IS_ODD(x) && LIE_MONOMIAL_IS_ODD(y))
        {
          b = (*PairSumMonomial)(b, y);
          if(LIE_MONOMIAL_IS_EVEN(z))
            (*LieSumMinus)(b);
        }
        else
          b = (*PairMonomialSum)(y, b);
        a = LieSumAddition(a, b);
      }
    }
    else
    {
      if((b = (*PairMonomialMonomial)(z, x)) != NIL)
      {
        if(LIE_MONOMIAL_IS_ODD(z) &&
           LIE_MONOMIAL_PARITY(x) != LIE_MONOMIAL_PARITY(y))
        {
          b = (*PairMonomialSum)(y, b);
          if(LIE_MONOMIAL_IS_EVEN(x))
            (*LieSumMinus)(b);
        }
        else
          b = (*PairSumMonomial)(b, y);
        a = LieSumAddition(a, b);
      }
    }

    if(a != NIL)
      goto out;
  }

  /* Try right pair in l = [x,[y,z]] to make relation: */
  /*                             p(x)p(y)              */
  /* [x,[y,z]] - [[x,y],z] - (-1)        [y,[x,z]] = 0 */

  y = LIE_MONOMIAL_RIGHT(l);
  if(LIE_MONOMIAL_IS_COMMUTATOR(y))
  {
    x = LIE_MONOMIAL_LEFT(l);
    z = LIE_MONOMIAL_RIGHT(y);
    y = LIE_MONOMIAL_LEFT(y);

    /* 1st of triple */

    a = (*LieTermFromMonomial)(l);

    /* 2nd of triple */

    if((b = (*PairMonomialMonomial)(x, y)) != NIL)
    {
      b = (*PairSumMonomial)(b, z);
      (*LieSumMinus)(b);
      a = LieSumAddition(a, b);
    }

    /* 3d of triple */

    if((b = (*PairMonomialMonomial)(x, z)) != NIL)
    {
      b = (*PairMonomialSum)(y, b);
      if(LIE_MONOMIAL_IS_EVEN(x) || LIE_MONOMIAL_IS_EVEN(y))
          (*LieSumMinus)(b);
      a = LieSumAddition(a, b);
    }

    goto out;
  }
  a = NIL;
  out:
OUT_NEW_JACOBI_RELATION /*-------------------------------------------*/
  return a;
}
/*=ReduceRelations=====================================================
  Reduce the system of relations starting from Ith one. For further
  differentiations returns lowest new positon (or starting one I).
*/
I ReduceRelations(I i)
{
  I i_min, j, lordj, lordl, min_gen, lmoni, k, l, m;
  U ai, aj;
  i_min = i;
  do           /* While relations with new leading monomialsls arise */
    if(RELATION_TO_BE_SUBSTITUTED(i))
    {
IN_REDUCE_RELATIONS  /*----------------------------------------------*/
      new_i:
      ai = RELATION_LIE_SUM(i);
      lmoni = LIE_TERM_MONOMIAL(ai);
      j = i + 1;
      while(j < RelationN)
      {
        aj = RELATION_LIE_SUM(j);
        lordj = LIE_TERM_MONOMIAL_ORDER(aj);
        aj = (*SubstituteRelationInRelation)(ai, aj);
        test_substitution_result:
        if(SubstitutionIsDone)
          if(aj == NIL)                        /* Killed relation */
          {
            --RelationN;
            k = lordj;
            l = LIE_MONOMIAL_POSITION(k);
            LIE_MONOMIAL_INDEX(l) = 0;            /* To ban usage */
            while(++k < LieMonomialN)   /* Shift I's of relations */
            {
              l = LIE_MONOMIAL_POSITION(k);
              if(LIE_MONOMIAL_IS_LEADING(l))       /* LieMonomial */
                ++LIE_MONOMIAL_INDEX(l);
            }
            for(k = j; k < RelationN; k++) /* Remove gap shifting */
              Relation[k] = Relation[k+1]; /* down top relations  */
            continue;
          }
          else          /* Non-killing substitution has been done */
          {
            (*NormalizeRelation)(aj);
            lordl = LIE_TERM_MONOMIAL_ORDER(aj);
            if(lordl < lordj)        /* Change of leading ordinal */
            {
              l = 0;
              k = j - 1;         /* Binary search of new position */
              while(l <= k)
              {
                m = (l + k)/2;
                if(lordl < LIE_TERM_MONOMIAL_ORDER(RELATION_LIE_SUM(m)))
                  k = --m;
                else
                  l = ++m;
              }
              if(l &&
                 LIE_TERM_MONOMIAL_ORDER(RELATION_LIE_SUM(l-1)) == lordl)
              {             /* Substitute once more to avoid collision */
                aj = (*SubstituteRelationInRelation)
                                           (RELATION_LIE_SUM(l-1), aj);
                goto test_substitution_result;
              }
              /* Set index of dropped relation in LieMonomial */
              LIE_MONOMIAL_INDEX_BY_ORDER(lordl) = ~l;
              /* Set zero to ban using old leading monomial
                 of dropped relation */
              LIE_MONOMIAL_INDEX_BY_ORDER(lordj) = 0;
              min_gen = RELATION_MIN_GENERATOR(j);
              /* Shift upper relations and their indices */
              k = (j+1 == RelationN) ? LieMonomialN :
                  LIE_TERM_MONOMIAL_ORDER(RELATION_LIE_SUM(j+1));
              while(--k > lordl)
                if(LIE_MONOMIAL_IS_LEADING_BY_ORDER(k))
                  --LIE_MONOMIAL_INDEX_BY_ORDER(k); /* Means ++ */
              for(k = j; k > l; k--)
                Relation[k] = Relation[k-1];
              RELATION_MIN_GENERATOR(l) =
                LIE_MONOMIAL_IS_GENERATOR_BY_ORDER(lordl) ?
                GeneratorN : /* Don't differentiate leading generator */
                min_gen;   /* Avoiding redifferentiation (or set 0 ??) */
              RELATION_TO_BE_SUBSTITUTED(l) = (CU)(l < RelationN-1);
              RELATION_LIE_SUM(l) = aj;
              if(l <= i)
              {         /* New substituted relation with lesser ordinal */
                i = l;
                if(i < i_min)
                  i_min = i;
                goto new_i;
              }
            }
            else                  /* No change of leading ordinal */
              RELATION_LIE_SUM(j) = aj;
          }
        j++;
      }
      /* Remove consequences of leading monomial of substituted relation
         from LieMonomial table */
      lordj = LieMonomialN-1;
      m = LIE_MONOMIAL_WEIGHT(lmoni);
      while(LIE_MONOMIAL_WEIGHT_BY_ORDER(lordj) > (U)m)
      {
        l = LIE_MONOMIAL_POSITION(lordj);
        if(IsMonomialInMonomial(lmoni, l))
        {
          if(l < LieMonomialFreePosition)   /* Set possibly lowest */
            LieMonomialFreePosition = l;    /* free position */
          LIE_MONOMIAL_IS_OCCUPIED(l) = NO; /* Mark free position */
          LieMonomialN--;
          lordl = k = lordj;
          while(k < LieMonomialN)
          {
            l = LIE_MONOMIAL_POSITION(++lordl); /* Shift positions */
            LIE_MONOMIAL_POSITION(k++) = l;     /* of upper orders */
            --LIE_MONOMIAL_ORDER(l); /* Decrease orders of upper monomials */
          }
        }
        lordj--;
      }
      RELATION_TO_BE_SUBSTITUTED(i) = NO;
OUT_REDUCE_RELATIONS /*----------------------------------------------*/
    }
  while(++i < RelationN);
  return i_min;
}

/*_6_1          Pairing functions=======================================*/

/*=AddPairToLieMonomial=================================================
 Find position in LieMonomial table for regular pair [i,j].
 LieMonomialIsNew is global boolean signal:
 LieMonomialIsNew == YES if pair has to be added in table,
 if so, add the pair to the table,
 LieMonomialIsNew == NO if pair exists already in table.
 Return position for [i,j]
*/
I AddPairToLieMonomial(I i, I j)
{
  U wt = LIE_MONOMIAL_WEIGHT(i) + LIE_MONOMIAL_WEIGHT(j);
  I ijo /* left */, r /* right */, m /* middle */, ijp;
IN_ADD_PAIR_TO_LIE_MONOMIAL  /*------------------------------------------*/
  ijo = 0;
  r = LieMonomialN - 1;
  do
  {
    m = (ijo + r)/2;
    ijp = LIE_MONOMIAL_POSITION(m);

    /* Compare wrt weights */

    if(wt > LIE_MONOMIAL_WEIGHT(ijp))
      goto shift_left;
    if(wt < LIE_MONOMIAL_WEIGHT(ijp))
      goto shift_right;

    /* Equal weights: compare lexicographically */

    if(LIE_MONOMIAL_ORDER(i) > LIE_MONOMIAL_LEFT_ORDER(ijp))
      goto shift_left;
    if(LIE_MONOMIAL_ORDER(i) < LIE_MONOMIAL_LEFT_ORDER(ijp))
      goto shift_right;
    if(LIE_MONOMIAL_ORDER(j) > LIE_MONOMIAL_RIGHT_ORDER(ijp))
      goto shift_left;
    if(LIE_MONOMIAL_ORDER(j) < LIE_MONOMIAL_RIGHT_ORDER(ijp))
      goto shift_right;
    LieMonomialIsNew = NO;
OUT_ADD_PAIR_TO_LIE_MONOMIAL_OLD  /*-------------------------------------*/
    return ijp;
    shift_left:
    ijo = ++m;
    continue;
    shift_right:
    r = --m;
  }while(ijo <= r);

  /* Add new monomial to table */

  LieMonomialIsNew = YES;
  if(LieMonomialN >= LieMonomialSize)
  {
    TIME_OFF;
    PutStatistics();                          /* No room for new element */
    Error(E_LIE_MONOMIAL_SIZE);
  }
  m = r = LieMonomialN++;
#if defined(SPACE_STATISTICS)
  if(LieMonomialN > LieMonomialMaxN)
    LieMonomialMaxN = LieMonomialN;
#endif
  while(m > ijo)
  {
    ijp = LIE_MONOMIAL_POSITION(--r); /* Shift positions of upper orders */
    LIE_MONOMIAL_POSITION(m--) = ijp;
    ++LIE_MONOMIAL_ORDER(ijp);      /* Increase orders of upper elements */
  }
  while(LIE_MONOMIAL_IS_OCCUPIED(LieMonomialFreePosition))
    LieMonomialFreePosition++;                   /* Search free position */
  ijp = LieMonomialFreePosition++;
  LIE_MONOMIAL_ORDER(ijp) = ijo;
  LIE_MONOMIAL_POSITION(ijo) = ijp;  /* Parity is 1bit field: + is mod 2 */
  LIE_MONOMIAL_PARITY(ijp) = LIE_MONOMIAL_PARITY(i) + LIE_MONOMIAL_PARITY(j);
  LIE_MONOMIAL_LEFT(ijp) = i;
  LIE_MONOMIAL_RIGHT(ijp) = j;
  LIE_MONOMIAL_WEIGHT(ijp) = wt;
  LIE_MONOMIAL_INDEX(ijp) = 0;              /* Set type of basis element */
OUT_ADD_PAIR_TO_LIE_MONOMIAL_NEW  /*-------------------------------------*/
  return ijp;
}
/*=MakeRelationRHSInteger============================================
 Make r.h.s. of i-th relation (Integer regime)
 Relation is in normalized form (no denominators, no content)
*/
U MakeRelationRHSInteger(I i)
{
  U c;
  if((c = LIE_TERM_R(RELATION_LIE_SUM(i))) != NIL)
  {
    INT n, cn;
#if !defined(RATIONAL_FIELD)
    INT ln = LIE_TERM_NUMERATOR_INTEGER(RELATION_LIE_SUM(i));
#endif
    U a, ea;
IN_MAKE_RELATION_RHS  /*-------------------------------------------*/
    /* Copy r.h.s setting negations for numerators */
    a = ea = NodeLTNew();
    LIE_TERM_MONOMIAL(ea) = LIE_TERM_MONOMIAL(c);
    n = LIE_TERM_NUMERATOR_INTEGER(c);
    INTEGER_HEAP_COPY(cn, n, i);
    INTEGER_MINUS(cn);
    LIE_TERM_NUMERATOR_INTEGER(ea) = cn;
    if((n = LIE_TERM_DENOMINATOR_INTEGER(c)) != NULL)
    {
      INTEGER_HEAP_COPY(cn, n, i);
      LIE_TERM_DENOMINATOR_INTEGER(ea) = cn;
    }
    else
      LIE_TERM_DENOMINATOR_INTEGER(ea) = NULL;
    while((c = LIE_TERM_R(c)) != NIL)
    {
      LIE_TERM_R(ea) = NodeLTNew();
      ea = LIE_TERM_R(ea);
      LIE_TERM_MONOMIAL(ea) = LIE_TERM_MONOMIAL(c);
      n = LIE_TERM_NUMERATOR_INTEGER(c);
      INTEGER_HEAP_COPY(cn, n, i);
      INTEGER_MINUS(cn);
      LIE_TERM_NUMERATOR_INTEGER(ea)= cn;
      if((n = LIE_TERM_DENOMINATOR_INTEGER(c)) != NULL)
      {
        INTEGER_HEAP_COPY(cn, n, i);
        LIE_TERM_DENOMINATOR_INTEGER(ea) = cn;
      }
      else
        LIE_TERM_DENOMINATOR_INTEGER(ea) = NULL;
    }
#if !defined(RATIONAL_FIELD)
    /* Divide by leading coefficient */
    if(INTEGER_IS_NOT_UNIT(ln))
    {
      INTEGER_STACK_COPY(cn, ln, i);
      LieSumDivInteger(a, cn);
    }
#endif
OUT_MAKE_RELATION_RHS /*-------------------------------------------*/
    return a;
  }
  return NIL;
}
/*=MakeRelationRHSParametric============================================
 Make r.h.s. of i-th relation (Parametric regime)
 Relation is in normalized form (no denominators, no content)
*/
U MakeRelationRHSParametric(I i)
{
  U a;
IN_MAKE_RELATION_RHS  /*----------------------------------------------*/
  if((a = LieSumCopyParametric(LIE_TERM_R(RELATION_LIE_SUM(i)))) != NIL)
  {
    U lc;

    /* Negation */

    LieSumMinusParametric(a);

    /* Divide by leading coefficient */

    lc = LIE_TERM_NUMERATOR_SCALAR_SUM(RELATION_LIE_SUM(i));
    if(SCALAR_SUM_IS_NOT_UNIT(lc))
    {
      lc = ScalarSumCopy(lc);
      LieSumDivScalarSum(a, lc);
    }
  }
OUT_MAKE_RELATION_RHS /*----------------------------------------------*/
  return a;
}
/*=PairMonomialMonomialInteger==============================
 Make regular expression from two monomials (Integer regime)
 Caller ensures ORDER(i) >= ORDER(j)
*/
U PairMonomialMonomialInteger(I i, I j)
{
  U a;
  I k;
IN_PAIR_MONOMIAL_MONOMIAL  /*-----------------------------*/
  if(LIE_MONOMIAL_IS_SQUARE(j))
  {                          /* [i,[j,j]] = 2 [[i,j],j] */
    j = LIE_MONOMIAL_LEFT(j);
    a = PairMonomialMonomialInteger(i, j);
    a = PairSumMonomialInteger(a, j);
    if(a != NIL)
    {
      LIMB two[2] = {1, 2};
      LieSumMultInteger(a, two);
    }
  }
  else if(LIE_MONOMIAL_IS_SQUARE(i))
  {
    LIMB two[2] = {1, 2};
    i = LIE_MONOMIAL_LEFT(i);
    if(i == j)
      a = NIL;                         /* [[i,i],i] = 0 */
    else
    {
      if(LIE_MONOMIAL_ORDER(i) < LIE_MONOMIAL_ORDER(j))
        a = PairMonomialMonomialInteger(j, i);
                           /* [[i,i],j] = - 2 [[j,i],i] */
      else
      {
        a = PairMonomialMonomialInteger(i, j);
        if(LIE_MONOMIAL_IS_EVEN(j))
          goto last_pairing; /* [[i,i],j] = 2 [[i,j],i] */
      }       /* IS_ODD(j) -> [[i,i],j] = - 2 [[i,j],i] */
      INTEGER_SET_MINUS(two);                /* 2 -> -2 */
      last_pairing:
      a = PairSumMonomialInteger(a, i);
      if(a != NIL)
        LieSumMultInteger(a, two);
    }
  }
  else if(LIE_MONOMIAL_IS_COMMUTATOR(i) &&  /* Irregular triple */
          LIE_MONOMIAL_ORDER(j) < LIE_MONOMIAL_RIGHT_ORDER(i))
  {
    U b;              /* i > k > j  =>  [[i,k],j]] =	*/
    k = LIE_MONOMIAL_RIGHT(i);
    i = LIE_MONOMIAL_LEFT(i);
    a = PairMonomialMonomialInteger(i, j);
    a = PairSumMonomialInteger(a, k);    /* + [[i,j],k] */
    if(LIE_MONOMIAL_IS_ODD(j) && LIE_MONOMIAL_IS_ODD(k))
    {
      U c = a;                          /* - [[i,j],k] */
      while(c != NIL)
      {
        LIE_TERM_MINUS_INTEGER(c);
        c = LIE_TERM_R(c);
      }
    }
    b = PairMonomialMonomialInteger(k, j);
    b = PairSumMonomialInteger(b, i);    /* + [[k,j],i] */
    if(LIE_MONOMIAL_IS_EVEN(i) ||
       LIE_MONOMIAL_PARITY(j) == LIE_MONOMIAL_PARITY(k))
    {
      U c = b;                          /* - [[k,j],i] */
      while(c != NIL)
      {
        LIE_TERM_MINUS_INTEGER(c);
        c = LIE_TERM_R(c);
      }
    }
    a = LieSumAddition(a, b);
  }
  else if(i == j && LIE_MONOMIAL_IS_EVEN(i))
    a = NIL;                    /* [i,i] = 0 for even i */
  else
  {                                     /* Regular pair */
    k = AddPairToLieMonomial(i, j);
    if(LIE_MONOMIAL_IS_LEADING(k))
      a = MakeRelationRHSInteger(LIE_MONOMIAL_I_RELATION(k));
    else
    {
      INT n;
      a = NodeLTNew();
      LIE_TERM_MONOMIAL(a) = k;
      INTEGER_HEAP_NEW(n, 2);
      n[0] = n[1] = 1;
      LIE_TERM_NUMERATOR_INTEGER(a) = n;
      LIE_TERM_DENOMINATOR_INTEGER(a) = NULL;
    }
  }
OUT_PAIR_MONOMIAL_MONOMIAL  /*----------------------------*/
  return a;
}
/*=PairMonomialMonomialParametric==============================
 Make regular expression from two monomials (Parametric regime)
 Caller ensures i >= j by Shirshov
*/
U PairMonomialMonomialParametric(I i, I j)
{
  U a;
  I k;
IN_PAIR_MONOMIAL_MONOMIAL  /*--------------------------------*/
  if(LIE_MONOMIAL_IS_SQUARE(j))
  {                               /* [i,[j,j]] = 2 [[i,j],j] */
    j = LIE_MONOMIAL_LEFT(j);
    a = PairMonomialMonomialParametric(i, j);
    a = PairSumMonomialParametric(a, j);
    if(a != NIL)
    {
      U two;
      INT n2;
      INTEGER_HEAP_NEW(n2, 2);
      n2[0] = 1;
      n2[1] = 2;
      two = NodeSTNew();
      SCALAR_TERM_MONOMIAL(two) = NIL;
      SCALAR_TERM_NUMERATOR(two) = n2;
      LieSumMultScalarSum(a, two);
    }
  }
  else if(LIE_MONOMIAL_IS_SQUARE(i))
  {
    INT n2;
    i = LIE_MONOMIAL_LEFT(i);
    if(i == j)
      a = NIL;                              /* [[i,i],i] = 0 */
    else
    {
      INTEGER_HEAP_NEW(n2, 2);
      n2[0] = 1;
      n2[1] = 2;
      if(LIE_MONOMIAL_ORDER(i) < LIE_MONOMIAL_ORDER(j))
        a = PairMonomialMonomialParametric(j, i);
                                /* [[i,i],j] = - 2 [[j,i],i] */
      else
      {
        a = PairMonomialMonomialParametric(i, j);
        if(LIE_MONOMIAL_IS_EVEN(j))
          goto last_pairing;      /* [[i,i],j] = 2 [[i,j],i] */
      }            /* IS_ODD(j) -> [[i,i],j] = - 2 [[i,j],i] */
      INTEGER_SET_MINUS(n2);                      /* 2 -> -2 */
      last_pairing:
      a = PairSumMonomialParametric(a, i);
      if(a != NIL)
      {
        U two = NodeSTNew();
        SCALAR_TERM_MONOMIAL(two) = NIL;
        SCALAR_TERM_NUMERATOR(two) = n2;
        LieSumMultScalarSum(a, two);
      }
      else
        INTEGER_KILL(n2);
    }
  }
  else if(LIE_MONOMIAL_IS_COMMUTATOR(i) &&  /* Irregular triple */
          LIE_MONOMIAL_ORDER(j) < LIE_MONOMIAL_RIGHT_ORDER(i))
  {
    U b;                     /* i > k > j  =>  [[i,k],j]] = */
    k = LIE_MONOMIAL_RIGHT(i);
    i = LIE_MONOMIAL_LEFT(i);
    a = PairMonomialMonomialParametric(i, j);
    a = PairSumMonomialParametric(a, k);      /* + [[i,j],k] */
    if(LIE_MONOMIAL_IS_ODD(j) && LIE_MONOMIAL_IS_ODD(k))
      LieSumMinusParametric(a);               /* - [[i,j],k] */
    b = PairMonomialMonomialParametric(k, j);
    b = PairSumMonomialParametric(b, i);      /* + [[k,j],i] */
    if(LIE_MONOMIAL_IS_EVEN(i) ||
       LIE_MONOMIAL_PARITY(j) == LIE_MONOMIAL_PARITY(k))
      LieSumMinusParametric(b);               /* - [[k,j],i] */
    a = LieSumAddition(a, b);
  }
  else if(i == j && LIE_MONOMIAL_IS_EVEN(i))
    a = NIL;                         /* [i,i] = 0 for even i */
  else
  {                                          /* Regular pair */
    k = AddPairToLieMonomial(i, j);
    if(LIE_MONOMIAL_IS_LEADING(k))
      a = MakeRelationRHSParametric(LIE_MONOMIAL_I_RELATION(k));
    else
    {
      INT n;
      U c;
      a = NodeLTNew();
      LIE_TERM_MONOMIAL(a) = k;
      INTEGER_HEAP_NEW(n, 2);
      n[0] = n[1] = 1;
      c = NodeSTNew();
      SCALAR_TERM_MONOMIAL(c) = NIL;
      SCALAR_TERM_NUMERATOR(c) = n;
      LIE_TERM_NUMERATOR_SCALAR_SUM(a) = c;
      LIE_TERM_DENOMINATOR_SCALAR_SUM(a) = NIL;
    }
  }
OUT_PAIR_MONOMIAL_MONOMIAL  /*--------------------------------*/
  return a;
}
/*=PairMonomialSumInteger==========================================

 Make commutator of the form [mon, Lie_sum] (Integer regime)
*/
U PairMonomialSumInteger(I mon, U a)
{
  U b, s;
  INT nb, db;                        /* Sum has definite parity */
  I monb, change_sign = (LIE_MONOMIAL_IS_EVEN(mon) ||
                      LIE_MONOMIAL_IS_EVEN(LIE_TERM_MONOMIAL(a)));
IN_PAIR_MONOMIAL_SUM  /*----------------------------------------*/
  s = NIL;
  while(a != NIL)
  {
    b = a;
    a = LIE_TERM_R(a);
    monb = LIE_TERM_MONOMIAL(b);     /* Take full info from `b' */
    nb = LIE_TERM_NUMERATOR_INTEGER(b);
    db = LIE_TERM_DENOMINATOR_INTEGER(b);
    NODE_LT_KILL(b);
    if(mon != monb || LIE_MONOMIAL_IS_ODD(mon))
    {                                       /* [mon, monb] != 0 */
      if(LIE_MONOMIAL_ORDER(mon) < LIE_MONOMIAL_ORDER(monb))
      {                                       /* Swap monomials */
        if(change_sign)
          INTEGER_MINUS(nb);
        b = PairMonomialMonomialInteger(monb, mon);
      }
      else
        b = PairMonomialMonomialInteger(mon, monb);
      if(INTEGER_IS_NOT_UNIT(nb))
        LieSumMultInteger(b, nb);
      if(db != NULL)
        LieSumDivInteger(b, db);
      s = LieSumAddition(s, b);
    }
    INTEGER_KILL(nb);
    if(db != NULL)
      INTEGER_KILL(db);
  }
OUT_PAIR_MONOMIAL_SUM  /*---------------------------------------*/
  return s;
}
/*=PairMonomialSumParametric======================================
 Make commutator of the form [mon, Lie_sum] (Parametric regime)
*/
U PairMonomialSumParametric(I mon, U a)
{
  U b, s, nb, db;                    /* Sum has definite parity */
  I monb, change_sign = (LIE_MONOMIAL_IS_EVEN(mon) ||
                      LIE_MONOMIAL_IS_EVEN(LIE_TERM_MONOMIAL(a)));
IN_PAIR_MONOMIAL_SUM   /*---------------------------------------*/
  s = NIL;
  while(a != NIL)
  {
    b = a;
    a = LIE_TERM_R(a);
    monb = LIE_TERM_MONOMIAL(b);     /* Take full info from `b' */
    nb = LIE_TERM_NUMERATOR_SCALAR_SUM(b);
    db = LIE_TERM_DENOMINATOR_SCALAR_SUM(b);
    NODE_LT_KILL(b);
    if(mon != monb || LIE_MONOMIAL_IS_ODD(mon))
    {                                       /* [mon, monb] != 0 */
      if(LIE_MONOMIAL_ORDER(mon) < LIE_MONOMIAL_ORDER(monb))
      {                                       /* Swap monomials */
        if(change_sign)
          ScalarSumMinus(nb);
        b = PairMonomialMonomialParametric(monb, mon);
      }
      else
        b = PairMonomialMonomialParametric(mon, monb);
      if(SCALAR_SUM_IS_NOT_UNIT(nb))
        LieSumMultScalarSum(b, nb);
      else
        ScalarSumKill(nb);
      if(db != NIL)
        LieSumDivScalarSum(b, db);
      s = LieSumAddition(s, b);
    }
    else
    {
      ScalarSumKill(nb);
      ScalarSumKill(db);
    }
  }
OUT_PAIR_MONOMIAL_SUM  /*---------------------------------------*/
  return s;
}
/*=PairSumMonomialInteger==========================================

 Make commutator of the form [Lie_sum, mon] (Integer regime)
*/
U PairSumMonomialInteger(U a, I mon)
{
  U b, s;
  INT nb, db;                        /* Sum has definite parity */
  I monb, change_sign = (LIE_MONOMIAL_IS_EVEN(mon) ||
                      LIE_MONOMIAL_IS_EVEN(LIE_TERM_MONOMIAL(a)));
IN_PAIR_SUM_MONOMIAL   /*---------------------------------------*/
  s = NIL;
  while(a != NIL)
  {
    b = a;
    a = LIE_TERM_R(a);
    monb = LIE_TERM_MONOMIAL(b);     /* Take full info from `b' */
    nb = LIE_TERM_NUMERATOR_INTEGER(b);
    db = LIE_TERM_DENOMINATOR_INTEGER(b);
    NODE_LT_KILL(b);
    if(mon != monb || LIE_MONOMIAL_IS_ODD(mon))
    {                                       /* [monb, mon] != 0 */
      if(LIE_MONOMIAL_ORDER(monb) < LIE_MONOMIAL_ORDER(mon))
      {                                       /* Swap monomials */
        if(change_sign)
          INTEGER_MINUS(nb);
        b = PairMonomialMonomialInteger(mon, monb);
      }
      else
        b = PairMonomialMonomialInteger(monb, mon);
      if(INTEGER_IS_NOT_UNIT(nb))
        LieSumMultInteger(b, nb);
      if(db != NULL)
        LieSumDivInteger(b, db);
      s = LieSumAddition(s, b);
    }
    INTEGER_KILL(nb);
    if(db != NULL)
      INTEGER_KILL(db);
  }
OUT_PAIR_SUM_MONOMIAL  /*---------------------------------------*/
  return s;
}
/*=PairSumMonomialParametric======================================
 Make commutator of the form [Lie_sum, mon] (Parametric regime)
*/
U PairSumMonomialParametric(U a, I mon)
{
  U b, s, nb, db;                    /* Sum has definite parity */
  I monb, change_sign = (LIE_MONOMIAL_IS_EVEN(mon) ||
                      LIE_MONOMIAL_IS_EVEN(LIE_TERM_MONOMIAL(a)));
IN_PAIR_SUM_MONOMIAL   /*---------------------------------------*/
  s = NIL;
  while(a != NIL)
  {
    b = a;
    a = LIE_TERM_R(a);
    monb = LIE_TERM_MONOMIAL(b);     /* Take full info from `b' */
    nb = LIE_TERM_NUMERATOR_SCALAR_SUM(b);
    db = LIE_TERM_DENOMINATOR_SCALAR_SUM(b);
    NODE_LT_KILL(b);
    if(mon != monb || LIE_MONOMIAL_IS_ODD(mon))
    {                                       /* [monb, mon] != 0 */
      if(LIE_MONOMIAL_ORDER(monb) < LIE_MONOMIAL_ORDER(mon))
      {                                       /* Swap monomials */
        if(change_sign)
          ScalarSumMinus(nb);
        b = PairMonomialMonomialParametric(mon, monb);
      }
      else
        b = PairMonomialMonomialParametric(monb, mon);
      if(SCALAR_SUM_IS_NOT_UNIT(nb))
        LieSumMultScalarSum(b, nb);
      else
        ScalarSumKill(nb);
      if(db != NIL)
        LieSumDivScalarSum(b, db);
      s = LieSumAddition(s, b);
    }
  }
OUT_PAIR_SUM_MONOMIAL  /*---------------------------------------*/
  return s;
}
/*=PairSumSumInteger======================================
 Commutator of the form [Lie_sum,Lie_sum] (Integer regime)
*/
U PairSumSumInteger(U a, U b)
{
IN_PAIR_SUM_SUM  /*-------------------------------------*/
  if(a == NIL)
    LieSumKillInteger(b);
  else if(b == NIL)
  {
    LieSumKillInteger(a);
    a = b;
  }
  else
  {
    INT num, den;
    U c, d, s;
    s = NIL;
    do
    {
      c = a;
      a = LIE_TERM_R(c);
      d = (a != NIL) ? LieSumCopyInteger(b) : b;
      d = PairMonomialSumInteger(LIE_TERM_MONOMIAL(c), d);
      num = LIE_TERM_NUMERATOR_INTEGER(c);
      den = LIE_TERM_DENOMINATOR_INTEGER(c);
      NODE_LT_KILL(c);
      if(INTEGER_IS_NOT_UNIT(num))
        LieSumMultInteger(d, num);
      INTEGER_KILL(num);
      if(den != NULL)
      {
        LieSumDivInteger(d, den);
        INTEGER_KILL(den);
      }
      s = LieSumAddition(s, d);
    }while(a != NIL);
    a = s;
  }
OUT_PAIR_SUM_SUM /*-------------------------------------*/
  return a;
}
/*=PairSumSumParametric======================================
 Commutator of the form [Lie_sum,Lie_sum] (Parametric regime)
*/
U PairSumSumParametric(U a, U b)
{
IN_PAIR_SUM_SUM  /*----------------------------------------*/
  if(a == NIL)
    LieSumKillParametric(b);
  else if(b == NIL)
  {
    LieSumKillParametric(a);
    a = b;
  }
  else
  {
    U num, den, c, d, s;
    s = NIL;
    do
    {
      c = a;
      a = LIE_TERM_R(c);
      d = (a != NIL) ? LieSumCopyParametric(b) : b;
      d = PairMonomialSumParametric(LIE_TERM_MONOMIAL(c), d);
      num = LIE_TERM_NUMERATOR_SCALAR_SUM(c);
      den = LIE_TERM_DENOMINATOR_SCALAR_SUM(c);
      NODE_LT_KILL(c);
      if(SCALAR_SUM_IS_NOT_UNIT(num))
        LieSumMultScalarSum(d, num);
      else
        ScalarSumKill(num);
      if(den != NIL)
        LieSumDivScalarSum(d, den);
      s = LieSumAddition(s, d);
    }while(a != NIL);
    a = s;
  }
OUT_PAIR_SUM_SUM /*----------------------------------------*/
  return a;
}

/*_6_2          Substitution (replacing) functions======================*/

/*=IsMonomialInMonomial==========================================

 Check whether `mon' contains `submon'
*/
I IsMonomialInMonomial(I submon, I mon)
{
  if(LIE_MONOMIAL_ORDER(submon) > LIE_MONOMIAL_ORDER(mon))
    return NO;
  if(submon == mon)
    return YES;
  if(LIE_MONOMIAL_IS_GENERATOR(mon))
    return NO;
  return IsMonomialInMonomial(submon, LIE_MONOMIAL_LEFT(mon)) ||
         IsMonomialInMonomial(submon, LIE_MONOMIAL_RIGHT(mon));
}
/*=SubstituteRelationInRelationInteger================================
 R is donor and unchanged, A is acceptor and changed. Integer regime
*/
U SubstituteRelationInRelationInteger(U r, U a)
{
  U b, bl, bf, rhs;
  INT nb;
#if defined(RATIONAL_FIELD)
  INT db;
#endif
  I lmon, monb, lord;
IN_SUBSTITUTE_RELATION_IN_RELATION /*-------------------------------*/
  lmon = LIE_TERM_MONOMIAL(r);
  lord = LIE_MONOMIAL_ORDER(lmon);
  SubstitutionIsDone = NO;
  bl = NIL;
  bf = b = a;
  do
  {
    monb = LIE_TERM_MONOMIAL(b);
    if(LIE_MONOMIAL_ORDER(monb) < lord)
    {
      if(SubstitutionIsDone)
      {
        a = LieSumAddition(a, bf);
        LieSumKillInteger(rhs);
      }
      goto out;
    }
    if(IsMonomialInMonomial(lmon, monb))
    {
      if(SubstitutionIsDone == NO)        /* First substituent term */
      {                                /* Make right hand side of R */
        rhs = LieSumCopyIntegerNegative(LIE_TERM_R(r));
#if !defined(RATIONAL_FIELD)
        if(rhs != NIL)
        {
          nb = LIE_TERM_NUMERATOR_INTEGER(r);
          if(INTEGER_IS_NOT_UNIT(nb))
          {
            INT den;
            I i;                   /* Divide by leading coefficient */
            INTEGER_STACK_COPY(den, nb, i);
            LieSumDivInteger(rhs, den);
          }
        }
#endif
        SubstitutionIsDone = YES;
        a = NIL;
      }
      nb = LIE_TERM_NUMERATOR_INTEGER(b);
      if((r = SubstituteRHSInMonomialInteger(monb, lmon, rhs)) != NIL)
      {
#if defined(RATIONAL_FIELD)                 /* Field R case compiling */
        db = LIE_TERM_DENOMINATOR_INTEGER(b);
        if(INTEGER_IS_UNIT(nb))
        {
          if(db != NULL)
          {
            LieSumDivInteger(r, db);
            INTEGER_KILL(db);
          }
        }
        else
          if(db != NULL)
          {
            LieSumMultRationalInteger(r, nb, db);
            INTEGER_KILL(db);
          }
          else
            LieSumMultInteger(r, nb);
#else                                         /* Ring Z case compiling */
        if(INTEGER_IS_NOT_UNIT(nb))
          LieSumMultInteger(r, nb);
#endif
        a = LieSumAddition(a, r);
      }
      INTEGER_KILL(nb);
      if(bl != NIL)
      {                /* There is substitution-free sublist before */
        LIE_TERM_R(bl) = NIL;
        a = LieSumAddition(a, bf);
      }
      bl = b;
      bf = b = LIE_TERM_R(b);
      NODE_LT_KILL(bl);
      bl = NIL;
    }
    else
    {                                /* Skip substitution-free term */
      bl = b;
      b = LIE_TERM_R(b);
    }
  }while(b != NIL);
  if(SubstitutionIsDone)
  {                                /* Append substitution-free tail */
    if(bl != NIL)
      a = LieSumAddition(a, bf);
    LieSumKillInteger(rhs);
  }
  out:
OUT_SUBSTITUTE_RELATION_IN_RELATION /*------------------------------*/
  return a;
}
/*=SubstituteRelationInRelationParametric================================
 R is donor and unchanged, A is acceptor and changed. Parametric regime
*/
U SubstituteRelationInRelationParametric(U r, U a)
{
  U b, bl, bf, rhs, pb;
  I lmon, monb, lord;
IN_SUBSTITUTE_RELATION_IN_RELATION /*----------------------------------*/
  lmon = LIE_TERM_MONOMIAL(r);
  lord = LIE_MONOMIAL_ORDER(lmon);
  SubstitutionIsDone = NO;
  bl = NIL;
  bf = b = a;
  do
  {
    monb = LIE_TERM_MONOMIAL(b);
    if(LIE_MONOMIAL_ORDER(monb) < lord)
    {
      if(SubstitutionIsDone)
      {
        a = LieSumAddition(a, bf);
        LieSumKillParametric(rhs);
      }
      goto out;
    }
    if(IsMonomialInMonomial(lmon, monb))
    {
      if(SubstitutionIsDone == NO)           /* First substituent term */
      {                                   /* Make right hand side of R */
        if((rhs = LieSumCopyParametric(LIE_TERM_R(r))) != NIL)
        {
          pb = LIE_TERM_NUMERATOR_SCALAR_SUM(r);
          if(SCALAR_SUM_IS_NOT_UNIT(pb))   /* Divide by leading coeff. */
            LieSumDivScalarSum(rhs, ScalarSumCopy(pb));
          LieSumMinusParametric(rhs);                      /* Negation */
        }
        SubstitutionIsDone = YES;
        a = NIL;
      }
      pb = LIE_TERM_NUMERATOR_SCALAR_SUM(b);
      if((r = SubstituteRHSInMonomialParametric(monb, lmon, rhs)) != NIL)
      {
        if(SCALAR_SUM_IS_NOT_UNIT(pb))
          LieSumMultScalarSum(r, pb);
        else
          ScalarSumKill(pb);
        a = LieSumAddition(a, r);
      }
      if(bl != NIL)
      {                   /* There is substitution-free sublist before */
        LIE_TERM_R(bl) = NIL;
        a = LieSumAddition(a, bf);
      }
      bl = b;
      bf = b = LIE_TERM_R(b);
      NODE_LT_KILL(bl);
      bl = NIL;
    }
    else
    {                                   /* Skip substitution-free term */
      bl = b;
      b = LIE_TERM_R(b);
    }
  }while(b != NIL);
  if(SubstitutionIsDone)
  {                                   /* Append substitution-free tail */
    if(bl != NIL)
      a = LieSumAddition(a, bf);
    LieSumKillParametric(rhs);
  }
  out:
OUT_SUBSTITUTE_RELATION_IN_RELATION /*---------------------------------*/
  return a;
}
/*=SubstituteRHSInMonomialInteger=======================================
 Insert right hand side `r' of relation with leading monomial `lmonr'
 in monomial `mon'.
 Returned NOTHING means "no substitution", NIL means 0.
 Function saves input `r'. Integer regime.
*/
U SubstituteRHSInMonomialInteger(I mon, I lmonr, U r)
{
  /* Single monomial matching case */

  if(mon == lmonr)
    return LieSumCopyInteger(r);

  /* Possible substitution(s) in submonomial(s) */

  if(LIE_MONOMIAL_ORDER(mon) > LIE_MONOMIAL_ORDER(lmonr)
     && LIE_MONOMIAL_IS_COMMUTATOR(mon))
  {
    U res;
    I monl = LIE_MONOMIAL_LEFT(mon);
    mon = LIE_MONOMIAL_RIGHT(mon);
    res = SubstituteRHSInMonomialInteger(monl, lmonr, r);
    if(res == NIL)
      return NIL;                                     /*  [0, x] -> 0 */
    {
      U resr = SubstituteRHSInMonomialInteger(mon, lmonr, r);
      if(res == NOTHING)
      {
        if(resr == NOTHING)
          return NOTHING;    /* No substitutions in both submonomials */
        if(resr == NIL)
          return NIL;                                  /* [x, 0] -> 0 */
        return PairMonomialSumInteger(monl, resr); /* -> [monl, resr] */
      }
      if(resr == NOTHING)
        return PairSumMonomialInteger(res, mon);     /* -> [res, mon] */
      if(resr == NIL)
      {
        LieSumKillInteger(res);
        return NIL;
      }
      return PairSumSumInteger(res, resr);          /* -> [res, resr] */
    }
  }
  return NOTHING;
}
/*=SubstituteRHSInMonomialParametric======================================
 Insert right hand side `r' of relation with leading monomial `lmonr'
 in monomial `mon'.
 Returned NOTHING means "no substitution", NIL means 0.
 Function saves input `r'. Parametric regime.
*/
U SubstituteRHSInMonomialParametric(I mon, I lmonr, U r)
{
  /* Single monomial matching case */

  if(mon == lmonr)
    return LieSumCopyParametric(r);

  /* Possible substitution(s) in submonomial(s) */

  if(LIE_MONOMIAL_ORDER(mon) > LIE_MONOMIAL_ORDER(lmonr)
     && LIE_MONOMIAL_IS_COMMUTATOR(mon))
  {
    U res;
    I monl = LIE_MONOMIAL_LEFT(mon);
    mon = LIE_MONOMIAL_RIGHT(mon);
    res = SubstituteRHSInMonomialParametric(monl, lmonr, r);
    if(res == NIL)
      return NIL;                                        /*  [0, x] -> 0 */
    {
      U resr = SubstituteRHSInMonomialParametric(mon, lmonr, r);
      if(res == NOTHING)
      {
        if(resr == NOTHING)
          return NOTHING;       /* No substitutions in both submonomials */
        if(resr == NIL)
          return NIL;                                     /* [x, 0] -> 0 */
        return PairMonomialSumParametric(monl, resr); /* -> [monl, resr] */
      }
      if(resr == NOTHING)
        return PairSumMonomialParametric(res, mon);     /* -> [res, mon] */
      if(resr == NIL)
      {
        LieSumKillParametric(res);
        return NIL;
      }
      return PairSumSumParametric(res, resr);          /* -> [res, resr] */
    }
  }
  return NOTHING;
}

/*_6_3		Lie and scalar algebra functions========================*/

/*=LieLikeTermsCollectionInteger==========================================
 For Lie terms `a' and `b' sum rational integers  `na/da' and `nb/db'
 destructing input terms, set nonzero result in `a', return YES for
 nonzero result, otherwise kill `a' and return NO;
 `da', `db'= NIL means 1.
*/
I LieLikeTermsCollectionInteger(U a, U b)
{
  INT na, da, nb, db;
  nb = LIE_TERM_NUMERATOR_INTEGER(b);
  db = LIE_TERM_DENOMINATOR_INTEGER(b);
  NODE_LT_KILL(b);
  na = LIE_TERM_NUMERATOR_INTEGER(a);
  da = LIE_TERM_DENOMINATOR_INTEGER(a);
  if(da != NULL) if(db != NULL)                 /* `da' != 1, `db' != 1 */
  {
    INT g, h;
    I i;
    INTEGER_STACK_COPY(g, da, i);
    INTEGER_STACK_COPY(h, db, i);
    if((g = IntegerGCD(g, h)) != NULL)           /* g = GCD(da, db) > 1 */
    {
      INT k, m, daa;
      INTEGER_STACK_COPY(k, g, i);                 /*  k = GCD(da, db)' */
      INTEGER_STACK_NEW(m, 2+INTEGER_N_LIMBS(da)-INTEGER_N_LIMBS(k));
      INTEGER_STACK_COPY_1(daa, da, i);
      INTEGER_KILL(da);
      IntegerQuotient(m, daa, k);               /*  m = da/GCD(da, db)' */
      INTEGER_STACK_NEW(h, 1+INTEGER_N_LIMBS(nb)+INTEGER_N_LIMBS(m));
      IntegerProduct(h, nb, m);             /*  h = nb*da'/GCD(da, db)' */
      INTEGER_KILL(nb);
      INTEGER_STACK_COPY_1(k, db, i);                       /*  k = db' */
      INTEGER_STACK_COPY(da, g, i);                /* da = GCD(da, db)' */
      INTEGER_STACK_NEW(nb, 2+INTEGER_N_LIMBS(k)-INTEGER_N_LIMBS(da));
      IntegerQuotient(nb, k, da);              /* nb = db'/GCD(da, db)' */
      INTEGER_STACK_NEW(k, 1+INTEGER_N_LIMBS(na)+INTEGER_N_LIMBS(nb));
      IntegerProduct(k, na, nb);            /*  k = na*db'/GCD(da, db)' */
      INTEGER_KILL(na);
      INTEGER_STACK_NEW(na, 3+MAX(INTEGER_N_LIMBS(h),INTEGER_N_LIMBS(k)));
      IntegerSum(na, h, k);                               /* na = h + k */
      if(INTEGER_N_LIMBS(na) != 0)
      {
        INTEGER_STACK_COPY(h, na, i);                      /* Numerator */
        if((h = IntegerGCD(h, g)) != NULL)
        {
          INTEGER_STACK_COPY(g, h, i);
          INTEGER_HEAP_NEW(k, 2+INTEGER_N_LIMBS(na)-INTEGER_N_LIMBS(g));
          IntegerQuotient(k, na, g);
          LIE_TERM_NUMERATOR_INTEGER(a) = k;
          INTEGER_STACK_NEW(k, 2+INTEGER_N_LIMBS(db)-INTEGER_N_LIMBS(h));
          INTEGER_STACK_COPY_1(daa, db, i);
          INTEGER_KILL(db);
          IntegerQuotient(k, daa, h);
          INTEGER_HEAP_NEW(db, 1+INTEGER_N_LIMBS(m)+INTEGER_N_LIMBS(k));
          IntegerProduct(db, m, k);
          if(INTEGER_IS_UNIT(db))
          {
            INTEGER_KILL(db);
            db = NULL;     /* Standard convention for unit denominators */
          }
          LIE_TERM_DENOMINATOR_INTEGER(a) = db;
        }
        else
        {
          INTEGER_HEAP_COPY(h, na, i);
          LIE_TERM_NUMERATOR_INTEGER(a) = h;
          INTEGER_HEAP_NEW(k, 1+INTEGER_N_LIMBS(m)+INTEGER_N_LIMBS(db));
          IntegerProduct(k, m, db);
          INTEGER_KILL(db);
          if(INTEGER_IS_UNIT(k))
          {
            INTEGER_KILL(k);
            k = NULL;      /* Standard convention for unit denominators */
          }
          LIE_TERM_DENOMINATOR_INTEGER(a) = k;
        }
        goto non_zero;
      }
      else
      {
        INTEGER_KILL(db);
        goto zero;
      }
    }
    else                                       /* Mutually prime da, db */
    {
      INTEGER_STACK_NEW(g, 1+INTEGER_N_LIMBS(nb)+INTEGER_N_LIMBS(da));
      IntegerProduct(g, nb, da);                           /* g = nb*da */
      INTEGER_KILL(nb);
      INTEGER_STACK_NEW(nb, 1+INTEGER_N_LIMBS(na)+INTEGER_N_LIMBS(db));
      IntegerProduct(nb, na, db);                         /* nb = na*db */
      INTEGER_KILL(na);
      INTEGER_HEAP_NEW(na, 2+MAX(INTEGER_N_LIMBS(nb),INTEGER_N_LIMBS(g)));
      IntegerSum(na, nb, g);                      /* na = nb*da + na*db */
      if(INTEGER_N_LIMBS(na) != 0)
      {
        LIE_TERM_NUMERATOR_INTEGER(a) = na;
        INTEGER_HEAP_NEW(nb, 1+INTEGER_N_LIMBS(da)+INTEGER_N_LIMBS(db));
        IntegerProduct(nb, da, db);                       /* nb = da*db */
        LIE_TERM_DENOMINATOR_INTEGER(a) = nb;
        INTEGER_KILL(da);
        INTEGER_KILL(db);
        goto non_zero;
      }
      else
      {
        INTEGER_KILL(na);
        INTEGER_KILL(da);
        INTEGER_KILL(db);
        goto zero;
      }
    }
  }
  else                                           /* `da' != 1, `db' = 1 */
  {
    INTEGER_STACK_NEW(db, 1+INTEGER_N_LIMBS(nb)+INTEGER_N_LIMBS(da));
    IntegerProduct(db, nb, da);
    INTEGER_KILL(nb);
    INTEGER_HEAP_NEW(nb, 2+MAX(INTEGER_N_LIMBS(db),INTEGER_N_LIMBS(na)));
    IntegerSum(nb, db, na);
    INTEGER_KILL(na);
    LIE_TERM_NUMERATOR_INTEGER(a) = nb;
    goto non_zero;
  }
  else if(db != NULL)                            /* `da' = 1, `db' != 1 */
  {
    INTEGER_STACK_NEW(da, 1+INTEGER_N_LIMBS(na)+INTEGER_N_LIMBS(db));
    IntegerProduct(da, na, db);
    INTEGER_KILL(na);
    INTEGER_HEAP_NEW(na, 2+MAX(INTEGER_N_LIMBS(da),INTEGER_N_LIMBS(nb)));
    IntegerSum(na, da, nb);
    INTEGER_KILL(nb);
    LIE_TERM_NUMERATOR_INTEGER(a) = na;
    LIE_TERM_DENOMINATOR_INTEGER(a) = db;
    goto non_zero;
  }
  else                                               /* `da' = `db' = 1 */
  {
    INTEGER_HEAP_NEW(da, 2+MAX(INTEGER_N_LIMBS(na),INTEGER_N_LIMBS(nb)));
    IntegerSum(da, na, nb);
    INTEGER_KILL(na);
    INTEGER_KILL(nb);
    if(INTEGER_N_LIMBS(da) != 0)
    {
      LIE_TERM_NUMERATOR_INTEGER(a) = da;
      goto non_zero;
    }
    else
    {
      INTEGER_KILL(da);
      goto zero;
    }
  }
  non_zero:
  return YES;
  zero:
  NODE_LT_KILL(a);                                   /* `na' + `nb' = 0 */
  return NO;
}
/*=LieLikeTermsCollectionParametric=======================================
 For Lie terms `a' and `b' sum rational functions  `na/da' and `nb/db'
 destructing input terms, set nonzero result in `a', return YES for
 nonzero result, otherwise kill `a' and return NO;
 `da', `db'= NIL means 1.
*/
I LieLikeTermsCollectionParametric(U a, U b)
{
  U na, da, nb, db;
  nb = LIE_TERM_NUMERATOR_SCALAR_SUM(b);
  db = LIE_TERM_DENOMINATOR_SCALAR_SUM(b);
  NODE_LT_KILL(b);
  na = LIE_TERM_NUMERATOR_SCALAR_SUM(a);
  da = LIE_TERM_DENOMINATOR_SCALAR_SUM(a);
  if(da != NIL) if(db != NIL)                /* `da' != 1 and `db' != 1 */
  {
    U g;
    if((g = PolyGCD(da, db)) != NIL)            /* g = GCD(da, db) != 1 */
    {
      da = PolyQuotient(da, g);                /*  da' = da/GCD(da, db) */
                                                       /*  nb' = nb*da' */
      nb = ScalarSumMultiplication(nb, ScalarSumCopy(da));
                                            /*  na' = na*db/GCD(da, db) */
      na = ScalarSumMultiplication(na, PolyQuotient(ScalarSumCopy(db), g));
      na = ScalarSumAddition(na, nb);               /* na'' = na' + nb' */
      if(na != NIL)
      {
        if((nb = PolyGCD(na, g)) != NIL)
        {                                      /* Set na''/GCD(na'', g) */
          LIE_TERM_NUMERATOR_SCALAR_SUM(a) = PolyQuotient(na, nb);
          db = PolyQuotient(db, nb);           /* db' = db/GCD(na'', g) */
          ScalarSumKill(nb);                       /* Kill GCD(na'', g) */
        }
        else
          LIE_TERM_NUMERATOR_SCALAR_SUM(a) = na;
        ScalarSumKill(g);                           /* Kill GCD(da, db) */
        da = ScalarSumMultiplication(da, db);
        if(SCALAR_SUM_IS_UNIT(da))
        {
          ScalarSumKill(da);
          da = NIL;
        }
        LIE_TERM_DENOMINATOR_SCALAR_SUM(a) = da;
        goto non_zero;
      }
      ScalarSumKill(g);             /* Nontrivial g at na == NIL branch */
    }
    else                                       /* Mutually prime da, db */
    {                                          /* na' = na*db' + nb*da' */
      na = ScalarSumAddition(ScalarSumMultiplication(na, ScalarSumCopy(db)),
                             ScalarSumMultiplication(nb, ScalarSumCopy(da)));
      if(na != NIL)
      {
        LIE_TERM_NUMERATOR_SCALAR_SUM(a) = na;
        LIE_TERM_DENOMINATOR_SCALAR_SUM(a) = ScalarSumMultiplication(da, db);
        goto non_zero;
      }
    }
    ScalarSumKill(da);                              /* na == NIL branch */
    ScalarSumKill(db);
    goto zero;
  }
  else                   /* `da' != 1 and `db' = 1 --> (na + nb*da')/da */
  {
    LIE_TERM_NUMERATOR_SCALAR_SUM(a) =
      ScalarSumAddition(na, ScalarSumMultiplication(nb, ScalarSumCopy(da)));
    goto non_zero;
  }
  else if(db != NIL)     /* `da' = 1 and `db' != 1 --> (nb + na*db')/db */
  {
    LIE_TERM_NUMERATOR_SCALAR_SUM(a) =
      ScalarSumAddition(nb, ScalarSumMultiplication(na, ScalarSumCopy(db)));
    LIE_TERM_DENOMINATOR_SCALAR_SUM(a) = db;
    goto non_zero;
  }
  else if((na = ScalarSumAddition(na, nb)) != NIL)
  {                           /* `da' = `db' = 1 --> (na + nb)/1 (!= 0) */
    LIE_TERM_NUMERATOR_SCALAR_SUM(a) = na;
    goto non_zero;
  }
  zero:
  NODE_LT_KILL(a);  /* `na' + `nb' = 0 */
  return NO;
  non_zero:
  return YES;
}
/*=LieSumAddition=============================================
 Sum of two Lie expressions
*/
U LieSumAddition(U a, U b)
{
  U sum = NIL, last, wa, wb;
IN_LIE_SUM_ADDITION /*---------------------------------------*/
  while(YES)
  {
    next_pair:
    if(b == NIL)
    {                   /* List b is ended, append rest of a */
      if(sum == NIL)
        sum = a;
      else
        LIE_TERM_R(last) = a;
      break;
    }
    if(a == NIL)
    {                   /* List a is ended, append rest of b */
      if(sum == NIL)
        sum = b;
      else
        LIE_TERM_R(last) = b;
      break;
    }

    /* Compare algebra terms */

    if(LIE_TERM_MONOMIAL_ORDER(a) > LIE_TERM_MONOMIAL_ORDER(b))
      goto order_12;
    if(LIE_TERM_MONOMIAL_ORDER(a) < LIE_TERM_MONOMIAL_ORDER(b))
      goto order_21;

    /* Reduce like algebra terms */

    wa = a;
    wb = b;
    a = LIE_TERM_R(a);
    b = LIE_TERM_R(b);

        /* Sum rational coefficients */

    if((*LieLikeTermsCollection)(wa, wb))
      goto append_term;
    else
      goto next_pair;

    order_12:
    wa = a;
    a = LIE_TERM_R(a);
    goto append_term;

    order_21:
    wa = b;
    b = LIE_TERM_R(b);

    append_term:
    if(sum == NIL)
      sum = wa;
    else
      LIE_TERM_R(last) = wa;
    last = wa;
  }
OUT_LIE_SUM_ADDITION /*--------------------------------------*/
  return sum;
}
/*=LieSumDivInteger=======================================================
 Divide Lie sum by integer (of unknown nature) on spot in Integer regime
 Integer `den' is spoiled
*/
V LieSumDivInteger(U lsum, INT den)
{
  if(lsum != NIL)
  {
    INT d, da, dao;
    I i, n;
    U a;
IN_LIE_SUM_DIV_INTEGER  /*----------------------------------------------*/
    n = INTEGER_N_LIMBS(den);
    INTEGER_STACK_NEW(d, 1+n);          /* Space for copies input `den' */
    do
    {
      a = lsum;
      lsum = LIE_TERM_R(lsum);
      if(lsum != NIL)
      {
        i = n;
        do
          d[i] = den[i];
        while(i--);
      }
      else
        d = den;
      IntegerCancellation(LIE_TERM_NUMERATOR_INTEGER(a), d);
      if(INTEGER_IS_NOT_UNIT(d))
      {
        if((dao = LIE_TERM_DENOMINATOR_INTEGER(a)) != NULL)
        {                           /* Nontrivial old denominator `dao' */
          INTEGER_HEAP_NEW(da, 1+INTEGER_N_LIMBS(d)+INTEGER_N_LIMBS(dao));
          IntegerProduct(da, d, dao);
          INTEGER_KILL(dao);
        }
        else
        {
          INTEGER_HEAP_COPY(da, d, i); /* Composite statement */
        }
        LIE_TERM_DENOMINATOR_INTEGER(a) = da;
      }
    }while(lsum != NIL);
OUT_LIE_SUM_DIV_INTEGER  /*---------------------------------------------*/
  }
}
/*=LieSumDivScalarSum======================================
 Divide Lie sum by scalar sum on spot in Parametric regime
 `den' is killed
*/
V LieSumDivScalarSum(U lsum, U den)
{
  if(lsum == NIL)
    ScalarSumKill(den);
  else
  {
    U n, d, a;
IN_LIE_SUM_DIV_SCALAR_SUM /*-----------------------------*/
    do
    {
      a = lsum;
      lsum = LIE_TERM_R(lsum);
      d = (lsum != NIL) ? ScalarSumCopy(den) : den;
      n = LIE_TERM_NUMERATOR_SCALAR_SUM(a);
      ScalarSumCancellation(&n, &d);
      LIE_TERM_NUMERATOR_SCALAR_SUM(a) = n;
      if(SCALAR_SUM_IS_NOT_UNIT(d))
      {
        if((n = LIE_TERM_DENOMINATOR_SCALAR_SUM(a)) != NIL)
          d = ScalarSumMultiplication(d, n);   /* Absorb */
        LIE_TERM_DENOMINATOR_SCALAR_SUM(a) = d;
      }
      else
        ScalarSumKill(d);                   /* Kill unit */
    }while(lsum != NIL);
OUT_LIE_SUM_DIV_SCALAR_SUM /*----------------------------*/
  }
}
/*=LieSumMinusInteger====================
 Change signs in Lie sum (Integer regime)
*/
V LieSumMinusInteger(U a)
{
  while(a != NIL)
  {
    LIE_TERM_MINUS_INTEGER(a);
    a = LIE_TERM_R(a);
  }
}

/*=LieSumMinusParametric====================
 Change signs in Lie sum (Parametric regime)
*/
V LieSumMinusParametric(U a)
{
  U b;
  while(a != NIL)
  {
    b = LIE_TERM_NUMERATOR_SCALAR_SUM(a);
    do
      SCALAR_TERM_MINUS(b);
    while((b = SCALAR_TERM_R(b)) != NIL);
    a = LIE_TERM_R(a);
  }
}
/*=LieSumMultInteger=======================================================
 Multiply Lie sum by integer (of unknown nature) on spot in Integer regime
 Integer `num' is spoiled
*/
V LieSumMultInteger(U lsum, INT num)
{
  if(lsum != NIL)
  {
    INT nw, nao, da;
    I i, n;
    U a;
IN_LIE_SUM_MULT_INTEGER  /*----------------------------------------------*/
    n = INTEGER_N_LIMBS(num);
    INTEGER_STACK_NEW(nw, 1+n);       /* Space for copies of input `num' */
    do
    {
      a = lsum;
      lsum = LIE_TERM_R(lsum);
      nao = LIE_TERM_NUMERATOR_INTEGER(a);        /* Old numerator `nao' */
      if((da = LIE_TERM_DENOMINATOR_INTEGER(a)) != NULL)
      {                                   /* Nontrivial denominator `da' */
        if(lsum != NIL)
        {                                            /* Copy if not last */
          i = n;
          do
            nw[i] = num[i];
          while(i--);
        }
        else
          nw = num;
        IntegerCancellation(nw, da);
        if(INTEGER_IS_UNIT(da))
        {                                 /* Trivialize unit denominator */
          INTEGER_KILL(da);
          LIE_TERM_DENOMINATOR_INTEGER(a) = NULL;
        }
        if(INTEGER_IS_NOT_UNIT(nw))
        {
          INTEGER_HEAP_NEW(da, 1+INTEGER_N_LIMBS(nw)+INTEGER_N_LIMBS(nao));
          IntegerProduct(da, nw, nao);
          goto stick_new;
        }
      }
      else
      {
        INTEGER_HEAP_NEW(da, 1+INTEGER_N_LIMBS(num)+INTEGER_N_LIMBS(nao));
        IntegerProduct(da, num, nao);
        stick_new:
        INTEGER_KILL(nao);      
        LIE_TERM_NUMERATOR_INTEGER(a) = da;
      }
    }while(lsum != NIL);
OUT_LIE_SUM_MULT_INTEGER /*----------------------------------------------*/
  }
}
#if defined(RATIONAL_FIELD)
/*=LieSumMultRationalInteger=============================================
 num and den are non-NULL integers of unknown nature
*/
V LieSumMultRationalInteger(I a, INT num, INT den)
{
  INT  numc, denc, numa, dena, w;
  I i, nn = INTEGER_N_LIMBS(num), nd = INTEGER_N_LIMBS(den);
  INTEGER_STACK_NEW(numc, 1+nn);
  INTEGER_STACK_NEW(denc, 1+nd);
  while(a != NIL)
  {
    for(i = 0; i <= nn; i++)                   /* Copy input numerator */
      numc[i] = num[i];
    if((dena = LIE_TERM_DENOMINATOR_INTEGER(a)) != NULL)
    {                                                         /* n1/d2 */
      IntegerCancellation(numc, dena);
      if(INTEGER_IS_UNIT(dena))
      {
        INTEGER_KILL(dena);
        dena = NULL;
      }
    }
    numa = LIE_TERM_NUMERATOR_INTEGER(a);
    for(i = 0; i <= nd; i++)               /* Copy input denominator */
      denc[i] = den[i];
    IntegerCancellation(numa, denc);                        /* n2/d1 */
    INTEGER_HEAP_NEW(w, 1+INTEGER_N_LIMBS(numc)+INTEGER_N_LIMBS(numa));
    IntegerProduct(w, numc, numa);                            /* n1*n2 */
    INTEGER_KILL(numa);
    LIE_TERM_NUMERATOR_INTEGER(a) = w;
    if(INTEGER_IS_UNIT(denc))
       if(dena == NULL)
         w = NULL;                                              /* 1*1 */
       else
       {                            /* Copy to avoid garbage tail in w */
         INTEGER_HEAP_COPY(w, dena, i);                        /* 1*d2 */
         INTEGER_KILL(dena);
       }
    else if(dena == NULL)
    {
      INTEGER_HEAP_COPY(w, denc, i);                           /* d1*1 */
    }
    else
    {
      INTEGER_HEAP_NEW(w, 1+INTEGER_N_LIMBS(denc)+INTEGER_N_LIMBS(dena));
      IntegerProduct(w, denc, dena);                          /* d1*d2 */
      INTEGER_KILL(dena);
    }
    LIE_TERM_DENOMINATOR_INTEGER(a) = w;
    a = LIE_TERM_R(a);
  }
}
#endif
/*=LieSumMultScalarSum===============================================
 Multiply Lie sum by scalar sum on spot in Parametric regime
 `num' is killed
*/
V LieSumMultScalarSum(U lsum, U num)
{
  if(lsum == NIL)
    ScalarSumKill(num);
  else
  {
    U n, d, a;
IN_LIE_SUM_MULT_SCALAR_SUM /*--------------------------------------*/
    do
    {
      a = lsum;
      lsum = LIE_TERM_R(lsum);
      n = (lsum != NIL) ? ScalarSumCopy(num) : num;
      if((d = LIE_TERM_DENOMINATOR_SCALAR_SUM(a)) != NIL)
      {
        ScalarSumCancellation(&n, &d);
        if(SCALAR_SUM_IS_UNIT(d))
        {
          ScalarSumKill(d);                           /* Kill unit */
          d = NIL;
        }
        LIE_TERM_DENOMINATOR_SCALAR_SUM(a) = d;
      }
      LIE_TERM_NUMERATOR_SCALAR_SUM(a) =
        ScalarSumMultiplication(LIE_TERM_NUMERATOR_SCALAR_SUM(a), n);
    }while(lsum != NIL);
OUT_LIE_SUM_MULT_SCALAR_SUM /*-------------------------------------*/
  }
}
/*=NormalizeRelationInteger================================================
 Normalize sign, remove GCD of integer numerators,
 remove denominators for non-NIL relation
*/
V NormalizeRelationInteger(U a)
{
  U b;
  INT n2, n1 = LIE_TERM_NUMERATOR_INTEGER(a);
IN_NORMALIZE_RELATION   /*-----------------------------------------------*/
  /* Normalize sign */

  if(INTEGER_IS_NEGATIVE(n1))
  {
    INTEGER_SET_PLUS(n1);
    b = LIE_TERM_R(a);
    while(b != NIL)
    {
      INTEGER_MINUS(LIE_TERM_NUMERATOR_INTEGER(b));
      b = LIE_TERM_R(b);
    }
  }
#if defined(RATIONAL_FIELD)         /* Field R case compiling */
  n2 = LIE_TERM_DENOMINATOR_INTEGER(a);
  if(INTEGER_IS_UNIT(n1))  /* Either 1 (nothing to do or 1/n2 */
  {
    if(n2 != NULL)        /* Leading coefficient in form 1/n2 */
    {
      LIE_TERM_DENOMINATOR_INTEGER(a) = NULL;
      LieSumMultInteger(LIE_TERM_R(a), n2);
      INTEGER_KILL(n2);              /* Free spoiled array n2 */
    }
  }
  else           /* Leading coefficient is either n1 or n1/n2 */
  {
    if(n2 != NULL)
    {
      LIE_TERM_DENOMINATOR_INTEGER(a) = NULL;
      LieSumMultRationalInteger(LIE_TERM_R(a), n2, n1);
      INTEGER_KILL(n2);              /* Free spoiled array n2 */
    }
    else                    /* Leading coefficient in form n1 */
      LieSumDivInteger(LIE_TERM_R(a), n1);
    n1[0] = n1[1] = 1;    /* Set big number unit in old array */
  }
#else                                /* Ring Z case compiling */
  {
    INT gcd;
    I i;

    /* Remove GCD of numerators */

    if(INTEGER_IS_UNIT(n1))
      goto kill_denominators;
    INTEGER_STACK_COPY(gcd, n1, i);
    b = LIE_TERM_R(a);
    while(b != NIL)
    {
      n1 = LIE_TERM_NUMERATOR_INTEGER(b);
      if(INTEGER_IS_UNIT_ABS(n1))
        goto kill_denominators;
      INTEGER_HEAP_COPY(n2, n1, i);                /* Working heap integer */
      gcd = IntegerGCD(gcd, n2);
      INTEGER_KILL(n2);                               /* Free heap integer */
      if(gcd == NULL)
        goto kill_denominators;
      b = LIE_TERM_R(b);
    }
    LieSumDivInteger(a, gcd);

    /* Remove denominators */

    kill_denominators:
    b = a;
    do
      if(LIE_TERM_DENOMINATOR_INTEGER(b) != NULL)
      {
        INT n3, n4, lcm;

        /* Make first LCM */

        n1 = LIE_TERM_DENOMINATOR_INTEGER(b);
        INTEGER_HEAP_COPY(lcm, n1, i);
        while((b = LIE_TERM_R(b)) != NIL)
          if((n1 = LIE_TERM_DENOMINATOR_INTEGER(b)) != NULL)
          {
            /* Make copy of previous LCM */

            INTEGER_HEAP_COPY(n3, lcm, i);

            /* Make 2 copies of current denominator */

            INTEGER_HEAP_COPY_DOUBLE_1(n2, n4, n1, i);

            /* GCD of LCM and current denominator (stored in `n3') */

            gcd = IntegerGCD(n3, n4);
            INTEGER_KILL(n4);

            /* Divide current denominator by GCD */

            if(gcd != NULL)
            {
              INTEGER_HEAP_NEW(n1, 2+INTEGER_N_LIMBS(n2)-INTEGER_N_LIMBS(gcd));
              IntegerQuotient(n1, n2, gcd);
              INTEGER_KILL(n2);
            }
            else
              n1 = n2;
            INTEGER_KILL(n3);

            /* New LCM */

            n2 = lcm;
            INTEGER_HEAP_NEW(lcm, 1+INTEGER_N_LIMBS(n1)+INTEGER_N_LIMBS(n2));
            IntegerProduct(lcm, n1, n2);
            INTEGER_KILL(n2);
            INTEGER_KILL(n1);
          }

        /* Kill denominators */

        LieSumMultInteger(a, lcm);
        INTEGER_KILL(lcm);
        break;
      }
    while((b = LIE_TERM_R(b)) != NIL);
  }
#endif
OUT_NORMALIZE_RELATION   /*----------------------------------------------*/
}
/*=NormalizeRelationParametric===========================================
 Normalize sign, remove GCD of polynomial numerators, remove denominators
 for non-NIL relation, set in table common factor and leading coefficient
*/
V NormalizeRelationParametric(U a)
{
  U b, c = LIE_TERM_NUMERATOR_SCALAR_SUM(a), d, e;
IN_NORMALIZE_RELATION   /*---------------------------------------------*/

  /* Normalize sign */

  if(INTEGER_IS_NEGATIVE(SCALAR_TERM_NUMERATOR(c)))
    LieSumMinusParametric(a);

  /* Remove GCD of numerators */

  if(SCALAR_SUM_IS_UNIT(c))
    goto kill_denominators;
  b = LIE_TERM_R(a);
  c = ScalarSumCopy(c);
  while(b != NIL)
  {
    d = LIE_TERM_NUMERATOR_SCALAR_SUM(b);
    if(SCALAR_SUM_IS_UNIT_ABS(d))
    {
      ScalarSumKill(c);
      goto kill_denominators;
    }
    e = c;
    c = PolyGCD(e, d);
    ScalarSumKill(e);                     /* Kill old GCD */
    if(c == NIL)
      goto kill_denominators;
    b = LIE_TERM_R(b);
  }
  if(NonZeroCoefficientsPut)
    InCoeffTable(ScalarSumCopy(c));
  LieSumDivScalarSum(a, c);

  /* Remove denominators */

  kill_denominators:
  b = a;
  do
    if(LIE_TERM_DENOMINATOR_SCALAR_SUM(b) != NIL)
    {

      /* Make first LCM */

      c = ScalarSumCopy(LIE_TERM_DENOMINATOR_SCALAR_SUM(b));
      while((b = LIE_TERM_R(b)) != NIL)
        if((d = LIE_TERM_DENOMINATOR_SCALAR_SUM(b)) != NIL)
        {
          /* GCD of LCM and current denominator */

          e = PolyGCD(c, d);

          /* Divide current denominator by GCD */

          d = ScalarSumCopy(d);
          if(e != NIL)
          {
            d = PolyQuotient(d, e);
            ScalarSumKill(e);
          }

          /* New LCM */

          c = ScalarSumMultiplication(c, d);
        }

      /* Kill denominators */

      LieSumMultScalarSum(a, c);
      if(NonZeroCoefficientsPut)
        InCoeffTable(ScalarSumCopy(LIE_TERM_NUMERATOR_SCALAR_SUM(a)));
      break;
    }
  while((b = LIE_TERM_R(b)) != NIL);
OUT_NORMALIZE_RELATION   /*--------------------------------------------*/
}
/*=ScalarMonomialMultiplication============================================
*/
U ScalarMonomialMultiplication(I *pchange_sign, U ma, U mb)
{
  U mc, wa, wb, last;
  *pchange_sign = NO;
  mc = NIL;
  while(YES)
  {
    next_pair:
    if(mb == NIL)
    {                             /* List mb is ended, append rest of ma */
      if(mc == NIL)
        mc = ma;
      else
        SCALAR_FACTOR_R(last) = ma;
      break;
    }
    if(ma == NIL)
    {                             /* List ma is ended, append rest of mb */
      if(mc == NIL)
        mc = mb;
      else
        SCALAR_FACTOR_R(last) = mb;
      break;
    }

    /* Compare scalar factors */

    if(SCALAR_FACTOR_PARAMETER(ma) > SCALAR_FACTOR_PARAMETER(mb))
      goto order_12;
    if(SCALAR_FACTOR_PARAMETER(ma) < SCALAR_FACTOR_PARAMETER(mb))
      goto order_21;

    /* Reduce like factors */

    wa = ma;
    wb = mb;
    ma = SCALAR_FACTOR_R(ma);
    mb = SCALAR_FACTOR_R(mb);
    if(SCALAR_FACTOR_IS_I_NUMBER(wa))       /* Imaginary unit i*i --> -1 */
    {
      NODE_SF_KILL(wa);
      NODE_SF_KILL(wb);
      if(*pchange_sign)
        *pchange_sign = NO;               /* Convey change of sign to up */
      else
        *pchange_sign = YES;
      goto next_pair;
    }
    SCALAR_FACTOR_DEGREE(wa) += SCALAR_FACTOR_DEGREE(wb); /* Sum degrees */
    NODE_SF_KILL(wb);
    goto append_term;

    order_12:
    wa = ma;
    ma = SCALAR_FACTOR_R(ma);
    goto append_term;

    order_21:
    wa = mb;
    mb = SCALAR_FACTOR_R(mb);

    append_term:
    if(mc == NIL)
      mc = wa;
    else
      SCALAR_FACTOR_R(last) = wa;
    last = wa;
  }
  return mc;
}
/*=ScalarSumAddition=====================================================
 Sum of two scalar (polynomial) expressions
*/
U ScalarSumAddition(U a, U b)
{
  U sum = NIL, last, wa, wb, ma, mb;
  INT na, nb, nc;
  while(YES)
  {
    next_pair:
    if(b == NIL)
    {                 /* List b is ended, append rest of a */
      if(sum == NIL)
        sum = a;
      else
        SCALAR_TERM_R(last) = a;
      break;
    }
    if(a == NIL)
    {                 /* List a is ended, append rest of b */
      if(sum == NIL)
        sum = b;
      else
        SCALAR_TERM_R(last) = b;
      break;
    }

    /* Compare scalar terms */

    ma = SCALAR_TERM_MONOMIAL(a);
    mb = SCALAR_TERM_MONOMIAL(b);
    while(YES)
    {
      if(ma == NIL)
      {
        if(mb != NIL)
          goto order_21;   /* a-monomial is contained in b-monomial */
        break;             /* a-monomial == b-monomial  */
      }                    /* (including both are NILs) */
      if(mb == NIL)
        goto order_12;     /* a-monomial contains b-monomial */
      if(SCALAR_FACTOR_WORD(ma) > SCALAR_FACTOR_WORD(mb))
        goto order_12;
      if(SCALAR_FACTOR_WORD(ma) < SCALAR_FACTOR_WORD(mb))
        goto order_21;
      ma = SCALAR_FACTOR_R(ma);  /* Skip equal factors in monomials */
      mb = SCALAR_FACTOR_R(mb);
    }

    /* Reduce like scalar terms */

    wa = a;
    wb = b;
    a = SCALAR_TERM_R(a);
    b = SCALAR_TERM_R(b);

        /* Sum integer coefficients */

    na = SCALAR_TERM_NUMERATOR(wa);
    nb = SCALAR_TERM_NUMERATOR(wb);
    INTEGER_HEAP_NEW(nc, 2+MAX(INTEGER_N_LIMBS(na),INTEGER_N_LIMBS(nb)));
    IntegerSum(nc, na, nb);
    INTEGER_KILL(na);
    INTEGER_KILL(nb);

        /* Kill head of wb and its monomial */

    mb = SCALAR_TERM_MONOMIAL(wb);
    NODE_ST_KILL(wb);
    while(mb != NIL)
    {
      ma = mb;
      mb = SCALAR_FACTOR_R(mb);
      NODE_SF_KILL(ma);
    }

        /* Nonzero collection */

    if(INTEGER_N_LIMBS(nc) != 0)
    {
      SCALAR_TERM_NUMERATOR(wa) = nc;
      goto append_term;
    }

        /* Zero collection: kill nc and wa */

    INTEGER_KILL(nc);
    ma = SCALAR_TERM_MONOMIAL(wa);
    NODE_ST_KILL(wa);
    while(ma != NIL)
    {
      mb = ma;
      ma = SCALAR_FACTOR_R(ma);
      NODE_SF_KILL(mb);
    }
    goto next_pair;

    order_12:
    wa = a;
    a = SCALAR_TERM_R(a);
    goto append_term;

    order_21:
    wa = b;
    b = SCALAR_TERM_R(b);

    append_term:
    if(sum == NIL)
      sum = wa;
    else
      SCALAR_TERM_R(last) = wa;
    last = wa;
  }
  return sum;
}
/*=ScalarSumCancellation===================
*/
V ScalarSumCancellation(U *pnum, U *pden)
{
  U g;
IN_SCALAR_SUM_CANCELLATION /*------------*/
  if((g = PolyGCD(*pnum, *pden)) != NIL)
  {
    *pnum = PolyQuotient(*pnum, g);
    *pden = PolyQuotient(*pden, g);
    ScalarSumKill(g);
  }
OUT_SCALAR_SUM_CANCELLATION /*-----------*/
}
/*=ScalarSumMinus===========================
 Change sign of scalar sum in Parametric regime
*/
V ScalarSumMinus(U a)
{
  while(a != NIL)
  {
    SCALAR_TERM_MINUS(a);
    a = SCALAR_TERM_R(a);
  }
}
/*=ScalarSumMultiplication===========================================
 Expanded product of two positive nonzero general scalar expressions,
 caller ensures A != NIL and B != NIL.
*/
U ScalarSumMultiplication(U a, U b)
{
  U s, aw, bcur, bw, ac, bc;
  s = NIL;
  while(a != NIL)
  {
    aw = a;
    a = SCALAR_TERM_R(a);
    bcur = b;
    while(bcur != NIL)
    {
      bw = bcur;
      bcur = SCALAR_TERM_R(bcur);
      if(a == NIL)
      {
        bc = bw;
        SCALAR_TERM_R(bc) = NIL;
      }
      else
        bc = ScalarTermCopy(bw);
      if(bcur == NIL)
      {
        ac = aw;
        SCALAR_TERM_R(ac) = NIL;
      }
      else
        ac = ScalarTermCopy(aw);
      ScalarTermMultiplication(ac, bc);
      s = ScalarSumAddition(s, ac);
    }
  }
  return s;
}
/*=ScalarTermMultiplication===============================================
 Product of two scalar terms on place of A, B deleted
*/
V ScalarTermMultiplication(U a, U b)
{
  INT na, nb, nc;
  U ma, mb, mc, last, aa;

  /* Multiply integer coefficients */

  na = SCALAR_TERM_NUMERATOR(a);
  nb = SCALAR_TERM_NUMERATOR(b);
  INTEGER_HEAP_NEW(nc, 1+INTEGER_N_LIMBS(na)+INTEGER_N_LIMBS(nb));
  IntegerProduct(nc, na, nb);
  INTEGER_KILL(na);
  INTEGER_KILL(nb);
  SCALAR_TERM_NUMERATOR(a) = nc;

  /* Multiply monomials */

  ma = SCALAR_TERM_MONOMIAL(a);
  mb = SCALAR_TERM_MONOMIAL(b);
  NODE_ST_KILL(b);
  mc = NIL;
  while(YES)
  {
    next_pair:
    if(mb == NIL)
    {                 /* List mb is ended, append rest of ma */
      if(mc == NIL)
        mc = ma;
      else
        SCALAR_FACTOR_R(last) = ma;
      break;
    }
    if(ma == NIL)
    {                 /* List ma is ended, append rest of mb */
      if(mc == NIL)
        mc = mb;
      else
        SCALAR_FACTOR_R(last) = mb;
      break;
    }

    /* Compare scalar factors */

    if(SCALAR_FACTOR_PARAMETER(ma) > SCALAR_FACTOR_PARAMETER(mb))
      goto order_12;
    if(SCALAR_FACTOR_PARAMETER(ma) < SCALAR_FACTOR_PARAMETER(mb))
      goto order_21;

    /* Reduce like factors */

    aa = ma;
    b = mb;                    /* U-U mixion */
    ma = SCALAR_FACTOR_R(ma);
    mb = SCALAR_FACTOR_R(mb);
    if(SCALAR_FACTOR_IS_I_NUMBER(aa)) /* Imaginary unit i*i --> -1 */
    {
      NODE_SF_KILL(aa);
      NODE_SF_KILL(b);
      INTEGER_MINUS(nc);
      goto next_pair;
    }
    SCALAR_FACTOR_DEGREE(aa) += SCALAR_FACTOR_DEGREE(b); /* Sum degrees */
    NODE_SF_KILL(b);
    goto append_term;

    order_12:
    aa = ma;
    ma = SCALAR_FACTOR_R(ma);
    goto append_term;

    order_21:
    aa = mb;
    mb = SCALAR_FACTOR_R(mb);

    append_term:
    if(mc == NIL)
      mc = aa;
    else
      SCALAR_FACTOR_R(last) = aa;
    last = aa;
  }
  SCALAR_TERM_MONOMIAL(a) = mc;
}

/*_6_4          Scalar polynomial algebraic functions===================*/

/*=ContentOfScalarSum=========================================
 Returns relative (or full if initial CONT == NIL) single term
 content of scalar sum. NIL corresponds to 1.
 CONT is destroyed, A remains.
*/
U ContentOfScalarSum(U cont, U a)
{
  if(cont == NIL)
  {
    cont = ScalarTermCopy(a);
    INTEGER_SET_PLUS(SCALAR_TERM_NUMERATOR(cont));
    if((a = SCALAR_TERM_R(a)) == NIL)
      goto out_cont;
  }
  while((cont = PolyTermGCD(cont, a)) != NIL
        && (a = SCALAR_TERM_R(a)) != NIL)
    ;
  out_cont:
  return cont;
}
/*=InCoeffParamTable===============================================
 Set in CoeffParamTable parameters of scalar term `cont' killing it
*/
V InCoeffParamTable(U cont)
{
  U a = SCALAR_TERM_MONOMIAL(cont);
  INTEGER_KILL(SCALAR_TERM_NUMERATOR(cont));
  NODE_ST_KILL(cont);

  if(a != NIL)
  {
    if(SCALAR_FACTOR_IS_I_NUMBER(a))
    {
      NODE_SF_KILL(a);
      return;
    }
    if(CoeffParamTable == NULL)
      CoeffParamTable = (I*)NewArray(ParameterN, sizeof(I),
                                             E_A_COEFF_PARA_TABLE);
    do
    {
      cont = a;
      a = SCALAR_FACTOR_R(a);
      CoeffParamTable[SCALAR_FACTOR_PARAMETER(cont)] = YES;
      NODE_SF_KILL(cont);
    }while(a != NIL);
  }
}
/*=InCoeffSumTable========================================================
 Insert parametric content-free SUM in table or delete if already exists
*/
V InCoeffSumTable(U sum)
{
  if(SCALAR_FACTOR_IS_I_NUMBER(SCALAR_TERM_MONOMIAL(sum)))
    ScalarSumKill(sum);                  /* Kill complex number a*i + b */
  else
  {
    I i;
    U gcd, quocoe, quosum;
    for(i = 0; i < CoeffSumTableN; i++)
      if(PolynomialsAreEqual(sum, CoeffSumTable[i]))
      {
        ScalarSumKill(sum);
        return;
      }
      else
      {
        gcd = PolyGCD(sum, CoeffSumTable[i]);
        if(gcd != NIL)
        {
          quocoe = PolyQuotient(CoeffSumTable[i], gcd);
          quosum = PolyQuotient(sum, gcd);
          --CoeffSumTableN; /* Remove gap in ith position */
          while(i < CoeffSumTableN)
          {
            CoeffSumTable[i] = CoeffSumTable[i+1];
            ++i;
          }
          InCoeffSumTable(gcd);
          if(SCALAR_TERM_R(quocoe) == NIL) /* Either sum or 1 certainly */
          {
            INTEGER_KILL(SCALAR_TERM_NUMERATOR(quocoe));      /* Kill 1 */
            NODE_ST_KILL(quocoe);
          }
          else
            InCoeffSumTable(quocoe);
          if(SCALAR_TERM_R(quosum) == NIL) /* Either sum or 1 certainly */
          {
            INTEGER_KILL(SCALAR_TERM_NUMERATOR(quosum));      /* Kill 1 */
            NODE_ST_KILL(quosum);
          }
          else
            InCoeffSumTable(quosum);
          return;
        }
      }
    if(CoeffSumTableN >= CoeffSumTableSize)
      Error(E_COEFF_SUM_TABLE_SIZE);
    if(CoeffSumTable == NULL)
      CoeffSumTable = (U *)NewArray(CoeffSumTableSize, sizeof(U),
                                               E_A_COEFF_SUM_TABLE);
    CoeffSumTable[CoeffSumTableN++] = sum;
  }
}
/*=InCoeffTable===========================================
 Set in tables components of non-NIL parametric polynomial
*/
V InCoeffTable(U coe)
{
  if(SCALAR_TERM_R(coe) != NIL)
  {
    U cont;
    if((cont = ContentOfScalarSum(NIL, coe)) != NIL)
    {
      coe = PolyQuotient(coe, cont);
      InCoeffParamTable(cont);
    }
    InCoeffSumTable(coe);
  }
  else
    InCoeffParamTable(coe);
}
/*=PolyCoeffAtMainParameter===========================================
 Polynomial coefficient with normalized sign at the current degree of
 the main parameter. *PA initially points to the start of list, at the
 end of work it points to tail of list. NIL corresponds to 1.
 Initial polynomial remains.
*/
U PolyCoeffAtMainParameter(U *pa, I mp)
{
  U a;
  I isnegative = INTEGER_IS_NEGATIVE(SCALAR_TERM_NUMERATOR(*pa));
  if(POLY_MAIN_PARAMETER(*pa) < mp)
  {                                                    /* Free term */
    a = ScalarSumCopy(*pa);
    if(isnegative)                                /* Normalize sign */
    {
      *pa = a;
      do
        SCALAR_TERM_MINUS(*pa);
      while((*pa = SCALAR_TERM_R(*pa)) != NIL);
    }
    else
      *pa = NIL;
  }
  else
  {
    U b;
    U mf;
    I mppow = SCALAR_TERM_MAIN_DEGREE(*pa);
    a = b = ScalarTermCopy(*pa);
    if(isnegative)
      SCALAR_TERM_MINUS(a);
    mf = SCALAR_TERM_MONOMIAL(a);      /* Strike out main parameter */
    SCALAR_TERM_MONOMIAL(a) = SCALAR_FACTOR_R(mf);
    NODE_SF_KILL(mf);
    while((*pa = SCALAR_TERM_R(*pa)) != NIL
          && POLY_MAIN_PARAMETER(*pa) == mp
          && SCALAR_TERM_MAIN_DEGREE(*pa) == mppow)
    {
      SCALAR_TERM_R(b) = ScalarTermCopy(*pa);
      b = SCALAR_TERM_R(b);
      if(isnegative)
        SCALAR_TERM_MINUS(b);
      mf = SCALAR_TERM_MONOMIAL(b);    /* Strike out main parameter */
      SCALAR_TERM_MONOMIAL(b) = SCALAR_FACTOR_R(mf);
      NODE_SF_KILL(mf);
    }
  }
  if(SCALAR_SUM_IS_UNIT(a))
  {
    INTEGER_KILL(SCALAR_TERM_NUMERATOR(a));
    NODE_ST_KILL(a);
    a = NIL;
  }
  return a;
}
/*=PolyContent=============================================
 Polynomial content of polynomial w.r.t. main parameter MP.
 A remains unchanged.
*/
U PolyContent(U a, I mp)
{
  U b;
IN_POLY_CONTENT /*---------------------------------------*/
  if((b = PolyCoeffAtMainParameter(&a, mp)) != NIL)
  {
    U c, d;
    while(a != NIL)
    {
      if((c = PolyCoeffAtMainParameter(&a, mp)) == NIL)
      {
        ScalarSumKill(b);
        b = NIL;
        break;
      }
      d = b;
      if((b = PolyGCD(b, c)) == NIL)
      {
        ScalarSumKill(d);
        ScalarSumKill(c);
        break;
      }
    }
  }
OUT_POLY_CONTENT /*--------------------------------------*/
  return b;
}
/*=PolyGCD==============================================================
 Returns Greatest Common Divisor of two multivariate polynomials in
 the form GCD(PP(A), PP(B)) * GCD(CONT(A), CONT(B)).
 A, B unchanged.
 Returned NIL means trivial GCD = 1
*/
U PolyGCD(U a, U b)
{
  U c;
IN_POLY_GCD /*--------------------------------------------------------*/
  if(SCALAR_TERM_R(a) == NIL || SCALAR_TERM_R(b) == NIL)
  {	              /* At least one of the polynomials is not a sum */
    if(SCALAR_TERM_R(a) != NIL)
    {                                    /* Set A to be a single term */
      c = a;
      a = b;
      b = c;
    }
    c = ScalarSumCopy(a);
    INTEGER_SET_PLUS(SCALAR_TERM_NUMERATOR(c));
    b = ContentOfScalarSum(c, b);
  }
  else                                 /* Both are polynomials really */
  {
    U conta, contb;
    I mp, mpb;                                     /* Main parameters */
    mp = SCALAR_FACTOR_PARAMETER(SCALAR_TERM_MONOMIAL(a));
    mpb = SCALAR_FACTOR_PARAMETER(SCALAR_TERM_MONOMIAL(b));
    if(mpb > mp ||
       (mpb == mp &&
        SCALAR_TERM_MAIN_DEGREE(b) > SCALAR_TERM_MAIN_DEGREE(a)))
    {                           /* Parameters go in DECREASING order! */
      c = a;                                      /* Swap polynomials */
      a = b;
      b = c;
      mp = mpb;
    }
    a = ScalarSumCopy(a);
    b = ScalarSumCopy(b);
    contb = PolyContent(b, mp);
    if((conta = PolyContent(a, mp)) != NIL)
    {                     /* Make primitive parts and GCD of contents */
      if(contb != NIL)
      {
        c = PolyGCD(conta, contb);
        b = PolyQuotient(b, contb);                 /* Primitive part */
        ScalarSumKill(contb);
      }
      else
        c = NIL;
      a = PolyQuotient(a, conta);                   /* Primitive part */
      ScalarSumKill(conta);
    }
    else
    {
      if(contb != NIL)
      {
        b = PolyQuotient(b, contb);                 /* Primitive part */
        ScalarSumKill(contb);
      }
      c = NIL;
    }
    while((conta = PolyPseudoRemainder(a, ScalarSumCopy(b), mp)) != NIL)
    {
      if(SCALAR_TERM_MONOMIAL(conta) == NIL || /* Pure number */
         SCALAR_FACTOR_PARAMETER(SCALAR_TERM_MONOMIAL(conta)) != mp)
      {                 /* Zero degree with respect to main parameter */
        ScalarSumKill(b);
        ScalarSumKill(conta);
        b = c;          /* C is content ?? */
        goto out;
      }
      a = b;
      if((contb = ContentOfScalarSum(NIL, conta)) != NIL)
      {                                               /* Term content */
        conta = PolyQuotient(conta, contb);
            ScalarSumKill(contb);
      }
      if((contb = PolyContent(conta, mp)) != NIL)
      {                                         /* Polynomial content */
        b = PolyQuotient(conta, contb);             /* Primitive part */
        ScalarSumKill(contb);
      }
      else
            b = conta;
    }
    if(c != NIL)
      b = ScalarSumMultiplication(b, c);
    if(INTEGER_IS_NEGATIVE(SCALAR_TERM_NUMERATOR(b)))
    {                                      /* Standardize sign of GCD */
      c = b;
      do
        SCALAR_TERM_MINUS(c);
      while((c = SCALAR_TERM_R(c)) != NIL);
    }
    if(SCALAR_SUM_IS_UNIT(b))
    {                                      /* Standardize trivial GCD */
      INTEGER_KILL(SCALAR_TERM_NUMERATOR(b));
      NODE_ST_KILL(b);
      b = NIL;
    }
  }
  out:
OUT_POLY_GCD /*-------------------------------------------------------*/
  return b;
}
/*=PolyMainParameterTerm================================================
 Take sublist of terms, containing main parameter MP of given degree
 MPDEG, *PA points to the next term after end of A.
 This function is applied in succession starting from top degree.
 Initial expression *PA is destructed.
*/
U PolyMainParameterTerm(U *pa, I mp, I mpdeg)
{
  U a;
  if(mpdeg)
  {
    SHU w; /* Word combining degree and index of parameter (MPDEG,MP) */
    w = mpdeg;
#if defined(SPP_2000)
    *((CU*)&w) = mp;
#else
    *((CU*)&w+1) = mp;
#endif
    if(SCALAR_TERM_MONOMIAL(*pa) != NIL &&
       SCALAR_TERM_MAIN_PARAMETER_WORD(*pa) == w)
    {                                         /* There is such degree */
      U b;
      a = *pa;
      while(YES)
      {
        b = *pa;                            /* Remember previous term */
        *pa = SCALAR_TERM_R(*pa);
        if(*pa == NIL)
          break;                   /* Whole expression is homogeneous */
        if(SCALAR_TERM_MONOMIAL(*pa) == NIL ||
           SCALAR_TERM_MAIN_PARAMETER_WORD(*pa) != w)
        {                         /* End of homogeneous part is found */
          SCALAR_TERM_R(b) = NIL;               /* Set end of sublist */
              break;
        }
      }
    }
    else                                            /* No such degree */
      a = NIL;
  }
  else
  {                                                      /* Free term */
    a = *pa;
    *pa = NIL;
  }
  return a;
}
/*=PolynomialsAreEqual====================================
*/
I PolynomialsAreEqual(U a, U b)
{
  U ma, mb;
  INT na, nb;
  while(YES)
  {
    /* Compare monomials */

    ma = SCALAR_TERM_MONOMIAL(a);
    mb = SCALAR_TERM_MONOMIAL(b);
    while(YES)
    {
      if(ma == NIL)
        if(mb == NIL)
          break;
            else
          goto no;
      else if(mb == NIL)
            goto no;
      if(SCALAR_FACTOR_WORD(ma) != SCALAR_FACTOR_WORD(mb))
            goto no;
      ma = SCALAR_FACTOR_R(ma);
      mb = SCALAR_FACTOR_R(mb);
    }
    /* Compare numerators */

    na = SCALAR_TERM_NUMERATOR(a);
    nb = SCALAR_TERM_NUMERATOR(b);
    if(na[0] != nb[0])
      goto no;
    ma = INTEGER_N_LIMBS(na);
    do
      if(na[ma] != nb[ma])
        goto no;
    while(ma-- > 0);

    a = SCALAR_TERM_R(a);
    b = SCALAR_TERM_R(b);
    if(a == NIL)
      if(b == NIL)
        return YES;
      else
        goto no;
        else if(b == NIL)
        goto no;
  }
  no:
  return NO;
}
/*=PolyPseudoRemainder==================================================
 Returns pseudo-remainder of two polynomials. MP is main parameter.
 main_degree(A) >= main_degree(B). A, B destructed.
*/
U PolyPseudoRemainder(U a, U b, I mp)
{
IN_POLY_PSEUDO_REMAINDER /*-------------------------------------------*/
  if(SCALAR_TERM_MAIN_PARAMETER(b) != mp)
  {                         /* B doesn't contain MP => return 0 (NIL) */
    ScalarSumKill(a);
    ScalarSumKill(b);
    a = NIL;
  }
  else
  {
    U *u, *v, vn, c, w;
    I m, n, j, k;
    m = SCALAR_TERM_MAIN_DEGREE(a);
    n = SCALAR_TERM_MAIN_DEGREE(b);
    POLY_ARRAY_STACK_NEW(u, m+1);
    POLY_ARRAY_STACK_NEW(v, n);
    for(j = m; j >= 0; j--)                     /*          j         */
      u[j] = PolyMainParameterTerm(&a, mp, j);  /* u[j] = mp  u  etc. */
    vn = PolyMainParameterTerm(&b, mp, n);      /*             j      */
    for(j = n - 1; j >= 0; j--)
      v[j] = PolyMainParameterTerm(&b, mp, j);
    for(k = m - n; k >= 0; k--)
    {
      j = n + k - 1;
      while(j >= k)                             /*    n+j             */
      {                                         /*  mp   (u  = v  u ) */
        if(u[j] != NIL)                         /*         j    n  j  */
          u[j] = ScalarSumMultiplication(ScalarSumCopy(vn), u[j]);
        if(u[n+k] != NIL)
          if(v[j-k] != NIL)
          {
            a = ScalarSumMultiplication(ScalarSumCopy(v[j-k]),
                                        ScalarSumCopy(u[n+k]));
            b = a;
            do
              SCALAR_TERM_MINUS(b);
            while((b = SCALAR_TERM_R(b)) != NIL);     /*     n+j          */
              u[j] = ScalarSumAddition(u[j], a);      /* - mp   v    u    */
          }                                           /*         j-k  n+k */
        if(u[j] != NIL)
        {
          c = u[j];                  /* Drop degree of main parameter */
          do
            if((SCALAR_TERM_MAIN_DEGREE(c) -= n) == 0)
            {                            /* Strike out main parameter */
              w = SCALAR_TERM_MONOMIAL(c);
              SCALAR_TERM_MONOMIAL(c) = SCALAR_FACTOR_R(w);
              NODE_SF_KILL(w);
            }
          while((c = SCALAR_TERM_R(c)) != NIL);
        }
        j--;
      }
      if(u[n+k] != NIL)
        ScalarSumKill(u[n+k]);
      while(j >= 0)
      {
        if(u[j] != NIL)
        {
          u[j] = ScalarSumMultiplication(ScalarSumCopy(vn), u[j]);
          c = u[j];                  /* Drop degree of main parameter */
          do
            if((SCALAR_TERM_MAIN_DEGREE(c) -= n) == 0)
            {                            /* Strike out main parameter */
              w = SCALAR_TERM_MONOMIAL(c);
              SCALAR_TERM_MONOMIAL(c) = SCALAR_FACTOR_R(w);
              NODE_SF_KILL(w);
            }
          while((c = SCALAR_TERM_R(c)) != NIL);
        }
        j--;
      }
    }
    ScalarSumKill(vn);
    for(j = n - 1; j >= 0; j--)
      if(v[j] != NIL)
        ScalarSumKill(v[j]);
    j = n - 1;
    while(j >= 0 && u[j] == NIL)
      j--;                          /* Search first nonzero term u[j] */
    if(j >= 0)
    {                   /* Concatenate pseudoremainder from array u[] */
      a = u[j--];
      b = a;
      while(SCALAR_TERM_R(b) != NIL)
        b = SCALAR_TERM_R(b);
      while(j >= 0)
      {
        if(u[j] != NIL)
            {
              SCALAR_TERM_R(b) = u[j];
          while(SCALAR_TERM_R(b) != NIL)
            b = SCALAR_TERM_R(b);
        }
        j--;
      }
    }
    else                                        /* All u[j] are zeros */
      a = NIL;
  }
OUT_POLY_PSEUDO_REMAINDER /*------------------------------------------*/
  return a;
}
/*=PolyTermGCD==========================================================
 GCD of two single (non-NIL) terms, A is destroyed, B remains,
 caller ensures A is positive, returned NIL corresponds to 1
*/
U PolyTermGCD(U a, U b)
{
  INT na, naa, nb, nbb;
  I i;
  U ma, maa;

  /* Do integer coefficients */

  na = SCALAR_TERM_NUMERATOR(a);
  nb = SCALAR_TERM_NUMERATOR(b);
  naa = na;                               /* Anyway it will be killed */
  INTEGER_STACK_COPY(nbb, nb, i);
  if((naa = IntegerGCD(naa, nbb)) != NULL)   /* naa = GCD(na, nb) > 1 */
  {
    INTEGER_HEAP_COPY(nb, naa, i);
    SCALAR_TERM_NUMERATOR(a) = nb;
  }
  INTEGER_KILL(na);

  /* Do parametric monomials (parameters go in DECREASING order) */

  maa = NIL;
  if((ma = SCALAR_TERM_MONOMIAL(a)) != NIL)
  {
    U maw, mb, mal;
    mb = SCALAR_TERM_MONOMIAL(b);
    while(YES)
    {
      if(mb == NIL)
      {               /* MB is ended - kill tail of MA and break loop */
        while(ma != NIL)
        {
          maw = ma;
          ma = SCALAR_FACTOR_R(ma);
          NODE_SF_KILL(maw);
        }
        if(maa != NIL)
          SCALAR_FACTOR_R(mal) = NIL;
        break;
      }
      if(SCALAR_FACTOR_PARAMETER(ma) > SCALAR_FACTOR_PARAMETER(mb))
      {
        maw = ma;                        /* No match for MA - kill it */
        ma = SCALAR_FACTOR_R(ma);
        NODE_SF_KILL(maw);
        if(ma == NIL)
        {
          if(maa != NIL)
            SCALAR_FACTOR_R(mal) = NIL;
          break;
        }
      }
      else if(SCALAR_FACTOR_PARAMETER(ma) < SCALAR_FACTOR_PARAMETER(mb))
        mb = SCALAR_FACTOR_R(mb);       /* No match for MB - shift it */
      else
      {                                 /* Match - set minimum degree */
        if(SCALAR_FACTOR_DEGREE(mb) < SCALAR_FACTOR_DEGREE(ma))
          SCALAR_FACTOR_DEGREE(ma) = SCALAR_FACTOR_DEGREE(mb);
        if(maa == NIL)
          maa = ma;
        else                                    /* Append to last MAA */
          SCALAR_FACTOR_R(mal) = ma;
        mal = ma;
        ma = SCALAR_FACTOR_R(ma);
        if(ma == NIL)
          break;
      }
    }
  }
  SCALAR_TERM_MONOMIAL(a) = maa;          /* Set constructed monomial */
  if(naa == NULL)
    if(maa == NIL)
    {                                                  /* Trivial GCD */
      NODE_ST_KILL(a);
      a = NIL;
    }
    else                         /* Make standard integer coefficient */
    {
      INTEGER_HEAP_NEW(na, 2);
      na[0] = na[1] = 1;
      SCALAR_TERM_NUMERATOR(a) = na;
    }
  return a;
}
/*=PolyTermQuotient===================================================
 Exact division of term A by term B: A = C*B on place of A, B remains.
 Parameters go in decreasing order.
*/
V PolyTermQuotient(U a, U b)
{
  INT na, nb, naa, nbb, nc;
  I i;
  U mb;

  /* Divide integer numerator */

  na = SCALAR_TERM_NUMERATOR(a);
  nb = SCALAR_TERM_NUMERATOR(b);
  INTEGER_STACK_COPY(nbb, nb, i);
  INTEGER_HEAP_NEW(nc, 2+INTEGER_N_LIMBS(na)-INTEGER_N_LIMBS(nbb));
  INTEGER_STACK_COPY_1(naa, na, i);
  INTEGER_KILL(na);
  IntegerQuotient(nc, naa, nbb);
  SCALAR_TERM_NUMERATOR(a) = nc;

  /* Divide parametric monomial */

  if((mb = SCALAR_TERM_MONOMIAL(b)) != NIL)
  {
    U ma, maa, mae, maw;
    ma = SCALAR_TERM_MONOMIAL(a);
    maa = NIL;
    do
    {
      while(SCALAR_FACTOR_PARAMETER(ma) > SCALAR_FACTOR_PARAMETER(mb))
      {
        if(maa == NIL)
          maa = ma;
        else
          SCALAR_FACTOR_R(mae) = ma;
        mae = ma;
        ma = SCALAR_FACTOR_R(ma);
      }
      if((SCALAR_FACTOR_DEGREE(ma) -= SCALAR_FACTOR_DEGREE(mb)) != 0)
      {
        if(maa == NIL)
          maa = ma;
        else
          SCALAR_FACTOR_R(mae) = ma;
        mae = ma;
        ma = SCALAR_FACTOR_R(ma);
      }
      else
      {
        maw = ma;
        ma = SCALAR_FACTOR_R(ma);
        NODE_SF_KILL(maw);
      }
    }while((mb = SCALAR_FACTOR_R(mb)) != NIL);
    if(maa == NIL)                      /* Append tail of numerator */
      maa = ma;
    else
      SCALAR_FACTOR_R(mae) = ma;
    SCALAR_TERM_MONOMIAL(a) = maa;
  }
}
/*=PolyQuotient====================================================
 Exact division of polynomial A by polynomial B: A = C*B, return C.
 Caller ensures A, B != NIL, B is positive.
 A is destructed, B remains unchanged.
*/
U PolyQuotient(U a, U b)
{
  U c;
IN_POLY_QUOTIENT /*----------------------------------------------*/
  if(SCALAR_TERM_R(b) == NIL)       /* Division by single term B */
  {
    c = a;
    if(SCALAR_SUM_IS_NOT_UNIT(b))             /* Nontrivial term */
      do
        PolyTermQuotient(a, b);
      while((a = SCALAR_TERM_R(a)) != NIL);
  }
  else                               /* Division by polynomial B */
  {
    U aw, bw, cw;
    INT n;
    bw = SCALAR_TERM_R(b);
    c = NIL;
    do
    {
      aw = a;
      a = SCALAR_TERM_R(a);
      SCALAR_TERM_R(aw) = NIL;
      PolyTermQuotient(aw, b);
      cw = ScalarTermCopy(aw);
      n = SCALAR_TERM_NUMERATOR(aw);
      INTEGER_MINUS(n);
      aw = ScalarSumMultiplication(aw, ScalarSumCopy(bw));
      a = ScalarSumAddition(a, aw);            /* Remainder of A */
      c = ScalarSumAddition(c, cw);                /* Quotient C */
    }while(a != NIL);
  }
OUT_POLY_QUOTIENT /*---------------------------------------------*/
  return c;
}

/*_6_5          Big number functions====================================*/

/*=BigNMinusBigN================================================
 Subtract two big numbers on the place of first one: `a' -= `b',
 caller provides `a' > `b', returns new size of `a'
*/
I BigNMinusBigN(INT a, I na, INT b, I nb)
{
  U lw;
  LIMB k = 1;
  I i = 0;
  while(i < nb)         /* Common part */
  {
    lw = MAX_LIMB + (U)k + (U)a[i] - (U)b[i];
    k = (lw > MAX_LIMB);
    a[i++] = (LIMB)lw;
  }
  while(i < na)
  {
    lw = MAX_LIMB + (U)k + (U)a[i];
    k = (lw > MAX_LIMB);
    a[i++] = (LIMB)lw;
  }
  while(--i >= 0)
    if(a[i] != 0)
      break;
  return (++i);
}
/*=BigNShiftLeft==============================================
 Add on spot 0 <= `cnt' < BITS_PER_LIMB lowest zero bits to
 `bign' of size `n', return the bits shifted out from the most
 significant LIMB digit
*/
LIMB BigNShiftLeft(INT bign, I n, I cnt)
{
  if(cnt)
  {
    I cocnt = BITS_PER_LIMB - cnt;
    LIMB low_limb,
         high_limb = bign[--n],
         pushed_out = high_limb >> cocnt;
    while(--n >= 0)
    {
      low_limb = bign[n];
      bign[n+1] = (high_limb << cnt) | (low_limb >> cocnt);
      high_limb = low_limb;
    }
    bign[n+1] = high_limb << cnt;
    return pushed_out;
  }
  return 0;
}
/*=BigNShiftRight==========================================
 Remove on spot 0 <= `cnt' < BITS_PER_LIMB lowest bits from
 `bign' of size `n', return size of the result
*/
I BigNShiftRight(INT bign, I n, I cnt)
{
  if(cnt)
  {
    INT bigni;
    I high_limb, low_limb, i, cocnt = BITS_PER_LIMB - cnt;
    low_limb = *bign;
    bigni = bign;
    bigni++;
    for(i = n-1; i > 0; i--)
    {
      high_limb = *(bigni++);
      *(bign++) = (low_limb >> cnt) | (high_limb << cocnt);
      low_limb = high_limb;
    }
    low_limb >>= cnt;
    if(low_limb != 0)
      *bign = low_limb;
    else
      n--;
#if 0
    LIMB high_limb, low_limb;
    I i, cocnt = BITS_PER_LIMB - cnt;
    low_limb = bign[0];
    for(i = 1; i < n; i++)
    {
      high_limb = bign[i];
      bign[i-1] = (low_limb >> cnt) | (high_limb << cocnt);
      low_limb = high_limb;
    }
    low_limb >>= cnt;
    if(low_limb != 0)
      bign[i-1] = low_limb;
    else
      n--;
#endif
  }
  return n;
}
/*=CountLeadingZeroBitsInLimb=========================
 Count number of leading zero bits in LIMB word
*/
I CountLeadingZeroBitsInLimb(LIMB w)
{
  if(w >= 0x100u) /* [0,  7] */
    if(w >= 0x1000u)    /* [0, 3] */
      if(w >= 0x4000u)          /* [0, 1] */
        if(w >= 0x8000u)
          return 0;
        else
          return 1;
      else                      /* [2, 3] */
        if(w >= 0x2000u)
          return 2;
        else
          return 3;
    else                /* [4, 7] */
      if(w >= 0x400u)           /* [4, 5] */
        if(w >= 0x800u)
          return 4;
        else
          return 5;
      else                      /* [6, 7] */
        if(w >= 0x200u)
          return 6;
        else
          return 7;
  else            /* [8, 16] */
    if(w >= 0x10u)      /* [ 8, 11] */
      if(w >= 0x40u)            /* [ 8,  9] */
        if(w >= 0x80u)
          return 8;
        else
          return 9;
      else                      /* [10, 11] */
        if(w >= 0x20u)
          return 10;
        else
          return 11;
    else                /* [12, 16] */
      if(w >= 0x4u)             /* [12, 13] */
        if(w >= 0x8u)
          return 12;
        else
          return 13;
      else                      /* [14, 16] */
        if(w >= 0x2u)
          return 14;
        else                            /* [15, 16] */
          if(w)
            return 15;
          else
            return 16;
}
/*=IntegerCancellation========================================
 Results are placed in `num' and `den' arrays
*/
V IntegerCancellation(INT num, INT den)
{
  INT n, d, g;
  I i;
IN_INTEGER_CANCELLATION  /*----------------------*/
  INTEGER_STACK_COPY_1(n, num, i);
  INTEGER_STACK_COPY_1(d, den, i);
  if((g = IntegerGCD(num, den)) != NULL)
  {
    INT gg;
    INTEGER_STACK_COPY(gg, g, i);  /* `g' in `num' */

    /* Cancel `den' */

    IntegerQuotient(den, d, g);

    /* Cancel `num' */

    IntegerQuotient(num, n, gg);
  }
  else    /* Lozh' vzad */
  {
    i = INTEGER_N_LIMBS(n);
    do
      num[i] = n[i];
    while(i--);
    i = d[0];  /* Denominators and GCDs are positive always */
    do
      den[i] = d[i];
    while(i--);
  }
OUT_INTEGER_CANCELLATION /*----------------------*/
}
/*=IntegerGCD=========================================================
 Binary algorithm is used,
 Returns pointer to array of greatest common divisor
 or NULL interpreted as 1 by caller,
 the function spoils both arrays `u' and `v',
 result is placed in `u' array
*/
INT IntegerGCD(INT u, INT v)
{
  I i, nu, nv, bcnt, w_bcnt;
  INT u0;
  LIMB carry_digit;
IN_INTEGER_GCD  /*--------------------------------------------------*/
  nu = INTEGER_N_LIMBS(u);
  nv = INTEGER_N_LIMBS(v);
  u0 = ++u;       /* Skip size information limbs and memorize begin */
  ++v;
  i = 0;                             /* Shift down U to make it odd */
  while(*u == 0)
  {                                              /* Skip zero limbs */
    ++i;
    ++u;
  }
  COUNT_LEADING_ZERO_BITS_IN_LIMB(bcnt, *u & -*u);
  bcnt = BITS_PER_LIMB - 1 - bcnt;
  nu = BigNShiftRight(u, nu - i, bcnt);
  bcnt += i * BITS_PER_LIMB;
  w_bcnt = bcnt;
  i = 0;                             /* Shift down V to make it odd */
  while(*v == 0)
  {                                              /* Skip zero limbs */
    ++i;
    ++v;
  }
  COUNT_LEADING_ZERO_BITS_IN_LIMB(bcnt, *v & -*v);
  bcnt = BITS_PER_LIMB - 1 - bcnt;
  nv = BigNShiftRight(v, nv - i, bcnt);
  bcnt += i * BITS_PER_LIMB;
  if(bcnt < w_bcnt)
    w_bcnt = bcnt;                  /* Number of common 2 factors.  */
  while(YES)
  {
    if(nu > nv)
      goto u_greater_v;
    if(nu < nv)
      goto v_greater_u;
    i = nu;
    while(--i >= 0)
    {
      if(u[i] > v[i])
        goto u_greater_v;
      if(v[i] > u[i])
        goto v_greater_u;
    }
    break;   /* If U and V have become equal, we have found the GCD */
    u_greater_v:  /* Replace U by (U - V) >> cnt making U odd again */
    nu = BigNMinusBigN(u, nu, v, nv);
    while(*u == 0)
    {
      --nu;
      ++u;
    }
    COUNT_LEADING_ZERO_BITS_IN_LIMB(bcnt, *u & -*u);
    bcnt = BITS_PER_LIMB - 1 - bcnt;
    nu = BigNShiftRight(u, nu, bcnt);
    continue;
    v_greater_u:  /* Replace V by (V - U) >> cnt making V odd again */
    nv = BigNMinusBigN(v, nv, u, nu);
    while(*v == 0)
    {
      --nv;
      ++v;
    }
    COUNT_LEADING_ZERO_BITS_IN_LIMB(bcnt, *v & -*v);
    bcnt = BITS_PER_LIMB - 1 - bcnt;
    nv = BigNShiftRight(v, nv, bcnt);
  }
  /* GCD(U_IN, V_IN) now is U * 2**W_BCNT.  */
  carry_digit = BigNShiftLeft(u, nu, w_bcnt % BITS_PER_LIMB);
  i = w_bcnt / BITS_PER_LIMB;
  u -= i;
  i += nu;
  if(carry_digit != 0)
  {
    if(u > u0)
    {
      u0 = u--;   /* Shift to left by 1 limb to make room for carry */
      for(nu = 0; nu < i; nu++)
        u[nu] = u0[nu];
    }
    u[i++] = carry_digit;
  }
  if(i == 1 && u[0] == 1)
    return NULL;
  --u;
  u[0] = i;                                    /* PLUS == 0 assumed */
OUT_INTEGER_GCD /*--------------------------------------------------*/
  return u;
}
/*=IntegerProduct======================================
 Traditional multiplication of two signed non-zero
 big numbers U and V, result in W, W[] != U[] or V[]
*/
V IntegerProduct(INT w, INT u, INT v)
{
  LIMB carry;
  U luw;
  INT w0;
  I set_minus, i, j, n, m;
IN_INTEGER_PRODUCT  /*-------------------------------*/
  n = INTEGER_N_LIMBS(u);
  m = INTEGER_N_LIMBS(v);
  set_minus = (INTEGER_SIGN(u) != INTEGER_SIGN(v));
  u++;
  v++;
  w0 = w;
  w++;
  i = j = 0;
  do
    w[i] = 0;
  while(++i < n);
  do
  {
    i = carry = 0;
    do
    {
      luw = (U)u[i]*(U)v[j] + (U)w[i+j] + (U)carry;
      w[i+j] = (LIMB)luw;
      carry = (LIMB)(luw/BASE_LIMB);
    }while(++i < n);
    w[j+n] = carry;
  }while(++j < m);
  n += m - (carry == 0);
#if defined(INTEGER_MAX_SIZE)
  if(n > IntegerMaxSize)
    IntegerMaxSize = n;
#endif
  w0[0] = n;
  if(set_minus)
    INTEGER_SET_MINUS(w0);
OUT_INTEGER_PRODUCT /*-------------------------------*/
}
/*=IntegerQuotient=====================================================
 Exact division of big numbers:
 Quotient in C[*PM - N + 1 or *PM - N stored in *PM] = A[M] / B[N],
 C != A, C != B.
 Function is spoiling input A and B.
 Array for A should have 1 additional LIMB at the top
 for increasing A at normalizing B.
*/
V IntegerQuotient(INT c, INT a, INT b)
{
  U lw;
  LIMB q;
  I i, n, set_minus = (INTEGER_SIGN(a) != INTEGER_SIGN(b));
#if defined(D_CHECK_EXACTNESS_OF_DIVISION)
  I nr;
#endif
  INT pm = c;
IN_INTEGER_QUOTIENT  /*----------------------------------------------*/
  *pm = INTEGER_N_LIMBS(a);
  n = INTEGER_N_LIMBS(b);
  a++;
  b++;
  c++;
  if(n == 1)
  {                                      /* Division by short number */
    i = *pm - 1;
    q = a[i] % *b;                                /* Carried residue */
    if((c[i] = a[i] / *b) == 0)
      --*pm;
    while(i)
    {
      lw = (U)(q)*BASE_LIMB + (U)a[--i];
      q = (LIMB)(lw % *b);
      c[i] = (LIMB)(lw / *b);
    }
#if defined(D_CHECK_EXACTNESS_OF_DIVISION)
    nr = (q != 0);
#endif
  }
  else
  {                                 /* Division by big number: n > 1 */
    INT aw, bq;
    I k, j, shift, n1 = n + 1;
    LIMB carry, aj, aj1, aj2, bn1, bn2;
    INTEGER_STACK_NEW(bq, n1);                        /* For B[] * Q */
    COUNT_LEADING_ZERO_BITS_IN_LIMB(shift, b[n-1]);
    if(shift)             /* Normalize to make b[n-1] >= BASE_LIMB/2 */
    {
      a[*pm] = BigNShiftLeft(a, *pm, shift);
      BigNShiftLeft(b, n, shift);
    }
    else
      a[*pm] = 0;
    bn1 = b[n-1];
    bn2 = b[n-2];
    j = *pm;
    k = *pm - n;                     /* Top digit C[M-N] may be zero */
    *pm = k + 1;                /* Number of C[K] getting iterations */
    aw = a + k;  /* Start of current subarray of A of the length N+1 */
    do
    {
      aj = a[j];
      aj1 = a[j-1];
      aj2 = a[j-2];
      lw = (U)aj * BASE_LIMB + (U)aj1;
      q = (aj == bn1) ? MAX_LIMB : (LIMB)(lw/bn1);
      lw -= (U)q*(U)bn1;
      if(lw < BASE_LIMB && (U)bn2*(U)q > lw*BASE_LIMB + (U)aj2)
      {                      /* Knuth's criterion shows Q is too big */
        q--;
        lw += (U)bn1;
        if(lw < BASE_LIMB && (U)bn2*(U)q > lw*BASE_LIMB + (U)aj2)
          q--;  /* Q was still too big */
      }
      if(q)
      {                                     /* Multiply and subtract */
        i = carry = 0;                /* Make copy of product B by Q */
        do
        {
          lw = (U)q * (U)b[i] + (U)carry;
          carry = (LIMB)(lw/BASE_LIMB);
          bq[i] = (LIMB)lw;
        }while(++i < n);
        bq[i] = carry;               /* BQ[] padded by zero if needs */
        i = n;
        do
          if(aw[i] != bq[i])
          {                                      /* AW[] - BQ[] != 0 */
            if(aw[i] < bq[i])
            {                             /* AW[] - BQ[] is negative */
              q--;                          /* Additional correction */
              BigNMinusBigN(bq, n1, b, n);
            }
            break;
          }
        while(--i >= 0);
#if defined(D_CHECK_EXACTNESS_OF_DIVISION)
        nr =
#endif
        BigNMinusBigN(aw, n1, bq, n1);        /* AW[] - BQ[] on spot */
      }
      c[k--] = q;                    /* Set current LIMB of quotient */
      --aw;                            /* Shift subarray of A digits */
    }while(--j >= n);
    if(c[*pm-1] == 0)
      --*pm;           /* Real quotient size is M - N, not M - N + 1 */
#if defined(D_CHECK_EXACTNESS_OF_DIVISION)
    if(nr && shift)
      nr = BigNShiftRight(a, nr, shift);      /* Normalize remainder */
#endif
  }
  if(set_minus)
    INTEGER_SET_MINUS(pm);
OUT_INTEGER_QUOTIENT /*----------------------------------------------*/
#if defined(D_CHECK_EXACTNESS_OF_DIVISION)
  if(nr)
  {
    PutFormattedU("\n***Division violation at Debug==%u\n", Debug);
    EXIT;
  }
#endif
}
/*=IntegerSum=========================================
 Sum of two signed big numbers A and B, result in C
*/
V IntegerSum(INT c, INT a, INT b)
{
  I set_minus, i, na, nb;
  U lw;
  LIMB carry;
IN_INTEGER_SUM /*-----------------------------------*/
  if(INTEGER_N_LIMBS(a) < INTEGER_N_LIMBS(b))
  {
    INT w = a;   /* Swap input numbers if necessary */
    a = b;
    b = w;
  }
  na = INTEGER_N_LIMBS(a);
  nb = INTEGER_N_LIMBS(b);
  if(INTEGER_SIGN(a) == INTEGER_SIGN(b))
  {                     /* The same signs: addition */
    set_minus = INTEGER_IS_NEGATIVE(a);
    i = 1;
    carry = 0;
    while(i <= nb)                   /* Common part */
    {
      lw = (U)carry + (U)a[i] + (U)b[i];
      carry = (lw > MAX_LIMB);
      c[i++] = (LIMB)lw;
    }
    while(i <= na)                          /* Tail */
    {
      lw = (U)carry + (U)a[i];
      carry = (lw > MAX_LIMB);
      c[i++] = (LIMB)lw;
    }
    if(carry)
      c[i] = 1;
    else
      i--;
#if defined(INTEGER_MAX_SIZE)
    if(i > IntegerMaxSize)
      IntegerMaxSize = i;
#endif
  }
  else              /* Different signs: subtraction */
  {
    if(na == nb)
    {
      i = na;
      while(i > 0)
      {
        if(a[i] < b[i])
        {                           /* Swap numbers */
          INT w = a;
          a = b;
          b = w;
          goto subtract;
        }
        else if(a[i] != b[i])
          goto subtract;
        i--;
      }
      c[0] = 0;       /* Zero result of subtraction */
      goto out;
    }
    subtract:
    set_minus = INTEGER_IS_NEGATIVE(a);
    i = carry = 1;
    while(i <= nb)                   /* Common part */
    {
      lw = MAX_LIMB + (U)carry + (U)a[i] - (U)b[i];
      carry = (lw > MAX_LIMB);
      c[i++] = (LIMB)lw;
    }
    while(i <= na)
    {
      lw = MAX_LIMB + (U)carry + (U)a[i];
      carry = (lw > MAX_LIMB);
      c[i++] = (LIMB)lw;
    }
    while(--i > 0)
      if(c[i] != 0)
        break;
  }
  c[0] = i;               /* Number of LIMBs in sum */
  if(set_minus)
    INTEGER_SET_MINUS(c);
  out:
OUT_INTEGER_SUM /*----------------------------------*/
  return;
}

/*_6_6          Copy and delete functions===============================*/

/*=LieSumCopyInteger===================================
  Integer regime
*/
U LieSumCopyInteger(U a)
{
  if(a != NIL)
  {
    U ca, eca;
    INT n, cn;
    I i;
IN_LIE_SUM_COPY  /*----------------------------------*/
    ca = eca = NodeLTNew();
    LIE_TERM_MONOMIAL(eca) = LIE_TERM_MONOMIAL(a);
    n = LIE_TERM_NUMERATOR_INTEGER(a);
    INTEGER_HEAP_COPY(cn, n, i);
    LIE_TERM_NUMERATOR_INTEGER(eca) = cn;
    if((n = LIE_TERM_DENOMINATOR_INTEGER(a)) != NULL)
    {
      INTEGER_HEAP_COPY(cn, n, i);
      LIE_TERM_DENOMINATOR_INTEGER(eca) = cn;
    }
    else
      LIE_TERM_DENOMINATOR_INTEGER(eca) = NULL;
    while((a = LIE_TERM_R(a)) != NIL)
    {
      LIE_TERM_R(eca) = NodeLTNew();
      eca = LIE_TERM_R(eca);
      LIE_TERM_MONOMIAL(eca) = LIE_TERM_MONOMIAL(a);
      n = LIE_TERM_NUMERATOR_INTEGER(a);
      INTEGER_HEAP_COPY(cn, n, i);
      LIE_TERM_NUMERATOR_INTEGER(eca)= cn;
      if((n = LIE_TERM_DENOMINATOR_INTEGER(a)) != NULL)
      {
        INTEGER_HEAP_COPY(cn, n, i);
        LIE_TERM_DENOMINATOR_INTEGER(eca) = cn;
      }
      else
        LIE_TERM_DENOMINATOR_INTEGER(eca) = NULL;
    }
OUT_LIE_SUM_COPY /*----------------------------------*/
    return ca;
  }
  return NIL;
}
/*=LieSumCopyIntegerNegative===================================
  Copy changing sign. Integer regime
*/
U LieSumCopyIntegerNegative(U a)
{
  if(a != NIL)
  {
    U ca, eca;
    INT n, cn;
    I i;
    ca = eca = NodeLTNew();
    LIE_TERM_MONOMIAL(eca) = LIE_TERM_MONOMIAL(a);
    n = LIE_TERM_NUMERATOR_INTEGER(a);
    INTEGER_HEAP_COPY(cn, n, i);
    INTEGER_MINUS(cn);
    LIE_TERM_NUMERATOR_INTEGER(eca) = cn;
    if((n = LIE_TERM_DENOMINATOR_INTEGER(a)) != NULL)
    {
      INTEGER_HEAP_COPY(cn, n, i);
      LIE_TERM_DENOMINATOR_INTEGER(eca) = cn;
    }
    else
      LIE_TERM_DENOMINATOR_INTEGER(eca) = NULL;
    while((a = LIE_TERM_R(a)) != NIL)
    {
      LIE_TERM_R(eca) = NodeLTNew();
      eca = LIE_TERM_R(eca);
      LIE_TERM_MONOMIAL(eca) = LIE_TERM_MONOMIAL(a);
      n = LIE_TERM_NUMERATOR_INTEGER(a);
      INTEGER_HEAP_COPY(cn, n, i);
      INTEGER_MINUS(cn);
      LIE_TERM_NUMERATOR_INTEGER(eca)= cn;
      if((n = LIE_TERM_DENOMINATOR_INTEGER(a)) != NULL)
      {
        INTEGER_HEAP_COPY(cn, n, i);
        LIE_TERM_DENOMINATOR_INTEGER(eca) = cn;
      }
      else
        LIE_TERM_DENOMINATOR_INTEGER(eca) = NULL;
    }
    return ca;
  }
  return NIL;
}
/*=LieSumCopyParametric=====================================
  Parametric regime
*/
U LieSumCopyParametric(U a)
{
  if(a != NIL)
  {
    U ca, eca;
IN_LIE_SUM_COPY  /*---------------------------------------*/
    ca = eca = NodeLTNew();
    LIE_TERM_MONOMIAL(eca) = LIE_TERM_MONOMIAL(a);
    LIE_TERM_NUMERATOR_SCALAR_SUM(eca) =

      ScalarSumCopy(LIE_TERM_NUMERATOR_SCALAR_SUM(a));
    if(LIE_TERM_DENOMINATOR_SCALAR_SUM(a) != NIL)
      LIE_TERM_DENOMINATOR_SCALAR_SUM(eca) =
        ScalarSumCopy(LIE_TERM_DENOMINATOR_SCALAR_SUM(a));
    else
      LIE_TERM_DENOMINATOR_SCALAR_SUM(eca) = NIL;
    while((a = LIE_TERM_R(a)) != NIL)
    {
      LIE_TERM_R(eca) = NodeLTNew();
      eca = LIE_TERM_R(eca);
      LIE_TERM_MONOMIAL(eca) = LIE_TERM_MONOMIAL(a);
      LIE_TERM_NUMERATOR_SCALAR_SUM(eca) =
        ScalarSumCopy(LIE_TERM_NUMERATOR_SCALAR_SUM(a));
      if(LIE_TERM_DENOMINATOR_SCALAR_SUM(a) != NIL)
        LIE_TERM_DENOMINATOR_SCALAR_SUM(eca) =
          ScalarSumCopy(LIE_TERM_DENOMINATOR_SCALAR_SUM(a));
      else
        LIE_TERM_DENOMINATOR_SCALAR_SUM(eca) = NIL;
    }
OUT_LIE_SUM_COPY /*---------------------------------------*/
    return ca;
  }
  return NIL;
}
/*=LieSumKillInteger================================
 a == NIL is admitted (Integer regime)
*/
V LieSumKillInteger(U a)
{
  U b;
  INT d;
IN_LIE_SUM_KILL  /*-------------------------------*/
  while(a != NIL)
  {
    b = a;
    a = LIE_TERM_R(a);
    INTEGER_KILL(LIE_TERM_NUMERATOR_INTEGER(b));
    if((d = LIE_TERM_DENOMINATOR_INTEGER(b)) != NULL)
      INTEGER_KILL(d);
    NODE_LT_KILL(b);
  }
OUT_LIE_SUM_KILL  /*------------------------------*/
}
/*=LieSumKillParametric===============================
 a == NIL is admitted (Parametric regime)
*/
V LieSumKillParametric(U a)
{
  U b;
IN_LIE_SUM_KILL  /*---------------------------------*/
  while(a != NIL)
  {
    b = a;
    a = LIE_TERM_R(a);
    ScalarSumKill(LIE_TERM_NUMERATOR_SCALAR_SUM(b));
    ScalarSumKill(LIE_TERM_DENOMINATOR_SCALAR_SUM(b));
    NODE_LT_KILL(b);
  }
OUT_LIE_SUM_KILL  /*--------------------------------*/
}
/*=LieTermFromMonomialInteger============
*/
U LieTermFromMonomialInteger(I mon)
{
  INT num;
  U a = NodeLTNew();

  LIE_TERM_MONOMIAL(a) = mon;

  INTEGER_HEAP_NEW(num, 2);
  num[0] = num[1] = 1;
  LIE_TERM_NUMERATOR_INTEGER(a) = num;

  LIE_TERM_DENOMINATOR_INTEGER(a) = NULL;

  return a;
}
/*=LieTermFromMonomialParametric===========
*/
U LieTermFromMonomialParametric(I mon)
{
  INT num;
  U c = NodeSTNew(), 
    a = NodeLTNew();

  LIE_TERM_MONOMIAL(a) = mon;

  SCALAR_TERM_MONOMIAL(c) = NIL;
  INTEGER_HEAP_NEW(num, 2);
  num[0] = num[1] = 1;
  SCALAR_TERM_NUMERATOR(c) = num;

  LIE_TERM_NUMERATOR_SCALAR_SUM(a) = c;

  LIE_TERM_DENOMINATOR_SCALAR_SUM(a) = NIL;

  return a;
}
/*=ScalarSumCopy=======================================
 Caller ensures a != NIL
*/
U ScalarSumCopy(U a)
{
  I i;
  INT n, o;
  U ca, bca, b, cb;
  bca = ca = NodeSTNew();
  while(YES)
  {
    /* Copy integer coefficient */

    o = SCALAR_TERM_NUMERATOR(a);
    INTEGER_HEAP_COPY(n, o, i);
    SCALAR_TERM_NUMERATOR(ca) = n;

    /* Copy scalar monomial */

    b = SCALAR_TERM_MONOMIAL(a);
    if(b != NIL)
    {
      SCALAR_TERM_MONOMIAL(ca) = cb = NodeSFNew();
      SCALAR_FACTOR_WORD(cb) = SCALAR_FACTOR_WORD(b);
      while((b = SCALAR_FACTOR_R(b)) != NIL)
      {
        SCALAR_FACTOR_R(cb) = NodeSFNew();
        cb = SCALAR_FACTOR_R(cb);
        SCALAR_FACTOR_WORD(cb) = SCALAR_FACTOR_WORD(b);
      }
    }
    else
      SCALAR_TERM_MONOMIAL(ca) = NIL;

    if((a = SCALAR_TERM_R(a)) == NIL)
      break;
    SCALAR_TERM_R(ca) = NodeSTNew();
    ca = SCALAR_TERM_R(ca);
  }
  return bca;
}
/*=ScalarSumKill=================================================
  Only at IsParametric == YES, a == NIL is admitted
*/
V ScalarSumKill(U a)
{
  U b, c;
  while(a != NIL)
  {
    b = a;
    a = SCALAR_TERM_R(a);
    INTEGER_KILL(SCALAR_TERM_NUMERATOR(b));
    c = SCALAR_TERM_MONOMIAL(b);
    NODE_ST_KILL(b);
    while(c != NIL)   /* Scalar monomial may be NIL, U-U mix */
    {
      b = c;
      c = SCALAR_FACTOR_R(c);
      NODE_SF_KILL(b);
    }
  }
}
/*=ScalarTermCopy====================================
 Caller ensures a != NIL
*/
U ScalarTermCopy(U a)
{
  I i;
  INT cn, n;
  U m, ca = NodeSTNew();

  /* Copy integer coefficient */

  n = SCALAR_TERM_NUMERATOR(a);
  INTEGER_HEAP_COPY(cn, n, i);
  SCALAR_TERM_NUMERATOR(ca) = cn;

  /* Copy monomial */

  if((m = SCALAR_TERM_MONOMIAL(a)) != NIL)
  {
    U cm;
    SCALAR_TERM_MONOMIAL(ca) = cm = NodeSFNew();
    SCALAR_FACTOR_WORD(cm) = SCALAR_FACTOR_WORD(m);
    while((m = SCALAR_FACTOR_R(m)) != NIL)
    {
      SCALAR_FACTOR_R(cm) = NodeSFNew();
      cm = SCALAR_FACTOR_R(cm);
      SCALAR_FACTOR_WORD(cm) = SCALAR_FACTOR_WORD(m);
    }
  }
  else
    SCALAR_TERM_MONOMIAL(ca) = NIL;
  return ca;
}

/*_6_7          Technical functions=====================================*/

/*=Error!===============
*/
V Error(I i_message)
{
  PutMessage(ERROR);
  PutMessage(i_message);
  EXIT;
}
/*=Initialization==========================================================
*/
V Initialization(V)
{
  FILE *inif;
  SHI c;
  U i, j;
  S init_case[N_INIT_CASES];

  /* Set cases strings */

  init_case[COEFFICIENT_SUM_TABLE_SIZE] = "Co";
  init_case[CRUDE_TIME]                 = "Cr";
  init_case[ECHO_INPUT_FILE]            = "Ec";
  init_case[EVEN_BASIS_SYMBOL]          = "Ev";
  init_case[GAP_ALGEBRA_NAME]           = "GAP a";
  init_case[GAP_BASIS_NAME]             = "GAP b";
  init_case[GAP_RELATIONS_NAME]         = "GAP r";
  init_case[GAP_OUTPUT_BASIS]           = "GAP output b";
  init_case[GAP_OUTPUT_COMMUTATORS]     = "GAP output c";
  init_case[GAP_OUTPUT_RELATIONS]       = "GAP output r";
  init_case[GENERATOR_MAX_N]            = "Ge";
  init_case[INPUT_DIRECTORY]            = "Input d";
  init_case[INPUT_INTEGER_SIZE]         = "Input i";
  init_case[INPUT_STRING_SIZE]          = "Input s";
  init_case[LEFT_NORMED_OUTPUT]         = "Le";
  init_case[LIE_MONOMIAL_SIZE]          = "Lie";
  init_case[LINE_LENGTH]                = "Lin";
  init_case[NAME_LENGTH]                = "Na";
  init_case[NODE_LT_SIZE]               = "Node L";
  init_case[NODE_SF_SIZE]               = "Node scalar f";
  init_case[NODE_ST_SIZE]               = "Node scalar t";
  init_case[ODD_BASIS_SYMBOL]           = "Od";
  init_case[OUT_LINE_SIZE]              = "Ou";
  init_case[PARAMETER_MAX_N]            = "Pa";
  init_case[PUT_BASIS_ELEMENTS]         = "Put b";
  init_case[PUT_COMMUTATORS]            = "Put c";
  init_case[PUT_HILBERT_SERIES]         = "Put H";
  init_case[PUT_INITIAL_RELATIONS]      = "Put i";
  init_case[PUT_NON_ZERO_COEFFICIENTS]  = "Put n";
  init_case[PUT_PROGRAM_HEADING]        = "Put p";
  init_case[PUT_REDUCED_RELATIONS]      = "Put r";
  init_case[PUT_STATISTICS]             = "Put s";
  init_case[RELATION_SIZE]              = "Re";

#if !defined(GAP)
#if defined(SPP_2000)
  MessageFile = OpenFile("fplsa4.msg", "r");
  SessionFile = OpenFile("fplsa4.ses", "w");
  inif = OpenFile("fplsa4.ini", "r");
#else
  MessageFile = OpenFile("fplsa4.msg", "rt");
  SessionFile = OpenFile("fplsa4.ses", "wt");
  inif = OpenFile("fplsa4.ini", "rt");
#endif
#else
#if defined(SPP_2000)
  inif = OpenFile("fplsa4.ini", "r");
#else
  inif = OpenFile("fplsa4.ini", "rt");
#endif
#endif
  while(YES)
    switch(ReadCaseFromFile(inif, init_case, N_INIT_CASES))
    {
      case COEFFICIENT_SUM_TABLE_SIZE:
        CoeffSumTableSize = ReadDecimalFromFile(inif);
      break;
      case CRUDE_TIME:
        CrudeTime = ReadBooleanFromFile(inif);
      break;
      case ECHO_INPUT_FILE:
        EchoInput = ReadBooleanFromFile(inif);
      break;
      case EVEN_BASIS_SYMBOL:
        BasisSymbolEven = fgetc(inif);
      break;
      case GAP_ALGEBRA_NAME:
        if(ReadStringFromFile(GAPAlgebraName, inif) == EOF)
          goto out;
      break;
      case GAP_BASIS_NAME:
        if(ReadStringFromFile(GAPBasisName, inif) == EOF)
          goto out;
      break;
      case GAP_RELATIONS_NAME:
        if(ReadStringFromFile(GAPRelationsName, inif) == EOF)
          goto out;
      break;
      case GAP_OUTPUT_BASIS:
        GAPOutputBasis = ReadBooleanFromFile(inif);
      break;
      case GAP_OUTPUT_COMMUTATORS:
        GAPOutputCommutators = ReadBooleanFromFile(inif);
      break;
      case GAP_OUTPUT_RELATIONS:
        GAPOutputRelations = ReadBooleanFromFile(inif);
      break;
      case GENERATOR_MAX_N:
        GeneratorMaxN = ReadDecimalFromFile(inif);
      break;
      case INPUT_DIRECTORY:
        while((c = fgetc(inif)) != '\n')
        {
          if(c == LEFT_COMMENT)
          {
            ungetc(c, inif);
            break;
          }
          if(c == EOF)
            goto out;
          if(!isspace(c))
            OutLine[PosOutLine++] = (C)c;
        }
      break;
      case INPUT_INTEGER_SIZE:
        InputIntegerSize =  (U)ReadDecimalFromFile(inif);
        InputIntegerSize++; /* For head */
      break;
      case INPUT_STRING_SIZE:
        InputStringSize =  (U)ReadDecimalFromFile(inif);
      break;
      case LEFT_NORMED_OUTPUT:
        if(ReadBooleanFromFile(inif))
          PutLieMonomial = PutLieMonomialLeftNormed;
      break;
      case LINE_LENGTH:
        LineLength = (U)ReadDecimalFromFile(inif);
      break;
      case LIE_MONOMIAL_SIZE:
        LieMonomialSize = (I)ReadDecimalFromFile(inif);
        LieMonomial = (LIE_MON*)NewArray(LieMonomialSize, sizeof(LIE_MON),
                                                         E_A_LIE_MONOMIAL);
      break;
      case NAME_LENGTH:
        NameLength1 = ReadDecimalFromFile(inif);
        NameLength1++;
      break;
      case NODE_LT_SIZE:
        NodeLTSize = (U)ReadDecimalFromFile(inif);
        NodeLT =
          (NODE_LT*)NewArray(NodeLTSize, sizeof(NODE_LT), E_A_NODE_LT);
        i = 1;
        j = 2;
        while(j < NodeLTSize) /* Install NodeLT for Lie terms */
          LIE_TERM_R(i++) = j++;
#if defined(SPACE_STATISTICS)
        LIE_TERM_R(i) = NOTHING;
#else
        LIE_TERM_R(i) = NIL;
#endif
      break;
      case NODE_SF_SIZE:
        NodeSFSize = (U)ReadDecimalFromFile(inif);
      break;
      case NODE_ST_SIZE:
        NodeSTSize = (U)ReadDecimalFromFile(inif);
      break;
      case ODD_BASIS_SYMBOL:
        BasisSymbolOdd = fgetc(inif);
      break;
      case OUT_LINE_SIZE:
        OutLineSize = (U)ReadDecimalFromFile(inif);
        OutLine = (S)NewArray(OutLineSize, 1, E_A_OUT_LINE);
      break;
      case PARAMETER_MAX_N:
        ParameterMaxN = ReadDecimalFromFile(inif);
      break;
      case PUT_BASIS_ELEMENTS:
        BasisElementsPut = ReadBooleanFromFile(inif);
      break;
      case PUT_COMMUTATORS:
        CommutatorsPut = ReadBooleanFromFile(inif);
      break;
      case PUT_HILBERT_SERIES:
        HilbertSeriesPut = ReadBooleanFromFile(inif);
      break;
      case PUT_INITIAL_RELATIONS:
        InitialRelationsPut = ReadBooleanFromFile(inif);
      break;
      case PUT_NON_ZERO_COEFFICIENTS:
        NonZeroCoefficientsPut = ReadBooleanFromFile(inif);
      break;
      case PUT_PROGRAM_HEADING:
        HeadingPut = ReadBooleanFromFile(inif);
      break;
      case PUT_REDUCED_RELATIONS:
        ReducedRelationsPut = ReadBooleanFromFile(inif);
      break;
      case PUT_STATISTICS:
        StatisticsPut = ReadBooleanFromFile(inif);
      break;
      case RELATION_SIZE:
        RelationSize = (I)ReadDecimalFromFile(inif);
        Relation = (REL*)NewArray(RelationSize, sizeof(REL), E_A_RELATION);
      break;
      case EOF:
        goto out;
      default:
        Error(E_WRONG_INI_CASE);
    }
  out:
  fclose(inif);
  if(HeadingPut)
    PutMessage(H_PROGRAM);
  GeneratorName = (S)NewArray(GeneratorMaxN*NameLength1, sizeof(C),
                                                 E_A_GENERATOR_NAME);
}
/*=NewArray=========================================
*/
V * NewArray(U n, U size, I i_message)
{
  V * new_pointer = (V *)calloc(n, size);
  if(new_pointer == NULL && n != 0)
  {
    S format = "%u elements of size %u\n%u bytes\n";
    PutMessage(E_ALLOC);
    PutMessage(i_message);
#if defined(ECHO_TO_SCREEN)
    printf(format, n,  size, n*size);
#endif
#if !defined(GAP)
    fprintf(SessionFile, format, n,  size, n*size);
#endif
    EXIT;
  }
  return new_pointer;
}
/*=NodeLTNew===================
 Get node from NodeLT pool.
*/
U NodeLTNew(V)
{
  U a = NodeLTTop;
#if !defined(SPACE_STATISTICS)
  if(a == NIL)
  {
    TIME_OFF;
    PutStatistics();
    Error(E_NODE_LT_SIZE);
  }
#endif
  NodeLTTop = LIE_TERM_R(a);
#if defined(SPACE_STATISTICS)
  if(NodeLTTopMax < NodeLTTop)
  {
    if(NodeLTTop > NodeLTSize)
    {
      TIME_OFF;
      PutStatistics();
      Error(E_NODE_LT_SIZE);
    }
    NodeLTTopMax = NodeLTTop;
  }
#endif
  LIE_TERM_R(a) = NIL;
PP_CURRENT_N_LT     /* MEMORY */
    return a;
}
/*=NodeSFNew=====================
 Get node from NodeSF pool.
*/
U NodeSFNew(V)
{
  U a = NodeSFTop;
#if !defined(SPACE_STATISTICS)
  if(a == NIL)
  {
    TIME_OFF;
    PutStatistics();
    Error(E_NODE_SF_SIZE);
  }
#endif
  NodeSFTop = SCALAR_FACTOR_R(a);
#if defined(SPACE_STATISTICS)
  if(NodeSFTopMax < NodeSFTop)
  {
    if(NodeSFTop > NodeSFSize)
    {
      TIME_OFF;
      PutStatistics();
      Error(E_NODE_SF_SIZE);
    }
    NodeSFTopMax = NodeSFTop;
  }
#endif
  SCALAR_FACTOR_R(a) = NIL;
PP_CURRENT_N_SF     /* MEMORY */
    return a;
}
/*=NodeSTNew===================
 Get node from NodeST pool.
*/
U NodeSTNew(V)
{
  U a = NodeSTTop;
#if !defined(SPACE_STATISTICS)
  if(a == NIL)
  {
    TIME_OFF;
    PutStatistics();
    Error(E_NODE_ST_SIZE);
  }
#endif
  NodeSTTop = SCALAR_TERM_R(a);
#if defined(SPACE_STATISTICS)
  if(NodeSTTopMax < NodeSTTop)
  {
    if(NodeSTTop > NodeSTSize)
    {
      TIME_OFF;
      PutStatistics();
      Error(E_NODE_ST_SIZE);
    }
    NodeSTTopMax = NodeSTTop;
  }
#endif
  SCALAR_TERM_R(a) = NIL;
PP_CURRENT_N_ST     /* MEMORY */
    return a;
}
/*=OpenFile================================
*/
FILE *OpenFile(S file_name, S file_type)
{
  FILE *file = fopen(file_name, file_type);
  if(file == NULL)
  {
    printf("\nNo file: %s", file_name);
    exit(1);
  }
  return file;
}

/*_6_8		Input functions=========================================*/

/*=BinaryQuestion!================
*/
I BinaryQuestion(I i_message)
{
  C c[2];
  get_symbol:
  PutMessage(i_message);
  scanf("%1s", c);
#if !defined(GAP)
  fputc(c[0], SessionFile);
#endif
  switch(c[0])
  {
    case 'y': case 'Y': case '\n':
      return YES;
    case 'n': case 'N':
      break;
    case 'c': case 'C':
      Error(E_CANCEL_PROGRAM);
    default:
      goto get_symbol;
  }
  return NO;
}
/*=FindNameInTable==============================================
 Find name from string in table ...NameIn
*/
I FindNameInTable(S name, S nametab, I n_nametab)
{
  S w_nametab, w_name;
  I j = 0;
  while(j < n_nametab)
  {
    w_nametab = nametab;
    w_name = name;
    while(YES)
    {
      if(*w_nametab == '\0')              /* Table name ended */
      {
        if(!isalnum(*w_name) && *w_name != SUBSCRIPT_INPUT_SIGN)
          goto out;                      /* String name ended */
        break;
      }                                 /* Table name goes on */
      if(!isalnum(*w_name) && *w_name != SUBSCRIPT_INPUT_SIGN)
        break;                           /* String name ended */
      if(*w_nametab != *w_name)
        break;                             /* Different names */
      w_nametab++;
      w_name++;
    }
    nametab += NameLength1;
    ++j;
  }
  out:
  return j;
}
/*=GetGenerator===========================================================
 Read single generator from description string
*/
V GetGenerator(S str)
{
  S name = GeneratorName + GeneratorN*NameLength1;
  if(GeneratorN == GeneratorMaxN)
    Error(E_GENERATOR_MAX_N);
  do
  {
    if(*str == ODD_GENERATOR_INPUT_SIGN)        /* EVEN == 0 is assumed */
      LIE_MONOMIAL_PARITY(GeneratorN) = ODD;
    else
      *(name++) = *str;
  }while(*(str++));
  LIE_MONOMIAL_ORDER(GeneratorN) =                 /* Standard settings */
  LIE_MONOMIAL_POSITION(GeneratorN) = GeneratorN;
  LIE_MONOMIAL_RIGHT(GeneratorN) = 1; /* To avoid SQUARE interpretation */
  LIE_MONOMIAL_WEIGHT(GeneratorN++) = 1;
}
/*=GetInput===============================================================
*/
V GetInput(I n, S fin)
{
  S instr, sfname, in_case[N_INPUT_CASES];
  FILE *inf;
  U i, j;

  in_case[GENERATORS]      = "G";
  in_case[LIMITING_WEIGHT] = "L";
  in_case[PARAMETERS]      = "P";
  in_case[RELATIONS]       = "R";
  in_case[WEIGHTS]         = "W";

  sfname = OutLine + PosOutLine;
  if(n == 1)      /* No input file at call */
  {
    PutMessage(H_ENTER_FILE);
    gets(sfname);
  }
  else
    do
      *(sfname++) = *fin;
    while(*(fin++));
  sfname = OutLine;
  while(YES)
  {
    if(*sfname == '.')
      break;
    if(*sfname == '\0')
    {
      *sfname = '.';
      *++sfname = 'i';
      *++sfname = 'n';
      *++sfname = '\0';
      break;
    }
    ++sfname;
  }
  /*
  PutMessage(H_INPUT_FILE);
  PutStringStandard(OutLine);
  */
#if defined(SPP_2000)
  if((inf = fopen(OutLine, "r")) == NULL)
#else
  if((inf = fopen(OutLine, "rt")) == NULL)
#endif
  {	/* New file */
    if(!BinaryQuestion(H_CREATE_NEW_FILE))
      exit(1);
    instr = (S)alloca(InputStringSize);
    if(instr == NULL)
      Error(E_A_STACK_INPUT_STRING);
    fgetc(stdin);
#if defined(SPP_2000)
    inf = OpenFile(OutLine, "w");
#else
    inf = OpenFile(OutLine, "wt");
#endif
    KeyBoardStringToFile(H_ENTER_GENERATORS, "Generators: ", instr, inf);
    KeyBoardStringToFile(H_ENTER_WEIGHTS_IN_FILE, "Weights: ", instr, inf);
    KeyBoardStringToFile(H_ENTER_LIMITING_WEIGHT, "Limiting weight: ",
                                                               instr, inf);
    KeyBoardStringToFile(H_ENTER_PARAMETERS, "Parameters: ", instr, inf);
    if(KeyBoardStringToFile(H_ENTER_RELATIONS, "Relations:\n", instr, inf))
    {
      n = YES; /* Now non-last */
      while(n && (j = KeyBoardBytesToString(instr)) > 0)
        for(i = 0; i <= j; i++)
        {
          if(instr[i] == '.')
            n = NO;             /* Last input */
          fputc(instr[i], inf); /* Copy entered string to file */
        }
    }
    fclose(inf);
#if defined(SPP_2000)
    inf = OpenFile(OutLine, "r");
#else
    inf = OpenFile(OutLine, "rt");
#endif
  }
  if(EchoInput)
  {
    SHI c;
    PutMessage(H_SHOW_INPUT);
    while((c = fgetc(inf)) != EOF)
      PutCharacter((C)c);
  }
  rewind(inf);
  while(YES)
    switch(ReadCaseFromFile(inf, in_case, N_INPUT_CASES))
    {
      case GENERATORS:
        ReadAndProcessStringsFromFile(GetGenerator, inf, ' ', ';');
        CUT_ARRAY(GeneratorName, C, NameLength1*GeneratorN);
        LieMonomialFreePosition = LieMonomialN = GeneratorN;
#if defined(SPACE_STATISTICS)
        LieMonomialMaxN = LieMonomialN;
#endif
      break;
      case WEIGHTS:    /* Should come after generators */
        GeneratorMaxN = GeneratorN;
        GeneratorN = 0;
        ReadAndProcessStringsFromFile(GetWeight, inf, ' ', ';');
        GeneratorN = GeneratorMaxN;

        /* Reorder generators in accordance with new weights */

        i = 1;
        while(i < (U)GeneratorN)
        {
          for(j = GeneratorN - 1; j >= i; j--)
            if(LIE_MONOMIAL_WEIGHT(j-1) > LIE_MONOMIAL_WEIGHT(j))
            {
              CU wt;       /* To save swapped walues */

              /* Swap generator names */

              fin = GeneratorName + j*NameLength1; /* Next name */
              instr = fin - NameLength1;           /* Previous name */
              for(n = 1; n < NameLength1; n++)
              {
                wt = *instr;
                *(instr++) = *fin;
                *(fin++) = wt;
              }

              /* Swap weights */

              wt = LIE_MONOMIAL_WEIGHT(j-1);
              LIE_MONOMIAL_WEIGHT(j-1) = LIE_MONOMIAL_WEIGHT(j);
              LIE_MONOMIAL_WEIGHT(j) = wt;

              /* Swap parities */

              wt = LIE_MONOMIAL_PARITY(j-1);
              LIE_MONOMIAL_PARITY(j-1) = LIE_MONOMIAL_PARITY(j);
              LIE_MONOMIAL_PARITY(j) = wt;
            }
          i++;
        }
      break;
      case PARAMETERS:
        IsParametric = YES;
        LieLikeTermsCollection = LieLikeTermsCollectionParametric;
        LieSumCopy = LieSumCopyParametric;
        LieSumKill = LieSumKillParametric;
        LieSumMinus = LieSumMinusParametric;
        NormalizeRelation = NormalizeRelationParametric;
        LieTermFromMonomial = LieTermFromMonomialParametric;
        PairMonomialMonomial = PairMonomialMonomialParametric;
        PairMonomialSum = PairMonomialSumParametric;
        PairSumMonomial = PairSumMonomialParametric;
        PairSumSum = PairSumSumParametric;
        SubstituteRelationInRelation =
                            SubstituteRelationInRelationParametric;
        ParameterName = (S)NewArray(NameLength1*ParameterMaxN,
                                    sizeof(C), E_A_PARAMETER_NAME);
        ParameterName[0] = 'i';         /* Obligatory imaginary unit */
        ParameterN = 1;
        ReadAndProcessStringsFromFile(GetParameter, inf, ' ', ';');
        CUT_ARRAY(ParameterName, C, NameLength1*ParameterN);
        NodeST =
          (NODE_ST*)NewArray(NodeSTSize, sizeof(NODE_ST), E_A_NODE_ST);
        i = 1;
        j = 2;
        while(j < NodeSTSize)     /* Install NodeST for scalar terms */
          SCALAR_TERM_R(i++) = j++;
#if defined(SPACE_STATISTICS)
        SCALAR_TERM_R(i) = NOTHING;
#else
        SCALAR_TERM_R(i) = NIL;
#endif
        NodeSF =
          (NODE_SF*)NewArray(NodeSFSize, sizeof(NODE_SF), E_A_NODE_SF);
        i = 1;
        j = 2;
        while(j < NodeSFSize)   /* Install NodeSF for scalar factors */
          SCALAR_FACTOR_R(i++) = j++;
#if defined(SPACE_STATISTICS)
        SCALAR_FACTOR_R(i) = NOTHING;
#else
        SCALAR_FACTOR_R(i) = NIL;
#endif
      break;
      case RELATIONS:
        if(!IsParametric)
          NonZeroCoefficientsPut = NO;
        ReadAndProcessStringsFromFile(GetRelation, inf, ';', '.');
      break;
      case LIMITING_WEIGHT:
        LimitingWeight = ReadDecimalFromFile(inf);
        while(fgetc(inf) != '\n')                 /* Go to next line */
          ;
      break;
      case EOF:
        goto out;
      default:
        Error(E_WRONG_INPUT_CASE);
    }
  out:
  fclose(inf);
  if(LimitingWeight == 0)
  {
    PutMessage(H_ENTER_LIMITING_WEIGHT);
    scanf("%d", &LimitingWeight);
#if !defined(GAP)
    fprintf(SessionFile, "%d\n", LimitingWeight);
#endif
  }
  TIME_ON;  /* First start of time */
}
/*=GetInteger===========================================================
 Read big integer with shift in string.
 A is already allocated array of LIMBs A[].
*/
V GetInteger(INT a, S *pstr)
{
  INT w;
  I i;
  LIMB digit[2], ten[2];
  digit[0] = ten[0] = 1;
  ten[1] = 10;
  INTEGER_STACK_NEW(w, InputIntegerSize);
  while(**pstr == '0')	/* Skip leading zeros */
    ++*pstr;
  if(isdigit(**pstr))
  {                     /* First digit: IntegerProduct does not eat 0 */
    a[0] = 1;
    a[1] = (LIMB)(**pstr - '0');
    while(isdigit(*(++*pstr)))
    {
      IntegerProduct(w, a, ten);                              /* a*10 */
      i = w[0];
      while(i >= 0)
        a[i--] = w[i];                                 /* Copy w to a */
      if((digit[1] = (LIMB)(**pstr - '0')) != 0)
        IntegerSum(a, a, digit);                      /* a*10 + digit */
    }
  }
  else        /* Caller interprets absence as  */
    a[0] = 0; /* 1 (or 0) depending on context */
}
/*=GetLieMonomial=========================================================
 Read monomial from string with transformations and substitutions
*/
U GetLieMonomial(S *pstr)
{
  I mon;
  U a;
IN_GET_LIE_MONOMIAL   /*------------------------------------------------*/
  if(isalpha(**pstr))
    if((mon=FindNameInTable(*pstr,GeneratorName,GeneratorN)) < GeneratorN)
    {
      INT num;
      SkipName(pstr);
      SkipSpaces(pstr);
      a = NodeLTNew();
      LIE_TERM_MONOMIAL(a) = mon;
      INTEGER_HEAP_NEW(num, 2);     /* Make integer 1 */
      num[0] = num[1] = 1;
      if(IsParametric)
      {
        U st = NodeSTNew();
        SCALAR_TERM_MONOMIAL(st) = NIL;
        SCALAR_TERM_NUMERATOR(st) = num;
        LIE_TERM_NUMERATOR_SCALAR_SUM(a) = st;
        LIE_TERM_DENOMINATOR_SCALAR_SUM(a) = NIL;
      }
      else
      {
        LIE_TERM_NUMERATOR_INTEGER(a) = num;
        LIE_TERM_DENOMINATOR_INTEGER(a) = NULL;
      }
    }
    else
      Error(E_UNDECLARED_GENERATOR);
  else if(**pstr == '[')
  {
    U b;
    SkipSpaces(pstr);
    ++*pstr;
    a = GetLieMonomial(pstr);
    SkipSpaces(pstr);
    if(**pstr != ',')
      Error(E_NO_COMMUTATOR_COMMA);
    ++*pstr;
    SkipSpaces(pstr);
    b = GetLieMonomial(pstr);
    SkipSpaces(pstr);
    if(**pstr != ']')
      Error(E_NO_COMMUTATOR_BRACKET);
    ++*pstr;
    a = (*PairSumSum)(a, b);
  }
  else
    Error(E_INVALID_CHARACTER);
OUT_GET_LIE_MONOMIAL  /*------------------------------------------------*/
  return a;
}
/*=GetLieSum=====================================================
 Read Lie expression from string and make internal representation
*/
U GetLieSum(S *pstr)
{
  U lsum, term;
  I sign = PLUS;
IN_GET_LIE_SUM   /*--------------------------------------------*/
  SkipSpaces(pstr);
  if(**pstr == '-')
  {
    sign = MINUS;
    ++*pstr;
    SkipSpaces(pstr);
  }
  lsum = GetLieTerm(pstr);
  SkipSpaces(pstr);
  if(sign)
    LieSumMinus(lsum);
  while(**pstr == '+' || **pstr == '-')
  {
    sign = (**pstr == '+') ? PLUS : MINUS;
    ++*pstr;
    SkipSpaces(pstr);
    term = GetLieTerm(pstr);
    SkipSpaces(pstr);
    if(sign)
      LieSumMinus(term);
    lsum = LieSumAddition(lsum, term);
  }
OUT_GET_LIE_SUM  /*--------------------------------------------*/
  return lsum;
}
/*=GetLieTerm===========================================================
*/
U GetLieTerm(S *pstr)
{
  U lterm;
IN_GET_LIE_TERM   /*--------------------------------------------------*/
  if(IsParametric)
  {
    U num = GetScalarSum(pstr),
       den = NIL;
    SkipSpaces(pstr);
    if(**pstr == '/')
    {
      ++*pstr;
      SkipSpaces(pstr);
      den = GetScalarSum(pstr);
      ScalarSumCancellation(&num, &den);
    }
    lterm = GetLieMonomial(pstr);    /* May be sum with generic coeffs */
    if(den != NIL)
      LieSumDivScalarSum(lterm, den);
    LieSumMultScalarSum(lterm, num);
  }
  else
  {
    INT num, den;
    INTEGER_STACK_NEW(num, InputIntegerSize);
    INTEGER_STACK_NEW(den, InputIntegerSize);
    GetInteger(num, pstr);
    den[0] = 0;
    SkipSpaces(pstr);
    if(**pstr == '/')
    {
      ++*pstr;
      SkipSpaces(pstr);
      GetInteger(den, pstr);
      SkipSpaces(pstr);
      IntegerCancellation(num, den);
    }
    lterm = GetLieMonomial(pstr);    /* May be sum with generic coeffs */
    if(den[0] != 0 && (den[0] != 1 || den[1] != 1))
      LieSumDivInteger(lterm, den);
    if(num[0] != 0 &&
       (INTEGER_IS_NEGATIVE(num) || num[0] != 1 || num[1] != 1))
      LieSumMultInteger(lterm, num);
  }
OUT_GET_LIE_TERM  /*--------------------------------------------------*/
  return lterm;
}
/*=GetUInteger====================================
 Read with shift long unsigned integer from string
*/
U GetUInteger(S *pstr)
{
  U i = 0;
  while(isdigit(**pstr))
  {
    i = i*10 + **pstr - '0';
    ++*pstr;
  }
  return i;
}
/*=GetParameter=====================================================
 Read single parameter from description string
*/
V GetParameter(S str)
{
  if(str[0] != 'i' || str[1] != '\0') /* Skip already settled `i' */
  {
    S name = ParameterName + ParameterN*NameLength1;
    if(ParameterN == ParameterMaxN)
      Error(E_PARAMETER_MAX_N);
    do
      *(name++) = *str;
    while(*(str++));
    ++ParameterN;
  }
}
/*=GetRelation===============================================================
 Read single relation from string, reduce and set in array
*/
V GetRelation(S str)
{
  U a;
  if(str[0] != '\0' && (a = GetLieSum(&str)) != NIL)
  {
    I lmonpos, pos, i, l;
    if(RelationN + 1 == RelationSize)
      Error(E_RELATION_SIZE);
    (*NormalizeRelation)(a);
    lmonpos = LIE_TERM_MONOMIAL(a);
    i = LIE_MONOMIAL_ORDER(lmonpos);
    l = FindNewPositionInRelation(i);
    LIE_MONOMIAL_INDEX(lmonpos) = ~l;  /* Set I of relation in LieMonomial */
    while(++i < LieMonomialN)     /* Shift I's of relations in LieMonomial */
      if(LIE_MONOMIAL_IS_LEADING(pos = LIE_MONOMIAL_POSITION(i)))
        --LIE_MONOMIAL_INDEX(pos);
    for(i = RelationN; i > l; i--) /* Make room moving Relation structures */
      Relation[i] = Relation[i-1];
    RELATION_MIN_GENERATOR(l) = LIE_MONOMIAL_IS_GENERATOR(lmonpos) ?
            GeneratorN /* Don't differentiate leading generator */ : 0;
    RELATION_LIE_SUM(l) = a;
    RELATION_TO_BE_SUBSTITUTED(l) = (CU)(l < RelationN);
    ++RelationN;
#if defined(SPACE_STATISTICS)
    if(RelationN > MaxNRelation)
      MaxNRelation = RelationN;
#endif
    ReduceRelations(l);
  }
}
/*=GetScalarSum==================================================
*/
U GetScalarSum(S *pstr)
{
  U a, term;
  I is_par, is_negative;
  if(**pstr == '(')
  {
    is_par = YES;
    ++*pstr;
    SkipSpaces(pstr);
  }
  else
    is_par = NO;
  if(**pstr == '-')
  {
    is_negative = YES;
    ++*pstr;
    SkipSpaces(pstr);
  }
  else
    is_negative = NO;
  a = GetScalarTerm(pstr);
  if(is_negative)
    ScalarSumMinus(a);
  while(**pstr == '+' || **pstr == '-')
  {
    is_negative = (**pstr == '+') ? NO : YES;
    ++*pstr;
    SkipSpaces(pstr);
    term = GetScalarTerm(pstr);
    if(is_negative)
      ScalarSumMinus(term);
    a = ScalarSumAddition(a, term);
  }
  if(is_par)
  {
    if(**pstr != ')')
      Error(E_NO_R_PARENTHESIS);
    ++*pstr;
    SkipSpaces(pstr);
  }
  return a;
}
/*=GetScalarTerm=========================================================
 Read unsigned scalar term in Parametric regime
*/
U GetScalarTerm(S *pstr)
{
  INT nums, numh;
  I i, change_sign;
  U m, f, a = NodeSTNew();

  /* Read numerical coefficient */

  INTEGER_STACK_NEW(nums, InputIntegerSize);
  GetInteger(nums, pstr);
  if(nums[0] == 0)
    nums[0] = nums[1] = 1;
  INTEGER_HEAP_COPY(numh, nums, i);
  SCALAR_TERM_NUMERATOR(a) = numh;

  /* Read scalar monomial */

  SkipSpaces(pstr);
  m = NIL;
  while(isalpha(**pstr) &&
        (i=FindNameInTable(*pstr,ParameterName,ParameterN)) < ParameterN)
  {
    f = NodeSFNew();
    SCALAR_FACTOR_PARAMETER(f) = i;
    SkipName(pstr);
    SkipSpaces(pstr);
    if(**pstr == '^')
    {
      ++*pstr;
      SkipSpaces(pstr);
      if(isdigit(**pstr))
      {
        i = (CU)GetUInteger(pstr);                   /* Read degree */
        SkipSpaces(pstr);
      }
      else
        Error(E_NO_GENERAL_POWER);
    }
    else
      i = 1;
    SCALAR_FACTOR_DEGREE(f) = i;                /* Degree of parameter */
    m = ScalarMonomialMultiplication(&change_sign, m, f);
    if(change_sign)
      SCALAR_TERM_MINUS(a);
  }
  SCALAR_TERM_MONOMIAL(a) = m;
  return a;
}
/*=GetWeight=================================================
 Read single generator weight from description string
*/
V GetWeight(S str)
{
  if(GeneratorN == GeneratorMaxN)
    Error(E_TOO_MUCH_INPUT_WEIGHTS);
  if(!isdigit(*str))
    Error(E_NON_NUM_INPUT_WEIGHT);
  LIE_MONOMIAL_WEIGHT(GeneratorN++) = (CU)GetUInteger(&str);
}
/*=KeyBoardBytesToString=====================
  Returns 0 for the last input (ended by '.')
  and last position otherwise
*/
I KeyBoardBytesToString(S str)
{
  C c;
  I inspace = YES, i = -1;
  while((c = fgetc(stdin)) != '\n')
  {
    if(c == ' ')
    {
      if(inspace)
        continue;     /* Skip extra blanks */
      inspace = YES;
    }
    else
      inspace = NO;
    PutCharacter(c);
    if(c == '\b')
    {
#if !defined(GAP)
       fseek(SessionFile, -2, SEEK_CUR);
#endif
       --i;
    }
    else
    {
      if(++i == InputStringSize)
        Error(E_INPUT_STRING_SIZE);
      str[i] = c;
    }
  }
  putchar('\n');
  if(i < 0)  		    /* Empty input */
    return 0;
  if(str[i] != ';' && str[i] != '.')
  {          /* Add semicolon if necessary */
    if(++i == InputStringSize)
      Error(E_INPUT_STRING_SIZE);
    str[i] = ';';
  }
  if(++i == InputStringSize)
    Error(E_INPUT_STRING_SIZE);
  str[i] = '\n';         /* Go to new line */
  return i;
}
/*=KeyBoardStringToFile==========================================
 Add string from keyboard to file between prefix and semicolon
*/
I KeyBoardStringToFile(I i_m, S prefix, S str, FILE *file)
{
  SHI itop;
  PutMessage(i_m);
  itop = KeyBoardBytesToString(str);
  if(itop)
  {
    SHI i = 0;
    while(*prefix)
      fputc(*(prefix++), file);	/* Copy prefix to file */
    while(i <= itop)
      fputc(str[i++], file);	/* Copy entered string to file */
  }
  return itop;
}
/*=ReadAndProcessStringsFromFile==================================
 Read array of strings separated by `sep' and ended with `end'
 Remove comments and unnecessary spaces
 Add ending '\0'   Process strings by (*proc_func)
*/
V ReadAndProcessStringsFromFile(V (*proc_func)(S str), FILE *inf,
                                                     C sep, C end)
{
  S str, wstr;
  C line_break;
  SHI c;
  I i;
  str = (S)alloca(InputStringSize);
  if(str == NULL)
    Error(E_A_STACK_INPUT_STRING);
  line_break = (sep == ' ') ? '\n' : '\0';
  wstr = str;
  i = 0;       /* Count number of characters */
  while(YES)
  {
    if((c = fgetc(inf)) == sep || c == line_break || c == end)
    {
      if(wstr != str && wstr[-1] == ' ')
        wstr[-1] = '\0';         /* Kill ending blank */
      else
        *wstr = '\0';
      (*proc_func)(str);         /* Process string */
      if(c == end)               /* Last */
        break;
      wstr = str;                /* Intermediate */
      i = 0;                     /* Count number of characters */
      while((c = SkipSpacesInFile(inf)) == LEFT_COMMENT)
        SkipCommentInFile(inf);
      if(c == EOF)
        break;
      continue;
    }
    if(isspace(c))
    {
      if(++i == InputStringSize)
        Error(E_INPUT_STRING_SIZE);
      *(wstr++) = ' ';
      SkipSpacesInFile(inf);
      continue;
    }
    if(c == LEFT_COMMENT)
    {
      if(*wstr != ' ')
      {
        if(++i == InputStringSize)
          Error(E_INPUT_STRING_SIZE);
        *(wstr++) = ' ';
      }
      do
        SkipCommentInFile(inf);
      while((c = SkipSpacesInFile(inf)) == LEFT_COMMENT);
      continue;
    }
    if(++i == InputStringSize)
      Error(E_INPUT_STRING_SIZE);
    *(wstr++) = (C)c;
  }
}
/*=ReadBooleanFromFile========================
  Read boolean constant from file
*/
I ReadBooleanFromFile(FILE *file)
{
  SHI c;
  I bool;
  c = fgetc(file);
  switch(c)
  {
    case 'Y': case 'y':
    bool = YES;
    break;
    case 'N': case 'n':
    bool = NO;
    break;
  }
  while(!isspace(c = fgetc(file)) && c != EOF)
    ;
  ungetc(c, file);
  return bool;
}
/*=ReadCaseFromFile=====================================
*/
I ReadCaseFromFile(FILE * file, S case_str[], I n_cases)
{
  C file_str[CASE_STRING_SIZE];
  S w_file_str, w_case_str;
  I i_case;
  SHI c;
  while(SkipSpacesInFile(file) == LEFT_COMMENT)
    SkipCommentInFile(file);

  /* Read string ending with : from file */

  w_file_str = file_str;
  do
  {
    if((c = fgetc(file)) == EOF)
    {
      i_case = c;
      goto out;
    }
    if(c == ':')
      c = '\0';
    *(w_file_str++) = (C)c;
  }while(c);

  /* Compare strings */

  i_case = 0;
  do
  {
    w_file_str = file_str;
    w_case_str = case_str[i_case];
    do
    {
      if(*w_case_str == '\0')  /* Case is found */
      {
        while(SkipSpacesInFile(file) == LEFT_COMMENT)
          SkipCommentInFile(file);
        goto out;
      }
      if(*w_file_str == '\0')
        break;
    }while(*(w_file_str++) == *(w_case_str++));
  }while(++i_case < n_cases);
  out:
  return i_case;
}
/*=ReadDecimalFromFile===================
  Read unsigned decimal integer from file
*/
U ReadDecimalFromFile(FILE *file)
{
  SHI c;
  U i = 0;
  while(isdigit(c = fgetc(file)))
    i = i*10 + c - '0';
  ungetc(c, file);
  return i;
}
/*=ReadStringFromFile====================
*/
SHI ReadStringFromFile(S str, FILE *file)
{
  SHI c;
  while((c = fgetc(file)) != '\n')
  {
    if(c == LEFT_COMMENT)
    {
      ungetc(c, file);
      break;
    }
    if(c == EOF)
      break;
    if(!isspace(c))
      *(str++) = (C)c;
  }
  return c;
}
/*=SkipCommentInFile=======================
*/
SHI SkipCommentInFile(FILE *file)
{
  SHI c;
  while((c = fgetc(file)) != RIGHT_COMMENT)
    if(c == EOF)
      Error(E_UNEXPECTED_EOF);
  return c;
}
/*=SkipName===============================================
*/
V SkipName(S *pstr)
{
  while(isalnum(**pstr) || **pstr == SUBSCRIPT_INPUT_SIGN)
    ++*pstr;
}
/*=SkipSpaces==================
 Skip spaces to right in string
*/
V SkipSpaces(S *pstr)
{
  while(isspace(**pstr))
    ++*pstr;
}
/*=SkipSpacesInFile==============
  Returns first non-space symbol
*/
SHI SkipSpacesInFile(FILE *file)
{
  SHI c;
  while(isspace(c = fgetc(file)))
    ;
  ungetc(c, file);
  return c;
}

/*_6_9          Output functions========================================*/

/*=AddSymbolToOutLine!===============
 Add symbol to output line OutLine
*/
V AddSymbolToOutLine(C c, I position)
{
  if(position >= OutLineSize)
    Error(E_OUT_LINE_SIZE);
  OutLine[position] = c;
}
/*=InLineLevel==============================
 Install level in OutLine
*/
V InLineLevel(I level)
{
  if(level != CurrentLevel)
  {
    AddSymbolToOutLine(LEVEL, ++PosOutLine);
    AddSymbolToOutLine((C)level, ++PosOutLine);
    CurrentLevel = level;
    if(level > MaxLevel)
      MaxLevel = level;
    else if(level < MinLevel)
      MinLevel = level;
  }
}
/*=InLineNumberInBrackets=====
 (With 2 blanks after)
*/
V InLineNumberInBrackets(U n)
{
  InLineSymbol('(');
  InLineString(UToString(n));
  InLineString(")  ");
}
/*=InLineString!================================
 Add string to output line OutLine for 2D output
*/
V InLineString(S str)
{
  while(*str)
    InLineSymbol(*(str++));
}
/*=InLineSubscript================
 Add symbolic subscript to OutLine
*/
V InLineSubscript(S s)
{
  I level = CurrentLevel;
  InLineLevel(level - 1);
  InLineString(s);
  InLineLevel(level);
}
/*=InLineSymbol!================================
 Add symbol to output line OutLine for 2D output
*/
V InLineSymbol(C symbol)
{
  AddSymbolToOutLine(symbol, ++PosOutLine);
  ++LastItemEnd;
}
/*=InLineTableName===================
 Possibly subscripted
*/
V InLineTableName(S name)
{
  PreviousEnd = LastItemEnd;
  while(*name)
  {
    if(*name == SUBSCRIPT_INPUT_SIGN)
    {
      InLineSubscript(++name);
      break;
    }
    InLineSymbol(*(name++));
  }
}
/*=UToString!====================================
 Transform unsigned long number to decimal string
*/
S UToString(U n)
{                            /*12345678910*/
  static C decimal_string[] = "4294967295";
  S first = decimal_string + 10;
  do
  {
    *--first = '0' + (C)(n % 10);
    n /= 10;
  }while(n);
  return first;
}
/*=PutBasis============================================
 Set index numbers and print basis elements
*/
V PutBasis(V)
{
  I pos, ord;
  U  i = 0;      /* Index number of basis element */
  TIME_OFF;
  if(BasisElementsPut)
    PutMessage(H_BASIS_ELEMENTS);
  for(ord = 0; ord < LieMonomialN; ord++)
  {
    pos = LIE_MONOMIAL_POSITION(ord);
    if(LIE_MONOMIAL_IS_BASIS(pos))
    {
      LIE_MONOMIAL_INDEX(pos) = ++i;
      if(BasisElementsPut)
      {
        PutStart();
        InLineNumberInBrackets(i);
        PutLieBasisElement(pos);
        InLineString(" = ");
        IN_LINE_MARGIN;
        (*PutLieMonomial)(pos);
        PutEnd();
      }
    }
  }
  if(BasisElementsPut)
    if(IncompletedBasis)
      PutDots();
  TIME_ON;
}
#if defined(GAP)
/*=PutBasisGAP=============================================

 Print basis elements into GAP file
*/
V PutBasisGAP(V)
{
  I pos, ord, tord;
  tord = LieMonomialN - 1;
  while(YES)
  {
    if(LIE_MONOMIAL_IS_BASIS(LIE_MONOMIAL_POSITION(tord)))
      break;
    --tord;
  }
  PutStringStandard(GAPBasisName);
  PutStringStandard(":=[\n");
  for(ord = 0; ord <= tord; ord++)
  {
    pos = LIE_MONOMIAL_POSITION(ord);
    if(LIE_MONOMIAL_IS_BASIS(pos))
    {
      PosOutLine = -1;
      PutLieMonomialGAP(pos);
      if(ord < tord)
        PutStringGAP(",\n");
    }
  }
  PutStringStandard("\n];\n");
}
#endif
/*=PutBlock==============================================================
 Print block of 2D output
*/
V PutBlock(V)
{
  if(!PrintEnd && (LastItemEnd > LineLength || PreviousEnd==LastItemEnd))
    PrintEnd = PreviousEnd;
  if(PrintEnd && CurrentLevel <= MAIN_LEVEL)
  {
    I xp, yp = MaxLevel, i, prlvl;
    while(yp >= MinLevel)
    {
      for(xp = 1; xp <= Margin; xp++)
        PutCharacter(' ');
      i = 0;
      while(xp <= PrintEnd)
      {
        switch(OutLine[i])
        {
          case LEVEL:
            prlvl = OutLine[++i];
            break;
          case MARGIN:
            NewMargin = xp - 1;
            break;
          default:
            PutCharacter((C)((prlvl == yp) ? OutLine[i] : ' '));
            xp++;
        }
        i++;
      }
      PutCharacter('\n');
      yp--;
    }
    PutCharacter('\n'); /* To next line */
    Margin = NewMargin;
    LastItemEnd += Margin - PrintEnd;
    PrintEnd = 0;
    xp = i;
    while(OutLine[xp] != LEVEL)
      xp--;
    *OutLine = LEVEL;
    OutLine[1] = MaxLevel = MinLevel = OutLine[xp + 1];
    xp = PosOutLine;
    PosOutLine = 1;
    while(i <= xp)
    {
      OutLine[++PosOutLine] = OutLine[i];
      if(OutLine[i++] == LEVEL)
        if(OutLine[i] > MaxLevel)
          MaxLevel = OutLine[i];
        else if(OutLine[i] < MinLevel)
          MinLevel = OutLine[i];
    }
  }
}
/*=PutCharacter!=============
   Echoed output of character
*/
V PutCharacter(C c)
{
#if defined(ECHO_TO_SCREEN)
  putc(c, stdout);
#endif
#if !defined(GAP)
  putc(c, SessionFile);
#endif
}
#if defined(GAP)
/*=PutCharacterGAP!======================
   Echoed output of character in GAP file
*/
V PutCharacterGAP(C c)
{
#if defined(ECHO_TO_SCREEN)
  putc(c, stdout);
#endif
/*  putc(c, SessionFile);  */
  PosOutLine++;
}
#endif
/*=PutCoefficientTable=================================
 Print list of non-zero coefficients
*/
V PutCoefficientTable(V)
{
  I i, j = 0, first = YES;
  TIME_OFF;
  if(CoeffParamTable != NULL)
  {
    for(i = FIRST_GENUINE_PARAMETER; i < ParameterN; i++)
      if(CoeffParamTable[i])
      {
        if(first)
        {
          first = NO;
          PutMessage(H_NON_ZERO_COEFFICIENTS);
        }
        PutStart();
        InLineNumberInBrackets(++j);
        InLineTableName(ParameterName + i*NameLength1);
        PutEnd();
      }
    free(CoeffParamTable);
  }
  if(CoeffSumTableN)
  {
    if(first)
    {
      first = NO;
      PutMessage(H_NON_ZERO_COEFFICIENTS);
    }
    for(i = 0; i < CoeffSumTableN; i++)
    {
      PutStart();
      InLineNumberInBrackets(++j);
      IN_LINE_MARGIN;
      PutScalarSum(CoeffSumTable[i]);
      PutEnd();
      ScalarSumKill(CoeffSumTable[i]);
    }
    free(CoeffSumTable);
  }
  TIME_ON;
}
/*=PutCommutators========================================================
 Compute and print commutators of basis elements [E(O),E(O)] -> E(O)
*/
V PutCommutators(V)
{
  I oi, oj, i, j, was_comm, set_minus;
  U icomm, rpart;
  CU weight_j;
  TIME_OFF;
  PutMessage(H_COMMUTATORS);
  TIME_ON;
  icomm = 0;
  for(oj = 0; oj < LieMonomialN; oj++)
    if(LIE_MONOMIAL_IS_BASIS(j = LIE_MONOMIAL_POSITION(oj)))
    {
      weight_j = LIE_MONOMIAL_WEIGHT(j);
      was_comm = NO;
      set_minus = LIE_MONOMIAL_IS_EVEN(j);
      for(oi = 0; oi < oj ||
                  (oi == oj &&
                   LIE_MONOMIAL_IS_ODD(LIE_MONOMIAL_POSITION(oi))); oi++)
        if(weight_j + LIE_MONOMIAL_WEIGHT(i = LIE_MONOMIAL_POSITION(oi))
           <= LimitingWeight)
        {
          if(LIE_MONOMIAL_IS_BASIS(i))
          {
            if(LIE_MONOMIAL_IS_EVEN(i))
              set_minus = YES;
            rpart = (*PairMonomialMonomial)(j, i);
            if(rpart != NIL)
            {
              TIME_OFF;
              PutStart();
              InLineNumberInBrackets(++icomm);
              InLineSymbol('[');
              PutLieBasisElement(i);
              InLineSymbol(',');
              PutLieBasisElement(j);
              InLineString("] = ");
              IN_LINE_MARGIN;
              if(set_minus)
                (*LieSumMinus)(rpart);
              PutLieSum(PutLieBasisElement, rpart);
              LieSumKill(rpart);
              PutEnd();
              TIME_ON;
            }
          }
          was_comm = YES;
        }
        else
        {
          if(was_comm)
          {
            while(oi < oj ||
                 (oi == oj &&
                  LIE_MONOMIAL_IS_ODD(LIE_MONOMIAL_POSITION(oi))))
            {
              if(LIE_MONOMIAL_IS_BASIS(LIE_MONOMIAL_POSITION(oi)))
                ++icomm;
              ++oi;
            }
            TIME_OFF;
            PutDots();
            PutCharacter('\n');
            TIME_ON;
          }
          break;
        }
    }
  TIME_OFF;
  if(icomm == 0)
    PutMessage(H_NO_PUT_COMMUTATORS);
  TIME_ON;
}
#if defined(GAP)
/*=PutCommutatorsGAP==================================
 Transform commutators of ordinary finite-dimensional 
 parameter-free Lie algebra to GAP input format
*/
V PutCommutatorsGAP(V)
{
  I oi, oj, otop, i, j;
  INT num;
  U rpart, a, b;
  otop = LieMonomialN - 1;
  while(YES)
  {
    if(LIE_MONOMIAL_IS_BASIS(LIE_MONOMIAL_POSITION(otop)))
      break;
    --otop;
  }
  PutStringStandard(GAPAlgebraName);
  PutStringStandard(":=[\n");   /* Begin main list */
  for(oj = 0; oj <= otop; oj++)
    if(LIE_MONOMIAL_IS_BASIS(j = LIE_MONOMIAL_POSITION(oj)))
    {
      PosOutLine = -1;
      PutCharacterGAP('[');
      for(oi = 0; oi <= otop; oi++) 
        if(LIE_MONOMIAL_IS_BASIS(i = LIE_MONOMIAL_POSITION(oi)))
        {
          if(oi == oj)
            rpart = NIL;
          else if(oj < oi) 
          {
            rpart = (*PairMonomialMonomial)(i, j);
            (*LieSumMinus)(rpart);
          }
          else
            rpart = (*PairMonomialMonomial)(j, i);
          if(rpart != NIL)
          {
            a = LIE_TERM_R(rpart);     /* Invert list */
            LIE_TERM_R(rpart) = NIL;
            while(a != NIL)
            {
              b = a;
              a = LIE_TERM_R(a);
              LIE_TERM_R(b) = rpart;
              rpart = b; 
            }
            PutStringGAP("[[");
            a = rpart;      /* Put indices of basis elements */
            while(YES)
            {
              PutStringGAP(UToString(LIE_MONOMIAL_INDEX(
                                       LIE_TERM_MONOMIAL(a))));
              a = LIE_TERM_R(a);
              if(a == NIL)
                break;
              PutStringGAP(",");
            }
            PutStringGAP("],[");
            a = rpart;                  /* Put coefficients */
            while(YES)
            {
              num = LIE_TERM_NUMERATOR_INTEGER(a);
              if(INTEGER_IS_NEGATIVE(num))
                PutStringGAP("-");
              PutIntegerUnsignedGAP(num);
              if((num = LIE_TERM_DENOMINATOR_INTEGER(a)) != NULL)
              {
                PutStringGAP("/");
                PutIntegerUnsignedGAP(num);
              }
              a = LIE_TERM_R(a);
              if(a == NIL)
                break;
              PutStringGAP(",");
            }
            PutStringGAP("]]");
            LieSumKill(rpart);
          }
          else
            PutStringGAP("[[],[]]");
          if(oi != otop)
            PutStringGAP(",");
        }
      PutStringGAP("],");
      PutCharacter('\n');
    }
  PutStringStandard("-1,0];\n");  /* Close main list */
}
#endif
/*=PutDegree==========================
 Print (positive) integer degree
*/
V PutDegree(U deg)
{
  if(deg != 1)
  {
    I level = CurrentLevel;
    InLineLevel(level + 1);
    InLineString(UToString((U)deg));
    InLineLevel(level);
    PutBlock();
  }
}
/*=PutDimensions================================================
  Print dimensions of homogeneous components of algebra
*/
V PutDimensions(V)
{
  I next, ord, pos;
  CU   curwt;
  U   dim;
  TIME_OFF;
  PutMessage(H_HILBERT_SERIES);
  PutStart();
  InLineString("H(t) = ");
  IN_LINE_MARGIN;
  next = NO;
  curwt = LIE_MONOMIAL_WEIGHT(0);     /* Start initial weight */
  dim = 0;
  for(ord = 0; ord < LieMonomialN; ord++)
  {
    pos = LIE_MONOMIAL_POSITION(ord);
    if(LIE_MONOMIAL_IS_BASIS(pos))
      if(LIE_MONOMIAL_WEIGHT(pos) != curwt)
      {
        if(dim != 0)
        {
          if(next)
            PutString(" + ");
          else
            next = YES;
          if(dim != 1)
          {
            PutString(UToString(dim));
            PutSymbol(' ');
          }
          PutSymbol('t');
          PutDegree(curwt);
        }
        curwt = LIE_MONOMIAL_WEIGHT(pos); /* Start new weight */
        dim = 1;
      }
      else
        dim++;
  }
  if(dim != 0)   /* Print last element */
  {
    if(next)
      PutString(" + ");
    if(dim != 1)
    {
      PutString(UToString(dim));
      PutSymbol(' ');
    }
    PutSymbol('t');
    PutDegree(curwt);
  }
  if(IncompletedBasis)
    PutString(" + ...");
  PutEnd();
  TIME_ON;
}
/*=PutDots=============================
 Print vertical dots
*/
V PutDots(V)
{
#if defined(ECHO_TO_SCREEN)
  printf(" .\n .\n .\n");
#endif
#if !defined(GAP)
  fprintf(SessionFile, " .\n .\n .\n");
#endif
}
/*=PutEnd=======================
   Print last block of 2D output
*/
V PutEnd(V)
{
  PreviousEnd = LastItemEnd;
  PutBlock();
}
/*=PutFormattedU=================
*/
V PutFormattedU(S format, U i)
{
#if !defined(GAP)
  fprintf(SessionFile, format, i);
#endif
#if defined(ECHO_TO_SCREEN)
  printf(format, i);
#endif
}
/*=PutLieBareTerm=======================================================
 put_lie_mon == PutLieMonomial     -> in terms of generators,
 put_lie_mon == PutLieBasisElement -> in terms of basis elements.
*/
V PutLieBareTerm(V (*put_lie_mon)(I a), U a)
{
  I put_mult_sign = NO;
  if(IsParametric)
  {
    U num = LIE_TERM_NUMERATOR_SCALAR_SUM(a),
      den = LIE_TERM_DENOMINATOR_SCALAR_SUM(a);

    /* Put numerator */

    if(SCALAR_TERM_R(num) != NIL)
    {
      PutSymbol('(');              /* Sum */
      PutScalarSum(num);
      PutSymbol(')');
      put_mult_sign = YES;
    }
    else if(SCALAR_TERM_MONOMIAL(num) != NIL ||
            INTEGER_IS_NOT_UNIT_ABS(SCALAR_TERM_NUMERATOR(num)) ||
            den != NIL)
    {
      PutScalarBareTerm(num);     /* Single term */
      put_mult_sign = YES;
    }

    /* Put denominator */

    if(den != NIL)
    {
      PutSymbol('/');
      if(SCALAR_TERM_R(den) == NIL &&  /* Single factor denominator */
         (SCALAR_TERM_MONOMIAL(den) == NIL ||
          INTEGER_IS_UNIT(SCALAR_TERM_NUMERATOR(den))))
        PutScalarBareTerm(den);
      else
      {
        PutSymbol('(');            /* Sum or multifactor denominator */
        PutScalarSum(den);
        PutSymbol(')');
      }
    }
  }
  else
  {
    INT num = LIE_TERM_NUMERATOR_INTEGER(a),
        den = LIE_TERM_DENOMINATOR_INTEGER(a);
    if(den != NULL)
    {
      PutIntegerUnsigned(num);
      PutSymbol('/');
      PutIntegerUnsigned(den);
      put_mult_sign = YES;
    }
    else if(INTEGER_IS_NOT_UNIT_ABS(num))
    {
      PutIntegerUnsigned(num);
      put_mult_sign = YES;
    }
  }
  if(put_mult_sign)
    PutSymbol(' ');
  (*put_lie_mon)(LIE_TERM_MONOMIAL(a));
}
/*=PutLieBasisElement======================================
 Print Lie monomial in form E  or O
                             i     i
*/
V PutLieBasisElement(I pos)
{
  InLineSymbol((C)(LIE_MONOMIAL_PARITY(pos) ? BasisSymbolOdd :
                                          BasisSymbolEven));
  InLineSubscript(UToString(LIE_MONOMIAL_INDEX(pos)));
  PutBlock();
}
/*=PutLieMonomialLeftNormed=====================================
 Put Lie monomial in terms of generators in left normed notation
*/
V PutLieMonomialLeftNormed(I pos)
{
  if(LIE_MONOMIAL_IS_GENERATOR(pos))
  {
    InLineTableName(GeneratorName + pos*NameLength1);
    PutBlock();
  }
  else
  {
    U deg = 1;
    I posi = LIE_MONOMIAL_LEFT(pos),
      posj = LIE_MONOMIAL_RIGHT(pos), posw;
    while(LIE_MONOMIAL_IS_COMMUTATOR(posi))
    {
      pos = posi;
      posi = LIE_MONOMIAL_LEFT(pos);
      posw = LIE_MONOMIAL_RIGHT(pos);
      if(posj == posw)
        ++deg;
      else
      {
        posi = pos;
        break;
      }
    }
    if(posi != posj)
        PutLieMonomialLeftNormed(posi);
    else
      ++deg;
    if(LIE_MONOMIAL_IS_COMMUTATOR(posj))
    {
      PutSymbol('(');
      PutLieMonomialLeftNormed(posj);
      PutSymbol(')');
    }
    else
      PutLieMonomialLeftNormed(posj);
    PutDegree(deg);
  }
}
/*=PutLieMonomialStandard============================================
 Put Lie monomial in terms of generators in standard bracket notation
*/
V PutLieMonomialStandard(I pos)
{
  if(LIE_MONOMIAL_IS_GENERATOR(pos))
  {
    InLineTableName(GeneratorName + pos*NameLength1);
    PutBlock();
  }
  else
  {
    PutSymbol('[');
    PutLieMonomialStandard(LIE_MONOMIAL_LEFT(pos));
    PutSymbol(',');
    PutLieMonomialStandard(LIE_MONOMIAL_RIGHT(pos));
    PutSymbol(']');
  }
}
#if defined(GAP)
/*=PutLieMonomialGAP============================================
 Put Lie monomial in terms of generators in GAP bracket notation
*/
V PutLieMonomialGAP(I pos)
{
  if(LIE_MONOMIAL_IS_GENERATOR(pos))
    PutStringGAP(UToString(pos+1));
  else
  {
    PutStringGAP("[");
    PutLieMonomialGAP(LIE_MONOMIAL_LEFT(pos));
    PutStringGAP(",");
    PutLieMonomialGAP(LIE_MONOMIAL_RIGHT(pos));
    PutStringGAP("]");
  }
}
#endif
/*=PutLieSum=====================================================
 put_lie_mon == PutLieMonomial     -> in terms of generators,
 put_lie_mon == PutLieBasisElement -> in terms of basis elements
*/
V PutLieSum(V (*put_lie_mon)(I a), U a)
{
  if(a == NIL)
    PutSymbol('0');
  else
  {
    U na;
    I is_negative = NO;
    if(IsParametric)
    {
      na = LIE_TERM_NUMERATOR_SCALAR_SUM(a);
      if(SCALAR_TERM_R(na) == NIL &&
         INTEGER_IS_NEGATIVE(SCALAR_TERM_NUMERATOR(na)))
        is_negative = YES;
    }
    else if(INTEGER_IS_NEGATIVE(LIE_TERM_NUMERATOR_INTEGER(a)))
      is_negative = YES;
    if(is_negative)
      PutString("- ");
    PutLieBareTerm(put_lie_mon, a);
    while((a = LIE_TERM_R(a)) != NIL)
    {
      is_negative = NO;
      if(IsParametric)
      {
        na = LIE_TERM_NUMERATOR_SCALAR_SUM(a);
        if(SCALAR_TERM_R(na) == NIL &&
           INTEGER_IS_NEGATIVE(SCALAR_TERM_NUMERATOR(na)))
          is_negative = YES;
      }
      else if(INTEGER_IS_NEGATIVE(LIE_TERM_NUMERATOR_INTEGER(a)))
        is_negative = YES;
      PutString(is_negative ? " - " : " + ");
      PutLieBareTerm(put_lie_mon, a);
    }
  }
}
/*=PutMessage!=========================
 Put message from MessageFile
*/
V PutMessage(I i_message)
{
#if !defined(GAP)
  static I current_message;
  SHI c;
  if(i_message < current_message)
  {
    rewind(MessageFile);
    current_message = 0;
  }
  while(i_message > current_message)
    if((c = fgetc(MessageFile)) == '$')
      ++current_message;
    else if(c == EOF)
      Error(E_MESSAGE);
  while(YES)
  {
    c = fgetc(MessageFile);
    if(c == '$')
    {
      ++current_message;
      return;
    }
    PutCharacter((C)c);
  }
#endif
}
/*=PutRelations====================================
 Print list of relations
*/
V PutRelations(I msg)
{
  I i;
  TIME_OFF;
  PutMessage(msg);
  for(i = 0; i < RelationN; i++)
  {
    PutStart();
    InLineNumberInBrackets(i+1);
    IN_LINE_MARGIN;
    PutLieSum(PutLieMonomial, RELATION_LIE_SUM(i));
    InLineString(" = 0");
    PutEnd();
  }
  if(IncompletedRelations)
    PutDots();
  TIME_ON;
}
#if defined(GAP)
/*=PutRelationsGAP=================================
*/
V PutRelationsGAP(V)
{
  I i;
  INT num;
  U a;
  PutStringStandard(GAPRelationsName);
  PutStringStandard(":=[\n");   /* Begin main list */
  for(i = 0; i < RelationN; i++)
  {
    a = RELATION_LIE_SUM(i);
    PosOutLine = -1;
    PutCharacterGAP('[');
    while(YES)
    {
      PutLieMonomialGAP(LIE_TERM_MONOMIAL(a));
      PutStringGAP(",");
      num = LIE_TERM_NUMERATOR_INTEGER(a);
      if(INTEGER_IS_NEGATIVE(num))
        PutStringGAP("-");
      PutIntegerUnsignedGAP(num);
      if((a = LIE_TERM_R(a)) == NIL)
        break;
      PutStringGAP(",");
    }
    PutStringGAP("]");
    if(i < RelationN - 1)
      PutStringGAP(",\n");
  }
  PutStringStandard("\n];\n");
}
#endif
/*=PutScalarBareTerm===============================
 Intermediate print of unsigned scalar term
*/
V PutScalarBareTerm(U a)
{
  I put_1 = YES;

  /* Put integer coefficient */

  if(INTEGER_IS_NOT_UNIT_ABS(SCALAR_TERM_NUMERATOR(a)))
  {
    PutIntegerUnsigned(SCALAR_TERM_NUMERATOR(a));
    put_1 = NO;
  }

  /* Put scalar monomial */

  a = SCALAR_TERM_MONOMIAL(a); /* U - U mixing */
  if(a != NIL)
  {
    if(put_1 == NO)
        PutSymbol(' ');
    PutScalarFactor(a);
    while((a = SCALAR_FACTOR_R(a)) != NIL)
    {
      PutSymbol(' ');
      PutScalarFactor(a);
    }
    put_1 = NO;
  }
  if(put_1)         /* Nothing's been put before */
    PutSymbol('1');
}
/*=PutIntegerUnsigned=============================================
 Print big integer
*/
V PutIntegerUnsigned(INT bn)
{
  INT bnw;
  S decstr;
  LIMB res;
  U lw;
  I i,
    n = INTEGER_N_LIMBS(bn),
    nw = n;
  bnw = (INT)alloca(sizeof(LIMB)*n);
  if(bnw == NULL)
    Error(E_A_STACK_INTEGER); /* LIMB contains 5 decimal digits */
  decstr = (S)alloca(5*n + 1);
  if(decstr == NULL)
    Error(E_A_STACK_INTEGER_DECIMAL_STRING);
  decstr += 5*n;            /* Go to last byte of string */
  for(i = 0; i < n; i++)
    bnw[i] = *(++bn);       /* Copy body of big number */
  /* Transform big number array to decimal string */
  decstr[0] = '\0';
  do
  { /* Divide bnw number in array form by 10 on spot */
    res = 0;
    if(nw)       /* Otherwise 0/n -> 0, 0 mod n -> 0 */
    {
      i = nw;
      do
      {
        lw = (U)res * BASE_LIMB + (U)bnw[--i];
        res = (LIMB)(lw % 10);
        bnw[i] = (LIMB)(lw / 10);
      }while(i);
      if(bnw[nw-1] == 0)
        --nw;
    }
    *--decstr = '0' + res;
  }while(nw);
  if(n < 3)
    PutString(decstr);      /* Don't cut short number */
  else
    do
      PutSymbol(*decstr);
    while(*(++decstr));
}
#if defined(GAP)
/*=PutIntegerUnsignedGAP==========================================
 Print big integer into GAP file
*/
V PutIntegerUnsignedGAP(INT bn)
{
  INT bnw;
  S decstr;
  LIMB res;
  U lw;
  I i,
    n = INTEGER_N_LIMBS(bn),
    nw = n;
  bnw = (INT)alloca(sizeof(LIMB)*n);
  if(bnw == NULL)
    Error(E_A_STACK_INTEGER); /* LIMB contains 5 decimal digits */
  decstr = (S)alloca(5*n + 1);
  if(decstr == NULL)
    Error(E_A_STACK_INTEGER_DECIMAL_STRING);
  decstr += 5*n;            /* Go to last byte of string */
  for(i = 0; i < n; i++)
    bnw[i] = *(++bn);       /* Copy body of big number */
  /* Transform big number array to decimal string */
  decstr[0] = '\0';
  do
  { /* Divide bnw number in array form by 10 on spot */
    res = 0;
    if(nw)       /* Otherwise 0/n -> 0, 0 mod n -> 0 */
    {
      i = nw;
      do
      {
        lw = (U)res * BASE_LIMB + (U)bnw[--i];
        res = (LIMB)(lw % 10);
        bnw[i] = (LIMB)(lw / 10);
      }while(i);
      if(bnw[nw-1] == 0)
        --nw;
    }
    *--decstr = '0' + res;
  }while(nw);
  PutStringGAP(decstr);
}
#endif
/*=PutScalarFactor========================================================
*/
V PutScalarFactor(U a)
{
  InLineTableName(ParameterName + SCALAR_FACTOR_PARAMETER(a)*NameLength1);
  PutDegree(SCALAR_FACTOR_DEGREE(a));
  PutBlock();
}
/*=PutScalarSum================================================
 Intermediate print of scalar sum
*/
V PutScalarSum(U a)
{
  if(a == NIL)
    PutSymbol('0');
  else
  {
    if(INTEGER_IS_NEGATIVE(SCALAR_TERM_NUMERATOR(a)))
      PutString("- ");
    PutScalarBareTerm(a);
    while((a = SCALAR_TERM_R(a)) != NIL)
    {
      PutString(INTEGER_IS_NEGATIVE(SCALAR_TERM_NUMERATOR(a)) ?
                " - " : " + ");
      PutScalarBareTerm(a);
    }
  }
}
/*=PutStart=======================================
 Start of 2dimensional output
*/
V PutStart(V)
{
  LastItemEnd = PrintEnd = Margin = NewMargin = 0;
  AddSymbolToOutLine(LEVEL, 0);
  AddSymbolToOutLine(MAIN_LEVEL, 1);
  PosOutLine = 1;
  CurrentLevel = MaxLevel = MinLevel = MAIN_LEVEL;
}
/*=PutStatistics=========================================================
 Put time and space statistics
*/
V PutStatistics(V)
{
  U sec, min, sec_100,
     time = CrudeTime ? TimeC : (U)(((double)TimeC/CLOCKS_PER_SEC)*100);
  PutStringStandard("Time: ");
  if(!CrudeTime)
  {
    sec_100 = (U)(time%100);
    time /= 100;                /* In seconds */
  }
  sec = (U)(time%60);
  time /= 60;                   /* In minutes */
  min = (U)(time%60);
  time /= 60;                   /* In hours */
  if(time)
    PutFormattedU("%lu h ", time);
  if(min || time)
    PutFormattedU("%lu min ", min);
  if(CrudeTime)
    PutFormattedU("%lu sec\n", sec);
  else
  {
    PutFormattedU("%u.", sec);
    if(sec_100 < 10 && sec_100 > 0)
      PutCharacter('0');
    PutFormattedU("%u sec\n", sec_100);
  }
#if defined(SPACE_STATISTICS)
  PutFormattedU("Number of relations: %14u\n", MaxNRelation);
  PutFormattedU("Number of Lie monomials: %10u\n", LieMonomialMaxN);
  PutFormattedU("Number of Lie terms: %14u\n", NodeLTTopMax - 1);
  if(IsParametric)
  {
    PutFormattedU("Number of scalar terms: %11u\n", NodeSTTopMax - 1);
    min = NodeSFTopMax - 1;
    PutFormattedU("Number of scalar factors:%10u\n", NodeSFTopMax - 1);
  }
#endif
#if defined(INTEGER_MAX_SIZE)
  PutFormattedU("Maximum size of integer in limbs: %5u\n", IntegerMaxSize);
#endif
#if defined(DEBUG)
  PutDebugU("Current Debug", Debug);
#endif
}
/*=PutString================
 2D output of string
*/
V PutString(S str)
{
  PreviousEnd = LastItemEnd;
  InLineString(str);
  PutBlock();
}
#if defined(GAP)
/*=PutStringGAP=======================================================
 Put string in GAP file
*/
V PutStringGAP(S str)
{
  C c = 0;
  while(*str)
  {
     if(PosOutLine == GAP_WIDTH - 2) 
       if(isdigit(*str))         /* Going to write in last position */
       {
         if(isdigit(c))
           PutCharacter('\\');
         PutCharacter('\n');
         PosOutLine = -1;
         PutCharacterGAP(*str); /* Continue number in the next line */
       }
       else
       {
         PutCharacter(*str);
         PutCharacter('\n');
         PosOutLine = -1;                     /* Ready to next line */
       }
     else
       PutCharacterGAP(*str);
     c = *str;                          /* Remember previous symbol */
     ++str;
  }
}
#endif
/*=PutStringStandard==============
*/
V PutStringStandard(S str)
{
#if defined(ECHO_TO_SCREEN)
  printf("%s", str);
#endif
#if !defined(GAP)
  fprintf(SessionFile, "%s", str);
#endif
}
/*=PutSymbol!===============
 2D output of symbol
*/
V PutSymbol(C c)
{
  PreviousEnd = LastItemEnd;
  InLineSymbol(c);
  PutBlock();
}

/*_6_10   Debugging functions===========================================*/

#if defined(DEBUG)
/*=PutDebugHeader====================================================
  Put header of tracing output.
*/
V PutDebugHeader(U debug, S f_name, S in_out)
{
#if !defined(GAP)
  fprintf(SessionFile,"\nDebug==%lu %s %s:\n", debug, f_name, in_out);
#endif
  printf("\nDebug==%lu %s %s\n", debug, f_name, in_out);
}
/*=PutDebugInteger==============
 Put name and signed big number
*/
V PutDebugInteger(S name, INT u)
{
  PutStart();
  InLineString(name);
  InLineString(": ");
  if(INTEGER_IS_NEGATIVE(u))
    InLineSymbol('-');
  PutIntegerUnsigned(u);
  PutEnd();
}
/*=PutDebugLieMonomial==============
  Put name and Lie sum
*/
V PutDebugLieMonomial(S name, I a)
{
  PutStart();
  InLineString(name);
  InLineString(": ");
  (*PutLieMonomial)(a);
  PutEnd();
}
/*=PutDebugLieMonomialTable=================================================
*/
V PutDebugLieMonomialTable(I newmon)
{
  I i, j, count;
  PutStringStandard("LieMonomial table:\n"
               "ORDER POSITION LEFT RIGHT PARITY INDEX WEIGHT MONOMIAL\n");
  i = count = 0;
  while(count < LieMonomialN)
  {
    if(LIE_MONOMIAL_IS_OCCUPIED(i))
    {
      count++;
      PutFormattedU("%5d", LIE_MONOMIAL_ORDER(i));
      PutFormattedU("%9d", i);
      PutFormattedU("%5d", LIE_MONOMIAL_LEFT(i));
      PutFormattedU("%6d", LIE_MONOMIAL_RIGHT(i));
      PutFormattedU("%4d", LIE_MONOMIAL_PARITY(i));
      if((j = LIE_MONOMIAL_INDEX(i)) < 0 )
        PutFormattedU(" Rel %-4d", ~j);
      else
        PutFormattedU("%9d", j);
      PutFormattedU("%7d ", LIE_MONOMIAL_WEIGHT(i));
      if(newmon == i)
        PutStringStandard("New! ");
      PutStart();
      (*PutLieMonomial)(i);
      PutEnd();
    }
    else
      PutFormattedU("Position %d is free!\n", i);
    i++;
  }
}
/*=PutDebugLieSum==============
  Put name and Lie sum
*/
V PutDebugLieSum(S name, U a)
{
  PutStart();
  InLineString(name);
  InLineString(": ");
  PutLieSum(PutLieMonomial, a);
  PutEnd();
}
/*=PutDebugLieTerm==============================================
*/
V PutDebugLieTerm(S name, U a)
{
  PutStart();
  InLineString(name);
  InLineString(": ");
  if(a == NIL)
    PutSymbol('0');
  else
  {
    U na;
    I is_negative = NO;
    if(IsParametric)
    {
      na = LIE_TERM_NUMERATOR_SCALAR_SUM(a);
      if(SCALAR_TERM_R(na) == NIL &&
         INTEGER_IS_NEGATIVE(SCALAR_TERM_NUMERATOR(na)))
        is_negative = YES;
    }
    else if(INTEGER_IS_NEGATIVE(LIE_TERM_NUMERATOR_INTEGER(a)))
      is_negative = YES;
    if(is_negative)
      PutString("- ");
    PutLieBareTerm(PutLieMonomial, a);
  }
  PutEnd();
}
/*=PutDebugU==================================
  Put name and long unsigned integer
*/
V PutDebugU(S name, U i)
{
  printf("\n%s==%lu\n", name, i);
#if !defined(GAP)
  fprintf(SessionFile, "\n%s==%lu\n", name, i);
#endif
}
#if defined(D_PUT_RELATIONS)
/*=PutDebugRelations======================================
 Put Relation table with structure fields
*/
V PutDebugRelations(V)
{
  I i, mg;
  S hformat = "Relations:\n  N SUB MIN_GEN  RELATION\n";
  printf(hformat);
#if !defined(GAP)
  fprintf(SessionFile, hformat);
#endif
  for(i = 0; i < RelationN; i++)
  {
    PutStart();
    if(i < 100)
      InLineSymbol(' ');
    if(i < 10)
      InLineSymbol(' ');
    InLineString(UToString(i));
    InLineString("  ");
    InLineSymbol(RELATION_TO_BE_SUBSTITUTED(i) ? 'Y':'N');
    InLineString(" ");
    mg = RELATION_MIN_GENERATOR(i);
    if(mg < 10)
      InLineSymbol(' ');
    InLineString(UToString(mg));
    InLineString(" ");
    if(mg < GeneratorN)
      PutLieMonomial(mg);
    else
      InLineString("done");
    InLineString("    ");
    IN_LINE_MARGIN;
    PutLieSum(PutLieMonomial, RELATION_LIE_SUM(i));
    PutEnd();
  }
}
#endif
/*=PutDebugScalarSum==============
  Put name and scalar sum
*/
V PutDebugScalarSum(S name, U a)
{
  PutStart();
  InLineString(name);
  InLineString(": ");
  PutScalarSum(a);
  PutEnd();
}
/*=PutDebugString================================
  Put name of string and string
*/
V PutDebugString(S strname, S str)
{
  printf("%s: %s\n", strname, str);
#if !defined(GAP)
  fprintf(SessionFile, "%s: %s\n", strname, str);
#endif
}
#endif
#if defined(MEMORY)
/*=AddLieSumNs=============================================

*/
V AddLieSumNs(U a, I minus_or_plus,
              I *pn_lt, I *pn_int, I *pn_st, I *pn_sf)
{
  I dn_lt, dn_int;
  dn_lt = dn_int = 0;
  while(a != NIL)
  {
    ++dn_lt;
    if(IsParametric)
    {
      AddScalarSumNs(LIE_TERM_NUMERATOR_SCALAR_SUM(a),
                     minus_or_plus, pn_int, pn_st, pn_sf);
      AddScalarSumNs(LIE_TERM_DENOMINATOR_SCALAR_SUM(a),
                     minus_or_plus, pn_int, pn_st, pn_sf);
    }
    else
    {
      ++dn_int;             /* Numerator is obligatory */
      if(LIE_TERM_DENOMINATOR_INTEGER(a) != NULL)
        ++dn_int;
    }
    a = LIE_TERM_R(a);
  }
  if(minus_or_plus == PLUS)
  {
    *pn_lt += dn_lt;
    if(!IsParametric)
      *pn_int += dn_int;
  }
  else
  {
    *pn_lt -= dn_lt;
    if(!IsParametric)
      *pn_int -= dn_int;
  }
}
/*=AddScalarSumNs========================================================
*/
V AddScalarSumNs(U a, I minus_or_plus, I *pn_int, I *pn_st, I *pn_sf)
{
  I dn_int, dn_st, dn_sf;
  U b;
  dn_int = dn_st = dn_sf = 0;
  while(a != NIL)
  {
    ++dn_st;
    ++dn_int;    /* Numerator is obligatory */
    b = SCALAR_TERM_MONOMIAL(a);
    while(b != NIL)
    {
      ++dn_sf;
      b = SCALAR_FACTOR_R(b);
    }
    a = SCALAR_TERM_R(a);
  }
  if(minus_or_plus == PLUS)
  {
    *pn_int += dn_int;
    *pn_st += dn_st;
    *pn_sf += dn_sf;
  }
  else
  {
    *pn_int -= dn_int;
    *pn_st -= dn_st;
    *pn_sf -= dn_sf;
  }
}
/*=PutIntegerBalance===================================================
*/
V PutIntegerBalance(S fname, I dn)
{
  PutStringStandard("\nHeap integer balance violation in function:\n");
  PutStringStandard(fname);
  if(dn > 0)
  {
#if !defined(GAP)
    fprintf(SessionFile, "\n*** %ld INTs gone to garbage\n", dn);
#endif
    printf("\n*** %ld INTs gone to garbage\n", dn);
  }
  else
  {
    dn = -dn;
#if !defined(GAP)
    fprintf(SessionFile, "\n*** %ld INTs appeared from nothing\n", dn);
#endif
    printf("\n*** %ld INTs appeared from nothing\n", dn);
  }
}
/*=PutNodeBalance======================================================
*/
V PutNodeBalance(S type, S fname, I dn)
{
  PutStringStandard(type);
  PutStringStandard(" balance violation in function:\n");
  PutStringStandard(fname);
  if(dn > 0)
  {
#if !defined(GAP)
    fprintf(SessionFile, "\n*** %ld nodes gone to garbage\n", dn);
#endif
    printf("\n*** %ld nodes gone to garbage", dn);
  }
  else
  {
    dn = -dn;
#if !defined(GAP)
    fprintf(SessionFile, "\n***%ld nodes appeared from nothing\n", dn);
#endif
    printf("\n***%ld nodes appeared from nothing\n", dn);
  }
}
#endif

