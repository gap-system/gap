/****************************************************************************
**
*W  blister.h                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This  file declares the functions  that mainly operate  on boolean lists.
**  Because boolean lists are  just a special case  of lists many  things are
**  done in the list package.
**
**  A *boolean list* is a list that has no holes and contains only 'true' and
**  'false'.  For  the full definition of  boolean list  see chapter "Boolean
**  Lists" in the {\GAP} Manual.  Read  also the section "More  about Boolean
**  Lists" about the different internal representations of such lists.
*/

#ifndef GAP_BLISTER_H
#define GAP_BLISTER_H

#include <src/system.h>

/****************************************************************************
**
*F  IS_BLIST_REP( <list> )  . . . . .  check if <list> is in boolean list rep
*/
static inline Int IS_BLIST_REP(Obj list)
{
    return T_BLIST <= TNUM_OBJ(list) &&
           TNUM_OBJ(list) <= T_BLIST_SSORT + IMMUTABLE;
}

/****************************************************************************
**
*F  IS_BLIST_REP_WITH_COPYING( <list> )  . . . . .check if <list> is a blist
**
**  This version of IS_PLIST also checks if 'COPYING' is set, which happens
**  during copying of object. This is only used in assertion checks, as it is
**  a (little) slower.
*/

static inline Int IS_BLIST_REP_WITH_COPYING(Obj list)
{
    UInt tnum = TNUM_OBJ(list);
#if !defined(USE_THREADSAFE_COPYING)
    if (tnum > COPYING)
        tnum -= COPYING;
#endif
    return T_BLIST <= tnum && tnum <= T_BLIST_SSORT + IMMUTABLE;
}

/****************************************************************************
**
*F  PLEN_SIZE_BLIST( <size> ) .  physical length from size for a boolean list
**
**  'PLEN_SIZE_BLIST'  computes  the  physical  length  (e.g.  the  number of
**  elements that could be stored  in a list) from the <size> (as reported by
**  'SIZE') for a boolean list.
**
*/
static inline Int PLEN_SIZE_BLIST(Int size)
{
    GAP_ASSERT(size >= 0);
    return ((size - sizeof(Obj)) / sizeof(UInt)) * BIPEB;
}


/****************************************************************************
**
*F  SIZE_PLEN_BLIST( <plen> ) . . size for a blist with given physical length
**
**  'SIZE_PLEN_BLIST' returns  the size  that a boolean list  with  room  for
**  <plen> elements must at least have.
**
*/
static inline Int SIZE_PLEN_BLIST(Int plen)
{
    GAP_ASSERT(plen >= 0);
    return sizeof(Obj) + (plen + BIPEB - 1) / BIPEB * sizeof(UInt);
}

/****************************************************************************
**
*F  LEN_BLIST( <list> ) . . . . . . . . . . . . . .  length of a boolean list
**
**  'LEN_BLIST' returns the logical length of the boolean list <list>, as a C
**  integer.
**
*/
static inline Int LEN_BLIST(Obj list)
{
    GAP_ASSERT(IS_BLIST_REP_WITH_COPYING(list));
    return INT_INTOBJ(CONST_ADDR_OBJ(list)[0]);
}


/***************************************************************************
**
*F  NUMBER_BLOCKS_BLIST(<list>) . . . . . . . . number of UInt blocks in list
**
*/
static inline Int NUMBER_BLOCKS_BLIST(Obj blist)
{
    GAP_ASSERT(IS_BLIST_REP_WITH_COPYING(blist));
    return (LEN_BLIST(blist) + BIPEB - 1) / BIPEB;
}


/****************************************************************************
**
*F  SET_LEN_BLIST( <list>, <len> )  . . . .  set the length of a boolean list
**
**  'SET_LEN_BLIST' sets the  length of the boolean list  <list> to the value
**  <len>, which must be a positive C integer.
**
*/
static inline void SET_LEN_BLIST(Obj list, Int len)
{
    GAP_ASSERT(IS_BLIST_REP_WITH_COPYING(list));
    GAP_ASSERT(len >= 0);
    ADDR_OBJ(list)[0] = INTOBJ_INT(len);
}


/****************************************************************************
**
*F  BLOCKS_BLIST( <list> )  . . . . . . . . . . first block of a boolean list
**
**  returns a pointer to the start of the data of the Boolean list
**
*/
static inline UInt * BLOCKS_BLIST_UNSAFE(Obj list)
{
    return ((UInt *)(ADDR_OBJ(list) + 1));
}

static inline UInt * BLOCKS_BLIST(Obj list)
{
    GAP_ASSERT(IS_BLIST_REP_WITH_COPYING(list));
    return BLOCKS_BLIST_UNSAFE(list);
}

static inline const UInt * CONST_BLOCKS_BLIST(Obj list)
{
    GAP_ASSERT(IS_BLIST_REP_WITH_COPYING(list));
    return ((const UInt *)(CONST_ADDR_OBJ(list) + 1));
}

/****************************************************************************
**
*F  BLOCK_ELM_BLIST( <list>, <pos> )  . . . . . . . . block of a boolean list
**
**  'BLOCK_ELM_BLIST' return the block containing the <pos>-th element of the
**  boolean list <list> as   a UInt value, which  is  also a valid left  hand
**  side.  <pos> must be a positive integer less than  or equal to the length
**  of <list>.
**
**  Note that 'BLOCK_ELM_BLIST' is a macro, so do not call it  with arguments
**  that have side effects.
*/
#define BLOCK_ELM_BLIST(list, pos) (BLOCKS_BLIST( list )[((pos)-1)/BIPEB])
#define BLOCK_ELM_BLIST_UNSAFE(list, pos)                                    \
    (BLOCKS_BLIST_UNSAFE(list)[((pos)-1) / BIPEB])


/****************************************************************************
**
*F  MASK_POS_BLIST( <pos> )  . . . .  bit mask for position of a Boolean list
**
**  MASK_POS_BLIST(<pos>) returns a UInt with   a single set bit in  position
**  (pos-1) % BIPEB, useful for accessing the pos'th element of a blist
**
**  Note that 'MASK_POS_BLIST' is a  macro, so do  not call it with arguments
**  that have side effects.
*/
#define MASK_POS_BLIST( pos ) (((UInt) 1)<<((pos)-1)%BIPEB)


/****************************************************************************
**
*F  ELM_BLIST( <list>, <pos> ) . . . . . . . . . .  element of a boolean list
**
**  'ELM_BLIST' return the <pos>-th element of the boolean list <list>, which
**  is either 'true' or 'false'.  <pos> must  be a positive integer less than
**  or equal to the length of <list>.
**
**  Note that 'ELM_BLIST' is a macro, so do not call it  with arguments  that
**  have side effects.
*/
#define ELM_BLIST(list,pos) \
  ((BLOCK_ELM_BLIST(list,pos) & MASK_POS_BLIST(pos)) ?  True : False)

#define ELM_BLIST_UNSAFE(list, pos)                                          \
    ((BLOCK_ELM_BLIST_UNSAFE(list, pos) & MASK_POS_BLIST(pos)) ? True : False)


/****************************************************************************
**
*F  SET_ELM_BLIST( <list>, <pos>, <val> ) .  set an element of a boolean list
**
**  'SET_ELM_BLIST' sets  the element at position <pos>   in the boolean list
**  <list> to the value <val>.  <pos> must be a positive integer less than or
**  equal to the length of <list>.  <val> must be either 'true' or 'false'.
**
**  Note that  'SET_ELM_BLIST' is  a macro, so do not  call it with arguments
**  that have side effects.
*/
#define SET_ELM_BLIST(list,pos,val)  \
 ((val) == True ? \
  (BLOCK_ELM_BLIST(list, pos) |= MASK_POS_BLIST(pos)) : \
  (BLOCK_ELM_BLIST(list, pos) &= ~MASK_POS_BLIST(pos)))


/****************************************************************************
**
*F COUNT_TRUES_BLOCK( <block> ) . . . . . . . . . . . count number of
*trues
** 
** 'COUNT_TRUES_BLOCK( <block> )' returns the number of 1 bits in the
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
  
static inline UInt COUNT_TRUES_BLOCK( UInt block )  {  
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
*T  monitor this situation periodically. 
*/

static inline UInt COUNT_TRUES_BLOCKS(UInt * ptr, UInt nblocks)
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
*F * * * * * * * * * * * * * * list functions * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  AssBlist( <list>, <pos>, <val> )  . . . . . . .  assign to a boolean list
**
**  'AssBlist' assigns the   value <val> to  the  boolean list <list> at  the
**  position <pos>.   It is the responsibility  of the caller to  ensure that
**  <pos> is positive, and that <val> is not 0.
**
**  'AssBlist' is the function in 'AssListFuncs' for boolean lists.
**
**  If <pos> is less than or equal to the logical length  of the boolean list
**  and <val> is 'true' or   'false' the assignment  is  done by setting  the
**  corresponding bit.  If <pos>  is one more  than the logical length of the
**  boolean list  the assignment is  done by   resizing  the boolean list  if
**  necessary, setting the   corresponding bit and  incrementing  the logical
**  length  by one.  Otherwise  the boolean list is  converted to an ordinary
**  list and the assignment is performed the ordinary way.
*/
extern void AssBlist (
    Obj                 list,
    Int                 pos,
    Obj                 val );


/****************************************************************************
**
*F  ConvBlist( <list> ) . . . . . . . . .  convert a list into a boolean list
**
**  `ConvBlist' changes the representation of boolean  lists into the compact
**  representation of type 'T_BLIST' described above.
*/
extern void ConvBlist (
    Obj                 list );


/****************************************************************************
**
*F  CopyBits( <fromblock>, <from-starting-bit>, <toblock>, <to-starting-bit>,
**            <numbits> )
**
**  `CopyBits' copies <numbits> bits (numbering bits within a UInt
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


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoBlist() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoBlist ( void );


#endif // GAP_BLISTER_H
