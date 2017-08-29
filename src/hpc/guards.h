#ifndef GAP_HPC_GUARD_H
#define GAP_HPC_GUARD_H

#if !defined(HPCGAP)

/*
 * HPC-GAP stubs.
 */

#define ReadGuard(bag) ((void) 0)
#define WriteGuard(bag) ((void) 0)

static inline Bag ImpliedWriteGuard(Bag bag)
{
  return bag;
}

#else

#include <src/hpc/tls.h>

#ifdef VERBOSE_GUARDS
void WriteGuardError(Bag bag,
    const char *file, unsigned line, const char *func, const char *expr);
void ReadGuardError(Bag bag,
    const char *file, unsigned line, const char *func, const char *expr);
#else
void WriteGuardError(Bag bag);
void ReadGuardError(Bag bag);
#endif

#ifdef VERBOSE_GUARDS
#define WriteGuard(bag) WriteGuardFull(bag, __FILE__, __LINE__, __FUNCTION__, #bag)
static ALWAYS_INLINE Bag WriteGuardFull(Bag bag,
  const char *file, unsigned line, const char *func, const char *expr)
#else
static ALWAYS_INLINE Bag WriteGuard(Bag bag)
#endif
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return bag;
  region = REGION(bag);
  if (region && region->owner != realTLS && region->alt_owner != realTLS)
    WriteGuardError(bag
#ifdef VERBOSE_GUARDS
    , file, line, func, expr
#endif
    );
  return bag;
}

static inline Bag ImpliedWriteGuard(Bag bag)
{
  return bag;
}

static inline int CheckWriteAccess(Bag bag)
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return 1;
  region = REGION(bag);
  return !(region && region->owner != realTLS && region->alt_owner != realTLS)
    || TLS(DisableGuards) >= 2;
}

static inline int CheckExclusiveWriteAccess(Bag bag)
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return 1;
  region = REGION(bag);
  if (!region)
    return 0;
  return region->owner == realTLS || region->alt_owner == realTLS
    || TLS(DisableGuards) >= 2;
}

#ifdef VERBOSE_GUARDS
#define ReadGuard(bag) ReadGuardFull(bag, __FILE__, __LINE__, __FUNCTION__, #bag)
static ALWAYS_INLINE Bag ReadGuardFull(Bag bag,
  const char *file, unsigned line, const char *func, const char *expr)
#else
static ALWAYS_INLINE Bag ReadGuard(Bag bag)
#endif
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return bag;
  region = REGION(bag);
  if (region && region->owner != realTLS &&
      !region->readers[TLS(threadID)] && region->alt_owner != realTLS)
    ReadGuardError(bag
#ifdef VERBOSE_GUARDS
    , file, line, func, expr
#endif
    );
  return bag;
}


static ALWAYS_INLINE Bag ImpliedReadGuard(Bag bag)
{
  return bag;
}


static ALWAYS_INLINE int CheckReadAccess(Bag bag)
{
  Region *region;
  if (!IS_BAG_REF(bag))
    return 1;
  region = REGION(bag);
  return !(region && region->owner != realTLS &&
    !region->readers[TLS(threadID)] && region->alt_owner != realTLS)
    || TLS(DisableGuards) >= 2;
}

#endif // HPCGAP

#endif // GAP_HPC_GUARD_H
