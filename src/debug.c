#include <src/system.h>

#include <src/compiled.h>
#include <src/hookintrprtr.h>
#include <src/calls.h>
#include <src/fibhash.h>

#if defined(HAVE_BACKTRACE) && defined(PRINT_BACKTRACE)
#include <execinfo.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>

static void BacktraceHandler(int sig) NORETURN;

static void BacktraceHandler(int sig)
{
    void *       trace[32];
    size_t       size;
    const char * sigtext = "Unknown signal";
    size = backtrace(trace, 32);
    switch (sig) {
    case SIGSEGV:
        sigtext = "Segmentation fault";
        break;
    case SIGBUS:
        sigtext = "Bus error";
        break;
    case SIGINT:
        sigtext = "Interrupt";
        break;
    case SIGABRT:
        sigtext = "Abort";
        break;
    case SIGFPE:
        sigtext = "Floating point exception";
        break;
    case SIGTERM:
        sigtext = "Program terminated";
        break;
    }
    fprintf(stderr, "%s\n", sigtext);
    backtrace_symbols_fd(trace, size, fileno(stderr));
    exit(1);
}

void InstallBacktraceHandlers(void)
{
    signal(SIGSEGV, BacktraceHandler);
    signal(SIGBUS, BacktraceHandler);
    signal(SIGINT, BacktraceHandler);
    signal(SIGABRT, BacktraceHandler);
    signal(SIGFPE, BacktraceHandler);
    signal(SIGTERM, BacktraceHandler);
}

#endif


// Global array of function pointers to static inline functions.
//
// This is a trick to force compilers to emit explicit code for these
// functions at least once, so that they can be used from debuggers like
// gdb or lldb.
typedef void (*VoidFunc)(void);
VoidFunc debug_func_pointers[] = {
    (VoidFunc)ActiveGAPState,
    (VoidFunc)ADDR_OBJ,
    (VoidFunc)ADDR_PPERM2,
    (VoidFunc)ADDR_PPERM4,
    (VoidFunc)ADDR_TRANS2,
    (VoidFunc)ADDR_TRANS4,
    (VoidFunc)AlwaysNo,
    (VoidFunc)AlwaysYes,
    (VoidFunc)ARE_INTOBJS,
    (VoidFunc)ASS_LIST,
    (VoidFunc)AssConstantGVar,
    (VoidFunc)AssReadOnlyGVar,
    (VoidFunc)ASSS_LIST,
    (VoidFunc)BAG_HEADER,
    (VoidFunc)BASE_PTR_PLIST,
    (VoidFunc)BLOCKS_BLIST,
    (VoidFunc)BODY_FUNC,
    (VoidFunc)BODY_HEADER,
    (VoidFunc)C_MAKE_MED_INT,
    (VoidFunc)C_NORMALIZE_64BIT,
    (VoidFunc)C_SET_LIMB4,
    (VoidFunc)C_SET_LIMB8,
    (VoidFunc)CAPACITY_PLIST,
    (VoidFunc)CAPACITY_PREC,
    (VoidFunc)CHANGED_BAG,
    (VoidFunc)CHAR_VALUE,
    (VoidFunc)CHARS_STRING,
    (VoidFunc)CheckRecursionBefore,
    (VoidFunc)CLEAR_OBJ_FLAG,
    (VoidFunc)CODEG_PPERM,
    (VoidFunc)CONST_ADDR_OBJ,
    (VoidFunc)CONST_PTR_BAG,
    (VoidFunc)COPY_CHARS,
    (VoidFunc)COUNT_TRUES_BLOCK,
    (VoidFunc)COUNT_TRUES_BLOCKS,
    (VoidFunc)CSTR_STRING,
    (VoidFunc)CURR_FUNC,
    (VoidFunc)DEG_PPERM,
    (VoidFunc)DEG_PPERM2,
    (VoidFunc)DEG_PPERM4,
    (VoidFunc)DEG_TRANS,
    (VoidFunc)DEG_TRANS2,
    (VoidFunc)DEG_TRANS4,
    (VoidFunc)DEN_RAT,
    (VoidFunc)DETECT_INTOBJ_OVERFLOW,
    (VoidFunc)ELM_DEFAULT_LIST,
    (VoidFunc)ELM_LIST,
    (VoidFunc)ELM_PLIST,
    (VoidFunc)ELM0_LIST,
    (VoidFunc)ELMS_LIST,
    (VoidFunc)ELMV_LIST,
    (VoidFunc)ELMV0_LIST,
    (VoidFunc)ELMW_LIST,
    (VoidFunc)ENVI_FUNC,
    (VoidFunc)EXEC_STAT,
    (VoidFunc)FEXS_FUNC,
    (VoidFunc)FibHash,
    (VoidFunc)FillInVersion,
    (VoidFunc)FUNC,
#ifdef HPCGAP
    (VoidFunc)GetTLS,
#endif
    (VoidFunc)GET_ELM_PREC,
    (VoidFunc)GET_ELM_RANGE,
    (VoidFunc)GET_ELM_STRING,
    (VoidFunc)GET_INC_RANGE,
    (VoidFunc)GET_LEN_RANGE,
    (VoidFunc)GET_LEN_STRING,
    (VoidFunc)GET_LOW_RANGE,
    (VoidFunc)GET_RNAM_PREC,
    (VoidFunc)GROW_PLIST,
    (VoidFunc)GROW_STRING,
    (VoidFunc)HDLR_FUNC,
    (VoidFunc)HookedLineIntoFunction,
    (VoidFunc)HookedLineOutFunction,
    (VoidFunc)INT_INTOBJ,
    (VoidFunc)INTOBJ_INT,
    (VoidFunc)IS_BLIST_REP,
    (VoidFunc)IS_BLIST_REP_WITH_COPYING,
    (VoidFunc)IS_DENSE_LIST,
    (VoidFunc)IS_DENSE_PLIST,
    (VoidFunc)IS_FFE,
    (VoidFunc)IS_HOMOG_LIST,
    (VoidFunc)IS_INTOBJ,
    (VoidFunc)IS_LIST,
    (VoidFunc)IS_LVARS_OR_HVARS,
    (VoidFunc)IS_MODULE_BUILTIN,
    (VoidFunc)IS_MODULE_DYNAMIC,
    (VoidFunc)IS_MODULE_STATIC,
    (VoidFunc)IS_MUTABLE_PLIST,
    (VoidFunc)IS_NONNEG_INTOBJ,
    (VoidFunc)IS_PLIST,
    (VoidFunc)IS_PLIST_OR_POSOBJ,
    (VoidFunc)IS_POS_INTOBJ,
    (VoidFunc)IS_POSS_LIST,
    (VoidFunc)IS_PPERM,
    (VoidFunc)IS_PREC,
    (VoidFunc)IS_PREC_OR_COMOBJ,
    (VoidFunc)IS_RANGE,
    (VoidFunc)IS_SMALL_LIST,
    (VoidFunc)IS_SSORT_LIST,
    (VoidFunc)IS_STRING,
    (VoidFunc)IS_STRING_REP,
    (VoidFunc)IS_TABLE_LIST,
    (VoidFunc)IS_TRANS,
    (VoidFunc)ISB_LIST,
#ifdef HPCGAP
    (VoidFunc)LCKS_FUNC,
#endif
    (VoidFunc)LEN_BLIST,
    (VoidFunc)LEN_LIST,
    (VoidFunc)LEN_PLIST,
    (VoidFunc)LEN_PREC,
    (VoidFunc)LENGTH,
    (VoidFunc)MakeHighVars,
    (VoidFunc)MakeImmString,
    (VoidFunc)MakeString,
    (VoidFunc)MarkBag,
    (VoidFunc)NAME_FUNC,
    (VoidFunc)NAMS_FUNC,
    (VoidFunc)NARG_FUNC,
    (VoidFunc)NEW_PLIST,
    (VoidFunc)NEW_RANGE_NSORT,
    (VoidFunc)NEW_RANGE_SSORT,
    (VoidFunc)NEW_TRANS,
    (VoidFunc)NEW_TRANS2,
    (VoidFunc)NEW_TRANS4,
    (VoidFunc)NewWord,
    (VoidFunc)NLOC_FUNC,
    (VoidFunc)NUM_RAT,
    (VoidFunc)NUMBER_BLOCKS_BLIST,
    (VoidFunc)PLAIN_LIST,
    (VoidFunc)PLEN_SIZE_BLIST,
    (VoidFunc)PopPlist,
    (VoidFunc)POS_LIST,
    (VoidFunc)PROF_FUNC,
    (VoidFunc)PTR_BAG,
    (VoidFunc)PushPlist,
    (VoidFunc)RANK_PPERM,
    (VoidFunc)RANK_TRANS,
    (VoidFunc)RegisterStatWithHook,
    (VoidFunc)SET_BODY_FUNC,
    (VoidFunc)SET_CHAR_VALUE,
    (VoidFunc)SET_DEN_RAT,
    (VoidFunc)SET_ELM_PLIST,
    (VoidFunc)SET_ELM_PREC,
    (VoidFunc)SET_ELM_STRING,
    (VoidFunc)SET_ENVI_FUNC,
    (VoidFunc)SET_FEXS_FUNC,
    (VoidFunc)SET_HDLR_FUNC,
    (VoidFunc)SET_INC_RANGE,
#ifdef HPCGAP
    (VoidFunc)SET_LCKS_FUNC,
#endif
    (VoidFunc)SET_LEN_BLIST,
    (VoidFunc)SET_LEN_PLIST,
    (VoidFunc)SET_LEN_PREC,
    (VoidFunc)SET_LEN_RANGE,
    (VoidFunc)SET_LEN_STRING,
    (VoidFunc)SET_LOW_RANGE,
    (VoidFunc)SET_NAMS_FUNC,
    (VoidFunc)SET_NARG_FUNC,
    (VoidFunc)SET_NLOC_FUNC,
    (VoidFunc)SET_NUM_RAT,
    (VoidFunc)SET_OBJ_FLAG,
    (VoidFunc)SET_PROF_FUNC,
    (VoidFunc)SET_PTR_BAG,
    (VoidFunc)SET_RNAM_PREC,
    (VoidFunc)SET_VAL_MACFLOAT,
    (VoidFunc)SetBrkCallTo,
    (VoidFunc)SHRINK_PLIST,
    (VoidFunc)SHRINK_STRING,
    (VoidFunc)SIZE_BAG,
    (VoidFunc)SIZE_BAG_CONTENTS,
    (VoidFunc)SIZE_OBJ,
    (VoidFunc)SIZE_PLEN_BLIST,
    (VoidFunc)SIZEBAG_STRINGLEN,
    (VoidFunc)SwitchToNewLvars,
    (VoidFunc)SwitchToOldLVars,
    (VoidFunc)SwitchToOldLVarsAndFree,
    (VoidFunc)TEST_OBJ_FLAG,
    (VoidFunc)TNAM_OBJ,
    (VoidFunc)TNUM_BAG,
    (VoidFunc)TNUM_OBJ,
    (VoidFunc)UNB_LIST,
    (VoidFunc)VAL_MACFLOAT,
    (VoidFunc)VisitStatIfHooked,
};
