/****************************************************************************
**
*W  objscoll.h                  GAP source                       Frank Celler
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
*/

#ifndef GAP_OBJSCOLL_H
#define GAP_OBJSCOLL_H


/****************************************************************************
**
*D  SCP_SOMETHING
**
*/
#define SCP_UNDERLYING_FAMILY       1   /* the family of our free grp elms */
#define SCP_RWS_GENERATORS          2   /* the free grp generators used    */
#define SCP_NUMBER_RWS_GENERATORS   3   /* number of generators            */
#define SCP_DEFAULT_TYPE            4   /* default type of the result      */
#define SCP_IS_DEFAULT_TYPE         5   /* tester for default type         */
#define SCP_RELATIVE_ORDERS         6   /* list of relative orders         */
#define SCP_POWERS                  7   /* list of power rhs               */
#define SCP_CONJUGATES              8   /* list of list of conjugates rhs  */
#define SCP_INVERSES                9   /* list of inverses of the gens    */
#define SCP_COLLECTOR              10   /* collector to use                */
#define SCP_AVECTOR                11   /* avector                         */
#define SCP_LAST          SCP_AVECTOR   /* last entry in a single coll.    */


/****************************************************************************
**
*D  SC_SOMETHING( <sc> )
**
**  WARNING: 'cwVector' and 'cw2Vector' must be cleaned after using them.
*/
#define SC_AVECTOR(sc) \
    (ADDR_OBJ(sc)[SCP_AVECTOR])

#define SC_COLLECTOR(sc) \
    (FinPowConjCollectors[INT_INTOBJ(ADDR_OBJ(sc)[SCP_COLLECTOR])])

#define SC_CONJUGATES(sc) \
    (ADDR_OBJ(sc)[SCP_CONJUGATES])

#define SC_DEFAULT_TYPE(sc) \
    (ADDR_OBJ(sc)[SCP_DEFAULT_TYPE])

#define SC_INVERSES(sc) \
    (ADDR_OBJ(sc)[SCP_INVERSES])

#define SC_NUMBER_RWS_GENERATORS(sc) \
    (INT_INTOBJ((ADDR_OBJ(sc)[SCP_NUMBER_RWS_GENERATORS])))

#define SC_POWERS(sc) \
    (ADDR_OBJ(sc)[SCP_POWERS])

#define SC_RELATIVE_ORDERS(sc) \
    (ADDR_OBJ(sc)[SCP_RELATIVE_ORDERS])

#define SC_RWS_GENERATORS(sc) \
    (ADDR_OBJ(sc)[SCP_RWS_GENERATORS])

/* TL: extern Obj SC_NW_STACK; */
/* TL: extern Obj SC_LW_STACK; */
/* TL: extern Obj SC_PW_STACK; */
/* TL: extern Obj SC_EW_STACK; */
/* TL: extern Obj SC_GE_STACK; */
/* TL: extern Obj SC_CW_VECTOR; */
/* TL: extern Obj SC_CW2_VECTOR; */
/* TL: extern UInt SC_MAX_STACK_SIZE; */

/****************************************************************************
**
*F  FuncFinPowConjCol_CollectWordOrFail( <self>, <sc>, <vv>, <w> )
*/
extern Obj FuncFinPowConjCol_CollectWordOrFail ( Obj, Obj, Obj, Obj );


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedComm( <self>, <sc>, <w>, <u> )
*/
extern Obj FuncFinPowConjCol_ReducedComm ( Obj, Obj, Obj, Obj );


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedForm( <self>, <sc>, <w> )
*/
extern Obj FuncFinPowConjCol_ReducedForm ( Obj, Obj, Obj );


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedLeftQuotient( <self>, <sc>, <w>, <u> )
*/
extern Obj FuncFinPowConjCol_ReducedLeftQuotient ( Obj, Obj, Obj, Obj );


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedProduct( <self>, <sc>, <w>, <u> )
*/
extern Obj FuncFinPowConjCol_ReducedProduct ( Obj, Obj, Obj, Obj );


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedPowerSmallInt( <self>, <sc>, <w>, <pow> )
*/
extern Obj FuncFinPowConjCol_ReducedPowerSmallInt ( Obj, Obj, Obj, Obj);


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedQuotient( <self>, <sc>, <w>, <u> )
*/
extern Obj FuncFinPowConjCol_ReducedQuotient ( Obj, Obj, Obj, Obj );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoSingleCollector() . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoSingleCollector ( void );


#endif // GAP_OBJSCOLL_H

/****************************************************************************
**
*E  objscoll.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
