/****************************************************************************
**
*W  opers.c                     GAP source                       Frank Celler
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions of the  filters, operations, attributes,
**  and properties package.
*/
char * Revision_opers_c =
   "@(#)$Id$";


#include        <assert.h>

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TNUM_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* AssGVar, GVarName               */

#include        "calls.h"               /* generic call mechanism          */

#define INCLUDE_DECLARATION_PART
#include        "opers.h"               /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "ariths.h"              /* arithmetic operations           */
#include        "lists.h"               /* generic list package            */

#include        "bool.h"                /* True, False                     */

#include        "plist.h"               /* NEW_PLIST, SET_LEN_PLIST, SET...*/
#include        "blister.h"             /* SIZE_PLEN_BLIST, SET_LEN_BLIST  */
#include        "string.h"              /* NEW_STRING, CSTR_STRING         */

#include        "records.h"             /* ASS_REC, ELM_REC                */
#include        "precord.h"             /* AssPRec, ElmPRec                */

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**

*V  TRY_NEXT_METHOD
*/
Obj TRY_NEXT_METHOD;


/****************************************************************************
**

*F  IS_OPERATION( <func> )  . . . . . . . . .  check if function is operation
**
#define IS_OPERATION(func) \
    (TNUM_OBJ(func) == T_FUNCTION && SIZE_OBJ(func) == SIZE_OPER )
*/


Obj             CacheOper (
    Obj                 oper,
    UInt                i )
{
    Obj                 cache;
    cache = CACHE_OPER( oper, i );
    if ( cache == 0 ) {
        cache = NEW_PLIST( T_PLIST, (i < 7 ? 4 * (i+1) : 4 * (1+1)) );
        CACHE_OPER( oper, i ) = cache;
        CHANGED_BAG( oper );
    }
    return cache;
}

Obj             MethsOper (
    Obj                 oper,
    UInt                i )
{
    Obj                 methods;
    methods = METHS_OPER( oper, i );
    if ( methods == 0 ) {
        methods = NEW_PLIST( T_PLIST, 0 );
        METHS_OPER( oper, i ) = methods;
        CHANGED_BAG( oper );
    }
    return methods;
}


/****************************************************************************
**

*F  SIZE_PLEN_FLAGS( <plen> ) . .  size for a flags list with physical length
*/
#define SIZE_PLEN_FLAGS(plen) \
  (3*sizeof(Obj)+((plen)+BIPEB-1)/BIPEB*sizeof(Obj))



/****************************************************************************
**
*F  DATA_FLAGS( <flags> ) . . . . . . . . . . . . . data area of a flags list
*/
#define DATA_FLAGS(flags)               ((UInt*)(ADDR_OBJ(flags)+3))


/****************************************************************************
**
*F  TRUES_FLAGS( <flags> )  . . . . . . . . . . . . . . trues of <flags> or 0
*/
#define TRUES_FLAGS(flags)              (ADDR_OBJ(flags)[0])


/****************************************************************************
**
*F  SET_TRUES_FLAGS( <flags>, <trues> ) . . . . . . . . . . . . . . set trues
*/
#define SET_TRUES_FLAGS(flags,trues)    (ADDR_OBJ(flags)[0] = trues)


/****************************************************************************
**
*F  HASH_FLAGS( <flags> ) . . . . . . . . . . . .  hash value of <flags> or 0
*/
#define HASH_FLAGS(flags)               (ADDR_OBJ(flags)[1])


/****************************************************************************
**
*F  SET_HASH_FLAGS( <flags>, <hash> ) . . . . . . . . . . . . . . .  set hash
*/
#define SET_HASH_FLAGS(flags,hash)      (ADDR_OBJ(flags)[1] = hash)


/****************************************************************************
**
*F  LEN_FLAGS( <flags> )  . . . . . . . . . . . . . .  length of a flags list
*/
#define LEN_FLAGS(list)                 (INT_INTOBJ(ADDR_OBJ(list)[2]))


/****************************************************************************
**
*F  SET_LEN_FLAGS( <flags>, <len> ) . . . . .  set the length of a flags list
*/
#define SET_LEN_FLAGS(flags,len)        (ADDR_OBJ(flags)[2]=INTOBJ_INT(len))


/****************************************************************************
**
*F  NRB_FLAGS( <flags> )  . . . . . . . numberof basic blocks of a flags lits
*/
#define NRB_FLAGS(flags)                ((LEN_FLAGS(flags)+BIPEB-1)/BIPEB)


/****************************************************************************
**
*F  ELM_FLAGS( <flags>, <pos> ) . . . . . . . . . . . element of a flags list
*/
#define ELM_FLAGS(flags,pos) \
  (((UInt4*)DATA_FLAGS(flags))[((pos)-1)/BIPEB]&(1UL<<((pos)-1)%BIPEB) ? \
  True : False)


/****************************************************************************
**
*F  SET_ELM_FLAGS( <list>, <pos>, <val> ) . .  set an element of a flags list
*/
#define SET_ELM_FLAGS(flags,pos,val)  \
  ((val) == True ? \
   (((UInt4*)DATA_FLAGS(flags))[((pos)-1)/BIPEB]|=(1UL<<((pos)-1)%BIPEB)) :\
   (((UInt4*)DATA_FLAGS(flags))[((pos)-1)/BIPEB]&=~(1UL<<((pos)-1)%BIPEB)))


/****************************************************************************
**

*F  PrintFlags( <flags> )
*/
void            PrintFlags (
    Obj                 flags )
{
    Pr( "<flag list>", 0L, 0L );
}


/****************************************************************************
**
*F  TypeFlags( <flags> )  . . . . . . . . . . . . . . .  kind of a flags list
*/
Obj TYPE_FLAGS;

Obj TypeFlags (
    Obj                 flags )
{
    return TYPE_FLAGS;
}


/****************************************************************************
**

*F  FuncLEN_FLAGS( <self>, <flags> )
**
*/
Obj FuncLEN_FLAGS (
    Obj                 self,
    Obj                 flags )
{
    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
        flags = ErrorReturnObj(
            "<flags> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags)].name), 0L,
            "you can return a list for <flags>" );
    }

    return INTOBJ_INT( LEN_FLAGS(flags) );
}


/****************************************************************************
**
*F  FuncELM_FLAGS( <self>, <flags>, <pos> ) 
*/
Obj FuncELM_FLAGS (
    Obj                 self,
    Obj                 flags,
    Obj                 pos )
{
    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
        flags = ErrorReturnObj(
            "<flags> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags)].name), 0L,
            "you can return a list for <flags>" );
    }

    /* select and return the element                                       */
    return ELM_FLAGS( flags, INT_INTOBJ(pos) );
}


/****************************************************************************
**
*F  FuncHASH_FLAGS( <self>, <flags> )
*/
#define HASH_FLAGS_SIZE 67108879L

Obj FuncHASH_FLAGS (
    Obj                 self,
    Obj                 flags )
{
    Int                 hash;
    Int                 x;
    Int                 len;
    UInt *              ptr;
    Int                 i;

    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
            flags = ErrorReturnObj(
            "<flags> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags)].name), 0L,
            "you can return a list for <flags>" );
    }
    if ( HASH_FLAGS(flags) != 0 ) {
        return HASH_FLAGS(flags);
    }

    /* do the real work                                                    */
    len = NRB_FLAGS(flags);
    ptr = DATA_FLAGS(flags);
    hash = 0;
    x    = 1;
    for ( i = 1; i <= len; i++ ) {
        hash = (hash + (*ptr % HASH_FLAGS_SIZE) * x) % HASH_FLAGS_SIZE;
        x    = ((8*sizeof(UInt)-1) * x) % HASH_FLAGS_SIZE;
        ptr++;
    }
    SET_HASH_FLAGS( flags, INTOBJ_INT(hash+1) );
    CHANGED_BAG(flags);
    return HASH_FLAGS(flags);
}


/****************************************************************************
**
*F  FuncIS_EQUAL_FLAGS( <self>, <flags1>, <flags2> )
*/
Obj FuncIS_EQUAL_FLAGS (
    Obj                 self,
    Obj                 flags1,
    Obj                 flags2 )
{
    Int                 len1;
    Int                 len2;
    UInt  *             ptr1;
    UInt  *             ptr2;
    Int                 i;

    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags1) != T_FLAGS ) {
        flags1 = ErrorReturnObj(
            "<flags1> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags1)].name), 0L,
            "you can return a list for <flags1>" );
    }
    while ( TNUM_OBJ(flags2) != T_FLAGS ) {
        flags2 = ErrorReturnObj(
            "<flags2> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags2)].name), 0L,
            "you can return a list for <flags2>" );
    }
    if ( flags1 == flags2 ) {
        return True;
    }

    /* do the real work                                                    */
    len1 = NRB_FLAGS(flags1);
    len2 = NRB_FLAGS(flags2);
    ptr1 = DATA_FLAGS(flags1);
    ptr2 = DATA_FLAGS(flags2);
    if ( len1 <= len2 ) {
        for ( i = 1; i <= len1; i++ ) {
            if ( *ptr1 != *ptr2 )
                return False;
            ptr1++;  ptr2++;
        }
        for ( ; i <= len2; i++ ) {
            if ( 0 != *ptr2 )
                return False;
            ptr2++;
        }
    }
    else {
        for ( i = 1; i <= len2; i++ ) {
            if ( *ptr1 != *ptr2 )
                return False;
            ptr1++;  ptr2++;
        }
        for ( ; i <= len1; i++ ) {
            if ( *ptr1 != 0 )
                return False;
            ptr1++;
        }
    }
    return True;
}


/****************************************************************************
**
*F  FuncAND_FLAGS( <self>, <flags1>, <flags2> )
*/
#define AND_FLAGS_HASH_SIZE             39733UL

#ifdef AND_FLAGS_HASH_SIZE
static Obj AndFlagsCache;
#endif
Int AndFlagsCacheHit;
Int AndFlagsCacheMiss;
Int AndFlagsCacheLost;

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
    UInt                hash;
    UInt                hash2;
    static UInt         count;
#endif

    /* check the cache                                                     */
#ifdef AND_FLAGS_HASH_SIZE
    hash = (31*INT_INTOBJ(flags1)+INT_INTOBJ(flags2)) % AND_FLAGS_HASH_SIZE;
    for ( i = 0;  i < 6;  i++ ) {
        hash2 = 3 * ( (hash+31*i) % AND_FLAGS_HASH_SIZE ) + 1;
        if ( ELM_PLIST(AndFlagsCache,hash2)   == flags1
          && ELM_PLIST(AndFlagsCache,hash2+1) == flags2 )
        {
#ifdef COUNT_OPERS
            AndFlagsCacheHit++;
#endif
            return ELM_PLIST(AndFlagsCache,hash2+2);
        }
        if ( ELM_PLIST(AndFlagsCache,hash2) == INTOBJ_INT(0) ) {
            break;
        }
    }
#ifdef COUNT_OPERS
    AndFlagsCacheMiss++;
#endif
    if ( i == 6 ) {
        count = (count+1) % 6;
        hash2 = 3 * ( (hash+31*count) % AND_FLAGS_HASH_SIZE ) + 1;
#ifdef COUNT_OPERS
        AndFlagsCacheLost++;
#endif
    }
#endif

    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags1) != T_FLAGS ) {
        flags1 = ErrorReturnObj(
            "<flags1> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags1)].name), 0L,
            "you can return a list for <flags1>" );
    }
    while ( TNUM_OBJ(flags2) != T_FLAGS ) {
        flags2 = ErrorReturnObj(
            "<flags2> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags2)].name), 0L,
            "you can return a list for <flags2>" );
    }

    /* do the real work                                                    */
    len1   = LEN_FLAGS(flags1);
    size1  = NRB_FLAGS(flags1);
    len2   = LEN_FLAGS(flags2);
    size2  = NRB_FLAGS(flags2);
    if ( len2 == 0 ) {
        return flags1;
    }
    if ( len1 < len2 ) {
        flags = NewBag( T_FLAGS, SIZE_OBJ(flags2) );
        SET_LEN_FLAGS( flags, len2 );
        ptr1 = DATA_FLAGS(flags1);
        ptr2 = DATA_FLAGS(flags2);
        ptr  = DATA_FLAGS(flags);
        for ( i = 1; i <= size1; i++ )
            *ptr++ = *ptr1++ | *ptr2++;
        for (      ; i <= size2; i++ )
            *ptr++ =           *ptr2++;
    }
    else {
        flags = NewBag( T_FLAGS, SIZE_OBJ(flags1) );
        SET_LEN_FLAGS( flags, len1 );
        ptr1 = DATA_FLAGS(flags1);
        ptr2 = DATA_FLAGS(flags2);
        ptr  = DATA_FLAGS(flags);
        for ( i = 1; i <= size2; i++ )
            *ptr++ = *ptr1++ | *ptr2++;
        for (      ; i <= size1; i++ )
            *ptr++ = *ptr1++;
    }        
#ifdef AND_FLAGS_HASH_SIZE
    SET_ELM_PLIST( AndFlagsCache, hash2,   flags1 );
    SET_ELM_PLIST( AndFlagsCache, hash2+1, flags2 );
    SET_ELM_PLIST( AndFlagsCache, hash2+2, flags  );
    CHANGED_BAG(AndFlagsCache);
#endif

    return flags;
}


/****************************************************************************
**
*F  FuncSUB_FLAGS( <self>, <flags1>, <flags2> )
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
        flags1 = ErrorReturnObj(
            "<flags1> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags1)].name), 0L,
            "you can return a list for <flags1>" );
    }
    while ( TNUM_OBJ(flags2) != T_FLAGS ) {
        flags2 = ErrorReturnObj(
            "<flags2> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags2)].name), 0L,
            "you can return a list for <flags2>" );
    }

    /* do the real work                                                    */
    len1   = LEN_FLAGS(flags1);
    size1  = NRB_FLAGS(flags1);
    len2   = LEN_FLAGS(flags2);
    size2  = NRB_FLAGS(flags2);
    if ( len1 < len2 ) {
        flags = NewBag( T_FLAGS, SIZE_OBJ(flags1) );
        SET_LEN_FLAGS( flags, len1 );
        ptr1 = DATA_FLAGS(flags1);
        ptr2 = DATA_FLAGS(flags2);
        ptr  = DATA_FLAGS(flags);
        for ( i = 1; i <= size1; i++ )
            *ptr++ = *ptr1++ & ~ *ptr2++;
    }
    else {
        flags = NewBag( T_FLAGS, SIZE_OBJ(flags1) );
        SET_LEN_FLAGS( flags, len1 );
        ptr1 = DATA_FLAGS(flags1);
        ptr2 = DATA_FLAGS(flags2);
        ptr  = DATA_FLAGS(flags);
        for ( i = 1; i <= size2; i++ )
            *ptr++ = *ptr1++ & ~ *ptr2++;
        for (      ; i <= size1; i++ )
            *ptr++ = *ptr1++;
    }        

    return flags;
}


/****************************************************************************
**
*F  FuncTRUES_FLAGS( <self>, <flags> )
**
**  see 'FuncPositionsTruesBlist'
*/
Obj FuncTRUES_FLAGS (
    Obj                 self,
    Obj                 flags )
{
    Obj                 sub;            /* handle of the result            */
    Int                 len;            /* logical length of the list      */
    UInt4 *             ptr;            /* pointer to flags                */
    UInt                nrb;            /* number of blocks in flags       */
    UInt4               m;              /* number of bits in a block       */
    UInt                n;              /* number of bits in flags         */
    UInt                nn;
    UInt                i;              /* loop variable                   */

    /* get and check the first argument                                    */
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
        flags = ErrorReturnObj(
            "<flags> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags)].name), 0L,
            "you can return a list for <flags>" );
    }
    if ( TRUES_FLAGS(flags) != 0 ) {
        return TRUES_FLAGS(flags);
    }

    /* compute the number of 'true'-s just as in 'FuncSizeBlist'            */
    nrb = NRB_FLAGS(flags);
    ptr = (UInt4*)DATA_FLAGS(flags);
    n = 0;
    for ( i = 1; i <= nrb; i++ ) {
        m = *ptr++;
        m = (m & 0x55555555) + ((m >> 1) & 0x55555555);
        m = (m & 0x33333333) + ((m >> 2) & 0x33333333);
        m = (m + (m >>  4)) & 0x0f0f0f0f;
        m = (m + (m >>  8));
        m = (m + (m >> 16)) & 0x000000ff;
        n += m;
    }

    /* make the sublist (we now know its size exactely)                    */
    sub = NEW_PLIST( IMMUTABLE_TNUM(T_PLIST), n );
    SET_LEN_PLIST( sub, n );

    /* loop over the boolean list and stuff elements into <sub>            */
    len = LEN_FLAGS( flags );
    nn  = 1;
    for ( i = 1; nn <= n && i <= len;  i++ ) {
        if ( ELM_FLAGS( flags, i ) == True ) {
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
*F  FuncIS_SUBSET_FLAGS( <self>, <flags1>, <flags2> )
*/
Int IsSubsetFlagsCalls;
Int IsSubsetFlagsCalls1;
Int IsSubsetFlagsCalls2;

Obj FuncIS_SUBSET_FLAGS (
    Obj                 self,
    Obj                 flags1,
    Obj                 flags2 )
{
    Int                 len1;
    Int                 len2;
    UInt *              ptr1;
    UInt *              ptr2;
    Int                 i;
    Obj                 trues;

    /* do some trivial checks                                              */
    while ( TNUM_OBJ(flags1) != T_FLAGS ) {
        flags1 = ErrorReturnObj(
            "<flags1> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags1)].name), 0L,
            "you can return a list for <flags1>" );
    }
    while ( TNUM_OBJ(flags2) != T_FLAGS ) {
        flags2 = ErrorReturnObj(
            "<flags2> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags2)].name), 0L,
            "you can return a list for <flags2>" );
    }
    if ( flags1 == flags2 ) {
        return True;
    }

    /* do the real work                                                    */
#ifdef COUNT_OPERS
    IsSubsetFlagsCalls++;
#endif

    /* first check the trues                                               */
    trues = TRUES_FLAGS(flags2);
    if ( trues != 0 ) {
        len2 = LEN_PLIST(trues);
        if ( TRUES_FLAGS(flags1) != 0 ) {
            if ( LEN_PLIST(TRUES_FLAGS(flags1)) < len2 ) {
#ifdef COUNT_OPERS
                IsSubsetFlagsCalls1++;
#endif
                return False;
            }
        }
        if ( len2 < 3 ) {
#ifdef COUNT_OPERS
            IsSubsetFlagsCalls2++;
#endif
            if ( LEN_FLAGS(flags1) < INT_INTOBJ(ELM_PLIST(trues,len2)) ) {
                return False;
            }
            for ( i = len2;  0 < i;  i-- ) {
               if (ELM_FLAGS(flags1,INT_INTOBJ(ELM_PLIST(trues,i)))==False) {
                   return False;
               }
            }
            return True;
        }
    }

    /* compare the bit lists                                               */
    len1 = NRB_FLAGS(flags1);
    len2 = NRB_FLAGS(flags2);
    ptr1 = DATA_FLAGS(flags1);
    ptr2 = DATA_FLAGS(flags2);
    if ( len1 <= len2 ) {
        for ( i = 1; i <= len1; i++ ) {
            if ( (*ptr1 & *ptr2) != *ptr2 ) {
                return False;
            }
            ptr1++;  ptr2++;
        }
        for ( ; i <= len2; i++ ) {
            if ( 0 != *ptr2 ) {
                return False;
            }
            ptr2++;
        }
    }
    else {
        for ( i = 1; i <= len2; i++ ) {
            if ( (*ptr1 & *ptr2) != *ptr2 ) {
                return False;
            }
            ptr1++;  ptr2++;
        }
    }
    return True;
}


/****************************************************************************
**
*F  FuncSIZE_FLAGS( <self>, <flags> )
**
**  see 'FuncSIZE_FLAGS'
*/
Obj FuncSIZE_FLAGS (
    Obj                 self,
    Obj                 flags )
{
    UInt4 *             ptr;            /* pointer to flags                */
    UInt                nrb;            /* number of blocks in flags       */
    UInt4               m;              /* number of bits in a block       */
    UInt                n;              /* number of bits in flags         */
    UInt                i;              /* loop variable                   */

    /* get and check the first argument                                    */
    while ( TNUM_OBJ(flags) != T_FLAGS ) {
        flags = ErrorReturnObj(
            "<flags> must be a flags list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(flags)].name), 0L,
            "you can return a list for <flags>" );
    }

    /* get the number of blocks and a pointer                              */
    nrb = NRB_FLAGS(flags);
    ptr = DATA_FLAGS(flags);

    /* loop over the blocks, adding the number of bits of each one         */
    n = 0;
    for ( i = 1; i <= nrb; i++ ) {
        m = *ptr++;
        m = (m & 0x55555555) + ((m >> 1) & 0x55555555);
        m = (m & 0x33333333) + ((m >> 2) & 0x33333333);
        m = (m + (m >>  4)) & 0x0f0f0f0f;
        m = (m + (m >>  8));
        m = (m + (m >> 16)) & 0x000000ff;
        n += m;
    }

    /* return the number of bits                                           */
    return INTOBJ_INT( n );
}


/****************************************************************************
**

*F  SetterFilter( <oper> )  . . . . . . . . . . . . . . .  setter of a filter
*/
extern Obj SetterAndFilter (
            Obj                 oper );

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
*F  TesterFilter( <oper> )  . . . . . . . . . . . . . . .  tester of a filter
*/
extern Obj TesterAndFilter (
            Obj                 oper );
            
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
*V  CountFlags  . . . . . . . . . . . . . . . . . . . . next free flag number
*/
Int CountFlags;


/****************************************************************************
**
*F  NewFilter( <name> )  . . . . . . . . . . . . . . . . .  make a new filter
*/
Obj DoTestFilter (
    Obj                 self,
    Obj                 obj )
{
    return True;
}

extern  Obj             ReturnTrueFilter;


Obj NewTesterFilter (
    Obj                 getter )
{
    Obj                 tester;
    tester = ReturnTrueFilter;
    return tester;
}


Obj DoSetFilter (
    Obj                 self,
    Obj                 obj,
    Obj                 val )
{
    Int                 flag1;
    Obj                 kind;
    Obj                 flags;
    
    /* get the flag for the getter                                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    
    /* get the kind of the object and its flags                            */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );
    
    /* return the value of the feature                                     */
    if ( flag1 <= LEN_FLAGS( flags ) ) {
        if ( val != ELM_FLAGS( flags, flag1 ) ) {
            ErrorReturnVoid(
                "value feature is already set the other way",
                0L, 0L,
                "you can return to ignore it" );
        }
    }
    else {
        if ( val != False ) {
            ErrorReturnVoid(
                "value feature is already set the other way",
                0L, 0L,
                "you can return to ignore it" );
        }
    }

    /* return 'void'                                                       */
    return 0;
}


Obj NewSetterFilter (
    Obj                 getter )
{
    Obj                 setter;

    setter = NewOperationC( "<<filter-setter>>", 2L, "obj, val",
                                DoSetFilter );
    FLAG1_FILT(setter)  = FLAG1_FILT(getter);
    FLAG2_FILT(setter)  = INTOBJ_INT( 0 );
    CHANGED_BAG(setter);

    return setter;
}


Obj DoFilter (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag1;
    Obj                 kind;
    Obj                 flags;
    
    /* get the flag for the getter                                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    
    /* get the kind of the object and its flags                            */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );
    
    /* return the value of the feature                                     */
    if ( flag1 <= LEN_FLAGS( flags ) ) {
        val = ELM_FLAGS( flags, flag1 );
    }
    else {
        val = False;
    }
    
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
    Obj                 tester;
    Int                 flag1;
    Obj                 flags;
    
    flag1 = ++CountFlags;

    getter = NewOperation( name, 1L, nams, (hdlr ? hdlr : DoFilter) );
    FLAG1_FILT(getter)  = INTOBJ_INT( flag1 );
    FLAG2_FILT(getter)  = INTOBJ_INT( 0 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag1) );
    SET_LEN_FLAGS( flags, flag1 );
    SET_ELM_FLAGS( flags, flag1, True );
    FLAGS_FILT(getter)  = flags;
    CHANGED_BAG(getter);

    setter = NewSetterFilter( getter );
    SETTR_FILT(getter)  = setter;
    CHANGED_BAG(getter);
    
    tester = NewTesterFilter( getter );
    TESTR_FILT(getter)  = tester;
    CHANGED_BAG(getter);

    return getter;    
}


Obj NewFilterC (
    Char *              name,
    Int                 narg,
    Char *              nams,
    ObjFunc             hdlr )
{
    Obj                 getter;
    Obj                 setter;
    Obj                 tester;
    Int                 flag1;
    Obj                 flags;
    
    flag1 = ++CountFlags;

    getter = NewOperationC( name, 1L, nams, (hdlr ? hdlr : DoFilter) );
    FLAG1_FILT(getter)  = INTOBJ_INT( flag1 );
    FLAG2_FILT(getter)  = INTOBJ_INT( 0 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag1) );
    SET_LEN_FLAGS( flags, flag1 );
    SET_ELM_FLAGS( flags, flag1, True );
    FLAGS_FILT(getter)  = flags;
    CHANGED_BAG(getter);

    setter = NewSetterFilter( getter );
    SETTR_FILT(getter)  = setter;
    CHANGED_BAG(getter);
    
    tester = NewTesterFilter( getter );
    TESTR_FILT(getter)  = tester;
    CHANGED_BAG(getter);

    return getter;    
}


Obj NewFilterFunc;

Obj NewFilterHandler (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewFilter( <name> )",0L,0L);
        return 0;
    }

    /* make the new operation                                              */
    return NewFilter( name, 1L, (Obj)0, (ObjFunc)0 );
}


/****************************************************************************
**
*F  TestAndFilter( <getter> )  . . . . . . . .tester of a concatenated filter
*/
Obj DoTestAndFilter (
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


Obj TesterAndFilter (
    Obj                 getter )
{
    Obj                 tester;

    if ( TESTR_FILT( getter ) == INTOBJ_INT(0xBADBABE) ) {

        tester = NewAndFilter( TesterFilter( FLAG1_FILT(getter) ),
                               TesterFilter( FLAG2_FILT(getter) ) );

        TESTR_FILT(getter) = tester;
        CHANGED_BAG(getter);

    }
    return TESTR_FILT(getter);
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

    if ( SETTR_FILT( getter ) == INTOBJ_INT(0xBADBABE) ) {
        setter = NewFunctionCT( T_FUNCTION, SIZE_OPER,
                                "<<setter-and-filter>>", 2L, "obj, val",
                                DoSetAndFilter );
        FLAG1_FILT(setter)  = SetterFilter( FLAG1_FILT(getter) );
        FLAG2_FILT(setter)  = SetterFilter( FLAG2_FILT(getter) );
        SETTR_FILT(getter)  = setter;
        CHANGED_BAG(getter);
    }

    return SETTR_FILT(getter);
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

    if ( oper1 == ReturnTrueFilter && oper2 == ReturnTrueFilter )
        return ReturnTrueFilter;

    getter = NewFunctionCT( T_FUNCTION, SIZE_OPER,
                            "<<and-filter>>", 1L, "obj",
                            DoAndFilter );
    FLAG1_FILT(getter)  = oper1;
    FLAG2_FILT(getter)  = oper2;
    flags = FuncAND_FLAGS( 0, FLAGS_FILT(oper1), FLAGS_FILT(oper2) );
    FLAGS_FILT(getter)  = flags;
    SETTR_FILT(getter)  = INTOBJ_INT(0xBADBABE);
    TESTR_FILT(getter)  = INTOBJ_INT(0xBADBABE);
    CHANGED_BAG(getter);

    return getter;
}


/****************************************************************************
**
*F  ReturnTrueFilter . . . . . . . . . . . . . . . . the return 'true' filter
*/
Obj DoTestReturnTrueFilter (
    Obj                 self,
    Obj                 obj )
{
    return True;
}

Obj TesterReturnTrueFilter (
    Obj                 getter )
{
    Obj                 tester;
    tester = getter;
    return getter;
}

Obj DoSetReturnTrueFilter (
    Obj                 self,
    Obj                 obj,
    Obj                 val )
{
    if ( val != True ) {
         ErrorReturnVoid(
             "you cannot set this flag to 'false'",
             0L, 0L,
             "you can return to ignore it" );
    }
    return 0;
}

Obj SetterReturnTrueFilter (
    Obj                 getter )
{
    Obj                 setter;

    setter = NewFunctionCT( T_FUNCTION, SIZE_OPER,
                                "<<setter-true-filter>>", 2L, "obj, val",
                                DoSetReturnTrueFilter );
    FLAG1_FILT(setter)  = INTOBJ_INT( 0 );
    FLAG2_FILT(setter)  = INTOBJ_INT( 0 );
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

    getter = NewFunctionCT( T_FUNCTION, SIZE_OPER,
                                "ReturnTrueFilter", 1L, "obj",
                                DoReturnTrueFilter );
    FLAG1_FILT(getter)  = INTOBJ_INT( 0 );
    FLAG2_FILT(getter)  = INTOBJ_INT( 0 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(0) );
    SET_LEN_FLAGS( flags, 0 );
    FLAGS_FILT(getter)  = flags;
    CHANGED_BAG(getter);

    setter = SetterReturnTrueFilter( getter );
    SETTR_FILT(getter)  = setter;
    CHANGED_BAG(getter);

    tester = TesterReturnTrueFilter( getter );
    TESTR_FILT(getter)  = tester;
    CHANGED_BAG(getter);
        
    return getter;
}

Obj ReturnTrueFilter;


/****************************************************************************
**

*F  FuncIS_OPERATION( <self>, <obj> ) . . . . . . . . . is <obj> an operation
*/
Obj IsOperationFilt;

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
*F  FuncFlag1Filter( <self>, <oper> )
*/
Obj FuncFlag1Filter (
    Obj                 self,
    Obj                 oper )
{
    Obj                 flag1;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    flag1 = FLAG1_FILT( oper );
    if ( flag1 == 0 )  flag1 = INTOBJ_INT( 0 );
    return flag1;
}


/****************************************************************************
**
*F  FuncSetFlag1Filter( <self>, <oper>, <flag1> )
*/
Obj FuncSetFlag1Filter (
    Obj                 self,
    Obj                 oper,
    Obj                 flag1 )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    FLAG1_FILT( oper ) = flag1;
    return 0;
}


/****************************************************************************
**
*F  FuncFlag2Filter( <self>, <oper> )
*/
Obj FuncFlag2Filter (
    Obj                 self,
    Obj                 oper )
{
    Obj                 flag2;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    flag2 = FLAG2_FILT( oper );
    if ( flag2 == 0 )  flag2 = INTOBJ_INT( 0 );
    return flag2;
}


/****************************************************************************
**
*F  FuncSetFlag2Filter( <self>, <oper>, <flag2> )
*/
Obj FuncSetFlag2Filter (
    Obj                 self,
    Obj                 oper,
    Obj                 flag2 )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    FLAG2_FILT( oper ) = flag2;
    return 0;
}


/****************************************************************************
**
*F  FuncFlagsFilter( <self>, <oper> )
*/
Obj FuncFlagsFilter (
    Obj                 self,
    Obj                 oper )
{
    Obj                 flags;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    flags = FLAGS_FILT( oper );
    if ( flags == 0 )  flags = False;
    return flags;
}


/****************************************************************************
**
*F  FuncSetFlagsFilter( <self>, <oper>, <flags> )
*/
Obj FuncSetFlagsFilter (
    Obj                 self,
    Obj                 oper,
    Obj                 flags )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    FLAGS_FILT( oper ) = flags;
    return 0;
}


/****************************************************************************
**
*F  FuncSetterFilter( <self>, <oper> )
*/
Obj FuncSetterFilter (
    Obj                 self,
    Obj                 oper )
{
    Obj                 setter;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    setter = SetterFilter( oper );
    if ( setter == 0 )  setter = False;
    return setter;
}


/****************************************************************************
**
*F  FuncSetSetterFilter( <self>, <oper>, <setter> )
*/
Obj FuncSetSetterFilter (
    Obj                 self,
    Obj                 oper,
    Obj                 setter )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    SETTR_FILT( oper ) = setter;
    return 0;
}


/****************************************************************************
**
*F  FuncTesterFilter( <self>, <oper> )
*/
Obj FuncTesterFilter (
    Obj                 self,
    Obj                 oper )
{
    Obj                 tester;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    tester = TesterFilter( oper );
    if ( tester == 0 )  tester = False;
    return tester;
}


/****************************************************************************
**
*F  FuncSetTesterFilter( <self>, <oper>, <tester> )
*/
Obj FuncSetTesterFilter (
    Obj                 self,
    Obj                 oper,
    Obj                 tester )
{
    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    if ( SIZE_OBJ(oper) != SIZE_OPER ) {
        ResizeBag( oper, SIZE_OPER );
    }
    TESTR_FILT( oper ) = tester;
    return 0;
}


/****************************************************************************
**
*F  FuncMethodsOperation( <self>, <oper>, <narg> )  . . . . .  list of method
*/
Obj FuncMethodsOperation (
    Obj                 self,
    Obj                 oper,
    Obj                 narg )
{
    Int                 n;
    Obj                 meth;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    if ( TNUM_OBJ(narg) != T_INT || INT_INTOBJ(narg) < 0 ) {
        ErrorQuit("<narg> must be a nonnegative integer",0L,0L);
        return 0;
    }
    n = INT_INTOBJ( narg );
    meth = MethsOper( oper, n );
    return meth == 0 ? Fail : meth;
}


/****************************************************************************
**
*F  FuncChangedMethodsOperation( <self>, <oper>, <narg> )
*/
Obj FuncChangedMethodsOperation (
    Obj                 self,
    Obj                 oper,
    Obj                 narg )
{
    Obj *               cache;
    Int                 n;
    Int                 i;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    if ( TNUM_OBJ(narg) != T_INT || INT_INTOBJ(narg) < 0 ) {
        ErrorQuit("<narg> must be a nonnegative integer",0L,0L);
        return 0;
    }
    n = INT_INTOBJ( narg );
    cache = ADDR_OBJ( CacheOper( oper, n ) );
    for ( i = 0;  i < SIZE_OBJ(CACHE_OPER(oper,n)) / sizeof(Obj);  i++ ) {
        cache[i] = 0;
    }
    return 0;
}


/****************************************************************************
**
*F  FuncSetMethodsOperation( <self>, <oper>, <narg>, <list> )
*/
Obj FuncSetMethodsOperation (
    Obj                 self,
    Obj                 oper,
    Obj                 narg,
    Obj                 meths )
{
    Int                 n;

    if ( ! IS_OPERATION(oper) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    if ( TNUM_OBJ(narg) != T_INT || INT_INTOBJ(narg) < 0 ) {
        ErrorQuit("<narg> must be a nonnegative integer",0L,0L);
        return 0;
    }
    n = INT_INTOBJ( narg );
    METHS_OPER( oper, n ) = meths;
    return 0;
}


/****************************************************************************
**

*F  NewOperation( <name> ) . . . . . . . . . . . . . . . make a new operation
*/
UInt CacheIndex;

Obj Method0Args;
Obj NextMethod0Args;
Obj Method1Args;
Obj NextMethod1Args;
Obj Method2Args;
Obj NextMethod2Args;
Obj Method3Args;
Obj NextMethod3Args;
Obj Method4Args;
Obj NextMethod4Args;
Obj Method5Args;
Obj NextMethod5Args;
Obj Method6Args;
Obj NextMethod6Args;
Obj MethodXArgs;
Obj NextMethodXArgs;

Obj VMethod0Args;
Obj NextVMethod0Args;
Obj VMethod1Args;
Obj NextVMethod1Args;
Obj VMethod2Args;
Obj NextVMethod2Args;
Obj VMethod3Args;
Obj NextVMethod3Args;
Obj VMethod4Args;
Obj NextVMethod4Args;
Obj VMethod5Args;
Obj NextVMethod5Args;
Obj VMethod6Args;
Obj NextVMethod6Args;
Obj VMethodXArgs;
Obj NextVMethodXArgs;


/****************************************************************************
**
*f  DoOperation0Args( <oper> )
*/
Int OperationHit;
Int OperationMiss;
Int OperationNext;

Obj DoOperation0Args (
    Obj                 oper )
{
    Obj                 res;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 0 ) );
    if ( cache[0] != 0 ) {
        method = cache[0];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_1ARGS( Method0Args, oper );
        cache = ADDR_OBJ( CACHE_OPER( oper, 0 ) );
        cache[0] = method;
        CHANGED_BAG(CACHE_OPER(oper,0));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_0ARGS( method );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_2ARGS( NextMethod0Args, oper, INTOBJ_INT(i) );
            i++;
            res = CALL_0ARGS( method );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoOperation1Args( <oper>, <a1> )
*/
Obj DoOperation1Args (
    Obj                 oper,
    Obj                 arg1 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 id1;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );  id1 = ID_TYPE( kind1 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 1 ) );
    if      ( cache[2*0+1] == id1 ) {
        method = cache[2*0+2];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[2*1+1] == id1 ) {
        method = cache[2*1+2];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[2*2+1] == id1 ) {
        method = cache[2*2+2];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[2*3+1] == id1 ) {
        method = cache[2*3+2];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_2ARGS( Method1Args, oper, kind1 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 1 ) );
        cache[ 2*CacheIndex+1 ] = id1;
        cache[ 2*CacheIndex+2 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,1));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_1ARGS( method, arg1 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_3ARGS( NextMethod1Args, oper, INTOBJ_INT(i),
                                 kind1 );
            i++;
            res = CALL_1ARGS( method, arg1 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoOperation2Args( <oper>, <a1>, <a2> )
*/
Obj DoOperation2Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 id1;
    Obj                 kind2;
    Obj                 id2;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );  id1 = ID_TYPE( kind1 );
    kind2 = TYPE_OBJ( arg2 );  id2 = ID_TYPE( kind2 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 2 ) );
    if      ( cache[3*0+1] == id1
           && cache[3*0+2] == id2 ) {
        method = cache[3*0+3];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[3*1+1] == id1
           && cache[3*1+2] == id2 ) {
        method = cache[3*1+3];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[3*2+1] == id1
           && cache[3*2+2] == id2 ) {
        method = cache[3*2+3];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[3*3+1] == id1
           && cache[3*3+2] == id2 ) {
        method = cache[3*3+3];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_3ARGS( Method2Args, oper,
                             kind1, kind2 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 2 ) );
        cache[ 3*CacheIndex+1 ] = id1;
        cache[ 3*CacheIndex+2 ] = id2;
        cache[ 3*CacheIndex+3 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,2));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_2ARGS( method, arg1, arg2 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_4ARGS( NextMethod2Args, oper, INTOBJ_INT(i),
                                 kind1, kind2 );
            i++;
            res = CALL_2ARGS( method, arg1, arg2 );
        }
    }

    /* return the result                                                   */
    return res;
}

/****************************************************************************
**
*f  DoOperation3Args( <oper>, <a1>, <a2>, <a3> )
*/
Obj DoOperation3Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 id1;
    Obj                 kind2;
    Obj                 id2;
    Obj                 kind3;
    Obj                 id3;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );  id1 = ID_TYPE( kind1 );
    kind2 = TYPE_OBJ( arg2 );  id2 = ID_TYPE( kind2 );
    kind3 = TYPE_OBJ( arg3 );  id3 = ID_TYPE( kind3 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 3 ) );
    if      ( cache[4*0+1] == id1
           && cache[4*0+2] == id2
           && cache[4*0+3] == id3 ) {
        method = cache[4*0+4];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[4*1+1] == id1
           && cache[4*1+2] == id2
           && cache[4*1+3] == id3 ) {
        method = cache[4*1+4];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[4*2+1] == id1
           && cache[4*2+2] == id2
           && cache[4*2+3] == id3 ) {
        method = cache[4*2+4];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[4*3+1] == id1
           && cache[4*3+2] == id2
           && cache[4*3+3] == id3 ) {
        method = cache[4*3+4];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_4ARGS( Method3Args, oper,
                             kind1, kind2, kind3 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 3 ) );
        cache[ 4*CacheIndex+1 ] = id1;
        cache[ 4*CacheIndex+2 ] = id2;
        cache[ 4*CacheIndex+3 ] = id3;
        cache[ 4*CacheIndex+4 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,3));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_3ARGS( method, arg1, arg2, arg3 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_5ARGS( NextMethod3Args, oper, INTOBJ_INT(i),
                                 kind1, kind2, kind3 );
            i++;
            res = CALL_3ARGS( method, arg1, arg2, arg3 );
        }
    }

    /* return the result                                                   */
    return res;
}

/****************************************************************************
**
*f  DoOperation4Args( <oper>, <a1>, <a2>, <a3>, <a4> )
*/
Obj DoOperation4Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 id1;
    Obj                 kind2;
    Obj                 id2;
    Obj                 kind3;
    Obj                 id3;
    Obj                 kind4;
    Obj                 id4;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );  id1 = ID_TYPE( kind1 );
    kind2 = TYPE_OBJ( arg2 );  id2 = ID_TYPE( kind2 );
    kind3 = TYPE_OBJ( arg3 );  id3 = ID_TYPE( kind3 );
    kind4 = TYPE_OBJ( arg4 );  id4 = ID_TYPE( kind4 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 4 ) );
    if      ( cache[5*0+1] == id1
           && cache[5*0+2] == id2
           && cache[5*0+3] == id3
           && cache[5*0+4] == id4 ) {
        method = cache[5*0+5];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[5*1+1] == id1
           && cache[5*1+2] == id2
           && cache[5*1+3] == id3
           && cache[5*1+4] == id4 ) {
        method = cache[5*1+5];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[5*2+1] == id1
           && cache[5*2+2] == id2
           && cache[5*2+3] == id3
           && cache[5*2+4] == id4 ) {
        method = cache[5*2+5];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[5*3+1] == id1
           && cache[5*3+2] == id2
           && cache[5*3+3] == id3
           && cache[5*3+4] == id4 ) {
        method = cache[5*3+5];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_5ARGS( Method4Args, oper,
                             kind1, kind2, kind3, kind4 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 4 ) );
        cache[ 5*CacheIndex+1 ] = id1;
        cache[ 5*CacheIndex+2 ] = id2;
        cache[ 5*CacheIndex+3 ] = id3;
        cache[ 5*CacheIndex+4 ] = id4;
        cache[ 5*CacheIndex+5 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,4));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_4ARGS( method, arg1, arg2, arg3, arg4 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_6ARGS( NextMethod4Args, oper, INTOBJ_INT(i),
                                 kind1, kind2, kind3, kind4 );
            i++;
            res = CALL_4ARGS( method, arg1, arg2, arg3, arg4 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoOperation5Args( <oper>, <a1>, <a2>, <a3>, <a4>, <a5> )
*/
Obj DoOperation5Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 id1;
    Obj                 kind2;
    Obj                 id2;
    Obj                 kind3;
    Obj                 id3;
    Obj                 kind4;
    Obj                 id4;
    Obj                 kind5;
    Obj                 id5;
    Obj *               cache;
    Obj                 method;
    Obj                 margs;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );  id1 = ID_TYPE( kind1 );
    kind2 = TYPE_OBJ( arg2 );  id2 = ID_TYPE( kind2 );
    kind3 = TYPE_OBJ( arg3 );  id3 = ID_TYPE( kind3 );
    kind4 = TYPE_OBJ( arg4 );  id4 = ID_TYPE( kind4 );
    kind5 = TYPE_OBJ( arg5 );  id5 = ID_TYPE( kind5 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 5 ) );
    if      ( cache[6*0+1] == id1
           && cache[6*0+2] == id2
           && cache[6*0+3] == id3
           && cache[6*0+4] == id4
           && cache[6*0+5] == id5 ) {
        method = cache[6*0+6];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[6*1+1] == id1
           && cache[6*1+2] == id2
           && cache[6*1+3] == id3
           && cache[6*1+4] == id4
           && cache[6*1+5] == id5 ) {
        method = cache[6*1+6];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[6*2+1] == id1
           && cache[6*2+2] == id2
           && cache[6*2+3] == id3
           && cache[6*2+4] == id4
           && cache[6*2+5] == id5 ) {
        method = cache[6*2+6];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[6*3+1] == id1
           && cache[6*3+2] == id2
           && cache[6*3+3] == id3
           && cache[6*3+4] == id4
           && cache[6*3+5] == id5 ) {
        method = cache[6*3+6];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_6ARGS( Method5Args, oper,
                             kind1, kind2, kind3, kind4, kind5 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 5 ) );
        cache[ 6*CacheIndex+1 ] = id1;
        cache[ 6*CacheIndex+2 ] = id2;
        cache[ 6*CacheIndex+3 ] = id3;
        cache[ 6*CacheIndex+4 ] = id4;
        cache[ 6*CacheIndex+5 ] = id5;
        cache[ 6*CacheIndex+6 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,5));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_5ARGS( method, arg1, arg2, arg3, arg4, arg5 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            margs = NEW_PLIST( T_PLIST, 7 );
            SET_LEN_PLIST( margs, 7 );
            SET_ELM_PLIST( margs, 1, oper );
            SET_ELM_PLIST( margs, 2, INTOBJ_INT(i) );
            SET_ELM_PLIST( margs, 3, kind1 );
            SET_ELM_PLIST( margs, 4, kind2 );
            SET_ELM_PLIST( margs, 5, kind3 );
            SET_ELM_PLIST( margs, 6, kind4 );
            SET_ELM_PLIST( margs, 7, kind5 );
            method = CALL_XARGS( NextMethod5Args, margs );
            i++;
            res = CALL_5ARGS( method, arg1, arg2, arg3, arg4, arg5 );
        }
    }

    /* return the result                                                   */
    return res;
}

/****************************************************************************
**
*f  DoOperation6Args( <oper>, <a1>, <a2>, <a3>, <a4>, <a5>, <a6> )
*/
Obj DoOperation6Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 id1;
    Obj                 kind2;
    Obj                 id2;
    Obj                 kind3;
    Obj                 id3;
    Obj                 kind4;
    Obj                 id4;
    Obj                 kind5;
    Obj                 id5;
    Obj                 kind6;
    Obj                 id6;
    Obj *               cache;
    Obj                 method;
    Obj                 margs;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );  id1 = ID_TYPE( kind1 );
    kind2 = TYPE_OBJ( arg2 );  id2 = ID_TYPE( kind2 );
    kind3 = TYPE_OBJ( arg3 );  id3 = ID_TYPE( kind3 );
    kind4 = TYPE_OBJ( arg4 );  id4 = ID_TYPE( kind4 );
    kind5 = TYPE_OBJ( arg5 );  id5 = ID_TYPE( kind5 );
    kind6 = TYPE_OBJ( arg6 );  id6 = ID_TYPE( kind6 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 6 ) );
    if      ( cache[7*0+1] == id1
           && cache[7*0+2] == id2
           && cache[7*0+3] == id3
           && cache[7*0+4] == id4
           && cache[7*0+5] == id5
           && cache[7*0+6] == id6 ) {
        method = cache[7*0+7];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[7*1+1] == id1
           && cache[7*1+2] == id2
           && cache[7*1+3] == id3
           && cache[7*1+4] == id4
           && cache[7*1+5] == id5
           && cache[7*1+6] == id6 ) {
        method = cache[7*1+7];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[7*2+1] == id1
           && cache[7*2+2] == id2
           && cache[7*2+3] == id3
           && cache[7*2+4] == id4
           && cache[7*2+5] == id5
           && cache[7*2+6] == id6 ) {
        method = cache[7*2+7];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[7*3+1] == id1
           && cache[7*3+2] == id2
           && cache[7*3+3] == id3
           && cache[7*3+4] == id4
           && cache[7*3+5] == id5
           && cache[7*3+6] == id6 ) {
        method = cache[7*3+7];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        margs = NEW_PLIST( T_PLIST, 7 );
        SET_LEN_PLIST( margs, 7 );
        SET_ELM_PLIST( margs, 1, oper );
        SET_ELM_PLIST( margs, 2, kind1 );
        SET_ELM_PLIST( margs, 3, kind2 );
        SET_ELM_PLIST( margs, 4, kind3 );
        SET_ELM_PLIST( margs, 5, kind4 );
        SET_ELM_PLIST( margs, 6, kind5 );
        SET_ELM_PLIST( margs, 7, kind6 );
        method = CALL_XARGS( Method6Args, margs );
        cache = ADDR_OBJ( CACHE_OPER( oper, 6 ) );
        cache[ 7*CacheIndex+1 ] = id1;
        cache[ 7*CacheIndex+2 ] = id2;
        cache[ 7*CacheIndex+3 ] = id3;
        cache[ 7*CacheIndex+4 ] = id4;
        cache[ 7*CacheIndex+5 ] = id5;
        cache[ 7*CacheIndex+6 ] = id6;
        cache[ 7*CacheIndex+7 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,6));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_6ARGS( method, arg1, arg2, arg3, arg4, arg5, arg6 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            margs = NEW_PLIST( T_PLIST, 8 );
            SET_LEN_PLIST( margs, 8 );
            SET_ELM_PLIST( margs, 1, oper );
            SET_ELM_PLIST( margs, 2, INTOBJ_INT(i) );
            SET_ELM_PLIST( margs, 3, kind1 );
            SET_ELM_PLIST( margs, 4, kind2 );
            SET_ELM_PLIST( margs, 5, kind3 );
            SET_ELM_PLIST( margs, 6, kind4 );
            SET_ELM_PLIST( margs, 7, kind5 );
            SET_ELM_PLIST( margs, 8, kind6 );
            method = CALL_XARGS( NextMethod6Args, margs );
            i++;
            res = CALL_6ARGS( method, arg1, arg2, arg3, arg4, arg5, arg6 );
        }
    }

    /* return the result                                                   */
    return res;
}

/****************************************************************************
**
*f  DoOperationXArgs( <oper>, ... )
*/
Obj DoOperationXArgs (
    Obj                 self,
    Obj                 args )
{
    ErrorQuit("sorry: cannot yet have X argument operations",0L,0L);
    return 0;
}


/****************************************************************************
**
*f  DoVerboseOperation0Args( <oper> )
*/
Obj DoVerboseOperation0Args (
    Obj                 oper )
{
    Obj                 res;
    Obj                 method;
    Int                 i;

    /* try to find one in the list of methods                              */
    method = CALL_1ARGS( VMethod0Args, oper );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_0ARGS( method );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_2ARGS( NextVMethod0Args, oper, INTOBJ_INT(i) );
            i++;
            res = CALL_0ARGS( method );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseOperation1Args( <oper>, <a1> )
*/
Obj DoVerboseOperation1Args (
    Obj                 oper,
    Obj                 arg1 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );

    /* try to find one in the list of methods                              */
    method = CALL_2ARGS( VMethod1Args, oper, kind1 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_1ARGS( method, arg1 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_3ARGS( NextVMethod1Args, oper, INTOBJ_INT(i),
                                 kind1 );
            i++;
            res = CALL_1ARGS( method, arg1 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseOperation2Args( <oper>, <a1>, <a2> )
*/
Obj DoVerboseOperation2Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );
    kind2 = TYPE_OBJ( arg2 );

    /* try to find one in the list of methods                              */
    method = CALL_3ARGS( VMethod2Args, oper, kind1, kind2 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_2ARGS( method, arg1, arg2 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_4ARGS( NextVMethod2Args, oper, INTOBJ_INT(i),
                                 kind1, kind2 );
            i++;
            res = CALL_2ARGS( method, arg1, arg2 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseOperation3Args( <oper>, <a1>, <a2>, <a3> )
*/
Obj DoVerboseOperation3Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 kind3;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );
    kind2 = TYPE_OBJ( arg2 );
    kind3 = TYPE_OBJ( arg3 );

    /* try to find one in the list of methods                              */
    method = CALL_4ARGS( VMethod3Args, oper, kind1, kind2, kind3 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_3ARGS( method, arg1, arg2, arg3 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_5ARGS( NextVMethod3Args, oper, INTOBJ_INT(i),
                                 kind1, kind2, kind3 );
            i++;
            res = CALL_3ARGS( method, arg1, arg2, arg3 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseOperation4Args( <oper>, <a1>, <a2>, <a3>, <a4> )
*/
Obj DoVerboseOperation4Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 kind3;
    Obj                 kind4;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );
    kind2 = TYPE_OBJ( arg2 );
    kind3 = TYPE_OBJ( arg3 );
    kind4 = TYPE_OBJ( arg4 );

    /* try to find one in the list of methods                              */
    method = CALL_5ARGS( VMethod4Args, oper, kind1, kind2, kind3, kind4 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_4ARGS( method, arg1, arg2, arg3, arg4 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_6ARGS( NextVMethod4Args, oper, INTOBJ_INT(i),
                                 kind1, kind2, kind3, kind4 );
            i++;
            res = CALL_4ARGS( method, arg1, arg2, arg3, arg4 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseOperation5Args( <oper>, <a1>, <a2>, <a3>, <a4>, <a5> )
*/
Obj DoVerboseOperation5Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 kind3;
    Obj                 kind4;
    Obj                 kind5;
    Obj                 method;
    Obj                 margs;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );
    kind2 = TYPE_OBJ( arg2 );
    kind3 = TYPE_OBJ( arg3 );
    kind4 = TYPE_OBJ( arg4 );
    kind5 = TYPE_OBJ( arg5 );

    /* try to find one in the list of methods                              */
    method = CALL_6ARGS( VMethod5Args, oper, kind1, kind2, kind3, kind4,
                         kind5 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_5ARGS( method, arg1, arg2, arg3, arg4, arg5 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            margs = NEW_PLIST( T_PLIST, 7 );
            SET_LEN_PLIST( margs, 7 );
            SET_ELM_PLIST( margs, 1, oper );
            SET_ELM_PLIST( margs, 2, INTOBJ_INT(i) );
            SET_ELM_PLIST( margs, 3, kind1 );
            SET_ELM_PLIST( margs, 4, kind2 );
            SET_ELM_PLIST( margs, 5, kind3 );
            SET_ELM_PLIST( margs, 6, kind4 );
            SET_ELM_PLIST( margs, 7, kind5 );
            method = CALL_XARGS( NextVMethod5Args, margs );
            i++;
            res = CALL_5ARGS( method, arg1, arg2, arg3, arg4, arg5 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseOperation6Args( <oper>, <a1>, <a2>, <a3>, <a4>, <a5>, <a6> )
*/
Obj DoVerboseOperation6Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 kind3;
    Obj                 kind4;
    Obj                 kind5;
    Obj                 kind6;
    Obj                 method;
    Obj                 margs;
    Int                 i;

    /* get the kinds of the arguments                                      */
    kind1 = TYPE_OBJ( arg1 );
    kind2 = TYPE_OBJ( arg2 );
    kind3 = TYPE_OBJ( arg3 );
    kind4 = TYPE_OBJ( arg4 );
    kind5 = TYPE_OBJ( arg5 );
    kind6 = TYPE_OBJ( arg6 );

    /* try to find one in the list of methods                              */
    margs = NEW_PLIST( T_PLIST, 7 );
    SET_LEN_PLIST( margs, 7 );
    SET_ELM_PLIST( margs, 1, oper );
    SET_ELM_PLIST( margs, 2, kind1 );
    SET_ELM_PLIST( margs, 3, kind2 );
    SET_ELM_PLIST( margs, 4, kind3 );
    SET_ELM_PLIST( margs, 5, kind4 );
    SET_ELM_PLIST( margs, 6, kind5 );
    SET_ELM_PLIST( margs, 7, kind6 );
    method = CALL_XARGS( VMethod6Args, margs );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_6ARGS( method, arg1, arg2, arg3, arg4, arg5, arg6 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            margs = NEW_PLIST( T_PLIST, 8 );
            SET_LEN_PLIST( margs, 8 );
            SET_ELM_PLIST( margs, 1, oper );
            SET_ELM_PLIST( margs, 2, INTOBJ_INT(i) );
            SET_ELM_PLIST( margs, 3, kind1 );
            SET_ELM_PLIST( margs, 4, kind2 );
            SET_ELM_PLIST( margs, 5, kind3 );
            SET_ELM_PLIST( margs, 6, kind4 );
            SET_ELM_PLIST( margs, 7, kind5 );
            SET_ELM_PLIST( margs, 8, kind6 );
            method = CALL_XARGS( NextVMethod6Args, margs );
            i++;
            res = CALL_6ARGS( method, arg1, arg2, arg3, arg4, arg5, arg6 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseOperationXArgs( <oper>, ... )
*/
Obj DoVerboseOperationXArgs (
    Obj                 self,
    Obj                 args )
{
    ErrorQuit("sorry: cannot yet have X argument operations",0L,0L);
    return 0;
}


/****************************************************************************
**
*f  NewOperation( <name>, <narg>, <nams>, <hdlr> )
*/
Obj NewOperation (
    Obj                 name,
    Int                 narg,
    Obj                 nams,
    ObjFunc             hdlr )
{
    Obj                 oper;
#ifdef  PREALLOCATE_TABLES
    Obj                 cache;
    Obj                 methods;
    UInt                i;
#endif

    /* create the function                                                 */
    oper = NewFunctionT( T_FUNCTION, SIZE_OPER, name, narg, nams, hdlr );

    /* enter the handlers                                                  */
    if ( narg == -1 ) {
        HDLR_FUNC(oper,0) = DoOperation0Args;
        HDLR_FUNC(oper,1) = DoOperation1Args;
        HDLR_FUNC(oper,2) = DoOperation2Args;
        HDLR_FUNC(oper,3) = DoOperation3Args;
        HDLR_FUNC(oper,4) = DoOperation4Args;
        HDLR_FUNC(oper,5) = DoOperation5Args;
        HDLR_FUNC(oper,6) = DoOperation6Args;
        HDLR_FUNC(oper,7) = DoOperationXArgs;
    }

    /*N 1996/06/06 mschoene this should not be done here                   */
    FLAG1_FILT(oper) = INT_INTOBJ(0);
    FLAG2_FILT(oper) = INT_INTOBJ(0);
    FLAGS_FILT(oper) = False;
    SETTR_FILT(oper) = False;
    TESTR_FILT(oper) = False;
    
    /* create caches and methods lists                                     */
#ifdef  PREALLOCATE_TABLES
    for ( i = 0; i <= 7; i++ ) {
        methods = NEW_PLIST( T_PLIST, 0 );
        METHS_OPER( oper, i ) = methods;
        cache = NEW_PLIST( T_PLIST, (i < 7 ? 4 * (i+1) : 4 * (1+1)) );
        CACHE_OPER( oper, i ) = cache;
        CHANGED_BAG(oper);
    }
#endif

    /* return operation                                                    */
    return oper;
}


/****************************************************************************
**
*f  NewOperationC( <name>, <narg>, <nams>, <hdlr> )
*/
Obj NewOperationC (
    Char *              name,
    Int                 narg,
    Char *              nams,
    ObjFunc             hdlr )
{
    Obj                 oper;
#ifdef  PREALLOCATE_TABLES
    Obj                 cache;
    Obj                 methods;
    UInt                i;
#endif

    /* create the function                                                 */
    oper = NewFunctionCT( T_FUNCTION, SIZE_OPER, name, narg, nams, hdlr );

    /* enter the handlers                                                  */
    if ( narg == -1 ) {
        HDLR_FUNC(oper,0) = DoOperation0Args;
        HDLR_FUNC(oper,1) = DoOperation1Args;
        HDLR_FUNC(oper,2) = DoOperation2Args;
        HDLR_FUNC(oper,3) = DoOperation3Args;
        HDLR_FUNC(oper,4) = DoOperation4Args;
        HDLR_FUNC(oper,5) = DoOperation5Args;
        HDLR_FUNC(oper,6) = DoOperation6Args;
        HDLR_FUNC(oper,7) = DoOperationXArgs;
    }

    /*N 1996/06/06 mschoene this should not be done here                   */
    FLAG1_FILT(oper) = INT_INTOBJ(0);
    FLAG2_FILT(oper) = INT_INTOBJ(0);
    FLAGS_FILT(oper) = False;
    SETTR_FILT(oper) = False;
    TESTR_FILT(oper) = False;
    
    /* create caches and methods lists                                     */
#ifdef  PREALLOCATE_TABLES
    for ( i = 0; i <= 7; i++ ) {
        methods = NEW_PLIST( T_PLIST, 0 );
        METHS_OPER( oper, i ) = methods;
        cache = NEW_PLIST( T_PLIST, (i < 7 ? 4 * (i+1) : 4 * (1+1)) );
        CACHE_OPER( oper, i ) = cache;
        CHANGED_BAG(oper);
    }
#endif

    /* return operation                                                    */
    return oper;
}


/****************************************************************************
**
*f  NewOperationHandler( <name> )
*/
Obj NewOperationFunc;

Obj NewOperationHandler (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewOperation( <name> )",0L,0L);
        return 0;
    }

    /* make the new operation                                              */
    return NewOperation( name, -1L, (Obj)0, DoOperationXArgs );
}


/****************************************************************************
**

*F  NewConstructor( <name> )  . . . . . . . . . . . .  make a new constructor
*/
UInt CacheIndex;

Obj Constructor0Args;
Obj NextConstructor0Args;
Obj Constructor1Args;
Obj NextConstructor1Args;
Obj Constructor2Args;
Obj NextConstructor2Args;
Obj Constructor3Args;
Obj NextConstructor3Args;
Obj Constructor4Args;
Obj NextConstructor4Args;
Obj Constructor5Args;
Obj NextConstructor5Args;
Obj Constructor6Args;
Obj NextConstructor6Args;
Obj ConstructorXArgs;
Obj NextConstructorXArgs;

Obj VConstructor0Args;
Obj NextVConstructor0Args;
Obj VConstructor1Args;
Obj NextVConstructor1Args;
Obj VConstructor2Args;
Obj NextVConstructor2Args;
Obj VConstructor3Args;
Obj NextVConstructor3Args;
Obj VConstructor4Args;
Obj NextVConstructor4Args;
Obj VConstructor5Args;
Obj NextVConstructor5Args;
Obj VConstructor6Args;
Obj NextVConstructor6Args;
Obj VConstructorXArgs;
Obj NextVConstructorXArgs;


/****************************************************************************
**
*f  DoConstructor0Args( <oper> )
*/
Obj DoConstructor0Args (
    Obj                 oper )
{
    Obj                 res;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 0 ) );
    if ( cache[0] != 0 ) {
        method = cache[0];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_1ARGS( Constructor0Args, oper );
        cache = ADDR_OBJ( CACHE_OPER( oper, 0 ) );
        cache[0] = method;
        CHANGED_BAG(CACHE_OPER(oper,0));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_0ARGS( method );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_2ARGS( NextConstructor0Args, oper, INTOBJ_INT(i) );
            i++;
            res = CALL_0ARGS( method );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoConstructor1Args( <oper>, <a1> )
*/
Obj DoConstructor1Args (
    Obj                 oper,
    Obj                 arg1 )
{
    Obj                 res;
    Obj                 kind1;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 1 ) );
    if      ( cache[2*0+1] == kind1 ) {
        method = cache[2*0+2];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[2*1+1] == kind1 ) {
        method = cache[2*1+2];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[2*2+1] == kind1 ) {
        method = cache[2*2+2];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[2*3+1] == kind1 ) {
        method = cache[2*3+2];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_2ARGS( Constructor1Args, oper, kind1 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 1 ) );
        cache[ 2*CacheIndex+1 ] = kind1;
        cache[ 2*CacheIndex+2 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,1));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_1ARGS( method, arg1 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_3ARGS( NextConstructor1Args, oper, INTOBJ_INT(i),
                                 kind1 );
            i++;
            res = CALL_1ARGS( method, arg1 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoConstructor2Args( <oper>, <a1>, <a2> )
*/
Obj DoConstructor2Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 id2;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );  id2 = ID_TYPE( kind2 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 2 ) );
    if      ( cache[3*0+1] == kind1
           && cache[3*0+2] == id2 ) {
        method = cache[3*0+3];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[3*1+1] == kind1
           && cache[3*1+2] == id2 ) {
        method = cache[3*1+3];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[3*2+1] == kind1
           && cache[3*2+2] == id2 ) {
        method = cache[3*2+3];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[3*3+1] == kind1
           && cache[3*3+2] == id2 ) {
        method = cache[3*3+3];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_3ARGS( Constructor2Args, oper,
                             kind1, kind2 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 2 ) );
        cache[ 3*CacheIndex+1 ] = kind1;
        cache[ 3*CacheIndex+2 ] = id2;
        cache[ 3*CacheIndex+3 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,2));
#ifdef COUNT_OPERS
    OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_2ARGS( method, arg1, arg2 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_4ARGS( NextConstructor2Args, oper, INTOBJ_INT(i),
                                 kind1, kind2 );
            i++;
            res = CALL_2ARGS( method, arg1, arg2 );
        }
    }

    /* return the result                                                   */
    return res;
}

/****************************************************************************
**
*f  DoConstructor3Args( <oper>, <a1>, <a2>, <a3> )
*/
Obj DoConstructor3Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 id2;
    Obj                 kind3;
    Obj                 id3;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );  id2 = ID_TYPE( kind2 );
    kind3 = TYPE_OBJ(   arg3 );  id3 = ID_TYPE( kind3 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 3 ) );
    if      ( cache[4*0+1] == kind1
           && cache[4*0+2] == id2
           && cache[4*0+3] == id3 ) {
        method = cache[4*0+4];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[4*1+1] == kind1
           && cache[4*1+2] == id2
           && cache[4*1+3] == id3 ) {
        method = cache[4*1+4];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[4*2+1] == kind1
           && cache[4*2+2] == id2
           && cache[4*2+3] == id3 ) {
        method = cache[4*2+4];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[4*3+1] == kind1
           && cache[4*3+2] == id2
           && cache[4*3+3] == id3 ) {
        method = cache[4*3+4];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_4ARGS( Constructor3Args, oper,
                             kind1, kind2, kind3 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 3 ) );
        cache[ 4*CacheIndex+1 ] = kind1;
        cache[ 4*CacheIndex+2 ] = id2;
        cache[ 4*CacheIndex+3 ] = id3;
        cache[ 4*CacheIndex+4 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,3));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_3ARGS( method, arg1, arg2, arg3 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_5ARGS( NextConstructor3Args, oper, INTOBJ_INT(i),
                                 kind1, kind2, kind3 );
            i++;
            res = CALL_3ARGS( method, arg1, arg2, arg3 );
        }
    }

    /* return the result                                                   */
    return res;
}

/****************************************************************************
**
*f  DoConstructor4Args( <oper>, <a1>, <a2>, <a3>, <a4> )
*/
Obj DoConstructor4Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 id2;
    Obj                 kind3;
    Obj                 id3;
    Obj                 kind4;
    Obj                 id4;
    Obj *               cache;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );  id2 = ID_TYPE( kind2 );
    kind3 = TYPE_OBJ(   arg3 );  id3 = ID_TYPE( kind3 );
    kind4 = TYPE_OBJ(   arg4 );  id4 = ID_TYPE( kind4 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 4 ) );
    if      ( cache[5*0+1] == kind1
           && cache[5*0+2] == id2
           && cache[5*0+3] == id3
           && cache[5*0+4] == id4 ) {
        method = cache[5*0+5];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[5*1+1] == kind1
           && cache[5*1+2] == id2
           && cache[5*1+3] == id3
           && cache[5*1+4] == id4 ) {
        method = cache[5*1+5];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[5*2+1] == kind1
           && cache[5*2+2] == id2
           && cache[5*2+3] == id3
           && cache[5*2+4] == id4 ) {
        method = cache[5*2+5];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[5*3+1] == kind1
           && cache[5*3+2] == id2
           && cache[5*3+3] == id3
           && cache[5*3+4] == id4 ) {
        method = cache[5*3+5];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_5ARGS( Constructor4Args, oper,
                             kind1, kind2, kind3, kind4 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 4 ) );
        cache[ 5*CacheIndex+1 ] = kind1;
        cache[ 5*CacheIndex+2 ] = id2;
        cache[ 5*CacheIndex+3 ] = id3;
        cache[ 5*CacheIndex+4 ] = id4;
        cache[ 5*CacheIndex+5 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,4));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_4ARGS( method, arg1, arg2, arg3, arg4 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_6ARGS( NextConstructor4Args, oper, INTOBJ_INT(i),
                                 kind1, kind2, kind3, kind4 );
            i++;
            res = CALL_4ARGS( method, arg1, arg2, arg3, arg4 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoConstructor5Args( <oper>, <a1>, <a2>, <a3>, <a4>, <a5> )
*/
Obj DoConstructor5Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 id2;
    Obj                 kind3;
    Obj                 id3;
    Obj                 kind4;
    Obj                 id4;
    Obj                 kind5;
    Obj                 id5;
    Obj *               cache;
    Obj                 method;
    Obj                 margs;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );  id2 = ID_TYPE( kind2 );
    kind3 = TYPE_OBJ(   arg3 );  id3 = ID_TYPE( kind3 );
    kind4 = TYPE_OBJ(   arg4 );  id4 = ID_TYPE( kind4 );
    kind5 = TYPE_OBJ(   arg5 );  id5 = ID_TYPE( kind5 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 5 ) );
    if      ( cache[6*0+1] == kind1
           && cache[6*0+2] == id2
           && cache[6*0+3] == id3
           && cache[6*0+4] == id4
           && cache[6*0+5] == id5 ) {
        method = cache[6*0+6];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[6*1+1] == kind1
           && cache[6*1+2] == id2
           && cache[6*1+3] == id3
           && cache[6*1+4] == id4
           && cache[6*1+5] == id5 ) {
        method = cache[6*1+6];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[6*2+1] == kind1
           && cache[6*2+2] == id2
           && cache[6*2+3] == id3
           && cache[6*2+4] == id4
           && cache[6*2+5] == id5 ) {
        method = cache[6*2+6];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[6*3+1] == kind1
           && cache[6*3+2] == id2
           && cache[6*3+3] == id3
           && cache[6*3+4] == id4
           && cache[6*3+5] == id5 ) {
        method = cache[6*3+6];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        method = CALL_6ARGS( Constructor5Args, oper,
                             kind1, kind2, kind3, kind4, kind5 );
        cache = ADDR_OBJ( CACHE_OPER( oper, 5 ) );
        cache[ 6*CacheIndex+1 ] = kind1;
        cache[ 6*CacheIndex+2 ] = id2;
        cache[ 6*CacheIndex+3 ] = id3;
        cache[ 6*CacheIndex+4 ] = id4;
        cache[ 6*CacheIndex+5 ] = id5;
        cache[ 6*CacheIndex+6 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,5));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_5ARGS( method, arg1, arg2, arg3, arg4, arg5 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            margs = NEW_PLIST( T_PLIST, 7 );
            SET_LEN_PLIST( margs, 7 );
            SET_ELM_PLIST( margs, 1, oper );
            SET_ELM_PLIST( margs, 2, INTOBJ_INT(i) );
            SET_ELM_PLIST( margs, 3, kind1 );
            SET_ELM_PLIST( margs, 4, kind2 );
            SET_ELM_PLIST( margs, 5, kind3 );
            SET_ELM_PLIST( margs, 6, kind4 );
            SET_ELM_PLIST( margs, 7, kind5 );
            method = CALL_XARGS( NextConstructor5Args, margs );
            i++;
            res = CALL_5ARGS( method, arg1, arg2, arg3, arg4, arg5 );
        }
    }

    /* return the result                                                   */
    return res;
}

/****************************************************************************
**
*f  DoConstructor6Args( <oper>, <a1>, <a2>, <a3>, <a4>, <a5>, <a6> )
*/
Obj DoConstructor6Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 id2;
    Obj                 kind3;
    Obj                 id3;
    Obj                 kind4;
    Obj                 id4;
    Obj                 kind5;
    Obj                 id5;
    Obj                 kind6;
    Obj                 id6;
    Obj *               cache;
    Obj                 method;
    Obj                 margs;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );  id2 = ID_TYPE( kind2 );
    kind3 = TYPE_OBJ(   arg3 );  id3 = ID_TYPE( kind3 );
    kind4 = TYPE_OBJ(   arg4 );  id4 = ID_TYPE( kind4 );
    kind5 = TYPE_OBJ(   arg5 );  id5 = ID_TYPE( kind5 );
    kind6 = TYPE_OBJ(   arg6 );  id6 = ID_TYPE( kind6 );

    /* try to find an applicable method in the cache                       */
    cache = ADDR_OBJ( CacheOper( oper, 6 ) );
    if      ( cache[7*0+1] == kind1
           && cache[7*0+2] == id2
           && cache[7*0+3] == id3
           && cache[7*0+4] == id4
           && cache[7*0+5] == id5
           && cache[7*0+6] == id6 ) {
        method = cache[7*0+7];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[7*1+1] == kind1
           && cache[7*1+2] == id2
           && cache[7*1+3] == id3
           && cache[7*1+4] == id4
           && cache[7*1+5] == id5
           && cache[7*1+6] == id6 ) {
        method = cache[7*1+7];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[7*2+1] == kind1
           && cache[7*2+2] == id2
           && cache[7*2+3] == id3
           && cache[7*2+4] == id4
           && cache[7*2+5] == id5
           && cache[7*2+6] == id6 ) {
        method = cache[7*2+7];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }
    else if ( cache[7*3+1] == kind1
           && cache[7*3+2] == id2
           && cache[7*3+3] == id3
           && cache[7*3+4] == id4
           && cache[7*3+5] == id5
           && cache[7*3+6] == id6 ) {
        method = cache[7*3+7];
#ifdef COUNT_OPERS
        OperationHit++;
#endif
    }

    /* otherwise try to find one in the list of methods                    */
    else {
        margs = NEW_PLIST( T_PLIST, 7 );
        SET_LEN_PLIST( margs, 7 );
        SET_ELM_PLIST( margs, 1, oper );
        SET_ELM_PLIST( margs, 2, kind1 );
        SET_ELM_PLIST( margs, 3, kind2 );
        SET_ELM_PLIST( margs, 4, kind3 );
        SET_ELM_PLIST( margs, 5, kind4 );
        SET_ELM_PLIST( margs, 6, kind5 );
        SET_ELM_PLIST( margs, 7, kind6 );
        method = CALL_XARGS( Constructor6Args, margs );
        cache = ADDR_OBJ( CACHE_OPER( oper, 6 ) );
        cache[ 7*CacheIndex+1 ] = kind1;
        cache[ 7*CacheIndex+2 ] = id2;
        cache[ 7*CacheIndex+3 ] = id3;
        cache[ 7*CacheIndex+4 ] = id4;
        cache[ 7*CacheIndex+5 ] = id5;
        cache[ 7*CacheIndex+6 ] = id6;
        cache[ 7*CacheIndex+7 ] = method;
        CacheIndex = (CacheIndex + 1) % 4;
        CHANGED_BAG(CACHE_OPER(oper,6));
#ifdef COUNT_OPERS
        OperationMiss++;
#endif
    }
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_6ARGS( method, arg1, arg2, arg3, arg4, arg5, arg6 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            margs = NEW_PLIST( T_PLIST, 8 );
            SET_LEN_PLIST( margs, 8 );
            SET_ELM_PLIST( margs, 1, oper );
            SET_ELM_PLIST( margs, 2, INTOBJ_INT(i) );
            SET_ELM_PLIST( margs, 3, kind1 );
            SET_ELM_PLIST( margs, 4, kind2 );
            SET_ELM_PLIST( margs, 5, kind3 );
            SET_ELM_PLIST( margs, 6, kind4 );
            SET_ELM_PLIST( margs, 7, kind5 );
            SET_ELM_PLIST( margs, 8, kind6 );
            method = CALL_XARGS( NextConstructor6Args, margs );
            i++;
            res = CALL_6ARGS( method, arg1, arg2, arg3, arg4, arg5, arg6 );
        }
    }

    /* return the result                                                   */
    return res;
}

/****************************************************************************
**
*f  DoConstructorXArgs( <oper>, ... )
*/
Obj DoConstructorXArgs (
    Obj                 self,
    Obj                 args )
{
    ErrorQuit("sorry: cannot yet have X argument constructors",0L,0L);
    return 0;
}


/****************************************************************************
**
*f  DoVerboseConstructor0Args( <oper> )
*/
Obj DoVerboseConstructor0Args (
    Obj                 oper )
{
    Obj                 res;
    Obj                 method;
    Int                 i;

    /* try to find one in the list of methods                              */
    method = CALL_1ARGS( VConstructor0Args, oper );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_0ARGS( method );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_2ARGS( NextVConstructor0Args, oper, INTOBJ_INT(i) );
            i++;
            res = CALL_0ARGS( method );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseConstructor1Args( <oper>, <a1> )
*/
Obj DoVerboseConstructor1Args (
    Obj                 oper,
    Obj                 arg1 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );

    /* try to find one in the list of methods                              */
    method = CALL_2ARGS( VConstructor1Args, oper, kind1 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_1ARGS( method, arg1 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_3ARGS( NextVConstructor1Args, oper, INTOBJ_INT(i),
                                 kind1 );
            i++;
            res = CALL_1ARGS( method, arg1 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseConstructor2Args( <oper>, <a1>, <a2> )
*/
Obj DoVerboseConstructor2Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );

    /* try to find one in the list of methods                              */
    method = CALL_3ARGS( VConstructor2Args, oper, kind1, kind2 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_2ARGS( method, arg1, arg2 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_4ARGS( NextVConstructor2Args, oper, INTOBJ_INT(i),
                                 kind1, kind2 );
            i++;
            res = CALL_2ARGS( method, arg1, arg2 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseConstructor3Args( <oper>, <a1>, <a2>, <a3> )
*/
Obj DoVerboseConstructor3Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 kind3;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );
    kind3 = TYPE_OBJ(   arg3 );

    /* try to find one in the list of methods                              */
    method = CALL_4ARGS( VConstructor3Args, oper, kind1, kind2, kind3 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_3ARGS( method, arg1, arg2, arg3 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_5ARGS( NextVConstructor3Args, oper, INTOBJ_INT(i),
                                 kind1, kind2, kind3 );
            i++;
            res = CALL_3ARGS( method, arg1, arg2, arg3 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseConstructor4Args( <oper>, <a1>, <a2>, <a3>, <a4> )
*/
Obj DoVerboseConstructor4Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 kind3;
    Obj                 kind4;
    Obj                 method;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );
    kind3 = TYPE_OBJ(   arg3 );
    kind4 = TYPE_OBJ(   arg4 );

    /* try to find one in the list of methods                              */
    method = CALL_5ARGS( VConstructor4Args, oper, kind1, kind2, kind3, kind4 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_4ARGS( method, arg1, arg2, arg3, arg4 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            method = CALL_6ARGS( NextVConstructor4Args, oper, INTOBJ_INT(i),
                                 kind1, kind2, kind3, kind4 );
            i++;
            res = CALL_4ARGS( method, arg1, arg2, arg3, arg4 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseConstructor5Args( <oper>, <a1>, <a2>, <a3>, <a4>, <a5> )
*/
Obj DoVerboseConstructor5Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 kind3;
    Obj                 kind4;
    Obj                 kind5;
    Obj                 method;
    Obj                 margs;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );
    kind3 = TYPE_OBJ(   arg3 );
    kind4 = TYPE_OBJ(   arg4 );
    kind5 = TYPE_OBJ(   arg5 );

    /* try to find one in the list of methods                              */
    method = CALL_6ARGS( VConstructor5Args, oper, kind1, kind2, kind3, kind4,
                         kind5 );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_5ARGS( method, arg1, arg2, arg3, arg4, arg5 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            margs = NEW_PLIST( T_PLIST, 7 );
            SET_LEN_PLIST( margs, 7 );
            SET_ELM_PLIST( margs, 1, oper );
            SET_ELM_PLIST( margs, 2, INTOBJ_INT(i) );
            SET_ELM_PLIST( margs, 3, kind1 );
            SET_ELM_PLIST( margs, 4, kind2 );
            SET_ELM_PLIST( margs, 5, kind3 );
            SET_ELM_PLIST( margs, 6, kind4 );
            SET_ELM_PLIST( margs, 7, kind5 );
            method = CALL_XARGS( NextVConstructor5Args, margs );
            i++;
            res = CALL_5ARGS( method, arg1, arg2, arg3, arg4, arg5 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseConstructor6Args( <oper>, <a1>, <a2>, <a3>, <a4>, <a5>, <a6> )
*/
Obj DoVerboseConstructor6Args (
    Obj                 oper,
    Obj                 arg1,
    Obj                 arg2,
    Obj                 arg3,
    Obj                 arg4,
    Obj                 arg5,
    Obj                 arg6 )
{
    Obj                 res;
    Obj                 kind1;
    Obj                 kind2;
    Obj                 kind3;
    Obj                 kind4;
    Obj                 kind5;
    Obj                 kind6;
    Obj                 method;
    Obj                 margs;
    Int                 i;

    /* get the kinds of the arguments                                      */
    if ( ! IS_OPERATION(arg1) ) {
        ErrorQuit("<arg1> must be an operation",0L,0L);
        return 0;
    }
    kind1 = FLAGS_FILT( arg1 );
    kind2 = TYPE_OBJ(   arg2 );
    kind3 = TYPE_OBJ(   arg3 );
    kind4 = TYPE_OBJ(   arg4 );
    kind5 = TYPE_OBJ(   arg5 );
    kind6 = TYPE_OBJ(   arg6 );

    /* try to find one in the list of methods                              */
    margs = NEW_PLIST( T_PLIST, 7 );
    SET_LEN_PLIST( margs, 7 );
    SET_ELM_PLIST( margs, 1, oper );
    SET_ELM_PLIST( margs, 2, kind1 );
    SET_ELM_PLIST( margs, 3, kind2 );
    SET_ELM_PLIST( margs, 4, kind3 );
    SET_ELM_PLIST( margs, 5, kind4 );
    SET_ELM_PLIST( margs, 6, kind5 );
    SET_ELM_PLIST( margs, 7, kind6 );
    method = CALL_XARGS( VConstructor6Args, margs );
    if ( method == 0 )  {
        ErrorQuit( "no method returned", 0L, 0L );
    }

    /* call this method                                                    */
    res = CALL_6ARGS( method, arg1, arg2, arg3, arg4, arg5, arg6 );

    /* try until a method doesn't give up                                  */
    if ( res == TRY_NEXT_METHOD ) {
        i = 1;
        while ( res == TRY_NEXT_METHOD ) {
#ifdef COUNT_OPERS
            OperationNext++;
#endif
            margs = NEW_PLIST( T_PLIST, 8 );
            SET_LEN_PLIST( margs, 8 );
            SET_ELM_PLIST( margs, 1, oper );
            SET_ELM_PLIST( margs, 2, INTOBJ_INT(i) );
            SET_ELM_PLIST( margs, 3, kind1 );
            SET_ELM_PLIST( margs, 4, kind2 );
            SET_ELM_PLIST( margs, 5, kind3 );
            SET_ELM_PLIST( margs, 6, kind4 );
            SET_ELM_PLIST( margs, 7, kind5 );
            SET_ELM_PLIST( margs, 8, kind6 );
            method = CALL_XARGS( NextVConstructor6Args, margs );
            i++;
            res = CALL_6ARGS( method, arg1, arg2, arg3, arg4, arg5, arg6 );
        }
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*f  DoVerboseConstructorXArgs( <oper>, ... )
*/
Obj DoVerboseConstructorXArgs (
    Obj                 self,
    Obj                 args )
{
    ErrorQuit("sorry: cannot yet have X argument constructors",0L,0L);
    return 0;
}


/****************************************************************************
**
*f  NewConstructor( <name>, <narg>, <nams>, <hdlr> )
*/
Obj NewConstructor (
    Obj                 name,
    Int                 narg,
    Obj                 nams,
    ObjFunc             hdlr )
{
    Obj                 oper;
#ifdef  PREALLOCATE_TABLES
    Obj                 cache;
    Obj                 methods;
    UInt                i;
#endif

    /* create the function                                                 */
    oper = NewFunctionT( T_FUNCTION, SIZE_OPER, name, narg, nams, hdlr );

    /* enter the handlers                                                  */
    if ( narg == -1 ) {
        HDLR_FUNC(oper,0) = DoConstructor0Args;
        HDLR_FUNC(oper,1) = DoConstructor1Args;
        HDLR_FUNC(oper,2) = DoConstructor2Args;
        HDLR_FUNC(oper,3) = DoConstructor3Args;
        HDLR_FUNC(oper,4) = DoConstructor4Args;
        HDLR_FUNC(oper,5) = DoConstructor5Args;
        HDLR_FUNC(oper,6) = DoConstructor6Args;
        HDLR_FUNC(oper,7) = DoConstructorXArgs;
    }

    /*N 1996/06/06 mschoene this should not be done here                   */
    FLAG1_FILT(oper) = INT_INTOBJ(0);
    FLAG2_FILT(oper) = INT_INTOBJ(0);
    FLAGS_FILT(oper) = False;
    SETTR_FILT(oper) = False;
    TESTR_FILT(oper) = False;
    
#ifdef  PREALLOCATE_TABLES
    /* create caches and methods lists                                     */
    for ( i = 0; i <= 7; i++ ) {
        methods = NEW_PLIST( T_PLIST, 0 );
        METHS_OPER( oper, i ) = methods;
        cache = NEW_PLIST( T_PLIST, (i < 7 ? 4 * (i+1) : 4 * (1+1)) );
        CACHE_OPER( oper, i ) = cache;
        CHANGED_BAG(oper);
    }
#endif

    /* return constructor                                                  */
    return oper;
}


/****************************************************************************
**
*f  NewConstructorC( <name>, <narg>, <nams>, <hdlr> )
*/
Obj NewConstructorC (
    Char *              name,
    Int                 narg,
    Char *              nams,
    ObjFunc             hdlr )
{
    Obj                 oper;
#ifdef  PREALLOCATE_TABLES
    Obj                 cache;
    Obj                 methods;
    UInt                i;
#endif

    /* create the function                                                 */
    oper = NewFunctionCT( T_FUNCTION, SIZE_OPER, name, narg, nams, hdlr );

    /* enter the handlers                                                  */
    if ( narg == -1 ) {
        HDLR_FUNC(oper,0) = DoConstructor0Args;
        HDLR_FUNC(oper,1) = DoConstructor1Args;
        HDLR_FUNC(oper,2) = DoConstructor2Args;
        HDLR_FUNC(oper,3) = DoConstructor3Args;
        HDLR_FUNC(oper,4) = DoConstructor4Args;
        HDLR_FUNC(oper,5) = DoConstructor5Args;
        HDLR_FUNC(oper,6) = DoConstructor6Args;
        HDLR_FUNC(oper,7) = DoConstructorXArgs;
    }

    /*N 1996/06/06 mschoene this should not be done here                   */
    FLAG1_FILT(oper) = INT_INTOBJ(0);
    FLAG2_FILT(oper) = INT_INTOBJ(0);
    FLAGS_FILT(oper) = False;
    SETTR_FILT(oper) = False;
    TESTR_FILT(oper) = False;
    
#ifdef  PREALLOCATE_TABLES
    /* create caches and methods lists                                     */
    for ( i = 0; i <= 7; i++ ) {
        methods = NEW_PLIST( T_PLIST, 0 );
        METHS_OPER( oper, i ) = methods;
        cache = NEW_PLIST( T_PLIST, (i < 7 ? 4 * (i+1) : 4 * (1+1)) );
        CACHE_OPER( oper, i ) = cache;
        CHANGED_BAG(oper);
    }
#endif

    /* return constructor                                                  */
    return oper;
}


/****************************************************************************
**
*f  NewConstructorHandler( <name> )
*/
Obj NewConstructorFunc;

Obj NewConstructorHandler (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewConstructor( <name> )",0L,0L);
        return 0;
    }

    /* make the new constructor                                            */
    return NewConstructor( name, -1L, (Obj)0, DoConstructorXArgs );
}


/****************************************************************************
**

*F  NewAttribute( <name> )  . . . . . . . . . . . . . .  make a new attribute
*/


/****************************************************************************
**
*f  DoTestAttribute( <attr>, <obj> )
*/
Obj DoTestAttribute (
    Obj                 self,
    Obj                 obj )
{
    Int                 flag2;
    Obj                 kind;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get kind of the object and its flags                                */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );

    /* if the value of the property is already known, return 'true'        */
    if ( flag2 <= LEN_FLAGS( flags ) && ELM_FLAGS( flags, flag2 ) == True ) {
        return True;
    }
    
    /* return the 'false'                                                  */
    return False;
}


/****************************************************************************
**
*f  DoAttribute( <attr>, <obj> )
*/
#define DoSetAttribute  DoOperation2Args

Obj DoAttribute (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag2;
    Obj                 kind;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get kind of the object and its flags                                */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );

    /* if the value of the property is already known, simply return it     */
    if ( flag2 <= LEN_FLAGS( flags ) && ELM_FLAGS( flags, flag2 ) == True ) {
        return DoOperation1Args( self, obj );
    }
    
    /* call the operation to compute the value                             */
    val = CopyObj( DoOperation1Args( self, obj ), 0 );
    
    /* set the value (but not for internal objects)                        */
    if      ( TNUM_OBJ( obj ) == T_COMOBJ ) {
        DoSetAttribute( SETTR_FILT(self), obj, val );
    }
    else if ( TNUM_OBJ( obj ) == T_POSOBJ ) {
        DoSetAttribute( SETTR_FILT(self), obj, val );
    }
    else if ( TNUM_OBJ( obj ) == T_DATOBJ ) {
        DoSetAttribute( SETTR_FILT(self), obj, val );
    }
    
    /* return the value                                                    */
    return val;    
}


/****************************************************************************
**
*f  DoVerboseAttribute( <attr>, <obj> )
*/
#define DoVerboseSetAttribute  DoVerboseOperation2Args

Obj DoVerboseAttribute (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag2;
    Obj                 kind;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get kind of the object and its flags                                */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );

    /* if the value of the property is already known, simply return it     */
    if ( flag2 <= LEN_FLAGS( flags ) && ELM_FLAGS( flags, flag2 ) == True ) {
        return DoVerboseOperation1Args( self, obj );
    }
    
    /* call the operation to compute the value                             */
    val = CopyObj( DoVerboseOperation1Args( self, obj ), 0 );
    
    /* set the value (but not for internal objects)                        */
    if      ( TNUM_OBJ( obj ) == T_COMOBJ ) {
        DoVerboseSetAttribute( SETTR_FILT(self), obj, val );
    }
    else if ( TNUM_OBJ( obj ) == T_POSOBJ ) {
        DoVerboseSetAttribute( SETTR_FILT(self), obj, val );
    }
    else if ( TNUM_OBJ( obj ) == T_DATOBJ ) {
        DoVerboseSetAttribute( SETTR_FILT(self), obj, val );
    }
    
    /* return the value                                                    */
    return val;    
}


/****************************************************************************
**
*f  DoMutableAttribute( <attr>, <obj> )
*/
Obj DoMutableAttribute (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag2;
    Obj                 kind;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get kind of the object and its flags                                */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );

    /* if the value of the property is already known, simply return it     */
    if ( flag2 <= LEN_FLAGS( flags ) && ELM_FLAGS( flags, flag2 ) == True ) {
        return DoOperation1Args( self, obj );
    }
    
    /* call the operation to compute the value                             */
    val = DoOperation1Args( self, obj );
    
    /* set the value (but not for internal objects)                        */
    if      ( TNUM_OBJ( obj ) == T_COMOBJ ) {
        DoSetAttribute( SETTR_FILT(self), obj, val );
    }
    else if ( TNUM_OBJ( obj ) == T_POSOBJ ) {
        DoSetAttribute( SETTR_FILT(self), obj, val );
    }
    else if ( TNUM_OBJ( obj ) == T_DATOBJ ) {
        DoSetAttribute( SETTR_FILT(self), obj, val );
    }
    
    /* return the value                                                    */
    return val;    
}


/****************************************************************************
**
*f  DoVerboseMutableAttribute( <attr>, <obj> )
*/
Obj DoVerboseMutableAttribute (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag2;
    Obj                 kind;
    Obj                 flags;

    /* get the flag for the tester                                         */
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get kind of the object and its flags                                */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );

    /* if the value of the property is already known, simply return it     */
    if ( flag2 <= LEN_FLAGS( flags ) && ELM_FLAGS( flags, flag2 ) == True ) {
        return DoVerboseOperation1Args( self, obj );
    }
    
    /* call the operation to compute the value                             */
    val = DoVerboseOperation1Args( self, obj );
    
    /* set the value (but not for internal objects)                        */
    if      ( TNUM_OBJ( obj ) == T_COMOBJ ) {
        DoVerboseSetAttribute( SETTR_FILT(self), obj, val );
    }
    else if ( TNUM_OBJ( obj ) == T_POSOBJ ) {
        DoVerboseSetAttribute( SETTR_FILT(self), obj, val );
    }
    else if ( TNUM_OBJ( obj ) == T_DATOBJ ) {
        DoVerboseSetAttribute( SETTR_FILT(self), obj, val );
    }
    
    /* return the value                                                    */
    return val;    
}


/****************************************************************************
**
*f  NewAttribute( <name>, <narg>, <nams>, <hdlr> )
*/
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
    Obj                 flags;
    Obj                 fname;
    
    flag2 = ++CountFlags;

    fname = NEW_STRING( GET_LEN_STRING(name) + 8 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "Setter(", 7 );
    SyStrncat( CSTR_STRING(fname), CSTR_STRING(name), GET_LEN_STRING(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    setter = NewOperation( fname, 2L, 0L, DoSetAttribute );
    FLAG1_FILT(setter)  = INTOBJ_INT( 0 );
    FLAG2_FILT(setter)  = INTOBJ_INT( flag2 );
    CHANGED_BAG(setter);

    fname = NEW_STRING( GET_LEN_STRING(name) + 8 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "Tester(", 7 );
    SyStrncat( CSTR_STRING(fname), CSTR_STRING(name), GET_LEN_STRING(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    tester = NewFunctionT( T_FUNCTION, SIZE_OPER, fname, 1L, 0L,
                           DoTestAttribute );    
    FLAG1_FILT(tester)  = INTOBJ_INT( 0 );
    FLAG2_FILT(tester)  = INTOBJ_INT( flag2 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag2) );
    SET_LEN_FLAGS( flags, flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    FLAGS_FILT(tester)  = flags;
    SETTR_FILT(tester)  = 0;
    TESTR_FILT(tester)  = ReturnTrueFilter;
    CHANGED_BAG(tester);

    getter = NewOperation( name, 1L, nams, (hdlr ? hdlr : DoAttribute) );
    FLAG1_FILT(getter)  = INTOBJ_INT( 0 );
    FLAG2_FILT(getter)  = INTOBJ_INT( flag2 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag2) );
    SET_LEN_FLAGS( flags, flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    FLAGS_FILT(tester)  = flags;
    SETTR_FILT(getter)  = setter;
    TESTR_FILT(getter)  = tester;
    CHANGED_BAG(getter);
    
    return getter;    
}


/****************************************************************************
**
*f  NewAttributeC( <name>, <narg>, <nams>, <hdlr> )
*/
Obj NewAttributeC (
    Char *              name,
    Int                 narg,
    Char *              nams,
    ObjFunc             hdlr )
{
    Obj                 getter;
    Obj                 setter;
    Obj                 tester;
    Int                 flag2;
    Obj                 flags;
    Obj                 fname;
    
    flag2 = ++CountFlags;

    fname = NEW_STRING( SyStrlen(name) + 8 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "Setter(", 7 );
    SyStrncat( CSTR_STRING(fname), name, SyStrlen(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    setter = NewOperation( fname, 2L, 0L, DoSetAttribute );
    FLAG1_FILT(setter)  = INTOBJ_INT( 0 );
    FLAG2_FILT(setter)  = INTOBJ_INT( flag2 );
    CHANGED_BAG(setter);

    fname = NEW_STRING( SyStrlen(name) + 8 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "Tester(", 7 );
    SyStrncat( CSTR_STRING(fname), name, SyStrlen(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    tester = NewFunctionT( T_FUNCTION, SIZE_OPER, fname, 1L, 0L,
                           DoTestAttribute );    
    FLAG1_FILT(tester)  = INTOBJ_INT( 0 );
    FLAG2_FILT(tester)  = INTOBJ_INT( flag2 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag2) );
    SET_LEN_FLAGS( flags, flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    FLAGS_FILT(tester)  = flags;
    SETTR_FILT(tester)  = 0;
    TESTR_FILT(tester)  = ReturnTrueFilter;
    CHANGED_BAG(tester);

    getter = NewOperationC( name, 1L, nams, (hdlr ? hdlr : DoAttribute) );
    FLAG1_FILT(getter)  = INTOBJ_INT( 0 );
    FLAG2_FILT(getter)  = INTOBJ_INT( flag2 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag2) );
    SET_LEN_FLAGS( flags, flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    FLAGS_FILT(tester)  = flags;
    SETTR_FILT(getter)  = setter;
    TESTR_FILT(getter)  = tester;
    CHANGED_BAG(getter);
    
    return getter;    
}


/****************************************************************************
**
*f  NewAttributeHandler( <name> )
*/
Obj NewAttributeFunc;

Obj NewAttributeHandler (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewAttribute( <name> )",0L,0L);
        return 0;
    }

    /* make the new operation                                              */
    return NewAttribute( name, 1L, (Obj)0, DoAttribute );
}


/****************************************************************************
**
*f  NewMutableAttributeHandler( <name> )
*/
Obj NewMutableAttributeFunc;

Obj NewMutableAttributeHandler (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewMutableAttribute( <name> )",0L,0L);
        return 0;
    }

    /* make the new operation                                              */
    return NewAttribute( name, 1L, (Obj)0, DoMutableAttribute );
}


/****************************************************************************
**

*F  NewProperty( <name> ) . . . . . . . . . . . . . . . . make a new property
*/
Obj SET_FILTER_OBJ;

Obj RESET_FILTER_OBJ;


/****************************************************************************
**
*f  DoTestProperty( <prop>, <obj> )
*/
Obj DoTestProperty (
    Obj                 self,
    Obj                 obj )
{
    Int                 flag1;
    Int                 flag2;
    Obj                 kind;
    Obj                 flags;

    /* get the flags for the getter and the tester                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get kind of the object and its flags                                */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );

    /* if the value of the property is already known, return 'true'        */
    if ( flag2 <= LEN_FLAGS( flags ) && ELM_FLAGS( flags, flag2 ) == True ) {
        return True;
    }
    
    /* otherwise return 'false'                                            */
    return False;
}


/****************************************************************************
**
*f  DoSetProperty( <prop>, <obj>, <val> )
*/
Obj DoSetProperty (
    Obj                 self,
    Obj                 obj,
    Obj                 val )
{
    Int                 flag1;
    Int                 flag2;
    Obj                 kind;
    Obj                 flags;

    /* get the flags for the getter and the tester                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get kind of the object and its flags                                */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );

    /* if the value of the property is already known, compare it           */
    if ( flag2 <= LEN_FLAGS( flags ) && ELM_FLAGS( flags, flag2 ) == True ) {
        if ( val == ELM_FLAGS( flags, flag1 ) ) {
            return 0;
        }
        else {
            ErrorReturnVoid(
                "value property is already set the other way",
                0L, 0L,
                "you can return to set it anyhow" );
        }
    }

    /* set the value                                                       */
    /*N 1996/06/28 mschoene <self> is the <setter> here, not the <getter>! */
    /*N 1996/06/28 mschoene see hack below                                 */
    if      ( TNUM_OBJ( obj ) == T_COMOBJ ) {
        flags = (val == True ? self : TESTR_FILT(self));
        CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
    }
    else if ( TNUM_OBJ( obj ) == T_POSOBJ ) {
        flags = (val == True ? self : TESTR_FILT(self));
        CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
    }
    else if ( TNUM_OBJ( obj ) == T_DATOBJ ) {
        flags = (val == True ? self : TESTR_FILT(self));
        CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
    }
    else {
        ErrorReturnVoid(
            "value cannot be set for internal objects",
            0L, 0L,
            "you can return without setting it" );
    }

    /* return the value                                                    */
    return 0;
}


/****************************************************************************
**
*f  DoProperty( <prop>, <obj> )
*/
Obj DoProperty (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag1;
    Int                 flag2;
    Obj                 kind;
    Obj                 flags;

    /* get the flags for the getter and the tester                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get kind of the object and its flags                                */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );

    /* if the value of the property is already known, simply return it     */
    if ( flag2 <= LEN_FLAGS( flags ) && ELM_FLAGS( flags, flag2 ) == True ) {
        return ELM_FLAGS( flags, flag1 );
    }

    /* call the operation to compute the value                             */
    val = DoOperation1Args( self, obj );
    
    /* set the value (but not for internal objects)                        */
    if ( ! IS_MUTABLE_OBJ(obj) ) {
        if      ( TNUM_OBJ( obj ) == T_COMOBJ ) {
            flags = (val == True ? self : TESTR_FILT(self));
            CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
        }
        else if ( TNUM_OBJ( obj ) == T_POSOBJ ) {
            flags = (val == True ? self : TESTR_FILT(self));
            CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
        }
        else if ( TNUM_OBJ( obj ) == T_DATOBJ ) {
            flags = (val == True ? self : TESTR_FILT(self));
            CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
        }
    }

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*f  DoVerboseProperty( <prop>, <obj> )
*/
Obj DoVerboseProperty (
    Obj                 self,
    Obj                 obj )
{
    Obj                 val;
    Int                 flag1;
    Int                 flag2;
    Obj                 kind;
    Obj                 flags;

    /* get the flags for the getter and the tester                         */
    flag1 = INT_INTOBJ( FLAG1_FILT( self ) );
    flag2 = INT_INTOBJ( FLAG2_FILT( self ) );

    /* get kind of the object and its flags                                */
    kind  = TYPE_OBJ( obj );
    flags = FLAGS_TYPE( kind );

    /* if the value of the property is already known, simply return it     */
    if ( flag2 <= LEN_FLAGS( flags ) && ELM_FLAGS( flags, flag2 ) == True ) {
        return ELM_FLAGS( flags, flag1 );
    }

    /* call the operation to compute the value                             */
    val = DoVerboseOperation1Args( self, obj );
    
    /* set the value (but not for internal objects)                        */
    if      ( TNUM_OBJ( obj ) == T_COMOBJ ) {
        flags = (val == True ? self : TESTR_FILT(self));
        CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
    }
    else if ( TNUM_OBJ( obj ) == T_POSOBJ ) {
        flags = (val == True ? self : TESTR_FILT(self));
        CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
    }
    else if ( TNUM_OBJ( obj ) == T_DATOBJ ) {
        flags = (val == True ? self : TESTR_FILT(self));
        CALL_2ARGS( SET_FILTER_OBJ, obj, flags );
    }

    /* return the value                                                    */
    return val;
}


/****************************************************************************
**
*f  NewProperty( <name>, <narg>, <nams>, <hdlr> )
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
    Obj                 fname;
    
    flag1 = ++CountFlags;
    flag2 = ++CountFlags;

    fname = NEW_STRING( GET_LEN_STRING(name) + 8 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "Setter(", 7 );
    SyStrncat( CSTR_STRING(fname), CSTR_STRING(name), GET_LEN_STRING(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    setter = NewOperation( fname, 2L, 0L, DoSetProperty );
    FLAG1_FILT(setter)  = INTOBJ_INT( flag1 );
    FLAG2_FILT(setter)  = INTOBJ_INT( flag2 );
    CHANGED_BAG(setter);

    fname = NEW_STRING( GET_LEN_STRING(name) + 8 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "Tester(", 7 );
    SyStrncat( CSTR_STRING(fname), CSTR_STRING(name), GET_LEN_STRING(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    tester = NewFunctionT( T_FUNCTION, SIZE_OPER, fname, 1L, 0L,
                           DoTestProperty );    
    FLAG1_FILT(tester)  = INTOBJ_INT( flag1 );
    FLAG2_FILT(tester)  = INTOBJ_INT( flag2 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag2) );
    SET_LEN_FLAGS( flags, flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    FLAGS_FILT(tester)  = flags;
    SETTR_FILT(tester)  = 0;
    TESTR_FILT(tester)  = ReturnTrueFilter;
    CHANGED_BAG(tester);

    getter = NewOperation( name, 1L, nams, (hdlr ? hdlr : DoProperty) );
    FLAG1_FILT(getter)  = INTOBJ_INT( flag1 );
    FLAG2_FILT(getter)  = INTOBJ_INT( flag2 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag2) );
    SET_LEN_FLAGS( flags, flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    SET_ELM_FLAGS( flags, flag1, True );
    FLAGS_FILT(getter)  = flags;
    SETTR_FILT(getter)  = setter;
    TESTR_FILT(getter)  = tester;
    CHANGED_BAG(getter);

    /*N 1996/06/28 mschoene bad hack see comment in <setter>               */
    FLAGS_FILT(setter)  = flags;
    SETTR_FILT(setter)  = setter;
    TESTR_FILT(setter)  = tester;

    /* return the getter                                                   */
    return getter;    
}


/****************************************************************************
**
*f  NewPropertyC( <name>, <narg>, <nams>, <hdlr> )
*/
Obj NewPropertyC (
    Char *              name,
    Int                 narg,
    Char *              nams,
    ObjFunc             hdlr )
{
    Obj                 getter;
    Obj                 setter;
    Obj                 tester;
    Int                 flag1;
    Int                 flag2;
    Obj                 flags;
    Obj                 fname;
    
    flag1 = ++CountFlags;
    flag2 = ++CountFlags;

    fname = NEW_STRING( SyStrlen(name) + 8 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "Setter(", 7 );
    SyStrncat( CSTR_STRING(fname), name, SyStrlen(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    setter = NewOperation( fname, 2L, 0L, DoSetProperty );
    FLAG1_FILT(setter)  = INTOBJ_INT( flag1 );
    FLAG2_FILT(setter)  = INTOBJ_INT( flag2 );
    CHANGED_BAG(setter);

    fname = NEW_STRING( SyStrlen(name) + 8 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "Tester(", 7 );
    SyStrncat( CSTR_STRING(fname), name, SyStrlen(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    tester = NewFunctionT( T_FUNCTION, SIZE_OPER, fname, 1L, 0L,
                           DoTestProperty );    
    FLAG1_FILT(tester)  = INTOBJ_INT( flag1 );
    FLAG2_FILT(tester)  = INTOBJ_INT( flag2 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag2) );
    SET_LEN_FLAGS( flags, flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    FLAGS_FILT(tester)  = flags;
    SETTR_FILT(tester)  = 0;
    TESTR_FILT(tester)  = ReturnTrueFilter;
    CHANGED_BAG(tester);

    getter = NewOperationC( name, 1L, nams, (hdlr ? hdlr : DoProperty) );
    FLAG1_FILT(getter)  = INTOBJ_INT( flag1 );
    FLAG2_FILT(getter)  = INTOBJ_INT( flag2 );
    flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(flag2) );
    SET_LEN_FLAGS( flags, flag2 );
    SET_ELM_FLAGS( flags, flag2, True );
    SET_ELM_FLAGS( flags, flag1, True );
    FLAGS_FILT(getter)  = flags;
    SETTR_FILT(getter)  = setter;
    TESTR_FILT(getter)  = tester;
    CHANGED_BAG(getter);
    
    /*N 1996/06/28 mschoene bad hack see comment in <setter>               */
    FLAGS_FILT(setter)  = flags;
    SETTR_FILT(setter)  = setter;
    TESTR_FILT(setter)  = tester;

    /* return the getter                                                   */
    return getter;    
}


/****************************************************************************
**
*f  NewPropertyHandler( <self>, <name> )
*/
Obj NewPropertyFunc;

Obj NewPropertyHandler (
    Obj                 self,
    Obj                 name )
{
    /* check the argument                                                  */
    if ( ! IsStringConv(name) ) {
        ErrorQuit("usage: NewProperty( <name> )",0L,0L);
        return 0;
    }

    /* make the new operation                                              */
    return NewProperty( name, 1L, (Obj)0, DoProperty );
}


/****************************************************************************
**

*F  FuncSetterFunction( <self>, <name> )
*/
Obj SetterFunctionFunc;

Obj DoSetterFunction (
    Obj                 self,
    Obj                 obj,
    Obj                 value )
{
    Obj                 tmp;
    Obj                 tester;
    Obj                 flags;
    UInt                flag2;
    Obj                 kind;

    if ( TNUM_OBJ(obj) != T_COMOBJ ) {
        ErrorQuit( "<obj> must be an component object", 0L, 0L );
        return 0L;
    }

    /* if the attribute is already there *do not* chage it                 */
    tmp = ENVI_FUNC(self);
    tester = ELM_PLIST( tmp, 2 );
    flag2  = INT_INTOBJ( FLAG2_FILT(tester) );
    kind   = TYPE_OBJ(obj);
    flags  = FLAGS_TYPE(kind);
    if ( flag2 <= LEN_FLAGS(flags) && ELM_FLAGS(flags,flag2) == True ) {
        return 0;
    }

    /* set the value                                                       */
    AssPRec( obj, INT_INTOBJ(ELM_PLIST(tmp,1)), CopyObj(value,0) );
    CALL_2ARGS( SET_FILTER_OBJ, obj, tester );
    return 0;
}


Obj FuncSetterFunction (
    Obj                 self,
    Obj                 name,
    Obj                 filter )
{
    Obj                 func;
    Obj                 fname;
    Obj                 tmp;

    fname = NEW_STRING( GET_LEN_STRING(name) + 12 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "SetterFunc(", 11 );
    SyStrncat( CSTR_STRING(fname), CSTR_STRING(name), GET_LEN_STRING(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    func = NewFunctionCT( T_FUNCTION, SIZE_FUNC, CSTR_STRING(fname), 2,
                         "object, value", DoSetterFunction );
    tmp = NEW_PLIST( T_PLIST, 2 );
    SET_LEN_PLIST( tmp, 2 );
    SET_ELM_PLIST( tmp, 1, INTOBJ_INT( RNamObj(name) ) );
    SET_ELM_PLIST( tmp, 2, filter );
    ENVI_FUNC(func) = tmp;
    return func;
}


/****************************************************************************
**
*F  FuncGetterFunction( <self>, <name> )
*/
Obj GetterFunctionFunc;

Obj DoGetterFunction (
    Obj                 self,
    Obj                 obj )
{
    if ( TNUM_OBJ(obj) != T_COMOBJ ) {
        ErrorQuit( "<obj> must be an component object", 0L, 0L );
        return 0L;
    }
    return ElmPRec( obj, INT_INTOBJ(ENVI_FUNC(self)) );
}


Obj FuncGetterFunction (
    Obj                 self,
    Obj                 name )
{
    Obj                 func;
    Obj                 fname;

    fname = NEW_STRING( GET_LEN_STRING(name) + 12 );
    RetypeBag( fname, IMMUTABLE_TNUM(TNUM_OBJ(fname)) );
    SyStrncat( CSTR_STRING(fname), "GetterFunc(", 11 );
    SyStrncat( CSTR_STRING(fname), CSTR_STRING(name), GET_LEN_STRING(name) );
    SyStrncat( CSTR_STRING(fname), ")", 1 );
    func = NewFunctionCT( T_FUNCTION, SIZE_FUNC, CSTR_STRING(fname), 1,
                         "object, value", DoGetterFunction );
    ENVI_FUNC(func) = INTOBJ_INT( RNamObj(name) );
    return func;
}


/****************************************************************************
**

*F  ChangeDoOperations( <oper>, <verb> )
*/
static void * TabSilentVerboseOperations[] =
{
    (void*) DoOperation0Args,   (void*) DoVerboseOperation0Args,
    (void*) DoOperation1Args,   (void*) DoVerboseOperation1Args,
    (void*) DoOperation2Args,   (void*) DoVerboseOperation2Args,
    (void*) DoOperation3Args,   (void*) DoVerboseOperation3Args,
    (void*) DoOperation4Args,   (void*) DoVerboseOperation4Args,
    (void*) DoOperation5Args,   (void*) DoVerboseOperation5Args,
    (void*) DoOperation6Args,   (void*) DoVerboseOperation6Args,
    (void*) DoOperationXArgs,   (void*) DoVerboseOperationXArgs,
    (void*) DoConstructor0Args, (void*) DoVerboseConstructor0Args,
    (void*) DoConstructor1Args, (void*) DoVerboseConstructor1Args,
    (void*) DoConstructor2Args, (void*) DoVerboseConstructor2Args,
    (void*) DoConstructor3Args, (void*) DoVerboseConstructor3Args,
    (void*) DoConstructor4Args, (void*) DoVerboseConstructor4Args,
    (void*) DoConstructor5Args, (void*) DoVerboseConstructor5Args,
    (void*) DoConstructor6Args, (void*) DoVerboseConstructor6Args,
    (void*) DoConstructorXArgs, (void*) DoVerboseConstructorXArgs,
    (void*) DoAttribute,        (void*) DoVerboseAttribute,
    (void*) DoMutableAttribute, (void*) DoVerboseMutableAttribute,
    (void*) DoProperty,         (void*) DoVerboseProperty,
    0,                          0
};


void ChangeDoOperations (
    Obj                 oper,
    Int                 verb )
{
    Int                 i;
    Int                 j;

    /* be verbose                                                          */
    if ( verb ) {

        /* catch infix operations                                          */
        if ( oper == EqOper   )  { InstallEqObject(1);   }
        if ( oper == LtOper   )  { InstallLtObject(1);   }
        if ( oper == InOper   )  { InstallInObject(1);   }
        if ( oper == SumOper  )  { InstallSumObject(1);  }
        if ( oper == DiffOper )  { InstallDiffObject(1); }
        if ( oper == ProdOper )  { InstallProdObject(1); }
        if ( oper == QuoOper  )  { InstallQuoObject(1);  }
        if ( oper == LQuoOper )  { InstallLQuoObject(1); }
        if ( oper == PowOper  )  { InstallPowObject(1);  }
        if ( oper == CommOper )  { InstallCommObject(1); }
        if ( oper == ModOper  )  { InstallModObject(1);  }
        if ( oper == InvAttr  )  { InstallInvObject(1);  }
        if ( oper == OneAttr  )  { InstallOneObject(1);  }
        if ( oper == AInvAttr )  { InstallAinvObject(1); }
        if ( oper == ZeroAttr )  { InstallZeroObject(1); }

        /* switch do with do verbose                                       */
        for ( j = 0;  TabSilentVerboseOperations[j];  j += 2 ) {
            for ( i = 0;  i <= 7;  i++ ) {
                if ( HDLR_FUNC(oper,i) == TabSilentVerboseOperations[j] ) {
                    HDLR_FUNC(oper,i) = TabSilentVerboseOperations[j+1];
                }
            }
        }
    }

    /* be silent                                                           */
    else {

        /* catch infix operations                                          */
        if ( oper == EqOper   )  { InstallEqObject(0);   }
        if ( oper == LtOper   )  { InstallLtObject(0);   }
        if ( oper == InOper   )  { InstallInObject(0);   }
        if ( oper == SumOper  )  { InstallSumObject(0);  }
        if ( oper == DiffOper )  { InstallDiffObject(0); }
        if ( oper == ProdOper )  { InstallProdObject(0); }
        if ( oper == QuoOper  )  { InstallQuoObject(0);  }
        if ( oper == LQuoOper )  { InstallLQuoObject(0); }
        if ( oper == PowOper  )  { InstallPowObject(0);  }
        if ( oper == CommOper )  { InstallCommObject(0); }
        if ( oper == ModOper  )  { InstallModObject(0); }
        if ( oper == InvAttr  )  { InstallInvObject(0);  }
        if ( oper == OneAttr  )  { InstallOneObject(0);  }
        if ( oper == AInvAttr )  { InstallAinvObject(0); }
        if ( oper == ZeroAttr )  { InstallZeroObject(0); }

        /* switch do verbose with do                                       */
        for ( j = 1;  TabSilentVerboseOperations[j-1];  j += 2 ) {
            for ( i = 0;  i <= 7;  i++ ) {
                if ( HDLR_FUNC(oper,i) == TabSilentVerboseOperations[j] ) {
                    HDLR_FUNC(oper,i) = TabSilentVerboseOperations[j-1];
                }
            }
        }
    }
}


/****************************************************************************
**
*F  FuncTraceMethods( <oper> )
*/
Obj FuncTraceMethods (
    Obj                 self,
    Obj                 oper )
{
    /* check the argument                                                  */
    if ( TNUM_OBJ(oper) != T_FUNCTION || SIZE_OBJ(oper) != SIZE_OPER ) {
        ErrorQuit( "<oper> must be an operation", 0L, 0L );
        return 0;
    }

    /* install trace handler                                               */
    ChangeDoOperations( oper, 1 );

    /* return nothing                                                      */
    return 0;
}


/****************************************************************************
**
*F  FuncUntraceMethods( <oper> )
*/
Obj FuncUntraceMethods (
    Obj                 self,
    Obj                 oper )
{

    /* check the argument                                                  */
    if ( TNUM_OBJ(oper) != T_FUNCTION || SIZE_OBJ(oper) != SIZE_OPER ) {
        ErrorQuit( "<oper> must be an operation", 0L, 0L );
        return 0;
    }

    /* install trace handler                                               */
    ChangeDoOperations( oper, 0 );

    /* return nothing                                                      */
    return 0;
}


/****************************************************************************
**
*F  FuncOPERS_CACHE_INFO( <self> )
*/
Obj FuncOPERS_CACHE_INFO (
    Obj                        self )
{
    Obj                 list;

    list = NEW_PLIST( IMMUTABLE_TNUM(T_PLIST), 9 );
    SET_LEN_PLIST( list, 9 );
    SET_ELM_PLIST( list, 1, INTOBJ_INT(AndFlagsCacheHit)    );
    SET_ELM_PLIST( list, 2, INTOBJ_INT(AndFlagsCacheMiss)   );
    SET_ELM_PLIST( list, 3, INTOBJ_INT(AndFlagsCacheLost)   );
    SET_ELM_PLIST( list, 4, INTOBJ_INT(OperationHit)        );
    SET_ELM_PLIST( list, 5, INTOBJ_INT(OperationMiss)       );
    SET_ELM_PLIST( list, 6, INTOBJ_INT(IsSubsetFlagsCalls)  );
    SET_ELM_PLIST( list, 7, INTOBJ_INT(IsSubsetFlagsCalls1) );
    SET_ELM_PLIST( list, 8, INTOBJ_INT(IsSubsetFlagsCalls2) );
    SET_ELM_PLIST( list, 9, INTOBJ_INT(OperationNext)       );

    return list;
}



/****************************************************************************
**
*F  FuncCLEAR_CACHE_INFO( <self> )
*/
Obj FuncCLEAR_CACHE_INFO (
    Obj                        self )
{
    AndFlagsCacheHit = 0;
    AndFlagsCacheMiss = 0;
    AndFlagsCacheLost = 0;
    OperationHit = 0;
    OperationMiss = 0;
    IsSubsetFlagsCalls = 0;
    IsSubsetFlagsCalls1 = 0;
    IsSubsetFlagsCalls2 = 0;
    OperationNext = 0;

    return 0;
}



/****************************************************************************
**

*F  InitOpers() . . . . . . . . . . . . . . initialize the operations package
*/
void InitOpers ( void )
{
    Int                        i;

    /* declare the handlers used in various places */
    InitHandlerFunc( DoFilter, "DoFilter");
    InitHandlerFunc( DoSetFilter, "DoSetFilter");
    InitHandlerFunc( DoAndFilter, "DoAndFilter");
    InitHandlerFunc( DoSetAndFilter, "DoSetAndFilter");
    InitHandlerFunc( DoReturnTrueFilter, "DoReturnTrueFilter");
    InitHandlerFunc( DoSetReturnTrueFilter, "DoSetReturnTrueFilter");
    
    InitHandlerFunc( DoAttribute, "DoAttribute");
    InitHandlerFunc( DoSetAttribute, "DoSetAttribute");
    InitHandlerFunc( DoTestAttribute, "DoTestAttribute");
    InitHandlerFunc( DoVerboseAttribute, "DoVerboseAttribute");
    InitHandlerFunc( DoMutableAttribute, "DoMutableAttribute");
    InitHandlerFunc( DoVerboseMutableAttribute, "DoVerboseMutableAttribute");

    InitHandlerFunc( DoProperty, "DoProperty");
    InitHandlerFunc( DoSetProperty, "DoSetProperty");
    InitHandlerFunc( DoTestProperty, "DoTestProperty");
    InitHandlerFunc( DoVerboseProperty, "DoVerboseProperty");

    InitHandlerFunc( DoSetterFunction, "DoSetterFunction");
    InitHandlerFunc( DoGetterFunction, "DoGetterFunction");
    
    InitHandlerFunc( DoOperation0Args, "DoOperation0Args");
    InitHandlerFunc( DoOperation1Args, "DoOperation1Args");
    InitHandlerFunc( DoOperation2Args, "DoOperation2Args");
    InitHandlerFunc( DoOperation3Args, "DoOperation3Args");
    InitHandlerFunc( DoOperation4Args, "DoOperation4Args");
    InitHandlerFunc( DoOperation5Args, "DoOperation5Args");
    InitHandlerFunc( DoOperation6Args, "DoOperation6Args");
    InitHandlerFunc( DoOperationXArgs, "DoOperationXArgs");

    InitHandlerFunc( DoVerboseOperation0Args, "DoVerboseOperation0Args");
    InitHandlerFunc( DoVerboseOperation1Args, "DoVerboseOperation1Args");
    InitHandlerFunc( DoVerboseOperation2Args, "DoVerboseOperation2Args");
    InitHandlerFunc( DoVerboseOperation3Args, "DoVerboseOperation3Args");
    InitHandlerFunc( DoVerboseOperation4Args, "DoVerboseOperation4Args");
    InitHandlerFunc( DoVerboseOperation5Args, "DoVerboseOperation5Args");
    InitHandlerFunc( DoVerboseOperation6Args, "DoVerboseOperation6Args");
    InitHandlerFunc( DoVerboseOperationXArgs, "DoVerboseOperationXArgs");
    
    InitHandlerFunc( DoConstructor0Args, "DoConstructor0Args");
    InitHandlerFunc( DoConstructor1Args, "DoConstructor1Args");
    InitHandlerFunc( DoConstructor2Args, "DoConstructor2Args");
    InitHandlerFunc( DoConstructor3Args, "DoConstructor3Args");
    InitHandlerFunc( DoConstructor4Args, "DoConstructor4Args");
    InitHandlerFunc( DoConstructor5Args, "DoConstructor5Args");
    InitHandlerFunc( DoConstructor6Args, "DoConstructor6Args");
    InitHandlerFunc( DoConstructorXArgs, "DoConstructorXArgs");

    InitHandlerFunc( DoVerboseConstructor0Args, "DoVerboseConstructor0Args");
    InitHandlerFunc( DoVerboseConstructor1Args, "DoVerboseConstructor1Args");
    InitHandlerFunc( DoVerboseConstructor2Args, "DoVerboseConstructor2Args");
    InitHandlerFunc( DoVerboseConstructor3Args, "DoVerboseConstructor3Args");
    InitHandlerFunc( DoVerboseConstructor4Args, "DoVerboseConstructor4Args");
    InitHandlerFunc( DoVerboseConstructor5Args, "DoVerboseConstructor5Args");
    InitHandlerFunc( DoVerboseConstructor6Args, "DoVerboseConstructor6Args");
    InitHandlerFunc( DoVerboseConstructorXArgs, "DoVerboseConstructorXArgs");
    
    
    /* make the property blist functions                                   */
    InitHandlerFunc( FuncAND_FLAGS, "AND_FLAGS" );
    AssGVar( GVarName( "AND_FLAGS" ),
         NewFunctionC( "AND_FLAGS", 2L, "oper1, oper2",
                    FuncAND_FLAGS ) );

    InitHandlerFunc( FuncSUB_FLAGS, "SUB_FLAGS" );
    AssGVar( GVarName( "SUB_FLAGS" ),
         NewFunctionC( "SUB_FLAGS", 2L, "oper1, oper2",
                    FuncSUB_FLAGS ) );

    InitHandlerFunc( FuncHASH_FLAGS, "HASH_FLAGS" );
    AssGVar( GVarName( "HASH_FLAGS" ),
         NewFunctionC( "HASH_FLAGS", 1L, "flags",
                    FuncHASH_FLAGS ) );

    InitHandlerFunc( FuncIS_EQUAL_FLAGS, "IS_EQUAL_FLAGS" );
    AssGVar( GVarName( "IS_EQUAL_FLAGS" ),
         NewFunctionC( "IS_EQUAL_FLAGS", 2L, "flags1, flags2",
                    FuncIS_EQUAL_FLAGS ) );

    InitHandlerFunc( FuncIS_SUBSET_FLAGS, "IS_SUBSET_FLAGS" );
    AssGVar( GVarName( "IS_SUBSET_FLAGS" ),
         NewFunctionC( "IS_SUBSET_FLAGS", 2L, "flags1, flags2",
                    FuncIS_SUBSET_FLAGS ) );

    InitHandlerFunc( FuncTRUES_FLAGS, "TRUES_FLAGS" );
    AssGVar( GVarName( "TRUES_FLAGS" ),
         NewFunctionC( "TRUES_FLAGS", 1L, "flags",
                    FuncTRUES_FLAGS ) );

    InitHandlerFunc( FuncSIZE_FLAGS, "SIZE_FLAGS" );
    AssGVar( GVarName( "SIZE_FLAGS" ),
         NewFunctionC( "SIZE_FLAGS", 1L, "flags",
                    FuncSIZE_FLAGS ) );

    InitHandlerFunc( FuncLEN_FLAGS, "LEN_FLAGS" );
    AssGVar( GVarName( "LEN_FLAGS" ),
         NewFunctionC( "LEN_FLAGS", 1L, "flags",
                    FuncLEN_FLAGS ) );

    InitHandlerFunc( FuncELM_FLAGS, "ELM_FLAGS" );
    AssGVar( GVarName( "ELM_FLAGS" ),
         NewFunctionC( "ELM_FLAGS", 2L, "flags, pos",
                    FuncELM_FLAGS ) );


    /* install the printing function                                       */
    PrintObjFuncs[ T_FLAGS ] = PrintFlags;


    /* install the kind function                                           */
    ImportGVarFromLibrary( "TYPE_FLAGS", &TYPE_FLAGS );
    TypeObjFuncs[ T_FLAGS ] = TypeFlags;

    /* install the marking function                                        */
    InfoBags[T_FLAGS].name = "flags list";
    InitMarkFuncBags( T_FLAGS, MarkTwoSubBags );


    /* make the functions that support new operations                      */
    C_NEW_GVAR_FILT( "IS_OPERATION", "obj", IsOperationFilt,
		  FuncIS_OPERATION,
         "src/opers.c:IS_OPERATION" );

    InitHandlerFunc( FuncFlag1Filter, "FLAG1_FILTER" );
    AssGVar( GVarName( "FLAG1_FILTER" ),
         NewFunctionC( "FLAG1_FILTER", 1L, "oper",
                    FuncFlag1Filter ) );

    InitHandlerFunc( FuncSetFlag1Filter, "SET_FLAG1_FILTER" );
    AssGVar( GVarName( "SET_FLAG1_FILTER" ),
         NewFunctionC( "SET_FLAG1_FILTER", 2L, "oper, flag1",
                    FuncSetFlag1Filter ) );

    InitHandlerFunc( FuncFlag2Filter, "FLAG2_FILTER" );
    AssGVar( GVarName( "FLAG2_FILTER" ),
         NewFunctionC( "FLAG2_FILTER", 1L, "oper",
                    FuncFlag2Filter ) );

    InitHandlerFunc( FuncSetFlag2Filter, "SET_FLAG2_FILTER" );
    AssGVar( GVarName( "SET_FLAG2_FILTER" ),
         NewFunctionC( "SET_FLAG2_FILTER", 2L, "oper, flag2",
                    FuncSetFlag2Filter ) );

    InitHandlerFunc( FuncFlagsFilter, "FLAGS_FILTER" );
    AssGVar( GVarName( "FLAGS_FILTER" ),
         NewFunctionC( "FLAGS_FILTER", 1L, "oper",
                    FuncFlagsFilter ) );

    InitHandlerFunc( FuncSetFlagsFilter, "SET_FLAGS_FILTER" );
    AssGVar( GVarName( "SET_FLAGS_FILTER" ),
         NewFunctionC( "SET_FLAGS_FILTER", 2L, "oper, flags",
                    FuncSetFlagsFilter ) );

    InitHandlerFunc( FuncSetterFilter, "SETTER_FILTER" );
    AssGVar( GVarName( "SETTER_FILTER" ),
         NewFunctionC( "SETTER_FILTER", 1L, "oper",
                    FuncSetterFilter ) );

    InitHandlerFunc( FuncSetSetterFilter, "SET_SETTER_FILTER" );
    AssGVar( GVarName( "SET_SETTER_FILTER" ),
         NewFunctionC( "SET_SETTER_FILTER", 2L, "oper, other",
                    FuncSetSetterFilter ) );

    InitHandlerFunc( FuncTesterFilter, "TESTER_FILTER" );
    AssGVar( GVarName( "TESTER_FILTER" ),
         NewFunctionC( "TESTER_FILTER", 1L, "oper",
                    FuncTesterFilter ) );

    InitHandlerFunc( FuncSetTesterFilter, "SET_TESTER_FILTER" );
    AssGVar( GVarName( "SET_TESTER_FILTER" ),
         NewFunctionC( "SET_TESTER_FILTER", 2L, "oper, other",
                    FuncSetTesterFilter ) );

    InitHandlerFunc( FuncMethodsOperation, "METHODS_OPERATION" );
    AssGVar( GVarName( "METHODS_OPERATION" ),
         NewFunctionC( "METHODS_OPERATION", 2L, "oper, narg",
                    FuncMethodsOperation ) );

    InitHandlerFunc( FuncSetMethodsOperation, "SET_METHODS_OPERATION" );
    AssGVar( GVarName( "SET_METHODS_OPERATION" ),
         NewFunctionC( "SET_METHODS_OPERATION", 3L, "oper, narg, meths",
                    FuncSetMethodsOperation ) );

    InitHandlerFunc( FuncChangedMethodsOperation, "CHANGED_METHODS_OPERATION" );
    AssGVar( GVarName( "CHANGED_METHODS_OPERATION" ),
         NewFunctionC( "CHANGED_METHODS_OPERATION", 2L, "oper, narg",
                    FuncChangedMethodsOperation) );


    /* make the functions for filter, operations, properties, attributes   */
    InitHandlerFunc( NewFilterHandler, "NewFilter" );
    NewFilterFunc = NewFunctionC(
        "NewFilter", 1L, "name", NewFilterHandler );
    AssGVar( GVarName( "NEW_FILTER" ), NewFilterFunc );

    InitHandlerFunc( NewOperationHandler, "NewOperation" );
    NewOperationFunc = NewFunctionC(
        "NewOperation", 1L, "name", NewOperationHandler );
    AssGVar( GVarName( "NEW_OPERATION" ), NewOperationFunc );

    InitHandlerFunc( NewConstructorHandler, "NewConstructor" );
    NewConstructorFunc = NewFunctionC(
        "NewConstructor", 1L, "name", NewConstructorHandler );
    AssGVar( GVarName( "NEW_CONSTRUCTOR" ), NewConstructorFunc );

    InitHandlerFunc( NewAttributeHandler, "NewAttribute" );
    NewAttributeFunc = NewFunctionC(
        "NewAttribute", 1L, "name", NewAttributeHandler );
    AssGVar( GVarName( "NEW_ATTRIBUTE" ), NewAttributeFunc );

    InitHandlerFunc( NewMutableAttributeHandler, "NewMutableAttribute" );
    NewMutableAttributeFunc = NewFunctionC(
        "NewMutableAttribute", 1L, "name", NewMutableAttributeHandler );
    AssGVar( GVarName( "NEW_MUTABLE_ATTRIBUTE" ), NewMutableAttributeFunc );

    InitHandlerFunc( NewPropertyHandler, "NewProperty" );
    NewPropertyFunc = NewFunctionC(
        "NewProperty", 1L, "name", NewPropertyHandler );
    AssGVar( GVarName( "NEW_PROPERTY" ), NewPropertyFunc );

    InitHandlerFunc( FuncSetterFunction, "SetterFunction" );
    SetterFunctionFunc = NewFunctionC(
        "SetterFunction", 2L, "name, filter", FuncSetterFunction );
    AssGVar( GVarName( "SETTER_FUNCTION" ), SetterFunctionFunc );

    InitHandlerFunc( FuncGetterFunction, "GetterFunction" );
    GetterFunctionFunc = NewFunctionC(
        "GetterFunction", 1L, "name", FuncGetterFunction );
    AssGVar( GVarName( "GETTER_FUNCTION" ), GetterFunctionFunc );


    /* make the trace functions                                            */
    InitHandlerFunc( FuncTraceMethods, "TRACE_METHODS" );
    AssGVar( GVarName( "TRACE_METHODS" ),
         NewFunctionC( "TRACE_METHODS", 1L, "oper",
                    FuncTraceMethods ) );

    InitHandlerFunc( FuncUntraceMethods, "UNTRACE_METHODS" );
    AssGVar( GVarName( "UNTRACE_METHODS" ),
         NewFunctionC( "UNTRACE_METHODS", 1L, "oper",
                    FuncUntraceMethods ) );


    /* make the 'true' operation                                           */  
    ReturnTrueFilter = NewReturnTrueFilter();
    AssGVar( GVarName( "IS_OBJECT" ), ReturnTrueFilter );


    /* install the (function) copies of global variables                   */
    /* for the inside-out (kernel to library) interface                    */
    TRY_NEXT_METHOD = NEW_STRING( 16 );
    SyStrncat( CSTR_STRING(TRY_NEXT_METHOD), "TRY_NEXT_METHOD", 16 );
    AssGVar( GVarName("TRY_NEXT_METHOD"), TRY_NEXT_METHOD );

    ImportGVarFromLibrary( "TRY_NEXT_METHOD", &TRY_NEXT_METHOD );

    ImportFuncFromLibrary( "METHOD_0ARGS", &Method0Args );
    ImportFuncFromLibrary( "METHOD_1ARGS", &Method1Args );
    ImportFuncFromLibrary( "METHOD_2ARGS", &Method2Args );
    ImportFuncFromLibrary( "METHOD_3ARGS", &Method3Args );
    ImportFuncFromLibrary( "METHOD_4ARGS", &Method4Args );
    ImportFuncFromLibrary( "METHOD_5ARGS", &Method5Args );
    ImportFuncFromLibrary( "METHOD_6ARGS", &Method6Args );
    ImportFuncFromLibrary( "METHOD_XARGS", &MethodXArgs );

    ImportFuncFromLibrary( "NEXT_METHOD_0ARGS", &NextMethod0Args );
    ImportFuncFromLibrary( "NEXT_METHOD_1ARGS", &NextMethod1Args );
    ImportFuncFromLibrary( "NEXT_METHOD_2ARGS", &NextMethod2Args );
    ImportFuncFromLibrary( "NEXT_METHOD_3ARGS", &NextMethod3Args );
    ImportFuncFromLibrary( "NEXT_METHOD_4ARGS", &NextMethod4Args );
    ImportFuncFromLibrary( "NEXT_METHOD_5ARGS", &NextMethod5Args );
    ImportFuncFromLibrary( "NEXT_METHOD_6ARGS", &NextMethod6Args );
    ImportFuncFromLibrary( "NEXT_METHOD_XARGS", &NextMethodXArgs );

    ImportFuncFromLibrary( "VMETHOD_0ARGS", &VMethod0Args );
    ImportFuncFromLibrary( "VMETHOD_1ARGS", &VMethod1Args );
    ImportFuncFromLibrary( "VMETHOD_2ARGS", &VMethod2Args );
    ImportFuncFromLibrary( "VMETHOD_3ARGS", &VMethod3Args );
    ImportFuncFromLibrary( "VMETHOD_4ARGS", &VMethod4Args );
    ImportFuncFromLibrary( "VMETHOD_5ARGS", &VMethod5Args );
    ImportFuncFromLibrary( "VMETHOD_6ARGS", &VMethod6Args );
    ImportFuncFromLibrary( "VMETHOD_XARGS", &VMethodXArgs );

    ImportFuncFromLibrary( "NEXT_VMETHOD_0ARGS", &NextVMethod0Args );
    ImportFuncFromLibrary( "NEXT_VMETHOD_1ARGS", &NextVMethod1Args );
    ImportFuncFromLibrary( "NEXT_VMETHOD_2ARGS", &NextVMethod2Args );
    ImportFuncFromLibrary( "NEXT_VMETHOD_3ARGS", &NextVMethod3Args );
    ImportFuncFromLibrary( "NEXT_VMETHOD_4ARGS", &NextVMethod4Args );
    ImportFuncFromLibrary( "NEXT_VMETHOD_5ARGS", &NextVMethod5Args );
    ImportFuncFromLibrary( "NEXT_VMETHOD_6ARGS", &NextVMethod6Args );
    ImportFuncFromLibrary( "NEXT_VMETHOD_XARGS", &NextVMethodXArgs );

    ImportFuncFromLibrary( "CONSTRUCTOR_0ARGS", &Constructor0Args );
    ImportFuncFromLibrary( "CONSTRUCTOR_1ARGS", &Constructor1Args );
    ImportFuncFromLibrary( "CONSTRUCTOR_2ARGS", &Constructor2Args );
    ImportFuncFromLibrary( "CONSTRUCTOR_3ARGS", &Constructor3Args );
    ImportFuncFromLibrary( "CONSTRUCTOR_4ARGS", &Constructor4Args );
    ImportFuncFromLibrary( "CONSTRUCTOR_5ARGS", &Constructor5Args );
    ImportFuncFromLibrary( "CONSTRUCTOR_6ARGS", &Constructor6Args );
    ImportFuncFromLibrary( "CONSTRUCTOR_XARGS", &ConstructorXArgs );

    ImportFuncFromLibrary( "NEXT_CONSTRUCTOR_0ARGS", &NextConstructor0Args );
    ImportFuncFromLibrary( "NEXT_CONSTRUCTOR_1ARGS", &NextConstructor1Args );
    ImportFuncFromLibrary( "NEXT_CONSTRUCTOR_2ARGS", &NextConstructor2Args );
    ImportFuncFromLibrary( "NEXT_CONSTRUCTOR_3ARGS", &NextConstructor3Args );
    ImportFuncFromLibrary( "NEXT_CONSTRUCTOR_4ARGS", &NextConstructor4Args );
    ImportFuncFromLibrary( "NEXT_CONSTRUCTOR_5ARGS", &NextConstructor5Args );
    ImportFuncFromLibrary( "NEXT_CONSTRUCTOR_6ARGS", &NextConstructor6Args );
    ImportFuncFromLibrary( "NEXT_CONSTRUCTOR_XARGS", &NextConstructorXArgs );

    ImportFuncFromLibrary( "VCONSTRUCTOR_0ARGS", &VConstructor0Args );
    ImportFuncFromLibrary( "VCONSTRUCTOR_1ARGS", &VConstructor1Args );
    ImportFuncFromLibrary( "VCONSTRUCTOR_2ARGS", &VConstructor2Args );
    ImportFuncFromLibrary( "VCONSTRUCTOR_3ARGS", &VConstructor3Args );
    ImportFuncFromLibrary( "VCONSTRUCTOR_4ARGS", &VConstructor4Args );
    ImportFuncFromLibrary( "VCONSTRUCTOR_5ARGS", &VConstructor5Args );
    ImportFuncFromLibrary( "VCONSTRUCTOR_6ARGS", &VConstructor6Args );
    ImportFuncFromLibrary( "VCONSTRUCTOR_XARGS", &VConstructorXArgs );

    ImportFuncFromLibrary( "NEXT_VCONSTRUCTOR_0ARGS", &NextVConstructor0Args );
    ImportFuncFromLibrary( "NEXT_VCONSTRUCTOR_1ARGS", &NextVConstructor1Args );
    ImportFuncFromLibrary( "NEXT_VCONSTRUCTOR_2ARGS", &NextVConstructor2Args );
    ImportFuncFromLibrary( "NEXT_VCONSTRUCTOR_3ARGS", &NextVConstructor3Args );
    ImportFuncFromLibrary( "NEXT_VCONSTRUCTOR_4ARGS", &NextVConstructor4Args );
    ImportFuncFromLibrary( "NEXT_VCONSTRUCTOR_5ARGS", &NextVConstructor5Args );
    ImportFuncFromLibrary( "NEXT_VCONSTRUCTOR_6ARGS", &NextVConstructor6Args );
    ImportFuncFromLibrary( "NEXT_VCONSTRUCTOR_XARGS", &NextVConstructorXArgs );

    ImportFuncFromLibrary( "SET_FILTER_OBJ",   &SET_FILTER_OBJ );
    ImportFuncFromLibrary( "RESET_FILTER_OBJ", &RESET_FILTER_OBJ );

    /* create the hash tables                                              */
#ifdef AND_FLAGS_HASH_SIZE
    AndFlagsCache = NEW_PLIST( T_PLIST, 3*AND_FLAGS_HASH_SIZE );
    SET_LEN_PLIST( AndFlagsCache, 3*AND_FLAGS_HASH_SIZE );
    AssGVar( GVarName( "AND_FLAGS_CACHE" ), AndFlagsCache );

    for ( i = 1;  i <= 3*AND_FLAGS_HASH_SIZE;  i++ ) {
         SET_ELM_PLIST( AndFlagsCache, i, INTOBJ_INT(0) );
    }
#endif

    InitHandlerFunc( FuncOPERS_CACHE_INFO, "OPERS_CACHE_INFO" );
    AssGVar( GVarName( "OPERS_CACHE_INFO" ),
         NewFunctionC( "OPERS_CACHE_INFO", 0L, "",
                    FuncOPERS_CACHE_INFO ) );

    InitHandlerFunc( FuncCLEAR_CACHE_INFO, "CLEAR_CACHE_INFO" );
    AssGVar( GVarName( "CLEAR_CACHE_INFO" ),
         NewFunctionC( "CLEAR_CACHE_INFO", 0L, "",
                    FuncCLEAR_CACHE_INFO ) );
}



/****************************************************************************
**

*E  opers.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
