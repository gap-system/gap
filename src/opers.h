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
char *          Revision_opers_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*V  SET_FILTER_OBJ
*/
extern Obj SET_FILTER_OBJ;


/****************************************************************************
**
*V  RESET_FILTER_OBJ
*/
extern Obj RESET_FILTER_OBJ;


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
            Char *              name,
            Int                 narg,
            Char *              nams,
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
            Char *              name,
            Int                 narg,
            Char *              nams,
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
            Char *              name,
            Int                 narg,
            Char *              nams,
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
            Char *              name,
            Int                 narg,
            Char *              nams,
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
            Char *              name,
            Int                 narg,
            Char *              nams,
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

*F  InitOpers() . . . . . . . . . . . . . . initialize the operations package
*/
extern  void            InitOpers ( void );



