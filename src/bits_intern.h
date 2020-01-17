/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_BITS_INTERN_H
#define GAP_BITS_INTERN_H

#include "system.h"

#include <string.h>


#define ALL_BITS_UINT  (~(UInt)0)

/****************************************************************************
**
*F  CopyBits( <fromblock>, <from-starting-bit>, <toblock>, <to-starting-bit>,
**            <numbits> )
**
**  'CopyBits' copies <numbits> bits (numbering bits within a UInt
**   from the least significant to the most significant) starting with
**   bit number <from-starting-bit> of UInt *<fromblock> to a destination
**   starting at bit <to-starting-bit> of *<toblock>. The source and
**   destination are assumed to be non-overlapping.
**
**   The full function is provided as an inline function here because it is
**   used in both blister.c and vecgf2.c and the compiler can do significant
**   optimisations if some or all of <frombits>, <tobits> and <numbits> are
**   known at compile time.
*/

/* constructs a mask that selects bits <from> to <to> inclusive of a UInt */
static inline UInt MaskForCopyBits(UInt from, UInt to)
{
    return ((to == BIPEB - 1) ? 0 : ((UInt)1 << (to + 1))) - ((UInt)1 << from);
}

/* copies a block of bits from the UInt <from> to the one pointed at
   by <to> the block starts in <from> at <startbit> and ends at
   <endbit>. It is shifted left by <shift> and must still fit within a
   single word (so endbits + shift must be < BIPEB and frombits +
   shift must be non-negative */

static inline void
CopyInWord(UInt * to, UInt startbit, UInt endbit, UInt from, Int shift)
{
    UInt m = MaskForCopyBits(startbit + shift, endbit + shift);
    *to &= ~m;
    if (shift >= 0)
        *to |= ((from << shift) & m);
    else
        *to |= ((from >> -shift) & m);
}


static ALWAYS_INLINE void CopyBits(const UInt * fromblock,
                                   UInt         frombit,
                                   UInt *       toblock,
                                   UInt         tobit,
                                   UInt         nbits)
{
    UInt tailbits;
    UInt x;
    UInt wholeblocks;
    if (!nbits)
        return;
    GAP_ASSERT(frombit < BIPEB);
    GAP_ASSERT(tobit < BIPEB);
    /* If the alignment of the two data blocks matches, things are relatively
     * easy
     */
    if (frombit == tobit) {
        /* if the first and last words are the same word */
        if ((frombit + nbits) < BIPEB) {
            CopyInWord(toblock, frombit, frombit + nbits - 1, *fromblock, 0);
            return;
        }
        /* do we need to start by copying a partial word */
        if (frombit) {
            CopyInWord(toblock, frombit, BIPEB - 1, *fromblock, 0);
            fromblock++;
            toblock++;
            nbits -= (BIPEB - frombit);
        }
        /* Now move whole words */
        if ((wholeblocks = nbits / BIPEB))
            memcpy(toblock, fromblock, sizeof(UInt) * wholeblocks);
        toblock += wholeblocks;
        fromblock += wholeblocks;
        nbits %= BIPEB;
        /* Finally, we may need to finish with another partial word */
        if (nbits)
            CopyInWord(toblock, 0, nbits - 1, *fromblock, 0);
        return;
    }

    /* Otherwise the bits are not aligned and we will be shifting */

    if (tobit) {
        /* How many bits are we going to put into the first destination word
         */
        if (tobit + nbits <= BIPEB)
            tailbits = nbits;
        else
            tailbits = BIPEB - tobit;
        /* We might be able to get all we need from the first source word */
        if (frombit + tailbits <= BIPEB) {
            CopyInWord(toblock, frombit, frombit + tailbits - 1, *fromblock,
                       (tobit - frombit));
            frombit += tailbits;
        }
        else {
            CopyInWord(toblock, frombit, BIPEB - 1, *fromblock,
                       (tobit - frombit));
            fromblock++;
            CopyInWord(toblock, 0, tailbits + frombit - 1 - BIPEB,
                       fromblock[1], tobit + BIPEB - frombit);
            frombit += tailbits - BIPEB;
        }
        toblock++;
        nbits -= tailbits;
        tobit = 0;
    }

    /* Main loop for long copies fills whole blocks of destination */
    UInt m1 = MaskForCopyBits(frombit, BIPEB - 1);
    while (nbits >= BIPEB) {
        x = (*fromblock++ & m1) >> frombit;
        x |= (*fromblock & ~m1) << (BIPEB - frombit);
        *toblock++ = x;
        nbits -= BIPEB;
    }

    /* Finally we may need to fill up a partial block at destination */
    if (nbits) {
        if (frombit + nbits <= BIPEB) {
            CopyInWord(toblock, frombit, frombit + nbits - 1, *fromblock,
                       -frombit);
        }
        else {
            CopyInWord(toblock, frombit, BIPEB - 1, *fromblock, -frombit);
            fromblock++;
            nbits -= BIPEB - frombit;
            tobit = BIPEB - frombit;
            CopyInWord(toblock, 0, nbits - 1, *fromblock, tobit);
        }
    }
}


#endif
