#ifndef GAP_TLS_H
#define GAP_TLS_H

/*
 * This header is a placeholder for the HPC-GAP header of the same name. It
 * is here to allow us to reduce diffs between the code bases of HPC-GAP
 * and classic GAP.
 */

#define ReadGuard(bag) NOOP
#define WriteGuard(bag) NOOP

static inline Bag ImpliedWriteGuard(Bag bag)
{
  return bag;
}

#endif
