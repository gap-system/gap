/****************************************************************************
**
*W  gap.h                       GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the various read-eval-print loops and  related  stuff.
*/

#ifndef GAP_GAP_H
#define GAP_GAP_H

#include <src/system.h>

#include <src/error.h>

/****************************************************************************
**
*V  Last  . . . . . . . . . . . . . . . . . . . . . . global variable  'last'
**
**  'Last',  'Last2', and 'Last3'  are the  global variables 'last', 'last2',
**  and  'last3', which are automatically  assigned  the result values in the
**  main read-eval-print loop.
*/
extern UInt Last;


/****************************************************************************
**
*V  Last2 . . . . . . . . . . . . . . . . . . . . . . global variable 'last2'
*/
extern UInt Last2;


/****************************************************************************
**
*V  Last3 . . . . . . . . . . . . . . . . . . . . . . global variable 'last3'
*/
extern UInt Last3;


/****************************************************************************
**
*V  Time  . . . . . . . . . . . . . . . . . . . . . . global variable  'time'
**
**  'Time' is the global variable 'time', which is automatically assigned the
**  time the last command took.
*/
extern UInt Time;


/****************************************************************************
**
*F  ViewObjHandler  . . . . . . . . . handler to view object and catch errors
*/
extern UInt ViewObjGVar;

extern void ViewObjHandler ( Obj obj );


/****************************************************************************
**
*T  ExecStatus . . . .  type of status values returned by read, eval and exec
**                      subroutines, explaining why evaluation, or execution
**                      has terminated.
**
**  Values are powers of two, although I do not currently know of any
**  cirumstances where they can get combined
*/

typedef UInt ExecStatus;

enum {
    STATUS_END         =  0,    // ran off the end of the code
    STATUS_RETURN_VAL  =  1,    // value returned
    STATUS_RETURN_VOID =  2,    // void returned
    STATUS_BREAK       =  4,    // 'break' statement
    STATUS_QUIT        =  8,    // quit command
    STATUS_CONTINUE    =  8,    // 'continue' statement
    STATUS_EOF         = 16,    // End of file
    STATUS_ERROR       = 32,    // error
    STATUS_QQUIT       = 64,    // QUIT command
};


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitBagNamesFromTable( <table> )  . . . . . . . . .  initialise bag names
*/
extern void InitBagNamesFromTable(const StructBagNames * tab);


/****************************************************************************
**
*F  InitClearFiltsTNumsFromTable( <tab> ) . . .  initialise clear filts tnums
*/
extern void InitClearFiltsTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitHasFiltListTNumsFromTable( <tab> )  . . initialise tester filts tnums
*/
extern void InitHasFiltListTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitSetFiltListTNumsFromTable( <tab> )  . . initialise setter filts tnums
*/
extern void InitSetFiltListTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitResetFiltListTNumsFromTable( <tab> )  initialise unsetter filts tnums
*/
extern void InitResetFiltListTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitGVarFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
extern void InitGVarFiltsFromTable(const StructGVarFilt * tab);


/****************************************************************************
**
*F  InitGVarAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
extern void InitGVarAttrsFromTable(const StructGVarAttr * tab);


/****************************************************************************
**
*F  InitGVarPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
extern void InitGVarPropsFromTable(const StructGVarProp * tab);


/****************************************************************************
**
*F  InitGVarOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
extern void InitGVarOpersFromTable(const StructGVarOper * tab);


/****************************************************************************
**
*F  InitGVarFuncsFromTable( <tab> ) . . . . . . . . . . . . . .  new function
*/
extern void InitGVarFuncsFromTable(const StructGVarFunc * tab);


/****************************************************************************
**
*F  InitHdlrFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
extern void InitHdlrFiltsFromTable(const StructGVarFilt * tab);


/****************************************************************************
**
*F  InitHdlrAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
extern void InitHdlrAttrsFromTable(const StructGVarAttr * tab);


/****************************************************************************
**
*F  InitHdlrPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
extern void InitHdlrPropsFromTable(const StructGVarProp * tab);


/****************************************************************************
**
*F  InitHdlrOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
extern void InitHdlrOpersFromTable(const StructGVarOper * tab);


/****************************************************************************
**
*F  InitHdlrFuncsFromTable( <tab> ) . . . . . . . . . . . . . . new functions
*/
extern void InitHdlrFuncsFromTable(const StructGVarFunc * tab);


/****************************************************************************
**
*F  ImportGVarFromLibrary( <name>, <address> )  . . .  import global variable
*/
extern void ImportGVarFromLibrary(
            const Char *        name,
            Obj *               address );


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/
extern void ImportFuncFromLibrary(
            const Char *        name,
            Obj *               address );


/****************************************************************************
**
*F  Modules . . . . . . . . . . . . . . . . . . . . . . . . . list of modules
*/
typedef struct {

    // pointer to the actual StructInitInfo
    StructInitInfo * info;

    // filename relative to GAP_ROOT or absolute
    Char *           filename;

    // true if the filename is GAP_ROOT relative
    Int              isGapRootRelative;

} StructInitInfoExt;


extern void SaveModules(void);
extern void LoadModules(void);

extern Int ModulesPreSave(void);
extern Int ModulesPostSave(void);


/****************************************************************************
**
*F  RecordLoadedModule( <module> )  . . . . . . . . store module in <Modules>
**
**  The filename argument is a C string. A copy of it is taken in some
**   private space and added to the module info.
*/
extern void RecordLoadedModule (
    StructInitInfo *        module,
    Int                     isGapRootRelative,
    const Char *            filename );




/****************************************************************************
**
*F  InitializeGap( <argc>, <argv> ) . . . . . . . . . . . . . . . .  init GAP
*/
extern void InitializeGap (
            int *               pargc,
            char *              argv [],
            char *              environ [] );


#endif // GAP_GAP_H
