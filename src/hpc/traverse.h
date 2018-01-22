#ifndef GAP_TRAVERSE_H
#define GAP_TRAVERSE_H

#include <src/system.h>

/*
 * Functionality to traverse nested object structures.
 */

typedef void (*TraversalFunction)(Obj);
typedef void (*TraversalCopyFunction)(Obj copy, Obj original);

typedef enum {
    TRAVERSE_NONE,
    TRAVERSE_BY_FUNCTION,
    TRAVERSE_ALL,
    TRAVERSE_ALL_BUT_FIRST,
} TraversalMethodEnum;

// set the traversal method (and optionally, helper functions)
// for all objects with the specified tnum.
extern void SetTraversalMethod(UInt tnum,
                               TraversalMethodEnum meth,
                               TraversalFunction tf,
                               TraversalCopyFunction cf);


// helper to be called from traverse functions
extern void QueueForTraversal(Obj obj);

// helper to be called from copy functions
extern Obj ReplaceByCopy(Obj obj);


Obj ReachableObjectsFrom(Obj obj);
Obj CopyReachableObjectsFrom(Obj obj, int delimited, int asList, int imm);
Obj CopyTraversed(Obj traversed);
int PreMakeImmutableCheck(Obj obj);


#endif // GAP_TRAVERSE_H
