/****************************************************************************
**
*W  opers.h                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions of the  filters, operations, attributes,
**  and properties package.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_opers_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F  IS_OPERATION( <func> )  . . . . . . . . .  check if function is operation
*/
#define IS_OPERATION(func) \
    (TNUM_OBJ(func) == T_FUNCTION && SIZE_OBJ(func) == SIZE_OPER )

#define FLAG1_FILT(oper)        (*            (ADDR_OBJ(oper) +16     ) )
#define FLAG2_FILT(oper)        (*            (ADDR_OBJ(oper) +17     ) )
#define FLAGS_FILT(oper)        (*            (ADDR_OBJ(oper) +18     ) )
#define SETTR_FILT(oper)        (*            (ADDR_OBJ(oper) +19     ) )
#define TESTR_FILT(oper)        (*            (ADDR_OBJ(oper) +20     ) )
#define METHS_OPER(oper,i)      (*            (ADDR_OBJ(oper) +21+ (i)) )
#define CACHE_OPER(oper,i)      (*            (ADDR_OBJ(oper) +29+ (i)) )
#define SIZE_OPER               (37*sizeof(Bag))


/****************************************************************************
**

*V  SET_FILTER_OBJ  . . . . . . . . . . . .  library function to set a filter
*/
extern Obj SET_FILTER_OBJ;


/****************************************************************************
**
*V  RESET_FILTER_OBJ  . . . . . . . . . .  library function to reset a filter
*/
extern Obj RESET_FILTER_OBJ;



/****************************************************************************
**
*V  CountFlags  . . . . . . . . . . . . . . . . . . . . next free flag number
*/
extern Int CountFlags;


/****************************************************************************
**
*F  RESERVE_FILTER( <filt>, <numr> )  . . . . . . . . reserve a filter number
*/
#define RESERVE_FILTER( filt, numr ) \
    do { \
        if ( CountFlags < numr )  CountFlags = numr; \
        filt = INTOBJ_INT(numr); \
    } \
    while (0)


/****************************************************************************
**
*F  RESERVE_PROPERTY( <filt>, <num1>, <num2> )  . . reserve a property number
*/
#define RESERVE_PROPERTY( filt, num1, num2 ) \
    do { \
        if ( CountFlags < num1 )  CountFlags = num1; \
        if ( CountFlags < num2 )  CountFlags = num2; \
        filt = INTOBJ_INT( (num1 << 10) + num2 ); \
    } \
    while (0)


/****************************************************************************
**

*F  NewFilter( <name> ) . . . . . . . . . . . . . . . . . . make a new filter
*/
extern Obj DoFilter (
            Obj                 self,
            Obj                 obj );

extern Obj NewFilter (
            Obj                 name,
            Int                 narg,
            Obj                 nams,
            ObjFunc             hdlr );

extern Obj NewFilterC (
            SYS_CONST Char *    name,
            Int                 narg,
            SYS_CONST Char *    nams,
            ObjFunc             hdlr );


/****************************************************************************
**
*F  NewAndFilter( <filt1>, <filt2> )  . . . .  make a new concatenated filter
*/
extern Obj NewAndFilter (
            Obj                 oper1,
            Obj                 oper2 );


/****************************************************************************
**
*F  NewOperation( <name> )  . . . . . . . . . . . . . .  make a new operation
*/
extern Obj DoOperation0Args (
            Obj                 oper );

extern Obj DoOperation1Args (
            Obj                 oper,
            Obj                 arg1 );

extern Obj DoOperation2Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2 );

extern Obj DoOperation3Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3 );

extern Obj DoOperation4Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4 );

extern Obj DoOperation5Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5 );

extern Obj DoOperation6Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5,
            Obj                 arg6 );

extern Obj DoOperationXArgs (
            Obj                 self,
            Obj                 args );

extern Obj DoVerboseOperation0Args (
            Obj                 oper );

extern Obj DoVerboseOperation1Args (
            Obj                 oper,
            Obj                 arg1 );

extern Obj DoVerboseOperation2Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2 );

extern Obj DoVerboseOperation3Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3 );

extern Obj DoVerboseOperation4Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4 );

extern Obj DoVerboseOperation5Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5 );

extern Obj DoVerboseOperation6Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5,
            Obj                 arg6 );

extern Obj DoVerboseOperationXArgs (
            Obj                 self,
            Obj                 args );

extern Obj NewOperation (
            Obj                 name,
            Int                 narg,
            Obj                 nams,
            ObjFunc             hdlr );

extern Obj NewOperationC (
            SYS_CONST Char *    name,
            Int                 narg,
            SYS_CONST Char *    nams,
            ObjFunc             hdlr );


/****************************************************************************
**
*F  NewOperationKA1( <name> ) . . . . . . . . . . . . .  make a new operation
*/
extern Obj NewOperationKA1 (
            Obj                 name,
            Int                 narg,
            Obj                 nams,
            ObjFunc             hdlr );

extern Obj NewOperationKA1C (
            SYS_CONST Char *    name,
            Int                 narg,
            SYS_CONST Char *    nams,
            ObjFunc             hdlr );


/****************************************************************************
**
*F  NewAttribute( <name> )  . . . . . . . . . . . . . .  make a new attribute
*/
extern  Obj DoAttribute (
            Obj                 self,
            Obj                 obj );

extern  Obj DoVerboseAttribute (
            Obj                 self,
            Obj                 obj );

extern  Obj NewAttribute (
            Obj                 name,
            Int                 narg,
            Obj                 nams,
            ObjFunc             hdlr );

extern  Obj NewAttributeC (
            SYS_CONST Char *    name,
            Int                 narg,
            SYS_CONST Char *    nams,
            ObjFunc             hdlr );


/****************************************************************************
**
*F  NewProperty( <name> ) . . . . . . . . . . . . . . . . make a new property
*/
extern Obj DoProperty (
            Obj                 self,
            Obj                 obj );

extern Obj NewProperty (
            Obj                 name,
            Int                 narg,
            Obj                 nams,
            ObjFunc             hdlr );

extern Obj NewPropertyC (
            SYS_CONST Char *    name,
            Int                 narg,
            SYS_CONST Char *    nams,
            ObjFunc             hdlr );


/****************************************************************************
**

*F  ChangeDoOperations( <oper>, <verb> )
*/
extern void ChangeDoOperations (
            Obj                 oper,
            Int                 verb );

/****************************************************************************
**
*F  SaveOperationExtras( <oper> ) . . . .additional savng for functions which
**                                       are operations
**
**  This is called by SaveFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/

extern void SaveOperationExtras( Obj oper );

/****************************************************************************
**
*F  LoadOperationExtras( <oper> ) . . . .additional loading for functions which
**                                       are operations
**
**  This is called by LoadFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/

extern void LoadOperationExtras( Obj oper );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupOpers() . . . . . . . . . . . . . . initialize the operations package
*/
extern void SetupOpers ( void );


/****************************************************************************
**
*F  InitOpers() . . . . . . . . . . . . . . initialize the operations package
*/
extern void InitOpers ( void );


/****************************************************************************
**
*F  CheckOpers()  . . . .  check the initialisation of the operations package
*/
extern void CheckOpers ( void );


/****************************************************************************
**

*E  opers.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
