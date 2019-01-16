/****************************************************************************
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002-2018 The GAP Group
**
**  This files declares APIs for GAP modules, including builtin modules,
**  or static and dynamic modules used by packages and end users to provide
**  kernel extensions.
*/

#ifndef GAP_MODULES_H
#define GAP_MODULES_H

#include "system.h"

/****************************************************************************
**
*V  GAP_KERNEL_API_VERSION
**
**  'GAP_KERNEL_API_VERSION' gives the version of the GAP kernel. This value
**  is used to check if kernel modules were built with a compatible kernel.
**  This version is not the same as, and not connected to, the GAP version.
**
**  This is stored as
**  'GAP_KERNEL_MAJOR_VERSION*1000 + GAP_KERNEL_MINOR_VERSION'.
**
**  The algorithm used is the following:
**
**  The kernel will not load a module compiled for a newer kernel.
**
**  The kernel will not load a module compiled for a different major version.
**
**  The minor version should be incremented when new backwards-compatible
**  functionality is added. The major version should be incremented when
**  a backwards-incompatible change is made.
**
**  The kernel version is a macro so it can be used by packages
**  to optionally compile support for new functionality.
**
*/

// GAP_KERNEL_MAJOR_VERSION and GAP_KERNEL_MINOR_VERSION are defined in
// config.h

#define GAP_KERNEL_API_VERSION                                               \
    ((GAP_KERNEL_MAJOR_VERSION)*1000 + (GAP_KERNEL_MINOR_VERSION))

enum {
    /** builtin module */
    MODULE_BUILTIN = GAP_KERNEL_API_VERSION * 10,

    /** statically loaded compiled module */
    MODULE_STATIC = GAP_KERNEL_API_VERSION * 10 + 1,

    /** dynamically loaded compiled module */
    MODULE_DYNAMIC = GAP_KERNEL_API_VERSION * 10 + 2,
};

static inline Int IS_MODULE_BUILTIN(UInt type)
{
    return type % 10 == 0;
}

static inline Int IS_MODULE_STATIC(UInt type)
{
    return type % 10 == 1;
}

static inline Int IS_MODULE_DYNAMIC(UInt type)
{
    return type % 10 == 2;
}


/****************************************************************************
**
*T  StructInitInfo  . . . . . . . . . . . . . . . . . module init information
*/
struct init_info {

    /* type of the module: MODULE_BUILTIN, MODULE_STATIC, MODULE_DYNAMIC   */
    UInt type;

    /* name of the module: filename with ".c" or library filename          */
    const Char * name;

    /* revision entry of c file for MODULE_BUILTIN                         */
    const Char * revision_c;

    /* revision entry of h file for MODULE_BUILTIN                         */
    const Char * revision_h;

    /* version number for MODULE_BUILTIN                                   */
    UInt version;

    /* CRC value for MODULE_STATIC or MODULE_DYNAMIC                       */
    Int crc;

    /* initialise kernel data structures                                   */
    Int (*initKernel)(StructInitInfo *);

    /* initialise library data structures                                  */
    Int (*initLibrary)(StructInitInfo *);

    /* sanity check                                                        */
    Int (*checkInit)(StructInitInfo *);

    /* function to call before saving workspace                            */
    Int (*preSave)(StructInitInfo *);

    /* function to call after saving workspace                             */
    Int (*postSave)(StructInitInfo *);

    /* function to call after restoring workspace                          */
    Int (*postRestore)(StructInitInfo *);

    // number of bytes this module needs for its per-thread module state
    UInt moduleStateSize;

    // if this is not zero, then the module state offset is stored into
    // the address this points at
    Int * moduleStateOffsetPtr;

    // initialize thread local module state
    Int (*initModuleState)(void);

    // destroy thread local module state
    Int (*destroyModuleState)(void);

};


/****************************************************************************
**
*T  StructBagNames  . . . . . . . . . . . . . . . . . . . . . tnums and names
*/
typedef struct {
    Int          tnum;
    const Char * name;
} StructBagNames;


/****************************************************************************
**
*T  StructGVarFilt  . . . . . . . . . . . . . . . . . . . . . exported filter
*/
typedef struct {
    const Char * name;
    const Char * argument;
    Obj *        filter;
    Obj (*handler)(Obj, Obj);
    const Char * cookie;
} StructGVarFilt;

// GVAR_FILTER a helper macro for quickly creating table entries in
// StructGVarFilt, StructGVarAttr and StructGVarProp arrays
#define GVAR_FILTER(name, argument, filter)                                  \
    {                                                                        \
        #name, argument, filter, Func##name, __FILE__ ":" #name              \
    }


/****************************************************************************
**
*T  StructGVarAttr  . . . . . . . . . . . . . . . . . . .  exported attribute
*/
typedef struct {
    const Char * name;
    const Char * argument;
    Obj *        attribute;
    Obj (*handler)(Obj, Obj);
    const Char * cookie;
} StructGVarAttr;


/****************************************************************************
**
*T  StructGVarProp  . . . . . . . . . . . . . . . . . . . . exported property
*/
typedef struct {
    const Char * name;
    const Char * argument;
    Obj *        property;
    Obj (*handler)(Obj, Obj);
    const Char * cookie;
} StructGVarProp;


/****************************************************************************
**
*T  StructGVarOper  . . . . . . . . . . . . . . . . . . .  exported operation
*/
typedef struct {
    const Char * name;
    Int          nargs;
    const Char * args;
    Obj *        operation;
    Obj (*handler)(/*arguments*/);
    const Char * cookie;
} StructGVarOper;

// GVAR_OPER is a helper macro for quickly creating table entries in
// StructGVarOper arrays
#define GVAR_OPER(name, nargs, args, operation)                              \
    {                                                                        \
        #name, nargs, args, operation, Func##name, __FILE__ ":" #name        \
    }


/****************************************************************************
**
*T  StructGVarFunc  . . . . . . . . . . . . . . . . . . . . exported function
*/
typedef struct {
    const Char * name;
    Int          nargs;
    const Char * args;
    Obj (*handler)(/*arguments*/);
    const Char * cookie;
} StructGVarFunc;

// GVAR_FUNC is a helper macro for quickly creating table entries in
// StructGVarFunc arrays
#define GVAR_FUNC(name, nargs, args)                                         \
    {                                                                        \
        #name, nargs, args, Func##name, __FILE__ ":" #name                   \
    }


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
extern void ImportGVarFromLibrary(const Char * name, Obj * address);


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/
extern void ImportFuncFromLibrary(const Char * name, Obj * address);


/****************************************************************************
**
*F  ModulesSetup() . . . . . . . . . . . . . . . . .  instantiate all modules
*/
extern void ModulesSetup(void);

/****************************************************************************
**
*F  ModulesInitKernel() . . . . . . . . . . call 'initKernel' for all modules
*F  ModulesInitLibrary() . . . . . . . . . call 'initLibrary' for all modules
*F  ModulesCheckInit() . . . . . . . . . . . call 'checkInit' for all modules
*F  ModulesPreSave() . . . . . . . . . . . . . call 'preSave' for all modules
*F  ModulesPostSave() . . . . . . . . . . . . call 'postSave' for all modules
*F  ModulesPostRestore() . . . . . . . . . call 'postRestore' for all modules
*/
extern void ModulesInitKernel(void);
extern void ModulesInitLibrary(void);
extern void ModulesCheckInit(void);
extern Int  ModulesPreSave(void);
extern void ModulesPostSave(void);
extern void ModulesPostRestore(void);

extern void ModulesInitModuleState(void);
extern void ModulesDestroyModuleState(void);

extern void SaveModules(void);
extern void LoadModules(void);


/****************************************************************************
**
*F  ActivateModule( <info> )
*/
extern void ActivateModule(StructInitInfo * info);


/****************************************************************************
**
*F  RecordLoadedModule( <module> )  . . . . . . . . store module in <Modules>
**
**  The filename argument is a C string. A copy of it is taken in some
**  private space and added to the module info.
**
**  This function triggers no garbage collection, so it OK to pass a pointer
**  to the content of a GAP string object as filename.
*/
extern void RecordLoadedModule(StructInitInfo * module,
                               Int              isGapRootRelative,
                               const Char *     filename);


/****************************************************************************
**
*F * * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoModules() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoModules(void);


#endif    // GAP_MODULES_H
