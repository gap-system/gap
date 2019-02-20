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

/****************************************************************************
**
*F  COUNT_TRUES_BLOCK( <block> ) . . . . . . . . . . .  count number of trues
**
**  'COUNT_TRUES_BLOCK( <block> )' returns the number of 1 bits in the
**  UInt <block>. Two implementations are included below. One uses the
**  gcc builtin __builtin_popcount which usually generates the popcntl
**  or popcntq instruction on sufficiently recent CPUs. The other uses
**  the algorithm described in the original comment below:
**
**  The sequence to compute the  number of bits in  a block is quite  clever.
**  The idea is that after the <i>-th instruction each subblock of $2^i$ bits
**  holds the number of   bits of this  subblock  in the original block  <m>.
**  This is illustrated in the example below for a block of with 8 bits:
**
**       // a b c d e f g h
**      m = (m & 0x55)       +  ((m >> 1) & 0x55);
**       // . b . d . f . h  +  . a . c . e . g   =  a+b c+d e+f g+h
**      m = (m & 0x33)       +  ((m >> 2) & 0x33);
**       // . . c+d . . g+h  +  . . a+b . . e+f   =  a+b+c+d e+f+g+h
**      m = (m & 0x0f)       +  ((m >> 4) & 0x0f);
**       // . . . . e+f+g+h  +  . . . . a+b+c+d   =  a+b+c+d+e+f+g+h
**
**  In the actual  code  some unnecessary mask  have  been removed, improving
**  performance quite a bit,  because masks are 32  bit immediate values  for
**  which most RISC  processors need two  instructions to load them.  Talking
**  about performance.  The code is  close to optimal,  it should compile  to
**  only about  22 MIPS  or SPARC instructions.   Dividing the  block into  4
**  bytes and looking up the number of bits  of a byte in a  table may be 10%
**  faster, but only if the table lives in the data cache.
**
**  At this time (2017) the optimum choice of implementation for this
**  function as used seems to be use the gcc builtin on all systems --
**  but see the comments below in the documentation of
**  'COUNT_TRUES_BLOCKS'.
**
*/
static inline UInt COUNT_TRUES_BLOCK(UInt block)
{
#if USE_POPCNT && defined(HAVE___BUILTIN_POPCOUNTL)
    return __builtin_popcountl(block);
#else
#ifdef SYS_IS_64_BIT
    block =
        (block & 0x5555555555555555L) + ((block >> 1) & 0x5555555555555555L);
    block =
        (block & 0x3333333333333333L) + ((block >> 2) & 0x3333333333333333L);
    block = (block + (block >> 4)) & 0x0f0f0f0f0f0f0f0fL;
    block = (block + (block >> 8));
    block = (block + (block >> 16));
    block = (block + (block >> 32)) & 0x00000000000000ffL;
#else
    block = (block & 0x55555555) + ((block >> 1) & 0x55555555);
    block = (block & 0x33333333) + ((block >> 2) & 0x33333333);
    block = (block + (block >> 4)) & 0x0f0f0f0f;
    block = (block + (block >> 8));
    block = (block + (block >> 16)) & 0x000000ff;
#endif
    return block;
#endif
}

/****************************************************************************
**
*F  COUNT_TRUES_BLOCKS( <ptr>, <nblocks> )
**
**  'COUNT_TRUES_BLOCKS( <ptr>, <nblocks> )' returns the total number of 1
**  bits in the array of UInt values starting at <ptr> and including a total
**  of <nblocks> UInts. The only reason this function is really needed is
**  that, owing to hardware bugs and compiler peculiarities current in 2017,
**  (see http://danluu.com/assembly-intrinsics/ or
**  https://stackoverflow.com/questions/25078285?) manually unrolling this
**  loop makes the code substantially faster on almost all CPUS.
**
**  This interacts strangely with the choice of algorithm for
**  COUNT_TRUES_BLOCK above. Without the loop unrolling, not using the gcc
**  builtin is sometimes faster, apparently because it allows the compiler
**  to unroll the loop and then generate SSE or AVX code to process multiple
**  words at once. With the loop unrolling the builtin is always faster, and
**  will itself generate AVX code when compiling for suitable processors.
**
**  TODO: monitor this situation periodically.
*/
static inline UInt COUNT_TRUES_BLOCKS(const UInt * ptr, UInt nblocks)
{
    UInt n = 0;
    while (nblocks >= 4) {
        UInt n1 = COUNT_TRUES_BLOCK(*ptr++);
        UInt n2 = COUNT_TRUES_BLOCK(*ptr++);
        UInt n3 = COUNT_TRUES_BLOCK(*ptr++);
        UInt n4 = COUNT_TRUES_BLOCK(*ptr++);
        n += n1 + n2 + n3 + n4;
        nblocks -= 4;
    }
    while (nblocks) {
        n += COUNT_TRUES_BLOCK(*ptr++);
        nblocks--;
    }
    // return the number of bits
    return n;
}


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
    return ((to == BIPEB - 1) ? 0 : (1L << (to + 1))) - (1L << from);
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
            frombit = 0;
            tobit = 0;
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
            frombit = 0;
            CopyInWord(toblock, 0, nbits - 1, *fromblock, tobit);
        }
    }
}


#endif
