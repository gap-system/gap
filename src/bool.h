/****************************************************************************
**
*W  bool.h                      GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions for the boolean package.
*/
#ifdef INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_bool_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*V  True  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  true value
**
**   'True' is the value 'true'.
*/
extern Obj True;


/****************************************************************************
**
*V  False . . . . . . . . . . . . . . . . . . . . . . . . . . . . false value
**
**  'False' is the value 'false'.
*/
extern Obj False;


/****************************************************************************
**
*V  Fail  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  fail value
**
**  'Fail' is the value 'fail'.
*/
extern Obj Fail;


/****************************************************************************
**

*F  ReturnTrue1( <val1> ) . . . . . . . . . . . . . . . . . .  return  'True'
*F  ReturnTrue2( <val1>, <val2> ) . . . . . . . . . . . . . .  return  'True'
*F  ReturnTrue3( <val1>, <val2>, <val3> ) . . . . . . . . . .  return  'True'
*F  ReturnFalse1( <val1> )  . . . . . . . . . . . . . . . . .  return 'False'
*F  ReturnFalse2( <val1>, <val2> )  . . . . . . . . . . . . .  return 'False'
*F  ReturnFalse3( <val1>, <val2>, <val3> )  . . . . . . . . .  return 'False'
*F  ReturnFail1( <val1> ) . . . . . . . . . . . . . . . . . .  return  'Fail'
*F  ReturnFail2( <val1>, <val2> ) . . . . . . . . . . . . . .  return  'Fail'
*F  ReturnFail3( <val1>, <val2>, <val3> ) . . . . . . . . . .  return  'Fail'
**
**  'ReturnTrue?'  simply return  'True'  independent of  the values of   the
**  arguments.
**
**  'ReturnFalse?' likewise return 'False'.
**
**  'ReturnFail?' likewise return 'Fail'.
**
**  Those  functions are  useful for  dispatcher  tables if the types already
**  determine the outcome.
*/
extern  Obj ReturnTrue1 (
            Obj                 self,
            Obj                 val1 );

extern  Obj ReturnTrue2 (
            Obj                 self,
            Obj                 val1,
            Obj                 val2 );

extern  Obj ReturnTrue3 (
            Obj                 self,
            Obj                 val1,
            Obj                 val2,
            Obj                 val3 );


extern  Obj ReturnFalse1 (
            Obj                 self,
            Obj                 val1 );

extern  Obj ReturnFalse2 (
            Obj                 self,
            Obj                 val1,
            Obj                 val2 );

extern  Obj ReturnFalse3 (
            Obj                 self,
            Obj                 val1,
            Obj                 val2,
            Obj                 val3 );


extern  Obj ReturnFail1 (
            Obj                 self,
            Obj                 val1 );

extern  Obj ReturnFail2 (
            Obj                 self,
            Obj                 val1,
            Obj                 val2 );

extern  Obj ReturnFail3 (
            Obj                 self,
            Obj                 val1,
            Obj                 val2,
            Obj                 val3 );


/****************************************************************************
**

*E  InitBool()  . . . . . . . . . . . . . . . initialize the booleans package
**
**  'InitBool' initializes the boolean package.
*/
extern  void            InitBool ( void );



