/***********************************************************************
 **
 *W  gapstate.c      GAP source                 Markus Pfeiffer
 **
 **
 */

#include "gapstate.h"

#include <assert.h>

typedef struct {
    UInt size;
    Int offset;
    ModuleConstructor constructor;
    ModuleDestructor destructor;
} StateDescriptor;

static StateDescriptor StateDescriptors[STATE_MAX_HANDLERS];
static Int StateDescriptorCount = 0;
static Int StateNextFreeOffset = 0; // Start of next free memory area (as offset into GAPState.StateSlots)

GAPState MainGAPState;

void InitGAPState(GAPState * state)
{
    RunModuleConstructors(state);
}

void DestroyGAPState(GAPState * state)
{
    RunModuleDestructors(state);
}

Int RegisterModuleState(UInt size, ModuleConstructor constructor, ModuleDestructor destructor)
{
    StateDescriptor * handler;

    // if not at least one of the three arguments is non-zero, it doesn't make
    // sense to call this function
    assert(size || constructor || destructor);

    // check that we have enough free space
    assert((STATE_SLOTS_SIZE - StateNextFreeOffset) >= size);
    assert(StateDescriptorCount < STATE_MAX_HANDLERS);

    handler = StateDescriptors + StateDescriptorCount++;
    handler->size = size;

    handler->offset = StateNextFreeOffset;
    StateNextFreeOffset += size;
    StateNextFreeOffset = (StateNextFreeOffset + sizeof(Obj)-1) & ~(sizeof(Obj)-1);

    handler->constructor = constructor;
    handler->destructor = destructor;

    return handler->offset;
}

void RunModuleConstructors(GAPState *state)
{
    Int i;
    for (i = 0; i < StateDescriptorCount; i++) {
        StateDescriptor * handler = StateDescriptors + i;
        if (handler->constructor)
            handler->constructor();
    }
}

void RunModuleDestructors(GAPState *state)
{
    Int i;
    for (i = 0; i < StateDescriptorCount; i++) {
        StateDescriptor * handler = StateDescriptors + i;
        if (handler->destructor)
            handler->destructor();
    }
}
