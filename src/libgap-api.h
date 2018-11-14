//// LibGAP API - API for using GAP as shared library.

#ifndef LIBGAP_API_H
#define LIBGAP_API_H

#include "system.h"


////
//// Setup and initialisation
////

typedef void (*GAP_CallbackFunc)(void);

// TODO: document this function
extern void GAP_Initialize(int              argc,
                           char **          argv,
                           char **          env,
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
// as an array <args> with <narg> entries
extern Obj GAP_CallFuncArray(Obj func, UInt narg, Obj args[]);


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

// Returns the value of the GAP char <obj>.
// If <obj> is not a GAP character object, it returns -1.
extern Int GAP_ValueOfChar(Obj obj);

// Returns the char Obj corresponding to <obj>
extern Obj GAP_CharWithValue(UChar obj);

#endif
