/****************************************************************************
**
*W  gvars.h                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions of the global variables package.
**
**  The global variables  package  is the   part of the  kernel that  manages
**  global variables, i.e., the global namespace.  A global variable binds an
**  identifier to a value.
**
**  A global variable can be automatic.   That means that the global variable
**  binds the  identifier to a function and  an argument.   When the value of
**  the global variable is needed, the  function is called with the argument.
**  This function call  should, as a side-effect, execute  an assignment of a
**  value to the global variable, otherwise an error is signalled.
**
**  A global variable can have a number of internal copies, i.e., C variables
**  that always reference the same value as the global variable.  In fact the
**  internal copies are  only used for  functions, i.e.,  the internal copies
**  only reference the same value as the global variable if it is a function.
**  Otherwise the internal copies reference functions that signal an error.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_gvars_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*V  ValGVars  . . . . . . . . . . . . . . . . . .  values of global variables
*V  PtrGVars  . . . . . . . . . . . . . pointer to values of global variables
**
**  'ValGVars' is the bag containing the values of the global variables.
**
**  'PtrGVars' is a pointer  to the 'ValGVars'  bag.  This makes it faster to
**  access global variables.
*/
extern  Obj             ValGVars;

extern  Obj *           PtrGVars;


/****************************************************************************
**
*F  VAL_GVAR(<gvar>)  . . . . . . . . . . . . . . .  value of global variable
**
**  'VAL_GVAR' returns the  value of the global  variable  <gvar>.  If <gvar>
**  has no  assigned value, 'VAL_GVAR' returns 0.   In this case <gvar> might
**  be an automatic global variable, and one should call 'ValAutoGVar', which
**  will return the value of <gvar>  after evaluating <gvar>-s expression, or
**  0 if <gvar> was not an automatic variable.
*/
#define VAL_GVAR(gvar)          PtrGVars[ (gvar) ]


/****************************************************************************
**
*V  WriteGVars  . . . . . . . . . . . . .  writable flags of global variables
*/
extern Obj WriteGVars;


/****************************************************************************
**
*V  ErrorMustEvalToFuncFunc . . . . . . . . .  function that signals an error
**
**  'ErrorMustEvalToFuncFunc' is a (variable number of  args)  function  that
**  signals the error ``Function: <func> be a function''.
*/
extern Obj ErrorMustEvalToFuncFunc;


/****************************************************************************
**
*V  ErrorMustHaveAssObjFunc . . . . . . . . .  function that signals an error
**
**  'ErrorMustHaveAssObjFunc' is a (variable number of  args)  function  that
**  signals the error ``Variable: <<unknown>> must have an assigned value''.
*/
extern Obj ErrorMustHaveAssObjFunc;


/****************************************************************************
**
*F  AssGVar(<gvar>,<val>) . . . . . . . . . . . . assign to a global variable
**
**  'AssGVar' assigns the value <val> to the global variable <gvar>.
*/
extern  void            AssGVar (
            UInt                gvar,
            Obj                 val );


/****************************************************************************
**
*F  ValAutoGVar(<gvar>) . . . . . . . .  value of a automatic global variable
**
**  'ValAutoGVar' returns the value of the global variable <gvar>.  This will
**  be 0 if  <gvar> has  no assigned value.    It will also cause a  function
**  call, if <gvar> is automatic.
*/
extern  Obj             ValAutoGVar (
            UInt                gvar );


/****************************************************************************
**
*F  NameGVar(<gvar>)  . . . . . . . . . . . . . . . name of a global variable
**
**  'NameGVar' returns the name of the global variable <gvar> as a C string.
*/
extern  Char *          NameGVar (
            UInt                gvar );


/****************************************************************************
**
*F  GVarName(<name>)  . . . . . . . . . . . . . .  global variable for a name
**
**  'GVarName' returns the global variable with the name <name>.
*/
extern  UInt            GVarName (
            SYS_CONST Char *              name );


/****************************************************************************
**
*F  InitCopyGVar(<gvar>,<copy>) . . . .  declare C variable as copy of global
**
**  'InitCopyGVar'  makes the C  variable <cvar> at  address <copy> a copy of
**  <gvar>.
**
*F  RemoveCopyFopyInfo( )  . . . remove the information about copies of gvars from
**                               the workspace
*F  RestoreCopyFopyInfo( )  . .  restore this information from the copy in the kernel
**
**  The Restore function is also intended to be used after loading a saved workspace
**
*/

extern  void            InitCopyGVar (
            Char *              name,
            Obj *               copy );

extern void RemoveCopyFopyInfo( void );

extern void RestoreCopyFopyInfo( void );


/****************************************************************************
**
*F  InitFopyGVar(<gvar>,<copy>) . . . .  declare C variable as copy of global
**
**  'InitFopyGVar' makes the C variable <cvar> at address <copy> a (function)
**  copy of   <gvar>.  That means  that whenever  the  value  of  <gvar> is a
**  function, then <cvar> will reference the same  value (i.e., will hold the
**  same bag identifier).  When the  value of <gvar> is  not a function, then
**  <cvar> will reference a function that signals the  error ``<func> must be
**  a   function''.  When <gvar>  has  no  assigned value,  then <cvar>  will
**  reference a  function  that  signals  the error  ``<gvar>  must  have  an
**  assigned value''.
*/

extern void            InitFopyGVar (
    Char *                name,
    Obj *               copy );


/****************************************************************************
**
*V  Tilde . . . . . . . . . . . . . . . . . . . . . . . . global variable '~'
**
**  'Tilde' is the  identifier for the global variable  '~', the one  used in
**  expressions such as '[ [ 1, 2 ], ~[1] ]'.
**
**  Actually  when such expressions  appear in functions, one should probably
**  use a local variable.  But for now this is good enough.
*/
extern  UInt            Tilde;


/****************************************************************************
**
*F  iscomplete_gvar( <name>, <len> )  . . . . . . . . . . . . .  check <name>
*/
extern UInt iscomplete_gvar (
            Char *              name,
            UInt                len );


/****************************************************************************
**
*F  completion_gvar( <name>, <len> )  . . . . . . . . . . . . find completion
*/
extern UInt completion_gvar (
            Char *              name,
            UInt                len );


/****************************************************************************
**
*F  MakeReadOnlyGVar( <gvar> )  . . . . . .  make a global variable read only
*/
extern void MakeReadOnlyGVar (
    UInt                gvar );


/****************************************************************************
**

*F * * * * * * * * * * * * *  create a new gvars *  * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  C_NEW_GVAR_FUNC( <name>, <nargs>, <nams>, <hdlr>, <cookie> )
*/
#define C_NEW_GVAR_FUNC( name, nargs, nams, hdlr, cookie ) \
  do { \
    InitHandlerFunc( hdlr, cookie ); \
    if ( ! SyRestoring ) \
      AssGVar( GVarName(name), NewFunctionC( name, nargs, nams, hdlr ) ); \
      MakeReadOnlyGVar( GVarName(name) ); \
  } while (0)


/****************************************************************************
**
*F  C_NEW_GVAR_ATTR( <name>, <nams>, <attr>, <hdlr>, <cookie> )
**
**  WARNING: <attr> must *always* be a global C variable never a local one.
*/
#define C_NEW_GVAR_ATTR( name, nams, attr, hdlr, cookie ) \
  do { \
    InitHandlerFunc( hdlr, cookie ); \
    InitFopyGVar( name, &attr ); \
    if ( ! SyRestoring ) \
      AssGVar( GVarName(name), NewAttributeC( name, 1L, nams, hdlr ) ); \
      MakeReadOnlyGVar( GVarName(name) ); \
  } while (0)


/****************************************************************************
**
*F  C_NEW_GVAR_PROP( <name>, <nams>, <prop>, <hdlr>, <cookie> )
**
**  WARNING: <prop> must *always* be a global C variable never a local one.
*/
#define C_NEW_GVAR_PROP( name, nams, attr, hdlr, cookie ) \
  do { \
    InitHandlerFunc( hdlr, cookie ); \
    InitFopyGVar( name, &attr ); \
    if ( ! SyRestoring ) \
      AssGVar( GVarName(name), NewPropertyC( name, 1L, nams, hdlr ) ); \
      MakeReadOnlyGVar( GVarName(name) ); \
  } while (0)


/****************************************************************************
**
*F  C_NEW_GVAR_OPER( <name>, <nargs>, <nams>, <oper>, <hdlr>, <cookie> )
**
**  WARNING: <oper> must *always* be a global C variable never a local one.
*/
#define C_NEW_GVAR_OPER( name, nargs, nams, oper, hdlr, cookie ) \
  do { \
    InitHandlerFunc( hdlr, cookie ); \
    InitFopyGVar( name, &oper ); \
    if ( ! SyRestoring ) \
      AssGVar( GVarName(name), NewOperationC( name, nargs, nams, hdlr ) ); \
      MakeReadOnlyGVar( GVarName(name) ); \
  } while (0)


/****************************************************************************
**
*F  C_NEW_GVAR_FILT( <name>, <nams>, <filt>, <hdlr>, <cookie> )
*/
#define C_NEW_GVAR_FILT( name, nams, filt, hdlr, cookie ) \
  do { \
    InitHandlerFunc( hdlr, cookie ); \
    InitFopyGVar( name, &filt ); \
    if ( ! SyRestoring ) \
      AssGVar( GVarName(name), NewFilterC( name, 1L, nams, hdlr ) ); \
      MakeReadOnlyGVar( GVarName(name) ); \
  } while (0)


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupGVars()  . . . . . . . . . . initialize the global variables package
*/
extern void SetupGVars ( void );


/****************************************************************************
**
*F  InitGVars() . . . . . . . . . . . initialize the global variables package
**
**  'InitGVars' initializes the global variables package.
*/
extern void InitGVars ( void );


/****************************************************************************
**
*F  CheckGVars()  .  check the initialisation of the global variables package
*/
extern void CheckGVars ( void );


/****************************************************************************
**

*E  gvars.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
