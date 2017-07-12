/****************************************************************************
**
*W  plist.c                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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
**  logical, there will be unused entries at the end  of the list, comtaining
**  0.  The physical length  might be greater than  the logical,  because the
**  physical size of a  list is increased by at  least 12.5\%, to avoid doing
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
#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/funcs.h>

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */
#include <src/finfield.h>               /* finite fields */

#include <src/bool.h>                   /* booleans */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/range.h>                  /* ranges */
#include <src/stringobj.h>              /* strings */
#include <src/blister.h>                /* boolean lists */

#include <src/saveload.h>               /* saving and loading */
#include <src/code.h>
#include <src/hpc/thread.h>
#include <src/hpc/tls.h>

#include <src/gaputils.h>

#include <assert.h>


/****************************************************************************
**
*F  GROW_PLIST(<list>,<plen>) . . . .  make sure a plain list is large enough
**
*/
Int             GrowPlist (
    Obj                 list,
    UInt                need )
{
    UInt                plen;           /* new physical length             */
    UInt                good;           /* good new physical length        */

    /* find out how large the plain list should become                     */
    good = 5 * (SIZE_OBJ(list)/sizeof(Obj)-1) / 4 + 4;

    /* but maybe we need more                                              */
    if ( need < good ) { plen = good; }
    else               { plen = need; }

    /* resize the plain list                                               */
    ResizeBag( list, ((plen)+1)*sizeof(Obj) );

    /* return something (to please some C compilers)                       */
    return 0L;
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
**  basically achieved with the TESTING flag in the TNum. This must be set in
**  the "current" list before triggering determination of the Type (or KTNum)
**  of any sublist.
**
**  KTNumPlist determined the "true" TNum of the list, taking account of such
**  factors as denseness, homogeneity and so on. It modifies the stored TNum
**  of the list to the most informative "safe" value, allowing for the
**  mutability of the list entries (and preserving TESTING).
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
**   T_PLIST_DENSE_NHOM_NSORT   dense, non-hom, known not be be sorted
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
**   * -- these tnums can only be safely given when none of the elements of the list
**        is mutable
**   ** -- dense recursive lists (have themselves as a (possibly nested) subobject)
**         appear here
**
**  There are 10 functions entered in TypeObjFuncs:
**      1. TypePlist
**      2. TypePlistNDenseMut/Imm
**      3. TypePlistDenseMut/Imm
**      4. TypePlistDenseNHomMut/Imm
**      5. TypePlistDenseNHomSSortMut/Imm
**      6. TypePlistDenseNHomNSortMut/Imm
**      7. TypePlistEmptyMut/Imm
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
**        family to find the type, calling out to a GAP function to make each type
**        for the first time.
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
**     using the TESTING tnums. Any list being examined must have TESTING added to
**     its tnum BEFORE any element of it is examined.
**
**     
**     FIXME HPC-GAP: All of this is horribly thread-unsafe!
**
*/

Obj TYPE_LIST_NDENSE_MUTABLE;
Obj TYPE_LIST_NDENSE_IMMUTABLE;
Obj TYPE_LIST_DENSE_NHOM_MUTABLE;
Obj TYPE_LIST_DENSE_NHOM_IMMUTABLE;
Obj TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE;
Obj TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE;
Obj TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE;
Obj TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE;
Obj TYPE_LIST_EMPTY_MUTABLE;
Obj TYPE_LIST_EMPTY_IMMUTABLE;
Obj TYPE_LIST_HOM;

#define IS_TESTING_PLIST(list) \
    (IS_BAG_REF(list) && TEST_OBJ_FLAG(list, TESTING))


static Obj TypePlistWithKTNum( Obj list, UInt *ktnum );

Int KTNumPlist (
    Obj                 list,
    Obj                 *famfirst)
{
    Int                 isHom   = 1;    /* is <list> homogeneous           */
    Int                 isDense = 1;    /* is <list> dense                 */
    Int                 isTable = 0;    /* are <list>s elms all lists      */
    Int                 isRect  = 0;    /* are lists elms of equal length
                                     only test this one for PLIST elements */
    Int                 areMut  = 0;    /* are <list>s elms mutable        */
    Int                 len     = 0;    /* if so, this is the length       */
    Obj                 typeObj = 0;    /* type of <list>s elements        */
    Obj                 family  = 0;    /* family of <list>s elements      */
    Int                 lenList;        /* length of <list>                */
    Obj                 elm, x;         /* one element of <list>           */
    Int                 i;              /* loop variable                   */
    Int                 testing;        /* to test or not to test type     */
    Int                 res;            /* result                          */
    Int                 knownDense;     /* set true if the list is already
					   known to be dense */
    Int                 knownNDense;    /* set true if the list is already
					   known not to be dense */
    UInt                ktnumFirst;

    Obj                 loopTypeObj = 0; /* typeObj in loop               */

#ifdef HPCGAP
    if (!CheckWriteAccess(list)) {
      return TNUM_OBJ(list);
    }
#endif
    /* if list has `TESTING' keep that                                     */
    testing = TEST_OBJ_FLAG(list, TESTING);

    knownDense = HAS_FILT_LIST( list, FN_IS_DENSE );
    knownNDense = HAS_FILT_LIST( list, FN_IS_NDENSE );

    /* get the length of the list                                          */
    lenList = LEN_PLIST(list);

    /* special case for empty list                                         */
    if ( lenList == 0 ) {
        SET_FILT_LIST( list, FN_IS_EMPTY );
        res = TNUM_OBJ(list);
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
    else if ( IS_TESTING_PLIST(elm) ) {
        isHom   = 0;
        areMut  = IS_MUTABLE_PLIST(elm);
        isTable = 0;
    }
    else {
#ifdef HPCGAP
	if (!testing) SET_OBJ_FLAG(list, TESTING|TESTED);
#else
	if (!testing) SET_OBJ_FLAG(list, TESTING);
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

	  /* entry is a homogenous list, so this miught be a table */
	  isTable = 1;

	  /* also check for rectangularity, unless this would be expensive */
	  if (IS_PLIST(elm))
	    {
	      isRect = 1;
	      len = LEN_PLIST(elm);
	    }
	  
        }
	if (!testing) CLEAR_OBJ_FLAG(list, TESTING);
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
        else if ( IS_TESTING_PLIST(elm) ) {
            isHom   = 0;
            areMut  = (areMut || IS_MUTABLE_PLIST(elm));
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
	if (TNUM_OBJ(ELM_PLIST(list,1)) <= T_CYC)
	  {
	    res = (lenList == 1) ? T_PLIST_CYC_SSORT : T_PLIST_CYC;
	    /* This is a hack */
	    RetypeBag(list, res + ( IS_MUTABLE_OBJ(list) ? 0 : IMMUTABLE ));
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
		RetypeBag(list, res + ( IS_MUTABLE_OBJ(list) ? 0 : IMMUTABLE ));
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


Int KTNumHomPlist (
    Obj                 list)
{
    Int                 isTable = 0;    /* are <list>s elms all lists   */
    Int                 isRect  = 0;    /* are <list>s elms all equal length */
    Int                 len     = 0;    /* if so, this is the length       */
    Int                 lenList;        /* length of list                  */
    Obj                 elm, x;         /* one element of <list>           */
    Int                 i;              /* loop variable                   */
    Int                 res;            /* result                          */
    Int                 isSSort;        /* list is (known to be) SSorted   */
    Int                 isNSort;        /* list is (known to be) non-sorted*/

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
    assert(!IS_TESTING_PLIST(elm));

    isSSort = HAS_FILT_LIST(list, FN_IS_SSORT );
    isNSort = HAS_FILT_LIST(list, FN_IS_NSORT );

    /* if it's a kernel cyclotomic then we know where we are*/
    if (TNUM_OBJ(elm) <= T_CYC)
      {
	if (lenList == 1 || isSSort)
	  res = T_PLIST_CYC_SSORT;
	else if (isNSort)
	  res = T_PLIST_CYC_NSORT;
        else
	  res = T_PLIST_CYC;
	
	/* This is a hack */
	RetypeBag(list, res + ( IS_MUTABLE_OBJ(list) ? 0 : IMMUTABLE ));
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
	    RetypeBag(list, res + ( IS_MUTABLE_OBJ(list) ? 0 : IMMUTABLE ));
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
	  assert(!IS_TESTING_PLIST(elm));
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

Obj TypePlist( Obj list)
{
  return TypePlistWithKTNum( list, (UInt *) 0);
}

static Obj TypePlistWithKTNum (
    Obj                 list,
    UInt                *ktnum )
{
    Obj                 type;           /* type, result                    */
    Int                 tnum;           /* TNUM of <list>                  */
    Obj                 family;         /* family of elements              */
    Obj                 types;          /* types list of <family>          */

#ifdef HPCGAP
    if (CheckWriteAccess(list)) {
      /* recursion is possible for this type of list                         */
      SET_OBJ_FLAG( list, TESTING|TESTED );
      tnum = KTNumPlist( list, &family);
      CLEAR_OBJ_FLAG( list, TESTING );
    } else {
      tnum = TNUM_OBJ(list);
      family = 0;
    }
#else
    /* recursion is possible for this type of list                         */
    SET_OBJ_FLAG( list, TESTING );
    tnum = KTNumPlist( list, &family);
    CLEAR_OBJ_FLAG( list, TESTING );
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

        /* get the list types of the elements family */
        types  = TYPES_LIST_FAM( family );

#ifdef HPCGAP
	if (CheckWriteAccess(types)) {
#endif
            /* if the type is not yet known, compute it                        */
            type = ELM0_LIST( types, tnum-T_PLIST_HOM+1 );
            if ( type == 0 ) {
                type = CALL_2ARGS( TYPE_LIST_HOM,
                    family, INTOBJ_INT(tnum-T_PLIST_HOM+1) );
                ASS_LIST( types, tnum-T_PLIST_HOM+1, type );
            }

            /* return the type                                                 */
            return type;
#ifdef HPCGAP
        }
#endif
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

Obj TypePlistNDenseMut (
    Obj                 list )
{
    return TYPE_LIST_NDENSE_MUTABLE;
}

Obj TypePlistNDenseImm (
    Obj                 list )
{
    return TYPE_LIST_NDENSE_IMMUTABLE;
}

#define         TypePlistDenseMut       TypePlist
#define         TypePlistDenseImm       TypePlist

Obj TypePlistDenseNHomMut (
    Obj                 list )
{
    return TYPE_LIST_DENSE_NHOM_MUTABLE;
}

Obj TypePlistDenseNHomImm (
    Obj                 list )
{
    return TYPE_LIST_DENSE_NHOM_IMMUTABLE;
}
Obj TypePlistDenseNHomSSortMut (
    Obj                 list )
{
    return TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE;
}

Obj TypePlistDenseNHomSSortImm (
    Obj                 list )
{
    return TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE;
}
Obj TypePlistDenseNHomNSortMut (
    Obj                 list )
{
    return TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE;
}

Obj TypePlistDenseNHomNSortImm (
    Obj                 list )
{
    return TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE;
}

Obj TypePlistEmptyMut (
    Obj                 list )
{
    return TYPE_LIST_EMPTY_MUTABLE;
}

Obj TypePlistEmptyImm (
    Obj                 list )
{
    return TYPE_LIST_EMPTY_IMMUTABLE;
}

Obj TypePlistHom (
    Obj                 list )
{
    Obj                 type;           /* type, result                    */
    Int                 tnum;           /* TNUM of <list>                  */
    Obj                 family;         /* family of elements              */
    Obj                 types;          /* types list of <family>          */

    /* get the tnum and the family of the elements                         */
    tnum   = KTNumHomPlist( list );
    family = FAMILY_TYPE( TYPE_OBJ( ELM_PLIST( list, 1 ) ) );

    /* get the list types of that family                                   */
    types  = TYPES_LIST_FAM( family );

    /* if the type is not yet known, compute it                            */
    type = ELM0_LIST( types, tnum-T_PLIST_HOM+1 );
    if ( type == 0 ) {
        type = CALL_2ARGS( TYPE_LIST_HOM,
            family, INTOBJ_INT(tnum-T_PLIST_HOM+1) );
        ASS_LIST( types, tnum-T_PLIST_HOM+1, type );
#ifdef HPCGAP
        // read back element before returning it, in case another thread raced us
	type = ELM0_LIST( types, tnum-T_PLIST_HOM+1 );
#endif
    }

    /* return the type                                                     */
    return type;
}

Obj TypePlistCyc (
    Obj                 list )
{
    Obj                 type;           /* type, result                    */
    Int                 tnum;           /* TNUM of <list>                  */
    Obj                 family;         /* family of elements              */
    Obj                 types;          /* types list of <family>          */

    /* get the tnum and the family of the elements                         */
    tnum   = TNUM_OBJ( list );

    /* This had better return the cyclotomics family, could be speeded up */
    family = FAMILY_TYPE( TYPE_OBJ( ELM_PLIST( list, 1 ) ) );

    /* get the list types of that family                                   */
    types  = TYPES_LIST_FAM( family );

    /* if the type is not yet known, compute it                            */
    type = ELM0_LIST( types, tnum-T_PLIST_CYC+1 );
    if ( type == 0 ) {
        type = CALL_2ARGS( TYPE_LIST_HOM,
            family, INTOBJ_INT(tnum-T_PLIST_CYC+1) );
        ASS_LIST( types, tnum-T_PLIST_CYC+1, type );
#ifdef HPCGAP
        // read back element before returning it, in case another thread raced us
	type = ELM0_LIST( types, tnum-T_PLIST_CYC+1 );
#endif
    }

    /* return the type                                                     */
    return type;
}

Obj TypePlistFfe (
    Obj                 list )
{
    Obj                 type;           /* type, result                    */
    Int                 tnum;           /* TNUM of <list>                  */
    Obj                 family;         /* family of elements              */
    Obj                 types;          /* types list of <family>          */

    /* get the tnum and the family of the elements                         */
    tnum   = TNUM_OBJ( list );
    family = FAMILY_TYPE( TYPE_OBJ( ELM_PLIST( list, 1 ) ) );

    /* get the list types of that family                                   */
    types  = TYPES_LIST_FAM( family );

    /* if the type is not yet known, compute it                            */
    type = ELM0_LIST( types, tnum-T_PLIST_FFE+1 );
    if ( type == 0 ) {
        type = CALL_2ARGS( TYPE_LIST_HOM,
            family, INTOBJ_INT(tnum-T_PLIST_FFE+1) );
        ASS_LIST( types, tnum-T_PLIST_FFE+1, type );
#ifdef HPCGAP
        // read back element before returning it, in case another thread raced us
	type = ELM0_LIST( types, tnum-T_PLIST_FFE+1 );
#endif
    }

    /* return the type                                                     */
    return type;
}

/****************************************************************************
**
*F  SetTypePlistToPosObj(<list>, <kind>) .  convert list to positional object
**
*/
void SetTypePlistToPosObj(Obj list, Obj kind)
{
    TYPE_POSOBJ(list) = kind;
    RetypeBag(list, T_POSOBJ);
    CHANGED_BAG(list);
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
    Obj *               o;
    Obj *               n;
    UInt                len;
    UInt                i;

    /* make the new object and copy the contents                           */
    len = LEN_PLIST(list);
    if ( ! IS_MUTABLE_PLIST(list) ) {
        new = NEW_PLIST( TNUM_OBJ(list) - IMMUTABLE, len );
    }
    else {
        new = NEW_PLIST( TNUM_OBJ(list), len );
    }
    o = ADDR_OBJ(list);
    n = ADDR_OBJ(new);
    for ( i = 0; i < len+1; i++ ) {
        *n++ = *o++;
    }
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
Obj    FuncEmptyPlist( Obj self, Obj len )
{
    Obj                 new;

    if (!IS_INTOBJ(len) || INT_INTOBJ(len) < 0) {
        ErrorMayQuit("<len> must be a non-negative small integer", 0L, 0L);
    }

    new = NEW_PLIST(T_PLIST_EMPTY, INT_INTOBJ(len));
    SET_LEN_PLIST(new, 0);
    return new;
}

/****************************************************************************
**
*F  FuncShrinkAllocationPlist( <self>, <list> ) . . . give back unneeded memory
*
*  Shrinks the bag of <list> to minimal possible size.
*
*/
Obj   FuncShrinkAllocationPlist( Obj self, Obj plist )
{
    while ( ! IS_PLIST(plist) ) {
        plist = ErrorReturnObj(
            "<plist> must be a plain list (not a %s)",
            (Int)TNAM_OBJ(plist), 0,
            "you can replace <plist> via 'return <plist>;'" );
    }
    SHRINK_PLIST(plist, LEN_PLIST(plist));
    return (Obj)0;
}

/****************************************************************************
**
*F  FuncIS_PLIST_REP( <self>, <obj> ) . . . . . . . .  handler for `IS_PLIST'
*/
Obj IsPListFilt;

Obj FuncIS_PLIST_REP (
    Obj                 self,
    Obj                 obj )
{
    return (IS_PLIST( obj ) ? True : False);
}


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
Obj CopyPlist (
    Obj                 list,
    Int                 mut )
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */
    UInt                i;              /* loop variable                   */

    /* don't change immutable objects                                      */
    if ( ! IS_MUTABLE_OBJ(list) ) {
        return list;
    }

    /* make a copy                                                         */
    if ( mut ) {
        copy = NewBag( TNUM_OBJ(list), SIZE_OBJ(list) );
    }
    else {
        copy = NewBag( IMMUTABLE_TNUM( TNUM_OBJ(list) ), SIZE_OBJ(list) );
    }
    ADDR_OBJ(copy)[0] = ADDR_OBJ(list)[0];

    /* leave a forwarding pointer                                          */
    ADDR_OBJ(list)[0] = copy;
    CHANGED_BAG( list );

    /* now it is copied                                                    */
    RetypeBag( list, TNUM_OBJ(list) + COPYING );

    /* copy the subvalues                                                  */
    for ( i = 1; i <= LEN_PLIST(copy); i++ ) {
        if ( ADDR_OBJ(list)[i] != 0 ) {
            tmp = COPY_OBJ( ADDR_OBJ(list)[i], mut );
            ADDR_OBJ(copy)[i] = tmp;
            CHANGED_BAG( copy );
        }
    }

    /* return the copy                                                     */
    return copy;
}


/****************************************************************************
**
*F  CopyPlistCopy( <list>, <mut> )  . . . . . . . .  copy a copied plain list
*/
Obj CopyPlistCopy (
    Obj                 list,
    Int                 mut )
{
    return ADDR_OBJ(list)[0];
}


/****************************************************************************
**
*F  CleanPlist( <list> )  . . . . . . . . . . . . . . . clean up a plain list
*/
void CleanPlist (
    Obj                 list )
{
}


/****************************************************************************
**
*F  CleanPlistCopy( <list> )  . . . . . . . . .  clean up a copied plain list
*/
void CleanPlistCopy (
    Obj                 list )
{
    UInt                i;              /* loop variable                   */

    /* remove the forwarding pointer                                       */
    ADDR_OBJ(list)[0] = ADDR_OBJ( ADDR_OBJ(list)[0] )[0];

    /* now it is cleaned                                                   */
    RetypeBag( list, TNUM_OBJ(list) - COPYING );

    /* clean the subvalues                                                 */
    for ( i = 1; i <= LEN_PLIST(list); i++ ) {
        if ( ADDR_OBJ(list)[i] != 0 )
            CLEAN_OBJ( ADDR_OBJ(list)[i] );
    }

}


/****************************************************************************
**
*F  EqPlist(<left>,<right>) . . . . . . . . test if two plain lists are equal
**
**  'EqList'  returns 'true' if  the two plain lists   <left> and <right> are
**  equal and 'false' otherwise.
**
**  Is called from the 'EQ' binop so both  operands  are  already  evaluated.
*/
Int             EqPlist (
    Obj                 left,
    Obj                 right )
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
        return 0L;
    }

    CheckRecursionBefore();

    /* loop over the elements and compare them                             */
    for ( i = 1; i <= lenL; i++ ) {
        elmL = ELM_PLIST( left, i );
        elmR = ELM_PLIST( right, i );
        if ( ( (elmL == 0 ) != (elmR == 0) ) || ! EQ( elmL, elmR ) ) {
            STATE(RecursionDepth)--;
            return 0L;
        }
    }

    /* no differences found, the lists are equal                           */
    STATE(RecursionDepth)--;
    return 1L;
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
Int             LtPlist (
    Obj                 left,
    Obj                 right )
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
            res = 1L;
            break;
        }
        else if ( elmR == 0 && elmL != 0 ) {
            res = 0L;
            break;
        }
        else if ( ! EQ( elmL, elmR ) ) {
            res = LT( elmL, elmR );
            break;
        }
    }

    /* reached the end of at least one list                                */
    STATE(RecursionDepth)--;
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
Int             LenPlist (
    Obj                 list )
{
    return LEN_PLIST( list );
}

Int             LenPlistEmpty (
    Obj                 list )
{
    return 0L;
}


/****************************************************************************
**
*F  IsbPlist(<list>,<pos>)  . . . . . . test for an element from a plain list
**
**  'IsbPlist' returns 1 if the list <list> has an entry  at  position  <pos>
**  and 0 otherwise.  It is the responsibility of the caller to  ensure  that
**  <pos> is a positive integer.
*/
Int             IsbPlist (
    Obj                 list,
    Int                 pos )
{
    return (pos <= LEN_PLIST( list ) && ELM_PLIST( list, pos ) != 0);
}

Int             IsbPlistDense (
    Obj                 list,
    Int                 pos )
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
**  'Elm0vPlist' does the same thing than 'Elm0List', but need not check that
**  <pos>  is less  than or  equal   to the length   of  <list>, this is  the
**  responsibility of the caller.
*/
Obj             Elm0Plist (
    Obj                 list,
    Int                 pos )
{
    if ( pos <= LEN_PLIST( list ) ) {
        return ELM_PLIST( list, pos );
    }
    else {
        return 0;
    }
}

Obj             Elm0vPlist (
    Obj                 list,
    Int                 pos )
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
Obj             ElmPlist (
    Obj                 list,
    Int                 pos )
{
    Obj                 elm;            /* the selected element, result    */

    /* check the position                                                  */
    if ( LEN_PLIST( list ) < pos ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            (Int)pos, 0L,
            "you can 'return;' after assigning a value" );
        return ELM_LIST( list, pos );
    }

    /* select the element                                                  */
    elm = ELM_PLIST( list, pos );

    /* check the element                                                   */
    if ( elm == 0 ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            (Int)pos, 0L,
            "you can 'return;' after assigning a value" );
        return ELM_LIST( list, pos );
    }

    /* return the element                                                  */
    return elm;
}

Obj             ElmPlistDense (
    Obj                 list,
    Int                 pos )
{
    Obj                 elm;            /* the selected element, result    */

    /* check the position                                                  */
    if ( LEN_PLIST( list ) < pos ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            (Int)pos, 0L,
            "you can 'return;' after assigning a value" );
        return ELM_LIST( list, pos );
    }

    /* select the element                                                  */
    elm = ELM_PLIST( list, pos );

    /* return the element                                                  */
    return elm;
}

Obj             ElmvPlist (
    Obj                 list,
    Int                 pos )
{
    Obj                 elm;            /* the selected element, result    */

    /* select the element                                                  */
    elm = ELM_PLIST( list, pos );

    /* check the element                                                   */
    if ( elm == 0 ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            (Int)pos, 0L,
            "you can 'return;' after assigning a value" );
        return ELM_LIST( list, pos );
    }

    /* return the element                                                  */
    return elm;
}

Obj             ElmvPlistDense (
    Obj                 list,
    Int                 pos )
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
Obj             ElmsPlist (
    Obj                 list,
    Obj                 poss )
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
        elms = NEW_PLIST( T_PLIST_EMPTY, 0 );
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
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can 'return;' after assigning a value" );
                return ELMS_LIST( list, poss );
            }

            /* select the element                                          */
            elm = ELM_PLIST( list, pos );
            if ( elm == 0 ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can 'return;' after assigning a value" );
                return ELMS_LIST( list, poss );
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
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos, 0L,
                "you can 'return;' after assigning a value" );
            return ELMS_LIST( list, poss );
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos + (lenPoss-1) * inc, 0L,
                "you can 'return;' after assigning a value" );
            return ELMS_LIST( list, poss );
        }

        /* make the result list                                            */
        elms = NEW_PLIST( T_PLIST_DENSE, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {

            /* select the element                                          */
            elm = ELM_PLIST( list, pos );
            if ( elm == 0 ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can 'return;' after assigning a value" );
                return ELMS_LIST( list, poss );
            }

            /* assign the element to <elms>                                */
            SET_ELM_PLIST( elms, i, elm );

        }

        /* notify Gasman                                                   */
        CHANGED_BAG( elms );

    }

    /* return the result                                                   */
    return elms;
}

/* This version for lists which are known to be at least dense 
   and might be better */

Obj             ElmsPlistDense (
    Obj                 list,
    Obj                 poss )
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
        elms = NEW_PLIST( T_PLIST_EMPTY, 0 );
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
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );
            if ( lenList < pos ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can 'return;' after assigning a value" );
                return ELMS_LIST( list, poss );
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
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos, 0L,
                "you can 'return;' after assigning a value" );
            return ELMS_LIST( list, poss );
        }
        if ( pos+(lenPoss-1) * inc < 1 || lenList < pos+(lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos + (lenPoss-1) * inc, 0L,
                "you can 'return;' after assigning a value" );
            return ELMS_LIST( list, poss );
        }

        /* make the result list                                            */
        /* try to assert as many properties as possible                    */
        if      ( HAS_FILT_LIST(list, FN_IS_SSORT) && inc > 0 )
	  {
	      elms = NEW_PLIST( MUTABLE_TNUM(TNUM_OBJ(list)), lenPoss );
	/*      if (lenPoss > 1 && inc < 0)
		{
		  RESET_FILT_LIST(elms, FN_IS_SSORT);
		  SET_FILT_LIST(elms, FN_IS_NSORT);
		}  */
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

    /* return the result                                                   */
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
void UnbPlist (
    Obj                 list,
    Int                 pos )
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
	if (LEN_PLIST( list) == 0)
	  SET_FILT_LIST(list, FN_IS_EMPTY);
    }
}

void            UnbPlistImm (
    Obj                 list,
    Int                 pos )
{
    ErrorReturnVoid(
        "List Unbind: <list> must be a mutable list",
        0L, 0L,
        "you can 'return;' and ignore the unbind" );
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
    CHANGED_BAG( list );
}

void            AssPlistXXX (
    Obj                 list,
    Int                 pos,
    Obj                 val )
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

    /* We may be able cheaply to tell that the list is non-dense          */
    if (len +1 < pos)
      SET_FILT_LIST(list, FN_IS_NDENSE);
}

void AssPlistCyc   (
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
    else if (TNUM_OBJ(val) > T_CYC) {
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

void AssPlistDense (
    Obj                 list,
    Int                 pos,
    Obj                 val )
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

void AssPlistHomog (
    Obj                 list,
    Int                 pos,
    Obj                 val )
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
	    if (TNUM_OBJ( val ) <= T_CYC)
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


void            AssPlistImm (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    ErrorReturnVoid(
        "Lists Assignment: <list> must be a mutable list",
        0L, 0L,
        "you can 'return;' and ignore the assignment" );
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
    /* if <pos> is large than one use `AssPlistDense'                        */
    if ( 1 != pos ) {
        AssPlistDense( list, pos, val );
    }

    /* catch booleans                                                      */
    else if ( val == True || val == False ) {
        ConvBlist(list);
        AssBlist( list, pos, val );
    }

    /* catch FFE                                                           */
    else if ( IS_FFE(val) ) {

      /* early in initialization, the type of the empty list may not be
	 available, in which case we must NOT call method selection */
      if (TYPE_LIST_EMPTY_MUTABLE != 0)
        AssListObject( list, pos, val );
      else
	AssPlistXXX( list, pos, val );
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
	/* fix up type */
	SET_FILT_LIST(list, FN_IS_DENSE);
	if ( !IS_MUTABLE_OBJ( val) )
	  {
	    SET_FILT_LIST(list, FN_IS_HOMOG);
	    if ( TNUM_OBJ(val) <= T_CYC ) 
	      RetypeBag( list, T_PLIST_CYC);
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
**  'AsssPlist' assignes the   values from the list  <vals>  at the positions
**  given in the list <poss> to the list <list>.  It is the responsibility of
**  the caller  to  ensure that <poss> is   dense and contains  only positive
**  integers, that <poss> and <vals> have the same length, and that <vals> is
**  dense.
**
**  'AsssPlist' is the function in 'AsssListFuncs' for plain lists.
*/
void            AsssPlist (
    Obj                 list,
    Obj                 poss,
    Obj                 vals )
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

void            AsssPlistXXX (
    Obj                 list,
    Obj                 poss,
    Obj                 vals )
{
    /* the list will probably loose its flags/properties                   */
    CLEAR_FILTS_LIST(list);

    /* and delegate                                                        */
    AsssPlist( list, poss, vals );
}

void            AsssPlistImm (
    Obj                 list,
    Obj                 poss,
    Obj                 val )
{
    ErrorReturnVoid(
        "Lists Assignments: <list> must be a mutable list",
        0L, 0L,
        "you can 'return;' and ignore the assignment" );
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
Int             IsDensePlist (
    Obj                 list )
{
    Int                 lenList;        /* length of <list>                */
    Int                 i;              /* loop variable                   */

    /* get the length of the list                                          */
    lenList = LEN_PLIST( list );

    /* special case for empty list                                         */
    if ( lenList == 0 ) {
        SET_FILT_LIST( list, FN_IS_EMPTY );
        return 1L;
    }

    /* loop over the entries of the list                                   */
    for ( i = 1; i <= lenList; i++ ) {
        if ( ELM_PLIST( list, i ) == 0 )
            return 0L;
    }

    /* set the dense flag (even if the elements are mutable)               */
    SET_FILT_LIST( list, FN_IS_DENSE );

    /* no hole found                                                       */
    return 1L;
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
Int             IsHomogPlist (
    Obj                 list )
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
Int             IsTablePlist (
    Obj                 list )
{
    Int                 tnum;
    tnum = KTNumPlist( list, (Obj *)0 );
    return (T_PLIST_TAB <= tnum && tnum <= T_PLIST_TAB_RECT_SSORT);
}


/****************************************************************************
**
*F  IsSSortPlist(<list>)  . . . . . sorted list test function for plain lists
**
**  'IsSSortPlist'  returns 2  if the  plain  list <list>  is strictly sorted
**  (each element is strictly smaller than the next one), and 0 otherwise.
**
**  'IsSSortPlist' is the function in 'IsSSortListFuncs' for plain lists.
*/

Int             IsSSortPlist (
    Obj                 list )
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
        SET_FILT_LIST( list, FN_IS_EMPTY );
        return 2L;
    }

    /* get the first element                                               */
    elm1    = ELM_PLIST( list, 1 );
    if (elm1 == 0)
      goto notDense;
#ifdef HPCGAP
    if (!CheckReadAccess(elm1))
      return 0L;
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
	return 0L;
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

      /* and we know about homoheneity */
      if ( ! areMut ) {
	if (isHom)
	  SET_FILT_LIST( list, FN_IS_HOMOG);
	else
	  SET_FILT_LIST( list, FN_IS_HOMOG);
	SET_FILT_LIST( list, FN_IS_SSORT );
      }
      return 2L;
    }
    else {
      if ( ! areMut ) {
	SET_FILT_LIST( list, FN_IS_NSORT );
      }
      return 0L;
      
    }

 notDense:
    SET_FILT_LIST( list, FN_IS_NDENSE );
    return 0L;
}

Int             IsSSortPlistDense (
    Obj                 list )
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
        SET_FILT_LIST( list, FN_IS_EMPTY );
        return 2L;
    }

    /* get the first element                                               */
    elm1    = ELM_PLIST( list, 1 );
#ifdef HPCGAP
    if (!CheckReadAccess(elm1))
      return 0L;
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
        return 0L;
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
      return 2L;
    }
    else {
        if ( ! areMut ) {
	  SET_FILT_LIST( list, FN_IS_NSORT );
        }
        return 0L;
    }

}

Int             IsSSortPlistHom (
    Obj                 list )
{
    Int                 lenList;
    Obj elm1;
    Obj elm2;
    Int                 i;
        
    /* get the length                                                      */
    lenList = LEN_PLIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        SET_FILT_LIST( list, FN_IS_EMPTY );
        return 2L;
    }

    /* get the first element                                               */
    elm1    = ELM_PLIST( list, 1 );
#ifdef HPCGAP
    if (!CheckReadAccess(elm1))
      return 0L;
#endif 

    /* loop over the other elements                                        */
    for ( i = 2; i <= lenList; i++ ) {
      elm2 = ELM_PLIST( list, i );
#ifdef HPCGAP
      if (!CheckReadAccess(elm2))
	return 0L;
#endif 
      if ( ! LT( elm1, elm2 ) )
	break;
      elm1 = elm2;
      }
    /* set flags      */

    if ( lenList < i ) {
      SET_FILT_LIST( list, FN_IS_SSORT );
      return 2L;
    }
    else {
      SET_FILT_LIST( list, FN_IS_NSORT );
      return 0L;
    }

}


Obj FuncSetIsSSortedPlist (Obj self, Obj list)
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
Int             IsPossPlist (
    Obj                 list )
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
	  return 0L;
#ifdef HPCGAP
        if ( !CheckReadAccess(elm) )
	  return 0L;
#endif
	if (IS_INTOBJ(elm))
	  {
	    if (INT_INTOBJ(elm) <= 0 )
	      return 0L;
	  }
	else
	  if (TNUM_OBJ(elm) != T_INTPOS)
	    return 0L;
    }

    /* no problems found                                                   */
    return 1L;
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
Obj             PosPlist (
    Obj                 list,
    Obj                 val,
    Obj                 start )
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

Obj             PosPlistDense (
    Obj                 list,
    Obj                 val,
    Obj                 start )
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

Obj             PosPlistSort (
    Obj                 list,
    Obj                 val,
    Obj                 start )
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


Obj             PosPlistHomSort (
    Obj                 list,
    Obj                 val,
    Obj                 start )
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
void            PlainPlist (
    Obj                 list )
{
    return;
}

/****************************************************************************
**
*F  SavePlist( <list> )
**
*/

void SavePlist( Obj list )
{
  UInt i;
  SaveUInt(LEN_PLIST(list));
  for (i = 1; i <= LEN_PLIST(list); i++)
    SaveSubObj(ELM_PLIST(list,i));
  return;
}

/****************************************************************************
**
*F  LoadPlist( <list> )
**
*/

void LoadPlist( Obj list )
{
  UInt i;
  SET_LEN_PLIST(list, LoadUInt());
  for (i = 1; i <= LEN_PLIST(list); i++)
    SET_ELM_PLIST(list,i, LoadSubObj());
  return;
}


/****************************************************************************
**
*F  FuncASS_PLIST_DEFAULT( <self>, <plist>, <pos>, <val> )  . . `AssPlistXXX'
*/
Obj FuncASS_PLIST_DEFAULT (
    Obj                 self,
    Obj                 plist,
    Obj                 pos,
    Obj                 val )
{
    Int                 p;

    /* check the arguments                                                 */
    while ( ! IS_INTOBJ(pos) ) {
        pos = ErrorReturnObj(
            "<pos> must be an integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0,
            "you can replace <pos> via 'return <pos>;'" );
    }
    p = INT_INTOBJ(pos);
    if ( p < 0 ) {
        pos = ErrorReturnObj(
            "<pos> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0,
            "you can replace <pos> via 'return <pos>;'" );
        return FuncASS_PLIST_DEFAULT( self, plist, pos, val );
    }
    while ( ! IS_PLIST(plist) || ! IS_MUTABLE_PLIST(plist) ) {
        plist = ErrorReturnObj(
            "<list> must be a mutable plain list (not a %s)",
            (Int)TNAM_OBJ(plist), 0,
            "you can replace <list> via 'return <list>;'" );
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
**  (or immutable, but MakeImmutable will have caught that case before we get here)
*/

void MakeImmutablePlistInHom( Obj list )
{
  UInt i;
  Obj elm;
  RetypeBag( list, IMMUTABLE_TNUM(TNUM_OBJ(list)));
  for (i = 1; i <= LEN_PLIST(list); i++)
    {
      elm = ELM_PLIST( list, i);
      if (elm != 0)
	{
	  MakeImmutable( elm );
	  CHANGED_BAG(list);
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
**  (or immutable, but MakeImmutable will have caught that case before we get here)
*/

void MakeImmutablePlistNoMutElms( Obj list )
{
  RetypeBag( list, IMMUTABLE_TNUM(TNUM_OBJ(list)));
}

/****************************************************************************
**
*F  FuncIsRectangularTablePlist( <plist> )
**
**  Determine whether a PLIST is a rectangulat table, set the TNUM 
**  appropriately. This is a mathod for IsRectangularTable, so the
**  method selection has alrewady checked that the list is a table
**  and should not bother to call us, unless we do not already know whether it
**  is rectangular
*/

Obj FuncIsRectangularTablePlist( Obj self, Obj plist)
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
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_PLIST,                                "list (plain)" },
  { T_PLIST            +IMMUTABLE,          "list (plain,imm)" },
  { T_PLIST                       +COPYING, "list (plain,copied)" },
  { T_PLIST            +IMMUTABLE +COPYING, "list (plain,imm,copied)" },

  { T_PLIST_NDENSE,                         "list (plain,ndense)" },
  { T_PLIST_NDENSE     +IMMUTABLE,          "list (plain,ndense,imm)" },
  { T_PLIST_NDENSE                +COPYING, "list (plain,ndense,copied)" },
  { T_PLIST_NDENSE     +IMMUTABLE +COPYING, "list (plain,ndense,imm,copied)" },

  { T_PLIST_DENSE,                          "list (plain,dense)" },
  { T_PLIST_DENSE      +IMMUTABLE,          "list (plain,dense,imm)" },
  { T_PLIST_DENSE                 +COPYING, "list (plain,dense,copied)" },
  { T_PLIST_DENSE      +IMMUTABLE +COPYING, "list (plain,dense,imm,copied)" },

  { T_PLIST_DENSE_NHOM,                     "list (plain,dense,nhom)" },
  { T_PLIST_DENSE_NHOM +IMMUTABLE,          "list (plain,dense,nhom,imm)" },
  { T_PLIST_DENSE_NHOM            +COPYING, "list (plain,dense,nhom,copied)" },
  { T_PLIST_DENSE_NHOM +IMMUTABLE +COPYING, "list (plain,dense,nhom,imm,copied)" },

  { T_PLIST_DENSE_NHOM_SSORT,                     "list (plain,dense,nhom,ssort)" },
  { T_PLIST_DENSE_NHOM_SSORT +IMMUTABLE,          "list (plain,dense,nhom,ssort,imm)" },
  { T_PLIST_DENSE_NHOM_SSORT            +COPYING, "list (plain,dense,nhom,ssort,copied)" },
  { T_PLIST_DENSE_NHOM_SSORT +IMMUTABLE +COPYING, "list (plain,dense,nhom,ssort,imm,copied)" },

  { T_PLIST_DENSE_NHOM_NSORT,                     "list (plain,dense,nhom,nsort)" },
  { T_PLIST_DENSE_NHOM_NSORT +IMMUTABLE,          "list (plain,dense,nhom,nsort,imm)" },
  { T_PLIST_DENSE_NHOM_NSORT            +COPYING, "list (plain,dense,nhom,nsort,copied)" },
  { T_PLIST_DENSE_NHOM_NSORT +IMMUTABLE +COPYING, "list (plain,dense,nhom,nsort,imm,copied)" },

  { T_PLIST_EMPTY,                          "list (plain,empty)" },
  { T_PLIST_EMPTY      +IMMUTABLE,          "list (plain,empty,imm)" },
  { T_PLIST_EMPTY                 +COPYING, "list (plain,empty,copied)" },
  { T_PLIST_EMPTY      +IMMUTABLE +COPYING, "list (plain,empty,imm,copied)" },

  { T_PLIST_HOM,                            "list (plain,hom)" },
  { T_PLIST_HOM        +IMMUTABLE,          "list (plain,hom,imm)" },
  { T_PLIST_HOM                   +COPYING, "list (plain,hom,copied)" },
  { T_PLIST_HOM        +IMMUTABLE +COPYING, "list (plain,hom,imm,copied)" },

  { T_PLIST_HOM_NSORT,                      "list (plain,hom,nsort)" },
  { T_PLIST_HOM_NSORT  +IMMUTABLE,          "list (plain,hom,nsort,imm)" },
  { T_PLIST_HOM_NSORT             +COPYING, "list (plain,hom,nsort,copied)" },
  { T_PLIST_HOM_NSORT  +IMMUTABLE +COPYING, "list (plain,hom,nsort,imm,copied)" },

  { T_PLIST_HOM_SSORT,                      "list (plain,hom,ssort)" },
  { T_PLIST_HOM_SSORT +IMMUTABLE,           "list (plain,hom,ssort,imm)" },
  { T_PLIST_HOM_SSORT            +COPYING,  "list (plain,hom,ssort,copied)" },
  { T_PLIST_HOM_SSORT +IMMUTABLE +COPYING,  "list (plain,hom,ssort,imm,copied)" },

  { T_PLIST_TAB,                            "list (plain,table)" },
  { T_PLIST_TAB       +IMMUTABLE,           "list (plain,table,imm)" },
  { T_PLIST_TAB                  +COPYING,  "list (plain,table,copied)" },
  { T_PLIST_TAB       +IMMUTABLE +COPYING,  "list (plain,table,imm,copied)" },

  { T_PLIST_TAB_NSORT,                      "list (plain,table,nsort)" },
  { T_PLIST_TAB_NSORT +IMMUTABLE,           "list (plain,table,nsort,imm)" },
  { T_PLIST_TAB_NSORT            +COPYING,  "list (plain,table,nsort,copied)" },
  { T_PLIST_TAB_NSORT +IMMUTABLE +COPYING,  "list (plain,table,nsort,imm,copied)" },

  { T_PLIST_TAB_SSORT,                      "list (plain,table,ssort)" },
  { T_PLIST_TAB_SSORT +IMMUTABLE,           "list (plain,table,ssort,imm)" },
  { T_PLIST_TAB_SSORT            +COPYING,  "list (plain,table,ssort,copied)" },
  { T_PLIST_TAB_SSORT +IMMUTABLE +COPYING,  "list (plain,table,ssort,imm,copied)" },

  { T_PLIST_TAB_RECT,                            "list (plain,rect table)" },
  { T_PLIST_TAB_RECT       +IMMUTABLE,           "list (plain,rect table,imm)" },
  { T_PLIST_TAB_RECT                  +COPYING,  "list (plain,rect table,copied)" },
  { T_PLIST_TAB_RECT       +IMMUTABLE +COPYING,  "list (plain,rect table,imm,copied)" },

  { T_PLIST_TAB_RECT_NSORT,                      "list (plain,rect table,nsort)" },
  { T_PLIST_TAB_RECT_NSORT +IMMUTABLE,           "list (plain,rect table,nsort,imm)" },
  { T_PLIST_TAB_RECT_NSORT            +COPYING,  "list (plain,rect table,nsort,copied)" },
  { T_PLIST_TAB_RECT_NSORT +IMMUTABLE +COPYING,  "list (plain,rect table,nsort,imm,copied)" },

  { T_PLIST_TAB_RECT_SSORT,                      "list (plain,rect table,ssort)" },
  { T_PLIST_TAB_RECT_SSORT +IMMUTABLE,           "list (plain,rect table,ssort,imm)" },
  { T_PLIST_TAB_RECT_SSORT            +COPYING,  "list (plain,rect table,ssort,copied)" },
  { T_PLIST_TAB_RECT_SSORT +IMMUTABLE +COPYING,  "list (plain,rect table,ssort,imm,copied)" },

  { T_PLIST_CYC,                            "list (plain,cyc)" },
  { T_PLIST_CYC       +IMMUTABLE,           "list (plain,cyc,imm)" },
  { T_PLIST_CYC                  +COPYING,  "list (plain,cyc,copied)" },
  { T_PLIST_CYC       +IMMUTABLE +COPYING,  "list (plain,cyc,imm,copied)" },

  { T_PLIST_CYC_NSORT,                      "list (plain,cyc,nsort)" },
  { T_PLIST_CYC_NSORT +IMMUTABLE,           "list (plain,cyc,nsort,imm)" },
  { T_PLIST_CYC_NSORT            +COPYING,  "list (plain,cyc,nsort,copied)" },
  { T_PLIST_CYC_NSORT +IMMUTABLE +COPYING,  "list (plain,cyc,nsort,imm,copied)" },

  { T_PLIST_CYC_SSORT,                      "list (plain,cyc,ssort)" },
  { T_PLIST_CYC_SSORT +IMMUTABLE,           "list (plain,cyc,ssort,imm)" },
  { T_PLIST_CYC_SSORT            +COPYING,  "list (plain,cyc,ssort,copied)" },
  { T_PLIST_CYC_SSORT +IMMUTABLE +COPYING,  "list (plain,cyc,ssort,imm,copied)" },

  { T_PLIST_FFE,                     "list (sml fin fld elms)" },
  { T_PLIST_FFE +IMMUTABLE,          "list (sml fin fld elms,imm)" },
  { T_PLIST_FFE            +COPYING, "list (sml fin fld elms,copied)" },
  { T_PLIST_FFE +IMMUTABLE +COPYING, "list (sml fin fld elms,imm,copied)" },

  { -1,                                     "" }
};


/****************************************************************************
**
*V  ClearFiltsTab . . . . . . . . . . . . . . . . . . . .  clear filter tnums
*/
static Int ClearFiltsTab [] = {
    T_PLIST,                          T_PLIST,
    T_PLIST           +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_NDENSE,                   T_PLIST,
    T_PLIST_NDENSE    +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_DENSE,                    T_PLIST,
    T_PLIST_DENSE     +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_DENSE_NHOM,               T_PLIST,
    T_PLIST_DENSE_NHOM+IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT,         T_PLIST,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, T_PLIST +IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT,         T_PLIST,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, T_PLIST +IMMUTABLE,
    T_PLIST_EMPTY,                    T_PLIST,
    T_PLIST_EMPTY     +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_HOM,                      T_PLIST,
    T_PLIST_HOM       +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_HOM_NSORT,                T_PLIST,
    T_PLIST_HOM_NSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_HOM_SSORT,                T_PLIST,
    T_PLIST_HOM_SSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_TAB,                      T_PLIST,
    T_PLIST_TAB       +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_TAB_NSORT,                T_PLIST,
    T_PLIST_TAB_NSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_TAB_SSORT,                T_PLIST,
    T_PLIST_TAB_SSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_TAB_RECT,                      T_PLIST,
    T_PLIST_TAB_RECT       +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT,                T_PLIST,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT,                T_PLIST,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_CYC,                      T_PLIST,
    T_PLIST_CYC       +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_CYC_NSORT,                T_PLIST,
    T_PLIST_CYC_NSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_CYC_SSORT,                T_PLIST,
    T_PLIST_CYC_SSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_FFE,                      T_PLIST,
    T_PLIST_FFE       +IMMUTABLE,     T_PLIST +IMMUTABLE,

    -1,                               -1
};


/****************************************************************************
**
*V  HasFiltTab  . . . . . . . . . . . . . . . . . . . . .  tester filter tnum
*/
static Int HasFiltTab [] = {

    /* mutable plain lists                                                 */
    T_PLIST,                      FN_IS_MUTABLE,  1,
    T_PLIST,                      FN_IS_EMPTY,    0,
    T_PLIST,                      FN_IS_DENSE,    0,
    T_PLIST,                      FN_IS_NDENSE,   0,
    T_PLIST,                      FN_IS_HOMOG,    0,
    T_PLIST,                      FN_IS_NHOMOG,   0,
    T_PLIST,                      FN_IS_TABLE,    0,
    T_PLIST,                      FN_IS_RECT,     0,
    T_PLIST,                      FN_IS_SSORT,    0,
    T_PLIST,                      FN_IS_NSORT,    0,

    /* immutable plain lists                                               */
    T_PLIST           +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST           +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST           +IMMUTABLE, FN_IS_DENSE,    0,
    T_PLIST           +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST           +IMMUTABLE, FN_IS_HOMOG,    0,
    T_PLIST           +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST           +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST           +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST           +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST           +IMMUTABLE, FN_IS_NSORT,    0,

    /* mutable empty list                                                  */
    T_PLIST_EMPTY,                FN_IS_MUTABLE,  1,
    T_PLIST_EMPTY,                FN_IS_EMPTY,    1,
    T_PLIST_EMPTY,                FN_IS_DENSE,    1,
    T_PLIST_EMPTY,                FN_IS_NDENSE,   0,
    T_PLIST_EMPTY,                FN_IS_HOMOG,    1,
    T_PLIST_EMPTY,                FN_IS_NHOMOG,   0,
    T_PLIST_EMPTY,                FN_IS_TABLE,    0,
    T_PLIST_EMPTY,                FN_IS_RECT,     0,
    T_PLIST_EMPTY,                FN_IS_SSORT,    1,
    T_PLIST_EMPTY,                FN_IS_NSORT,    0,

    /* immutable empty list                                                */
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_EMPTY,    1,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_SSORT,    1,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NSORT,    0,

    /* mutable dense list                                                  */
    T_PLIST_DENSE,                FN_IS_MUTABLE,  1,
    T_PLIST_DENSE,                FN_IS_EMPTY,    0,
    T_PLIST_DENSE,                FN_IS_DENSE,    1,
    T_PLIST_DENSE,                FN_IS_NDENSE,   0,
    T_PLIST_DENSE,                FN_IS_HOMOG,    0,
    T_PLIST_DENSE,                FN_IS_NHOMOG,   0,
    T_PLIST_DENSE,                FN_IS_TABLE,    0,
    T_PLIST_DENSE,                FN_IS_RECT,     0,
    T_PLIST_DENSE,                FN_IS_SSORT,    0,
    T_PLIST_DENSE,                FN_IS_NSORT,    0,

    /* immutable dense list                                                */
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_HOMOG,    0,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_NSORT,    0,

    /* mutable dense list, which contains immutables and is not homog      */
    T_PLIST_DENSE_NHOM,           FN_IS_MUTABLE,  1,
    T_PLIST_DENSE_NHOM,           FN_IS_EMPTY,    0,
    T_PLIST_DENSE_NHOM,           FN_IS_DENSE,    1,
    T_PLIST_DENSE_NHOM,           FN_IS_NDENSE,   0,
    T_PLIST_DENSE_NHOM,           FN_IS_HOMOG,    0,
    T_PLIST_DENSE_NHOM,           FN_IS_NHOMOG,   1,
    T_PLIST_DENSE_NHOM,           FN_IS_TABLE,    0,
    T_PLIST_DENSE_NHOM,           FN_IS_RECT,     0,
    T_PLIST_DENSE_NHOM,           FN_IS_SSORT,    0,
    T_PLIST_DENSE_NHOM,           FN_IS_NSORT,    0,

    /* immutable dense list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_HOMOG,    0,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NHOMOG,   1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NSORT,    0,

    /* mutable dense ssorted list, which contains immutables and is not homog      */
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_MUTABLE,  1,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_EMPTY,    0,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_DENSE,    1,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_NDENSE,   0,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_HOMOG,    0,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_NHOMOG,   1,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_TABLE,    0,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_RECT,     0,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_SSORT,    1,
    T_PLIST_DENSE_NHOM_SSORT,      FN_IS_NSORT,    0,

    /* immutable dense ssorted list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_HOMOG,    0,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_NHOMOG,   1,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_SSORT,    1,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_NSORT,    0,

    /* mutable dense nsorted list, which contains immutables and is not homog      */
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_MUTABLE,  1,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_EMPTY,    0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_DENSE,    1,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_NDENSE,   0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_HOMOG,    0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_NHOMOG,   1,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_TABLE,    0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_RECT,     0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_SSORT,    0,
    T_PLIST_DENSE_NHOM_NSORT,           FN_IS_NSORT,    1,

    /* immutable dense nsorted list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_HOMOG,    0,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_NHOMOG,   1,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_RECT,    0,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_NSORT,    1,

    /* a mutable list with holes                                           */
    T_PLIST_NDENSE,               FN_IS_MUTABLE,  1,
    T_PLIST_NDENSE,               FN_IS_EMPTY,    0,
    T_PLIST_NDENSE,               FN_IS_DENSE,    0,
    T_PLIST_NDENSE,               FN_IS_NDENSE,   1,
    T_PLIST_NDENSE,               FN_IS_HOMOG,    0,
    T_PLIST_NDENSE,               FN_IS_NHOMOG,   0,
    T_PLIST_NDENSE,               FN_IS_TABLE,    0,
    T_PLIST_NDENSE,               FN_IS_RECT,     0,
    T_PLIST_NDENSE,               FN_IS_SSORT,    0,
    T_PLIST_NDENSE,               FN_IS_NSORT,    0,

    /* an immutable list with holes                                        */
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_DENSE,    0,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_NDENSE,   1,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_HOMOG,    0,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_RECT,    0,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_NSORT,    0,

    /* mutable dense list, which conts imms, is homogeneous, not a table   */
    T_PLIST_HOM,                  FN_IS_MUTABLE,  1,
    T_PLIST_HOM,                  FN_IS_EMPTY,    0,
    T_PLIST_HOM,                  FN_IS_DENSE,    1,
    T_PLIST_HOM,                  FN_IS_NDENSE,   0,
    T_PLIST_HOM,                  FN_IS_HOMOG,    1,
    T_PLIST_HOM,                  FN_IS_NHOMOG,   0,
    T_PLIST_HOM,                  FN_IS_TABLE,    0,
    T_PLIST_HOM,                  FN_IS_RECT,    0,
    T_PLIST_HOM,                  FN_IS_SSORT,    0,
    T_PLIST_HOM,                  FN_IS_NSORT,    0,

    /* immutable dense list, which is immutable, homogeneous, not a table  */
    T_PLIST_HOM       +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_RECT,    0,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_NSORT,    0,

    /* ssort mutable dense list, which conts imms, is homog, not a table   */
    T_PLIST_HOM_SSORT,            FN_IS_MUTABLE,  1,
    T_PLIST_HOM_SSORT,            FN_IS_EMPTY,    0,
    T_PLIST_HOM_SSORT,            FN_IS_DENSE,    1,
    T_PLIST_HOM_SSORT,            FN_IS_NDENSE,   0,
    T_PLIST_HOM_SSORT,            FN_IS_HOMOG,    1,
    T_PLIST_HOM_SSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_HOM_SSORT,            FN_IS_TABLE,    0,
    T_PLIST_HOM_SSORT,            FN_IS_RECT,    0,
    T_PLIST_HOM_SSORT,            FN_IS_SSORT,    1,
    T_PLIST_HOM_SSORT,            FN_IS_NSORT,    0,

    /* ssort immutable dense list, which is immutable, homog, not a table  */
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_RECT,    0,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_SSORT,    1,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_NSORT,    0,

    /* nsort mutable dense list, which conts imms, is homog, not a table   */
    T_PLIST_HOM_NSORT,            FN_IS_MUTABLE,  1,
    T_PLIST_HOM_NSORT,            FN_IS_EMPTY,    0,
    T_PLIST_HOM_NSORT,            FN_IS_DENSE,    1,
    T_PLIST_HOM_NSORT,            FN_IS_NDENSE,   0,
    T_PLIST_HOM_NSORT,            FN_IS_HOMOG,    1,
    T_PLIST_HOM_NSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_HOM_NSORT,            FN_IS_TABLE,    0,
    T_PLIST_HOM_NSORT,            FN_IS_RECT,    0,
    T_PLIST_HOM_NSORT,            FN_IS_SSORT,    0,
    T_PLIST_HOM_NSORT,            FN_IS_NSORT,    1,

    /* nsort immutable dense list, which is immutable, homog, not a table  */
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_NSORT,    1,

    /* mutable dense list, which is immutable, homog, non-empty, table     */
    T_PLIST_TAB,                  FN_IS_MUTABLE,  1,
    T_PLIST_TAB,                  FN_IS_EMPTY,    0,
    T_PLIST_TAB,                  FN_IS_DENSE,    1,
    T_PLIST_TAB,                  FN_IS_NDENSE,   0,
    T_PLIST_TAB,                  FN_IS_HOMOG,    1,
    T_PLIST_TAB,                  FN_IS_NHOMOG,   0,
    T_PLIST_TAB,                  FN_IS_TABLE,    1,
    T_PLIST_TAB,                  FN_IS_RECT,     0,
    T_PLIST_TAB,                  FN_IS_SSORT,    0,
    T_PLIST_TAB,                  FN_IS_NSORT,    0,

    /* immutable dense list, which is immutable, homog, non-empty, table   */
    T_PLIST_TAB       +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_TABLE,    1,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_NSORT,    0,

    /* ssort, mutable dense list, which is imm, homog, non-empty, table    */
    T_PLIST_TAB_SSORT,            FN_IS_MUTABLE,  1,
    T_PLIST_TAB_SSORT,            FN_IS_EMPTY,    0,
    T_PLIST_TAB_SSORT,            FN_IS_DENSE,    1,
    T_PLIST_TAB_SSORT,            FN_IS_NDENSE,   0,
    T_PLIST_TAB_SSORT,            FN_IS_HOMOG,    1,
    T_PLIST_TAB_SSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_TAB_SSORT,            FN_IS_TABLE,    1,
    T_PLIST_TAB_SSORT,            FN_IS_RECT,     0,
    T_PLIST_TAB_SSORT,            FN_IS_SSORT,    1,
    T_PLIST_TAB_SSORT,            FN_IS_NSORT,    0,

    /* ssort, immutable dense list, which is imm, homog, non-empty, table  */
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_TABLE,    1,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_SSORT,    1,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_NSORT,    0,

    /* nsort, mutable dense list, which is imm, homog, non-empty, table    */
    T_PLIST_TAB_NSORT,            FN_IS_MUTABLE,  1,
    T_PLIST_TAB_NSORT,            FN_IS_EMPTY,    0,
    T_PLIST_TAB_NSORT,            FN_IS_DENSE,    1,
    T_PLIST_TAB_NSORT,            FN_IS_NDENSE,   0,
    T_PLIST_TAB_NSORT,            FN_IS_HOMOG,    1,
    T_PLIST_TAB_NSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_TAB_NSORT,            FN_IS_TABLE,    1,
    T_PLIST_TAB_NSORT,            FN_IS_RECT,     0,
    T_PLIST_TAB_NSORT,            FN_IS_SSORT,    0,
    T_PLIST_TAB_NSORT,            FN_IS_NSORT,    1,

    /* nsort, immutable dense list, which is imm, homog, non-empty, table  */
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_TABLE,    1,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NSORT,    1,

    /* mutable dense list, which is immutable, homog, non-empty, rect table     */
    T_PLIST_TAB_RECT,                  FN_IS_MUTABLE,  1,
    T_PLIST_TAB_RECT,                  FN_IS_EMPTY,    0,
    T_PLIST_TAB_RECT,                  FN_IS_DENSE,    1,
    T_PLIST_TAB_RECT,                  FN_IS_NDENSE,   0,
    T_PLIST_TAB_RECT,                  FN_IS_HOMOG,    1,
    T_PLIST_TAB_RECT,                  FN_IS_NHOMOG,   0,
    T_PLIST_TAB_RECT,                  FN_IS_TABLE,    1,
    T_PLIST_TAB_RECT,                  FN_IS_RECT,     1,
    T_PLIST_TAB_RECT,                  FN_IS_SSORT,    0,
    T_PLIST_TAB_RECT,                  FN_IS_NSORT,    0,

    /* immutable dense list, which is immutable, homog, non-empty, rect table   */
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_TABLE,    1,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_RECT,     1,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_NSORT,    0,

    /* ssort, mutable dense list, which is imm, homog, non-empty, rect table    */
    T_PLIST_TAB_RECT_SSORT,            FN_IS_MUTABLE,  1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_EMPTY,    0,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_DENSE,    1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NDENSE,   0,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_HOMOG,    1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_TABLE,    1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_RECT,     1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_SSORT,    1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NSORT,    0,

    /* ssort, immutable dense list, which is imm, homog, non-empty, rect table  */
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_TABLE,    1,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_RECT,     1,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_SSORT,    1,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_NSORT,    0,

    /* nsort, mutable dense list, which is imm, homog, non-empty, rect table    */
    T_PLIST_TAB_RECT_NSORT,            FN_IS_MUTABLE,  1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_EMPTY,    0,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_DENSE,    1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NDENSE,   0,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_HOMOG,    1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_TABLE,    1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_RECT,     1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_SSORT,    0,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NSORT,    1,

    /* nsort, immutable dense list, which is imm, homog, non-empty, rect table  */
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_TABLE,    1,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_RECT,     1,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_NSORT,    1,

    /* mutable dense list, which only contains objects of type <= T_CYC    */
    T_PLIST_CYC,                  FN_IS_MUTABLE,  1,
    T_PLIST_CYC,                  FN_IS_EMPTY,    0,
    T_PLIST_CYC,                  FN_IS_DENSE,    1,
    T_PLIST_CYC,                  FN_IS_NDENSE,   0,
    T_PLIST_CYC,                  FN_IS_HOMOG,    1,
    T_PLIST_CYC,                  FN_IS_NHOMOG,   0,
    T_PLIST_CYC,                  FN_IS_TABLE,    0,
    T_PLIST_CYC,                  FN_IS_RECT,     0,
    T_PLIST_CYC,                  FN_IS_SSORT,    0,
    T_PLIST_CYC,                  FN_IS_NSORT,    0,

    /* immutable dense list, which only contains objects of type <= T_CYC  */
    T_PLIST_CYC       +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NSORT,    0,

    /* ssort mutable dense list, which only contains objs of type <= T_CYC */
    T_PLIST_CYC_SSORT,            FN_IS_MUTABLE,  1,
    T_PLIST_CYC_SSORT,            FN_IS_EMPTY,    0,
    T_PLIST_CYC_SSORT,            FN_IS_DENSE,    1,
    T_PLIST_CYC_SSORT,            FN_IS_NDENSE,   0,
    T_PLIST_CYC_SSORT,            FN_IS_HOMOG,    1,
    T_PLIST_CYC_SSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_CYC_SSORT,            FN_IS_TABLE,    0,
    T_PLIST_CYC_SSORT,            FN_IS_RECT,     0,
    T_PLIST_CYC_SSORT,            FN_IS_SSORT,    1,
    T_PLIST_CYC_SSORT,            FN_IS_NSORT,    0,

    /* ssort immutable dense list, which contains objs of type <= T_CYC    */
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_SSORT,    1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NSORT,    0,

    /* nsort mutable dense list, which only contains objs of type <= T_CYC */
    T_PLIST_CYC_NSORT,            FN_IS_MUTABLE,  1,
    T_PLIST_CYC_NSORT,            FN_IS_EMPTY,    0,
    T_PLIST_CYC_NSORT,            FN_IS_DENSE,    1,
    T_PLIST_CYC_NSORT,            FN_IS_NDENSE,   0,
    T_PLIST_CYC_NSORT,            FN_IS_HOMOG,    1,
    T_PLIST_CYC_NSORT,            FN_IS_NHOMOG,   0,
    T_PLIST_CYC_NSORT,            FN_IS_TABLE,    0,
    T_PLIST_CYC_NSORT,            FN_IS_RECT,     0,
    T_PLIST_CYC_NSORT,            FN_IS_SSORT,    0,
    T_PLIST_CYC_NSORT,            FN_IS_NSORT,    1,

    /* nsort immutable dense list, which contains objs of type <= T_CYC    */
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_CYC_NSORT,            FN_IS_RECT,     0,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NSORT,    1,

    /* mutable dense list, which only contains objects of type T_FFE
       all written over the same field*/
    T_PLIST_FFE,            FN_IS_MUTABLE,  1,
    T_PLIST_FFE,            FN_IS_EMPTY,    0,
    T_PLIST_FFE,            FN_IS_DENSE,    1,
    T_PLIST_FFE,            FN_IS_NDENSE,   0,
    T_PLIST_FFE,            FN_IS_HOMOG,    1,
    T_PLIST_FFE,            FN_IS_NHOMOG,   0,
    T_PLIST_FFE,            FN_IS_TABLE,    0,
    T_PLIST_FFE,            FN_IS_RECT,     0,
    T_PLIST_FFE,            FN_IS_SSORT,    0,
    T_PLIST_FFE,            FN_IS_NSORT,    0,

    /* immutable dense list, which only contains objects of type T_FFE
       all written over the same field */
    T_PLIST_FFE +IMMUTABLE, FN_IS_MUTABLE,  0,
    T_PLIST_FFE +IMMUTABLE, FN_IS_EMPTY,    0,
    T_PLIST_FFE +IMMUTABLE, FN_IS_DENSE,    1,
    T_PLIST_FFE +IMMUTABLE, FN_IS_NDENSE,   0,
    T_PLIST_FFE +IMMUTABLE, FN_IS_HOMOG,    1,
    T_PLIST_FFE +IMMUTABLE, FN_IS_NHOMOG,   0,
    T_PLIST_FFE +IMMUTABLE, FN_IS_TABLE,    0,
    T_PLIST_FFE +IMMUTABLE, FN_IS_RECT,     0,
    T_PLIST_FFE +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_FFE +IMMUTABLE, FN_IS_NSORT,    0,

    -1,                         -1,             -1
};


/****************************************************************************
**
*V  SetFiltTab  . . . . . . . . . . . . . . . . . . . . .  setter filter tnum
*/
static Int SetFiltTab [] = {

    /* mutable plain lists                                                 */
    T_PLIST,                      FN_IS_MUTABLE, T_PLIST,
    T_PLIST,                      FN_IS_EMPTY,   T_PLIST_EMPTY,
    T_PLIST,                      FN_IS_DENSE,   T_PLIST_DENSE,
    T_PLIST,                      FN_IS_NDENSE,  T_PLIST_NDENSE,
    T_PLIST,                      FN_IS_HOMOG,   T_PLIST_HOM,
    T_PLIST,                      FN_IS_NHOMOG,  T_PLIST,
    T_PLIST,                      FN_IS_TABLE,   T_PLIST_TAB,
    T_PLIST,                      FN_IS_RECT,   T_PLIST_TAB_RECT,
    T_PLIST,                      FN_IS_SSORT,   T_PLIST,
    T_PLIST,                      FN_IS_NSORT,   T_PLIST,

    /* immutable plain lists                                               */
    T_PLIST           +IMMUTABLE, FN_IS_MUTABLE, T_PLIST,
    T_PLIST           +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_DENSE,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT   +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_SSORT,   T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_NSORT,   T_PLIST           +IMMUTABLE,

    /* mutable empty list                                                  */
    T_PLIST_EMPTY,                FN_IS_MUTABLE, T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_EMPTY,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_DENSE,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_NDENSE,  -1,
    T_PLIST_EMPTY,                FN_IS_HOMOG,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_NHOMOG,  -1,
    T_PLIST_EMPTY,                FN_IS_TABLE,   -1,
    T_PLIST_EMPTY,                FN_IS_RECT,    -1,
    T_PLIST_EMPTY,                FN_IS_SSORT,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_NSORT,   -1,


    /* immutable empty list                                                */
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_EMPTY,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_DENSE,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_RECT,   -1,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_SSORT,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NSORT,   -1,

    /* mutable dense list                                                  */
    T_PLIST_DENSE,                FN_IS_MUTABLE, T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_EMPTY,   T_PLIST_EMPTY,
    T_PLIST_DENSE,                FN_IS_DENSE,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_NDENSE,  -1,
    T_PLIST_DENSE,                FN_IS_HOMOG,   T_PLIST_HOM,
    T_PLIST_DENSE,                FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE,                FN_IS_TABLE,   T_PLIST_TAB,
    T_PLIST_DENSE,                FN_IS_RECT,   T_PLIST_TAB_RECT,
    T_PLIST_DENSE,                FN_IS_SSORT,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_NSORT,   T_PLIST_DENSE,

    /* immutable dense list                                                */
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_DENSE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_DENSE,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_RECT,    T_PLIST_TAB_RECT  +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_SSORT,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_NSORT,   T_PLIST_DENSE     +IMMUTABLE,

    /* mutable dense list, which contains immutables and is not homog      */
    T_PLIST_DENSE_NHOM,           FN_IS_MUTABLE, T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_EMPTY,   -1,
    T_PLIST_DENSE_NHOM,           FN_IS_DENSE,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM,           FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM,           FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM,           FN_IS_RECT,   -1,
    T_PLIST_DENSE_NHOM,           FN_IS_SSORT,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM,           FN_IS_NSORT,   T_PLIST_DENSE_NHOM_NSORT,

    /* immutable dense list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_MUTABLE, T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_DENSE,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_RECT,   -1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_SSORT,   T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NSORT,   T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,

    /* mutable dense ssorted list, which contains immutables and is not homog      */
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_MUTABLE, T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_EMPTY,   -1,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_DENSE,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_RECT,   -1,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_SSORT,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NSORT,   -1,

    /* immutable dense ssorted list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_MUTABLE, T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_DENSE,   T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_RECT,   -1,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_SSORT,   T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_NSORT,   -1,

    /* mutable dense nsorted list, which contains immutables and is not homog      */
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_MUTABLE, T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_EMPTY,   -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_DENSE,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_RECT,   -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_SSORT,   -1,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NSORT,   T_PLIST_DENSE_NHOM_NSORT,

    /* immutable dense nsorted list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_MUTABLE, T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_DENSE,   T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_RECT,   -1,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_SSORT,   -1,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_NSORT,   T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,

    /* a mutable list with holes                                           */
    T_PLIST_NDENSE,               FN_IS_MUTABLE, T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_EMPTY,   -1,
    T_PLIST_NDENSE,               FN_IS_DENSE,   -1,
    T_PLIST_NDENSE,               FN_IS_NDENSE,  T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_HOMOG,   -1,
    T_PLIST_NDENSE,               FN_IS_NHOMOG,  T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_TABLE,   -1,
    T_PLIST_NDENSE,               FN_IS_RECT,   -1,
    T_PLIST_NDENSE,               FN_IS_SSORT,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NSORT,   T_PLIST_NDENSE,

    /* an immutable list with holes                                        */
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_NDENSE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_DENSE,   -1,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_HOMOG,   -1,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_RECT,   -1,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_SSORT,   T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_NSORT,   T_PLIST_NDENSE    +IMMUTABLE,

    /* mutable dense list, which conts imms, is homogeneous, not a table   */
    T_PLIST_HOM,                  FN_IS_MUTABLE, T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_EMPTY,   T_PLIST_EMPTY,
    T_PLIST_HOM,                  FN_IS_DENSE,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_NDENSE,  -1,
    T_PLIST_HOM,                  FN_IS_HOMOG,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_NHOMOG,  -1,
    T_PLIST_HOM,                  FN_IS_TABLE,   T_PLIST_TAB,
    T_PLIST_HOM,                  FN_IS_RECT,   T_PLIST_TAB_RECT,
    T_PLIST_HOM,                  FN_IS_SSORT,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM,                  FN_IS_NSORT,   T_PLIST_HOM_NSORT,

    /* immutable dense list, which is immutable, homogeneous, not a table  */
    T_PLIST_HOM       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_HOM,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_DENSE,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_SSORT,   T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_NSORT,   T_PLIST_HOM_NSORT +IMMUTABLE,

    /* ssort mutable dense list, which conts imms, is homog, not a table   */
    T_PLIST_HOM_SSORT,            FN_IS_MUTABLE, T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_EMPTY,   T_PLIST_EMPTY,
    T_PLIST_HOM_SSORT,            FN_IS_DENSE,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_HOM_SSORT,            FN_IS_HOMOG,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_HOM_SSORT,            FN_IS_TABLE,   T_PLIST_TAB_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_RECT,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_SSORT,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_NSORT,   -1,

    /* ssort immutable dense list, which is immutable, homog, not a table  */
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_NSORT,   -1,

    /* nsort mutable dense list, which conts imms, is homog, not a table   */
    T_PLIST_HOM_NSORT,            FN_IS_MUTABLE, T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_EMPTY,   -1,
    T_PLIST_HOM_NSORT,            FN_IS_DENSE,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_HOM_NSORT,            FN_IS_HOMOG,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_HOM_NSORT,            FN_IS_TABLE,   T_PLIST_TAB_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_RECT,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_SSORT,   -1,
    T_PLIST_HOM_NSORT,            FN_IS_NSORT,   T_PLIST_HOM_NSORT,

    /* nsort immutable dense list, which is immutable, homog, not a table  */
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_SSORT,   -1,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_HOM_NSORT +IMMUTABLE,

    /* mutable dense list, which is immutable, homog, non-empty, table     */
    T_PLIST_TAB,                  FN_IS_MUTABLE, T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_EMPTY,   -1,
    T_PLIST_TAB,                  FN_IS_DENSE,   T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_NDENSE,  -1,
    T_PLIST_TAB,                  FN_IS_HOMOG,   T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_NHOMOG,  -1,
    T_PLIST_TAB,                  FN_IS_TABLE,   T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_RECT,   T_PLIST_TAB_RECT,
    T_PLIST_TAB,                  FN_IS_SSORT,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB,                  FN_IS_NSORT,   T_PLIST_TAB_NSORT,

    /* immutable dense list, which is immutable, homog, non-empty, table   */
    T_PLIST_TAB       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_DENSE,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB_NSORT +IMMUTABLE,

    /* ssort, mutable dense list, which is imm, homog, non-empty, table    */
    T_PLIST_TAB_SSORT,            FN_IS_MUTABLE, T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_EMPTY,   -1,
    T_PLIST_TAB_SSORT,            FN_IS_DENSE,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_TAB_SSORT,            FN_IS_HOMOG,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_SSORT,            FN_IS_TABLE,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_RECT,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_SSORT,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_NSORT,   -1,

    /* ssort, immutable dense list, which is imm, homog, non-empty, table  */
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_NSORT,   -1,

    /* nsort, mutable dense list, which is imm, homog, non-empty, table    */
    T_PLIST_TAB_NSORT,            FN_IS_MUTABLE, T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_EMPTY,   -1,
    T_PLIST_TAB_NSORT,            FN_IS_DENSE,   T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_TAB_NSORT,            FN_IS_HOMOG,   T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_NSORT,            FN_IS_TABLE,   T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_RECT,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_SSORT,   -1,
    T_PLIST_TAB_NSORT,            FN_IS_NSORT,   T_PLIST_TAB_NSORT,

    /* nsort, immutable dense list, which is imm, homog, non-empty, table  */
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_SSORT,   -1,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB_NSORT +IMMUTABLE,


    /* mutable dense list, which is immutable, homog, non-empty, rect table     */
    T_PLIST_TAB_RECT,                  FN_IS_MUTABLE, T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_EMPTY,   -1,
    T_PLIST_TAB_RECT,                  FN_IS_DENSE,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_NDENSE,  -1,
    T_PLIST_TAB_RECT,                  FN_IS_HOMOG,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_RECT,                  FN_IS_TABLE,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_RECT,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_SSORT,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT,                  FN_IS_NSORT,   T_PLIST_TAB_RECT_NSORT,

    /* immutable dense list, which is immutable, homog, non-empty, rect table   */
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_DENSE,   T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,

    /* ssort, mutable dense list, which is imm, homog, non-empty, rect table    */
    T_PLIST_TAB_RECT_SSORT,            FN_IS_MUTABLE, T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_EMPTY,   -1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_DENSE,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_HOMOG,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_TABLE,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_RECT,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_SSORT,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NSORT,   -1,

    /* ssort, immutable dense list, which is imm, homog, non-empty, rect table  */
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_NSORT,   -1,

    /* nsort, mutable dense list, which is imm, homog, non-empty, rect table    */
    T_PLIST_TAB_RECT_NSORT,            FN_IS_MUTABLE, T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_EMPTY,   -1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_DENSE,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_HOMOG,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_TABLE,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_RECT,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_SSORT,   -1,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NSORT,   T_PLIST_TAB_RECT_NSORT,

    /* nsort, immutable dense list, which is imm, homog, non-empty, rect table  */
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_SSORT,   -1,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,

    /* mutable dense list, which only contains objects of type <= T_CYC    */
    T_PLIST_CYC,                  FN_IS_MUTABLE, T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_EMPTY,   -1,
    T_PLIST_CYC,                  FN_IS_DENSE,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_NDENSE,  -1,
    T_PLIST_CYC,                  FN_IS_HOMOG,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_NHOMOG,  -1,
    T_PLIST_CYC,                  FN_IS_TABLE,   -1,
    T_PLIST_CYC,                  FN_IS_RECT,   -1,
    T_PLIST_CYC,                  FN_IS_SSORT,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC,                  FN_IS_NSORT,   T_PLIST_CYC_NSORT,

    /* immutable dense list, which only contains objects of type <= T_CYC  */
    T_PLIST_CYC       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_CYC,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_EMPTY,  -1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_DENSE,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_RECT,   -1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_SSORT,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NSORT,   T_PLIST_CYC_NSORT +IMMUTABLE,

    /* ssort mutable dense list, which only contains objs of type <= T_CYC */
    T_PLIST_CYC_SSORT,            FN_IS_MUTABLE, T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_EMPTY,   -1,
    T_PLIST_CYC_SSORT,            FN_IS_DENSE,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_CYC_SSORT,            FN_IS_HOMOG,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_CYC_SSORT,            FN_IS_TABLE,   -1,
    T_PLIST_CYC_SSORT,            FN_IS_RECT,   -1,
    T_PLIST_CYC_SSORT,            FN_IS_SSORT,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_NSORT,   -1,

    /* ssort immutable dense list, which contains objs of type <= T_CYC    */
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_RECT,   -1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NSORT,   -1,

    /* nsort mutable dense list, which only contains objs of type <= T_CYC */
    T_PLIST_CYC_NSORT,            FN_IS_MUTABLE, T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_EMPTY,   -1,
    T_PLIST_CYC_NSORT,            FN_IS_DENSE,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_CYC_NSORT,            FN_IS_HOMOG,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_CYC_NSORT,            FN_IS_TABLE,   -1,
    T_PLIST_CYC_NSORT,            FN_IS_RECT,   -1,
    T_PLIST_CYC_NSORT,            FN_IS_SSORT,   -1,
    T_PLIST_CYC_NSORT,            FN_IS_NSORT,   T_PLIST_CYC_NSORT,

    /* nsort immutable dense list, which contains objs of type <= T_CYC    */
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_RECT,   -1,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_SSORT,   -1,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_CYC_NSORT +IMMUTABLE,

    /* mutable dense list, which only contains objects of type T_FFE       */
    T_PLIST_FFE,            FN_IS_MUTABLE, T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_EMPTY,   -1,
    T_PLIST_FFE,            FN_IS_DENSE,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_NDENSE,  -1,
    T_PLIST_FFE,            FN_IS_HOMOG,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_NHOMOG,  -1,
    T_PLIST_FFE,            FN_IS_TABLE,   -1,
    T_PLIST_FFE,            FN_IS_RECT,   -1,
    T_PLIST_FFE,            FN_IS_SSORT,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_NSORT,   T_PLIST_FFE,

    /* immutable dense list, which only contains objects of type T_FFE     */
    T_PLIST_FFE +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_FFE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_FFE +IMMUTABLE, FN_IS_DENSE,   T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_FFE +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_FFE +IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_FFE +IMMUTABLE, FN_IS_RECT,   -1,
    T_PLIST_FFE +IMMUTABLE, FN_IS_SSORT,   T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_NSORT,   T_PLIST_FFE +IMMUTABLE,

    -1,                           -1,            -1

};


/****************************************************************************
**
*V  ResetFiltTab  . . . . . . . . . . . . . . . . . . .  unsetter filter tnum
*/
static Int ResetFiltTab [] = {

    /* mutable plain lists                                                 */
    T_PLIST,                      FN_IS_MUTABLE, T_PLIST           +IMMUTABLE,
    T_PLIST,                      FN_IS_EMPTY,   T_PLIST,
    T_PLIST,                      FN_IS_DENSE,   T_PLIST,
    T_PLIST,                      FN_IS_NDENSE,  T_PLIST,
    T_PLIST,                      FN_IS_HOMOG,   T_PLIST,
    T_PLIST,                      FN_IS_NHOMOG,  T_PLIST,
    T_PLIST,                      FN_IS_TABLE,   T_PLIST,
    T_PLIST,                      FN_IS_RECT,   T_PLIST,
    T_PLIST,                      FN_IS_SSORT,   T_PLIST,
    T_PLIST,                      FN_IS_NSORT,   T_PLIST,

    /* immutable plain lists                                               */
    T_PLIST           +IMMUTABLE, FN_IS_MUTABLE, T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_EMPTY,   T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_NDENSE,  T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_HOMOG,   T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_TABLE,   T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_RECT,   T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_SSORT,   T_PLIST           +IMMUTABLE,
    T_PLIST           +IMMUTABLE, FN_IS_NSORT,   T_PLIST           +IMMUTABLE,

    /* mutable empty list                                                  */
    T_PLIST_EMPTY,                FN_IS_MUTABLE, T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY,                FN_IS_EMPTY,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_DENSE,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NDENSE,  T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_HOMOG,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NHOMOG,  T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_TABLE,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_RECT,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_SSORT,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NSORT,   T_PLIST_EMPTY,

    /* mutable empty list                                                  */
    T_PLIST_EMPTY,                FN_IS_MUTABLE, T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY,                FN_IS_EMPTY,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_DENSE,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NDENSE,  T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_HOMOG,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NHOMOG,  T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_TABLE,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_RECT,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_SSORT,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NSORT,   T_PLIST_EMPTY,

    /* immutable empty list                                                */
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_EMPTY,   T_PLIST           +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_HOMOG,   T_PLIST           +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_RECT,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_TABLE,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_SSORT,   T_PLIST,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NSORT,   T_PLIST_EMPTY     +IMMUTABLE,

    /* mutable dense list                                                  */
    T_PLIST_DENSE,                FN_IS_MUTABLE, T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE,                FN_IS_EMPTY,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_DENSE,   T_PLIST,
    T_PLIST_DENSE,                FN_IS_NDENSE,  T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_NHOMOG,  T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_TABLE,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_RECT,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_SSORT,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_NSORT,   T_PLIST_DENSE,

    /* immutable dense list                                                */
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_TABLE,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_RECT,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_SSORT,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE     +IMMUTABLE, FN_IS_NSORT,   T_PLIST_DENSE     +IMMUTABLE,

    /* mutable dense list, which contains immutables and is not homog      */
    T_PLIST_DENSE_NHOM,           FN_IS_MUTABLE, T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM,           FN_IS_EMPTY,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_DENSE,   T_PLIST,
    T_PLIST_DENSE_NHOM,           FN_IS_NDENSE,  T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_HOMOG,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_NHOMOG,  T_PLIST_DENSE,
    T_PLIST_DENSE_NHOM,           FN_IS_TABLE,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_RECT,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_SSORT,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_NSORT,   T_PLIST_DENSE_NHOM,

    /* immutable dense list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_MUTABLE, T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_EMPTY,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NDENSE,  T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_TABLE,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_RECT,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_SSORT,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NSORT,   T_PLIST_DENSE_NHOM+IMMUTABLE,

    /* mutable dense ssorted list, which contains immutables and is not homog      */
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_MUTABLE, T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_EMPTY,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_DENSE,   T_PLIST,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NDENSE,  T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_HOMOG,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NHOMOG,  T_PLIST_DENSE,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_TABLE,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_RECT,   T_PLIST_DENSE_NHOM_SSORT,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_SSORT,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM_SSORT,     FN_IS_NSORT,   T_PLIST_DENSE_NHOM_SSORT,

    /* immutable dense ssorted list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_MUTABLE, T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_EMPTY,   T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_NDENSE,  T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_TABLE,   T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_RECT,   T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_SSORT,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE, FN_IS_NSORT,   T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE,

    /* mutable dense nsorted list, which contains immutables and is not homog      */
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_MUTABLE, T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_EMPTY,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_DENSE,   T_PLIST,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NDENSE,  T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_HOMOG,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NHOMOG,  T_PLIST_DENSE,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_TABLE,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_RECT,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_SSORT,   T_PLIST_DENSE_NHOM_NSORT,
    T_PLIST_DENSE_NHOM_NSORT,     FN_IS_NSORT,   T_PLIST_DENSE_NHOM,

    /* immutable dense nsorted list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_MUTABLE, T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_EMPTY,   T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_NDENSE,  T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_TABLE,   T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_RECT,   T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_SSORT,   T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE,
    T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE, FN_IS_NSORT,   T_PLIST_DENSE_NHOM+IMMUTABLE,

    /* a mutable list with holes                                           */
    T_PLIST_NDENSE,               FN_IS_MUTABLE, T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE,               FN_IS_EMPTY,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_DENSE,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NDENSE,  T_PLIST,
    T_PLIST_NDENSE,               FN_IS_HOMOG,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NHOMOG,  T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_TABLE,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_RECT,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_SSORT,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NSORT,   T_PLIST_NDENSE,

    /* an immutable list with holes                                        */
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_DENSE,   T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_NDENSE,  T_PLIST           +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_TABLE,   T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_RECT,   T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_SSORT,   T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE    +IMMUTABLE, FN_IS_NSORT,   T_PLIST_NDENSE    +IMMUTABLE,

    /* mutable dense list, which conts imms, is homogeneous, not a table   */
    T_PLIST_HOM,                  FN_IS_MUTABLE, T_PLIST_HOM      +IMMUTABLE,
    T_PLIST_HOM,                  FN_IS_EMPTY,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_DENSE,   T_PLIST,
    T_PLIST_HOM,                  FN_IS_NDENSE,  T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_HOM,                  FN_IS_NHOMOG,  T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_TABLE,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_RECT,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_SSORT,   T_PLIST_HOM,
    T_PLIST_HOM,                  FN_IS_NSORT,   T_PLIST_HOM,

    /* immutable dense list, which is immutable, homogeneous, not a table  */
    T_PLIST_HOM       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_TABLE,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_RECT,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_SSORT,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM       +IMMUTABLE, FN_IS_NSORT,   T_PLIST_HOM       +IMMUTABLE,

    /* ssort mutable dense list, which conts imms, is homog, not a table   */
    T_PLIST_HOM_SSORT,            FN_IS_MUTABLE, T_PLIST_HOM_SSORT+IMMUTABLE,
    T_PLIST_HOM_SSORT,            FN_IS_EMPTY,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_HOM_SSORT,            FN_IS_NDENSE,  T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_HOM_SSORT,            FN_IS_NHOMOG,  T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_TABLE,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_RECT,   T_PLIST_HOM_SSORT,
    T_PLIST_HOM_SSORT,            FN_IS_SSORT,   T_PLIST_HOM,
    T_PLIST_HOM_SSORT,            FN_IS_NSORT,   T_PLIST_HOM_SSORT,

    /* ssort immutable dense list, which is immutable, homog, not a table  */
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_HOM_SSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_HOM_SSORT +IMMUTABLE,

    /* nsort mutable dense list, which conts imms, is homog, not a table   */
    T_PLIST_HOM_NSORT,            FN_IS_MUTABLE, T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT,            FN_IS_EMPTY,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_HOM_NSORT,            FN_IS_NDENSE,  T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_HOM_NSORT,            FN_IS_NHOMOG,  T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_TABLE,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_RECT,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_SSORT,   T_PLIST_HOM_NSORT,
    T_PLIST_HOM_NSORT,            FN_IS_NSORT,   T_PLIST_HOM,

    /* nsort immutable dense list, which is immutable, homog, not a table  */
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST           +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_HOM_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_HOM       +IMMUTABLE,

    /* mutable dense list, which is immutable, homog, non-empty, table     */
    T_PLIST_TAB,                  FN_IS_MUTABLE, T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB,                  FN_IS_EMPTY,   T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB,                  FN_IS_NDENSE,  T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB,                  FN_IS_NHOMOG,  T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_TABLE,   T_PLIST_HOM,
    T_PLIST_TAB,                  FN_IS_RECT,    T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_SSORT,   T_PLIST_TAB,
    T_PLIST_TAB,                  FN_IS_NSORT,   T_PLIST_TAB,

    /* immutable dense list, which is immutable, homog, non-empty, table   */
    T_PLIST_TAB       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_TABLE,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB       +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB       +IMMUTABLE,

    /* ssort, mutable dense list, which is imm, homog, non-empty, table    */
    T_PLIST_TAB_SSORT,            FN_IS_MUTABLE, T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT,            FN_IS_EMPTY,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_SSORT,            FN_IS_NDENSE,  T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_SSORT,            FN_IS_NHOMOG,  T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_TABLE,   T_PLIST_HOM_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_RECT,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_SSORT,            FN_IS_SSORT,   T_PLIST_TAB,
    T_PLIST_TAB_SSORT,            FN_IS_NSORT,   T_PLIST_TAB_SSORT,

    /* ssort, immutable dense list, which is imm, homog, non-empty, table  */
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_RECT,    T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB_SSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB_SSORT +IMMUTABLE,

    /* nsort, mutable dense list, which is imm, homog, non-empty, table    */
    T_PLIST_TAB_NSORT,            FN_IS_MUTABLE, T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT,            FN_IS_EMPTY,   T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_NSORT,            FN_IS_NDENSE,  T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_NSORT,            FN_IS_NHOMOG,  T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_TABLE,   T_PLIST_HOM_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_RECT,    T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_SSORT,   T_PLIST_TAB_NSORT,
    T_PLIST_TAB_NSORT,            FN_IS_NSORT,   T_PLIST_TAB,

    /* nsort, immutable dense list, which is imm, homog, non-empty, table  */
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_RECT,    T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB       +IMMUTABLE,
    /* mutable dense list, which is immutable, homog, non-empty, rect table     */
    T_PLIST_TAB_RECT,                  FN_IS_MUTABLE, T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT,                  FN_IS_EMPTY,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_RECT,                  FN_IS_NDENSE,  T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_RECT,                  FN_IS_NHOMOG,  T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_TABLE,   T_PLIST_HOM,
    T_PLIST_TAB_RECT,                  FN_IS_RECT,    T_PLIST_TAB,
    T_PLIST_TAB_RECT,                  FN_IS_SSORT,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT,                  FN_IS_NSORT,   T_PLIST_TAB_RECT,

    /* immutable dense list, which is immutable, homog, non-empty, rect table   */
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_TABLE,   T_PLIST_HOM       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_RECT,   T_PLIST_TAB       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT       +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB_RECT       +IMMUTABLE,

    /* ssort, mutable dense list, which is imm, homog, non-empty, rect table    */
    T_PLIST_TAB_RECT_SSORT,            FN_IS_MUTABLE, T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_EMPTY,   T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NDENSE,  T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NHOMOG,  T_PLIST_TAB_RECT_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_TABLE,   T_PLIST_HOM_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_RECT,   T_PLIST_TAB_SSORT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_SSORT,   T_PLIST_TAB_RECT,
    T_PLIST_TAB_RECT_SSORT,            FN_IS_NSORT,   T_PLIST_TAB_RECT_SSORT,

    /* ssort, immutable dense list, which is imm, homog, non-empty, rect table  */
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_TAB_RECT_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_HOM_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_RECT,    T_PLIST_TAB_SSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB_RECT       +IMMUTABLE,
    T_PLIST_TAB_RECT_SSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB_RECT_SSORT +IMMUTABLE,

    /* nsort, mutable dense list, which is imm, homog, non-empty, rect table    */
    T_PLIST_TAB_RECT_NSORT,            FN_IS_MUTABLE, T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_EMPTY,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NDENSE,  T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NHOMOG,  T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_TABLE,   T_PLIST_HOM_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_RECT,    T_PLIST_TAB_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_SSORT,   T_PLIST_TAB_RECT_NSORT,
    T_PLIST_TAB_RECT_NSORT,            FN_IS_NSORT,   T_PLIST_TAB_RECT,

    /* nsort, immutable dense list, which is imm, homog, non-empty, rect table  */
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_HOM_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_RECT,    T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB_RECT_NSORT +IMMUTABLE,
    T_PLIST_TAB_RECT_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB_RECT       +IMMUTABLE,

    /* mutable dense list, which only contains objects of type <= T_CYC    */
    T_PLIST_CYC,                  FN_IS_MUTABLE, T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC,                  FN_IS_EMPTY,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_DENSE,   T_PLIST,
    T_PLIST_CYC,                  FN_IS_NDENSE,  T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_HOMOG,   T_PLIST_DENSE,
    T_PLIST_CYC,                  FN_IS_NHOMOG,  T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_TABLE,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_RECT,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_SSORT,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_NSORT,   T_PLIST_CYC,

    /* immutable dense list, which only contains objects of type <= T_CYC  */
    T_PLIST_CYC       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_DENSE     +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_TABLE,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_RECT,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_SSORT,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NSORT,   T_PLIST_CYC       +IMMUTABLE,

    /* ssort mutable dense list, which only contains objs of type <= T_CYC */
    T_PLIST_CYC_SSORT,            FN_IS_MUTABLE, T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT,            FN_IS_EMPTY,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_CYC_SSORT,            FN_IS_NDENSE,  T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_HOMOG,   T_PLIST,
    T_PLIST_CYC_SSORT,            FN_IS_NHOMOG,  T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_TABLE,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_RECT,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_SSORT,   T_PLIST_CYC,
    T_PLIST_CYC_SSORT,            FN_IS_NSORT,   T_PLIST_CYC_SSORT,

    /* ssort immutable dense list, which contains objs of type <= T_CYC    */
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST           +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_CYC_SSORT +IMMUTABLE,

    /* nsort mutable dense list, which only contains objs of type <= T_CYC */
    T_PLIST_CYC_NSORT,            FN_IS_MUTABLE, T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT,            FN_IS_EMPTY,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_CYC_NSORT,            FN_IS_NDENSE,  T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_HOMOG,   T_PLIST,
    T_PLIST_CYC_NSORT,            FN_IS_NHOMOG,  T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_TABLE,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_RECT,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_SSORT,   T_PLIST_CYC_NSORT,
    T_PLIST_CYC_NSORT,            FN_IS_NSORT,   T_PLIST_CYC,

    /* nsort immutable dense list, which contains objs of type <= T_CYC    */
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST           +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_TABLE,   T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_RECT,   T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_CYC       +IMMUTABLE,

    /* mutable dense list, which only contains objects of type T_FFE       */
    T_PLIST_FFE,            FN_IS_MUTABLE, T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE,            FN_IS_EMPTY,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_DENSE,   T_PLIST,
    T_PLIST_FFE,            FN_IS_NDENSE,  T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_HOMOG,   T_PLIST,
    T_PLIST_FFE,            FN_IS_NHOMOG,  T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_TABLE,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_RECT,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_SSORT,   T_PLIST_FFE,
    T_PLIST_FFE,            FN_IS_NSORT,   T_PLIST_FFE,

    /* immutable dense list, which only contains objects of type T_FFE     */
    T_PLIST_FFE +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_DENSE,   T_PLIST     +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_HOMOG,   T_PLIST     +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_TABLE,   T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_RECT,   T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_SSORT,   T_PLIST_FFE +IMMUTABLE,
    T_PLIST_FFE +IMMUTABLE, FN_IS_NSORT,   T_PLIST_FFE +IMMUTABLE,

    -1,                         -1,             -1

};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    { "IS_PLIST_REP", "obj", &IsPListFilt,
      FuncIS_PLIST_REP, "src/lists.c:IS_PLIST_REP" },

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "ASS_PLIST_DEFAULT", 3, "list, pos, val",
      FuncASS_PLIST_DEFAULT, "src/lists.c:ASS_PLIST_DEFAULT" },
    
    { "IsRectangularTablePlist", 1, "plist",
      FuncIsRectangularTablePlist, "src/lists.c:IsRectangularTablePlist" },

    { "SET_IS_SSORTED_PLIST", 1, "list",
      FuncSetIsSSortedPlist, "src/lists.c:SET_IS_SSORTED_PLIST" },
    
    { "EmptyPlist", 1, "len",
      FuncEmptyPlist, "src/lists.c:FuncEmptyPlist" },
    
    { "ShrinkAllocationPlist", 1, "plist",
      FuncShrinkAllocationPlist, "src/lists.c:FuncShrinkAllocationPlist" },
    
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  SweepAndCheckNonDensePlist
*/

void SweepAndCheckNonDensePlist ( Bag * src,
				  Bag *dest,
				  UInt baglength )
{
  UInt holeseen=0;
  UInt listlength = (UInt)(*src);
  UInt i;
  if (listlength > baglength - 1)
    Pr("#W Plain list with length %d in bag of size only %d\n", listlength, baglength);
  *(UInt *)dest = listlength;
  if (listlength == 0)
    Pr("#W Plain non-dense list length 0\n", 0, 0);
  for (i = 1; i < listlength; i++)
    if (!(dest[i] = src[i]))
      holeseen = 1;
  if (!(dest[listlength] = src[listlength]))
    Pr("#W plain list length %d with final entry unbound\n", listlength, 0);
  if (!holeseen)
    Pr("#W plain non-dense list length %d contains no hole\n", listlength, 0);
  for (i = listlength+1; i < baglength; i++)
    dest[i] = (Bag)0;  
}
			  

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
        InitMarkFuncBags( t1                     , MarkAllSubBags );
        InitMarkFuncBags( t1 +IMMUTABLE          , MarkAllSubBags );
        InitMarkFuncBags( t1            +COPYING , MarkAllSubBags );
        InitMarkFuncBags( t1 +IMMUTABLE +COPYING , MarkAllSubBags );
    }

    InitMarkFuncBags( T_PLIST_FFE                     , MarkNoSubBags );
    InitMarkFuncBags( T_PLIST_FFE +IMMUTABLE          , MarkNoSubBags );
    InitMarkFuncBags( T_PLIST_FFE            +COPYING , MarkNoSubBags );
    InitMarkFuncBags( T_PLIST_FFE +IMMUTABLE +COPYING , MarkNoSubBags );

#ifdef CHECK_NDENSE_BAGS
    InitSweepFuncBags( T_PLIST_NDENSE, SweepAndCheckNonDensePlist);
    InitSweepFuncBags( T_PLIST_NDENSE + IMMUTABLE, SweepAndCheckNonDensePlist);
#endif
    
    /* If T_PLIST_FFE is not the last PLIST type then some more
       work needs to be done here */

    for ( t1 = T_PLIST;  t1 <= LAST_PLIST_TNUM;  t1 += 2 ) {
        SaveObjFuncs[ t1 ]             = SavePlist;
        SaveObjFuncs[ t1 + IMMUTABLE ] = SavePlist; 
        LoadObjFuncs[ t1 ]             = LoadPlist;
        LoadObjFuncs[ t1 + IMMUTABLE ] = LoadPlist; 
    }

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
    TypeObjFuncs[ T_PLIST_NDENSE                ] = TypePlistNDenseMut;
    TypeObjFuncs[ T_PLIST_NDENSE     +IMMUTABLE ] = TypePlistNDenseImm;
    TypeObjFuncs[ T_PLIST_DENSE                 ] = TypePlistDenseMut;
    TypeObjFuncs[ T_PLIST_DENSE      +IMMUTABLE ] = TypePlistDenseImm;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM            ] = TypePlistDenseNHomMut;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM +IMMUTABLE ] = TypePlistDenseNHomImm;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM_SSORT      ] = TypePlistDenseNHomSSortMut;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE ] = TypePlistDenseNHomSSortImm;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM_NSORT      ] = TypePlistDenseNHomNSortMut;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM_NSORT +IMMUTABLE ] = TypePlistDenseNHomNSortImm;
    TypeObjFuncs[ T_PLIST_EMPTY                 ] = TypePlistEmptyMut;
    TypeObjFuncs[ T_PLIST_EMPTY      +IMMUTABLE ] = TypePlistEmptyImm;

    for ( t1 = T_PLIST;  t1 <= LAST_PLIST_TNUM;  t1 += 2 ) {
        SetTypeObjFuncs[ t1 ] = SetTypePlistToPosObj;
    }
    
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


    /* install the copy list methods                                       */
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        CopyObjFuncs [ t1                     ] = CopyPlist;
        CopyObjFuncs [ t1 +IMMUTABLE          ] = CopyPlist;
        CopyObjFuncs [ t1            +COPYING ] = CopyPlistCopy;
        CopyObjFuncs [ t1 +IMMUTABLE +COPYING ] = CopyPlistCopy;
        CleanObjFuncs[ t1                     ] = CleanPlist;
        CleanObjFuncs[ t1 +IMMUTABLE          ] = CleanPlist;
        CleanObjFuncs[ t1            +COPYING ] = CleanPlistCopy;
        CleanObjFuncs[ t1 +IMMUTABLE +COPYING ] = CleanPlistCopy;
    }


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
    for ( t1 = T_PLIST; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
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
    for ( t1 = T_PLIST_DENSE; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
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
        UnbListFuncs    [ t1+IMMUTABLE  ] = UnbPlistImm;
    }


    /* install the list assignment methods                                 */
    AssListFuncs    [ T_PLIST           ] = AssPlist;
    AssListFuncs    [ T_PLIST+IMMUTABLE ] = AssPlistImm;
    AssListFuncs    [ T_PLIST_NDENSE    ] = AssPlistXXX;
    AssListFuncs    [ T_PLIST_NDENSE+IMMUTABLE ] = AssPlistImm;
    AssListFuncs    [ T_PLIST_DENSE    ] = AssPlistDense;
    AssListFuncs    [ T_PLIST_DENSE+IMMUTABLE ] = AssPlistImm;
    AssListFuncs    [ T_PLIST_DENSE_NHOM    ] = AssPlistDense;
    AssListFuncs    [ T_PLIST_DENSE_NHOM+IMMUTABLE ] = AssPlistImm;
    AssListFuncs    [ T_PLIST_DENSE_NHOM_SSORT    ] = AssPlistDense;
    AssListFuncs    [ T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE ] = AssPlistImm;
    AssListFuncs    [ T_PLIST_DENSE_NHOM_NSORT    ] = AssPlistDense;
    AssListFuncs    [ T_PLIST_DENSE_NHOM_NSORT+IMMUTABLE ] = AssPlistImm;
    AssListFuncs    [ T_PLIST_EMPTY    ] = AssPlistEmpty;
    AssListFuncs    [ T_PLIST_EMPTY+IMMUTABLE ] = AssPlistImm;
    
    
    
    for ( t1 = T_PLIST_HOM; t1 < T_PLIST_CYC; t1 += 2 ) {
      AssListFuncs[ t1+IMMUTABLE      ] = AssPlistImm;
      AssListFuncs[ t1                ] = AssPlistHomog;
    }

    for ( t1 = T_PLIST_CYC; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
      AssListFuncs[ t1+IMMUTABLE      ] = AssPlistImm;
      AssListFuncs[ t1                ] = AssPlistCyc;
    }

    AssListFuncs[ T_PLIST_FFE+IMMUTABLE ] = AssPlistImm;
    AssListFuncs[ T_PLIST_FFE           ] = AssPlistFfe;

    /* install the list assignments methods                                */
    AsssListFuncs   [ T_PLIST            ] = AsssPlist;
    AsssListFuncs   [ T_PLIST +IMMUTABLE ] = AsssPlistImm;
    for ( t1 = T_PLIST_NDENSE; t1 <= LAST_PLIST_TNUM; t1 += 2 ) {
        AsssListFuncs   [ t1             ] = AsssPlistXXX;
        AsssListFuncs   [ t1 +IMMUTABLE  ] = AsssPlistImm;
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
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM_SSORT      ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE ] = AlwaysNo;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM_NSORT      ] = AlwaysNo;
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
    IsTableListFuncs[ T_PLIST_DENSE_NHOM_SSORT      ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM_SSORT +IMMUTABLE ] = AlwaysNo;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM_NSORT      ] = AlwaysNo;
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
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM_SSORT     ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM_SSORT+IMMUTABLE ] = AlwaysYes;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM_NSORT     ] = AlwaysNo;
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
    
    PosListFuncs[ T_PLIST_DENSE_NHOM_SSORT     ] = PosPlistSort;
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

    /* return success                                                      */
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

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoPlist() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "plist",                            /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoPlist ( void )
{
    return &module;
}


/****************************************************************************
**
*E  plist.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
