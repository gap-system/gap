#ifndef GAP_TRAVERSE_H
#define GAP_TRAVERSE_H

/*
 * Functionality to traverse nested object structures.
 */

typedef void (*TraversalFunction)(Obj);

extern TraversalFunction TraversalFunc[];

Obj ReachableObjectsFrom(Obj obj);
Obj CopyReachableObjectsFrom(Obj obj, int delimited, int asList, int imm);
Obj CopyTraversed(Obj traversed);
int PreMakeImmutableCheck(Obj obj);

#endif // GAP_TRAVERSE_H
