//// LibGAP API - API for using GAP as shared library.

#ifndef LIBGAP_API_H
#define LIBGAP_API_H

#include "system.h"


#ifdef __GNUC__
#define GAP_unlikely(x) __builtin_expect(!!(x), 0)
#else
#define GAP_unlikely(x) (x)
#endif


#ifndef GAP_ENTER_DEBUG
#define GAP_ENTER_DEBUG 0
#endif


extern syJmp_buf * GAP_GetReadJmpError(void);
extern void GAP_EnterDebugMessage_(char * message, char * file, int line);
extern void GAP_EnterStack_(void *);
extern void GAP_LeaveStack_(void);
extern int GAP_Error_Prejmp_(const char *, int);
extern void GAP_Error_Postjmp_Returning_(void);


static inline int GAP_Error_Postjmp_(int JumpRet)
{
    if (GAP_unlikely(JumpRet != 0)) {
        GAP_Error_Postjmp_Returning_();
        return 0;
    }

    return 1;
}


#if GAP_ENTER_DEBUG
#define GAP_ENTER_DEBUG_MESSAGE(message, file, line)                         \
    GAP_EnterDebugMessage_(message, file, line)
#else
#define GAP_ENTER_DEBUG_MESSAGE(message, file, line)                         \
    do {                                                                     \
    } while (0)
#endif


// Code which uses the GAP API and/or which keeps references to any GAP
// objects in local variables must be bracketed by uses of GAP_EnterStack()
// and GAP_LeaveStack(), in particular when using the GASMAN garbage
// collector; otherwise GAP objects may be garbage collected while still in
// use.
//
// In general user code should use the more general GAP_Enter()/Leave() macros
// defined below, as these also specify a terminal point for unhandled GAP
// errors to bubble up to.  However, GAP_EnterStack() and GAP_LeaveStack()
// should still be used in the defintion of a custom error handling callback as
// passed to GAP_Initialize().  Using the more general GAP_Enter() in this case
// will result in crashes if the error handler is entered recursively (you
// don't want the GAP error handling code to cause a longjmp into the error
// callback itself since then the error callback will never be returned from).
#ifdef __GNUC__
#define GAP_EnterStack()                                                     \
    do {                                                                     \
        GAP_ENTER_DEBUG_MESSAGE("EnterStack", __FILE__, __LINE__);           \
        GAP_EnterStack_(__builtin_frame_address(0));                         \
    } while (0)
#elif defined(USE_GASMAN)
#error GASMAN requires a way to get the current stack frame base address     \
       for the GAP_EnterStack() macro; normally this uses the                \
       __builtin_frame_address GNU extension so if this is not available     \
       it is necessary to provide your own implementation here.
#else
// If we're not using GASMAN in the first place GAP_EnterStack_() is not
// strictly needed, and can just be called with a dummy value
#define GAP_EnterStack()                                                     \
    do {                                                                     \
        GAP_ENTER_DEBUG_MESSAGE("EnterStack", __FILE__, __LINE__);           \
        GAP_EnterStack_(0);                                                  \
    } while (0)
#endif

#define GAP_LeaveStack()                                                     \
    GAP_LeaveStack_();


#define GAP_Error_Setjmp()                                                   \
    (GAP_unlikely(GAP_Error_Prejmp_(__FILE__, __LINE__)) ||                  \
     GAP_Error_Postjmp_(sySetjmp(*GAP_GetReadJmpError())))


// Code which uses the GAP API exposed by this header file should sandwich any
// such calls between uses of the GAP_Enter() and GAP_Leave() macro as follows:
// 
// int ok = GAP_Enter();
// if (ok) {
//     ... // any number of calls to GAP APIs
// }
// GAP_Leave();
// 
// This is in particular crucial if your code keeps references to any GAP
// functions in local variables: Calling GAP_Enter() ensures that GAP is aware
// of such references, and will not garbage collect the referenced objects.
// Failing to use these macros properly can lead to crashes, or worse, silent
// memory corruption. You have been warned!
// 
// Note that due to the implementation of these macros, you unfortunately
// cannot "simplify" the above example code to:
//
// if (GAP_Enter()) { ... } GAP_Leave();
//
// Some notes on the implementation:
//
// GAP_Enter() is a combination of GAP_Error_Setjmp() and GAP_EnterStack().
// It must call GAP_Error_Setjmp() first, to ensure that writing
// ``int ok = GAP_Enter();'' works as intended (the value assigned to ok then
// is the return value of GAP_Error_Setjmp).
//
// * GAP_EnterStack() defined and explained above must be a macro since it
//   needs to figure out (to the extent possible) the base address of the stack
//   frame from which it is called.
//
// * GAP_Error_Setjmp() effectively calls setjmp to the STATE(ReadJmpError)
//   longjmp buffer, so that read errors which occur in GAP that are not
//   otherwise "handled" by a TRY_IF_NO_ERROR { } block have a logical place
//   to return to.  It returns 1 if no error occurred, and 0 if returning from
//   an error.
#define GAP_Enter()                                                          \
    GAP_Error_Setjmp();                                                      \
    GAP_EnterStack()

#define GAP_Leave() GAP_LeaveStack()


////
//// Setup and initialisation
////

typedef void (*GAP_CallbackFunc)(void);

// TODO: document this function
extern void GAP_Initialize(int              argc,
                           char **          argv,
                           GAP_CallbackFunc markBagsCallback,
                           GAP_CallbackFunc errorCallback);


////
//// program evaluation and execution
////

// Evaluate a string of GAP commands
//
// To see an example of how to use this function see tst/testlibgap/basic.c
//
// TODO: properly document this function
extern Obj GAP_EvalString(const char * cmd);


////
//// variables
////

// Combines GVarName and ValGVar. For a given string, it returns the value
// of the gvar with name <name>, or NULL if the global variable is not
// defined.
extern Obj GAP_ValueGlobalVariable(const char * name);


////
//// arithmetic
////

extern int GAP_EQ(Obj a, Obj b);
extern int GAP_LT(Obj a, Obj b);
extern int GAP_IN(Obj a, Obj b);

extern Obj GAP_SUM(Obj a, Obj b);
extern Obj GAP_DIFF(Obj a, Obj b);
extern Obj GAP_PROD(Obj a, Obj b);
extern Obj GAP_QUO(Obj a, Obj b);
extern Obj GAP_LQUO(Obj a, Obj b);
extern Obj GAP_POW(Obj a, Obj b);
extern Obj GAP_COMM(Obj a, Obj b);
extern Obj GAP_MOD(Obj a, Obj b);


////
//// booleans
////

extern Obj GAP_True;
extern Obj GAP_False;
extern Obj GAP_Fail;


////
//// calls
////

// Call the GAP object <func> as a function with arguments given
// as a GAP list <args>.
extern Obj GAP_CallFuncList(Obj func, Obj args);

// Call the GAP object <func> as a function with arguments given
// as an array <args> with <narg> entries.
extern Obj GAP_CallFuncArray(Obj func, UInt narg, Obj args[]);


////
//// floats
////

// Returns 1 if <obj> is a GAP machine float, 0 if not.
extern Int GAP_IsMacFloat(Obj obj);

// Returns the value of the GAP machine float object <obj>.
// If <obj> is not a machine float object, an error is raised.
extern double GAP_ValueMacFloat(Obj obj);

// Returns a new GAP machine float with value <x>.
extern Obj GAP_NewMacFloat(double x);


////
//// integers
////

// Returns 1 if <obj> is a GAP integer, 0 if not.
extern int GAP_IsInt(Obj obj);

// Returns 1 if <obj> is a GAP small (aka immediate) integer, 0 if not.
extern int GAP_IsSmallInt(Obj obj);

// Returns 1 if <obj> is a GAP large integer, 0 if not.
extern int GAP_IsLargeInt(Obj obj);


// Construct an integer object from the limbs at which <limbs> points (for a
// definition of "limbs", please consult the comment at the top of
// `integer.c`). The absolute value of <size> determines the number of limbs.
// If <size> is zero, then `INTOBJ_INT(0)` is returned. Otherwise, the sign
// of the returned integer object is determined by the sign of <size>.
// //
// Note that GAP automatically reduces and normalized the integer object,
// i.e., it will discard any leading zeros; and if the integer fits into a
// small integer, it will be returned as such.
extern Obj GAP_MakeObjInt(const UInt * limbs, Int size);

// If <obj> is a GAP integer, returns the number of limbs needed to store the
// integer, times the sign. If <obj> is the integer 0, then 0 is returned. If
// <obj> is any other small integer, then 1 or -1 is returned, depending on
// its sign.
//
// If <obj> is not a GAP integer, an error is raised.
extern Int GAP_SizeInt(Obj obj);

// Returns a pointer to the limbs of a the GAP large integer <obj>.
// If <obj> is not a GAP large integer, then NULL is returned.
//
// Note: The pointer returned by this function is only valid until the next
// GAP garbage collection. In particular, if you use any GAP APIs, then you
// should assume that the pointer became stale. Barring that, you may safely
// copy, inspect, or even modify the content of the string buffer.
extern const UInt * GAP_AddrInt(Obj obj);


////
//// lists
////

// Returns 1 if <obj> is a GAP list, 0 if not.
extern int GAP_IsList(Obj obj);

// Returns the length of the given GAP list.
// If <list> is not a GAP list, an error may be raised.
extern UInt GAP_LenList(Obj list);

// Assign <val> at position <pos> into the GAP list <list>.
// If <val> is zero, then this unbinds the list entry.
// If <list> is not a GAP list, an error may be raised.
extern void GAP_AssList(Obj list, UInt pos, Obj val);

// Returns the element at the position <pos> in the list <list>.
// Returns 0 if there is no entry at the given position.
// Also returns 0 if <pos> is out of bounds, i.e., if <pos> is zero,
// or larger than the length of the list.
// If <list> is not a GAP list, an error may be raised.
extern Obj GAP_ElmList(Obj list, UInt pos);

// Returns a new empty plain list with capacity <capacity>
extern Obj GAP_NewPlist(Int capacity);


////
//// strings
////

// Returns 1 if <obj> is a GAP string, 0 if not.
extern int GAP_IsString(Obj obj);

// Returns the length of the given GAP string.
// If <string> is not a GAP string, an error may be raised.
extern UInt GAP_LenString(Obj string);

// Returns a pointer to the contents of the GAP string <string>.
// Returns 0 if <string> is not a GAP string.
//
// Note: GAP strings may contain null bytes, so to copy the full string, you
// should use `GAP_LenString` to determine its length. GAP always adds an
// additional terminating null byte.
//
// Note: The pointer returned by this function is only valid until the next
// GAP garbage collection. In particular, if you use any GAP APIs, then you
// should assume that the pointer became stale. Barring that, you may safely
// copy, inspect, or even modify the content of the string buffer.
//
// Usage example:
//    Int len = GAP_LenString(string);
//    char *buf = malloc(len + 1);
//    memcpy(buf, GAP_CSTR_STRING(string), len + 1); // copy terminator, too
//    // .. now we can safely use the content of buf
extern char * GAP_CSTR_STRING(Obj obj);

// Returns a new mutable GAP string containing a copy of the given NULL
// terminated C string.
extern Obj GAP_MakeString(const char * string);

// Returns a immutable GAP string containing a copy of the given NULL
// terminated C string.
extern Obj GAP_MakeImmString(const char * string);

// Returns the value of the GAP character object <obj>.
// If <obj> is not a GAP character object, it returns -1.
extern Int GAP_ValueOfChar(Obj obj);

// Returns the GAP character object with value <obj>.
extern Obj GAP_CharWithValue(UChar obj);

#endif
