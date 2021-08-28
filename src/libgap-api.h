/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

//// LibGAP API - API for using GAP as shared library.

#ifndef LIBGAP_API_H
#define LIBGAP_API_H

#ifdef __cplusplus
extern "C" {
#endif

#include "system.h"

#include <setjmp.h>


#ifdef __GNUC__
#define GAP_unlikely(x) __builtin_expect(!!(x), 0)
#else
#define GAP_unlikely(x) (x)
#endif


#ifndef GAP_ENTER_DEBUG
#define GAP_ENTER_DEBUG 0
#endif


extern jmp_buf * GAP_GetReadJmpError(void);
extern void GAP_EnterDebugMessage_(char * message, char * file, int line);
extern void GAP_EnterStack_(void *);
extern void GAP_LeaveStack_(void);
extern int  GAP_Error_Prejmp_(const char *, int);
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
// In general user code should use the more general GAP_Enter()/Leave()
// macros defined below, as these also specify a terminal point for unhandled
// GAP errors to bubble up to.  However, GAP_EnterStack() and
// GAP_LeaveStack() should still be used in the definition of a custom error
// handling callback as passed to GAP_Initialize().  Using the more general
// GAP_Enter() in this case will result in crashes if the error handler is
// entered recursively (you don't want the GAP error handling code to cause a
// longjmp into the error callback itself since then the error callback will
// never be returned from).
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

#define GAP_LeaveStack() GAP_LeaveStack_();


#define GAP_Error_Setjmp()                                                   \
    (GAP_unlikely(GAP_Error_Prejmp_(__FILE__, __LINE__)) ||                  \
     GAP_Error_Postjmp_(_setjmp(*GAP_GetReadJmpError())))


// Code which uses the GAP API exposed by this header file should sandwich
// any such calls between uses of the GAP_Enter() and GAP_Leave() macro as
// follows:
//
// int ok = GAP_Enter();
// if (ok) {
//     ... // any number of calls to GAP APIs
// }
// GAP_Leave();
//
// This is in particular crucial if your code keeps references to any GAP
// functions in local variables: Calling GAP_Enter() ensures that GAP is
// aware of such references, and will not garbage collect the referenced
// objects. Failing to use these macros properly can lead to crashes, or
// worse, silent memory corruption. You have been warned!
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
//   needs to figure out (to the extent possible) the base address of the
//   stack frame from which it is called.
//
// * GAP_Error_Setjmp() effectively calls setjmp to the STATE(ReadJmpError)
//   longjmp buffer, so that read errors which occur in GAP that are not
//   otherwise "handled" by a GAP_TRY { } block have a logical place
//   to return to.  It returns 1 if no error occurred, and 0 if returning
//   from an error.
#define GAP_Enter()                                                          \
    GAP_Error_Setjmp();                                                      \
    GAP_EnterStack()

#define GAP_Leave() GAP_LeaveStack()


////
//// Setup and initialisation
////

typedef void (*GAP_CallbackFunc)(void);

// TODO: document this function
void GAP_Initialize(int              argc,
                    char **          argv,
                    GAP_CallbackFunc markBagsCallback,
                    GAP_CallbackFunc errorCallback,
                    int              handleSignals);


////
//// Garbage collector
////

// Manual management of the GAP garbage collector: for cases where you want
// a GAP object to be long-lived beyond the context of the stack frame where
// it was created, it is necessary to call GAP_MarkBag on the object when
// the garbage collector is run by the markBagsCallback function passed to
// GAP_Initialize.
void GAP_MarkBag(Obj obj);

// Manually run the garbage collector.
// A <full> collection checks all previously allocated objects, including those
// that have survived at least one previous garbage collection.
// A partial collection will attempt to clean up only recently allocated
// objects which have not been garbage-collected yet, and is hence normally
// a faster operation.
void GAP_CollectBags(BOOL full);


////
//// program evaluation and execution
////

// Evaluate a string of GAP commands.
//
// To see an example of how to use this function see tst/testlibgap/basic.c
//
// TODO: properly document this function
Obj GAP_EvalString(const char * cmd);


////
//// variables
////

// Returns the value of the global GAP variable with name <name>, or NULL if
// no global variable with this name is defined.
Obj GAP_ValueGlobalVariable(const char * name);

// Checks if assigning to the global GAP variable <name> is possible, by
// verifying that <name> is not the name of a read-only or constant variable.
int GAP_CanAssignGlobalVariable(const char * name);

// Assign <value> to the global GAP variable <name>. If <name> is the name of
// a readonly or constant variable, an error is raised.
void GAP_AssignGlobalVariable(const char * name, Obj value);


////
//// arithmetic
////

// Returns a nonzero value if the object <a> is equal to the object <b>, and
// zero otherwise.
int GAP_EQ(Obj a, Obj b);

// Returns a nonzero value if the object <a> is less than the object <b>, and
// zero otherwise.
int GAP_LT(Obj a, Obj b);

// Returns a nonzero value if the object <a> is a member of the object <b>,
// and zero otherwise.
int GAP_IN(Obj a, Obj b);

// Returns the sum of the two objects <a> and <b>.
Obj GAP_SUM(Obj a, Obj b);

// Returns the difference of the two objects <a> and <b>.
Obj GAP_DIFF(Obj a, Obj b);

// Returns the product of the two objects <a> and <b>.
Obj GAP_PROD(Obj a, Obj b);

// Returns the quotient of the object <a> by the object <b>.
Obj GAP_QUO(Obj a, Obj b);

// Returns the left quotient of the object <a> by the object <b>.
Obj GAP_LQUO(Obj a, Obj b);

// Returns the power of the object <a> by the object <a>.
Obj GAP_POW(Obj a, Obj b);

// Returns the commutator of the two objects <a> and <b>.
Obj GAP_COMM(Obj a, Obj b);

// Returns the remainder of the object <a> by the object <b>.
Obj GAP_MOD(Obj a, Obj b);


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
Obj GAP_CallFuncList(Obj func, Obj args);

// Call the GAP object <func> as a function with arguments given
// as an array <args> with <narg> entries.
Obj GAP_CallFuncArray(Obj func, UInt narg, Obj args[]);

// Call the GAP object <func> as a function with 0 arguments.
Obj GAP_CallFunc0Args(Obj func);

// Call the GAP object <func> as a function with 1 argument.
Obj GAP_CallFunc1Args(Obj func, Obj a1);

// Call the GAP object <func> as a function with 2 arguments.
Obj GAP_CallFunc2Args(Obj func, Obj a1, Obj a2);

// Call the GAP object <func> as a function with 3 arguments.
Obj GAP_CallFunc3Args(Obj func, Obj a1, Obj a2, Obj a3);


////
//// floats
////

// Returns 1 if <obj> is a GAP machine float, 0 if not.
Int GAP_IsMacFloat(Obj obj);

// Returns the value of the GAP machine float object <obj>.
// If <obj> is not a machine float object, an error is raised.
double GAP_ValueMacFloat(Obj obj);

// Returns a new GAP machine float with value <x>.
Obj GAP_NewMacFloat(double x);


////
//// integers
////

// Returns 1 if <obj> is a GAP integer, 0 if not.
int GAP_IsInt(Obj obj);

// Returns 1 if <obj> is a GAP small (aka immediate) integer, 0 if not.
int GAP_IsSmallInt(Obj obj);

// Returns 1 if <obj> is a GAP large integer, 0 if not.
int GAP_IsLargeInt(Obj obj);


// Construct a GAP integer object from the limbs at which <limbs> points (for
// a definition of "limbs", please consult the comment at the top of
// `integer.c`). The absolute value of <size> determines the number of limbs.
// If <size> is zero, then `INTOBJ_INT(0)` is returned. Otherwise, the sign
// of the returned integer object is determined by the sign of <size>.
//
// Note that GAP automatically reduces and normalized the integer object,
// i.e., it will discard any leading zeros; and if the integer fits into a
// small integer, it will be returned as such.
Obj GAP_MakeObjInt(const UInt * limbs, Int size);

// Return a GAP integer object with value equal to <val>.
Obj GAP_NewObjIntFromInt(Int val);

// Return an integer equal to the given GAP integer object. If <obj> is not
// a GAP integer, or does not fit into an Int, an error is raised.
//
// If `GAP_IsSmallInt(obj)` return 1, then it is guaranteed that this will
// succeed and no error is raised.
Int GAP_ValueInt(Obj);

// If <obj> is a GAP integer, returns the number of limbs needed to store the
// integer, times the sign. If <obj> is the integer 0, then 0 is returned. If
// <obj> is any other small integer, then 1 or -1 is returned, depending on
// its sign.
//
// If <obj> is not a GAP integer, an error is raised.
Int GAP_SizeInt(Obj obj);

// Returns a pointer to the limbs of a the GAP large integer <obj>.
// If <obj> is not a GAP large integer, then NULL is returned.
//
// Note: The pointer returned by this function is only valid until the next
// GAP garbage collection. In particular, if you use any GAP APIs, then you
// should assume that the pointer became stale. Barring that, you may safely
// copy, inspect, or even modify the content of the string buffer.
const UInt * GAP_AddrInt(Obj obj);


////
//// lists
////

// Returns 1 if <obj> is a GAP list, 0 if not.
int GAP_IsList(Obj obj);

// Returns the length of the given GAP list.
// If <list> is not a GAP list, an error may be raised.
UInt GAP_LenList(Obj list);

// Assign <val> at position <pos> into the GAP list <list>.
// If <val> is zero, then this unbinds the list entry.
// If <list> is not a GAP list, an error may be raised.
void GAP_AssList(Obj list, UInt pos, Obj val);

// Returns the element at the position <pos> in the GAP list <list>.
// Returns 0 if there is no entry at the given position.
// Also returns 0 if <pos> is out of bounds, i.e., if <pos> is zero,
// or larger than the length of the list.
// If <list> is not a GAP list, an error may be raised.
Obj GAP_ElmList(Obj list, UInt pos);

// Returns a new empty plain list with capacity <capacity>
Obj GAP_NewPlist(Int capacity);

// Returns a new range with <len> elements, starting at <low>, and proceeding
// in increments of <inc>. So the final element in the range will be equal to
// <high> := <low> + <inc> * (<len> - 1).
//
// Note that <inc> must be non-zero, and all three arguments as
// well as the value <high> must fit into a GAP small integer.
// If any of these conditions is violated, then GAP_Fail is returned.
Obj GAP_NewRange(Int len, Int low, Int inc);


////
//// matrix obj
////

// Note that the meaning of the following filters is not self-explanatory,
// see the chapter "Vector and Matrix Objects" in the GAP Reference Manual.
// `GAP_IsMatrixOrMatrixObj` checks whether the argument is an abstract
// 2-dim. array; such objects admit access to entries via `GAP_ElmMat`,
// one can ask for the numbers of rows and columns via `GAP_NrRows` and
// `GAP_NrCols`, respectively, etc.
// `GAP_IsMatrix` checks for special cases that are nonempty list of lists
// with additional properties; often these are plain lists.
// `GAP_IsMatrixObj` checks for special cases that are not plain lists.

// Returns 1 if <obj> is a GAP matrix or matrix obj, 0 if not.
int GAP_IsMatrixOrMatrixObj(Obj obj);

// Returns 1 if <obj> is a GAP matrix, 0 if not.
int GAP_IsMatrix(Obj obj);

// Returns 1 if <obj> is a GAP matrix obj, 0 if not.
int GAP_IsMatrixObj(Obj obj);

// Returns the number of rows of the given GAP matrix or matrix obj.
// If <mat> is not a GAP matrix or matrix obj, an error may be raised.
UInt GAP_NrRows(Obj mat);

// Returns the number of columns of the given GAP matrix or matrix obj.
// If <mat> is not a GAP matrix or matrix obj, an error may be raised.
UInt GAP_NrCols(Obj mat);

// Assign <val> at position <pos> into the GAP matrix obj <mat>.
// If <val> is zero, then this unbinds the list entry.
// If <mat> is not a GAP matrix obj, an error may be raised.
void GAP_AssMat(Obj mat, UInt row, UInt col, Obj val);

// Returns the element at the <row>, <col> in the GAP matrix obj <mat>.
// Returns 0 if <row> or <col> are out of bounds, i.e., if either
// is zero, or larger than the number of rows respectively columns of the list.
// If <mat> is not a GAP matrix obj, an error may be raised.
Obj GAP_ElmMat(Obj mat, UInt row, UInt col);


////
//// records
////

// Returns 1 if <obj> is a GAP record, 0 if not.
int GAP_IsRecord(Obj obj);

// Assign <val> to component given by <name> in the GAP record <rec>.
// If <val> is zero, then this unbinds the record entry.
// If <record> is not a GAP record, an error may be raised.
void GAP_AssRecord(Obj rec, Obj name, Obj val);

// Returns the component given by <name> in the GAP record <rec>.
// Returns 0 if there is no entry of the given name.
// If <rec> is not a GAP record, an error may be raised.
Obj GAP_ElmRecord(Obj rec, Obj name);

// Returns a new empty plain record with capacity <capacity>.
Obj GAP_NewPrecord(Int capacity);


////
//// strings
////

// Returns 1 if <obj> is a GAP string, 0 if not.
int GAP_IsString(Obj obj);

// Returns the length of the given GAP string.
// If <string> is not a GAP string, an error may be raised.
UInt GAP_LenString(Obj string);

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
char * GAP_CSTR_STRING(Obj obj);

// Returns a new mutable GAP string containing a copy of the given NULL
// terminated C string.
Obj GAP_MakeString(const char * string);

// Returns a new mutable GAP string containing a copy of the given
// C string of given length (in bytes).
Obj GAP_MakeStringWithLen(const char * string, UInt len);

// Returns a immutable GAP string containing a copy of the given NULL
// terminated C string.
Obj GAP_MakeImmString(const char * string);

// Returns the value of the GAP character object <obj>.
// If <obj> is not a GAP character object, it returns -1.
Int GAP_ValueOfChar(Obj obj);

// Returns the GAP character object with value <obj>.
Obj GAP_CharWithValue(UChar obj);

#ifdef __cplusplus
}
#endif

#endif
