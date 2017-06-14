/****************************************************************************
**
*W  gvars.h                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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

#ifndef GAP_GVARS_H
#define GAP_GVARS_H


/****************************************************************************
**
*F  ValGVar(<gvar>)   . . . . . . . . . . . . . . .  value of global variable
**
**  'ValGVar' returns the  value of the global  variable  <gvar>.  If <gvar>
**  has no  assigned value, 'ValGVar' returns 0.   In this case <gvar> might
**  be an automatic global variable, and one should call 'ValAutoGVar', which
**  will return the value of <gvar>  after evaluating <gvar>-s expression, or
**  0 if <gvar> was not an automatic variable.
*/
extern Obj ValGVar(UInt gvar);

#define VAL_GVAR(gvar)      ValGVar(gvar)


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
*F  ValGVarTL(<gvar>) . . . . . . . . value of a global/thread-local variable
**
**  'ValGVarTL' returns the value of the global or thread-local variable
**  <gvar>.
*/
#ifdef HPCGAP
extern  Obj             ValGVarTL (
            UInt                gvar );
#else
#define ValGVarTL(gvar)     ValGVar(gvar)
#endif


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
*F  NameGVarObj(<gvar>)  . . . . . . . . . . . . .  name of a global variable
**
**  'NameGVarObj' returns the name of the global variable <gvar> as a GAP
**  string.
*/
extern  Obj            NameGVarObj (
            UInt                gvar );


/****************************************************************************
**
*F  ExprGVar(<gvar>)  . . . . . .  expression of an automatic global variable
**
**  'ExprGVar' returns the expression of the automatic global variable <gvar>.
*/
extern  Obj            ExprGVar (
            UInt                gvar );


/****************************************************************************
**
*F  GVarName(<name>)  . . . . . . . . . . . . . .  global variable for a name
**
**  'GVarName' returns the global variable with the name <name>.
*/
extern UInt GVarName (
            const Char *              name );


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
*F  MakeReadWriteGVar( <gvar> ) . . . . . . make a global variable read-write
*/
extern void MakeReadOnlyGVar (
    UInt                gvar );

extern void MakeReadWriteGVar (
    UInt                gvar );

/****************************************************************************
**
*F  MakeThreadLocalVar( <gvar>, <rnam> ) . . . . make a variable thread-local
*/
#ifdef HPCGAP
extern void MakeThreadLocalVar (
    UInt                gvar,
    UInt		rnam );
#endif

extern Int IsReadOnlyGVar (
    UInt                gvar );

/****************************************************************************
**
*F * * * * * * * * * * * * * copies and fopies  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitCopyGVar( <name>, <copy> )  . .  declare C variable as copy of global
**
**  'InitCopyGVar' makes  the C variable <cvar>  at address  <copy> a copy of
**  the global variable named <name> (which must be a kernel string).
**
**  The function only registers the  information in <CopyAndFopyGVars>.  At a
**  latter stage one  has to call  'UpdateCopyFopyInfo' to actually enter the
**  information stored in <CopyAndFopyGVars> into a plain list.
**
**  This is OK for garbage collection, but  a real problem  for saving in any
**  event, this information  does not really want to  be saved  because it is
**  kernel centred rather than workspace centred.
**
**  Accordingly we     provide  two    functions    `RemoveCopyFopyInfo'  and
**  `RestoreCopyFopyInfo' to  remove  or restore   the  information from  the
**  workspace.  The  Restore  function is  also   intended to  be used  after
**  loading a saved workspace
*/
extern void InitCopyGVar (
    const Char *        name ,
    Obj *               copy );


/****************************************************************************
**
*F  InitFopyGVar( <name>, <copy> )  . .  declare C variable as copy of global
**
**  'InitFopyGVar' makes the C variable <cvar> at address <copy> a (function)
**  copy  of the  global variable <gvar>,  whose name  is <name>.  That means
**  that whenever   the value  of   <gvar> is a    function, then <cvar> will
**  reference the same value (i.e., will hold the same bag identifier).  When
**  the value  of <gvar>  is not a   function, then  <cvar> will  reference a
**  function  that signals  the error ``<func>  must be  a function''.   When
**  <gvar> has no assigned value, then <cvar> will  reference a function that
**  signals the error ``<gvar> must have an assigned value''.
*/
extern void InitFopyGVar (
    const Char *        name,
    Obj *               copy );


/****************************************************************************
**
*F  UpdateCopyFopyInfo()  . . . . . . . . . .  convert kernel info into plist
*/
extern void UpdateCopyFopyInfo ( void );


/****************************************************************************
**
*F  RemoveCopyFopyInfo()  . . . remove the info about copies of gvars from ws
*/
extern void RemoveCopyFopyInfo( void );


/****************************************************************************
**
*F  RestoreCopyFopyInfo() . . .  restore the info from the copy in the kernel
*/
extern void RestoreCopyFopyInfo( void );


/****************************************************************************
**
*F  GVarsAfterCollectBags()
*/
extern void GVarsAfterCollectBags( void );


/****************************************************************************
**
*F  DeclareGVar(<gvar>, <name>) . . . . . .  declare global variable by name
*F  GVarValue(<gvar>) . . . . . . . . . return value of <gvar>, 0 if unbound
*F  GVarObj(<gvar>) . . . . . . . . return value of <gvar>, error if unbound
*F  GVarFunction(<gvar>) . . . . return value of <gvar>, error if not a function
*F  GVarOptFunction(<gvar>) . . return value of <gvar>, 0 if unbound/no function
*F  SetGVar(<gvar>, <obj>) . . . . . . . . . . . . .  assign <obj> to <gvar>
*/

#ifdef HPCGAP


/****************************************************************************
**
*T  GVarDescriptor  . . . . . . . . . . . .  descriptor for a global variable
*/

typedef struct GVarDescriptor {
    Obj *ref;
    char *name;
    struct GVarDescriptor *next;
} GVarDescriptor;


extern void DeclareGVar(GVarDescriptor *gvar, char *name);
extern Obj GVarValue(GVarDescriptor *gvar);
extern Obj GVarObj(GVarDescriptor *gvar);
extern Obj GVarFunction(GVarDescriptor *gvar);
extern Obj GVarOptFunction(GVarDescriptor *gvar);
extern void SetGVar(GVarDescriptor *gvar, Obj obj);
#endif


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoGVars() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoGVars ( void );


#endif // GAP_GVARS_H

/****************************************************************************
**
*E  gvars.h . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
