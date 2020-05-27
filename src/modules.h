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

#include "common.h"

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
**  The kernel version is set in `configure.ac`. As a rule, when new
**  backwards-compatible functionality is added, the major version stays the
**  same and the minor version is incremented. When a backwards-incompatible
**  change is made, the major version is increased and the minor version reset
**  to zero.
**
**  The kernel version is a macro so it can be used by packages for
**  conditional compilation of code using new kernel functionality.
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

EXPORT_INLINE BOOL IS_MODULE_BUILTIN(UInt type)
{
    return type % 10 == 0;
}

EXPORT_INLINE BOOL IS_MODULE_STATIC(UInt type)
{
    return type % 10 == 1;
}

EXPORT_INLINE BOOL IS_MODULE_DYNAMIC(UInt type)
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

    // revision_c is obsolete and only kept for backwards compatibility
    const Char * revision_c;

    // revision_h is obsolete and only kept for backwards compatibility
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
*T  InitInfoFunc
*/
typedef StructInitInfo* (*InitInfoFunc)(void);


/****************************************************************************
**
**  Some helper functions and macros used for validation in GVAR_FUNC_2ARGS
**  and its likes.
**
**  The trick is that VALIDATE_FUNC_nARGS(func) produces code that the
**  compiler can trivially prove to be equivalent to just inserting 'func';
**  and the "call" to VALIDATE_FUNC_HELPER_n can never ever be executed;
**  but since it is still there in the input, the compiler has to check
**  that its argument has the correct type.
*/
static inline ObjFunc VALIDATE_FUNC_HELPER_0(ObjFunc_0ARGS f)
{
    return 0;
}
static inline ObjFunc VALIDATE_FUNC_HELPER_1(ObjFunc_1ARGS f)
{
    return 0;
}
static inline ObjFunc VALIDATE_FUNC_HELPER_2(ObjFunc_2ARGS f)
{
    return 0;
}
static inline ObjFunc VALIDATE_FUNC_HELPER_3(ObjFunc_3ARGS f)
{
    return 0;
}
static inline ObjFunc VALIDATE_FUNC_HELPER_4(ObjFunc_4ARGS f)
{
    return 0;
}
static inline ObjFunc VALIDATE_FUNC_HELPER_5(ObjFunc_5ARGS f)
{
    return 0;
}
static inline ObjFunc VALIDATE_FUNC_HELPER_6(ObjFunc_6ARGS f)
{
    return 0;
}

#define VALIDATE_FUNC_0ARGS(func)                                            \
    (0 ? VALIDATE_FUNC_HELPER_0(func) : (ObjFunc)func)
#define VALIDATE_FUNC_1ARGS(func)                                            \
    (0 ? VALIDATE_FUNC_HELPER_1(func) : (ObjFunc)func)
#define VALIDATE_FUNC_2ARGS(func)                                            \
    (0 ? VALIDATE_FUNC_HELPER_2(func) : (ObjFunc)func)
#define VALIDATE_FUNC_3ARGS(func)                                            \
    (0 ? VALIDATE_FUNC_HELPER_3(func) : (ObjFunc)func)
#define VALIDATE_FUNC_4ARGS(func)                                            \
    (0 ? VALIDATE_FUNC_HELPER_4(func) : (ObjFunc)func)
#define VALIDATE_FUNC_5ARGS(func)                                            \
    (0 ? VALIDATE_FUNC_HELPER_5(func) : (ObjFunc)func)
#define VALIDATE_FUNC_6ARGS(func)                                            \
    (0 ? VALIDATE_FUNC_HELPER_6(func) : (ObjFunc)func)


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
    ObjFunc_1ARGS handler;
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
    ObjFunc_1ARGS handler;
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
    ObjFunc_1ARGS handler;
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

// The following helper macros are similar to GVAR_FUNC, but perform stricter
// validation of the function passed in; in particular, it is checked that it
// has the correct return and argument types, and the correct number of
// arguments.
#define GVAR_OPER_0ARGS(name, operation)                                     \
    {                                                                        \
        #name, 0, "", operation,                                             \
            VALIDATE_FUNC_0ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_OPER_1ARGS(name, a1, operation)                                 \
    {                                                                        \
        #name, 1, #a1, operation,                                            \
            VALIDATE_FUNC_1ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_OPER_2ARGS(name, a1, a2, operation)                             \
    {                                                                        \
        #name, 2, #a1 "," #a2, operation,                                    \
            VALIDATE_FUNC_2ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_OPER_3ARGS(name, a1, a2, a3, operation)                         \
    {                                                                        \
        #name, 3, #a1 "," #a2 "," #a3, operation,                            \
            VALIDATE_FUNC_3ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_OPER_4ARGS(name, a1, a2, a3, a4, operation)                     \
    {                                                                        \
        #name, 4, #a1 "," #a2 "," #a3 "," #a4, operation,                    \
            VALIDATE_FUNC_4ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_OPER_5ARGS(name, a1, a2, a3, a4, a5, operation)                 \
    {                                                                        \
        #name, 5, #a1 "," #a2 "," #a3 "," #a4 "," #a5, operation,            \
            VALIDATE_FUNC_5ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_OPER_6ARGS(name, a1, a2, a3, a4, a5, a6, operation)             \
    {                                                                        \
        #name, 6, #a1 "," #a2 "," #a3 "," #a4 "," #a5 "," #a6, operation,    \
            VALIDATE_FUNC_6ARGS(Func##name), __FILE__ ":" #name              \
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

// The following helper macros are similar to GVAR_FUNC, but perform stricter
// validation of the function passed in; in particular, it is checked that it
// has the correct return and argument types, and the correct number of
// arguments.
#define GVAR_FUNC_0ARGS(name)                                                \
    {                                                                        \
        #name, 0, "",                                                        \
            VALIDATE_FUNC_0ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_FUNC_1ARGS(name, a1)                                            \
    {                                                                        \
        #name, 1, #a1,                                                       \
            VALIDATE_FUNC_1ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_FUNC_2ARGS(name, a1, a2)                                        \
    {                                                                        \
        #name, 2, #a1 "," #a2,                                               \
            VALIDATE_FUNC_2ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_FUNC_3ARGS(name, a1, a2, a3)                                    \
    {                                                                        \
        #name, 3, #a1 "," #a2 "," #a3,                                       \
            VALIDATE_FUNC_3ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_FUNC_4ARGS(name, a1, a2, a3, a4)                                \
    {                                                                        \
        #name, 4, #a1 "," #a2 "," #a3 "," #a4,                               \
            VALIDATE_FUNC_4ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_FUNC_5ARGS(name, a1, a2, a3, a4, a5)                            \
    {                                                                        \
        #name, 5, #a1 "," #a2 "," #a3 "," #a4 "," #a5,                       \
            VALIDATE_FUNC_5ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_FUNC_6ARGS(name, a1, a2, a3, a4, a5, a6)                        \
    {                                                                        \
        #name, 6, #a1 "," #a2 "," #a3 "," #a4 "," #a5 "," #a6,               \
            VALIDATE_FUNC_6ARGS(Func##name), __FILE__ ":" #name              \
    }

#define GVAR_FUNC_XARGS(name, nargs, args)                                   \
    {                                                                        \
        #name, nargs, args,                                                  \
            VALIDATE_FUNC_1ARGS(Func##name), __FILE__ ":" #name              \
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
Int ActivateModule(StructInitInfo * info);


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
*F  LookupStaticModule(<name>)
*/
StructInitInfo * LookupStaticModule(const char * name);


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
