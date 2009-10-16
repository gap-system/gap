/****************************************************************************
**
*W  objscoll.h                  GAP source                       Frank Celler
**
*H  @(#)$Id: objscoll.h,v 4.14 2002/04/15 10:03:54 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_objscoll_h =
   "@(#)$Id: objscoll.h,v 4.14 2002/04/15 10:03:54 sal Exp $";
#endif


/****************************************************************************
**

*D  SCP_SOMETHING
**
**  WARNING: 'cwVector' and 'cw2Vector' must be cleaned after using them.
*/
#define SCP_UNDERLYING_FAMILY       1   /* the family of our free grp elms */
#define SCP_RWS_GENERATORS          2   /* the free grp generators used    */
#define SCP_NUMBER_RWS_GENERATORS   3   /* number of generators            */
#define SCP_DEFAULT_TYPE            4   /* default kind of the result      */
#define SCP_IS_DEFAULT_TYPE         5   /* tester for default kind         */
#define SCP_RELATIVE_ORDERS         6   /* list of relative orders         */
#define SCP_POWERS                  7   /* list of power rhs               */
#define SCP_CONJUGATES              8   /* list of list of conjugates rhs  */
#define SCP_INVERSES                9   /* list of inverses of the gens    */
#define SCP_NW_STACK               10   /* word stack                      */
#define SCP_LW_STACK               11   /* end marker stack                */
#define SCP_PW_STACK               12   /* position stack                  */
#define SCP_EW_STACK               13   /* exponent stack                  */
#define SCP_GE_STACK               14   /* global exponent stack           */
#define SCP_CW_VECTOR              15   /* temporary collect vector        */
#define SCP_CW2_VECTOR             16   /* temporary collect vector        */
#define SCP_MAX_STACK_SIZE         17   /* maximal stack size              */
#define SCP_COLLECTOR              18   /* collector to use                */
#define SCP_AVECTOR                19   /* avector                         */
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

#define SC_CW_VECTOR(sc) \
    (ADDR_OBJ(sc)[SCP_CW_VECTOR])

#define SC_CW2_VECTOR(sc) \
    (ADDR_OBJ(sc)[SCP_CW2_VECTOR])

#define SC_DEFAULT_TYPE(sc) \
    (ADDR_OBJ(sc)[SCP_DEFAULT_TYPE])

#define SC_EW_STACK(sc) \
    (ADDR_OBJ(sc)[SCP_EW_STACK])

#define SC_GE_STACK(sc) \
    (ADDR_OBJ(sc)[SCP_GE_STACK])

#define SC_INVERSES(sc) \
    (ADDR_OBJ(sc)[SCP_INVERSES])

#define SC_LW_STACK(sc) \
    (ADDR_OBJ(sc)[SCP_LW_STACK])

#define SC_MAX_STACK_SIZE(sc) \
    (INT_INTOBJ((ADDR_OBJ(sc)[SCP_MAX_STACK_SIZE])))

#define SC_SET_MAX_STACK_SIZE(sc,obj) \
    ((ADDR_OBJ(sc)[SCP_MAX_STACK_SIZE]) = INTOBJ_INT(obj))

#define SC_NUMBER_RWS_GENERATORS(sc) \
    (INT_INTOBJ((ADDR_OBJ(sc)[SCP_NUMBER_RWS_GENERATORS])))

#define SC_NW_STACK(sc) \
    (ADDR_OBJ(sc)[SCP_NW_STACK])

#define SC_POWERS(sc) \
    (ADDR_OBJ(sc)[SCP_POWERS])

#define SC_PW_STACK(sc) \
    (ADDR_OBJ(sc)[SCP_PW_STACK])

#define SC_RELATIVE_ORDERS(sc) \
    (ADDR_OBJ(sc)[SCP_RELATIVE_ORDERS])

#define SC_RWS_GENERATORS(sc) \
    (ADDR_OBJ(sc)[SCP_RWS_GENERATORS])


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


/****************************************************************************
**

*E  objscoll.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
