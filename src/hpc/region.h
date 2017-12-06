#ifndef GAP_REGION_H
#define GAP_REGION_H

#include <src/system.h>

#ifndef HPCGAP
#error This header is only meant to be used with HPC-GAP
#endif

#include <src/hpc/atomic.h>

typedef struct
{
    void *lock;       /* void * so that we don't have to include pthread.h always */
    Bag obj;          /* references a unique T_REGION object per region */
    Bag name;         /* name of the region, or a null pointer */
    Int prec;         /* locking precedence */
    int fixed_owner;
    void *owner;      /* opaque thread descriptor */
    void *alt_owner;  /* for paused threads */
    int count_active; /* whether we counts number of (contended) locks */
    AtomicUInt locks_acquired;    /* number of times the lock was acquired successfully */
    AtomicUInt locks_contended;   /* number of failed attempts at acuiring the lock */
    unsigned char readers[];     /* this field extends with number of threads
                                     don't add any fields after it */
} Region;

/****************************************************************************
**
*F  NewRegion() . . . . . . . . . . . . . . . . allocate a new region
*/

Region *NewRegion(void);

/****************************************************************************
**
*F  REGION(<bag>)  . . . . . . . .  return the region containing the bag
*F  RegionBag(<bag>)   . . . . . .  return the region containing the bag
**
**  RegionBag() also contains a memory barrier.
*/
#define REGION(bag) (((Region **)(bag))[1])

Region *RegionBag(Bag bag);

#endif // GAP_REGION_H
