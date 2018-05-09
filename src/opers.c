/****************************************************************************
**
*W  opers.c                     GAP source                       Frank Celler
*W                                                         & Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the  filters, operations, attributes,
**  and properties package.
*/

#include <src/opers.h>

#include <src/ariths.h>
#include <src/blister.h>
#include <src/bool.h>
#include <src/calls.h>
#include <src/error.h>
#include <src/gapstate.h>
#include <src/gvars.h>
#include <src/io.h>
#include <src/lists.h>
#include <src/modules.h>
#include <src/plist.h>
#include <src/precord.h>
#include <src/range.h>
#include <src/records.h>
#include <src/saveload.h>
#include <src/stringobj.h>
#include <src/sysfiles.h>

#ifdef HPCGAP
#include <src/hpc/aobjects.h>
#include <src/hpc/guards.h>
#include <src/hpc/thread.h>
#include <pthread.h>
#endif

/****************************************************************************
**
*V  TRY_NEXT_METHOD . . . . . . . . . . . . . . . . .  'TRY_NEXT_METHOD' flag
*/
Obj TRY_NEXT_METHOD;


#define CACHE_SIZE 5


static Obj StringFilterSetter;
static Obj ArglistObjVal;
static Obj ArglistObj;


/****************************************************************************
**
*F * * * * * * * * * * * * internal flags functions * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  PrintFlags( <flags> ) . . . . . . . . . . . . . . . .  print a flags list
*/
void PrintFlags (
    Obj                 flags )
{
    Pr( "<flag list>", 0L, 0L );
}


/****************************************************************************
**
*F  TypeFlags( <flags> )  . . . . . . . . . . . . . . .  type of a flags list
*/
static Obj TYPE_FLAGS;

Obj TypeFlags (
    Obj                 flags )
{
    return TYPE_FLAGS;
}


/****************************************************************************
**
*F  SaveFlags( <flags> )  . . . . . . . . . . . . . . . . . save a flags list
**
*/
void SaveFlags (
    Obj         flags )
{
    UInt        i, len, *ptr;

    SaveSubObj(TRUES_FLAGS(flags));
    SaveSubObj(HASH_FLAGS(flags));
    SaveSubObj(AND_CACHE_FLAGS(flags));

    len = NRB_FLAGS(flags);
    ptr = BLOCKS_FLAGS(flags);
    for ( i = 1;  i <= len;  i++ )
        SaveUInt(*ptr++);
}


/****************************************************************************
**
*F  LoadFlags( <flags> )  . . . . . . . . . . . . . . . . . load a flags list
**
*/
void LoadFlags(
    Obj         flags )
{
    Obj         sub;
    UInt        i, len, *ptr;

    sub = LoadSubObj();  SET_TRUES_FLAGS( flags, sub );
    sub = LoadSubObj();  SET_HASH_FLAGS( flags, sub );
    sub = LoadSubObj();  SET_AND_CACHE_FLAGS( flags, sub );
    
    len = NRB_FLAGS(flags);
    ptr = BLOCKS_FLAGS(flags);
    for ( i = 1;  i <= len;  i++ )
        *ptr++ = LoadUInt();
}


/****************************************************************************
**
*F * * * * * * * * * * * * *  GAP flags functions * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncHASH_FLAGS( <self>, <flags> ) . . . . . .  hash value of a flags list
**
**  The hash value is independent of the size of a machine word (32 or 64).
**
**  The rather peculiar cast in the definition of HASH_FLAGS_SIZE is needed
**  to get the calculation to work right on the alpha.
**
*T  The 64 bit version depends on the byte order -- it assumes that
**  the lower addressed half-word is the less significant
**
*/
#define HASH_FLAGS_SIZE (Int4)67108879L

Obj FuncHASH_FLAGS (
    Obj                 self,
    Obj                 flags )
{
    Int4                 hash;
    Int4                 x;
    Int                  len;
    UInt4 *              ptr;
    Int                  i;

    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
            flags = ErrorReturnObj( "<flags> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags), 0L,
            "you can replace <flags> via 'return <flags>;'" );
    }
    if ( HASH_FLAGS(flags) != 0 ) {
        return HASH_FLAGS(flags);
    }

    /* do the real work*/
#ifndef SYS_IS_64_BIT

    /* 32 bit case  -- this is the "defining" case, others are
     adjusted to comply with this */
    len = NRB_FLAGS(flags);
    ptr = (UInt4 *)BLOCKS_FLAGS(flags);
    hash = 0;
    x    = 1;
    for ( i = len; i >= 1; i-- ) {
        hash = (hash + (*ptr % HASH_FLAGS_SIZE) * x) % HASH_FLAGS_SIZE;
        x    = ((8*sizeof(UInt4)-1) * x) % HASH_FLAGS_SIZE;
        ptr++;
    }
#else
#ifdef WORDS_BIGENDIAN

    /* This is the hardest case */
    len = NRB_FLAGS(flags);
    ptr = (UInt4 *)BLOCKS_FLAGS(flags);
    hash = 0;
    x    = 1;
    for ( i = len; i >= 1; i-- ) {

        /* least significant 32 bits first */
        hash = (hash + (ptr[1] % HASH_FLAGS_SIZE) * x) % HASH_FLAGS_SIZE;
        x    = ((8*sizeof(UInt4)-1) * x) % HASH_FLAGS_SIZE;
        /* now the more significant */
        hash = (hash + (*ptr % HASH_FLAGS_SIZE) * x) % HASH_FLAGS_SIZE;
        x    = ((8*sizeof(UInt4)-1) * x) % HASH_FLAGS_SIZE;
        
        ptr+= 2;
    }
#else

    /* and the middle case -- for DEC alpha, the 32 bit chunks are
       in the right order, and we merely have to be sure to process them as
       32 bit chunks */
    len = NRB_FLAGS(flags)*(sizeof(UInt)/sizeof(UInt4));
    ptr = (UInt4 *)BLOCKS_FLAGS(flags);
    hash = 0;
    x    = 1;
    for ( i = len; i >= 1; i-- ) {
        hash = (hash + (*ptr % HASH_FLAGS_SIZE) * x) % HASH_FLAGS_SIZE;
        x    = ((8*sizeof(UInt4)-1) * x) % HASH_FLAGS_SIZE;
        ptr++;
    }
#endif
#endif
    SET_HASH_FLAGS( flags, INTOBJ_INT((UInt)hash+1) );
    CHANGED_BAG(flags);
    return HASH_FLAGS(flags);
}


/****************************************************************************
**
*F  FuncTRUES_FLAGS( <self>, <flags> )  . . .  true positions of a flags list
**
**  see 'FuncPositionsTruesBlist' in "blister.c" for information.
*/
Obj FuncTRUES_FLAGS (
    Obj                 self,
    Obj                 flags )
{
    Obj                 sub;            /* handle of the result            */
    Int                 len;            /* logical length of the list      */
    UInt *              ptr;            /* pointer to flags                */
    UInt                nrb;            /* number of blocks in flags       */
    UInt                n;              /* number of bits in flags         */
    UInt                nn;
    UInt                i;              /* loop variable                   */

    /* get and check the first argument                                    */
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
        flags = ErrorReturnObj( "<flags> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags), 0L,
            "you can replace <flags> via 'return <flags>;'" );
    }
    if ( TRUES_FLAGS(flags) != 0 ) {
        return TRUES_FLAGS(flags);
    }

    /* compute the number of 'true'-s just as in 'FuncSizeBlist'            */
    nrb = NRB_FLAGS(flags);
    ptr = (UInt*)BLOCKS_FLAGS(flags);
    n = COUNT_TRUES_BLOCKS(ptr, nrb);    

    /* make the sublist (we now know its size exactly)                    */
    sub = NEW_PLIST_IMM( T_PLIST, n );
    SET_LEN_PLIST( sub, n );

    /* loop over the boolean list and stuff elements into <sub>            */
    len = LEN_FLAGS( flags );
    nn  = 1;
    for ( i = 1; nn <= n && i <= len;  i++ ) {
        if ( C_ELM_FLAGS( flags, i ) ) {
            SET_ELM_PLIST( sub, nn, INTOBJ_INT(i) );
            nn++;
        }
    }
    CHANGED_BAG(sub);

    /* return the sublist                                                  */
    SET_TRUES_FLAGS( flags, sub );
    CHANGED_BAG(flags);
    return sub;
}


/****************************************************************************
**
*F  FuncSIZE_FLAGS( <self>, <flags> ) . . . . number of trues of a flags list
**
**  see 'FuncSIZE_FLAGS'
*/
Obj FuncSIZE_FLAGS (
    Obj                 self,
    Obj                 flags )
{
    UInt *              ptr;            /* pointer to flags                */
    UInt                nrb;            /* number of blocks in flags       */
    UInt                n;              /* number of bits in flags         */

    /* get and check the first argument                                    */
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
        flags = ErrorReturnObj( "<flags> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags), 0L,
            "you can replace <flags> via 'return <flags>;'" );
    }
    if ( TRUES_FLAGS(flags) != 0 ) {
        return INTOBJ_INT( LEN_PLIST( TRUES_FLAGS(flags) ) );
    }

    /* get the number of blocks and a pointer                              */
    nrb = NRB_FLAGS(flags);
    ptr = BLOCKS_FLAGS(flags);

    n = COUNT_TRUES_BLOCKS(ptr, nrb);

    /* return the number of bits                                           */
    return INTOBJ_INT( n );
}


/****************************************************************************
**
*F  EqFlags( <flags1>, <flags2> ) . . . . . . . . . . equality of flags lists
*/
Int EqFlags(Obj flags1, Obj flags2)
{
    Int                 len1;
    Int                 len2;
    UInt  *             ptr1;
    UInt  *             ptr2;
    Int                 i;

    if ( flags1 == flags2 ) {
        return 1;
    }

    // do the real work
    len1 = NRB_FLAGS(flags1);
    len2 = NRB_FLAGS(flags2);
    ptr1 = BLOCKS_FLAGS(flags1);
    ptr2 = BLOCKS_FLAGS(flags2);
    if ( len1 <= len2 ) {
        for ( i = 1; i <= len1; i++ ) {
            if ( *ptr1 != *ptr2 )
                return 0;
            ptr1++;  ptr2++;
        }
        for ( ; i <= len2; i++ ) {
            if ( 0 != *ptr2 )
                return 0;
            ptr2++;
        }
    }
    else {
        for ( i = 1; i <= len2; i++ ) {
            if ( *ptr1 != *ptr2 )
                return 0;
            ptr1++;  ptr2++;
        }
        for ( ; i <= len1; i++ ) {
            if ( *ptr1 != 0 )
                return 0;
            ptr1++;
        }
    }
    return 1;
}


/****************************************************************************
**
*F  FuncIS_EQUAL_FLAGS( <self>, <flags1>, <flags2> )  equality of flags lists
*/
Obj FuncIS_EQUAL_FLAGS (
    Obj                 self,
    Obj                 flags1,
    Obj                 flags2 )
{
    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags1) != T_FLAGS ) {
        flags1 = ErrorReturnObj( "<flags1> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags1), 0L,
            "you can replace <flags1> via 'return <flags1>;'" );
    }
    while ( TNUM_OBJ(flags2) != T_FLAGS ) {
        flags2 = ErrorReturnObj( "<flags2> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags2), 0L,
            "you can replace <flags2> via 'return <flags2>;'" );
    }

    return EqFlags(flags1, flags2) ? True : False;
}


#ifdef COUNT_OPERS
static Int IsSubsetFlagsCalls;
#endif

/****************************************************************************
**
*F  IS_SUBSET_FLAGS( <flags1>, <flags2> ) . subset test with no safety check
*/
static Int IS_SUBSET_FLAGS(Obj flags1, Obj flags2)
{
    Int    len1;
    Int    len2;
    UInt * ptr1;
    UInt * ptr2;
    Int    i;

#ifdef COUNT_OPERS
    IsSubsetFlagsCalls++;
#endif

    /* compare the bit lists                                               */
    len1 = NRB_FLAGS(flags1);
    len2 = NRB_FLAGS(flags2);
    ptr1 = BLOCKS_FLAGS(flags1);
    ptr2 = BLOCKS_FLAGS(flags2);
    if (len1 < len2) {
        for (i = len2 - 1; i >= len1; i--) {
            if (ptr2[i] != 0)
                return 0;
        }
        for (i = len1 - 1; i >= 0; i--) {
            UInt x = ptr2[i];
            if ((x & ptr1[i]) != x)
                return 0;
        }
    }
    else {
        for (i = len2 - 1; i >= 0; i--) {
            UInt x = ptr2[i];
            if ((x & ptr1[i]) != x)
                return 0;
        }
    }
    return 1;
}

/****************************************************************************
**
*F  FuncIS_SUBSET_FLAGS( <self>, <flags1>, <flags2> ) . . . . . . subset test
*/
Obj FuncIS_SUBSET_FLAGS (
    Obj                 self,
    Obj                 flags1,
    Obj                 flags2 )
{
    /* do some correctness checks                                            */
    while ( TNUM_OBJ(flags1) != T_FLAGS ) {
        flags1 = ErrorReturnObj( "<flags1> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags1), 0L,
            "you can replace <flags1> via 'return <flags1>;'" );
    }
    while ( TNUM_OBJ(flags2) != T_FLAGS ) {
        flags2 = ErrorReturnObj( "<flags2> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags2), 0L,
            "you can replace <flags2> via 'return <flags2>;'" );
    }
    
    return IS_SUBSET_FLAGS(flags1, flags2) ? True : False;
}

/****************************************************************************
**
*F  FuncSUB_FLAGS( <self>, <flags1>, <flags2> ) . . .  substract a flags list
*/
Obj FuncSUB_FLAGS (
    Obj                 self,
    Obj                 flags1,
    Obj                 flags2 )
{
    Obj                 flags;
    Int                 len1;
    Int                 len2;
    Int                 size1;
    Int                 size2;
    UInt *              ptr;
    UInt *              ptr1;
    UInt *              ptr2;
    Int                 i;

    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags1) != T_FLAGS ) {
        flags1 = ErrorReturnObj( "<flags1> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags1), 0L,
            "you can replace <flags1> via 'return <flags1>;'" );
    }
    while ( TNUM_OBJ(flags2) != T_FLAGS ) {
        flags2 = ErrorReturnObj( "<flags2> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags2), 0L,
            "you can replace <flags2> via 'return <flags2>;'" );
    }

    /* do the real work                                                    */
    len1   = LEN_FLAGS(flags1);
    size1  = NRB_FLAGS(flags1);
    len2   = LEN_FLAGS(flags2);
    size2  = NRB_FLAGS(flags2);
    if ( len1 < len2 ) {
        flags = NEW_FLAGS( len1 );
        ptr1 = BLOCKS_FLAGS(flags1);
        ptr2 = BLOCKS_FLAGS(flags2);
        ptr  = BLOCKS_FLAGS(flags);
        for ( i = 1; i <= size1; i++ )
            *ptr++ = *ptr1++ & ~ *ptr2++;
    }
    else {
        flags = NEW_FLAGS( len1 );
        ptr1 = BLOCKS_FLAGS(flags1);
        ptr2 = BLOCKS_FLAGS(flags2);
        ptr  = BLOCKS_FLAGS(flags);
        for ( i = 1; i <= size2; i++ )
            *ptr++ = *ptr1++ & ~ *ptr2++;
        for (      ; i <= size1; i++ )
            *ptr++ = *ptr1++;
    }        

    return flags;
}


/****************************************************************************
**
*F  FuncAND_FLAGS( <self>, <flags1>, <flags2> ) . . . .  `and' of flags lists
*/
#define AND_FLAGS_HASH_SIZE             50

#ifdef COUNT_OPERS
static Int AndFlagsCacheHit;
static Int AndFlagsCacheMiss;
static Int AndFlagsCacheLost;
#endif

Obj FuncAND_FLAGS (
    Obj                 self,
    Obj                 flags1,
    Obj                 flags2 )
{
    Obj                 flags;
    Int                 len1;
    Int                 len2;
    Int                 size1;
    Int                 size2;
    UInt *              ptr;
    UInt *              ptr1;
    UInt *              ptr2;
    Int                 i;

#ifdef AND_FLAGS_HASH_SIZE
    Obj                 cache;
    Obj                 entry;
#ifdef HPCGAP
    Obj                 locked = 0;
#endif
    UInt                hash;
    UInt                hash2;
    static UInt         next = 0;   // FIXME HPC-GAP: is usage of this static thread-safe?
#endif

    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags1) != T_FLAGS ) {
        flags1 = ErrorReturnObj( "<flags1> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags1), 0L,
            "you can replace <flags1> via 'return <flags1>;'" );
    }
    while ( TNUM_OBJ(flags2) != T_FLAGS ) {
        flags2 = ErrorReturnObj( "<flags2> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags2), 0L,
            "you can replace <flags2> via 'return <flags2>;'" );
    }

    if (flags1 == flags2)
        return flags1;
    if (LEN_FLAGS(flags2) == 0)
        return flags1;
    if (LEN_FLAGS(flags1) == 0)
        return flags2;

    // check the cache
#   ifdef AND_FLAGS_HASH_SIZE
        // We want to ensure if we calculate 'flags1 and flags2', then
        // later do 'flags2 and flags1', we will get the value from the cache.
        // Therefore we just compare the location of the Bag masterpointers
        // for both flags (which doesn't change), and use the cache of the
        // smaller. To this end, ensure flags1 is the smaller one.
        if ( flags1 > flags2 ) {
            SWAP(Obj, flags1, flags2);
        }

#       ifdef HPCGAP
            if (!PreThreadCreation) {
                locked = flags1;
                HashLock(locked);
            }
#       endif
        cache  = AND_CACHE_FLAGS(flags1);
        if ( cache == 0 ) {
            cache = NEW_PLIST( T_PLIST, 2*AND_FLAGS_HASH_SIZE );
            MakeBagPublic(cache);
            SET_AND_CACHE_FLAGS( flags1, cache );
            CHANGED_BAG(flags1);
        }
        hash = (UInt)flags2;
        for ( i = 0;  i < 24;  i++ ) {
            hash2 = (hash + 97*i) % AND_FLAGS_HASH_SIZE;
            entry = ELM_PLIST( cache, 2*hash2+1 );
            if ( entry == 0 ) {
                break;
            }
            if ( entry == flags2 ) {
#               ifdef COUNT_OPERS
                    AndFlagsCacheHit++;
#               endif
#               if defined(HPCGAP) && defined(AND_FLAGS_HASH_SIZE)
                    if (locked)
                        HashUnlock(locked);
#               endif
                return ELM_PLIST( cache, 2*hash2+2 );
            }
        }
        if ( entry == 0 ) {
            hash = hash2;
        }
        else {
            next = (next+1) % 24;
            hash = (hash + 97*next) % AND_FLAGS_HASH_SIZE;
        }
#       ifdef COUNT_OPERS
            AndFlagsCacheMiss++;
#       endif
#   endif


    /* do the real work                                                    */
    len1   = LEN_FLAGS(flags1);
    size1  = NRB_FLAGS(flags1);
    len2   = LEN_FLAGS(flags2);
    size2  = NRB_FLAGS(flags2);

    if ( len1 < len2 ) {
        flags = NEW_FLAGS( len2 );
        ptr1 = BLOCKS_FLAGS(flags1);
        ptr2 = BLOCKS_FLAGS(flags2);
        ptr  = BLOCKS_FLAGS(flags);
        for ( i = 1; i <= size1; i++ )
            *ptr++ = *ptr1++ | *ptr2++;
        for (      ; i <= size2; i++ )
            *ptr++ =           *ptr2++;
    }
    else {
        flags = NEW_FLAGS( len1 );
        ptr1 = BLOCKS_FLAGS(flags1);
        ptr2 = BLOCKS_FLAGS(flags2);
        ptr  = BLOCKS_FLAGS(flags);
        for ( i = 1; i <= size2; i++ )
            *ptr++ = *ptr1++ | *ptr2++;
        for (      ; i <= size1; i++ )
            *ptr++ = *ptr1++;
    }        

    /* store result in the cache                                           */
#   ifdef AND_FLAGS_HASH_SIZE
#       ifdef COUNT_OPERS
            if ( ELM_PLIST(cache,2*hash+1) != 0 ) {
                    AndFlagsCacheLost++;
            }
#       endif
        SET_ELM_PLIST( cache, 2*hash+1, flags2 );
        SET_ELM_PLIST( cache, 2*hash+2, flags  );
        CHANGED_BAG(cache);
#       ifdef HPCGAP
            if (locked)
                HashUnlock(locked);
#       endif
#   endif

    /* and return the result                                               */
    return flags;
}

Obj HIDDEN_IMPS;
Obj WITH_HIDDEN_IMPS_FLAGS_CACHE;
enum { HIDDEN_IMPS_CACHE_LENGTH = 2003 };

/* Forward declaration of FuncFLAGS_FILTER */
Obj FuncFLAGS_FILTER(Obj self, Obj oper);
    
/****************************************************************************
**
*F  FuncInstallHiddenTrueMethod( <filter>, <filters> ) Add a hidden true method
*/
Obj FuncInstallHiddenTrueMethod(Obj self, Obj filter, Obj filters)
{
    Obj imp = FuncFLAGS_FILTER(0, filter);
    Obj imps = FuncFLAGS_FILTER(0, filters);
#ifdef HPCGAP
    RegionWriteLock(REGION(HIDDEN_IMPS));
#endif
    UInt len = LEN_PLIST(HIDDEN_IMPS);
    GROW_PLIST(HIDDEN_IMPS, len + 2);
    SET_LEN_PLIST(HIDDEN_IMPS, len + 2);
    SET_ELM_PLIST(HIDDEN_IMPS, len + 1, imp);
    SET_ELM_PLIST(HIDDEN_IMPS, len + 2, imps);
    CHANGED_BAG(HIDDEN_IMPS);
#ifdef HPCGAP
    RegionWriteUnlock(REGION(HIDDEN_IMPS));
#endif
    return 0;
}

/****************************************************************************
**
*F  FuncCLEAR_HIDDEN_IMP_CACHE( <self>, <flags> ) . . . .clear cache of flags
*/
Obj FuncCLEAR_HIDDEN_IMP_CACHE(Obj self, Obj filter)
{
  Int i;
  Obj flags = FuncFLAGS_FILTER(0, filter);
#ifdef HPCGAP
  RegionWriteLock(REGION(WITH_HIDDEN_IMPS_FLAGS_CACHE));
#endif
  for(i = 1; i < HIDDEN_IMPS_CACHE_LENGTH * 2 - 1; i += 2)
  {
    if(ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, i) &&
       FuncIS_SUBSET_FLAGS(0, ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, i+1), flags) == True)
    {
        SET_ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, i, 0);
        SET_ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, i + 1, 0);
        CHANGED_BAG(WITH_HIDDEN_IMPS_FLAGS_CACHE);
    }
  }
#ifdef HPCGAP
  RegionWriteUnlock(REGION(WITH_HIDDEN_IMPS_FLAGS_CACHE));
#endif
  return 0;
}

/****************************************************************************
**
*F  FuncWITH_HIDDEN_IMP_FLAGS( <self>, <flags> ) . . add hidden imps to flags
*/
#ifdef COUNT_OPERS
static Int WITH_HIDDEN_IMPS_MISS=0;
static Int WITH_HIDDEN_IMPS_HIT=0;
#endif
Obj FuncWITH_HIDDEN_IMPS_FLAGS(Obj self, Obj flags)
{
    // do some trivial checks, so we can use IS_SUBSET_FLAGS
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
            flags = ErrorReturnObj( "<flags> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags), 0L,
            "you can replace <flags> via 'return <flags>;'" );
    }

    Int changed, i, lastand, stop;
    Int hidden_imps_length = LEN_PLIST(HIDDEN_IMPS) / 2;
    Int base_hash = INT_INTOBJ(FuncHASH_FLAGS(0, flags)) % HIDDEN_IMPS_CACHE_LENGTH;
    Int hash = base_hash;
    Int hash_loop = 0;
    Obj cacheval;
    Obj old_with, old_flags, new_with, new_flags;
    Int old_moving;
    Obj with = flags;
    
#ifdef HPCGAP
    RegionWriteLock(REGION(WITH_HIDDEN_IMPS_FLAGS_CACHE));
#endif
    for(hash_loop = 0; hash_loop < 3; ++hash_loop)
    {
      cacheval = ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, hash*2+1);
      if(cacheval && cacheval == flags) {
        Obj ret = ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, hash*2+2);
#ifdef HPCGAP
        RegionWriteUnlock(REGION(WITH_HIDDEN_IMPS_FLAGS_CACHE));
#endif
#ifdef COUNT_OPERS
        WITH_HIDDEN_IMPS_HIT++;
#endif
        return ret;
      }
      hash = (hash * 311 + 61) % HIDDEN_IMPS_CACHE_LENGTH;
    }
    
#ifdef COUNT_OPERS
    WITH_HIDDEN_IMPS_MISS++;
#endif
    changed = 1;
    lastand = 0;
    while(changed)
    {
      changed = 0;
      for (i = hidden_imps_length, stop = lastand; i > stop; i--)
      {
        if( IS_SUBSET_FLAGS(with, ELM_PLIST(HIDDEN_IMPS, i*2)) &&
           !IS_SUBSET_FLAGS(with, ELM_PLIST(HIDDEN_IMPS, i*2-1)) )
        {
          with = FuncAND_FLAGS(0, with, ELM_PLIST(HIDDEN_IMPS, i*2-1));
          changed = 1;
          stop = 0;
          lastand = i;
        }
      }
    }

    /* add to hash table, shuffling old values along (last one falls off) */
    hash = base_hash;
    
    old_moving = 1;
    new_with = with;
    new_flags = flags;
    
    for(hash_loop = 0; old_moving && hash_loop < 3; ++hash_loop) {
      old_moving = 0;
      if(ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, hash*2+1))
      {
        old_flags = ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, hash*2+1);
        old_with = ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, hash*2+2);
        old_moving = 1;
      }

      SET_ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, hash * 2 + 1, new_flags);
      SET_ELM_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, hash * 2 + 2, new_with);

      if(old_moving)
      {
        new_flags = old_flags;
        new_with = old_with;
        hash = (hash * 311 + 61) % HIDDEN_IMPS_CACHE_LENGTH;
      }
    }
    
    CHANGED_BAG(WITH_HIDDEN_IMPS_FLAGS_CACHE);
#ifdef HPCGAP
    RegionWriteUnlock(REGION(WITH_HIDDEN_IMPS_FLAGS_CACHE));
#endif
    return with;
}


static Obj IMPLICATIONS_SIMPLE;
static Obj IMPLICATIONS_COMPOSED;
static Obj WITH_IMPS_FLAGS_CACHE;
enum { IMPS_CACHE_LENGTH = 11001 };

/****************************************************************************
**
*F  FuncCLEAR_IMP_CACHE( <self>, <flags> ) . . . . . . . clear cache of flags
*/
Obj FuncCLEAR_IMP_CACHE(Obj self)
{
  Int i;
#ifdef HPCGAP
  RegionWriteLock(REGION(IMPLICATIONS_SIMPLE));
#endif
  for(i = 1; i < IMPS_CACHE_LENGTH * 2 - 1; i += 2)
  {
    SET_ELM_PLIST(WITH_IMPS_FLAGS_CACHE, i, 0);
    SET_ELM_PLIST(WITH_IMPS_FLAGS_CACHE, i + 1, 0);
  }
#ifdef HPCGAP
  RegionWriteUnlock(REGION(IMPLICATIONS_SIMPLE));
#endif
  return 0;
}

/****************************************************************************
**
*F  FuncWITH_IMPS_FLAGS( <self>, <flags> ) . . . . . . . . add imps to flags
*/
#ifdef COUNT_OPERS
static Int WITH_IMPS_FLAGS_MISS=0;
static Int WITH_IMPS_FLAGS_HIT=0;
#endif
Obj FuncWITH_IMPS_FLAGS(Obj self, Obj flags)
{
    // do some trivial checks, so we can use IS_SUBSET_FLAGS
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
            flags = ErrorReturnObj( "<flags> must be a flags list (not a %s)",
            (Int)TNAM_OBJ(flags), 0L,
            "you can replace <flags> via 'return <flags>;'" );
    }

    Int changed, lastand, i, j, stop, imps_length;
    Int base_hash = INT_INTOBJ(FuncHASH_FLAGS(0, flags)) % IMPS_CACHE_LENGTH;
    Int hash = base_hash;
    Int hash_loop = 0;
    Obj cacheval;
    Obj old_with, old_flags, new_with, new_flags;
    Int old_moving;
    Obj with = flags;
    Obj imp;
    Obj trues;
    
#ifdef HPCGAP
    RegionWriteLock(REGION(IMPLICATIONS_SIMPLE));
#endif
    for(hash_loop = 0; hash_loop < 3; ++hash_loop)
    {
      cacheval = ELM_PLIST(WITH_IMPS_FLAGS_CACHE, hash*2+1);
      if(cacheval && cacheval == flags) {
        Obj ret = ELM_PLIST(WITH_IMPS_FLAGS_CACHE, hash*2+2);
#ifdef HPCGAP
        RegionWriteUnlock(REGION(IMPLICATIONS_SIMPLE));
#endif
#ifdef COUNT_OPERS
        WITH_IMPS_FLAGS_HIT++;
#endif
        return ret;
      }
      hash = (hash * 311 + 61) % IMPS_CACHE_LENGTH;
    }
    
#ifdef COUNT_OPERS
    WITH_IMPS_FLAGS_MISS++;
#endif
    /* first implications from simple filters (need only be checked once) */
    trues = FuncTRUES_FLAGS(0, flags);
    for (i=1; i<=LEN_PLIST(trues); i++) {
        j = INT_INTOBJ(ELM_PLIST(trues, i));
        if (j <= LEN_PLIST(IMPLICATIONS_SIMPLE)
            && ELM_PLIST(IMPLICATIONS_SIMPLE, j)) {
           imp = ELM_PLIST(IMPLICATIONS_SIMPLE, j);
           if( IS_SUBSET_FLAGS(with, ELM_PLIST(imp, 2)) &&
              !IS_SUBSET_FLAGS(with, ELM_PLIST(imp, 1)) )
           {
             with = FuncAND_FLAGS(0, with, ELM_PLIST(imp, 1));
           }
        }
    }

    /* the other implications have to be considered in a loop */
    imps_length = LEN_PLIST(IMPLICATIONS_COMPOSED);
    changed = 1;
    lastand = imps_length+1;
    while(changed)
    {
      changed = 0;
      for (i = 1, stop = lastand; i < stop; i++)
      {
        imp = ELM_PLIST(IMPLICATIONS_COMPOSED, i);
        if( IS_SUBSET_FLAGS(with, ELM_PLIST(imp, 2)) &&
           !IS_SUBSET_FLAGS(with, ELM_PLIST(imp, 1)) )
        {
          with = FuncAND_FLAGS(0, with, ELM_PLIST(imp, 1));
          changed = 1;
          stop = imps_length+1;
          lastand = i;
        }
      }
    }

    /* add to hash table, shuffling old values along (last one falls off) */
    hash = base_hash;
    
    old_moving = 1;
    new_with = with;
    new_flags = flags;
    
    for(hash_loop = 0; old_moving && hash_loop < 3; ++hash_loop) {
      old_moving = 0;
      if(ELM_PLIST(WITH_IMPS_FLAGS_CACHE, hash*2+1))
      {
        old_flags = ELM_PLIST(WITH_IMPS_FLAGS_CACHE, hash*2+1);
        old_with = ELM_PLIST(WITH_IMPS_FLAGS_CACHE, hash*2+2);
        old_moving = 1;
      }

      SET_ELM_PLIST(WITH_IMPS_FLAGS_CACHE, hash * 2 + 1, new_flags);
      SET_ELM_PLIST(WITH_IMPS_FLAGS_CACHE, hash * 2 + 2, new_with);
      CHANGED_BAG(WITH_IMPS_FLAGS_CACHE);

      if(old_moving)
      {
        new_flags = old_flags;
        new_with = old_with;
        hash = (hash * 311 + 61) % IMPS_CACHE_LENGTH;
      }
    }
    
#ifdef HPCGAP
    RegionWriteUnlock(REGION(IMPLICATIONS_SIMPLE));
#endif
    return with;
}

Obj FuncWITH_IMPS_FLAGS_STAT(Obj self)
{
    Obj res;
    res = NEW_PLIST(T_PLIST, 3);
    SET_LEN_PLIST(res, 3);
    SET_ELM_PLIST(res, 1, WITH_IMPS_FLAGS_CACHE);
#ifdef COUNT_OPERS
    SET_ELM_PLIST(res, 2, INTOBJ_INT(WITH_IMPS_FLAGS_HIT));
    SET_ELM_PLIST(res, 3, INTOBJ_INT(WITH_IMPS_FLAGS_MISS));
#else
    SET_ELM_PLIST(res, 2, Fail);
    SET_ELM_PLIST(res, 3, Fail);
#endif
    return res;
}

/****************************************************************************
**
*F * * * * * * * * * * *  internal filter functions * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  Countlags  . . . . . . . . . . . . . . . . . . . . next free flag number
*/
static Int CountFlags;


/****************************************************************************
**
*F  SetterFilter( <oper> )  . . . . . . . . . . . . . . .  setter of a filter
*/
Obj SetterFilter (
    Obj                 oper )
{
    Obj                 setter;

    setter = SETTR_FILT( oper );
    if ( setter == INTOBJ_INT(0xBADBABE) )
        setter = SetterAndFilter( oper );
    return setter;
}


/****************************************************************************
**
*F  SetterAndFilter( <getter> )  . . . . . .  setter of a concatenated filter
*/
Obj DoSetAndFilter (
    Obj                 self,
    Obj                 obj,
    Obj                 val )
{
    Obj                 op;

    while (val != True)
      val = ErrorReturnObj(
             "You cannot set an \"and-filter\" except to true", 0L, 0L,
             "you can type 'return true;' to set all components true\n"
             "(but you might really want to reset just one component)");
    
    /* call the first 'and'-ed function                                    */
    op = FLAG1_FILT( self );
    CALL_2ARGS( op, obj, val );
    
    /* call the second 'and'-ed function                                   */
    op = FLAG2_FILT( self );
    CALL_2ARGS( op, obj, val );
    
    /* return 'void'                                                       */
    return 0;
}


Obj SetterAndFilter (
    Obj                 getter )
{
    Obj                 setter;
    Obj                 obj;
    if ( SETTR_FILT( getter ) == INTOBJ_INT(0xBADBABE) ) {
        setter = NewFunctionT( T_FUNCTION, sizeof(OperBag),
                                MakeImmString("<<setter-and-filter>>"), 2, ArglistObjVal,
                                DoSetAndFilter );
        /* assign via 'obj' to avoid GC issues */
        obj =  SetterFilter( FLAG1_FILT(getter) );
        SET_FLAG1_FILT(setter, obj);
        obj = SetterFilter( FLAG2_FILT(getter) );
        SET_FLAG2_FILT(setter, obj);
        SET_SETTR_FILT(getter, setter);
        CHANGED_BAG(getter);
    }

    return SETTR_FILT(getter);
}
        

/****************************************************************************
**
*F  TesterFilter( <oper> )  . . . . . . . . . . . . . . .  tester of a filter
*/
Obj TesterFilter (
    Obj                 oper )
{
    Obj                 tester;

    tester = TESTR_FILT( oper );
    if ( tester == INTOBJ_INT(0xBADBABE) )
        tester = TesterAndFilter( oper );
    return tester;
}


/****************************************************************************
**
*F  TestAndFilter( <getter> )  . . . . . . . .tester of a concatenated filter
*/
Obj TesterAndFilter (
    Obj                 getter )
{
    Obj                 tester;

    if ( TESTR_FILT( getter ) == INTOBJ_INT(0xBADBABE) ) {
        tester = NewAndFilter( TesterFilter( FLAG1_FILT(getter) ),
                               TesterFilter( FLAG2_FILT(getter) ) );
        SET_TESTR_FILT(getter, tester);
        CHANGED_BAG(getter);

    }
    return TESTR_FILT(getter);
}


/****************************************************************************
**
*F  NewFilter( <name>, <narg>, <nams>, <hdlr> )  . . . . .  make a new filter
*/
Obj DoSetFilter (
    Obj                 self,
    Obj                 obj,
    Obj                 val )
{
    Int                 flag1;
    Obj                 type;
    Obj                 flags;
    
    /* get the flag for the getter                                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    
    /* get the type of the object and its flags                            */
    type  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( type );
    
    /* return the value of the feature                                     */
    if ( val != SAFE_ELM_FLAGS( flags, flag1 ) ) {
        ErrorReturnVoid(
            "value feature is already set the other way",
            0L, 0L,
            "you can 'return;' and ignore it" );
    }

    /* return 'void'                                                       */
    return 0;
}

Obj NewSetterFilter (
    Obj                 getter )
{
    Obj                 setter;

    setter = NewOperation( StringFilterSetter, 2, ArglistObjVal,
                           DoSetFilter );
    SET_FLAG1_FILT(setter, FLAG1_FILT(getter));
    SET_FLAG2_FILT(setter, INTOBJ_INT(0));
    CHANGED_BAG(setter);

    return setter;
}


Obj DoFilter (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag1;
    Obj                 type;
    Obj                 flags;
    
    /* get the flag for the getter                                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    
    /* get the type of the object and its flags                            */
    type  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( type );
    
    /* return the value of the feature                                     */
    val = SAFE_ELM_FLAGS( flags, flag1 );
    
    /* return the value                                                    */
    return val;
}


Obj NewFilter (
    Obj                 name,
    Int                 narg,
    Obj                 nams,
    ObjFunc             hdlr )
{
    Obj                 getter;
    Obj                 setter;
    Int                 flag1;
    Obj                 flags;
    
    flag1 = ++CountFlags;

    getter = NewOperation( name, 1L, nams, (hdlr ? hdlr : DoFilter) );
    SET_FLAG1_FILT(getter, INTOBJ_INT(flag1));
    SET_FLAG2_FILT(getter, INTOBJ_INT(0));
    flags = NEW_FLAGS( flag1 );
    SET_ELM_FLAGS( flags, flag1, True );
    SET_FLAGS_FILT(getter, flags);
    CHANGED_BAG(getter);

    setter = NewSetterFilter( getter );
    SET_SETTR_FILT(getter, setter);
    SET_TESTR_FILT(getter, ReturnTrueFilter);
    CHANGED_BAG(getter);

    return getter;    
}


/****************************************************************************
**
*F  NewAndFilter( <filt1>, <filt2> ) . . . . . make a new concatenated filter
*/
Obj DoAndFilter (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Obj                 op;
    
    /* call the first 'and'-ed function                                    */
    op = FLAG1_FILT( self );
    val = CALL_1ARGS( op, obj );
    if ( val != True )  return False;
    
    /* call the second 'and'-ed function                                   */
    op = FLAG2_FILT( self );
    val = CALL_1ARGS( op, obj );
    if ( val != True )  return False;
    
    /* return 'true'                                                       */
    return True;
}

Obj NewAndFilter (
    Obj                 oper1,
    Obj                 oper2 )
{
    Obj                 getter;
    Obj                 flags;

    Int                 str_len;
    Obj                 str;
    char*               s;

    if ( oper1 == ReturnTrueFilter )
        return oper2;

    if ( oper2 == ReturnTrueFilter )
        return oper1;

    str_len = GET_LEN_STRING(NAME_FUNC(oper1)) + GET_LEN_STRING(NAME_FUNC(oper2)) + 8;
    str = NEW_STRING(str_len);
    s = CSTR_STRING(str);
    s[0] = '(';
    s[1] = 0;
    strlcat(s, CSTR_STRING(NAME_FUNC(oper1)), str_len);
    strlcat(s, " and ", str_len);
    strlcat(s, CSTR_STRING(NAME_FUNC(oper2)), str_len);
    strlcat(s, ")", str_len);
    SET_LEN_STRING(str, str_len - 1);

    getter = NewFunctionT( T_FUNCTION, sizeof(OperBag), str, 1,
                           ArglistObj, DoAndFilter );
    SET_FLAG1_FILT(getter, oper1);
    SET_FLAG2_FILT(getter, oper2);
    flags = FuncAND_FLAGS( 0, FLAGS_FILT(oper1), FLAGS_FILT(oper2) );
    SET_FLAGS_FILT(getter, flags);
    SET_SETTR_FILT(getter, INTOBJ_INT(0xBADBABE));
    SET_TESTR_FILT(getter, INTOBJ_INT(0xBADBABE));
    CHANGED_BAG(getter);

    return getter;
}

Obj FuncIS_AND_FILTER( Obj self, Obj filt )
{
  return (IS_FUNC(filt) && HDLR_FUNC(filt, 1) == DoAndFilter) ? True : False;
}


/****************************************************************************
**
*V  ReturnTrueFilter . . . . . . . . . . . . . . . . the return 'true' filter
*/
Obj ReturnTrueFilter;


/****************************************************************************
**
*F  NewReturnTrueFilter() . . . . . . . . . . create a new return true filter
*/
Obj TesterReturnTrueFilter (
    Obj                 getter )
{
    return getter;
}

Obj DoSetReturnTrueFilter (
    Obj                 self,
    Obj                 obj,
    Obj                 val )
{
    if ( val != True ) {
         ErrorReturnVoid( "you cannot set this flag to 'false'",
             0L, 0L,
             "you can 'return;' and ignore it" );
    }
    return 0;
}

Obj SetterReturnTrueFilter (
    Obj                 getter )
{
    Obj                 setter;

    setter = NewFunctionT( T_FUNCTION, sizeof(OperBag),
        MakeImmString("<<setter-true-filter>>"), 2, ArglistObjVal,
        DoSetReturnTrueFilter );
    SET_FLAG1_FILT(setter, INTOBJ_INT(0));
    SET_FLAG2_FILT(setter, INTOBJ_INT(0));
    CHANGED_BAG(setter);

    return setter;    
}

Obj DoReturnTrueFilter (
    Obj                 self,
    Obj                 obj )
{
    return True;
}

Obj NewReturnTrueFilter ( void )
{
    Obj                 getter;
    Obj                 setter;
    Obj                 tester;
    Obj                 flags;

    getter = NewFunctionT( T_FUNCTION, sizeof(OperBag),
        MakeImmString("ReturnTrueFilter"), 1, ArglistObj,
        DoReturnTrueFilter );
    SET_FLAG1_FILT(getter, INTOBJ_INT(0));
    SET_FLAG2_FILT(getter, INTOBJ_INT(0));
    flags = NEW_FLAGS( 0 );
    SET_FLAGS_FILT(getter, flags);
    CHANGED_BAG(getter);

    setter = SetterReturnTrueFilter( getter );
    SET_SETTR_FILT(getter, setter);
    CHANGED_BAG(getter);

    tester = TesterReturnTrueFilter( getter );
    SET_TESTR_FILT(getter, tester);
    CHANGED_BAG(getter);
        
    return getter;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * GAP filter functions * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncNEW_FILTER( <self>, <name> )  . . . . . . . . . . . . .  new filter
*/
Obj FuncNEW_FILTER (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewFilter( <name> )",0L,0L);
    }

    /* make the new operation                                              */
    return NewFilter( name, 1L, (Obj)0, (ObjFunc)0 );
}


/****************************************************************************
**
*F  FuncFLAG1_FILTER( <self>, <oper> )  . . . . . . . . . . . .  `FLAG1_FILT'
*/
Obj FuncFLAG1_FILTER (
    Obj                 self,
    Obj                 oper )
{
    Obj                 flag1;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    flag1 = FLAG1_FILT( oper );
    if ( flag1 == 0 )
        flag1 = INTOBJ_INT(0);
    return flag1;
}


/****************************************************************************
**
*F  FuncSET_FLAG1_FILTER( <self>, <oper>, <flag1> ) . . . .  set `FLAG1_FILT'
*/
Obj FuncSET_FLAG1_FILTER (
    Obj                 self,
    Obj                 oper,
    Obj                 flag1 )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    SET_FLAG1_FILT(oper, flag1);
    return 0;
}


/****************************************************************************
**
*F  FuncFLAG2_FILTER( <self>, <oper> )  . . . . . . . . . . . .  `FLAG2_FILT'
*/
Obj FuncFLAG2_FILTER (
    Obj                 self,
    Obj                 oper )
{
    Obj                 flag2;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    flag2 = FLAG2_FILT( oper );
    if ( flag2 == 0 )
        flag2 = INTOBJ_INT(0);
    return flag2;
}


/****************************************************************************
**
*F  FuncSET_FLAG2_FILTER( <self>, <oper>, <flag2> ) . . . .  set `FLAG2_FILT'
*/
Obj FuncSET_FLAG2_FILTER (
    Obj                 self,
    Obj                 oper,
    Obj                 flag2 )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    SET_FLAG2_FILT(oper, flag2);
    return 0;
}


/****************************************************************************
**
*F  FuncFLAGS_FILTER( <self>, <oper> )  . . . . . . . . . . . .  `FLAGS_FILT'
*/
Obj FuncFLAGS_FILTER (
    Obj                 self,
    Obj                 oper )
{
    Obj                 flags;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    flags = FLAGS_FILT( oper );
    if ( flags == 0 )
        flags = False;
    return flags;
}


/****************************************************************************
**
*F  FuncSET_FLAGS_FILTER( <self>, <oper>, <flags> ) . . . .  set `FLAGS_FILT'
*/
Obj FuncSET_FLAGS_FILTER (
    Obj                 self,
    Obj                 oper,
    Obj                 flags )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    SET_FLAGS_FILT(oper, flags);
    return 0;
}


/****************************************************************************
**
*F  FuncSETTER_FILTER( <self>, <oper> ) . . . . . . . . .  setter of a filter
*/
Obj FuncSETTER_FILTER (
    Obj                 self,
    Obj                 oper )
{
    Obj                 setter;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    setter = SetterFilter( oper );
    if ( setter == 0 )  setter = False;
    return setter;
}


/****************************************************************************
**
*F  FuncSET_SETTER_FILTER( <self>, <oper>, <setter> )  set setter of a filter
*/
Obj FuncSET_SETTER_FILTER (
    Obj                 self,
    Obj                 oper,
    Obj                 setter )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    SET_SETTR_FILT(oper, setter);
    return 0;
}


/****************************************************************************
**
*F  FuncTESTER_FILTER( <self>, <oper> ) . . . . . . . . .  tester of a filter
*/
Obj FuncTESTER_FILTER (
    Obj                 self,
    Obj                 oper )
{
    Obj                 tester;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    tester = TesterFilter( oper );
    if ( tester == 0 )  tester = False;
    return tester;
}


/****************************************************************************
**
*F  FuncSET_TESTER_FILTER( <self>, <oper>, <tester> )  set tester of a filter
*/
Obj FuncSET_TESTER_FILTER (
    Obj                 self,
    Obj                 oper,
    Obj                 tester )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    if ( SIZE_OBJ(oper) != sizeof(OperBag) ) {
        ResizeBag( oper, sizeof(OperBag) );
    }
    SET_TESTR_FILT(oper, tester);
    return 0;
}


/****************************************************************************
**
*F * * * * * * * * * *  internal operation functions  * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  HandleMethodNotFound( <oper>, <nargs>, <args>, <verbose>, <constructor>,
**                        <precedence> )
**
**  This enables the special error handling for Method Not Found Errors.
**  It assembles all the necessary information into a form where it can be
**  conveniently accessed from GAP.
**
*/

static UInt RNamOperation;
static UInt RNamArguments;
static UInt RNamIsVerbose;
static UInt RNamIsConstructor;
static UInt RNamPrecedence;
static Obj  HANDLE_METHOD_NOT_FOUND;

static void HandleMethodNotFound(Obj   oper,
                                 Int   nargs,
                                 Obj * args,
                                 UInt  verbose,
                                 UInt  constructor,
                                 Int   precedence)
{
  Obj r;
  Obj arglist;
  UInt i;
#ifdef HPCGAP
  Region *savedRegion = TLS(currentRegion);
  TLS(currentRegion) = TLS(threadRegion);
#endif

  r = NEW_PREC(5);
  if (RNamOperation == 0)
    {
      /* we can't do this in initialization because opers
         is initialized BEFORE records */
      RNamIsConstructor = RNamName("isConstructor");
      RNamIsVerbose = RNamName("isVerbose");
      RNamOperation = RNamName("Operation");
      RNamArguments = RNamName("Arguments");
      RNamPrecedence = RNamName("Precedence");
    }
  AssPRec(r,RNamOperation,oper);
  arglist = NEW_PLIST_IMM(nargs ? T_PLIST_DENSE : T_PLIST_EMPTY, nargs);
  SET_LEN_PLIST(arglist,nargs);
  for (i = 0; i < nargs; i++)
    SET_ELM_PLIST( arglist, i+1, args[i]);
  CHANGED_BAG(arglist);
  AssPRec(r,RNamArguments,arglist);
  AssPRec(r,RNamIsVerbose,verbose ? True : False);
  AssPRec(r,RNamIsConstructor,constructor ? True : False);
  AssPRec(r,RNamPrecedence,INTOBJ_INT(precedence));
  SortPRecRNam(r,0);
  CALL_1ARGS(HANDLE_METHOD_NOT_FOUND, r);
#ifdef HPCGAP
  TLS(currentRegion) = savedRegion;
#endif
  ErrorQuit("panic, HANDLE_METHOD_NOT_FOUND should not return", 0, 0);
}

/****************************************************************************
**
*F  FuncCOMPACT_TYPE_IDS( <self> ) . . . garbage collect the type IDs
**
*/

#if !defined(HPCGAP)

static Obj FLUSH_ALL_METHOD_CACHES;

static Int NextTypeID;
static Obj IsType;

static void FixTypeIDs( Bag b ) {
  if ( (TNUM_OBJ( b )  == T_POSOBJ) &&
       (DoFilter(IsType, b ) == True ))
    {
      SET_ID_TYPE(b, INTOBJ_INT(NextTypeID));
      NextTypeID++;
    } 
}


Obj FuncCOMPACT_TYPE_IDS( Obj self )
{
  NextTypeID = INT_INTOBJ_MIN;
  CallbackForAllBags( FixTypeIDs );
  CALL_0ARGS(FLUSH_ALL_METHOD_CACHES);
  return INTOBJ_INT(NextTypeID);
}

#endif

/****************************************************************************
**
*F  DoOperation<N>Args( <oper>, ... ) . . . . . . . . . .  Operation Handlers
**
**  This section of the file provides handlers for operations. The main ones
**  are DoOperation0Args ... DoOperation6Args and the DoVerboseOperation
**  tracing variants. Then there are variants for constructors. In the
**  following section are handlers for attributes, properties and the
**  operations related to them.
**
**  This code has been refactored to reduce repetition. Its efficiency now
**  depends on the C compiler inlining some quite large functions and then
**  doing constant folding to effectively produce a specialised version of
**  the main function. This is why several functions below have been
**  marked with 'ALWAYS_INLINE'.
*/

// Helper function to quickly get the type of an object, avoiding
// indirection in the case of external objects with a stored type I.e.,
// the compiler can inline TYPE_COMOBJ etc., while it cannot inline
// TYPE_OBJ
static inline Obj TYPE_OBJ_FEO(Obj obj)
{
#ifdef HPCGAP
    /* TODO: We need to be able to automatically derive this. */
    ImpliedWriteGuard(obj);
#endif
    switch ( TNUM_OBJ( obj ) ) {
    case T_COMOBJ:
        return TYPE_COMOBJ(obj);
    case T_POSOBJ:
        return TYPE_POSOBJ(obj);
    case T_DATOBJ:
        return TYPE_DATOBJ(obj);
    default:
        return TYPE_OBJ(obj);
    }
}

/* Method Cache -- we remember recently selected methods in a cache.
   The effectiveness of this cache is vital for GAP's performance */


/* The next few functions deal with finding and allocating if necessary the cache 
   for a given operation and number of arguments, and some locking in HPC-GAP */


#ifdef HPCGAP

static pthread_mutex_t CacheLock;
static UInt            CacheSize;

static void LockCache(void)
{
    if (!PreThreadCreation)
        pthread_mutex_lock(&CacheLock);
}

static void UnlockCache(void)
{
    if (!PreThreadCreation)
        pthread_mutex_unlock(&CacheLock);
}

#endif

static inline Obj CacheOper(Obj oper, UInt i)
{
    Obj  cache = CACHE_OPER(oper, i);
    UInt len;

#ifdef HPCGAP
    UInt cacheIndex;

    if (cache == 0) {
        /* This is a safe form of double-checked locking, because
         * the cache value is not a reference. */
        LockCache();
        cache = CACHE_OPER(oper, i);
        if (cache == 0) {
            CacheSize++;
            cacheIndex = CacheSize;
            SET_CACHE_OPER(oper, i, INTOBJ_INT(cacheIndex));
        }
        else
            cacheIndex = INT_INTOBJ(cache);
        UnlockCache();
    }
    else {
        cacheIndex = INT_INTOBJ(cache);
    }

    if (cacheIndex > STATE(MethodCacheSize)) {
        len = STATE(MethodCacheSize);
        while (cacheIndex > len)
            len *= 2;
        GROW_PLIST(STATE(MethodCache), len);
        SET_LEN_PLIST(STATE(MethodCache), len);
        STATE(MethodCacheItems) = ADDR_OBJ(STATE(MethodCache));
        STATE(MethodCacheSize) = len;
    }

    cache = ELM_PLIST(STATE(MethodCache), cacheIndex);
#endif

    if (cache == 0) {
        len = (i < 7 ? CACHE_SIZE * (i + 2) : CACHE_SIZE * (1 + 2));
        cache = NEW_PLIST(T_PLIST, len);
        SET_LEN_PLIST(cache, len);
#ifdef HPCGAP
        SET_ELM_PLIST(STATE(MethodCache), cacheIndex, cache);
        CHANGED_BAG(STATE(MethodCache));
#else
        SET_CACHE_OPER(oper, i, cache);
        CHANGED_BAG(oper);
#endif
    }

    return cache;
}


#ifdef HPCGAP

#define GET_METHOD_CACHE(oper, i)                                            \
    (STATE(MethodCacheItems)[INT_INTOBJ(CACHE_OPER(oper, i))])

#else

#define GET_METHOD_CACHE(oper, i) CACHE_OPER(oper, i)

#endif

#ifdef COUNT_OPERS
static UInt CacheHitStatistics[CACHE_SIZE][CACHE_SIZE][7];
static UInt CacheMissStatistics[CACHE_SIZE + 1][7];
#endif


// This function actually searches the cache. Normally it should be
// called with n a compile-time constant to allow the optimiser to tidy
// things up.
// It is also marked with 'ALWAYS_INLINE' for this reason (see above).
static ALWAYS_INLINE Obj GetMethodCached(Obj  oper,
                                         UInt n,
                                         Int  prec,
                                         Obj  ids[])
{
    UInt  typematch;
    Obj * cache;
    Obj   method = 0;
    UInt  i;
    const UInt cacheEntrySize = n + 2;

    cache = 1 + ADDR_OBJ(CacheOper(oper, n));

    /* Up to CACHE_SIZE methods might be in the cache */
    if (prec < CACHE_SIZE) {
        /* This loop runs through those */
        UInt target =
            cacheEntrySize * prec; /* first place to look and also the place
                                      we'll put the result */
        for (i = target; i < cacheEntrySize * CACHE_SIZE;
             i += cacheEntrySize) {
            if (cache[i + 1] == INTOBJ_INT(prec)) {
                typematch = 1;
                // This loop runs over the arguments, should be compiled away
                for (UInt j = 0; j < n; j++) {
                    if (cache[i + j + 2] != ids[j]) {
                        typematch = 0;
                        break;
                    }
                }
                if (typematch) {
                    method = cache[i];
#ifdef COUNT_OPERS
                    CacheHitStatistics[prec][i / cacheEntrySize][n]++;
#endif
                    if (i > target) {

                        /* We found the method, but it was further down the
                           cache than we would like it to be, so move it up */
                        Obj buf[cacheEntrySize];
                        memcpy(buf, cache + i,
                               sizeof(Obj) * cacheEntrySize);
                        SyMemmove(cache + target + cacheEntrySize,
                                cache + target,
                                sizeof(Obj) * (i - target));
                        memcpy(cache + target, buf,
                               sizeof(Obj) * cacheEntrySize);
                    }
                    break;
                }
            }
        }
    }
    return method;
}

/* Add a method to the cache -- called when a method is selected that is not
   in the cache */
static inline void
CacheMethod(Obj oper, UInt n, Int prec, Obj * ids, Obj method)
{
    if (prec >= CACHE_SIZE)
        return;
    /* We insert this method at position <prec> and move
       the older methods down */
    UInt  cacheEntrySize = n + 2;
    Bag   cacheBag = GET_METHOD_CACHE(oper, n);
    Obj * cache = 1 + prec * cacheEntrySize + ADDR_OBJ(cacheBag);
    SyMemmove(cache + cacheEntrySize, cache,
            sizeof(Obj) * (CACHE_SIZE - prec - 1) * cacheEntrySize);
    cache[0] = method;
    cache[1] = INTOBJ_INT(prec);
    for (UInt i = 0; i < n; i++)
        cache[2 + i] = ids[i];
    CHANGED_BAG(cacheBag);
}

static Obj ReturnTrue;
static Obj VMETHOD_PRINT_INFO;
static Obj NEXT_VMETHOD_PRINT_INFO;

// This function searches through the methods of operation <oper> with
// arity <n>, looking for those matching the given <types>. Among these,
// the <prec>-th is selected (<prec> starts at 0).
//
// If <verbose> is non-zero, the matching method are printed by calling
// 'VMETHOD_PRINT_INFO' resp. 'NEXT_VMETHOD_PRINT_INFO'.
//
// If <constructor> is non-zero, then <oper> is a constructor, leading
// to <types[0]> being treated differently.
//
// Use of 'ALWAYS_INLINE' is critical for performance, see discussion
// earlier in this file.
enum {
    BASE_SIZE_METHODS_OPER_ENTRY = 5,
};
static ALWAYS_INLINE Obj GetMethodUncached(
    UInt verbose, UInt constructor, UInt n, Obj oper, Int prec, Obj types[])
{
    Obj methods = METHS_OPER(oper, n);
    if (methods == 0)
        return Fail;

    const UInt len = LEN_PLIST(methods);
    UInt       j = 0;
    for (UInt pos = 0; pos < len; pos += n + BASE_SIZE_METHODS_OPER_ENTRY) {
        // each method comprises n + BASE_SIZE_METHODS_OPER_ENTRY
        // entries in the 'methods' list:
        // entry 1 is the family predicate;
        // entries 2 till n+1 are the n argument filters
        // entry n+2 is the actual method
        // entry n+3 is the rank
        // entry n+4 is the info text
        // entry n+5 is, if set, the location where the method was installed

        // check argument filters against the given types
        Obj filter;
        int k = 1;
        if (constructor) {
            filter = ELM_PLIST(methods, pos + k + 1);
            GAP_ASSERT(TNUM_OBJ(filter) == T_FLAGS);
            if (!IS_SUBSET_FLAGS(filter, types[0]))
                continue;
            k++;
        }
        for (; k <= n; ++k) {
            filter = ELM_PLIST(methods, pos + k + 1);
            GAP_ASSERT(TNUM_OBJ(filter) == T_FLAGS);
            if (!IS_SUBSET_FLAGS(FLAGS_TYPE(types[k - 1]), filter))
                break;
        }

        // if some filter did not match, go to next method
        if (k <= n)
            continue;

        // check family predicate, with a hot path for the very
        // common trivial predicate 'ReturnTrue'
        Obj fampred = ELM_PLIST(methods, pos + 1);
        if (fampred != ReturnTrue) {
            Obj res = 0;
            switch (n) {
            case 0:
                res = CALL_0ARGS(fampred);
                break;
            case 1:
                res = CALL_1ARGS(fampred, FAMILY_TYPE(types[0]));
                break;
            case 2:
                res = CALL_2ARGS(fampred, FAMILY_TYPE(types[0]),
                                 FAMILY_TYPE(types[1]));
                break;
            case 3:
                res =
                    CALL_3ARGS(fampred, FAMILY_TYPE(types[0]),
                               FAMILY_TYPE(types[1]), FAMILY_TYPE(types[2]));
                break;
            case 4:
                res = CALL_4ARGS(fampred, FAMILY_TYPE(types[0]),
                                 FAMILY_TYPE(types[1]), FAMILY_TYPE(types[2]),
                                 FAMILY_TYPE(types[3]));
                break;
            case 5:
                res =
                    CALL_5ARGS(fampred, FAMILY_TYPE(types[0]),
                               FAMILY_TYPE(types[1]), FAMILY_TYPE(types[2]),
                               FAMILY_TYPE(types[3]), FAMILY_TYPE(types[4]));
                break;
            case 6:
                res = CALL_6ARGS(fampred, FAMILY_TYPE(types[0]),
                                 FAMILY_TYPE(types[1]), FAMILY_TYPE(types[2]),
                                 FAMILY_TYPE(types[3]), FAMILY_TYPE(types[4]),
                                 FAMILY_TYPE(types[5]));
                break;
            default:
                ErrorMayQuit("not supported yet", 0, 0);
            }

            if (res != True)
                continue;
        }

        // we have a match; is it the right one?
        if (prec == j) {
            if (verbose) {
                CALL_3ARGS(prec == 0 ? VMETHOD_PRINT_INFO : NEXT_VMETHOD_PRINT_INFO, methods,
                           INTOBJ_INT(pos / (n + BASE_SIZE_METHODS_OPER_ENTRY) + 1),
                           INTOBJ_INT(n));

            }
            Obj meth = ELM_PLIST(methods, pos + n + 2);
            return meth;
        }
        j++;
    }
    return Fail;
}

#ifdef COUNT_OPERS
static Int OperationHit;
static Int OperationMiss;
static Int OperationNext;
#endif


// Use of 'ALWAYS_INLINE' is critical for performance, see discussion
// earlier in this file.
static ALWAYS_INLINE Obj DoOperationNArgs(Obj  oper,
                 UInt n,
                 UInt verbose,
                 UInt constructor,
                 Obj  arg1,
                 Obj  arg2,
                 Obj  arg3,
                 Obj  arg4,
                 Obj  arg5,
                 Obj  arg6)
{
    Obj types[n];
    Obj ids[n];
    Int prec;
    Obj method;
    Obj res;

    /* It is intentional that each case in this case statement except 0
       drops through */
    switch (n) {
    case 6:
        types[5] = TYPE_OBJ_FEO(arg6);
    case 5:
        types[4] = TYPE_OBJ_FEO(arg5);
    case 4:
        types[3] = TYPE_OBJ_FEO(arg4);
    case 3:
        types[2] = TYPE_OBJ_FEO(arg3);
    case 2:
        types[1] = TYPE_OBJ_FEO(arg2);
    case 1:
        if (constructor) {
            while (!IS_OPERATION(arg1)) {
                arg1 = ErrorReturnObj("Constructor: the first argument must "
                                      "be a filter not a %s",
                                      (Int)TNAM_OBJ(arg1), 0L,
                                      "you can replace the first argument "
                                      "<arg1> via 'return <arg1>;'");
            }

            types[0] = FLAGS_FILT(arg1);
        }
        else
            types[0] = TYPE_OBJ_FEO(arg1);
    case 0:
        break;
    default:
        GAP_ASSERT(0);
    }

    if (n > 0) {
        if (constructor)
            ids[0] = types[0];
        else
            ids[0] = ID_TYPE(types[0]);
    }

    for (UInt i = 1; i < n; i++)
        ids[i] = ID_TYPE(types[i]);

    /* outer loop deals with TryNextMethod */
    prec = -1;
    do {
        prec++;
        /* Is there a method in the cache */
        method = verbose ? 0 : GetMethodCached(oper, n, prec, ids);

#ifdef COUNT_OPERS
        if (method)
            OperationHit++;
        else {
            OperationMiss++;
            CacheMissStatistics[(prec >= CACHE_SIZE) ? CACHE_SIZE : prec]
                               [n]++;
        }
        if (prec > 0)
            OperationNext++;
#endif

        /* otherwise try to find one in the list of methods */
        if (!method) {
            method = GetMethodUncached(verbose, constructor, n, oper,
                                              prec, types);
            /* update the cache */
            if (!verbose && method)
                CacheMethod(oper, n, prec, ids, method);
        }

        /* If there was no method found, then pass the information needed
           for the error reporting. This function rarely returns */
        if (method == Fail) {
            Obj args[n];
            /* It is intentional that each case in this case statement except
               0 drops through */
            switch (n) {
            case 6:
                args[5] = arg6;
            case 5:
                args[4] = arg5;
            case 4:
                args[3] = arg4;
            case 3:
                args[2] = arg3;
            case 2:
                args[1] = arg2;
            case 1:
                args[0] = arg1;
            case 0:
                break;
            default:
                GAP_ASSERT(0);
            }
            HandleMethodNotFound(oper, n, args, verbose, constructor, prec);
        }

        if (!method) {
            ErrorQuit("no method returned", 0L, 0L);
        }

        /* call this method */
        switch (n) {
        case 0:
            res = CALL_0ARGS(method);
            break;
        case 1:
            res = CALL_1ARGS(method, arg1);
            break;
        case 2:
            res = CALL_2ARGS(method, arg1, arg2);
            break;
        case 3:
            res = CALL_3ARGS(method, arg1, arg2, arg3);
            break;
        case 4:
            res = CALL_4ARGS(method, arg1, arg2, arg3, arg4);
            break;
        case 5:
            res = CALL_5ARGS(method, arg1, arg2, arg3, arg4, arg5);
            break;
        case 6:
            res = CALL_6ARGS(method, arg1, arg2, arg3, arg4, arg5, arg6);
            break;
        }
    } while (res == TRY_NEXT_METHOD);

    /* return the result                                                   */
    return res;
}


Obj DoOperation0Args(Obj oper)
{
    return DoOperationNArgs(oper, 0, 0, 0, 0, 0, 0, 0, 0, 0);
}

Obj DoOperation1Args(Obj oper, Obj arg1)
{
    return DoOperationNArgs(oper, 1, 0, 0, arg1, 0, 0, 0, 0,
                            0);
}

Obj DoOperation2Args(Obj oper, Obj arg1, Obj arg2)
{
    return DoOperationNArgs(oper, 2, 0, 0, arg1, arg2, 0, 0,
                            0, 0);
}

Obj DoOperation3Args(Obj oper, Obj arg1, Obj arg2, Obj arg3)
{
    return DoOperationNArgs(oper, 3, 0, 0, arg1, arg2, arg3,
                            0, 0, 0);
}

Obj DoOperation4Args(Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4)
{
    return DoOperationNArgs(oper, 4, 0, 0, arg1, arg2, arg3,
                            arg4, 0, 0);
}

Obj DoOperation5Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5)
{
    return DoOperationNArgs(oper, 5, 0, 0, arg1, arg2, arg3,
                            arg4, arg5, 0);
}

Obj DoOperation6Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6)
{
    return DoOperationNArgs(oper, 6, 0, 0, arg1, arg2, arg3,
                            arg4, arg5, arg6);
}


/****************************************************************************
**
**  DoOperationXArgs( <oper>, ... )
*/

Obj DoOperationXArgs(Obj self, Obj args)
{
    ErrorQuit("sorry: cannot yet have X argument operations", 0L, 0L);
    return 0;
}


/****************************************************************************
**
**  DoVerboseOperation0Args( <oper> )
*/
Obj DoVerboseOperation0Args(Obj oper)
{
    return DoOperationNArgs(oper, 0, 1, 0, 0, 0, 0, 0,
                            0, 0);
}

Obj DoVerboseOperation1Args(Obj oper, Obj arg1)
{
    return DoOperationNArgs(oper, 1, 1, 0, arg1, 0, 0,
                            0, 0, 0);
}

Obj DoVerboseOperation2Args(Obj oper, Obj arg1, Obj arg2)
{
    return DoOperationNArgs(oper, 2, 1, 0, arg1, arg2,
                            0, 0, 0, 0);
}

Obj DoVerboseOperation3Args(Obj oper, Obj arg1, Obj arg2, Obj arg3)
{
    return DoOperationNArgs(oper, 3, 1, 0, arg1, arg2,
                            arg3, 0, 0, 0);
}

Obj DoVerboseOperation4Args(Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4)
{
    return DoOperationNArgs(oper, 4, 1, 0, arg1, arg2,
                            arg3, arg4, 0, 0);
}

Obj DoVerboseOperation5Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5)
{
    return DoOperationNArgs(oper, 5, 1, 0, arg1, arg2,
                            arg3, arg4, arg5, 0);
}

Obj DoVerboseOperation6Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6)
{
    return DoOperationNArgs(oper, 6, 1, 0, arg1, arg2,
                            arg3, arg4, arg5, arg6);
}


/****************************************************************************
**
**  DoVerboseOperationXArgs( <oper>, ... )
*/
Obj DoVerboseOperationXArgs(Obj self, Obj args)
{
    ErrorQuit("sorry: cannot yet have X argument operations", 0L, 0L);
    return 0;
}


/****************************************************************************
**
*F  NewOperation( <name>, <narg>, <nams>, <hdlr> )
*/
Obj NewOperation(Obj name, Int narg, Obj nams, ObjFunc hdlr)
{
    Obj oper;

    /* create the function                                                 */
    oper = NewFunctionT(T_FUNCTION, sizeof(OperBag), name, narg, nams, hdlr);

    /* enter the handlers                                                  */
    SET_HDLR_FUNC(oper, 0, DoOperation0Args);
    SET_HDLR_FUNC(oper, 1, DoOperation1Args);
    SET_HDLR_FUNC(oper, 2, DoOperation2Args);
    SET_HDLR_FUNC(oper, 3, DoOperation3Args);
    SET_HDLR_FUNC(oper, 4, DoOperation4Args);
    SET_HDLR_FUNC(oper, 5, DoOperation5Args);
    SET_HDLR_FUNC(oper, 6, DoOperation6Args);
    SET_HDLR_FUNC(oper, 7, DoOperationXArgs);

    /* reenter the given handler */
    if (narg != -1)
        SET_HDLR_FUNC(oper, narg, hdlr);

    /*N 1996/06/06 mschoene this should not be done here                   */
    SET_FLAG1_FILT(oper, INTOBJ_INT(0));
    SET_FLAG2_FILT(oper, INTOBJ_INT(0));
    SET_FLAGS_FILT(oper, False);
    SET_SETTR_FILT(oper, False);
    SET_TESTR_FILT(oper, False);

    /* This isn't an attribute (yet) */
    SET_ENABLED_ATTR(oper, 0);

    /* return operation                                                    */
    return oper;
}


/****************************************************************************
**
**  DoConstructor0Args( <oper> )
**
** I'm not sure if this makes any sense at all
*/


Obj DoConstructor0Args(Obj oper)
{
    return DoOperationNArgs(oper, 0, 0, 1, 0, 0, 0, 0,
                            0, 0);
}

Obj DoConstructor1Args(Obj oper, Obj arg1)
{
    return DoOperationNArgs(oper, 1, 0, 1, arg1, 0, 0,
                            0, 0, 0);
}

Obj DoConstructor2Args(Obj oper, Obj arg1, Obj arg2)
{
    return DoOperationNArgs(oper, 2, 0, 1, arg1, arg2,
                            0, 0, 0, 0);
}

Obj DoConstructor3Args(Obj oper, Obj arg1, Obj arg2, Obj arg3)
{
    return DoOperationNArgs(oper, 3, 0, 1, arg1, arg2,
                            arg3, 0, 0, 0);
}

Obj DoConstructor4Args(Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4)
{
    return DoOperationNArgs(oper, 4, 0, 1, arg1, arg2,
                            arg3, arg4, 0, 0);
}

Obj DoConstructor5Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5)
{
    return DoOperationNArgs(oper, 5, 0, 1, arg1, arg2,
                            arg3, arg4, arg5, 0);
}

Obj DoConstructor6Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6)
{
    return DoOperationNArgs(oper, 6, 0, 1, arg1, arg2,
                            arg3, arg4, arg5, arg6);
}


/****************************************************************************
**
**  DoConstructorXArgs( <oper>, ... )
*/
Obj DoConstructorXArgs(Obj self, Obj args)
{
    ErrorQuit("sorry: cannot yet have X argument constructors", 0L, 0L);
    return 0;
}

/****************************************************************************
**
**  DoVerboseConstructor0Args( <oper> )
*/

Obj DoVerboseConstructor0Args(Obj oper)
{
    return DoOperationNArgs(oper, 0, 1, 1, 0, 0,
                            0, 0, 0, 0);
}

Obj DoVerboseConstructor1Args(Obj oper, Obj arg1)
{
    return DoOperationNArgs(oper, 1, 1, 1, arg1,
                            0, 0, 0, 0, 0);
}

Obj DoVerboseConstructor2Args(Obj oper, Obj arg1, Obj arg2)
{
    return DoOperationNArgs(oper, 2, 1, 1, arg1,
                            arg2, 0, 0, 0, 0);
}

Obj DoVerboseConstructor3Args(Obj oper, Obj arg1, Obj arg2, Obj arg3)
{
    return DoOperationNArgs(oper, 3, 1, 1, arg1,
                            arg2, arg3, 0, 0, 0);
}

Obj DoVerboseConstructor4Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4)
{
    return DoOperationNArgs(oper, 4, 1, 1, arg1,
                            arg2, arg3, arg4, 0, 0);
}

Obj DoVerboseConstructor5Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5)
{
    return DoOperationNArgs(oper, 5, 1, 1, arg1,
                            arg2, arg3, arg4, arg5, 0);
}

Obj DoVerboseConstructor6Args(
    Obj oper, Obj arg1, Obj arg2, Obj arg3, Obj arg4, Obj arg5, Obj arg6)
{
    return DoOperationNArgs(oper, 6, 1, 1, arg1,
                            arg2, arg3, arg4, arg5, arg6);
}


/****************************************************************************
**
**  DoVerboseConstructorXArgs( <oper>, ... )
*/
Obj DoVerboseConstructorXArgs(Obj self, Obj args)
{
    ErrorQuit("sorry: cannot yet have X argument constructors", 0L, 0L);
    return 0;
}


/****************************************************************************
**
*F  NewConstructor( <name>> )
*/
Obj NewConstructor(Obj name)
{
    Obj                 oper;

    /* create the function                                                 */
    oper = NewFunctionT( T_FUNCTION, sizeof(OperBag), name, -1, 0, 0 );

    /* enter the handlers                                                  */
    SET_HDLR_FUNC(oper, 0, DoConstructor0Args);
    SET_HDLR_FUNC(oper, 1, DoConstructor1Args);
    SET_HDLR_FUNC(oper, 2, DoConstructor2Args);
    SET_HDLR_FUNC(oper, 3, DoConstructor3Args);
    SET_HDLR_FUNC(oper, 4, DoConstructor4Args);
    SET_HDLR_FUNC(oper, 5, DoConstructor5Args);
    SET_HDLR_FUNC(oper, 6, DoConstructor6Args);
    SET_HDLR_FUNC(oper, 7, DoConstructorXArgs);

    /*N 1996/06/06 mschoene this should not be done here                   */
    SET_FLAG1_FILT(oper, INTOBJ_INT(0));
    SET_FLAG2_FILT(oper, INTOBJ_INT(0));
    SET_FLAGS_FILT(oper, False);
    SET_SETTR_FILT(oper, False);
    SET_TESTR_FILT(oper, False);

    /* return constructor                                                  */
    return oper;
}


/****************************************************************************
**
*F  DoAttribute( <name> ) . . . . . . . . . . . . . . .  make a new attribute
*/



/****************************************************************************
**
**  DoTestAttribute( <attr>, <obj> )
*/
Obj DoTestAttribute (
    Obj                 self,
    Obj                 obj )
{
    Int                 flag2;
    Obj                 type;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get type of the object and its flags                                */
    type  = TYPE_OBJ_FEO( obj );
    flags = FLAGS_TYPE( type );

    /* return whether the value of the attribute is already known          */
    return SAFE_ELM_FLAGS( flags, flag2 );
}


/****************************************************************************
**
**  DoAttribute( <attr>, <obj> )
*/
#define DoSetAttribute  DoOperation2Args

Obj DoAttribute (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag2;
    Obj                 type;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get type of the object and its flags                                */
    type  = TYPE_OBJ_FEO( obj );
    flags = FLAGS_TYPE( type );

    /* if the value of the attribute is already known, simply return it     */
    if ( SAFE_C_ELM_FLAGS( flags, flag2 ) ) {
        return DoOperation1Args( self, obj );
    }
    
    /* call the operation to compute the value                             */
    val = DoOperation1Args( self, obj );
    while (val == (Obj) 0) {
        val = ErrorReturnObj("Method for an attribute must return a value",
                             0L, 0L, 
                             "you can supply a value <val> via 'return <val>;'");
    }
    val = CopyObj( val, 0 );
    
    /* set the value (but not for internal objects)                        */
    if ( ENABLED_ATTR( self ) == 1 ) {
        switch ( TNUM_OBJ( obj ) ) {
        case T_COMOBJ:
        case T_POSOBJ:
        case T_DATOBJ:
#ifdef HPCGAP
        case T_ACOMOBJ:
        case T_APOSOBJ:
#endif
            DoSetAttribute( SETTR_FILT(self), obj, val );
        }
    }
    
    /* return the value                                                    */
    return val;    
}


/****************************************************************************
**
**  DoVerboseAttribute( <attr>, <obj> )
*/
#define DoVerboseSetAttribute  DoVerboseOperation2Args

Obj DoVerboseAttribute (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag2;
    Obj                 type;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get type of the object and its flags                                */
    type  = TYPE_OBJ_FEO( obj );
    flags = FLAGS_TYPE( type );

    /* if the value of the attribute is already known, simply return it     */
    if ( SAFE_C_ELM_FLAGS( flags, flag2 ) ) {
        return DoVerboseOperation1Args( self, obj );
    }
    
    /* call the operation to compute the value                             */
    val = DoVerboseOperation1Args( self, obj );
    val = CopyObj( val, 0 );
    
    /* set the value (but not for internal objects)                        */
    if ( ENABLED_ATTR( self ) == 1 ) {
        switch ( TNUM_OBJ( obj ) ) {
        case T_COMOBJ:
        case T_POSOBJ:
        case T_DATOBJ:
#ifdef HPCGAP
        case T_ACOMOBJ:
        case T_APOSOBJ:
#endif
            DoVerboseSetAttribute( SETTR_FILT(self), obj, val );
        }
    }
    
    /* return the value                                                    */
    return val;    
}


/****************************************************************************
**
**  DoMutableAttribute( <attr>, <obj> )
*/
Obj DoMutableAttribute (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag2;
    Obj                 type;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get type of the object and its flags                                */
    type  = TYPE_OBJ_FEO( obj );
    flags = FLAGS_TYPE( type );

    /* if the value of the attribute is already known, simply return it     */
    if ( SAFE_C_ELM_FLAGS( flags, flag2 ) ) {
        return DoOperation1Args( self, obj );
    }
    
    /* call the operation to compute the value                             */
    val = DoOperation1Args( self, obj );
    
    /* set the value (but not for internal objects)                        */
    if ( ENABLED_ATTR( self ) == 1 ) {
        switch ( TNUM_OBJ( obj ) ) {
        case T_COMOBJ:
        case T_POSOBJ:
        case T_DATOBJ:
#ifdef HPCGAP
        case T_ACOMOBJ:
        case T_APOSOBJ:
#endif
            DoSetAttribute( SETTR_FILT(self), obj, val );
        }
    }
    
    /* return the value                                                    */
    return val;    
}


/****************************************************************************
**
**  DoVerboseMutableAttribute( <attr>, <obj> )
*/
Obj DoVerboseMutableAttribute (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag2;
    Obj                 type;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get type of the object and its flags                                */
    type  = TYPE_OBJ_FEO( obj );
    flags = FLAGS_TYPE( type );

    /* if the value of the attribute is already known, simply return it     */
    if ( SAFE_C_ELM_FLAGS( flags, flag2 ) ) {
        return DoVerboseOperation1Args( self, obj );
    }
    
    /* call the operation to compute the value                             */
    val = DoVerboseOperation1Args( self, obj );
    
    /* set the value (but not for internal objects)                        */
    if ( ENABLED_ATTR( self ) == 1 ) {
        switch ( TNUM_OBJ( obj ) ) {
        case T_COMOBJ:
        case T_POSOBJ:
        case T_DATOBJ:
#ifdef HPCGAP
        case T_ACOMOBJ:
        case T_APOSOBJ:
#endif
            DoVerboseSetAttribute( SETTR_FILT(self), obj, val );
        }
    }
    
    /* return the value                                                    */
    return val;    
}


/****************************************************************************
**
*F  NewAttribute( <name>, <narg>, <nams>, <hdlr> )
**
** MakeSetter, MakeTester and SetupAttribute are support functions
*/

#if !defined(HPCGAP)
#define ImpliedWriteGuard(x)
#endif

static Obj WRAP_NAME(Obj name, const char *addon)
{
    UInt name_len = GET_LEN_STRING(name);
    UInt addon_len = strlen(addon);
    Obj fname = NEW_STRING( name_len + addon_len + 2 );
    ImpliedWriteGuard(fname);

    char *ptr = CSTR_STRING(fname);
    memcpy( ptr, addon, addon_len );
    ptr += addon_len;
    *ptr++ = '(';
    memcpy( ptr, CSTR_STRING(name), name_len );
    ptr += name_len;
    *ptr++ = ')';
    *ptr = 0;
    MakeImmutableString(fname);
    return fname;
}

static Obj PREFIX_NAME(Obj name, const char *prefix)
{
    UInt name_len = GET_LEN_STRING(name);
    UInt prefix_len = strlen(prefix);
    Obj fname = NEW_STRING( name_len + prefix_len );
    ImpliedWriteGuard(fname);

    char *ptr = CSTR_STRING(fname);
    memcpy( ptr, prefix, prefix_len );
    ptr += prefix_len;
    memcpy( ptr, CSTR_STRING(name), name_len );
    ptr += name_len;
    *ptr = 0;
    MakeImmutableString(fname);
    return fname;
}

static Obj MakeSetter(Obj name, Int flag1, Int flag2, Obj (*setFunc)(Obj, Obj, Obj))
{
    Obj fname;
    Obj setter;
    fname = PREFIX_NAME(name, "Set");
    setter = NewOperation( fname, 2L, 0L, setFunc );
    SET_FLAG1_FILT(setter, INTOBJ_INT(flag1));
    SET_FLAG2_FILT(setter, INTOBJ_INT(flag2));
    CHANGED_BAG(setter);
    return setter;
}

static Obj MakeTester( Obj name, Int flag1, Int flag2)
{
    Obj fname;
    Obj tester;
    Obj flags;
    fname = PREFIX_NAME(name, "Has");
    tester = NewFunctionT( T_FUNCTION, sizeof(OperBag), fname, 1L, 0L,
                           DoTestAttribute );
    SET_FLAG1_FILT(tester, INTOBJ_INT(flag1));
    SET_FLAG2_FILT(tester, INTOBJ_INT(flag2));
    flags = NEW_FLAGS( flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    SET_FLAGS_FILT(tester, flags);
    SET_SETTR_FILT(tester, 0);
    SET_TESTR_FILT(tester, ReturnTrueFilter);
    CHANGED_BAG(tester);
    return tester;
}


static void SetupAttribute(Obj attr, Obj setter, Obj tester, Int flag2)
{
    // Install additional data
    SET_FLAG1_FILT(attr, INTOBJ_INT(0));
    SET_FLAG2_FILT(attr, INTOBJ_INT(flag2));

    // reuse flags from tester
    SET_FLAGS_FILT(attr, FLAGS_FILT(tester));

    SET_SETTR_FILT(attr, setter);
    SET_TESTR_FILT(attr, tester);
    SET_ENABLED_ATTR(attr,1);
    CHANGED_BAG(attr);
}

  

Obj NewAttribute (
    Obj                 name,
    Int                 narg,
    Obj                 nams,
    ObjFunc             hdlr )
{
    Obj                 getter;
    Obj                 setter;
    Obj                 tester;
    Int                 flag2;
    
    flag2 = ++CountFlags;

    setter = MakeSetter(name, 0, flag2, DoSetAttribute);
    tester = MakeTester(name, 0, flag2);

    getter = NewOperation( name, 1L, nams, (hdlr ? hdlr : DoAttribute) ); 
    
    SetupAttribute(getter, setter, tester, flag2);

    return getter;    
}

/****************************************************************************
**
*F  ConvertOperationIntoAttribute( <oper> )  transform an operation (which 
**  should not have any one-argument declarations) into an attribute
*/

void ConvertOperationIntoAttribute( Obj oper, ObjFunc hdlr ) 
{
    Obj                 setter;
    Obj                 tester;
    Int                 flag2;
    Obj                 name;

    /* Need to get the name from oper */
    name = NAME_FUNC(oper);

    flag2 = ++CountFlags;

    setter = MakeSetter(name, 0, flag2, DoSetAttribute);
    tester = MakeTester(name, 0, flag2);

    /* Change the handlers */
    SET_HDLR_FUNC(oper, 1, hdlr ? hdlr : DoAttribute);

    SetupAttribute( oper, setter, tester, flag2);
}


/****************************************************************************
**
*F  DoProperty( <name> )  . . . . . . . . . . . . . . . . make a new property
*/
Obj SET_FILTER_OBJ;

Obj RESET_FILTER_OBJ;


/****************************************************************************
**
**  DoSetProperty( <prop>, <obj>, <val> )
*/
Obj DoSetProperty (
    Obj                 self,
    Obj                 obj,
    Obj                 val )
{
    Int                 flag1;
    Int                 flag2;
    Obj                 type;
    Obj                 flags;

    /* get the flags for the getter and the tester                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get type of the object and its flags                                */
    type  = TYPE_OBJ_FEO( obj );
    flags = FLAGS_TYPE( type );

    /* if the value of the property is already known, compare it           */
    if ( SAFE_C_ELM_FLAGS( flags, flag2 ) ) {
        if ( val == ELM_FLAGS( flags, flag1 ) ) {
            return 0;
        }
        else {
            ErrorReturnVoid(
                "Value property is already set the other way",
                0L, 0L,
                "you can 'return;' to set it anyhow" );
        }
    }

    /* set the value                                                       */
    /*N 1996/06/28 mschoene <self> is the <setter> here, not the <getter>! */
    /*N 1996/06/28 mschoene see hack below                                 */
    switch ( TNUM_OBJ( obj ) ) {
    case T_COMOBJ:
    case T_POSOBJ:
    case T_DATOBJ:
#ifdef HPCGAP
    case T_ACOMOBJ:
    case T_APOSOBJ:
#endif
        flags = (val == True ? self : TESTR_FILT(self));
        CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
        return 0;
    }

    if ( IS_PLIST(obj) || IS_RANGE(obj) || IS_STRING_REP(obj)
           || IS_BLIST_REP(obj) )  {
        if ( val == True ) {
            FuncSET_FILTER_LIST( 0, obj, self );
        }
    }
    else {
        ErrorReturnVoid(
            "Value cannot be set for internal objects",
            0L, 0L,
            "you can 'return;' without setting it" );
    }

    return 0;
}


/****************************************************************************
**
**  DoProperty( <prop>, <obj> )
*/
Obj DoProperty (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag1;
    Int                 flag2;
    Obj                 type;
    Obj                 flags;

    /* get the flags for the getter and the tester                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get type of the object and its flags                                */
    type  = TYPE_OBJ_FEO( obj );
    flags = FLAGS_TYPE( type );

    /* if the value of the property is already known, simply return it     */
    if ( SAFE_C_ELM_FLAGS( flags, flag2 ) ) {
        return ELM_FLAGS( flags, flag1 );
    }

    /* call the operation to compute the value                             */
    val = DoOperation1Args( self, obj );
    while ( val != True && val != False ) {
        val = ErrorReturnObj( 
               "Method for a property did not return true or false",
               0L, 0L, 
               "you can 'return true;' or 'return false;'");
    }
    
    /* set the value (but not for internal objects)                        */
    if ( ENABLED_ATTR(self) == 1 && ! IS_MUTABLE_OBJ(obj) ) {
        switch ( TNUM_OBJ( obj ) ) {
        case T_COMOBJ:
        case T_POSOBJ:
        case T_DATOBJ:
#ifdef HPCGAP
        case T_ACOMOBJ:
        case T_APOSOBJ:
#endif
            flags = (val == True ? self : TESTR_FILT(self));
            CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
        }
    }

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
**  DoVerboseProperty( <prop>, <obj> )
*/
Obj DoVerboseProperty (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag1;
    Int                 flag2;
    Obj                 type;
    Obj                 flags;

    /* get the flags for the getter and the tester                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get type of the object and its flags                                */
    type  = TYPE_OBJ_FEO( obj );
    flags = FLAGS_TYPE( type );

    /* if the value of the property is already known, simply return it     */
    if ( SAFE_C_ELM_FLAGS( flags, flag2 ) ) {
        return ELM_FLAGS( flags, flag1 );
    }

    /* call the operation to compute the value                             */
    val = DoVerboseOperation1Args( self, obj );
    
    /* set the value (but not for internal objects)                        */
    if ( ENABLED_ATTR(self) == 1 && ! IS_MUTABLE_OBJ(obj) ) {
        switch ( TNUM_OBJ( obj ) ) {
        case T_COMOBJ:
        case T_POSOBJ:
        case T_DATOBJ:
#ifdef HPCGAP
        case T_ACOMOBJ:
        case T_APOSOBJ:
#endif
            flags = (val == True ? self : TESTR_FILT(self));
            CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
        }
    }

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*F  NewProperty( <name>, <narg>, <nams>, <hdlr> )
*/
Obj NewProperty (
    Obj                 name,
    Int                 narg,
    Obj                 nams,
    ObjFunc             hdlr )
{
    Obj                 getter;
    Obj                 setter;
    Obj                 tester;
    Int                 flag1;
    Int                 flag2;
    Obj                 flags;
    
    flag1 = ++CountFlags;
    flag2 = ++CountFlags;

    setter = MakeSetter(name, flag1, flag2, DoSetProperty);
    tester = MakeTester(name, flag1, flag2);

    getter = NewOperation( name, 1L, nams, (hdlr ? hdlr : DoProperty) );

    SET_FLAG1_FILT(getter, INTOBJ_INT(flag1));
    SET_FLAG2_FILT(getter, INTOBJ_INT(flag2));
    flags = NEW_FLAGS( flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    SET_ELM_FLAGS( flags, flag1, True );
    SET_FLAGS_FILT(getter, flags);
    SET_SETTR_FILT(getter, setter);
    SET_TESTR_FILT(getter, tester);
    SET_ENABLED_ATTR(getter,1);
    CHANGED_BAG(getter);

    /*N 1996/06/28 mschoene bad hack see comment in <setter>               */
    SET_FLAGS_FILT(setter, flags);
    SET_SETTR_FILT(setter, setter);
    SET_TESTR_FILT(setter, tester);

    /* return the getter                                                   */
    return getter;    
}


/****************************************************************************
**
*F  DoGlobalFunction( <name> ) . . . . . . . . . . make a new global function
*/


/****************************************************************************
**
**  DoUninstalledGlobalFunction( <oper>, <args> )
*/
Obj DoUninstalledGlobalFunction (
    Obj                 oper,
    Obj                 args )
{
    ErrorQuit( "%g: function is not yet defined",
               (Int)NAME_FUNC(oper), 0L );
    return 0;
}


/****************************************************************************
**
*F  NewGlobalFunction( <name>, <nams> )
*/
Obj NewGlobalFunction (
    Obj                 name,
    Obj                 nams )
{
    Obj                 func;
    Obj                 namobj;

    /* create the function                                                 */
    func = NewFunction( name, -1, nams, DoUninstalledGlobalFunction );
    SET_HDLR_FUNC(func, 0, DoUninstalledGlobalFunction);
    SET_HDLR_FUNC(func, 1, DoUninstalledGlobalFunction);
    SET_HDLR_FUNC(func, 2, DoUninstalledGlobalFunction);
    SET_HDLR_FUNC(func, 3, DoUninstalledGlobalFunction);
    SET_HDLR_FUNC(func, 4, DoUninstalledGlobalFunction);
    SET_HDLR_FUNC(func, 5, DoUninstalledGlobalFunction);
    SET_HDLR_FUNC(func, 6, DoUninstalledGlobalFunction);
    SET_HDLR_FUNC(func, 7, DoUninstalledGlobalFunction);

    /* added the name                                                      */
    namobj = CopyObj( name, 0 );
    SET_NAME_FUNC(func, namobj);
    CHANGED_BAG(func);

    /* and return                                                          */
    return func;
}


/****************************************************************************
**
*F  InstallGlobalFunction( <oper>, <func> ) . . . . . . . . .  clone function
**
**  There is a problem  with uncompleted functions: if  they are  cloned then
**  only   the orignal and not  the  clone will be  completed.  Therefore the
**  clone must postpone the real cloning.
*/
void InstallGlobalFunction (
    Obj                 oper,
    Obj                 func )
{
    // get the name
    Obj name = NAME_FUNC(oper);

    // clone the function
    if ( SIZE_OBJ(oper) != SIZE_OBJ(func) ) {
        ErrorQuit( "size mismatch of function bags", 0L, 0L );
    }
    memcpy(ADDR_OBJ(oper), CONST_ADDR_OBJ(func), SIZE_OBJ(func));

    SET_NAME_FUNC(oper, ConvImmString(name));
    CHANGED_BAG(oper);
}


/****************************************************************************
**
*F  SaveOperationExtras( <oper> ) . . . additional saving for functions which
**
**  This is called by SaveFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/
void SaveOperationExtras (
    Obj         oper )
{
    const OperBag * header = CONST_OPER(oper);

    SaveSubObj(header->flag1);
    SaveSubObj(header->flag2);
    SaveSubObj(header->flags);
    SaveSubObj(header->setter);
    SaveSubObj(header->tester);
    SaveSubObj(header->enabled);
    for (UInt i = 0; i <= 7; i++)
        SaveSubObj(header->methods[i]);
#ifdef HPCGAP
    // FIXME: We probably don't want to save/restore the cache?
    // (and that would include "normal" GAP, too...)
#else
    for (UInt i = 0; i <= 7; i++)
        SaveSubObj(header->cache[i]);
#endif
}


/****************************************************************************
**
*F  LoadOperationExtras( <oper> ) . .  additional loading for functions which
**                                     are operations
**  This is called by LoadFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/
void LoadOperationExtras (
    Obj         oper )
{
    OperBag * header = OPER(oper);

    header->flag1 = LoadSubObj();
    header->flag2 = LoadSubObj();
    header->flags = LoadSubObj();
    header->setter = LoadSubObj();
    header->tester = LoadSubObj();
    header->enabled = LoadSubObj();
    for (UInt i = 0; i <= 7; i++)
        header->methods[i] = LoadSubObj();
#ifdef HPCGAP
    // FIXME: We probably don't want to save/restore the cache?
    // (and that would include "normal" GAP, too...)
#else
    for (UInt i = 0; i <= 7; i++)
        header->cache[i] = LoadSubObj();
#endif
}


/****************************************************************************
**
**
*F * * * * * * * * * * * * GAP operation functions  * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncNEW_OPERATION( <self>, <name> ) . . . . . . . . . . . . new operation
*/
Obj FuncNEW_OPERATION (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewOperation( <name> )",0L,0L);
    }

    /* make the new operation                                              */
    return NewOperation( name, -1L, (Obj)0, DoOperationXArgs );
}


/****************************************************************************
**
*F  FuncNEW_CONSTRUCTOR( <self>, <name> ) . . . . . . . . . . new constructor
*/
Obj FuncNEW_CONSTRUCTOR (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewConstructor( <name> )",0L,0L);
    }

    /* make the new constructor                                            */
    return NewConstructor( name );
}

Obj FuncIS_CONSTRUCTOR(Obj self, Obj x)
{
    return (IS_FUNC(x) && HDLR_FUNC(x, 1) == DoConstructor1Args) ? True : False;
}

/****************************************************************************
**
*F  FuncNEW_ATTRIBUTE( <self>, <name> ) . . . . . . . . . . . . new attribute
*/
Obj FuncNEW_ATTRIBUTE (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewAttribute( <name> )",0L,0L);
    }

    /* make the new operation                                              */
    return NewAttribute( name, -1L, (Obj)0, DoAttribute );
}
/****************************************************************************
**
*F  FuncOPER_TO_ATTRIBUTE( <self>, oper ) make existing operation into attribute
*/
Obj FuncOPER_TO_ATTRIBUTE (
    Obj                 self,
    Obj                 oper )
{
    /* check the argument                                                  */
  if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("usage: OPER_TO_ATTRIBUTE( <oper> )",0L,0L);
    }

    /* make the new operation                                              */
  ConvertOperationIntoAttribute( oper, (ObjFunc) 0L );
    return (Obj) 0L;
}

/****************************************************************************
**
*F  FuncOPER_TO_MUTABLE_ATTRIBUTE( <self>, oper ) make existing operation into attribute
*/
Obj FuncOPER_TO_MUTABLE_ATTRIBUTE (
    Obj                 self,
    Obj                 oper )
{
    /* check the argument                                                  */
  if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("usage: OPER_TO_MUTABLE_ATTRIBUTE( <oper> )",0L,0L);
    }

    /* make the new operation                                              */
  ConvertOperationIntoAttribute( oper, DoMutableAttribute );
  return (Obj) 0L;
}


/****************************************************************************
**
*F  FuncNEW_MUTABLE_ATTRIBUTE( <self>, <name> ) . . . . new mutable attribute
*/
Obj FuncNEW_MUTABLE_ATTRIBUTE (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewMutableAttribute( <name> )",0L,0L);
    }

    /* make the new operation                                              */
    return NewAttribute( name, -1L, (Obj)0, DoMutableAttribute );
}


/****************************************************************************
**
*F  FuncNEW_PROPERTY( <self>, <name> )  . . . . . . . . . . . .  new property
*/
Obj FuncNEW_PROPERTY (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewProperty( <name> )",0L,0L);
    }

    /* make the new operation                                              */
    return NewProperty( name, -1L, (Obj)0, DoProperty );
}


/****************************************************************************
**
*F  FuncNEW_GLOBAL_FUNCTION( <self>, <name> ) . . . . . . new global function
*/
Obj FuncNEW_GLOBAL_FUNCTION (
    Obj                 self,
    Obj                 name )
{
    Obj                 args;           
    Obj                 list;

    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit( "usage: NewGlobalFunction( <name> )", 0L, 0L );
    }

    /* make the new operation                                              */
    args = MakeImmString("args");
    list = NEW_PLIST( T_PLIST, 1 );
    SET_LEN_PLIST( list, 1 );
    SET_ELM_PLIST( list, 1, args );
    CHANGED_BAG( list );
    return NewGlobalFunction( name, list );
}


/****************************************************************************
**
*F  FuncINSTALL_GLOBAL_FUNCTION( <self>, <oper>, <func> )
*/
static Obj REREADING;

Obj FuncINSTALL_GLOBAL_FUNCTION (
    Obj                 self,
    Obj                 oper,
    Obj                 func )
{
    /* check the arguments                                                 */
    if ( ! IS_FUNC(oper) ) {
        ErrorQuit( "<oper> must be a function (not a %s)",
                   (Int)TNAM_OBJ(oper), 0L );
    }
    if ( (REREADING != True) &&
         (HDLR_FUNC(oper,0) != (ObjFunc)DoUninstalledGlobalFunction) ) {
        ErrorQuit( "operation already installed",
                   0L, 0L );
    }
    if ( ! IS_FUNC(func) ) {
        ErrorQuit( "<func> must be a function (not a %s)",
                   (Int)TNAM_OBJ(func), 0L );
    }
    if ( IS_OPERATION(func) ) {
        ErrorQuit( "<func> must not be an operation", 0L, 0L );
    }

    /* install the new method                                              */
    InstallGlobalFunction( oper, func );
    return 0;
}


/****************************************************************************
**
*F  FuncIS_OPERATION( <self>, <obj> ) . . . . . . . . . is <obj> an operation
*/
static Obj IsOperationFilt;

Obj FuncIS_OPERATION (
    Obj                 self,
    Obj                 obj )
{
    if ( TNUM_OBJ(obj) == T_FUNCTION && IS_OPERATION(obj) ) {
        return True;
    }
    else if ( TNUM_OBJ(obj) < FIRST_EXTERNAL_TNUM ) {
        return False;
    }
    else {
        return DoFilter( self, obj );
    }
}


/****************************************************************************
**
*F  FuncMETHODS_OPERATION( <self>, <oper>, <narg> ) . . . . .  list of method
*/
Obj MethsOper (
    Obj                 oper,
    UInt                i )
{
    Obj                 methods;
    methods = METHS_OPER( oper, i );
    if ( methods == 0 ) {
        methods = NEW_PLIST( T_PLIST, 0 );
        MakeBagReadOnly(methods);
        SET_METHS_OPER(oper, i, methods);
        CHANGED_BAG( oper );
    }
    return methods;
}

Obj FuncMETHODS_OPERATION (
    Obj                 self,
    Obj                 oper,
    Obj                 narg )
{
    Int                 n;
    Obj                 meth;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    if ( !IS_INTOBJ(narg) || INT_INTOBJ(narg) < 0 ) {
        ErrorQuit("<narg> must be a nonnegative integer",0L,0L);
    }
    n = INT_INTOBJ( narg );
    meth = MethsOper( oper, (UInt)n );
#ifdef HPCGAP
    MEMBAR_READ();
#endif
    return meth == 0 ? Fail : meth;
}


/****************************************************************************
**
*F  FuncCHANGED_METHODS_OPERATION( <self>, <oper>, <narg> ) . . . clear cache
*/
Obj FuncCHANGED_METHODS_OPERATION (
    Obj                 self,
    Obj                 oper,
    Obj                 narg )
{
    Obj *               cache;
    Bag                 cacheBag;
    Int                 n;
    Int                 i;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    if ( !IS_INTOBJ(narg) || INT_INTOBJ(narg) < 0 ) {
        ErrorQuit("<narg> must be a nonnegative integer",0L,0L);
    }
#ifdef HPCGAP
    if (!PreThreadCreation) {
        ErrorQuit("Methods may only be changed before thread creation",0L,0L);
    }
#endif
    n = INT_INTOBJ( narg );
    cacheBag = CacheOper( oper, (UInt) n );
    cache = ADDR_OBJ( cacheBag );
    for ( i = 0;  i < SIZE_OBJ(cacheBag) / sizeof(Obj);  i++ ) {
        cache[i] = 0;
    }
    return 0;
}


/****************************************************************************
**
*F  FuncSET_METHODS_OPERATION( <self>, <oper>, <narg>, <list> ) . set methods
*/
Obj FuncSET_METHODS_OPERATION (
    Obj                 self,
    Obj                 oper,
    Obj                 narg,
    Obj                 meths )
{
    Int                 n;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
    }
    if ( !IS_INTOBJ(narg) || INT_INTOBJ(narg) < 0 ) {
        ErrorQuit("<narg> must be a nonnegative integer",0L,0L);
    }
    n = INT_INTOBJ( narg );
#ifdef HPCGAP
    MEMBAR_WRITE();
#endif
    SET_METHS_OPER(oper, n, meths);
    return 0;
}


/****************************************************************************
**
*F  FuncSETTER_FUNCTION( <self>, <name>, <filter> )  default attribute setter
*/
Obj DoSetterFunction (
    Obj                 self,
    Obj                 obj,
    Obj                 value )
{
    Obj                 tmp;
    Obj                 tester;
    Obj                 flags;
    UInt                flag2;
    Obj                 type;
#ifdef HPCGAP
    int                 atomic = 0;
#endif

    switch (TNUM_OBJ(obj)) {
#ifdef HPCGAP
      case T_ACOMOBJ:
        atomic = 1;
#endif
      case T_COMOBJ:
        break;
      default:
        ErrorQuit( "<obj> must be a component object", 0L, 0L );
        return 0L;
    }

    /* if the attribute is already there *do not* chage it                 */
    tmp = ENVI_FUNC(self);
    tester = ELM_PLIST( tmp, 2 );
    flag2  = INT_INTOBJ( FLAG2_FILT(tester) );
    type   = TYPE_OBJ_FEO(obj);
    flags  = FLAGS_TYPE(type);
    if ( SAFE_C_ELM_FLAGS(flags,flag2) ) {
        return 0;
    }

    /* set the value                                                       */
    UInt rnam = (UInt)INT_INTOBJ(ELM_PLIST(tmp,1));
#ifdef HPCGAP
    if (atomic)
      SetARecordField( obj, rnam, CopyObj(value,0) );
    else
#endif
      AssPRec( obj, rnam, CopyObj(value,0) );
    CALL_2ARGS( SET_FILTER_OBJ, obj, tester );
    return 0;
}


Obj FuncSETTER_FUNCTION (
    Obj                 self,
    Obj                 name,
    Obj                 filter )
{
    Obj                 func;
    Obj                 fname;
    Obj                 tmp;

    fname = WRAP_NAME(name, "SetterFunc");
    func = NewFunction( fname, 2, ArglistObjVal, DoSetterFunction );
    tmp = NEW_PLIST_IMM( T_PLIST, 2 );
    SET_LEN_PLIST( tmp, 2 );
    SET_ELM_PLIST( tmp, 1, INTOBJ_INT( RNamObj(name) ) );
    SET_ELM_PLIST( tmp, 2, filter );
    CHANGED_BAG(tmp);
    SET_ENVI_FUNC(func, tmp);
    CHANGED_BAG(func);
    return func;
}


/****************************************************************************
**
*F  FuncGETTER_FUNCTION( <self>, <name> ) . . . . .  default attribute getter
*/
Obj DoGetterFunction (
    Obj                 self,
    Obj                 obj )
{
    switch (TNUM_OBJ(obj)) {
      case T_COMOBJ:
        return ElmPRec( obj, (UInt)INT_INTOBJ(ENVI_FUNC(self)) );
#ifdef HPCGAP
      case T_ACOMOBJ:
        return GetARecordField( obj, (UInt)INT_INTOBJ(ENVI_FUNC(self)) );
#endif
      default:
        ErrorQuit( "<obj> must be a component object", 0L, 0L );
        return 0L;
    }
}


Obj FuncGETTER_FUNCTION (
    Obj                 self,
    Obj                 name )
{
    Obj                 func;
    Obj                 fname;

    fname = WRAP_NAME(name, "GetterFunc");
    func = NewFunction( fname, 1, ArglistObj, DoGetterFunction );
    SET_ENVI_FUNC(func, INTOBJ_INT( RNamObj(name) ));
    return func;
}


/****************************************************************************
**
*F  FuncOPERS_CACHE_INFO( <self> )  . . . . . . .  return cache stats as list
*/
Obj FuncOPERS_CACHE_INFO (
    Obj                        self )
{
    Obj                 list;
    Int                 i;

    list = NEW_PLIST_IMM(T_PLIST, 13);
    SET_LEN_PLIST(list, 13);
#ifdef COUNT_OPERS
    SET_ELM_PLIST(list, 1, INTOBJ_INT(AndFlagsCacheHit));
    SET_ELM_PLIST(list, 2, INTOBJ_INT(AndFlagsCacheMiss));
    SET_ELM_PLIST(list, 3, INTOBJ_INT(AndFlagsCacheLost));
    SET_ELM_PLIST(list, 4, INTOBJ_INT(OperationHit));
    SET_ELM_PLIST(list, 5, INTOBJ_INT(OperationNext));
    SET_ELM_PLIST(list, 6, INTOBJ_INT(OperationMiss));
    SET_ELM_PLIST(list, 7, INTOBJ_INT(IsSubsetFlagsCalls));
    SET_ELM_PLIST(list, 8, INTOBJ_INT(WITH_HIDDEN_IMPS_HIT));
    SET_ELM_PLIST(list, 9, INTOBJ_INT(WITH_HIDDEN_IMPS_MISS));
    SET_ELM_PLIST(list, 10, INTOBJ_INT(WITH_IMPS_FLAGS_HIT));
    SET_ELM_PLIST(list, 11, INTOBJ_INT(WITH_IMPS_FLAGS_MISS));
    
    /* Now we need to convert the 3d matrix of cache hit counts (by
       precedence, location found and number of arguments) into a three
       dimensional GAP matrix (tensor) */
    Obj tensor = NEW_PLIST_IMM(T_PLIST, CACHE_SIZE);
    SET_LEN_PLIST(tensor, CACHE_SIZE);
    for (i = 1; i <= CACHE_SIZE; i++) {
        Obj mat = NEW_PLIST_IMM(T_PLIST, CACHE_SIZE);
        SET_LEN_PLIST(mat, CACHE_SIZE);
        SET_ELM_PLIST(tensor, i, mat);
        CHANGED_BAG(tensor);
        for (Int j = 1; j <= CACHE_SIZE; j++) {
            Obj vec = NEW_PLIST_IMM(T_PLIST, 7);
            SET_LEN_PLIST(vec, 7);
            SET_ELM_PLIST(mat, j, vec);
            CHANGED_BAG(mat);
            for (Int k = 0; k <= 6; k++)
                SET_ELM_PLIST(
                    vec, k + 1,
                    INTOBJ_INT(CacheHitStatistics[i - 1][j - 1][k]));
        }
    }
    SET_ELM_PLIST(list, 12, tensor);
    CHANGED_BAG(list);

    /* and similarly the 2D matrix of cache miss information (by
       precedence and number of arguments) */
    Obj mat = NEW_PLIST_IMM(T_PLIST, CACHE_SIZE + 1);
    SET_LEN_PLIST(mat, CACHE_SIZE + 1);
    for (Int j = 1; j <= CACHE_SIZE + 1; j++) {
        Obj vec = NEW_PLIST_IMM(T_PLIST, 7);
        SET_LEN_PLIST(vec, 7);
        SET_ELM_PLIST(mat, j, vec);
        CHANGED_BAG(mat);
        for (Int k = 0; k <= 6; k++)
            SET_ELM_PLIST(vec, k + 1,
                          INTOBJ_INT(CacheMissStatistics[j - 1][k]));
    }
    SET_ELM_PLIST(list, 13, mat);
    CHANGED_BAG(list);
#else
    for (i = 1; i <= 13; i++)
        SET_ELM_PLIST(list, i, INTOBJ_INT(0));
#endif
    return list;
}


/****************************************************************************
**
*F  FuncCLEAR_CACHE_INFO( <self> )  . . . . . . . . . . . . clear cache stats
*/
Obj FuncCLEAR_CACHE_INFO (
    Obj                        self )
{
#ifdef COUNT_OPERS
    AndFlagsCacheHit = 0;
    AndFlagsCacheMiss = 0;
    AndFlagsCacheLost = 0;
    OperationHit = 0;
    OperationMiss = 0;
    IsSubsetFlagsCalls = 0;
    OperationNext = 0;
    WITH_HIDDEN_IMPS_HIT = 0;
    WITH_HIDDEN_IMPS_MISS = 0;
    WITH_IMPS_FLAGS_HIT = 0;
    WITH_IMPS_FLAGS_MISS = 0;
    memset(CacheHitStatistics, 0, sizeof(CacheHitStatistics));
    memset(CacheMissStatistics, 0, sizeof(CacheMissStatistics));
#endif

    return 0;
}

/****************************************************************************
**
*F  ChangeDoOperations( <oper>, <verb> )  . . .  verbose or silent operations
*/
static ObjFunc TabSilentVerboseOperations[] =
{
    (ObjFunc) DoOperation0Args,   (ObjFunc) DoVerboseOperation0Args,
    (ObjFunc) DoOperation1Args,   (ObjFunc) DoVerboseOperation1Args,
    (ObjFunc) DoOperation2Args,   (ObjFunc) DoVerboseOperation2Args,
    (ObjFunc) DoOperation3Args,   (ObjFunc) DoVerboseOperation3Args,
    (ObjFunc) DoOperation4Args,   (ObjFunc) DoVerboseOperation4Args,
    (ObjFunc) DoOperation5Args,   (ObjFunc) DoVerboseOperation5Args,
    (ObjFunc) DoOperation6Args,   (ObjFunc) DoVerboseOperation6Args,
    (ObjFunc) DoOperationXArgs,   (ObjFunc) DoVerboseOperationXArgs,
    (ObjFunc) DoConstructor0Args, (ObjFunc) DoVerboseConstructor0Args,
    (ObjFunc) DoConstructor1Args, (ObjFunc) DoVerboseConstructor1Args,
    (ObjFunc) DoConstructor2Args, (ObjFunc) DoVerboseConstructor2Args,
    (ObjFunc) DoConstructor3Args, (ObjFunc) DoVerboseConstructor3Args,
    (ObjFunc) DoConstructor4Args, (ObjFunc) DoVerboseConstructor4Args,
    (ObjFunc) DoConstructor5Args, (ObjFunc) DoVerboseConstructor5Args,
    (ObjFunc) DoConstructor6Args, (ObjFunc) DoVerboseConstructor6Args,
    (ObjFunc) DoConstructorXArgs, (ObjFunc) DoVerboseConstructorXArgs,
    (ObjFunc) DoAttribute,        (ObjFunc) DoVerboseAttribute,
    (ObjFunc) DoMutableAttribute, (ObjFunc) DoVerboseMutableAttribute,
    (ObjFunc) DoProperty,         (ObjFunc) DoVerboseProperty,
    0,                          0
};


void ChangeDoOperations (
    Obj                 oper,
    Int                 verb )
{
    Int                 i;
    Int                 j;

    /* catch infix operations                                          */
    if ( oper == EqOper   )  { InstallEqObject(verb);   }
    if ( oper == LtOper   )  { InstallLtObject(verb);   }
    if ( oper == InOper   )  { InstallInObject(verb);   }
    if ( oper == SumOper  )  { InstallSumObject(verb);  }
    if ( oper == DiffOper )  { InstallDiffObject(verb); }
    if ( oper == ProdOper )  { InstallProdObject(verb); }
    if ( oper == QuoOper  )  { InstallQuoObject(verb);  }
    if ( oper == LQuoOper )  { InstallLQuoObject(verb); }
    if ( oper == PowOper  )  { InstallPowObject(verb);  }
    if ( oper == CommOper )  { InstallCommObject(verb); }
    if ( oper == ModOper  )  { InstallModObject(verb);  }

    if ( oper == InvOp  )  { InstallInvObject(verb);  }
    if ( oper == OneOp  )  { InstallOneObject(verb);  }
    if ( oper == AInvOp )  { InstallAinvObject(verb); }
    if ( oper == ZEROOp )  { InstallZeroObject(verb); }

    if ( oper == InvMutOp  )  { InstallInvMutObject(verb);  }
    if ( oper == OneMutOp  )  { InstallOneMutObject(verb);  }
    if ( oper == AdditiveInverseOp )  { InstallAinvMutObject(verb); }
    if ( oper == ZeroOp )  { InstallZeroMutObject(verb); }

    /* be verbose                                                          */
    if ( verb ) {

        /* switch do with do verbose                                       */
        for ( j = 0;  TabSilentVerboseOperations[j];  j += 2 ) {
            for ( i = 0;  i <= 7;  i++ ) {
                if ( HDLR_FUNC(oper,i) == TabSilentVerboseOperations[j] ) {
                    SET_HDLR_FUNC(oper, i, TabSilentVerboseOperations[j+1]);
                }
            }
        }
    }

    /* be silent                                                           */
    else {

        /* switch do verbose with do                                       */
        for ( j = 1;  TabSilentVerboseOperations[j-1];  j += 2 ) {
            for ( i = 0;  i <= 7;  i++ ) {
                if ( HDLR_FUNC(oper,i) == TabSilentVerboseOperations[j] ) {
                    SET_HDLR_FUNC(oper, i, TabSilentVerboseOperations[j-1]);
                }
            }
        }
    }
}


/****************************************************************************
**
*F  FuncTRACE_METHODS( <oper> ) . . . . . . . .  switch tracing of methods on
*/
Obj FuncTRACE_METHODS (
    Obj                 self,
    Obj                 oper )
{
    /* check the argument                                                  */
    if (!IS_OPERATION(oper)) {
        ErrorQuit( "<oper> must be an operation", 0L, 0L );
    }

    /* install trace handler                                               */
    ChangeDoOperations( oper, 1 );

    /* return nothing                                                      */
    return 0;
}


/****************************************************************************
**
*F  FuncUNTRACE_METHODS( <oper> ) . . . . . . . switch tracing of methods off
*/
Obj FuncUNTRACE_METHODS (
    Obj                 self,
    Obj                 oper )
{

    /* check the argument                                                  */
    if (!IS_OPERATION(oper)) {
        ErrorQuit( "<oper> must be an operation", 0L, 0L );
    }

    /* install trace handler                                               */
    ChangeDoOperations( oper, 0 );

    /* return nothing                                                      */
    return 0;
}

/****************************************************************************
**
*F  FuncSET_ATTRIBUTE_STORING( <self>, <attr>, <val> )
**               switch off or on the setter call of an attribute
*/
Obj FuncSET_ATTRIBUTE_STORING (
    Obj                 self,
    Obj                 attr,
    Obj                 val )
{
  SET_ENABLED_ATTR(attr, (val == True) ? 1L : 0L);
  return 0;
}

/****************************************************************************
**
*F  FuncDO_NOTHING_SETTER(<self> , <obj>, <val> )
**
*/
Obj FuncDO_NOTHING_SETTER( Obj self, Obj obj, Obj val)
{
  return 0;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILTER(IS_OPERATION, "obj", &IsOperationFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(AND_FLAGS, 2, "oper1, oper2"),
    GVAR_FUNC(SUB_FLAGS, 2, "oper1, oper2"),
    GVAR_FUNC(HASH_FLAGS, 1, "flags"),
    GVAR_FUNC(IS_EQUAL_FLAGS, 2, "flags1, flags2"),
    GVAR_FUNC(CLEAR_HIDDEN_IMP_CACHE, 1, "flags"),
    GVAR_FUNC(WITH_HIDDEN_IMPS_FLAGS, 1, "flags"),
    GVAR_FUNC(InstallHiddenTrueMethod, 2, "filter, filters"),
    GVAR_FUNC(CLEAR_IMP_CACHE, 0, ""),
    GVAR_FUNC(WITH_IMPS_FLAGS, 1, "flags"),
    GVAR_FUNC(WITH_IMPS_FLAGS_STAT, 0, ""),
    GVAR_FUNC(IS_SUBSET_FLAGS, 2, "flags1, flags2"),
    GVAR_FUNC(TRUES_FLAGS, 1, "flags"),
    GVAR_FUNC(SIZE_FLAGS, 1, "flags"),
    GVAR_FUNC(FLAG1_FILTER, 1, "oper"),
    GVAR_FUNC(SET_FLAG1_FILTER, 2, "oper, flag1"),
    GVAR_FUNC(FLAG2_FILTER, 1, "oper"),
    GVAR_FUNC(SET_FLAG2_FILTER, 2, "oper, flag2"),
    GVAR_FUNC(FLAGS_FILTER, 1, "oper"),
    GVAR_FUNC(SET_FLAGS_FILTER, 2, "oper, flags"),
    GVAR_FUNC(SETTER_FILTER, 1, "oper"),
    GVAR_FUNC(SET_SETTER_FILTER, 2, "oper, other"),
    GVAR_FUNC(TESTER_FILTER, 1, "oper"),
    GVAR_FUNC(SET_TESTER_FILTER, 2, "oper, other"),
    GVAR_FUNC(METHODS_OPERATION, 2, "oper, narg"),
    GVAR_FUNC(SET_METHODS_OPERATION, 3, "oper, narg, meths"),
    GVAR_FUNC(CHANGED_METHODS_OPERATION, 2, "oper, narg"),
    GVAR_FUNC(NEW_FILTER, 1, "name"),
    GVAR_FUNC(NEW_OPERATION, 1, "name"),
    GVAR_FUNC(NEW_CONSTRUCTOR, 1, "name"),
    GVAR_FUNC(NEW_ATTRIBUTE, 1, "name"),
    GVAR_FUNC(NEW_MUTABLE_ATTRIBUTE, 1, "name"),
    GVAR_FUNC(NEW_PROPERTY, 1, "name"),
    GVAR_FUNC(SETTER_FUNCTION, 2, "name, filter"),
    GVAR_FUNC(GETTER_FUNCTION, 1, "name"),
    GVAR_FUNC(NEW_GLOBAL_FUNCTION, 1, "name"),
    GVAR_FUNC(INSTALL_GLOBAL_FUNCTION, 2, "oper, func"),
    GVAR_FUNC(TRACE_METHODS, 1, "oper"),
    GVAR_FUNC(UNTRACE_METHODS, 1, "oper"),
    GVAR_FUNC(OPERS_CACHE_INFO, 0, ""),
    GVAR_FUNC(CLEAR_CACHE_INFO, 0, ""),
    GVAR_FUNC(SET_ATTRIBUTE_STORING, 2, "attr, val"),
    GVAR_FUNC(DO_NOTHING_SETTER, 2, "obj, val"),
    GVAR_FUNC(IS_AND_FILTER, 1, "filter"),
    GVAR_FUNC(IS_CONSTRUCTOR, 1, "x"),
#if !defined(HPCGAP)
    GVAR_FUNC(COMPACT_TYPE_IDS, 0, ""),
#endif
    GVAR_FUNC(OPER_TO_ATTRIBUTE, 1, "oper"),
    GVAR_FUNC(OPER_TO_MUTABLE_ATTRIBUTE, 1, "oper"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{

    CountFlags = 0;

    InitGlobalBag( &StringFilterSetter, "src/opers.c:StringFilterSetter" );
    InitGlobalBag( &ArglistObj,         "src/opers.c:ArglistObj"         );
    InitGlobalBag( &ArglistObjVal,      "src/opers.c:ArglistObjVal"      );

    /* share between uncompleted functions                                 */
    StringFilterSetter = MakeImmString("<<filter-setter>>");

    ArglistObj = NEW_PLIST_IMM( T_PLIST, 1 );
    SET_LEN_PLIST( ArglistObj, 1 );
    SET_ELM_PLIST( ArglistObj, 1, MakeImmString("obj") );
    CHANGED_BAG( ArglistObj );

    ArglistObjVal = NEW_PLIST_IMM( T_PLIST, 2 );
    SET_LEN_PLIST( ArglistObjVal, 2 );
    SET_ELM_PLIST( ArglistObjVal, 1, MakeImmString("obj") );
    CHANGED_BAG( ArglistObjVal );
    SET_ELM_PLIST( ArglistObjVal, 2, MakeImmString("val") );
    CHANGED_BAG( ArglistObjVal );


    // Declare the handlers used in various places. Some of the most common
    // ones are abbreviated to save space in saved workspace.
    InitHandlerFunc( DoFilter,                  "df"                                    );
    InitHandlerFunc( DoSetFilter,               "dsf"                                   );
    InitHandlerFunc( DoAndFilter,               "daf"                                   );
    InitHandlerFunc( DoSetAndFilter,            "dsaf"                                  );
    InitHandlerFunc( DoReturnTrueFilter,        "src/opers.c:DoReturnTrueFilter"        );
    InitHandlerFunc( DoSetReturnTrueFilter,     "src/opers.c:DoSetReturnTrueFilter"     );
    
    InitHandlerFunc( DoAttribute,               "da"                                    );
    InitHandlerFunc( DoSetAttribute,            "dsa"                                   );
    InitHandlerFunc( DoTestAttribute,           "src/opers.c:DoTestAttribute"           );
    InitHandlerFunc( DoVerboseAttribute,        "src/opers.c:DoVerboseAttribute"        );
    InitHandlerFunc( DoMutableAttribute,        "src/opers.c:DoMutableAttribute"        );
    InitHandlerFunc( DoVerboseMutableAttribute, "src/opers.c:DoVerboseMutableAttribute" );

    InitHandlerFunc( DoProperty,                "src/opers.c:DoProperty"                );
    InitHandlerFunc( DoSetProperty,             "src/opers.c:DoSetProperty"             );
    InitHandlerFunc( DoVerboseProperty,         "src/opers.c:DoVerboseProperty"         );

    InitHandlerFunc( DoSetterFunction,          "dtf"                                   );
    InitHandlerFunc( DoGetterFunction,          "dgf"                                   );
    
    InitHandlerFunc( DoOperation0Args,          "o0"                                    );
    InitHandlerFunc( DoOperation1Args,          "o1"                                    );
    InitHandlerFunc( DoOperation2Args,          "o2"                                    );
    InitHandlerFunc( DoOperation3Args,          "o3"                                    );
    InitHandlerFunc( DoOperation4Args,          "o4"                                    );
    InitHandlerFunc( DoOperation5Args,          "o5"                                    );
    InitHandlerFunc( DoOperation6Args,          "o6"                                    );
    InitHandlerFunc( DoOperationXArgs,          "o7"                                    );

    InitHandlerFunc( DoVerboseOperation0Args,   "src/opers.c:DoVerboseOperation0Args"   );
    InitHandlerFunc( DoVerboseOperation1Args,   "src/opers.c:DoVerboseOperation1Args"   );
    InitHandlerFunc( DoVerboseOperation2Args,   "src/opers.c:DoVerboseOperation2Args"   );
    InitHandlerFunc( DoVerboseOperation3Args,   "src/opers.c:DoVerboseOperation3Args"   );
    InitHandlerFunc( DoVerboseOperation4Args,   "src/opers.c:DoVerboseOperation4Args"   );
    InitHandlerFunc( DoVerboseOperation5Args,   "src/opers.c:DoVerboseOperation5Args"   );
    InitHandlerFunc( DoVerboseOperation6Args,   "src/opers.c:DoVerboseOperation6Args"   );
    InitHandlerFunc( DoVerboseOperationXArgs,   "src/opers.c:DoVerboseOperationXArgs"   );
    
    InitHandlerFunc( DoConstructor0Args,        "src/opers.c:DoConstructor0Args"        );
    InitHandlerFunc( DoConstructor1Args,        "src/opers.c:DoConstructor1Args"        );
    InitHandlerFunc( DoConstructor2Args,        "src/opers.c:DoConstructor2Args"        );
    InitHandlerFunc( DoConstructor3Args,        "src/opers.c:DoConstructor3Args"        );
    InitHandlerFunc( DoConstructor4Args,        "src/opers.c:DoConstructor4Args"        );
    InitHandlerFunc( DoConstructor5Args,        "src/opers.c:DoConstructor5Args"        );
    InitHandlerFunc( DoConstructor6Args,        "src/opers.c:DoConstructor6Args"        );
    InitHandlerFunc( DoConstructorXArgs,        "src/opers.c:DoConstructorXArgs"        );

    InitHandlerFunc( DoVerboseConstructor0Args, "src/opers.c:DoVerboseConstructor0Args" );
    InitHandlerFunc( DoVerboseConstructor1Args, "src/opers.c:DoVerboseConstructor1Args" );
    InitHandlerFunc( DoVerboseConstructor2Args, "src/opers.c:DoVerboseConstructor2Args" );
    InitHandlerFunc( DoVerboseConstructor3Args, "src/opers.c:DoVerboseConstructor3Args" );
    InitHandlerFunc( DoVerboseConstructor4Args, "src/opers.c:DoVerboseConstructor4Args" );
    InitHandlerFunc( DoVerboseConstructor5Args, "src/opers.c:DoVerboseConstructor5Args" );
    InitHandlerFunc( DoVerboseConstructor6Args, "src/opers.c:DoVerboseConstructor6Args" );
    InitHandlerFunc( DoVerboseConstructorXArgs, "src/opers.c:DoVerboseConstructorXArgs" );

    InitHandlerFunc( DoUninstalledGlobalFunction, "src/opers.c:DoUninstalledGlobalFunction" );

    /* install the type function                                           */
    ImportGVarFromLibrary( "TYPE_FLAGS", &TYPE_FLAGS );
    TypeObjFuncs[ T_FLAGS ] = TypeFlags;

    
    /* set up hidden implications                                          */
    InitGlobalBag( &WITH_HIDDEN_IMPS_FLAGS_CACHE, "src/opers.c:WITH_HIDDEN_IMPS_FLAGS_CACHE");
    InitGlobalBag( &HIDDEN_IMPS, "src/opers.c:HIDDEN_IMPS");
    
    /* set up implications                                                 */
    InitGlobalBag( &WITH_IMPS_FLAGS_CACHE, "src/opers.c:WITH_IMPS_FLAGS_CACHE");
    InitGlobalBag( &IMPLICATIONS_SIMPLE, "src/opers.c:IMPLICATIONS_SIMPLE");
    InitGlobalBag( &IMPLICATIONS_COMPOSED, "src/opers.c:IMPLICATIONS_COMPOSED");
    
    /* make the 'true' operation                                           */  
    InitGlobalBag( &ReturnTrueFilter, "src/opers.c:ReturnTrueFilter" );

    /* install the (function) copies of global variables                   */
    /*for the inside-out (kernel to library) interface                    */
    InitGlobalBag( &TRY_NEXT_METHOD, "src/opers.c:TRY_NEXT_METHOD" );

    ImportFuncFromLibrary("ReturnTrue", &ReturnTrue);
    ImportFuncFromLibrary("VMETHOD_PRINT_INFO", &VMETHOD_PRINT_INFO);
    ImportFuncFromLibrary("NEXT_VMETHOD_PRINT_INFO", &NEXT_VMETHOD_PRINT_INFO);

    ImportFuncFromLibrary( "SET_FILTER_OBJ",   &SET_FILTER_OBJ );
    ImportFuncFromLibrary( "RESET_FILTER_OBJ", &RESET_FILTER_OBJ );

    ImportFuncFromLibrary("HANDLE_METHOD_NOT_FOUND",
                          &HANDLE_METHOD_NOT_FOUND);

#if !defined(HPCGAP)
    ImportGVarFromLibrary( "IsType", &IsType );
    ImportFuncFromLibrary( "FLUSH_ALL_METHOD_CACHES", &FLUSH_ALL_METHOD_CACHES );
#endif

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* install the marking function                                        */
    InfoBags[T_FLAGS].name = "flags list";
    InitMarkFuncBags( T_FLAGS, MarkFourSubBags );

    /* install the printing function                                       */
    PrintObjFuncs[ T_FLAGS ] = PrintFlags;

    /* and the saving function */
    SaveObjFuncs[ T_FLAGS ] = SaveFlags;
    LoadObjFuncs[ T_FLAGS ] = LoadFlags;

    /* flags are public objects by default */
    MakeBagTypePublic(T_FLAGS);

    /* import copy of REREADING */
    ImportGVarFromLibrary( "REREADING", &REREADING );


#ifdef HPCGAP
    /* initialize cache mutex */
    pthread_mutex_init(&CacheLock, NULL);
#endif

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  postRestore( <module> ) . . . . . . .  initialise library data structures
**
*/


static Int postRestore (
    StructInitInfo *    module )
{

  CountFlags = LEN_LIST(ValGVar(GVarName("FILTERS")));
  return 0;
}

/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    // HACK: move this here, instead of InitKernel, to avoid ariths.c overwriting it
    EqFuncs[T_FLAGS][T_FLAGS] = EqFlags;

    ExportAsConstantGVar(BASE_SIZE_METHODS_OPER_ENTRY);

    HIDDEN_IMPS = NEW_PLIST(T_PLIST, 0);
    SET_LEN_PLIST(HIDDEN_IMPS, 0);
    WITH_HIDDEN_IMPS_FLAGS_CACHE = NEW_PLIST(T_PLIST, HIDDEN_IMPS_CACHE_LENGTH * 2);
    SET_LEN_PLIST(WITH_HIDDEN_IMPS_FLAGS_CACHE, HIDDEN_IMPS_CACHE_LENGTH * 2);

#ifdef HPCGAP
    REGION(HIDDEN_IMPS) = NewRegion();
    REGION(WITH_HIDDEN_IMPS_FLAGS_CACHE) = REGION(HIDDEN_IMPS);
#endif

    IMPLICATIONS_SIMPLE = NEW_PLIST(T_PLIST, 0);
    SET_LEN_PLIST(IMPLICATIONS_SIMPLE, 0);
    IMPLICATIONS_COMPOSED = NEW_PLIST(T_PLIST, 0);
    SET_LEN_PLIST(IMPLICATIONS_COMPOSED, 0);
    WITH_IMPS_FLAGS_CACHE = NEW_PLIST(T_PLIST, IMPS_CACHE_LENGTH * 2);
    SET_LEN_PLIST(WITH_IMPS_FLAGS_CACHE, IMPS_CACHE_LENGTH * 2);
    AssGVar(GVarName("IMPLICATIONS_SIMPLE"), IMPLICATIONS_SIMPLE);
    AssGVar(GVarName("IMPLICATIONS_COMPOSED"), IMPLICATIONS_COMPOSED);

#ifdef HPCGAP
    REGION(IMPLICATIONS_SIMPLE) = NewRegion();
    REGION(IMPLICATIONS_COMPOSED) = REGION(IMPLICATIONS_SIMPLE);
    REGION(WITH_IMPS_FLAGS_CACHE) = REGION(IMPLICATIONS_SIMPLE);
#endif

    /* make the 'true' operation                                           */  
    ReturnTrueFilter = NewReturnTrueFilter();
    AssReadOnlyGVar( GVarName( "IS_OBJECT" ), ReturnTrueFilter );

    /* install the (function) copies of global variables                   */
    /* for the inside-out (kernel to library) interface                    */
    TRY_NEXT_METHOD = MakeImmString("TRY_NEXT_METHOD");
    AssReadOnlyGVar( GVarName("TRY_NEXT_METHOD"), TRY_NEXT_METHOD );

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}

static void InitModuleState(ModuleStateOffset offset)
{
#ifdef HPCGAP
    STATE(MethodCache) = NEW_PLIST(T_PLIST, 1);
    STATE(MethodCacheItems) = ADDR_OBJ(STATE(MethodCache));
    STATE(MethodCacheSize) = 1;
    SET_LEN_PLIST(STATE(MethodCache), 1);
#endif
}

/****************************************************************************
**
*F  InitInfoOpers() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "opers",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .postRestore = postRestore
};

StructInitInfo * InitInfoOpers ( void )
{
    RegisterModuleState(0, InitModuleState, 0);
    return &module;
}
