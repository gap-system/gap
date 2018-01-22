#include <src/compiled.h>
#include <src/gap.h>
#include <src/hookintrprtr.h>
#include <src/intfuncs.h>
#include <src/iostream.h>
#include <src/objccoll.h>
#include <src/objset.h>
#include <src/profile.h>
#include <src/vec8bit.h>
#include <src/vecffe.h>
#include <src/vecgf2.h>

#ifdef HPCGAP
#include <src/hpc/aobjects.h>
#include <src/hpc/serialize.h>
#include <src/hpc/threadapi.h>
#include <src/hpc/traverse.h>
#endif

extern StructInitInfo * InitInfoGap ( void );

/****************************************************************************
**
*V  InitFuncsBuiltinModules . . . . .  list of builtin modules init functions
*/
const InitInfoFunc InitFuncsBuiltinModules[] = {

#ifdef HPCGAP
    // Traversal functionality may be needed during the initialization
    // of some modules, so set it up as early as possible
    InitInfoTraverse,
#endif

    /* global variables                                                    */
    InitInfoGVars,

    /* objects                                                             */
    InitInfoObjects,

    /* profiling and interpreter hooking information */
    InitInfoProfile,
    InitInfoHookIntrprtr,

    /* scanner, reader, interpreter, coder, caller, compiler               */
    InitInfoIO,
    InitInfoScanner,
    InitInfoRead,
    InitInfoCalls,
    InitInfoExprs,
    InitInfoStats,
    InitInfoCode,
    InitInfoVars,       /* must come after InitExpr and InitStats */
    InitInfoFuncs,
    InitInfoOpers,
    InitInfoIntrprtr,
    InitInfoCompiler,

    /* arithmetic operations                                               */
    InitInfoAriths,
    InitInfoInt,
    InitInfoIntFuncs,
    InitInfoRat,
    InitInfoCyc,
    InitInfoFinfield,
    InitInfoPermutat,
    InitInfoTrans,
    InitInfoPPerm,
    InitInfoBool,
    InitInfoMacfloat,

    /* record packages                                                     */
    InitInfoRecords,
    InitInfoPRecord,

    /* list packages                                                       */
    InitInfoLists,
    InitInfoListOper,
    InitInfoListFunc,
    InitInfoPlist,
    InitInfoSet,
    InitInfoVector,
    InitInfoVecFFE,
    InitInfoBlist,
    InitInfoRange,
    InitInfoString,
    InitInfoGF2Vec,
    InitInfoVec8bit,

    /* free and presented groups                                           */
    InitInfoFreeGroupElements,
    InitInfoCosetTable,
    InitInfoTietze,
    InitInfoPcElements,
    InitInfoSingleCollector,
    InitInfoCombiCollector,
    InitInfoPcc,
    InitInfoDeepThought,
    InitInfoDTEvaluation,

    /* algebras                                                            */
    InitInfoSCTable,

    /* save and load workspace, weak pointers                              */
    InitInfoWeakPtr,
    InitInfoSaveLoad,

    /* input and output                                                    */
    InitInfoStreams,
    InitInfoSysFiles,
    InitInfoIOStream,

    /* main module                                                         */
    InitInfoGap,

    // objsets / objmaps
    InitInfoObjSets,

#ifdef HPCGAP
    /* threads                                                             */
    InitInfoThreadAPI,
    InitInfoAObjects,
    InitInfoSerialize,
#endif

    0
};
