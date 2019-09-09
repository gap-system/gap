/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares APIs for GAP modules, including builtin modules,
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

EXPORT_INLINE Int IS_MODULE_BUILTIN(UInt type)
{
    return type % 10 == 0;
}

EXPORT_INLINE Int IS_MODULE_STATIC(UInt type)
{
    return type % 10 == 1;
}

EXPORT_INLINE Int IS_MODULE_DYNAMIC(UInt type)
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

// GVAR_FILT a helper macro for quickly creating table entries in
// StructGVarFilt arrays
#define GVAR_FILT(name, argument, filter)                                    \
    {                                                                        \
        #name, argument, filter, Filt##name, __FILE__ ":" #name              \
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

// GVAR_ATTR a helper macro for quickly creating table entries in
// StructGVarAttr arrays
#define GVAR_ATTR(name, argument, filter)                                    \
    {                                                                        \
        #name, argument, filter, Attr##name, __FILE__ ":" #name              \
    }


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

// GVAR_PROP a helper macro for quickly creating table entries in
// StructGVarProp arrays
#define GVAR_PROP(name, argument, filter)                                    \
    {                                                                        \
        #name, argument, filter, Prop##name, __FILE__ ":" #name              \
    }

/****************************************************************************
**
*T  StructGVarOper  . . . . . . . . . . . . . . . . . . .  exported operation
*/
typedef struct {
    const Char * name;
    Int          nargs;
    const Char * args;
    Obj *        operation;
    ObjFunc      handler;
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
    ObjFunc      handler;
    const Char * cookie;
} StructGVarFunc;

// GVAR_FUNC is a helper macro for quickly creating table entries in
// StructGVarFunc arrays
#define GVAR_FUNC(name, nargs, args)                                         \
    {                                                                        \
        #name, nargs, args, (ObjFunc)Func##name, __FILE__ ":" #name   \
    }


/****************************************************************************
**
*F  InitBagNamesFromTable( <table> )  . . . . . . . . .  initialise bag names
*/
void InitBagNamesFromTable(const StructBagNames * tab);


/****************************************************************************
**
*F  InitClearFiltsTNumsFromTable( <tab> ) . . .  initialise clear filts tnums
*/
void InitClearFiltsTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitHasFiltListTNumsFromTable( <tab> )  . . initialise tester filts tnums
*/
void InitHasFiltListTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitSetFiltListTNumsFromTable( <tab> )  . . initialise setter filts tnums
*/
void InitSetFiltListTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitResetFiltListTNumsFromTable( <tab> )  initialise unsetter filts tnums
*/
void InitResetFiltListTNumsFromTable(const Int * tab);


/****************************************************************************
**
*F  InitGVarFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
void InitGVarFiltsFromTable(const StructGVarFilt * tab);


/****************************************************************************
**
*F  InitGVarAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
void InitGVarAttrsFromTable(const StructGVarAttr * tab);


/****************************************************************************
**
*F  InitGVarPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
void InitGVarPropsFromTable(const StructGVarProp * tab);


/****************************************************************************
**
*F  InitGVarOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
void InitGVarOpersFromTable(const StructGVarOper * tab);


/****************************************************************************
**
*F  InitGVarFuncsFromTable( <tab> ) . . . . . . . . . . . . . .  new function
*/
void InitGVarFuncsFromTable(const StructGVarFunc * tab);


/****************************************************************************
**
*F  InitHdlrFiltsFromTable( <tab> ) . . . . . . . . . . . . . . . new filters
*/
void InitHdlrFiltsFromTable(const StructGVarFilt * tab);


/****************************************************************************
**
*F  InitHdlrAttrsFromTable( <tab> ) . . . . . . . . . . . . .  new attributes
*/
void InitHdlrAttrsFromTable(const StructGVarAttr * tab);


/****************************************************************************
**
*F  InitHdlrPropsFromTable( <tab> ) . . . . . . . . . . . . .  new properties
*/
void InitHdlrPropsFromTable(const StructGVarProp * tab);


/****************************************************************************
**
*F  InitHdlrOpersFromTable( <tab> ) . . . . . . . . . . . . .  new operations
*/
void InitHdlrOpersFromTable(const StructGVarOper * tab);


/****************************************************************************
**
*F  InitHdlrFuncsFromTable( <tab> ) . . . . . . . . . . . . . . new functions
*/
void InitHdlrFuncsFromTable(const StructGVarFunc * tab);


/****************************************************************************
**
*F  ImportGVarFromLibrary( <name>, <address> )  . . .  import global variable
*/
void ImportGVarFromLibrary(const Char * name, Obj * address);


/****************************************************************************
**
*F  ImportFuncFromLibrary( <name>, <address> )  . . .  import global function
*/
void ImportFuncFromLibrary(const Char * name, Obj * address);


/****************************************************************************
**
*F  ModulesSetup() . . . . . . . . . . . . . . . . .  instantiate all modules
*/
void ModulesSetup(void);

/****************************************************************************
**
*F  ModulesInitKernel() . . . . . . . . . . call 'initKernel' for all modules
*F  ModulesInitLibrary() . . . . . . . . . call 'initLibrary' for all modules
*F  ModulesCheckInit() . . . . . . . . . . . call 'checkInit' for all modules
*F  ModulesPreSave() . . . . . . . . . . . . . call 'preSave' for all modules
*F  ModulesPostSave() . . . . . . . . . . . . call 'postSave' for all modules
*F  ModulesPostRestore() . . . . . . . . . call 'postRestore' for all modules
*/
void ModulesInitKernel(void);
void ModulesInitLibrary(void);
void ModulesCheckInit(void);
Int  ModulesPreSave(void);
void ModulesPostSave(void);
void ModulesPostRestore(void);

void ModulesInitModuleState(void);
void ModulesDestroyModuleState(void);

void SaveModules(void);
void LoadModules(void);


/****************************************************************************
**
*F  ActivateModule( <info> )
*/
void ActivateModule(StructInitInfo * info);


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
void RecordLoadedModule(StructInitInfo * module,
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
