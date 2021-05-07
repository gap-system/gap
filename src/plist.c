/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions that deal with plain lists.
**
**  A plain list  is represented by  a bag  of type 'T_PLIST',  which has the
**  following format:
**
**      +-------+-------+-------+- - - -+-------+-------+- - - -+-------+
**      |logical| first |second |       |last   |       |       |       |
**      |length |element|element|       |element|   0   |       |   0   |
**      +-------+-------+-------+- - - -+-------+-------+- - - -+-------+
**
**  The first entry is the logical length of the list stored as GAP immediate
**  integer.  The second entry is the identifier of the  first element of the
**  list.  The third  entry is  the identifier  of the second  element of the
**  list, and so on.  If  the physical length  of a list  is greater than the
**  logical, there will be unused entries at the end  of the list, containing
**  0.  The physical length  might be greater than  the logical,  because the
**  physical size of a  list is increased by at  least 25\%, to avoid doing
**  this too often.
**
**  This representation  is encoded by  the macros 'NEW_PLIST', 'GROW_PLIST',
**  'SHRINK_PLIST', 'SET_LEN_PLIST',    'LEN_PLIST',     'SET_ELM_PLIST', and
**  'ELM_PLIST', which are used by the functions in this package and the rest
**  of the {\GAP} kernel to access plain lists.
**
**  This package also contains the list  functions for plain lists, i.e., the
**  functions called from the generic lists package.
*/

#include "plist.h"

#include "ariths.h"
#include "blister.h"
#include "bool.h"
#include "calls.h"
#include "cyclotom.h"
#include "error.h"
#include "finfield.h"
#include "funcs.h"
#include "gaputils.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "range.h"
#include "saveload.h"
#include "sysopt.h"    // for SyInitializing

#ifdef HPCGAP
#include "hpc/guards.h"
#include "hpc/traverse.h"
#endif


/****************************************************************************
**
*F  GROW_PLIST(<list>,<plen>) . . . .  make sure a plain list is large enough
**
*/
void             GrowPlist (
    Obj                 list,
    UInt                need )
{
    UInt                plen;           /* new physical length             */
    UInt                good;           /* good new physical length        */

    if (need > INT_INTOBJ_MAX)
        ErrorMayQuit("GrowPlist: List size too large", 0, 0);

    /* find out how large the plain list should become                     */
    good = 5 * (SIZE_OBJ(list)/sizeof(Obj)-1) / 4 + 4;
    if (good > INT_INTOBJ_MAX)
        good = INT_INTOBJ_MAX;

    /* but maybe we need more                                              */
    if ( need < good ) { plen = good; }
    else               { plen = need; }

    /* resize the plain list                                               */
    ResizeBag( list, ((plen)+1)*sizeof(Obj) );
}


/****************************************************************************
**
*F  TypePlist(<list>) . . . . . . . . . . . . . . . . .  type of a plain list
**
**  'TypePlist' returns the type of the plain list <list>.
**
**  'TypePlist' is the function in 'TypeObjFuncs' for plain lists.
**
**  TypePlist works with KTNumPlist to determine the type of a plain list
**  Considerable care is needed to deal with self-referential lists. This is
**  basically achieved with the OBJ_FLAG_TESTING flag in the TNum. This must
**  be set in the "current" list before triggering determination of the Type
**  (or KTNum) of any sublist.
**
**  KTNumPlist determined the "true" TNum of the list, taking account of such
**  factors as denseness, homogeneity and so on. It modifies the stored TNum
**  of the list to the most informative "safe" value, allowing for the
**  mutability of the list entries (and preserving OBJ_FLAG_TESTING).
**
**  Here begins a new attempt by Steve to describe how it all works:
**
**  We begin with the TNUMs attached to the objects. They are defined in
**  objects.h and consist of the following, each of which can be qualified by
**  adding the constant IMMUTABLE.
**
**   T_PLIST                    nothing is known
**   T_PLIST_NDENSE             known to have a hole
**   T_PLIST_DENSE              known only not to have a hole
**   T_PLIST_DENSE_NHOM         known to be dense but not homogenous *  **
**   T_PLIST_DENSE_NHOM_SSORT   dense, non-hom but strictly sorted
**   T_PLIST_DENSE_NHOM_NSORT   dense, non-hom, known not to be sorted
**   T_PLIST_EMPTY              the empty list
**   T_PLIST_HOM                known to be homogenous *
**   T_PLIST_HOM_NSORT           etc
**   T_PLIST_HOM_SSORT           etc
**   T_PLIST_TAB                known to be a table  *
**   T_PLIST_TAB_NSORT           etc
**   T_PLIST_TAB_SSORT           etc
**   T_PLIST_TAB_RECT           known to be a rectangular table  *
**   T_PLIST_TAB_RECT_NSORT      etc
**   T_PLIST_TAB_RECT_SSORT      etc
**   T_PLIST_CYC                known to be a list of constant kernel cyclotomics
**   T_PLIST_CYC_NSORT           etc
**   T_PLIST_CYC_SSORT           etc
**   T_PLIST_FFE                known to be a list of kernel FFEs over same field
**
**   * -- these tnums can only be safely given when none of the elements of
**        the list is mutable
**   ** -- dense recursive lists (have themselves as a (possibly nested) subobject)
**         appear here
**
**  There are 10 functions entered in TypeObjFuncs:
**      1. TypePlist
**      2. TypePlistNDense
**      3. TypePlistDense
**      4. TypePlistDenseNHom
**      5. TypePlistDenseNHomSSort
**      6. TypePlistDenseNHomNSort
**      7. TypePlistEmpty
**      8. TypePlistHom     -- also handles Tab and RectTab
**      9. TypePlistCyc
**      10.TypePlistFfe
**
**     Of these:
**         3 is actually an alias of 1
**         2,4, 5, 6 and 7  simply return a fixed type
**         Thus 1, 8, 9 and 10 have work to do.
**
**     9 and 10 look up the exact TNUM in a table associated with the element
**        family to find the type, calling out to a GAP function to make each
**        type for the first time.
**
**     1 and 8 now get really complicated. This is because they now have to
**     check properties of the list which may be currently true, but not yet
**     known, and possibly not storable due to the presence of mutable
**     elements in the list. If we didn't do this, a lot of matrix stuff
**     wouldn't work
**
**     8 is the simpler. It calls KTNumHomPlist, which checks whether we
**     should really be in T_PLIST_CYC, T_PLIST_FFE or T_PLIST_TAB and if so,
**     changes the TNUM appropriately and returns the new tnum.  The only
**     time this is slow is a homogenous list of lists which looks like a
**     table until the very last entry which has the wrong length. This
**     should be rare.
**
**     1 is the real nightmare, because it has to handle recursive mutable
**     lists, lists with mutable subobjects, etc.  We now concentrate on this
**     case.
**
**     The entry point is the function TypePlistWithKTNum, which returns both
**     the type and the ktnum of the list. This must be done in one function
**     to avoid an exponential slowdown for deeply nested lists. This
**     function is mutually recursive with KTNumPlist, which also returns two
**     pieces of information: the ktnum of the list and, if it is homogenous,
**     the family of the elements.
**
**     recursive lists (ie lists which are there own subobjects are detected
**     using the OBJ_FLAG_TESTING tnums. Any list being examined must have
**     OBJ_FLAG_TESTING added to its tnum BEFORE any element of it is examined.
**
**
**     FIXME HPC-GAP: All of this is horribly thread-unsafe!
**
*/

static Obj TYPE_LIST_NDENSE_MUTABLE;
static Obj TYPE_LIST_NDENSE_IMMUTABLE;
static Obj TYPE_LIST_DENSE_NHOM_MUTABLE;
static Obj TYPE_LIST_DENSE_NHOM_IMMUTABLE;
static Obj TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE;
static Obj TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE;
static Obj TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE;
static Obj TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE;
static Obj TYPE_LIST_EMPTY_MUTABLE;
static Obj TYPE_LIST_EMPTY_IMMUTABLE;
static Obj TYPE_LIST_HOM;

static Obj TypePlistWithKTNum( Obj list, UInt *ktnum );

static Int KTNumPlist(Obj list, Obj * famfirst)
{
    BOOL isHom   = TRUE;    // is <list> homogeneous
    BOOL isDense = TRUE;    // is <list> dense
    BOOL isTable = FALSE;   // are <list>s elms all lists
    BOOL isRect  = FALSE;   // are lists elms of equal length only test this
                            // one for PLIST elements
    BOOL areMut  = FALSE;   // are <list>s elms mutable
    Int  len     = 0;       // if so, this is the length
    Obj  typeObj = 0;       // type of <list>s elements
    Obj  family  = 0;       // family of <list>s elements
    Int  lenList;           // length of <list>
    Obj  elm, x;            // one element of <list>
    Int  i;                 // loop variable
    Int  testing;           // to test or not to test type
    Int  res;               // result
    Int  knownDense;        // set true if the list is already known to be dense
    Int  knownNDense;       // set true if the list is already known not to be dense
    UInt ktnumFirst;

    Obj  loopTypeObj = 0; // typeObj in loop

#ifdef HPCGAP
    if (!CheckWriteAccess(list)) {
      return TNUM_OBJ(list);
    }
#endif
    // if list has `OBJ_FLAG_TESTING' keep that
    testing = TEST_OBJ_FLAG(list, OBJ_FLAG_TESTING);

    knownDense = HAS_FILT_LIST( list, FN_IS_DENSE );
    knownNDense = HAS_FILT_LIST( list, FN_IS_NDENSE );

    /* get the length of the list                                          */
    lenList = LEN_PLIST(list);

    /* special case for empty list                                         */
    if ( lenList == 0 ) {
        res = IS_MUTABLE_OBJ(list) ? T_PLIST_EMPTY : T_PLIST_EMPTY+IMMUTABLE;
        RetypeBagIfWritable(list, res);
        if (famfirst != (Obj *) 0)
          *famfirst = (Obj) 0;
        return res;
    }

    /* look at the first element                                           */
    elm = ELM_PLIST( list, 1 );
    if ( elm == 0 ) {
        isDense = 0;
    }
#ifdef HPCGAP
    else if ( !CheckReadAccess(elm) ) {
      isHom = 0;
      areMut = 1;
      isTable = 0;
    }
#endif
    else if (TEST_OBJ_FLAG(elm, OBJ_FLAG_TESTING)) {
        isHom   = 0;
        areMut  = IS_PLIST_MUTABLE(elm);
        isTable = 0;
    }
    else {
#ifdef HPCGAP
        if (!testing) SET_OBJ_FLAG(list, OBJ_FLAG_TESTING|OBJ_FLAG_TESTED);
#else
        if (!testing) SET_OBJ_FLAG(list, OBJ_FLAG_TESTING);
#endif

        if (IS_PLIST(elm)) {
            typeObj = TypePlistWithKTNum(elm, &ktnumFirst);
            family = FAMILY_TYPE( typeObj );
        }
        else {
            typeObj =  TYPE_OBJ(elm);
            family  = FAMILY_TYPE( typeObj );
            ktnumFirst = 0;
        }
        isHom   = 1;
        areMut  = IS_MUTABLE_OBJ(elm);
        if ( ktnumFirst >= T_PLIST_HOM ||
             ( ktnumFirst == 0 && IS_HOMOG_LIST( elm) )) {

          /* entry is a homogenous list, so this might be a table */
          isTable = 1;

          /* also check for rectangularity, unless this would be expensive */
          if (IS_PLIST(elm))
            {
              isRect = 1;
              len = LEN_PLIST(elm);
            }

        }
        if (!testing) CLEAR_OBJ_FLAG(list, OBJ_FLAG_TESTING);
    }

    i = 2;
    /* scan quickly through any initial INTOBJs                            */
    if ( IS_INTOBJ(ELM_PLIST(list, 1)) ) {
        /* We have already marked list as not table, not rect */
        while(i <= lenList && IS_INTOBJ(ELM_PLIST( list, i ))) {
            i++;
        }
    }

    /* loop over the list                                                  */
    for ( ; isDense && (isHom || ! areMut) && i <= lenList; i++ ) {
        elm = ELM_PLIST( list, i );
        if ( elm == 0 ) {
            isDense = 0;
        }
#ifdef HPCGAP
        else if ( !CheckReadAccess(elm) ) {
            isHom = 0;
            areMut = 1;
            isTable = 0;
            isRect = 0;
        }
#endif
        else if (TEST_OBJ_FLAG(elm, OBJ_FLAG_TESTING)) {
            isHom   = 0;
            areMut  = (areMut || IS_PLIST_MUTABLE(elm));
            isTable = 0;
            isRect = 0;
        }
        else {
            if (isHom) {
                loopTypeObj = TYPE_OBJ(elm);
                if ( loopTypeObj != typeObj && FAMILY_TYPE(loopTypeObj) != family ) {
                    isHom = 0;
                    isTable = 0;
                    isRect = 0;
                }
                if ( isTable ) {
                    /* IS_PLIST first, as it is much cheaper */
                    if (!(IS_PLIST(elm) || IS_LIST(elm))) {
                        isTable = 0;
                        isRect = 0;
                    }
                    if ( isRect ) {
                        if ( !(IS_PLIST(elm) && LEN_PLIST(elm) == len) ) {
                            isRect = 0;
                        }
                    }
                }
            }
            areMut  = (areMut || IS_MUTABLE_OBJ(elm));
        }
    }

    /* if we know it is not dense */
    if (knownNDense)
      isDense = 0;
    /* otherwise if we don't know that it IS dense */
    else if (!knownDense)
      for ( ;  isDense && i <= lenList;  i++ ) {
        elm = ELM_PLIST( list, i );
        if ( elm == 0 ) {
          isDense = 0;
        }
      }

    /* set the appropriate flags (not the hom. flag if elms are mutable)   */
    if      ( ! isDense ) {
        SET_FILT_LIST( list, FN_IS_NDENSE );
        res = T_PLIST_NDENSE;
        if (famfirst != (Obj *) 0)
          *famfirst = (Obj) 0;
    }
    else if ( isDense && ! isHom ) {
        SET_FILT_LIST( list, FN_IS_DENSE );
        if ( ! areMut )
            SET_FILT_LIST( list, FN_IS_NHOMOG );
        res = T_PLIST_DENSE_NHOM;
        if (famfirst != (Obj *) 0)
          *famfirst = (Obj) 0;
    }
    else if ( isDense &&   isHom && ! isTable ) {
        SET_FILT_LIST( list, areMut ? FN_IS_DENSE : FN_IS_HOMOG );
        if (IS_CYC(ELM_PLIST(list,1)))
          {
            res = (lenList == 1) ? T_PLIST_CYC_SSORT : T_PLIST_CYC;
            /* This is a hack */
            RetypeBagSM(list, res);
          }
        else if (IS_FFE(ELM_PLIST(list,1)))
          {
            FF fld = FLD_FFE(ELM_PLIST(list,1));
            UInt isFFE = 1;
            for (i = 2; i <= lenList; i++)
              {
                x = ELM_PLIST(list,i);
                if (!IS_FFE(x) || FLD_FFE(x) != fld)
                  {
                    isFFE = 0;
                    break;
                  }
              }
            if (isFFE)
              {
                res = T_PLIST_FFE;
                RetypeBagSM(list, res);
              }
            else
              res = T_PLIST_HOM;
          }
        else
          res = T_PLIST_HOM;
        if (famfirst != (Obj *) 0)
          *famfirst = (Obj) family;

    }
    else  if ( isDense &&   isHom &&   isTable && !isRect )  {
        SET_FILT_LIST( list, areMut ? FN_IS_DENSE : FN_IS_TABLE );
        res = T_PLIST_TAB;
        if (famfirst != (Obj *) 0)
          *famfirst = (Obj) family;
    }
    else
      {
        SET_FILT_LIST( list, areMut ? FN_IS_DENSE : FN_IS_RECT );
        res = T_PLIST_TAB_RECT;
        if (famfirst != (Obj *) 0)
          *famfirst = (Obj) family;
      }
    res = res + ( IS_MUTABLE_OBJ(list) ? 0 : IMMUTABLE );
    return res;
}


static Int KTNumHomPlist(Obj list)
{
    BOOL isTable = FALSE;   // are <list>s elms all lists
    BOOL isRect  = FALSE;   // are <list>s elms all equal length
    Int  len     = 0;       // if so, this is the length
    Int  lenList;           // length of list
    Obj  elm, x;            // one element of <list>
    Int  i;                 // loop variable
    Int  res;               // result
    Int  isSSort;           // list is (known to be) SSorted
    Int  isNSort;           // list is (known to be) non-sorted

#ifdef HPCGAP
    if (!CheckWriteAccess(list)) {
      return TNUM_OBJ(list);
    }
#endif

    /* get the length of the list                                          */
    lenList = LEN_PLIST(list);

    /* special case for empty list                                         */
    assert(lenList);

    /* look at the first element                                           */
    elm = ELM_PLIST( list, 1 );
    assert(elm);
    assert(!TEST_OBJ_FLAG(elm, OBJ_FLAG_TESTING));

    isSSort = HAS_FILT_LIST(list, FN_IS_SSORT );
    isNSort = HAS_FILT_LIST(list, FN_IS_NSORT );

    /* if it's a kernel cyclotomic then we know where we are*/
    if (IS_CYC(elm))
      {
        if (lenList == 1 || isSSort)
          res = T_PLIST_CYC_SSORT;
        else if (isNSort)
          res = T_PLIST_CYC_NSORT;
        else
          res = T_PLIST_CYC;

        /* This is a hack */
        RetypeBagSM(list, res);
        goto finish;
      }
    if (IS_FFE(elm))
      {
        FF fld = FLD_FFE(ELM_PLIST(list,1));
        UInt isFFE = 1;
        for (i = 2; i <= lenList; i++)
          {
            x = ELM_PLIST(list,i);
            if (!IS_FFE(x) || FLD_FFE(x) != fld)
              {
                isFFE = 0;
                break;
              }
          }
        if (isFFE)
          {
            res = T_PLIST_FFE;
            RetypeBagSM(list, res);
            goto finish;
          }
      }


    /* Unless we already know it is, then check if the list is a table */
    if (!HAS_FILT_LIST(list, FN_IS_TABLE ))
      {
        if ( IS_HOMOG_LIST(elm) ) {
          isTable = 1;
          if (IS_PLIST(elm))
              {
                isRect = 1;
                len     = LEN_PLIST(elm);
              }
        }

        /* loop over the list */
        for ( i = 2; isTable && i <= lenList; i++ ) {
          elm = ELM_PLIST( list, i );
          assert(elm);
          assert(!TEST_OBJ_FLAG(elm, OBJ_FLAG_TESTING));
          isTable = isTable && IS_LIST(elm); /* (isTable && IS_SMALL_LIST(elm) && LEN_LIST(elm) == len);*/
          isRect = isRect && IS_PLIST(elm) && LEN_PLIST(elm) == len;
        }
      }
    else
      {
        isTable = 1;
        isRect = HAS_FILT_LIST(list, FN_IS_RECT);
      }
    if (isTable && !isRect)
      {
        SET_FILT_LIST( list, FN_IS_TABLE );
        if (isSSort)
          res = T_PLIST_TAB_SSORT;
        else if (isNSort)
          res = T_PLIST_TAB_NSORT;
        else
          res = T_PLIST_TAB;
      }
    else if (isRect)
      {
        SET_FILT_LIST( list, FN_IS_RECT );
        if (isSSort)
          res = T_PLIST_TAB_RECT_SSORT;
        else if (isNSort)
          res = T_PLIST_TAB_RECT_NSORT;
        else
          res = T_PLIST_TAB_RECT;

      }
    else if (isSSort)
      res = T_PLIST_HOM_SSORT;
    else if (isNSort)
      res = T_PLIST_HOM_NSORT;
    else
      res = T_PLIST_HOM;

 finish:
    res = res + ( IS_MUTABLE_OBJ(list) ? 0 : IMMUTABLE );
    return res;
}

static Obj TypePlist(Obj list)
{
  return TypePlistWithKTNum( list, (UInt *) 0);
}

static Obj TypePlistHomHelper(Obj family, UInt tnum, UInt knr, Obj list)
{
    GAP_ASSERT(knr <= tnum);
    knr = tnum - knr + 1;

    // get the list types of that family
    Obj types = TYPES_LIST_FAM(family);

    // if the type is not yet known, compute it
    Obj type = ELM0_LIST(types, knr);
    if (type == 0) {
        Obj isMutable = IS_MUTABLE_OBJ(list) ? True : False;
        Obj sort = HasFiltListTNums[tnum][FN_IS_SSORT]
                       ? True
                       : HasFiltListTNums[tnum][FN_IS_NSORT] ? False : Fail;
        Obj table = HasFiltListTNums[tnum][FN_IS_RECT]
                        ? INTOBJ_INT(2)
                        : HasFiltListTNums[tnum][FN_IS_TABLE] ? INTOBJ_INT(1)
                                                              : INTOBJ_INT(0);
        type = CALL_4ARGS(TYPE_LIST_HOM, family, isMutable, sort, table);
        ASS_LIST(types, knr, type);
#ifdef HPCGAP
        // read back element before returning it, in case another thread
        // raced us (this works because <TYPES_LIST_FAM> returns an atomic
        // list in HPC-GAP)
        type = ELM0_LIST(types, knr);
#endif
    }
    return type;
}

static Obj TypePlistWithKTNum (
    Obj                 list,
    UInt                *ktnum )
{
    Int                 tnum;           /* TNUM of <list>                  */
    Obj                 family;         /* family of elements              */

#ifdef HPCGAP
    if (CheckWriteAccess(list)) {
      /* recursion is possible for this type of list                       */
      SET_OBJ_FLAG( list, OBJ_FLAG_TESTING|OBJ_FLAG_TESTED );
      tnum = KTNumPlist( list, &family);
      CLEAR_OBJ_FLAG( list, OBJ_FLAG_TESTING );
    } else {
      tnum = TNUM_OBJ(list);
      family = 0;
    }
#else
    /* recursion is possible for this type of list                         */
    SET_OBJ_FLAG( list, OBJ_FLAG_TESTING );
    tnum = KTNumPlist( list, &family);
    CLEAR_OBJ_FLAG( list, OBJ_FLAG_TESTING );
#endif
    if (ktnum != (UInt *) 0)
      *ktnum = tnum;

    /* handle special cases                                                */
    switch (tnum)
      {
      case T_PLIST_NDENSE:
        return TYPE_LIST_NDENSE_MUTABLE;
      case T_PLIST_NDENSE+IMMUTABLE:
        return TYPE_LIST_NDENSE_IMMUTABLE;
      case T_PLIST_DENSE_NHOM:
        return TYPE_LIST_DENSE_NHOM_MUTABLE;
      case T_PLIST_DENSE_NHOM+IMMUTABLE:
        return TYPE_LIST_DENSE_NHOM_IMMUTABLE;
      case T_PLIST_DENSE_NHOM_SSORT:
        return TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE;
      case T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE:
        return TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE;
      case T_PLIST_DENSE_NHOM_NSORT:
        return TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE;
      case T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE:
        return TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE;
      case T_PLIST_EMPTY:
        return TYPE_LIST_EMPTY_MUTABLE;
      case T_PLIST_EMPTY+IMMUTABLE:
        return TYPE_LIST_EMPTY_IMMUTABLE;
      default: ; /* fall through into the rest of the function */
    }

    /* handle homogeneous list                                             */
    if ( family && HasFiltListTNums[tnum][FN_IS_HOMOG] ) {
        return TypePlistHomHelper(family, tnum, T_PLIST_HOM, list);
    }

#ifdef HPCGAP
    UInt len = LEN_LIST(list);
    UInt i;
    for (i = 1; i <= len; i++) {
      if (ELM_LIST(list, i) == (Obj) 0) {
        if (IS_MUTABLE_OBJ(list))
          return TYPE_LIST_NDENSE_MUTABLE;
        else
          return TYPE_LIST_NDENSE_IMMUTABLE;
      }
    }

    if (IS_MUTABLE_OBJ(list))
      return TYPE_LIST_DENSE_NHOM_MUTABLE;
    else
      return TYPE_LIST_DENSE_NHOM_IMMUTABLE;
#else
    /* whats going on here?                                                */
    ErrorQuit( "Panic: strange type tnum '%s' ('%d')",
               (Int)TNAM_OBJ(list), (Int)(TNUM_OBJ(list)) );
    return 0;
#endif
}

static Obj TypePlistNDense(Obj list)
{
    if (IS_MUTABLE_OBJ(list))
        return TYPE_LIST_NDENSE_MUTABLE;
    else
        return TYPE_LIST_NDENSE_IMMUTABLE;
}

#define         TypePlistDense       TypePlist

static Obj TypePlistDenseNHom(Obj list)
{
    if (IS_MUTABLE_OBJ(list))
        return TYPE_LIST_DENSE_NHOM_MUTABLE;
    else
        return TYPE_LIST_DENSE_NHOM_IMMUTABLE;
}

static Obj TypePlistDenseNHomSSort(Obj list)
{
    if (IS_MUTABLE_OBJ(list))
        return TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE;
    else
        return TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE;
}

static Obj TypePlistDenseNHomNSort(Obj list)
{
    if (IS_MUTABLE_OBJ(list))
        return TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE;
    else
        return TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE;
}

static Obj TypePlistEmpty(Obj list)
{
    if (IS_MUTABLE_OBJ(list))
        return TYPE_LIST_EMPTY_MUTABLE;
    else
        return TYPE_LIST_EMPTY_IMMUTABLE;
}

static Obj TypePlistHom(Obj list)
{
    Int                 tnum;           /* TNUM of <list>                  */
    Obj                 family;         /* family of elements              */

    /* get the tnum and the family of the elements                         */
    tnum   = KTNumHomPlist( list );
    family = FAMILY_OBJ( ELM_PLIST( list, 1 ) );

    return TypePlistHomHelper(family, tnum, T_PLIST_HOM, list);
}

static Obj TypePlistCyc(Obj list)
{
    Int                 tnum;           /* TNUM of <list>                  */
    Obj                 family;         /* family of elements              */

    /* get the tnum and the family of the elements                         */
    tnum   = TNUM_OBJ( list );

    /* This had better return the cyclotomics family, could be speeded up */
    family = FAMILY_OBJ( ELM_PLIST( list, 1 ) );

    return TypePlistHomHelper(family, tnum, T_PLIST_CYC, list);
}

static Obj TypePlistFfe(Obj list)
{
    Int                 tnum;           /* TNUM of <list>                  */
    Obj                 family;         /* family of elements              */

    /* get the tnum and the family of the elements                         */
    tnum   = TNUM_OBJ( list );
    family = FAMILY_OBJ( ELM_PLIST( list, 1 ) );

    return TypePlistHomHelper(family, tnum, T_PLIST_FFE, list);
}

/****************************************************************************
**
*F  ShallowCopyPlist( <list> )  . . . . . . . .  shallow copy of a plain list
**
**  'ShallowCopyPlist' makes a copy of a plain list.
**
**  'ShallowCopyPlist'  only copies up to  the  logical length, the result is
**  always a mutable list.
*/
Obj             ShallowCopyPlist (
    Obj                 list )
{
    Obj                 new;
    UInt                len;

    /* make the new object and copy the contents                           */
    len = LEN_PLIST(list);
    if ( ! IS_PLIST_MUTABLE(list) ) {
        new = NEW_PLIST( TNUM_OBJ(list) - IMMUTABLE, len );
    }
    else {
        new = NEW_PLIST( TNUM_OBJ(list), len );
    }
    memcpy(ADDR_OBJ(new), CONST_ADDR_OBJ(list), (len + 1) * sizeof(Obj));
    /* 'CHANGED_BAG(new);' not needed, <new> is newest object              */
    return new;
}

/****************************************************************************
**
*F  FuncEmptyPlist( <self>, <len> ) . . . . . . . empty plist with space
*
* Returns an empty plain list, but with space for len entries preallocated.
*
*/
static Obj FuncEmptyPlist(Obj self, Obj len)
{
    RequireNonnegativeSmallInt(SELF_NAME, len);
    return NEW_PLIST(T_PLIST_EMPTY, INT_INTOBJ(len));
}

/****************************************************************************
**
*F  FuncShrinkAllocationPlist( <self>, <list> ) . . give back unneeded memory
*
*  Shrinks the bag of <list> to minimal possible size.
*
*/
static Obj FuncShrinkAllocationPlist(Obj self, Obj plist)
{
    RequirePlainList(SELF_NAME, plist);
    SHRINK_PLIST(plist, LEN_PLIST(plist));
    return (Obj)0;
}

/****************************************************************************
**
*F  FiltIS_PLIST_REP( <self>, <obj> ) . . . . . . . .  handler for `IS_PLIST'
*/
static Obj IsPlistFilt;

static Obj FiltIS_PLIST_REP(Obj self, Obj obj)
{
    return (IS_PLIST( obj ) ? True : False);
}


#ifdef USE_THREADSAFE_COPYING
#ifndef WARD_ENABLED

static void TraversePlist(TraversalState * traversal, Obj obj)
{
    UInt  len = LEN_PLIST(obj);
    const Obj * ptr = CONST_ADDR_OBJ(obj) + 1;
    while (len) {
        QueueForTraversal(traversal, *ptr++);
        len--;
    }
}

static void CopyPlist(TraversalState * traversal, Obj copy, Obj original)
{
    UInt  len = LEN_PLIST(original);
    const Obj * ptr = CONST_ADDR_OBJ(original) + 1;
    Obj * copyptr = ADDR_OBJ(copy) + 1;
    while (len) {
        *copyptr++ = ReplaceByCopy(traversal, *ptr++);
        len--;
    }
}

#endif // WARD_ENABLED
#else

/****************************************************************************
**
*F  CopyPlist( <list>, <mut> )  . . . . . . . . . . . . . . copy a plain list
**
**  'CopyPlist' returns a  structural (deep) copy  of the plain  list <list>,
**  i.e., a recursive copy that preserves the structure.
**
**  If <list>  has not yet  been  copied, it makes  a copy,  leaves a forward
**  pointer to the copy in the first entry of the plain  list, where the size
**  of  the plain list usually resides,  and copies all  the entries.  If the
**  plain list  has  already   been  copied, it  returns  the   value  of the
**  forwarding pointer.
**
**  'CopyPlist' is the function in 'CopyObjFuncs' for plain lists.
**
**  'CleanPlist'  removes the  mark and the forwarding pointer from the plain
**  list <list>.
**
**  'CleanPlist' is the function in 'CleanObjFuncs' for plain lists.
*/
static Obj CopyPlist(Obj list, Int mut)
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */
    UInt                i;              /* loop variable                   */

    // immutable input is handled by COPY_OBJ
    GAP_ASSERT(IS_MUTABLE_OBJ(list));

    /* make a copy                                                         */
    copy = NewBag(TNUM_OBJ(list), SIZE_OBJ(list));
    if (!mut)
        MakeImmutableNoRecurse(copy);
    ADDR_OBJ(copy)[0] = CONST_ADDR_OBJ(list)[0];

    /* leave a forwarding pointer                                          */
    PrepareCopy(list, copy);

    /* copy the subvalues                                                  */
    for ( i = 1; i <= LEN_PLIST(copy); i++ ) {
        Obj obj = CONST_ADDR_OBJ(list)[i];
        if (obj != 0) {
            tmp = COPY_OBJ(obj, mut);
            ADDR_OBJ(copy)[i] = tmp;
            CHANGED_BAG( copy );
        }
    }

    /* return the copy                                                     */
    return copy;
}

/****************************************************************************
**
*F  CleanPlist( <list> )  . . . . . . . . . . .  clean up a copied plain list
*/
static void CleanPlist(Obj list)
{
    UInt                i;              /* loop variable                   */

    /* clean the subvalues                                                 */
    for ( i = 1; i <= LEN_PLIST(list); i++ ) {
        Obj obj = CONST_ADDR_OBJ(list)[i];
        if (obj != 0)
            CLEAN_OBJ(obj);
    }

}


#endif // !defined(USE_THREADSAFE_COPYING)


/****************************************************************************
**
*F  EqPlist(<left>,<right>) . . . . . . . . test if two plain lists are equal
**
**  'EqList'  returns 'true' if  the two plain lists   <left> and <right> are
**  equal and 'false' otherwise.
**
**  Is called from the 'EQ' binop so both  operands  are  already  evaluated.
*/
static Int EqPlist(Obj left, Obj right)
{
    Int                 lenL;           /* length of the left operand      */
    Int                 lenR;           /* length of the right operand     */
    Obj                 elmL;           /* element of the left operand     */
    Obj                 elmR;           /* element of the right operand    */
    Int                 i;              /* loop variable                   */

    /* get the lengths of the lists and compare them                       */
    lenL = LEN_PLIST( left );
    lenR = LEN_PLIST( right );
    if ( lenL != lenR ) {
        return 0;
    }

    CheckRecursionBefore();

    /* loop over the elements and compare them                             */
    for ( i = 1; i <= lenL; i++ ) {
        elmL = ELM_PLIST( left, i );
        elmR = ELM_PLIST( right, i );
        if ( ( (elmL == 0 ) != (elmR == 0) ) || ! EQ( elmL, elmR ) ) {
            DecRecursionDepth();
            return 0;
        }
    }

    /* no differences found, the lists are equal                           */
    DecRecursionDepth();
    return 1;
}


/****************************************************************************
**
*F  LtPlist(<left>,<right>) . . . . . . . . test if two plain lists are equal
**
**  'LtList' returns 'true' if the plain  list <left> is  less than the plain
**  list <right> and 'false' otherwise.
**
**  Is called from the 'LT' binop so both operands are already evaluated.
*/
static Int LtPlist(Obj left, Obj right)
{
    Int                 lenL;           /* length of the left operand      */
    Int                 lenR;           /* length of the right operand     */
    Obj                 elmL;           /* element of the left operand     */
    Obj                 elmR;           /* element of the right operand    */
    Int                 i;              /* loop variable                   */
    Int                 res;            /* result of comparison            */

    /* get the lengths of the lists and compare them                       */
    lenL = LEN_PLIST( left );
    lenR = LEN_PLIST( right );
    res = (lenL < lenR);

    CheckRecursionBefore();

    /* loop over the elements and compare them                             */
    for ( i = 1; i <= lenL && i <= lenR; i++ ) {
        elmL = ELM_PLIST( left, i );
        elmR = ELM_PLIST( right, i );
        if ( elmL == 0 && elmR != 0 ) {
            res = 1;
            break;
        }
        else if ( elmR == 0 && elmL != 0 ) {
            res = 0;
            break;
        }
        else if ( ! EQ( elmL, elmR ) ) {
            res = LT( elmL, elmR );
            break;
        }
    }

    /* reached the end of at least one list                                */
    DecRecursionDepth();
    return res;
}


/****************************************************************************
**
*F  LenPlist(<list>)  . . . . . . . . . . . . . . . .  length of a plain list
**
**  'LenPlist' returns the length of the plain list <list> as a C integer.
**
**  'LenPlist' is the function in 'LenListFuncs' for plain lists.
*/
static Int LenPlist(Obj list)
{
    return LEN_PLIST( list );
}

static Int LenPlistEmpty(Obj list)
{
    GAP_ASSERT(LEN_PLIST(list) == 0);
    return 0;
}


/****************************************************************************
**
*F  IsbPlist(<list>,<pos>)  . . . . . . test for an element from a plain list
**
**  'IsbPlist' returns 1 if the list <list> has an entry  at  position  <pos>
**  and 0 otherwise.  It is the responsibility of the caller to  ensure  that
**  <pos> is a positive integer.
*/
static BOOL IsbPlist(Obj list, Int pos)
{
    return (pos <= LEN_PLIST( list ) && ELM_PLIST( list, pos ) != 0);
}

static BOOL IsbPlistDense(Obj list, Int pos)
{
    return (pos <= LEN_PLIST( list ));
}


/****************************************************************************
**
*F  Elm0Plist(<list>,<pos>) . . . . . . . . select an element of a plain list
*F  Elm0vPlist(<list>,<pos>)  . . . . . . . select an element of a plain list
**
**  'Elm0Plist' returns the element  at the position  <pos> of the plain list
**  <list>, or  0  if <list> has no  assigned  object at  <pos>.   It  is the
**  responsibility of the caller to ensure that <pos> is a positive integer.
**
**  'Elm0vPlist' does the same thing as 'Elm0Plist', but does not need to
**  check that <pos> is less than or equal to the length of <list>, this is
**  the responsibility of the caller.
*/
static Obj Elm0Plist(Obj list, Int pos)
{
    if ( pos <= LEN_PLIST( list ) ) {
        return ELM_PLIST( list, pos );
    }
    else {
        return 0;
    }
}

static Obj Elm0vPlist(Obj list, Int pos)
{
    return ELM_PLIST( list, pos );
}


/****************************************************************************
**
*F  ElmPlist(<list>,<pos>)  . . . . . . . . select an element of a plain list
*F  ElmvPlist(<list>,<pos>) . . . . . . . . select an element of a plain list
*F  ElmwPlist(<list>,<pos>) . . . . . . . . select an element of a plain list
**
**  'ElmPlist'  selects  the element at   position  <pos> of the  plain  list
**  <list>.  It is the responsibility of the caller to ensure that <pos> is a
**  positive   integer.  An error is signalled   if <pos> is  larger than the
**  length   of <list> or if  <list>  has no assigned  value  at the position
**  <pos>.
**
**  'ElmvPlist' does the same thing  than 'ElmList', but  need not check that
**  <pos> is  less  than or   equal  to the length   of  <list>, this  is the
**  responsibility of  the  caller.
**
**  'ElmPlist'   is the   function    in 'ElmListFuncs'   for  plain   lists.
**  'ElmvPlist' is the function in 'ElmvListFuncs' for plain lists.
*/
static Obj ElmPlist(Obj list, Int pos)
{
    Obj                 elm;            /* the selected element, result    */

    /* check the position                                                  */
    if ( LEN_PLIST( list ) < pos ) {
        ErrorMayQuit("List Element: <list>[%d] must have an assigned value",
                     (Int)pos, 0);
    }

    /* select the element                                                  */
    elm = ELM_PLIST( list, pos );

    /* check the element                                                   */
    if ( elm == 0 ) {
        ErrorMayQuit("List Element: <list>[%d] must have an assigned value",
                     (Int)pos, 0);
    }

    /* return the element                                                  */
    return elm;
}

static Obj ElmPlistDense(Obj list, Int pos)
{
    Obj                 elm;            /* the selected element, result    */

    /* check the position                                                  */
    if ( LEN_PLIST( list ) < pos ) {
        ErrorMayQuit("List Element: <list>[%d] must have an assigned value",
                     (Int)pos, 0);
    }

    /* select the element                                                  */
    elm = ELM_PLIST( list, pos );

    /* return the element                                                  */
    return elm;
}

static Obj ElmvPlist(Obj list, Int pos)
{
    Obj                 elm;            /* the selected element, result    */

    /* select the element                                                  */
    elm = ELM_PLIST( list, pos );

    /* check the element                                                   */
    if ( elm == 0 ) {
        ErrorMayQuit("List Element: <list>[%d] must have an assigned value",
                     (Int)pos, 0);
    }

    /* return the element                                                  */
    return elm;
}

static Obj ElmvPlistDense(Obj list, Int pos)
{
    Obj                 elm;            /* the selected element, result    */

    /* select the element                                                  */
    elm = ELM_PLIST( list, pos );

    /* return the element                                                  */
    return elm;
}


/****************************************************************************
**
*F  ElmsPlist(<list>,<poss>)  . . . . . .  select a sublist from a plain list
**
**  'ElmsPlist' returns a  new list containing the  elements at  the position
**  given in the  list <poss>   from the  plain   list  <list>.  It is    the
**  responsibility of the caller to ensure that  <poss> is dense and contains
**  only positive integers.  An error is signalled if  <list> has no assigned
**  value at any of  the positions in <poss>, or  if an element of  <poss> is
**  larger than the length of <list>.
**
**  'ElmsPlist' is the function in 'ElmsListFuncs' for plain lists which are
**  not known to be dense.
*/
static Obj ElmsPlist(Obj list, Obj poss)
{
    Obj                 elms;           /* selected sublist, result        */
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element from <list>         */
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    Int                 i;              /* loop variable                   */

    /* select no element                                                   */
    if ( LEN_LIST(poss) == 0 ) {
        elms = NewEmptyPlist();
    }

    /* general code                                                        */
    else if ( ! IS_RANGE(poss) ) {

        /* get the length of <list>                                        */
        lenList = LEN_PLIST( list );

        /* get the length of <positions>                                   */
        lenPoss = LEN_LIST( poss );

        /* make the result list                                            */
        elms = NEW_PLIST( T_PLIST_DENSE, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );
            if ( lenList < pos ) {
                ErrorMayQuit(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0);
            }

            /* select the element                                          */
            elm = ELM_PLIST( list, pos );
            if ( elm == 0 ) {
                ErrorMayQuit(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0);
            }

            /* assign the element into <elms>                              */
            SET_ELM_PLIST( elms, i, elm );

        }

        /* notify Gasman                                                   */
        CHANGED_BAG( elms );

    }

    /* special code for ranges                                             */
    else {

        /* get the length of <list>                                        */
        lenList = LEN_PLIST( list );

        /* get the length of <positions>, the first elements, and the inc. */
        lenPoss = GET_LEN_RANGE( poss );
        pos = GET_LOW_RANGE( poss );
        inc = GET_INC_RANGE( poss );

        /* check that no <position> is larger than 'LEN_LIST(<list>)'      */
        if ( lenList < pos ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos, 0);
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos + (lenPoss - 1) * inc, 0);
        }

        /* make the result list                                            */
        elms = NEW_PLIST( T_PLIST_DENSE, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {

            /* select the element                                          */
            elm = ELM_PLIST( list, pos );
            if ( elm == 0 ) {
                ErrorMayQuit(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0);
            }

            /* assign the element to <elms>                                */
            SET_ELM_PLIST( elms, i, elm );

        }

        /* notify Gasman                                                   */
        CHANGED_BAG( elms );

    }

    return elms;
}

/* This version for lists which are known to be at least dense
   and might be better */

static Obj ElmsPlistDense(Obj list, Obj poss)
{
    Obj                 elms;           /* selected sublist, result        */
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element from <list>         */
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    Int                 i;              /* loop variable                   */

    /* select no element                                                   */
    if ( LEN_LIST(poss) == 0 ) {
        elms = NewEmptyPlist();
    }

    /* general code                                                        */
    else if ( ! IS_RANGE(poss) ) {

        /* get the length of <list>                                        */
        lenList = LEN_PLIST( list );

        /* get the length of <positions>                                   */
        lenPoss = LEN_LIST( poss );

        /* make the result list                                            */
        /* try to assert as many properties as possible                    */
        if (HAS_FILT_LIST(list, FN_IS_SSORT) && HAS_FILT_LIST(poss, FN_IS_SSORT))
          {
            elms = NEW_PLIST( MUTABLE_TNUM(TNUM_OBJ(list)), lenPoss);
            RESET_FILT_LIST( elms, FN_IS_NHOMOG); /* can't deduce this one */
          }
        else if (HAS_FILT_LIST(list, FN_IS_RECT))
          elms = NEW_PLIST( T_PLIST_TAB_RECT, lenPoss );
        else if (HAS_FILT_LIST(list, FN_IS_TABLE))
          elms = NEW_PLIST( T_PLIST_TAB, lenPoss );
        else if (T_PLIST_CYC <= TNUM_OBJ(list) && TNUM_OBJ(list) <=
                                                  T_PLIST_CYC_SSORT+IMMUTABLE)
          elms = NEW_PLIST( T_PLIST_CYC, lenPoss );
        else if (T_PLIST_FFE <= TNUM_OBJ(list) && TNUM_OBJ(list) <=
                                                  T_PLIST_FFE+IMMUTABLE)
          elms = NEW_PLIST( T_PLIST_FFE, lenPoss );
        else if (HAS_FILT_LIST(list, FN_IS_HOMOG))
          elms = NEW_PLIST( T_PLIST_HOM, lenPoss );
        else
          elms = NEW_PLIST( T_PLIST_DENSE, lenPoss);

        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
            Obj p = ELMW_LIST(poss, i);
            if (!IS_INTOBJ(p)) {
                ErrorMayQuit("List Elements: position is too large for "
                             "this type of list",
                             0, 0);
            }
            pos = INT_INTOBJ(p);

            /* select the element                                          */
            if ( lenList < pos ) {
                ErrorMayQuit(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0);
            }

            /* select the element                                          */
            elm = ELM_PLIST( list, pos );

            /* assign the element into <elms>                              */
            SET_ELM_PLIST( elms, i, elm );

        }

        /* notify Gasman                                                   */
        CHANGED_BAG( elms );

    }

    /* special code for ranges                                             */
    else {

        /* get the length of <list>                                        */
        lenList = LEN_PLIST( list );

        /* get the length of <positions>, the first elements, and the inc. */
        lenPoss = GET_LEN_RANGE( poss );
        pos = GET_LOW_RANGE( poss );
        inc = GET_INC_RANGE( poss );

        /* check that no <position> is larger than 'LEN_LIST(<list>)'      */
        if ( pos < 1 || lenList < pos ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos, 0);
        }
        if ( pos+(lenPoss-1) * inc < 1 || lenList < pos+(lenPoss-1) * inc ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos + (lenPoss - 1) * inc, 0);
        }

        /* make the result list                                            */
        /* try to assert as many properties as possible                    */
        if      ( HAS_FILT_LIST(list, FN_IS_SSORT) && inc > 0 )
          elms = NEW_PLIST( MUTABLE_TNUM(TNUM_OBJ(list)), lenPoss );
        else if (HAS_FILT_LIST(list, FN_IS_RECT))
          elms = NEW_PLIST( T_PLIST_TAB_RECT, lenPoss );
        else if (HAS_FILT_LIST(list, FN_IS_TABLE))
          elms = NEW_PLIST( T_PLIST_TAB, lenPoss );
        else if (T_PLIST_CYC <= TNUM_OBJ(list) && TNUM_OBJ(list) <=
                                                  T_PLIST_CYC_SSORT+IMMUTABLE)
          elms = NEW_PLIST( T_PLIST_CYC, lenPoss );
        else if (T_PLIST_FFE <= TNUM_OBJ(list) && TNUM_OBJ(list) <=
                                                  T_PLIST_FFE+IMMUTABLE)
          elms = NEW_PLIST( T_PLIST_FFE, lenPoss );
        else if (HAS_FILT_LIST(list, FN_IS_HOMOG))
          elms = NEW_PLIST( T_PLIST_HOM, lenPoss );
        else
          elms = NEW_PLIST( T_PLIST, lenPoss);

        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {

            /* select the element                                          */
            elm = ELM_PLIST( list, pos );

            /* assign the element to <elms>                                */
            SET_ELM_PLIST( elms, i, elm );

        }

        /* notify Gasman                                                   */
        CHANGED_BAG( elms );

    }

    return elms;
}


/****************************************************************************
**
*F  UnbPlist( <list>, <pos> ) . . . . . . unbind an element from a plain list
**
**  'UnbPlist' unbinds the element at position  <pos>  from  the  plain  list
**  <list>.  It is the responsibility of the caller to ensure that  <pos>  is
**  positive.
**
**  'UnbPlist' is the function in 'UnbListFuncs' for plain lists.
*/
static void UnbPlist(Obj list, Int pos)
{
    /* if <pos> is less than the length, convert to plain list and unbind  */
    if ( pos < LEN_PLIST( list ) ) {
        RESET_FILT_LIST( list, FN_IS_DENSE );
        SET_ELM_PLIST( list, pos, 0 );
    }

    /* if <pos> is equal to the length, unbind and compute new length      */
    else if ( pos == LEN_PLIST( list ) ) {
        CLEAR_FILTS_LIST(list);
        SET_ELM_PLIST( list, pos, 0 );
        while ( 1 <= pos && ELM_PLIST( list, pos ) == 0 ) { pos--; }
        SET_LEN_PLIST( list, pos );
        if (LEN_PLIST(list) == 0)
            RetypeBagIfWritable(list, T_PLIST_EMPTY);
    }
}


/****************************************************************************
**
*F  AssPlist(<list>,<pos>,<val>)  . . . . . . . . . .  assign to a plain list
**
**  'AssPlist'  assigns  the value  <val>  to  the plain  list  <list> at the
**  position <pos>.  It  is the responsibility of the  caller to ensure  that
**  <pos> is positive, and that <val> is not 'Void'.
**
**  If the position is larger then the length of the list <list>, the list is
**  automatically  extended.  To avoid  making this too often, the bag of the
**  list is extended by at least '<length>/8 + 4' entries.  Thus in the loop
**
**      l := [];  for i in [1..1024]  do l[i] := i^2;  od;
**
**  the list 'l' is extended only 32 times not 1024 times.
**
**  'AssPlist' is the function in 'AssListFuncs' for plain lists.
*/
void            AssPlist (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    /* resize the list if necessary                                        */
    if ( LEN_PLIST( list ) < pos ) {
        GROW_PLIST( list, pos );
        SET_LEN_PLIST( list, pos );
    }

    /* now perform the assignment                                          */
    SET_ELM_PLIST( list, pos, val );
    if ( IS_BAG_REF( val ) )
        CHANGED_BAG( list );
}

static void AssPlistXXX(Obj list, Int pos, Obj val)
{
  Int len;

    /* the list will probably loose its flags/properties                   */
    CLEAR_FILTS_LIST(list);

    /* resize the list if necessary                                        */
    len = LEN_PLIST( list );
    if ( len < pos ) {
        GROW_PLIST( list, pos );
        SET_LEN_PLIST( list, pos );
    }

    /* now perform the assignment                                          */
    SET_ELM_PLIST( list, pos, val );
    if ( IS_BAG_REF( val ) )
        CHANGED_BAG( list );

    /* We may be able cheaply to tell that the list is non-dense          */
    if (len +1 < pos)
      SET_FILT_LIST(list, FN_IS_NDENSE);
}

static void AssPlistCyc(Obj list, Int pos, Obj val)
{
  Int len;

  /* resize the list if necessary                                        */
  len = LEN_PLIST( list );
  if ( len < pos ) {
    GROW_PLIST( list, pos );
    SET_LEN_PLIST( list, pos );
  }

    /* now perform the assignment                                          */
    SET_ELM_PLIST( list, pos, val );
    if ( IS_BAG_REF( val ) )
        CHANGED_BAG( list );

    /* try and maintain maximum information about the list                */
    if (pos > len + 1) {
        CLEAR_FILTS_LIST(list);
        SET_FILT_LIST( list, FN_IS_NDENSE );
    }
#ifdef HPCGAP
    else if (!CheckReadAccess(val)) {
        CLEAR_FILTS_LIST(list);
        SET_FILT_LIST( list, FN_IS_DENSE );
    }
#endif
    else if (!IS_CYC(val)) {
        CLEAR_FILTS_LIST(list);
        SET_FILT_LIST( list, FN_IS_DENSE );
    }
    else {
        RESET_FILT_LIST( list, FN_IS_NSORT );
        RESET_FILT_LIST( list, FN_IS_SSORT );
    }
}

void AssPlistFfe   (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    Int len;

    /* resize the list if necessary                                        */
    len = LEN_PLIST( list );
    if ( len < pos ) {
        GROW_PLIST( list, pos );
        SET_LEN_PLIST( list, pos );
    }

    /* now perform the assignment                                          */
    SET_ELM_PLIST( list, pos, val );
    if ( IS_BAG_REF( val ) )
        CHANGED_BAG( list );

    /* try and maintain maximum information about the list                 */
    if( pos > len + 1 ) {
        CLEAR_FILTS_LIST(list);
        SET_FILT_LIST( list, FN_IS_NDENSE );
    }
    else if( !IS_FFE(val) ) {
        CLEAR_FILTS_LIST(list);
        SET_FILT_LIST( list, FN_IS_DENSE );
    }
    else
      {
        FF ffval;
        Obj elm1;
        FF ffelm1;
        UInt otherpos;

        /* Here we select an other element to compare the field and
           possibly characteristic of the assigned value to. This
           code will never select pos, where the assignment has
           already been done, unless we are replacing the only entry
           of a length 1 list, in which case the result will always
           still be a vecffe, so we are happy */

        if (pos == 1)
          otherpos = len;
        else
          otherpos = 1;
        elm1 = ELM_PLIST( list, otherpos);
        ffval = FLD_FFE(val);
        ffelm1 = FLD_FFE(elm1);
        if( ffval != ffelm1 ) {
          CLEAR_FILTS_LIST(list);
          SET_FILT_LIST( list, FN_IS_DENSE );
          if (CHAR_FF(ffval) == CHAR_FF(ffelm1))
            SET_FILT_LIST( list, FN_IS_HOMOG );
        }
        else
          {
            RESET_FILT_LIST( list, FN_IS_NSORT );
            RESET_FILT_LIST( list, FN_IS_SSORT );
          }
      }
}

static void AssPlistDense(Obj list, Int pos, Obj val)
{
  Int len;

  /* the list will probably loose its flags/properties                   */
  CLEAR_FILTS_LIST(list);

  /* resize the list if necessary                                        */
  len = LEN_PLIST( list );
  if ( len < pos ) {
    GROW_PLIST( list, pos );
    SET_LEN_PLIST( list, pos );
  }

    /* now perform the assignment                                          */
    SET_ELM_PLIST( list, pos, val );
    CHANGED_BAG( list );

    /* restore denseness if we can */
    if (pos <= len+1)
      SET_FILT_LIST( list, FN_IS_DENSE );
    else
        SET_FILT_LIST( list, FN_IS_NDENSE );
}

static void AssPlistHomog(Obj list, Int pos, Obj val)
{
  Int len;
  Obj fam;

  /* the list may loose its flags/properties                   */
  CLEAR_FILTS_LIST(list);

  /* resize the list if necessary                                        */
  len = LEN_PLIST( list );
  if ( len < pos ) {
    GROW_PLIST( list, pos );
    SET_LEN_PLIST( list, pos );
  }

    /* now perform the assignment                                          */
    SET_ELM_PLIST( list, pos, val );
    CHANGED_BAG( list );

    /* restore denseness if we can */
    if (pos <= len+1)
      {
        SET_FILT_LIST( list, FN_IS_DENSE );

        /* In this case, we may be able to restore homogeneity */
        if (len == 1 && pos == 1)
          {

            /* case of replacing the only list element */
            if (IS_CYC( val ))
              {
                RetypeBag( list, T_PLIST_CYC_SSORT );
              }
            else
              {
                SET_FILT_LIST( list, FN_IS_HOMOG );
                SET_FILT_LIST( list, FN_IS_SSORT );
              }
          }
#ifdef HPCGAP
        else if (!CheckReadAccess(val)) {
          SET_FILT_LIST(list, FN_IS_NHOMOG);
        }
#endif
        else if (!SyInitializing && !IS_MUTABLE_OBJ(val))
          {
            /* find the family of an original list element */
            if (pos != 1)
              fam = FAMILY_OBJ(ELM_PLIST(list, 1));
            else
              fam = FAMILY_OBJ(ELM_PLIST(list, 2));

            /* restore homogeneity if we can */
            if (fam == FAMILY_OBJ( val ))
              SET_FILT_LIST(list, FN_IS_HOMOG);
            else
              SET_FILT_LIST(list, FN_IS_NHOMOG);
          }
      }
    else
      SET_FILT_LIST( list, FN_IS_NDENSE );

}


/****************************************************************************
**
*F  AssPlistEmpty( <list>, <pos>, <val> ) . . . . .  assignment to empty list
*/
void AssPlistEmpty (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    /* if <pos> is large than one use `AssPlistDense'                      */
    if ( 1 != pos ) {
        AssPlistDense( list, pos, val );
    }

    /* catch booleans                                                      */
    else if ( val == True || val == False ) {
        ConvBlist(list);
        AssBlist( list, pos, val );
    }

#ifdef HPCGAP
    else if (!CheckReadAccess(val)) {
        RetypeBag( list, T_PLIST );
        AssPlistXXX( list, pos, val );
    }
#endif
    /* catch constants                                                     */
    else if ( TNUM_OBJ(val) < FIRST_EXTERNAL_TNUM ) {
        AssPlistXXX( list, pos, val );

        // fix up type
        if (IS_CYC(val))
            RetypeBag(list, T_PLIST_CYC_SSORT);
        else if (IS_FFE(val))
            RetypeBag(list, T_PLIST_FFE);
        else {
            SET_FILT_LIST(list, FN_IS_DENSE);
            if (!IS_MUTABLE_OBJ(val)) {
                SET_FILT_LIST(list, FN_IS_HOMOG);
            }
        }
    }


    /* use method selection                                                */
    else {
      /* early in initialization, the type of the empty list may not be
         available, in which case we must NOT call method selection */
      if (TYPE_LIST_EMPTY_MUTABLE != 0)
        AssListObject( list, pos, val );
      else
        AssPlistXXX( list, pos, val );
    }

}


/****************************************************************************
**
*F  AsssPlist(<list>,<poss>,<vals>) . . . . assign several elements to a list
**
**  'AsssPlist' assigns the   values from the list  <vals>  at the positions
**  given in the list <poss> to the list <list>.  It is the responsibility of
**  the caller  to  ensure that <poss> is   dense and contains  only positive
**  integers, that <poss> and <vals> have the same length, and that <vals> is
**  dense.
**
**  'AsssPlist' is the function in 'AsssListFuncs' for plain lists.
*/
static void AsssPlist(Obj list, Obj poss, Obj vals)
{
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 max;            /* larger position                 */
    Int                 inc;            /* increment in a range            */
    Obj                 val;            /* one element from <vals>         */
    Int                 i;              /* loop variable                   */

    /* general code                                                        */
    if ( ! IS_RANGE(poss) ) {

        /* get the length of <positions>                                   */
        lenPoss = LEN_LIST( poss );

        /* find the largest entry in <positions>                           */
        max = LEN_PLIST( list );
        for ( i = 1; i <= lenPoss; i++ ) {
            if ( max < INT_INTOBJ( ELMW_LIST( poss, i ) ) )
                max = INT_INTOBJ( ELMW_LIST( poss, i ) );
        }

        /* resize the list if necessary                                    */
        if ( LEN_PLIST(list) < max ) {
            GROW_PLIST( list, max );
            SET_LEN_PLIST( list, max );
        }

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );

            /* select the element                                          */
            val = ELMW_LIST( vals, i );

            /* assign the element into <elms>                              */
            SET_ELM_PLIST( list, pos, val );

        }

        /* notify Gasman                                                   */
        CHANGED_BAG( list );

    }

    /* special code for ranges                                             */
    else {

        /* get the length of <positions>                                   */
        lenPoss = GET_LEN_RANGE( poss );
        pos = GET_LOW_RANGE( poss );
        inc = GET_INC_RANGE( poss );

        /* find the largest entry in <positions>                           */
        max = LEN_PLIST( list );
        if ( max < pos )
            max = pos;
        if ( max < pos + (lenPoss-1) * inc )
            max = pos + (lenPoss-1) * inc;

        /* resize the list if necessary                                    */
        if ( LEN_PLIST(list) < max ) {
            GROW_PLIST( list, max );
            SET_LEN_PLIST( list, max );
        }

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {

            /* select the element                                          */
            val = ELMW_LIST( vals, i );

            /* assign the element to <elms>                                */
            SET_ELM_PLIST( list, pos, val );

        }

        /* notify Gasman                                                   */
        CHANGED_BAG( list );

    }
}

static void AsssPlistXXX(Obj list, Obj poss, Obj vals)
{
    /* the list will probably loose its flags/properties                   */
    CLEAR_FILTS_LIST(list);

    /* and delegate                                                        */
    AsssPlist( list, poss, vals );
}


/****************************************************************************
**
*F  IsDensePlist(<list>)  . . . . .  dense list test function for plain lists
**
**  'IsDensePlist' returns 1 if the plain list <list> is a dense list and 0
**  otherwise.
**
**  'IsDensePlist' is the function in 'IsDenseListFuncs' for plain lists.
*/
static BOOL IsDensePlist(Obj list)
{
    Int                 lenList;        /* length of <list>                */
    Int                 i;              /* loop variable                   */

    /* get the length of the list                                          */
    lenList = LEN_PLIST( list );

    /* special case for empty list                                         */
    if ( lenList == 0 ) {
        RetypeBagSMIfWritable(list, T_PLIST_EMPTY);
        return TRUE;
    }

    /* loop over the entries of the list                                   */
    for ( i = 1; i <= lenList; i++ ) {
        if ( ELM_PLIST( list, i ) == 0 )
            return FALSE;
    }

    /* set the dense flag (even if the elements are mutable)               */
    SET_FILT_LIST( list, FN_IS_DENSE );

    /* no hole found                                                       */
    return TRUE;
}


/****************************************************************************
**
*F  IsHomogPlist(<list>)  . .  homogeneous list test function for plain lists
**
**  'IsHomogPlist' returns  1 if the plain  list <list> is a homogeneous list
**  and 0 otherwise.
**
**  'IsHomogPlist' is the function in 'IsHomogListFuncs' for plain lists.
*/
static BOOL IsHomogPlist(Obj list)
{
    Int                 tnum;
    tnum = KTNumPlist( list, (Obj *)0 );
    return (T_PLIST_HOM <= tnum);
}


/****************************************************************************
**
*F  IsTablePlist(<list>)  . . . . . . . . table test function for plain lists
**
**  'IsTablePlist' returns  1 if the plain list  <list> is a homogeneous list
**  of lists and 0 otherwise.
**
**  'IsTablePlist' is the function in 'IsTableListFuncs' for plain lists.
*/
static BOOL IsTablePlist(Obj list)
{
    Int                 tnum;
    tnum = KTNumPlist( list, (Obj *)0 );
    return (T_PLIST_TAB <= tnum && tnum <= T_PLIST_TAB_RECT_SSORT);
}


/****************************************************************************
**
*F  IsSSortPlist(<list>)  . . . . . sorted list test function for plain lists
**
**  'IsSSortPlist'  returns 1  if the  plain  list <list>  is strictly sorted
**  (each element is strictly smaller than the next one), and 0 otherwise.
**
**  'IsSSortPlist' is the function in 'IsSSortListFuncs' for plain lists.
*/

static BOOL IsSSortPlist(Obj list)
{
    Int                 lenList;
    Obj elm1;
    Obj elm2;
    Int                 areMut;
    Int                 i;
    Obj                 fam=0;    /* initialize to help compiler */
    Int                 isHom;

    /* get the length                                                      */
    lenList = LEN_PLIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        RetypeBagSMIfWritable(list, T_PLIST_EMPTY);
        return TRUE;
    }

    /* get the first element                                               */
    elm1    = ELM_PLIST( list, 1 );
    if (elm1 == 0)
      goto notDense;
#ifdef HPCGAP
    if (!CheckReadAccess(elm1))
      return FALSE;
#endif
    areMut   = IS_MUTABLE_OBJ( elm1 );
    if (!SyInitializing)
      {
        fam = FAMILY_OBJ(elm1);
        isHom = 1;
      }
    else
      isHom = 0;

    /* loop over the other elements                                        */
    for ( i = 2; i <= lenList; i++ ) {
      elm2 = ELM_PLIST( list, i );
      if (elm2 == 0)
        goto notDense;
#ifdef HPCGAP
      if (!CheckReadAccess(elm2))
        return FALSE;
#endif
      if ( ! LT( elm1, elm2 ) )
        break;
      areMut = (areMut || IS_MUTABLE_OBJ( elm2 ));
      isHom = (isHom && fam == FAMILY_OBJ(elm2 ));
      elm1 = elm2;
      }
    /* set flags (unless the elements are mutable)                      */

    /* If we found inhomogeneity then it is real  */
    if (!areMut && !isHom)
      {
        SET_FILT_LIST(list,FN_IS_NHOMOG);
      }

    if ( lenList < i ) {
      /* we got to the end, so there were no holes */
      SET_FILT_LIST( list, FN_IS_DENSE);

      /* and we know about homogeneity */
      if ( ! areMut ) {
        if (isHom)
          SET_FILT_LIST( list, FN_IS_HOMOG);
        else
          SET_FILT_LIST( list, FN_IS_NHOMOG);
        SET_FILT_LIST( list, FN_IS_SSORT );
      }
      return TRUE;
    }
    else {
      if ( ! areMut ) {
        SET_FILT_LIST( list, FN_IS_NSORT );
      }
      return FALSE;

    }

 notDense:
    SET_FILT_LIST( list, FN_IS_NDENSE );
    return FALSE;
}

static BOOL IsSSortPlistDense(Obj list)
{
    Int                 lenList;
    Obj elm1;
    Obj elm2;
    Int                 areMut;
    Int                 i;
    Obj                 fam=0;     /* initialize to help compiler */
    Int                 isHom;

    /* get the length                                                      */
    lenList = LEN_PLIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        RetypeBagSMIfWritable(list, T_PLIST_EMPTY);
        return TRUE;
    }

    /* get the first element                                               */
    elm1    = ELM_PLIST( list, 1 );
#ifdef HPCGAP
    if (!CheckReadAccess(elm1))
      return FALSE;
#endif
    areMut   = IS_MUTABLE_OBJ( elm1 );
    if (!SyInitializing)
      {
        fam = FAMILY_OBJ(elm1);
        isHom = 1;
      }
    else
      isHom = 0;

    /* loop over the other elements                                        */
    for ( i = 2; i <= lenList; i++ ) {
      elm2 = ELM_PLIST( list, i );
#ifdef HPCGAP
      if (!CheckReadAccess(elm2))
        return FALSE;
#endif
      if ( ! LT( elm1, elm2 ) )
        break;
      areMut = (areMut || IS_MUTABLE_OBJ( elm2 ));
      isHom = (isHom && fam == FAMILY_OBJ(elm2 ));
      elm1 = elm2;
      }
    /* set flags (unless the elements are mutable)                      */

    if (!areMut && !isHom)
      SET_FILT_LIST( list, FN_IS_NHOMOG);
    if ( lenList < i ) {
      if ( ! areMut ) {
        if (isHom)
          SET_FILT_LIST( list, FN_IS_HOMOG);
        else
          SET_FILT_LIST( list, FN_IS_NHOMOG);
        SET_FILT_LIST( list, FN_IS_SSORT );
      }
      return TRUE;
    }
    else {
        if ( ! areMut ) {
          SET_FILT_LIST( list, FN_IS_NSORT );
        }
        return FALSE;
    }

}

static BOOL IsSSortPlistHom(Obj list)
{
    Int                 lenList;
    Obj elm1;
    Obj elm2;
    Int                 i;

    /* get the length                                                      */
    lenList = LEN_PLIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        RetypeBagSMIfWritable(list, T_PLIST_EMPTY);
        return TRUE;
    }

    /* get the first element                                               */
    elm1    = ELM_PLIST( list, 1 );
#ifdef HPCGAP
    if (!CheckReadAccess(elm1))
      return FALSE;
#endif

    /* loop over the other elements                                        */
    for ( i = 2; i <= lenList; i++ ) {
      elm2 = ELM_PLIST( list, i );
#ifdef HPCGAP
      if (!CheckReadAccess(elm2))
        return FALSE;
#endif
      if ( ! LT( elm1, elm2 ) )
        break;
      elm1 = elm2;
      }
    /* set flags      */

    if ( lenList < i ) {
      SET_FILT_LIST( list, FN_IS_SSORT );
      return TRUE;
    }
    else {
      SET_FILT_LIST( list, FN_IS_NSORT );
      return FALSE;
    }

}


static Obj FuncSET_IS_SSORTED_PLIST(Obj self, Obj list)
{
  SET_FILT_LIST(list, FN_IS_SSORT);
  return (Obj)0;
}


/****************************************************************************
**
*F  IsPossPlist(<list>) . . . .  positions list test function for plain lists
**
**  'IsPossPlist'  returns   1 if the plain    list <list> is  a   dense list
**  containing only positive integers, and 0 otherwise.
**
**  'IsPossPlist' is the function in 'IsPossListFuncs' for plain lists.
*/
static BOOL IsPossPlist(Obj list)
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Int                 i;              /* loop variable                   */

    /* get the length of the variable                                      */
    lenList = LEN_PLIST( list );

    /* loop over the entries of the list                                   */
    for ( i = 1; i <= lenList; i++ ) {
        elm = ELM_PLIST( list, i );
        if (elm == 0)
          return FALSE;
#ifdef HPCGAP
        if ( !CheckReadAccess(elm) )
          return FALSE;
#endif
        if (IS_INTOBJ(elm))
          {
            if (INT_INTOBJ(elm) <= 0 )
              return FALSE;
          }
        else
          if (TNUM_OBJ(elm) != T_INTPOS)
            return FALSE;
    }

    /* no problems found                                                   */
    return TRUE;
}


/****************************************************************************
**
*F  PosPlist(<list>,<val>,<start>)  . . . .  position of an element in a list
**
**  'PosPlist'  returns the  position  of the value  <val>  in the plain list
**  <list> after the first position <start> as a C integer.  0 is returned if
**  <val> is not in the list.
**
**  'PosPlist' is the function in 'PosListFuncs' for plain lists.
*/
static Obj PosPlist(Obj list, Obj val, Obj start)
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Int                 i;              /* loop variable                   */
    UInt istart;

    /* if the starting position is too big to be a small int
       then there can't be anything to find */
    if (!IS_INTOBJ(start))
      return Fail;

    istart = INT_INTOBJ(start);

    /* get the length of <list>                                            */
    lenList = LEN_PLIST( list );

    /* loop over all entries in <list>                                     */
    for ( i = istart+1; i <= lenList; i++ ) {

        /* select one element from <list>                                  */
        elm = ELM_PLIST( list, i );

        /* compare with <val>                                              */
        if ( elm != 0 && EQ( elm, val ) )
            break;

    }

    /* return the position (0 if <val> was not found)                      */
    return (lenList < i ? Fail : INTOBJ_INT(i));
}

static Obj PosPlistDense(Obj list, Obj val, Obj start)
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Int                 i;              /* loop variable                   */
    UInt istart;

    /* if the starting position is too big to be a small int
       then there can't be anything to find */
    if (!IS_INTOBJ(start))
      return Fail;

    istart = INT_INTOBJ(start);

    /* get the length of <list>                                            */
    lenList = LEN_PLIST( list );

    /* loop over all entries in <list>                                     */
    for ( i = istart+1; i <= lenList; i++ ) {

        /* select one element from <list>                                  */
        elm = ELM_PLIST( list, i );
        assert(elm);

        /* compare with <val>                                              */
        if ( EQ( elm, val ) )
            break;

    }

    /* return the position (0 if <val> was not found)                      */
    return (lenList < i ? Fail : INTOBJ_INT(i));
}

static Obj PosPlistSort(Obj list, Obj val, Obj start)
{
    UInt                lenList;        /* logical length of the set       */
    UInt                i, j, k;        /* loop variables                  */
    UInt                istart;

    /* if the starting position is too big to be a small int
       then there can't be anything to find */
    if (!IS_INTOBJ(start))
      return Fail;

    istart = INT_INTOBJ(start);

    /* get a pointer to the set and the logical length of the set          */
    lenList = LEN_PLIST(list);

    /* perform the binary search to find the position                      */
    i = istart;  k = lenList + 1;
    while ( i+1 < k ) {                 /* set[i] < elm && elm <= set[k]   */
        j = (i + k) / 2;                /* i < j < k                       */
        if ( LT( ELM_PLIST(list,j), val ) )  i = j;
        else                                 k = j;
    }

    /* test if the element was found at position k                         */
    if ( lenList < k || ! EQ( ELM_PLIST(list,k), val ) )
        k = 0;

    /* return the position                                                 */
    return k == 0 ? Fail : INTOBJ_INT(k);
}


static Obj PosPlistHomSort(Obj list, Obj val, Obj start)
{
    /* deal with the case which can be decided by the family relationship  */
    if (FAMILY_OBJ(val) != FAMILY_OBJ(ELM_PLIST(list,1)))
      return Fail;

    return PosPlistSort(list, val, start);
}


/****************************************************************************
**
*F  PlainPlist(<list>)  . . . . . . . .  convert a plain list to a plain list
**
**  'PlainPlist' converts the plain  list <list> to a  plain list.  Not  much
**  work.
**
**  'PlainPlist' is the function in 'PlainListFuncs' for plain lists.
*/
static void PlainPlist(Obj list)
{
}

/****************************************************************************
**
*F  SavePlist( <list> )
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SavePlist(Obj list)
{
  UInt i;
  SaveUInt(LEN_PLIST(list));
  for (i = 1; i <= LEN_PLIST(list); i++)
    SaveSubObj(ELM_PLIST(list,i));
}
#endif


/****************************************************************************
**
*F  LoadPlist( <list> )
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadPlist(Obj list)
{
  UInt i;
  SET_LEN_PLIST(list, LoadUInt());
  for (i = 1; i <= LEN_PLIST(list); i++)
    SET_ELM_PLIST(list,i, LoadSubObj());
}
#endif


/****************************************************************************
**
*F  FuncASS_PLIST_DEFAULT( <self>, <plist>, <pos>, <val> )  . . `AssPlistXXX'
*/
static Obj FuncASS_PLIST_DEFAULT(Obj self, Obj plist, Obj pos, Obj val)
{
    Int                 p;

    p = GetPositiveSmallInt("List Assignment", pos);
    if (!IS_PLIST(plist) || !IS_PLIST_MUTABLE(plist)) {
        RequireArgumentEx(0, plist, "<list>", "must be a mutable plain list");
    }

    /* call `AssPlistXXX'                                                  */
    AssPlistXXX( plist, p, val );
    return 0;
}

/****************************************************************************
**
*F  MakeImmutablePlistInHom( <plist> )
**
**  This is the function for Plists that might have mutable subobjects
**  which is currently exactly those that are not known to be homogenous
**  (or immutable, but MakeImmutable will have caught that case before we get
**  here)
*/

static void MakeImmutablePlistInHom(Obj list)
{
    // change the tnum first, to avoid infinite recursion for objects that
    // contain themselves
    MakeImmutableNoRecurse(list);

    // FIXME HPC-GAP: there is a potential race here: <list> becomes public
    // the moment we change its type, but it's not ready for public access
    // until the following code completed.

    UInt len = LEN_PLIST(list);
    for (UInt i = 1; i <= len; i++) {
        Obj elm = ELM_PLIST(list, i);
        if (elm != 0) {
            MakeImmutable(elm);
        }
    }
}

/****************************************************************************
**
*F  MakeImmutablePlistNoMutElms( <plist> )
**
**  This is the function for Plists that cannot have mutable subobjects
**  which is currently  those that are  known to be homogenous or known to
**  be non-homogenous
**  (or immutable, but MakeImmutable will have caught that case before we get
**  here)
*/

static void MakeImmutablePlistNoMutElms(Obj list)
{
    MakeImmutableNoRecurse(list);
}

/****************************************************************************
**
*F  FuncIsRectangularTablePlist( <plist> )
**
**  Determine whether a PLIST is a rectangular table, set the TNUM
**  appropriately. This is a method for IsRectangularTable, so the
**  method selection has already checked that the list is a table
**  and should not bother to call us, unless we do not already know whether
**  it is rectangular
*/

static Obj FuncIsRectangularTablePlist(Obj self, Obj plist)
{
  Obj len;
  UInt lenlist;
  UInt i;
  UInt hasMut = 0;
  Obj elm;

  assert(!HAS_FILT_LIST(plist, FN_IS_RECT));
  lenlist = LEN_PLIST(plist);
  assert(lenlist);
  if (lenlist == 1)
    {
      if (!IS_MUTABLE_OBJ(ELM_PLIST(plist,1)))
        SET_FILT_LIST(plist, FN_IS_RECT);
      return True;
    }
  elm = ELM_PLIST(plist,1);
  len = LENGTH(elm);
  hasMut = IS_MUTABLE_OBJ(elm);
  for (i = 2; i <= lenlist; i++)
    {
      elm = ELM_PLIST(plist,i);
      if (!EQ(len, LENGTH(elm)))
        return False;
      hasMut = hasMut || IS_MUTABLE_OBJ(elm);
    }
  if (!hasMut)
    SET_FILT_LIST(plist, FN_IS_RECT);
  return True;

}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_PLIST,                                "plain list" },
  { T_PLIST            +IMMUTABLE,          "immutable plain list" },

  { T_PLIST_NDENSE,                         "non-dense plain list" },
  { T_PLIST_NDENSE     +IMMUTABLE,          "immutable non-dense plain list" },

  { T_PLIST_DENSE,                          "dense plain list" },
  { T_PLIST_DENSE      +IMMUTABLE,          "immutable dense plain list" },

  { T_PLIST_DENSE_NHOM,                     "dense non-homogeneous plain list" },
  { T_PLIST_DENSE_NHOM +IMMUTABLE,          "immutable dense non-homogeneous plain list" },

  { T_PLIST_DENSE_NHOM_SSORT,               "dense non-homogeneous strictly-sorted plain list" },
  { T_PLIST_DENSE_NHOM_SSORT +IMMUTABLE,    "immutable dense non-homogeneous strictly-sorted plain list" },

  { T_PLIST_DENSE_NHOM_NSORT,               "dense non-homogeneous non-strictly-sorted plain list" },
  { T_PLIST_DENSE_NHOM_NSORT +IMMUTABLE,    "immutable dense non-homogeneous non-strictly-sorted plain list" },

  { T_PLIST_EMPTY,                          "empty plain list" },
  { T_PLIST_EMPTY      +IMMUTABLE,          "immutable empty plain list" },

  { T_PLIST_HOM,                            "homogeneous plain list" },
  { T_PLIST_HOM        +IMMUTABLE,          "immutable homogeneous plain list" },

  { T_PLIST_HOM_NSORT,                      "homogeneous non-strictly-sorted plain list" },
  { T_PLIST_HOM_NSORT  +IMMUTABLE,          "immutable homogeneous non-strictly-sorted plain list" },

  { T_PLIST_HOM_SSORT,                      "homogeneous strictly-sorted plain list" },
  { T_PLIST_HOM_SSORT +IMMUTABLE,           "immutable homogeneous strictly-sorted plain list" },

  { T_PLIST_TAB,                            "plain list (table)" },
  { T_PLIST_TAB       +IMMUTABLE,           "immutable plain list (table)" },

  { T_PLIST_TAB_NSORT,                      "non-strictly-sorted plain list (table)" },
  { T_PLIST_TAB_NSORT +IMMUTABLE,           "immutable non-strictly-sorted plain list (table)" },

  { T_PLIST_TAB_SSORT,                      "strictly-sorted plain list (table)" },
  { T_PLIST_TAB_SSORT +IMMUTABLE,           "immutable strictly-sorted plain list (table)" },

  { T_PLIST_TAB_RECT,                       "plain list (rectangular table)" },
  { T_PLIST_TAB_RECT       +IMMUTABLE,      "immutable plain list (rectangular table)" },

  { T_PLIST_TAB_RECT_NSORT,                 "non-strictly-sorted plain list (rectangular table)" },
  { T_PLIST_TAB_RECT_NSORT +IMMUTABLE,      "immutable non-strictly-sorted plain list (rectangular table)" },

  { T_PLIST_TAB_RECT_SSORT,                 "strictly-sorted plain list (rectangular table)" },
  { T_PLIST_TAB_RECT_SSORT +IMMUTABLE,      "immutable strictly-sorted plain list (rectangular table)" },

  { T_PLIST_CYC,                            "plain list of cyclotomics" },
  { T_PLIST_CYC       +IMMUTABLE,           "immutable plain list of cyclotomics" },

  { T_PLIST_CYC_NSORT,                      "non-strictly-sorted plain list of cyclotomics" },
  { T_PLIST_CYC_NSORT +IMMUTABLE,           "immutable non-strictly-sorted plain list of cyclotomics" },

  { T_PLIST_CYC_SSORT,                      "strictly-sorted plain list of cyclotomics" },
  { T_PLIST_CYC_SSORT +IMMUTABLE,           "immutable strictly-sorted plain list of cyclotomics" },

  { T_PLIST_FFE,                            "plain list of small finite field elements" },
  { T_PLIST_FFE +IMMUTABLE,                 "immutable plain list of small finite field elements" },

  { -1,                                     "" }
};


/****************************************************************************
**
*V  ClearFiltsTab . . . . . . . . . . . . . . . . . . . .  clear filter tnums
*/
static Int ClearFiltsTab [] = {
    T_PLIST,                          T_PLIST,
    T_PLIST_NDENSE,                   T_PLIST,
    T_PLIST_DENSE,                    T_PLIST,
    T_PLIST_DENSE_NHOM,               T_PLIST,
    T_PLIST_DENSE_NHOM_SSORT,         T_PLIST,
    T_PLIST_DENSE_NHOM_NSORT,         T_PLIST,
    T_PLIST_EMPTY,                    T_PLIST,
    T_PLIST_HOM,                      T_PLIST,
    T_PLIST_HOM_NSORT,                T_PLIST,
    T_PLIST_HOM_SSORT,                T_PLIST,
    T_PLIST_TAB,                      T_PLIST,
    T_PLIST_TAB_NSORT,                T_PLIST,
    T_PLIST_TAB_SSORT,                T_PLIST,
    T_PLIST_TAB_RECT,                 T_PLIST,
    T_PLIST_TAB_RECT_NSORT,           T_PLIST,
    T_PLIST_TAB_RECT_SSORT,           T_PLIST,
    T_PLIST_CYC,                      T_PLIST,
    T_PLIST_CYC_NSORT,                T_PLIST,
    T_PLIST_CYC_SSORT,                T_PLIST,
    T_PLIST_FFE,                      T_PLIST,

    -1,                               -1
};


/****************************************************************************
**
*V  HasFiltTab  . . . . . . . . . . . . . . . . . . . . .  tester filter tnum
*/
static Int HasFiltTab [] = {

    // plain lists
    T_PLIST,                      FN_IS_DENSE,    0,
    T_PLIST,                      FN_IS_NDENSE,   0,
    T_PLIST,                      FN_IS_HOMOG,    0,
    T_PLIST,                      FN_IS_NHOMOG,   0,
    T_PLIST,                      FN_IS_TABLE,    0,
    T_PLIST,                      FN_IS_RECT,     0,
    T_PLIST,                      FN_IS_SSORT,    0,
    T_PLIST,                      FN_IS_NSORT,    0,

    // empty list
    T_PLIST_EMPTY,                FN_IS_DENSE,    1,
    T_PLIST_EMPTY,                FN_IS_NDENSE,   0,
    T_PLIST_EMPTY,                FN_IS_HOMOG,    1,
    T_PLIST_EMPTY,                FN_IS_NHOMOG,   0,
    T_PLIST_EMPTY,                FN_IS_TABLE,    0,
    T_PLIST_EMPTY,                FN_IS_RECT,     0,
    T_PLIST_EMPTY,                FN_IS_SSORT,    1,
    T_PLIST_EMPTY,                FN_IS_NSORT,    0,

    // dense list
    T_PLIST_DENSE,                FN_IS_DENSE,    1,
    T_PLIST_DENSE,                FN_IS_NDENSE,   0,
    T_PLIST_DENSE,                FN_IS_HOMOG,    0,
    T_PLIST_DENSE,                FN_IS_NHOMOG,   0,
    T_PLIST_DENSE,                FN_IS_TABLE,    0,
    T_PLIST_DENSE,                FN_IS_RECT,     0,
    T_PLIST_DENSE,                FN_IS_SSORT,    0,
    T_PLIST_DENSE,                FN_IS_NSORT,    0,

    // dense list, which contains immutables and is not homog
    T_PLIST_DENSE_NHOM,           FN_IS_DENSE,    1,
    T_PLIST_DENSE_NHOM,           FN_IS_NDENSE,   0,
    T_PLIST_DENSE_NHOM,           FN_IS_HOMOG,    0,
    T_PLIST_DENSE_NHOM,           FN_IS_NHOMOG,   1,
    T_PLIST_DENSE_NHOM,           FN_IS_TABLE,    0,
    T_PLIST_DENSE_NHOM,           FN_IS_RECT,     0,
    T_PLIST_DENSE_NHOM,           FN_IS_SSORT,    0,
    T_PLIST_DENSE_NHOM,           FN_IS_NSORT,    0,

    // dense ssorted list, which contains immutables and is not homog
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_DENSE,    1,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_NDENSE,   0,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_HOMOG,    0,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_NHOMOG,   1,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_TABLE,    0,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_RECT,     0,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_SSORT,    1,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_NSORT,    0,

    // dense nsorted list, which contains immutables and is not homog
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_DENSE,    1,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_NDENSE,   0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_HOMOG,    0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_NHOMOG,   1,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_TABLE,    0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_RECT,     0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_SSORT,    0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_NSORT,    1,

    // a mutable list with holes
    T_PLIST_NDENSE,               FN_IS_DENSE,    0,
    T_PLIST_NDENSE,               FN_IS_NDENSE,   1,
    T_PLIST_NDENSE,               FN_IS_HOMOG,    0,
    T_PLIST_NDENSE,               FN_IS_NHOMOG,   0,
    T_PLIST_NDENSE,               FN_IS_TABLE,    0,
    T_PLIST_NDENSE,               FN_IS_RECT,     0,
    T_PLIST_NDENSE,               FN_IS_SSORT,    0,
    T_PLIST_NDENSE,               FN_IS_NSORT,    0,

    // dense list, which conts imms, is homogeneous, not a table
    T_PLIST_HOM,                  FN_IS_DENSE,    1,
    T_PLIST_HOM,                  FN_IS_NDENSE,   0,
    T_PLIST_HOM,                  FN_IS_HOMOG,    1,
    T_PLIST_HOM,                  FN_IS_NHOMOG,   0,
    T_PLIST_HOM,                  FN_IS_TABLE,    0,
    T_PLIST_HOM,                  FN_IS_RECT,     0,
    T_PLIST_HOM,                  FN_IS_SSORT,    0,
    T_PLIST_HOM,                  FN_IS_NSORT,    0,

    // ssort dense list, which conts imms, is homog, not a table
    T_PLIST_HOM_SSORT,            FN_IS_DENSE,    1,
    T_PLIST_HOM_SSORT,            FN_IS_NDENSE,   0,
    T_PLIST_HOM_SSORT,            FN_IS_HOMOG,    1,
    T_PLIST_HOM_SSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_HOM_SSORT,            FN_IS_TABLE,    0,
    T_PLIST_HOM_SSORT,            FN_IS_RECT,     0,
    T_PLIST_HOM_SSORT,            FN_IS_SSORT,    1,
    T_PLIST_HOM_SSORT,            FN_IS_NSORT,    0,

    // nsort dense list, which conts imms, is homog, not a table
    T_PLIST_HOM_NSORT,            FN_IS_DENSE,    1,
    T_PLIST_HOM_NSORT,            FN_IS_NDENSE,   0,
    T_PLIST_HOM_NSORT,            FN_IS_HOMOG,    1,
    T_PLIST_HOM_NSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_HOM_NSORT,            FN_IS_TABLE,    0,
    T_PLIST_HOM_NSORT,            FN_IS_RECT,     0,
    T_PLIST_HOM_NSORT,            FN_IS_SSORT,    0,
    T_PLIST_HOM_NSORT,            FN_IS_NSORT,    1,

    // dense list, which is immutable, homog, non-empty, table
    T_PLIST_TAB,                  FN_IS_DENSE,    1,
    T_PLIST_TAB,                  FN_IS_NDENSE,   0,
    T_PLIST_TAB,                  FN_IS_HOMOG,    1,
    T_PLIST_TAB,                  FN_IS_NHOMOG,   0,
    T_PLIST_TAB,                  FN_IS_TABLE,    1,
    T_PLIST_TAB,                  FN_IS_RECT,     0,
    T_PLIST_TAB,                  FN_IS_SSORT,    0,
    T_PLIST_TAB,                  FN_IS_NSORT,    0,

    // ssort, dense list, which is imm, homog, non-empty, table
    T_PLIST_TAB_SSORT,            FN_IS_DENSE,    1,
    T_PLIST_TAB_SSORT,            FN_IS_NDENSE,   0,
    T_PLIST_TAB_SSORT,            FN_IS_HOMOG,    1,
    T_PLIST_TAB_SSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_TAB_SSORT,            FN_IS_TABLE,    1,
    T_PLIST_TAB_SSORT,            FN_IS_RECT,     0,
    T_PLIST_TAB_SSORT,            FN_IS_SSORT,    1,
    T_PLIST_TAB_SSORT,            FN_IS_NSORT,    0,

    // nsort, dense list, which is imm, homog, non-empty, table
    T_PLIST_TAB_NSORT,            FN_IS_DENSE,    1,
    T_PLIST_TAB_NSORT,            FN_IS_NDENSE,   0,
    T_PLIST_TAB_NSORT,            FN_IS_HOMOG,    1,
    T_PLIST_TAB_NSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_TAB_NSORT,            FN_IS_TABLE,    1,
    T_PLIST_TAB_NSORT,            FN_IS_RECT,     0,
    T_PLIST_TAB_NSORT,            FN_IS_SSORT,    0,
    T_PLIST_TAB_NSORT,            FN_IS_NSORT,    1,

    // dense list, which is immutable, homog, non-empty, rect table
    T_PLIST_TAB_RECT,                  FN_IS_DENSE,    1,
    T_PLIST_TAB_RECT,                  FN_IS_NDENSE,   0,
    T_PLIST_TAB_RECT,                  FN_IS_HOMOG,    1,
    T_PLIST_TAB_RECT,                  FN_IS_NHOMOG,   0,
    T_PLIST_TAB_RECT,                  FN_IS_TABLE,    1,
    T_PLIST_TAB_RECT,                  FN_IS_RECT,     1,
    T_PLIST_TAB_RECT,                  FN_IS_SSORT,    0,
    T_PLIST_TAB_RECT,                  FN_IS_NSORT,    0,

    // ssort, dense list, which is imm, homog, non-empty, rect table
    T_PLIST_TAB_RECT_SSORT,            FN_IS_DENSE,    1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NDENSE,   0,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_HOMOG,    1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_TABLE,    1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_RECT,     1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_SSORT,    1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NSORT,    0,

    // nsort, dense list, which is imm, homog, non-empty, rect table
    T_PLIST_TAB_RECT_NSORT,            FN_IS_DENSE,    1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NDENSE,   0,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_HOMOG,    1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_TABLE,    1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_RECT,     1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_SSORT,    0,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NSORT,    1,

    // dense list, which only contains objects of type <= T_CYC
    T_PLIST_CYC,                  FN_IS_DENSE,    1,
    T_PLIST_CYC,                  FN_IS_NDENSE,   0,
    T_PLIST_CYC,                  FN_IS_HOMOG,    1,
    T_PLIST_CYC,                  FN_IS_NHOMOG,   0,
    T_PLIST_CYC,                  FN_IS_TABLE,    0,
    T_PLIST_CYC,                  FN_IS_RECT,     0,
    T_PLIST_CYC,                  FN_IS_SSORT,    0,
    T_PLIST_CYC,                  FN_IS_NSORT,    0,

    // ssort dense list, which only contains objs of type <= T_CYC
    T_PLIST_CYC_SSORT,            FN_IS_DENSE,    1,
    T_PLIST_CYC_SSORT,            FN_IS_NDENSE,   0,
    T_PLIST_CYC_SSORT,            FN_IS_HOMOG,    1,
    T_PLIST_CYC_SSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_CYC_SSORT,            FN_IS_TABLE,    0,
    T_PLIST_CYC_SSORT,            FN_IS_RECT,     0,
    T_PLIST_CYC_SSORT,            FN_IS_SSORT,    1,
    T_PLIST_CYC_SSORT,            FN_IS_NSORT,    0,

    // nsort dense list, which only contains objs of type <= T_CYC
    T_PLIST_CYC_NSORT,            FN_IS_DENSE,    1,
    T_PLIST_CYC_NSORT,            FN_IS_NDENSE,   0,
    T_PLIST_CYC_NSORT,            FN_IS_HOMOG,    1,
    T_PLIST_CYC_NSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_CYC_NSORT,            FN_IS_TABLE,    0,
    T_PLIST_CYC_NSORT,            FN_IS_RECT,     0,
    T_PLIST_CYC_NSORT,            FN_IS_SSORT,    0,
    T_PLIST_CYC_NSORT,            FN_IS_NSORT,    1,

    // dense list, which only contains objects of type T_FFE
    // all written over the same field
    T_PLIST_FFE,            FN_IS_DENSE,    1,
    T_PLIST_FFE,            FN_IS_NDENSE,   0,
    T_PLIST_FFE,            FN_IS_HOMOG,    1,
    T_PLIST_FFE,            FN_IS_NHOMOG,   0,
    T_PLIST_FFE,            FN_IS_TABLE,    0,
    T_PLIST_FFE,            FN_IS_RECT,     0,
    T_PLIST_FFE,            FN_IS_SSORT,    0,
    T_PLIST_FFE,            FN_IS_NSORT,    0,

    -1,                         -1,             -1
};


/****************************************************************************
**
*V  SetFiltTab  . . . . . . . . . . . . . . . . . . . . .  setter filter tnum
*/
static Int SetFiltTab [] = {

    // plain lists
    T_PLIST,                      FN_IS_DENSE,   T_PLIST_DENSE,
    T_PLIST,                      FN_IS_NDENSE,  T_PLIST_NDENSE,
    T_PLIST,                      FN_IS_HOMOG,   T_PLIST_HOM,
    T_PLIST,                      FN_IS_NHOMOG,  T_PLIST,
    T_PLIST,                      FN_IS_TABLE,   T_PLIST_TAB,
    T_PLIST,                      FN_IS_RECT,    T_PLIST_TAB_RECT,
    T_PLIST,                      FN_IS_SSORT,   T_PLIST,
    T_PLIST,                      FN_IS_NSORT,   T_PLIST,

    // empty list
    T_PLIST_EMPTY,                FN_IS_DENSE,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_NDENSE,  -1,
    T_PLIST_EMPTY,                FN_IS_HOMOG,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_NHOMOG,  -1,
    T_PLIST_EMPTY,                FN_IS_TABLE,   -1,
    T_PLIST_EMPTY,                FN_IS_RECT,    -1,
    T_PLIST_EMPTY,                FN_IS_SSORT,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_NSORT,   -1,

    // dense list
    T_PLIST_DENSE,                FN_IS_DENSE,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_NDENSE,  -1,
    T_PLIST_DENSE,                FN_IS_HOMOG,   T_PLIST_HOM,
    T_PLIST_DENSE,                FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE,                FN_IS_TABLE,   T_PLIST_TAB,
    T_PLIST_DENSE,                FN_IS_RECT,    T_PLIST_TAB_RECT,
    T_PLIST_DENSE,                FN_IS_SSORT,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_NSORT,   T_PLIST_DENSE,

    // dense list, which contains immutables and is not homog
    T_PLIST_DENSE_NHOM,           FN_IS_DENSE,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM,           FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM,           FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM,           FN_IS_RECT,    -1,
    T_PLIST_DENSE_NHOM,           FN_IS_SSORT,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM,           FN_IS_NSORT,   T_PLIST_DENSE_NHOM_NSORT,

    // dense ssorted list, which contains immutables and is not homog
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_DENSE,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_RECT,    -1,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_SSORT,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NSORT,   -1,

    // dense nsorted list, which contains immutables and is not homog
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_DENSE,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_RECT,    -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_SSORT,   -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NSORT,   T_PLIST_DENSE_NHOM_NSORT,

    // a mutable list with holes
    T_PLIST_NDENSE,               FN_IS_DENSE,   -1,
    T_PLIST_NDENSE,               FN_IS_NDENSE,  T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_HOMOG,   -1,
    T_PLIST_NDENSE,               FN_IS_NHOMOG,  T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_TABLE,   -1,
    T_PLIST_NDENSE,               FN_IS_RECT,    -1,
    T_PLIST_NDENSE,               FN_IS_SSORT,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NSORT,   T_PLIST_NDENSE,

    // dense list, which conts imms, is homogeneous, not a table
    T_PLIST_HOM,                  FN_IS_DENSE,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_NDENSE,  -1,
    T_PLIST_HOM,                  FN_IS_HOMOG,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_NHOMOG,  -1,
    T_PLIST_HOM,                  FN_IS_TABLE,   T_PLIST_TAB,
    T_PLIST_HOM,                  FN_IS_RECT,    T_PLIST_TAB_RECT,
    T_PLIST_HOM,                  FN_IS_SSORT,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM,                  FN_IS_NSORT,   T_PLIST_HOM_NSORT,

    // ssort dense list, which conts imms, is homog, not a table
    T_PLIST_HOM_SSORT,            FN_IS_DENSE,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_HOM_SSORT,            FN_IS_HOMOG,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_HOM_SSORT,            FN_IS_TABLE,   T_PLIST_TAB_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_RECT,    T_PLIST_TAB_RECT_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_SSORT,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_NSORT,   -1,

    // nsort dense list, which conts imms, is homog, not a table
    T_PLIST_HOM_NSORT,            FN_IS_DENSE,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_HOM_NSORT,            FN_IS_HOMOG,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_HOM_NSORT,            FN_IS_TABLE,   T_PLIST_TAB_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_RECT,    T_PLIST_TAB_RECT_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_SSORT,   -1,
    T_PLIST_HOM_NSORT,            FN_IS_NSORT,   T_PLIST_HOM_NSORT,

    // dense list, which is immutable, homog, non-empty, table
    T_PLIST_TAB,                  FN_IS_DENSE,   T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_NDENSE,  -1,
    T_PLIST_TAB,                  FN_IS_HOMOG,   T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_NHOMOG,  -1,
    T_PLIST_TAB,                  FN_IS_TABLE,   T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_RECT,    T_PLIST_TAB_RECT,
    T_PLIST_TAB,                  FN_IS_SSORT,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB,                  FN_IS_NSORT,   T_PLIST_TAB_NSORT,

    // ssort, dense list, which is imm, homog, non-empty, table
    T_PLIST_TAB_SSORT,            FN_IS_DENSE,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_TAB_SSORT,            FN_IS_HOMOG,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_SSORT,            FN_IS_TABLE,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_RECT,    T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_SSORT,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_NSORT,   -1,

    // nsort, dense list, which is imm, homog, non-empty, table
    T_PLIST_TAB_NSORT,            FN_IS_DENSE,   T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_TAB_NSORT,            FN_IS_HOMOG,   T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_NSORT,            FN_IS_TABLE,   T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_RECT,    T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_SSORT,   -1,
    T_PLIST_TAB_NSORT,            FN_IS_NSORT,   T_PLIST_TAB_NSORT,

    // dense list, which is immutable, homog, non-empty, rect table
    T_PLIST_TAB_RECT,                  FN_IS_DENSE,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_NDENSE,  -1,
    T_PLIST_TAB_RECT,                  FN_IS_HOMOG,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_RECT,                  FN_IS_TABLE,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_RECT,    T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_SSORT,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT,                  FN_IS_NSORT,   T_PLIST_TAB_RECT_NSORT,

    // ssort, dense list, which is imm, homog, non-empty, rect table
    T_PLIST_TAB_RECT_SSORT,            FN_IS_DENSE,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_HOMOG,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_TABLE,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_RECT,    T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_SSORT,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NSORT,   -1,

    // nsort, dense list, which is imm, homog, non-empty, rect table
    T_PLIST_TAB_RECT_NSORT,            FN_IS_DENSE,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_HOMOG,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_TABLE,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_RECT,    T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_SSORT,   -1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NSORT,   T_PLIST_TAB_RECT_NSORT,

    // dense list, which only contains objects of type <= T_CYC
    T_PLIST_CYC,                  FN_IS_DENSE,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_NDENSE,  -1,
    T_PLIST_CYC,                  FN_IS_HOMOG,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_NHOMOG,  -1,
    T_PLIST_CYC,                  FN_IS_TABLE,   -1,
    T_PLIST_CYC,                  FN_IS_RECT,    -1,
    T_PLIST_CYC,                  FN_IS_SSORT,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC,                  FN_IS_NSORT,   T_PLIST_CYC_NSORT,

    // ssort dense list, which only contains objs of type <= T_CYC
    T_PLIST_CYC_SSORT,            FN_IS_DENSE,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_CYC_SSORT,            FN_IS_HOMOG,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_CYC_SSORT,            FN_IS_TABLE,   -1,
    T_PLIST_CYC_SSORT,            FN_IS_RECT,    -1,
    T_PLIST_CYC_SSORT,            FN_IS_SSORT,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_NSORT,   -1,

    // nsort dense list, which only contains objs of type <= T_CYC
    T_PLIST_CYC_NSORT,            FN_IS_DENSE,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_CYC_NSORT,            FN_IS_HOMOG,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_CYC_NSORT,            FN_IS_TABLE,   -1,
    T_PLIST_CYC_NSORT,            FN_IS_RECT,    -1,
    T_PLIST_CYC_NSORT,            FN_IS_SSORT,   -1,
    T_PLIST_CYC_NSORT,            FN_IS_NSORT,   T_PLIST_CYC_NSORT,

    // dense list, which only contains objects of type T_FFE
    T_PLIST_FFE,            FN_IS_DENSE,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_NDENSE,  -1,
    T_PLIST_FFE,            FN_IS_HOMOG,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_NHOMOG,  -1,
    T_PLIST_FFE,            FN_IS_TABLE,   -1,
    T_PLIST_FFE,            FN_IS_RECT,    -1,
    T_PLIST_FFE,            FN_IS_SSORT,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_NSORT,   T_PLIST_FFE,

    -1,                           -1,            -1
};


/****************************************************************************
**
*V  ResetFiltTab  . . . . . . . . . . . . . . . . . . .  unsetter filter tnum
*/
static Int ResetFiltTab [] = {

    // plain lists
    T_PLIST,                      FN_IS_DENSE,   T_PLIST,
    T_PLIST,                      FN_IS_NDENSE,  T_PLIST,
    T_PLIST,                      FN_IS_HOMOG,   T_PLIST,
    T_PLIST,                      FN_IS_NHOMOG,  T_PLIST,
    T_PLIST,                      FN_IS_TABLE,   T_PLIST,
    T_PLIST,                      FN_IS_RECT,    T_PLIST,
    T_PLIST,                      FN_IS_SSORT,   T_PLIST,
    T_PLIST,                      FN_IS_NSORT,   T_PLIST,

    // empty list
    T_PLIST_EMPTY,                FN_IS_DENSE,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NDENSE,  T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_HOMOG,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NHOMOG,  T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_TABLE,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_RECT,    T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_SSORT,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NSORT,   T_PLIST_EMPTY,

    // dense list
    T_PLIST_DENSE,                FN_IS_DENSE,   T_PLIST,
    T_PLIST_DENSE,                FN_IS_NDENSE,  T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_NHOMOG,  T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_TABLE,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_RECT,    T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_SSORT,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_NSORT,   T_PLIST_DENSE,

    // dense list, which contains immutables and is not homog
    T_PLIST_DENSE_NHOM,           FN_IS_DENSE,   T_PLIST,
    T_PLIST_DENSE_NHOM,           FN_IS_NDENSE,  T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_HOMOG,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_NHOMOG,  T_PLIST_DENSE,
    T_PLIST_DENSE_NHOM,           FN_IS_TABLE,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_RECT,    T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_SSORT,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_NSORT,   T_PLIST_DENSE_NHOM,

    // dense ssorted list, which contains immutables and is not homog
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_DENSE,   T_PLIST,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NDENSE,  T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_HOMOG,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NHOMOG,  T_PLIST_DENSE,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_TABLE,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_RECT,    T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_SSORT,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NSORT,   T_PLIST_DENSE_NHOM_SSORT,

    // dense nsorted list, which contains immutables and is not homog
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_DENSE,   T_PLIST,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NDENSE,  T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_HOMOG,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NHOMOG,  T_PLIST_DENSE,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_TABLE,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_RECT,    T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_SSORT,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NSORT,   T_PLIST_DENSE_NHOM,

    // a mutable list with holes
    T_PLIST_NDENSE,               FN_IS_DENSE,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NDENSE,  T_PLIST,
    T_PLIST_NDENSE,               FN_IS_HOMOG,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NHOMOG,  T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_TABLE,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_RECT,    T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_SSORT,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NSORT,   T_PLIST_NDENSE,

    // dense list, which conts imms, is homogeneous, not a table
    T_PLIST_HOM,                  FN_IS_DENSE,   T_PLIST,
    T_PLIST_HOM,                  FN_IS_NDENSE,  T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_HOM,                  FN_IS_NHOMOG,  T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_TABLE,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_RECT,    T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_SSORT,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_NSORT,   T_PLIST_HOM,

    // ssort dense list, which conts imms, is homog, not a table
    T_PLIST_HOM_SSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_HOM_SSORT,            FN_IS_NDENSE,  T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_HOM_SSORT,            FN_IS_NHOMOG,  T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_TABLE,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_RECT,    T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_SSORT,   T_PLIST_HOM,
    T_PLIST_HOM_SSORT,            FN_IS_NSORT,   T_PLIST_HOM_SSORT,

    // nsort dense list, which conts imms, is homog, not a table
    T_PLIST_HOM_NSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_HOM_NSORT,            FN_IS_NDENSE,  T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_HOM_NSORT,            FN_IS_NHOMOG,  T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_TABLE,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_RECT,    T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_SSORT,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_NSORT,   T_PLIST_HOM,

    // dense list, which is immutable, homog, non-empty, table
    T_PLIST_TAB,                  FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB,                  FN_IS_NDENSE,  T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB,                  FN_IS_NHOMOG,  T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_TABLE,   T_PLIST_HOM,
    T_PLIST_TAB,                  FN_IS_RECT,    T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_SSORT,   T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_NSORT,   T_PLIST_TAB,

    // ssort, dense list, which is imm, homog, non-empty, table
    T_PLIST_TAB_SSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_SSORT,            FN_IS_NDENSE,  T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_SSORT,            FN_IS_NHOMOG,  T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_TABLE,   T_PLIST_HOM_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_RECT,    T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_SSORT,   T_PLIST_TAB,
    T_PLIST_TAB_SSORT,            FN_IS_NSORT,   T_PLIST_TAB_SSORT,

    // nsort, dense list, which is imm, homog, non-empty, table
    T_PLIST_TAB_NSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_NSORT,            FN_IS_NDENSE,  T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_NSORT,            FN_IS_NHOMOG,  T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_TABLE,   T_PLIST_HOM_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_RECT,    T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_SSORT,   T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_NSORT,   T_PLIST_TAB,

    // dense list, which is immutable, homog, non-empty, rect table
    T_PLIST_TAB_RECT,                  FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_RECT,                  FN_IS_NDENSE,  T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_RECT,                  FN_IS_NHOMOG,  T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_TABLE,   T_PLIST_HOM,
    T_PLIST_TAB_RECT,                  FN_IS_RECT,    T_PLIST_TAB,
    T_PLIST_TAB_RECT,                  FN_IS_SSORT,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_NSORT,   T_PLIST_TAB_RECT,

    // ssort, dense list, which is imm, homog, non-empty, rect table
    T_PLIST_TAB_RECT_SSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NDENSE,  T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NHOMOG,  T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_TABLE,   T_PLIST_HOM_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_RECT,    T_PLIST_TAB_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_SSORT,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NSORT,   T_PLIST_TAB_RECT_SSORT,

    // loop variables
    T_PLIST_TAB_RECT_NSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NDENSE,  T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NHOMOG,  T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_TABLE,   T_PLIST_HOM_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_RECT,    T_PLIST_TAB_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_SSORT,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NSORT,   T_PLIST_TAB_RECT,

    // dense list, which only contains objects of type <= T_CYC
    T_PLIST_CYC,                  FN_IS_DENSE,   T_PLIST,
    T_PLIST_CYC,                  FN_IS_NDENSE,  T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_CYC,                  FN_IS_NHOMOG,  T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_TABLE,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_RECT,    T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_SSORT,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_NSORT,   T_PLIST_CYC,

    // ssort dense list, which only contains objs of type <= T_CYC
    T_PLIST_CYC_SSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_CYC_SSORT,            FN_IS_NDENSE,  T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_HOMOG,   T_PLIST,
    T_PLIST_CYC_SSORT,            FN_IS_NHOMOG,  T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_TABLE,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_RECT,    T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_SSORT,   T_PLIST_CYC,
    T_PLIST_CYC_SSORT,            FN_IS_NSORT,   T_PLIST_CYC_SSORT,

    // nsort dense list, which only contains objs of type <= T_CYC
    T_PLIST_CYC_NSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_CYC_NSORT,            FN_IS_NDENSE,  T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_HOMOG,   T_PLIST,
    T_PLIST_CYC_NSORT,            FN_IS_NHOMOG,  T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_TABLE,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_RECT,    T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_SSORT,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_NSORT,   T_PLIST_CYC,

    // dense list, which only contains objects of type T_FFE
    T_PLIST_FFE,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_FFE,            FN_IS_NDENSE,  T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_HOMOG,   T_PLIST,
    T_PLIST_FFE,            FN_IS_NHOMOG,  T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_TABLE,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_RECT,    T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_SSORT,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_NSORT,   T_PLIST_FFE,

    -1,                         -1,             -1

};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_PLIST_REP, "obj", &IsPlistFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_3ARGS(ASS_PLIST_DEFAULT, list, pos, val),
    GVAR_FUNC_1ARGS(IsRectangularTablePlist, plist),
    GVAR_FUNC_1ARGS(SET_IS_SSORTED_PLIST, list),
    GVAR_FUNC_1ARGS(EmptyPlist, len),
    GVAR_FUNC_1ARGS(ShrinkAllocationPlist, plist),
    { 0, 0, 0, 0, 0 }

};

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                t1, t2;         /* loop variables                  */

    /* GASMAN marking functions and GASMAN names                           */
    InitBagNamesFromTable( BagNames );

    for ( t1 = T_PLIST;  t1 < T_PLIST_FFE ;  t1 += 2 ) {
        InitMarkFuncBags( t1                     , MarkAllButFirstSubBags );
        InitMarkFuncBags( t1 +IMMUTABLE          , MarkAllButFirstSubBags );
    }

    InitMarkFuncBags( T_PLIST_FFE                     , MarkNoSubBags );
    InitMarkFuncBags( T_PLIST_FFE +IMMUTABLE          , MarkNoSubBags );

    /* If T_PLIST_FFE is not the last PLIST type then some more
       work needs to be done here */

#ifdef GAP_ENABLE_SAVELOAD
    for ( t1 = T_PLIST;  t1 <= LAST_PLIST_TNUM;  t1 += 2 ) {
        SaveObjFuncs[ t1            ] = SavePlist;
        SaveObjFuncs[ t1 +IMMUTABLE ] = SavePlist;
        LoadObjFuncs[ t1            ] = LoadPlist;
        LoadObjFuncs[ t1 +IMMUTABLE ] = LoadPlist;
    }
#endif

    /* get the types (resp. type functions)                                */
    ImportGVarFromLibrary( "TYPE_LIST_NDENSE_MUTABLE",
                           &TYPE_LIST_NDENSE_MUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_NDENSE_IMMUTABLE",
                           &TYPE_LIST_NDENSE_IMMUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_DENSE_NHOM_MUTABLE",
                           &TYPE_LIST_DENSE_NHOM_MUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_DENSE_NHOM_IMMUTABLE",
                           &TYPE_LIST_DENSE_NHOM_IMMUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE",
                           &TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE",
                           &TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE",
                           &TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE",
                           &TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_EMPTY_MUTABLE",
                           &TYPE_LIST_EMPTY_MUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_EMPTY_IMMUTABLE",
                           &TYPE_LIST_EMPTY_IMMUTABLE );

    ImportFuncFromLibrary( "TYPE_LIST_HOM",
                           &TYPE_LIST_HOM );

    /* install the type methods                                            */
    TypeObjFuncs[ T_PLIST                       ] = TypePlist;
    TypeObjFuncs[ T_PLIST            +IMMUTABLE ] = TypePlist;
    TypeObjFuncs[ T_PLIST_NDENSE                ] = TypePlistNDense;
    TypeObjFuncs[ T_PLIST_NDENSE     +IMMUTABLE ] = TypePlistNDense;
    TypeObjFuncs[ T_PLIST_DENSE                 ] = TypePlistDense;
    TypeObjFuncs[ T_PLIST_DENSE      +IMMUTABLE ] = TypePlistDense;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM            ] = TypePlistDenseNHom;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM +IMMUTABLE ] = TypePlistDenseNHom;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM_SSORT            ] = TypePlistDenseNHomSSort;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM_SSORT +IMMUTABLE ] = TypePlistDenseNHomSSort;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM_NSORT            ] = TypePlistDenseNHomNSort;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM_NSORT +IMMUTABLE ] = TypePlistDenseNHomNSort;
    TypeObjFuncs[ T_PLIST_EMPTY                 ] = TypePlistEmpty;
    TypeObjFuncs[ T_PLIST_EMPTY      +IMMUTABLE ] = TypePlistEmpty;

    for ( t1 = T_PLIST_HOM; t1 <= T_PLIST_TAB_RECT_SSORT; t1 += 2 ) {
        TypeObjFuncs[ t1            ] = TypePlistHom;
        TypeObjFuncs[ t1 +IMMUTABLE ] = TypePlistHom;
    }

    for ( t1 = T_PLIST_CYC; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        TypeObjFuncs[ t1            ] = TypePlistCyc;
        TypeObjFuncs[ t1 +IMMUTABLE ] = TypePlistCyc;
    }

    TypeObjFuncs[ T_PLIST_FFE            ] = TypePlistFfe;
    TypeObjFuncs[ T_PLIST_FFE +IMMUTABLE ] = TypePlistFfe;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* initialise list tables                                              */
    InitClearFiltsTNumsFromTable   ( ClearFiltsTab );
    InitHasFiltListTNumsFromTable  ( HasFiltTab    );
    InitSetFiltListTNumsFromTable  ( SetFiltTab    );
    InitResetFiltListTNumsFromTable( ResetFiltTab  );


    /* install the shallow copy methods                                    */
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        ShallowCopyObjFuncs[ t1            ] = ShallowCopyPlist;
        ShallowCopyObjFuncs[ t1 +IMMUTABLE ] = ShallowCopyPlist;
    }

#ifdef USE_THREADSAFE_COPYING
    for (t1 = FIRST_PLIST_TNUM; t1 <= LAST_PLIST_TNUM; t1++) {
        SetTraversalMethod(t1, TRAVERSE_BY_FUNCTION, TraversePlist, CopyPlist);
    }
    for (t1 = T_PLIST_CYC; t1 <= T_PLIST_FFE+IMMUTABLE; t1++) {
        SetTraversalMethod(t1, TRAVERSE_NONE, 0, 0);
    }
#else
    /* install the copy list methods                                       */
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        CopyObjFuncs [ t1                     ] = CopyPlist;
        CopyObjFuncs [ t1 +IMMUTABLE          ] = CopyPlist;
        CleanObjFuncs[ t1                     ] = CleanPlist;
        CleanObjFuncs[ t1 +IMMUTABLE          ] = CleanPlist;
    }
#endif

    /* install the comparison methods                                      */
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1++ ) {
        for ( t2 = T_PLIST; t2 <= LAST_PLIST_TNUM; t2++ ) {
            EqFuncs[ t1 ][ t2 ] = EqPlist;
            LtFuncs[ t1 ][ t2 ] = LtPlist;
        }
    }


    /* install the list length methods                                     */
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        LenListFuncs[ t1            ] = LenPlist;
        LenListFuncs[ t1 +IMMUTABLE ] = LenPlist;
    }
    LenListFuncs[ T_PLIST_EMPTY           ] = LenPlistEmpty;
    LenListFuncs[ T_PLIST_EMPTY+IMMUTABLE ] = LenPlistEmpty;


    /* install the list element test methods                               */
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        IsbListFuncs  [ t1            ] = IsbPlist;
        IsbListFuncs  [ t1 +IMMUTABLE ] = IsbPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        IsbListFuncs  [ t1            ] = IsbPlistDense;
        IsbListFuncs  [ t1 +IMMUTABLE ] = IsbPlistDense;
    }


    /* install the list element methods                                    */
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        Elm0ListFuncs [ t1            ] = Elm0Plist;
        Elm0ListFuncs [ t1 +IMMUTABLE ] = Elm0Plist;
    }
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        Elm0vListFuncs[ t1            ] = Elm0vPlist;
        Elm0vListFuncs[ t1 +IMMUTABLE ] = Elm0vPlist;
    }
    for ( t1 = T_PLIST; t1 <= T_PLIST_NDENSE; t1 += 2 ) {
        ElmListFuncs  [ t1            ] = ElmPlist;
        ElmListFuncs  [ t1 +IMMUTABLE ] = ElmPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        ElmListFuncs  [ t1            ] = ElmPlistDense;
        ElmListFuncs  [ t1 +IMMUTABLE ] = ElmPlistDense;
    }
    for ( t1 = T_PLIST; t1 <= T_PLIST_NDENSE; t1 += 2 ) {
        ElmvListFuncs [ t1            ] = ElmvPlist;
        ElmvListFuncs [ t1 +IMMUTABLE ] = ElmvPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        ElmvListFuncs [ t1            ] = ElmvPlistDense;
        ElmvListFuncs [ t1 +IMMUTABLE ] = ElmvPlistDense;
    }
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        ElmwListFuncs [ t1            ] = ElmvPlistDense;
        ElmwListFuncs [ t1 +IMMUTABLE ] = ElmvPlistDense;
    }


    /* install the list elements methods                                   */
    for ( t1 = T_PLIST; t1 <= T_PLIST_NDENSE; t1 += 2 ) {
        ElmsListFuncs   [ t1            ] = ElmsPlist;
        ElmsListFuncs   [ t1 +IMMUTABLE ] = ElmsPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        ElmsListFuncs   [ t1            ] = ElmsPlistDense;
        ElmsListFuncs   [ t1 +IMMUTABLE ] = ElmsPlistDense;
    }


    /* install the list unbind methods                                     */
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        UnbListFuncs    [ t1            ] = UnbPlist;
    }


    /* install the list assignment methods                                 */
    AssListFuncs    [ T_PLIST           ] = AssPlist;
    AssListFuncs    [ T_PLIST_NDENSE           ] = AssPlistXXX;
    AssListFuncs    [ T_PLIST_DENSE           ] = AssPlistDense;
    AssListFuncs    [ T_PLIST_DENSE_NHOM           ] = AssPlistDense;
    AssListFuncs    [ T_PLIST_DENSE_NHOM_SSORT           ] = AssPlistDense;
    AssListFuncs    [ T_PLIST_DENSE_NHOM_NSORT           ] = AssPlistDense;
    AssListFuncs    [ T_PLIST_EMPTY           ] = AssPlistEmpty;


    for ( t1 = T_PLIST_HOM; t1 < T_PLIST_CYC; t1 += 2 ) {
      AssListFuncs[ t1                ] = AssPlistHomog;
    }

    for ( t1 = T_PLIST_CYC; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
      AssListFuncs[ t1                ] = AssPlistCyc;
    }

    AssListFuncs[ T_PLIST_FFE           ] = AssPlistFfe;

    /* install the list assignments methods                                */
    AsssListFuncs   [ T_PLIST            ] = AsssPlist;
    for ( t1 = T_PLIST_NDENSE; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        AsssListFuncs   [ t1             ] = AsssPlistXXX;
    }


    /* install the dense list test methods                                 */
    IsDenseListFuncs[ T_PLIST                   ] = IsDensePlist;
    IsDenseListFuncs[ T_PLIST        +IMMUTABLE ] = IsDensePlist;
    IsDenseListFuncs[ T_PLIST_NDENSE            ] = AlwaysNo;
    IsDenseListFuncs[ T_PLIST_NDENSE +IMMUTABLE ] = AlwaysNo;
    for ( t1 = T_PLIST_DENSE; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        IsDenseListFuncs[ t1            ] = AlwaysYes;
        IsDenseListFuncs[ t1 +IMMUTABLE ] = AlwaysYes;
    }


    /* install the homogeneous list test methods                           */
    IsHomogListFuncs[ T_PLIST                       ] = IsHomogPlist;
    IsHomogListFuncs[ T_PLIST            +IMMUTABLE ] = IsHomogPlist;
    IsHomogListFuncs[ T_PLIST_NDENSE                ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_NDENSE     +IMMUTABLE ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_DENSE                 ] = IsHomogPlist;
    IsHomogListFuncs[ T_PLIST_DENSE      +IMMUTABLE ] = IsHomogPlist;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM            ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM +IMMUTABLE ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM_SSORT            ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM_SSORT +IMMUTABLE ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM_NSORT            ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM_NSORT +IMMUTABLE ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_EMPTY                 ] = AlwaysYes;
    IsHomogListFuncs[ T_PLIST_EMPTY      +IMMUTABLE ] = AlwaysYes;
    for ( t1 = T_PLIST_HOM; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        IsHomogListFuncs[ t1            ] = AlwaysYes;
        IsHomogListFuncs[ t1 +IMMUTABLE ] = AlwaysYes;
    }


    /* install the equal length list test methods                          */
    IsTableListFuncs[ T_PLIST                       ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST            +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_NDENSE                ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_NDENSE     +IMMUTABLE ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_DENSE                 ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_DENSE      +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM            ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM +IMMUTABLE ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM_SSORT            ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM_SSORT +IMMUTABLE ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM_NSORT            ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM_NSORT +IMMUTABLE ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_EMPTY                 ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_EMPTY      +IMMUTABLE ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_HOM                   ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM        +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM_NSORT             ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM_NSORT  +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM_SSORT             ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM_SSORT  +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_TAB                   ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB        +IMMUTABLE ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_NSORT             ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_NSORT  +IMMUTABLE ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_SSORT             ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_SSORT  +IMMUTABLE ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_RECT                   ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_RECT        +IMMUTABLE ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_RECT_NSORT             ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_RECT_NSORT  +IMMUTABLE ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_RECT_SSORT             ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_TAB_RECT_SSORT  +IMMUTABLE ] = AlwaysYes;
    IsTableListFuncs[ T_PLIST_CYC                   ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_CYC        +IMMUTABLE ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_CYC_NSORT             ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_CYC_NSORT  +IMMUTABLE ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_CYC_SSORT             ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_CYC_SSORT  +IMMUTABLE ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_FFE                   ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_FFE        +IMMUTABLE ] = AlwaysNo;


    /* install the strictly sorted list test methods                       */
    IsSSortListFuncs[ T_PLIST                      ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST           +IMMUTABLE ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_NDENSE               ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_NDENSE    +IMMUTABLE ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_DENSE                ] = IsSSortPlistDense;
    IsSSortListFuncs[ T_PLIST_DENSE     +IMMUTABLE ] = IsSSortPlistDense;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM           ] = IsSSortPlistDense;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM+IMMUTABLE ] = IsSSortPlistDense;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM_SSORT           ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM_NSORT           ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_EMPTY                ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_EMPTY     +IMMUTABLE ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_HOM                  ] = IsSSortPlistHom;
    IsSSortListFuncs[ T_PLIST_HOM       +IMMUTABLE ] = IsSSortPlistHom;
    IsSSortListFuncs[ T_PLIST_HOM_NSORT            ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_HOM_NSORT +IMMUTABLE ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_HOM_SSORT            ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_HOM_SSORT +IMMUTABLE ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_TAB                  ] = IsSSortPlistHom;
    IsSSortListFuncs[ T_PLIST_TAB       +IMMUTABLE ] = IsSSortPlistHom;
    IsSSortListFuncs[ T_PLIST_TAB_NSORT            ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_TAB_NSORT +IMMUTABLE ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_TAB_SSORT            ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_TAB_SSORT +IMMUTABLE ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_TAB_RECT                  ] = IsSSortPlistHom;
    IsSSortListFuncs[ T_PLIST_TAB_RECT       +IMMUTABLE ] = IsSSortPlistHom;
    IsSSortListFuncs[ T_PLIST_TAB_RECT_NSORT            ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_TAB_RECT_NSORT +IMMUTABLE ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_TAB_RECT_SSORT            ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_TAB_RECT_SSORT +IMMUTABLE ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_CYC                  ] = IsSSortPlistHom;
    IsSSortListFuncs[ T_PLIST_CYC       +IMMUTABLE ] = IsSSortPlistHom;
    IsSSortListFuncs[ T_PLIST_CYC_NSORT            ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_CYC_NSORT +IMMUTABLE ] = AlwaysNo;
    IsSSortListFuncs[ T_PLIST_CYC_SSORT            ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_CYC_SSORT +IMMUTABLE ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_FFE                  ] = IsSSortPlistHom;
    IsSSortListFuncs[ T_PLIST_FFE       +IMMUTABLE ] = IsSSortPlistHom;


    /* install the position list test methods                              */
    for ( t1 = T_PLIST; t1 <= T_PLIST_FFE; t1 += 2 ) {
        IsPossListFuncs[ t1            ] = IsPossPlist;
        IsPossListFuncs[ t1 +IMMUTABLE ] = IsPossPlist;
    }


    /* install the position list methods                                   */
    for ( t1 = T_PLIST; t1 <= T_PLIST_NDENSE; t1 += 2 ) {
        PosListFuncs[ t1            ] = PosPlist;
        PosListFuncs[ t1 +IMMUTABLE ] = PosPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= T_PLIST_FFE; t1 += 2 ) {
        PosListFuncs[ t1            ] = PosPlistDense;
        PosListFuncs[ t1 +IMMUTABLE ] = PosPlistDense;
    }

    PosListFuncs[ T_PLIST_DENSE_NHOM_SSORT            ] = PosPlistSort;
    PosListFuncs[ T_PLIST_DENSE_NHOM_SSORT +IMMUTABLE ] = PosPlistSort;
    PosListFuncs[ T_PLIST_HOM_SSORT            ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_HOM_SSORT +IMMUTABLE ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_TAB_SSORT            ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_TAB_SSORT +IMMUTABLE ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_TAB_RECT_SSORT            ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_TAB_RECT_SSORT +IMMUTABLE ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_CYC_SSORT            ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_CYC_SSORT +IMMUTABLE ] = PosPlistHomSort;


    /* install the plain list methods                                      */
    for ( t1 = T_PLIST; t1 <= T_PLIST_FFE; t1 += 2 ) {
        PlainListFuncs[ t1            ] = PlainPlist;
        PlainListFuncs[ t1 +IMMUTABLE ] = PlainPlist;
    }

    for (t1 = T_PLIST; t1 < T_PLIST_DENSE_NHOM; t1 += 2 )
      MakeImmutableObjFuncs[ t1 ] = MakeImmutablePlistInHom;

    for (t1 = T_PLIST_DENSE_NHOM; t1 <= T_PLIST_FFE; t1 += 2 )
      MakeImmutableObjFuncs[ t1 ] = MakeImmutablePlistNoMutElms;

    /* mutable tables may have mutable rows */
    MakeImmutableObjFuncs[T_PLIST_TAB] = MakeImmutablePlistInHom;

#ifdef HPCGAP
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        MakeBagTypePublic(t1 +IMMUTABLE);
    }
#endif

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  InitInfoPlist() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "plist",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoPlist ( void )
{
    return &module;
}
