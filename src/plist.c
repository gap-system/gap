/****************************************************************************
**
*W  plist.c                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
#include        "system.h"              /* system dependent part           */

const char * Revision_plist_c =
   "@(#)$Id$";

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* basic arithmetic                */

#include        "bool.h"                /* booleans                        */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#define INCLUDE_DECLARATION_PART
#include        "plist.h"               /* plain lists                     */
#undef  INCLUDE_DECLARATION_PART
#include        "range.h"               /* ranges                          */
#include        "string.h"              /* strings                         */
#include        "blister.h"             /* boolean lists                   */

#include        "saveload.h"            /* saving and loading              */


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
*F  TypePlist(<list>) . . . . . . . . . . . . . . . . .  kind of a plain list
**
**  'TypePlist' returns the kind of the plain list <list>.
**
**  'TypePlist' is the function in 'TypeObjFuncs' for plain lists.
**
**  TypePlist works with KTnumPlist to determine the type of a plain list
**  Considerable care is needed to deal with self-referential lists. This is
**  basically achieved with the TESTING flag in the Tnum. This must be set in the
**  "current" list before triggering determination of the Type (or KTnum) of
**  any sublist.
**
**  KTnumPlist determined the "true" Tnum of the list, taking account
**  of such factors as denseness, homogeneity and so on. It modifies the stored
**  Tnum of the list to the most informative "safe" value, allowing for the
**  mutability of the list entries (and preserving TESTING).
**
**  These functions could be made more efficient for nested mutable lists,
** 
*/
Obj TYPE_LIST_NDENSE_MUTABLE;
Obj TYPE_LIST_NDENSE_IMMUTABLE;
Obj TYPE_LIST_DENSE_NHOM_MUTABLE;
Obj TYPE_LIST_DENSE_NHOM_IMMUTABLE;
Obj TYPE_LIST_EMPTY_MUTABLE;
Obj TYPE_LIST_EMPTY_IMMUTABLE;
Obj TYPE_LIST_HOM;

#define IS_TESTING_PLIST(list) \
    (FIRST_TESTING_TNUM <= TNUM_OBJ(list) \
  && TNUM_OBJ(list) <= LAST_TESTING_TNUM)


Int KTNumPlist (
    Obj                 list )
{
    Int                 isHom   = 1;    /* is <list> homogeneous           */
    Int                 isDense = 1;    /* is <list> dense                 */
    Int                 isTable = 0;    /* are <list>s elms equal length   */
    Int                 isCyc   = 0;    /* are <list> elms all cyclotomic  */
    Int                 areMut  = 0;    /* are <list>s elms mutable        */
    Int                 len     = 0;    /* if so, this is the length       */
    Obj                 family  = 0;    /* family of <list>s elements      */
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Int                 i;              /* loop variable                   */
    Int                 testing;        /* to test or not to test type     */
    Int                 res;            /* result                          */

    /* if list has `TESTING' keep that                                     */
    testing = IS_TESTING_PLIST(list) ? TESTING : 0;

    /* get the length of the list                                          */
    lenList = LEN_PLIST(list);

    /* special case for empty list                                         */
    if ( lenList == 0 ) {
        UNMARK_LIST( list, testing );
        SET_FILT_LIST( list, FN_IS_EMPTY );
        res = TNUM_OBJ(list);
        MARK_LIST( list, testing );
        return res;
    }

    /* look at the first element                                           */
    elm = ELM_PLIST( list, 1 );
    if ( elm == 0 ) {
        isDense = 0;
    }
    else if ( IS_TESTING_PLIST(elm) ) {
        isHom   = 0;
        areMut  = IS_MUTABLE_PLIST(elm);
        isTable = 0;
    }
    else {
	if (!testing) MARK_LIST(list, TESTING);
        family  = FAMILY_TYPE( TYPE_OBJ(elm) );
        isHom   = 1;
        areMut  = IS_MUTABLE_OBJ(elm);
        if ( IS_HOMOG_LIST(elm) ) {
            isTable = 1;
            len     = LEN_LIST(elm);
        }
	if (!testing) UNMARK_LIST(list, TESTING);
    }

    /* loop over the list                                                  */
    for ( i = 2; isDense && (isHom || ! areMut) && i <= lenList; i++ ) {
        elm = ELM_PLIST( list, i );
        if ( elm == 0 ) {
            isDense = 0;
        }
        else if ( IS_TESTING_PLIST(elm) ) {
            isHom   = 0;
            areMut  = (areMut || IS_MUTABLE_PLIST(elm));
            isTable = 0;
        }
        else {
            isHom   = (isHom && family == FAMILY_TYPE( TYPE_OBJ(elm) ));
            areMut  = (areMut || IS_MUTABLE_OBJ(elm));
            isTable = (isTable && IS_LIST(elm) && LEN_LIST(elm) == len);
        }
    }
    for ( ;  isDense && i <= lenList;  i++ ) {
        elm = ELM_PLIST( list, i );
        if ( elm == 0 ) {
            isDense = 0;
        }
    }

    /* set the appropriate flags (not the hom. flag if elms are mutable)   */
    UNMARK_LIST( list, testing );
    if      ( ! isDense ) {
        SET_FILT_LIST( list, FN_IS_NDENSE );
        res = T_PLIST_NDENSE;
    }
    else if ( isDense && ! isHom ) {
        SET_FILT_LIST( list, FN_IS_DENSE );
        if ( ! areMut )
            SET_FILT_LIST( list, FN_IS_NHOMOG );
        res = T_PLIST_DENSE_NHOM;
    }
    else if ( isDense &&   isHom && ! isTable ) {
        SET_FILT_LIST( list, areMut ? FN_IS_DENSE : FN_IS_HOMOG );
	if (TNUM_OBJ(ELM_PLIST(list,1)) <= T_CYC)
	  {
	    res = (lenList == 1) ? T_PLIST_CYC_SSORT : T_PLIST_CYC;
	    /* This is a hack */
	    RetypeBag(list, res + ( IS_MUTABLE_OBJ(list) ? 0 : IMMUTABLE ));
	  }
	else
	  res = T_PLIST_HOM;
    }
    else /* if ( isDense &&   isHom &&   isTable ) */ {
        SET_FILT_LIST( list, areMut ? FN_IS_DENSE : FN_IS_TABLE );
        res = T_PLIST_TAB;
    }
    res = res + ( IS_MUTABLE_OBJ(list) ? 0 : IMMUTABLE );
    MARK_LIST( list, testing );
    return res;
}

Obj TypePlist (
    Obj                 list )
{
    Obj                 kind;           /* kind, result                    */
    Int                 ktype;          /* kind type of <list>             */
    Obj                 family;         /* family of elements              */
    Obj                 kinds;          /* kinds list of <family>          */
    UInt                testing;

    /* recursion is possible for this type of list                         */
    MARK_LIST( list, TESTING );
    ktype = KTNumPlist( list );
    UNMARK_LIST( list, TESTING );

    /* handle special cases                                                */
    if      ( ktype == T_PLIST_NDENSE ) {
        return TYPE_LIST_NDENSE_MUTABLE;
    }
    else if ( ktype == T_PLIST_NDENSE+IMMUTABLE ) {
        return TYPE_LIST_NDENSE_IMMUTABLE;
    }
    else if ( ktype == T_PLIST_DENSE_NHOM ) {
        return TYPE_LIST_DENSE_NHOM_MUTABLE;
    }
    else if ( ktype == T_PLIST_DENSE_NHOM+IMMUTABLE ) {
        return TYPE_LIST_DENSE_NHOM_IMMUTABLE;
    }
    else if ( ktype == T_PLIST_EMPTY ) {
        return TYPE_LIST_EMPTY_MUTABLE;
    }
    else if ( ktype == T_PLIST_EMPTY+IMMUTABLE ) {
        return TYPE_LIST_EMPTY_IMMUTABLE;
    }

    /* handle homogeneous list                                             */
    else if ( HasFiltListTNums[ktype][FN_IS_HOMOG] ) {

        /* get the family of the elements                                  */

      MARK_LIST(list, TESTING);
      family = FAMILY_TYPE( TYPE_OBJ( ELM_PLIST(list,1) ) );
      UNMARK_LIST(list, TESTING);

        /* get the list kinds of that family                               */
        kinds  = TYPES_LIST_FAM( family );

        /* if the kind is not yet known, compute it                        */
        kind = ELM0_LIST( kinds, ktype-T_PLIST_HOM+1 );
        if ( kind == 0 ) {
            kind = CALL_2ARGS( TYPE_LIST_HOM,
                family, INTOBJ_INT(ktype-T_PLIST_HOM+1) );
            ASS_LIST( kinds, ktype-T_PLIST_HOM+1, kind );
        }

        /* return the kind                                                 */
        return kind;

    }

    /* whats going on here?                                                */
    else {
        ErrorQuit(
            "Panic: strange kind type '%s' ('%d')",
            (Int)TNAM_OBJ(list), (Int)(TNUM_OBJ(list)) );
        return 0;
    }

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
    Obj                 kind;           /* kind, result                    */
    Int                 ktype;          /* kind type of <list>             */
    Obj                 family;         /* family of elements              */
    Obj                 kinds;          /* kinds list of <family>          */

    /* get the kind type and the family of the elements                    */
    ktype  = TNUM_OBJ( list );
    family = FAMILY_TYPE( TYPE_OBJ( ELM_PLIST( list, 1 ) ) );

    /* get the list kinds of that family                                   */
    kinds  = TYPES_LIST_FAM( family );

    /* if the kind is not yet known, compute it                            */
    kind = ELM0_LIST( kinds, ktype-T_PLIST_HOM+1 );
    if ( kind == 0 ) {
        kind = CALL_2ARGS( TYPE_LIST_HOM,
            family, INTOBJ_INT(ktype-T_PLIST_HOM+1) );
        ASS_LIST( kinds, ktype-T_PLIST_HOM+1, kind );
    }

    /* return the kind                                                     */
    return kind;
}

Obj TypePlistCyc (
    Obj                 list )
{
    Obj                 kind;           /* kind, result                    */
    Int                 ktype;          /* kind type of <list>             */
    Obj                 family;         /* family of elements              */
    Obj                 kinds;          /* kinds list of <family>          */

    /* get the kind type and the family of the elements                    */
    ktype  = TNUM_OBJ( list );
    family = FAMILY_TYPE( TYPE_OBJ( ELM_PLIST( list, 1 ) ) );

    /* get the list kinds of that family                                   */
    kinds  = TYPES_LIST_FAM( family );

    /* if the kind is not yet known, compute it                            */
    kind = ELM0_LIST( kinds, ktype-T_PLIST_CYC+1 );
    if ( kind == 0 ) {
        kind = CALL_2ARGS( TYPE_LIST_HOM,
            family, INTOBJ_INT(ktype-T_PLIST_CYC+1) );
        ASS_LIST( kinds, ktype-T_PLIST_CYC+1, kind );
    }

    /* return the kind                                                     */
    return kind;
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
    MARK_LIST( list, COPYING );

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
    UNMARK_LIST( list, COPYING );

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

    /* loop over the elements and compare them                             */
    for ( i = 1; i <= lenL; i++ ) {
        elmL = ELM_PLIST( left, i );
        elmR = ELM_PLIST( right, i );
        if ( elmL == 0 && elmR != 0 ) {
            return 0L;
        }
        else if ( elmR == 0 && elmL != 0 ) {
            return 0L;
        }
        else if ( ! EQ( elmL, elmR ) ) {
            return 0L;
        }
    }

    /* no differences found, the lists are equal                           */
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

    /* get the lengths of the lists and compare them                       */
    lenL = LEN_PLIST( left );
    lenR = LEN_PLIST( right );

    /* loop over the elements and compare them                             */
    for ( i = 1; i <= lenL && i <= lenR; i++ ) {
        elmL = ELM_PLIST( left, i );
        elmR = ELM_PLIST( right, i );
        if ( elmL == 0 && elmR != 0 ) {
            return 1L;
        }
        else if ( elmR == 0 && elmL != 0 ) {
            return 0L;
        }
        else if ( ! EQ( elmL, elmR ) ) {
            return LT( elmL, elmR );
        }
    }

    /* reached the end of at least one list                                */
    return (lenL < lenR);
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
*F  IsbvPlist(<list>,<pos>) . . . . . . test for an element from a plain list
**
**  'IsbPlist' returns 1 if the list <list> has an entry  at  position  <pos>
**  and 0 otherwise.  It is the responsibility of the caller to  ensure  that
**  <pos> is a positive integer.
**
**  'IsbvPlist' does the  same thing than  'IsbList', but need not check that
**  <pos>  is less  than or  equal  to the  length of   <list>,  this is  the
**  responsibility of the caller.
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

Int             IsbvPlist (
    Obj                 list,
    Int                 pos )
{
    return (ELM_PLIST( list, pos ) != 0);
}

Int             IsbvPlistDense (
    Obj                 list,
    Int                 pos )
{
    return (1L);
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
            "you can return after assigning a value" );
        return ELM_LIST( list, pos );
    }

    /* select the element                                                  */
    elm = ELM_PLIST( list, pos );

    /* check the element                                                   */
    if ( elm == 0 ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            (Int)pos, 0L,
            "you can return after assigning a value" );
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
            "you can return after assigning a value" );
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
            "you can return after assigning a value" );
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
**  'ElmsPlist' is the function in 'ElmsListFuncs' for plain lists.
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
        /* do not assert "dense", list might be homogeneous                */
        elms = NEW_PLIST( T_PLIST, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );
            if ( lenList < pos ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can return after assigning a value" );
                return ELMS_LIST( list, poss );
            }

            /* select the element                                          */
            elm = ELM_PLIST( list, pos );
            if ( elm == 0 ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can return after assigning a value" );
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
                "you can return after assigning a value" );
            return ELMS_LIST( list, poss );
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos + (lenPoss-1) * inc, 0L,
                "you can return after assigning a value" );
            return ELMS_LIST( list, poss );
        }

        /* make the result list                                            */
        /* do not assert "dense", list might be homogeneous                */
        elms = NEW_PLIST( T_PLIST, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {

            /* select the element                                          */
            elm = ELM_PLIST( list, pos );
            if ( elm == 0 ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can return after assigning a value" );
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
        if      ( (TNUM_OBJ(list) == T_PLIST_HOM_SSORT
                || TNUM_OBJ(list) == T_PLIST_TAB_SSORT
                || TNUM_OBJ(list) == T_PLIST_CYC_SSORT)
               && (TNUM_OBJ(poss) == T_PLIST_HOM_SSORT
                || TNUM_OBJ(poss) == T_PLIST_CYC_SSORT) )
        {
            elms = NEW_PLIST( TNUM_OBJ(list), lenPoss );
        }
        else if (  TNUM_OBJ(list) == T_PLIST_HOM
                || TNUM_OBJ(list) == T_PLIST_HOM_NSORT
                || TNUM_OBJ(list) == T_PLIST_HOM_SSORT )
        {
            elms = NEW_PLIST( T_PLIST_HOM, lenPoss );
        }
        else if (  TNUM_OBJ(list) == T_PLIST_TAB
                || TNUM_OBJ(list) == T_PLIST_TAB_NSORT
                || TNUM_OBJ(list) == T_PLIST_TAB_SSORT )
        {
            elms = NEW_PLIST( T_PLIST_TAB, lenPoss );
        }
        else if (  TNUM_OBJ(list) == T_PLIST_CYC
                || TNUM_OBJ(list) == T_PLIST_CYC_NSORT
                || TNUM_OBJ(list) == T_PLIST_CYC_SSORT )
        {
            elms = NEW_PLIST( T_PLIST_CYC, lenPoss );
        }
        else {
            elms = NEW_PLIST( T_PLIST, lenPoss );
        }
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );
            if ( lenList < pos ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can return after assigning a value" );
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
        if ( lenList < pos ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos, 0L,
                "you can return after assigning a value" );
            return ELMS_LIST( list, poss );
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos + (lenPoss-1) * inc, 0L,
                "you can return after assigning a value" );
            return ELMS_LIST( list, poss );
        }

        /* make the result list                                            */
        /* try to assert as many properties as possible                    */
        if      ( (TNUM_OBJ(list) == T_PLIST_HOM_SSORT
                || TNUM_OBJ(list) == T_PLIST_TAB_SSORT
                || TNUM_OBJ(list) == T_PLIST_CYC_SSORT)
               && (TNUM_OBJ(poss) == T_PLIST_HOM_SSORT
                || TNUM_OBJ(poss) == T_PLIST_CYC_SSORT) )
        {
            elms = NEW_PLIST( TNUM_OBJ(list), lenPoss );
        }
        else if (  TNUM_OBJ(list) == T_PLIST_HOM
                || TNUM_OBJ(list) == T_PLIST_HOM_NSORT
                || TNUM_OBJ(list) == T_PLIST_HOM_SSORT )
        {
            elms = NEW_PLIST( T_PLIST_HOM, lenPoss );
        }
        else if (  TNUM_OBJ(list) == T_PLIST_TAB
                || TNUM_OBJ(list) == T_PLIST_TAB_NSORT
                || TNUM_OBJ(list) == T_PLIST_TAB_SSORT )
        {
            elms = NEW_PLIST( T_PLIST_TAB, lenPoss );
        }
        else if (  TNUM_OBJ(list) == T_PLIST_CYC
                || TNUM_OBJ(list) == T_PLIST_CYC_NSORT
                || TNUM_OBJ(list) == T_PLIST_CYC_SSORT )
        {
            elms = NEW_PLIST( T_PLIST_CYC, lenPoss );
        }
        else {
            elms = NEW_PLIST( T_PLIST, lenPoss );
        }
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
    }
}

void            UnbPlistImm (
    Obj                 list,
    Int                 pos )
{
    ErrorReturnVoid(
        "List Unbind: <list> must be a mutable list",
        0L, 0L,
        "you can return and ignore the unbind" );
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
    if (pos > len + 1)
      {
	CLEAR_FILTS_LIST(list);
	SET_FILT_LIST( list, FN_IS_NDENSE );
      }
    else if (TNUM_OBJ(val) > T_CYC)
      {
	CLEAR_FILTS_LIST(list);
	SET_FILT_LIST( list, FN_IS_DENSE );
      }
    else
      {
      	RESET_FILT_LIST( list, FN_IS_NSORT );
	RESET_FILT_LIST( list, FN_IS_SSORT );
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


void            AssPlistImm (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    ErrorReturnVoid(
        "Lists Assignment: <list> must be a mutable list",
        0L, 0L,
        "you can return and ignore the assignment" );
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
        AssListObject( list, pos, val );
    }

    /* catch constants                                                     */
    else if ( TNUM_OBJ(val) < FIRST_EXTERNAL_TNUM ) {
        AssPlistXXX( list, pos, val );
    }
    
    /* use method selection                                                */
    else {
        AssListObject( list, pos, val );
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
        "you can return and ignore the assignment" );
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

Int             IsDensePlistNot (
    Obj                 list )
{
    return 0L;
}

Int             IsDensePlistYes (
    Obj                 list )
{
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
    Int                 ktype;
    ktype = KTNumPlist( list );
    return (T_PLIST_HOM <= ktype);
}

Int             IsHomogPlistNot (
    Obj                 list )
{
    return 0L;
}

Int             IsHomogPlistYes (
    Obj                 list )
{
    return 1L;
}


/****************************************************************************
**
*F  IsTablePlist(<list>)  . . . . . . . . table test function for plain lists
**
**  'IsTablePlist' returns  1 if the plain list  <list> is a homogeneous list
**  of lists of equal length and 0 otherwise.
**
**  'IsTablePlist' is the function in 'IsTableListFuncs' for plain lists.
*/
Int             IsTablePlist (
    Obj                 list )
{
    Int                 ktype;
    ktype = KTNumPlist( list );
    return (T_PLIST_TAB <= ktype && ktype <= T_PLIST_TAB_SSORT);
}

Int             IsTablePlistNot (
    Obj                 list )
{
    return 0L;
}

Int             IsTablePlistYes (
    Obj                 list )
{
    return 1L;
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
extern  Int             IsSSortPlistHom (
            Obj                 list );

Int             IsSSortPlist (
    Obj                 list )
{
    Int                 lenList;

    /* get the length                                                      */
    lenList = LEN_PLIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        SET_FILT_LIST( list, FN_IS_EMPTY );
        return 2L;
    }

    /* a list must be homogeneous to be strictly sorted                    */
    if ( ! IS_HOMOG_LIST(list) ) {
        return 0L;
    }

    /* delegate                                                            */
    return IsSSortPlistHom( list );
}

Int             IsSSortPlistHom (
    Obj                 list )
{
    Int                 areMut;
    Int                 lenList;
    Obj                 elm1;
    Obj                 elm2;
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
    areMut   = IS_MUTABLE_OBJ( elm1 );

    /* loop over the other elements                                        */
    for ( i = 2; i <= lenList; i++ ) {
        elm2 = ELM_PLIST( list, i );
        if ( ! LT( elm1, elm2 ) )
            break;
        areMut = (areMut || IS_MUTABLE_OBJ( elm2 ));
        elm1 = elm2;
    }

    /* set the flag (unless the elements are mutable)                      */
    if ( lenList < i ) {
        if ( ! areMut ) {
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

Int             IsSSortPlistNot (
    Obj                 list )
{
    return 0L;
}

Int             IsSSortPlistYes (
    Obj                 list )
{
    return 2L;
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
        if ( elm == 0 || ! IS_INTOBJ(elm) || INT_INTOBJ(elm) <= 0 )
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
Int             PosPlist (
    Obj                 list,
    Obj                 val,
    Int                 start )
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Int                 i;              /* loop variable                   */

    /* get the length of <list>                                            */
    lenList = LEN_PLIST( list );

    /* loop over all entries in <list>                                     */
    for ( i = start+1; i <= lenList; i++ ) {

        /* select one element from <list>                                  */
        elm = ELM_PLIST( list, i );

        /* compare with <val>                                              */
        if ( elm != 0 && EQ( elm, val ) )
            break;

    }

    /* return the position (0 if <val> was not found)                      */
    return (lenList < i ? 0 : i);
}

Int             PosPlistDense (
    Obj                 list,
    Obj                 val,
    Int                 start )
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Int                 i;              /* loop variable                   */

    /* get the length of <list>                                            */
    lenList = LEN_PLIST( list );

    /* loop over all entries in <list>                                     */
    for ( i = start+1; i <= lenList; i++ ) {

        /* select one element from <list>                                  */
        elm = ELM_PLIST( list, i );

        /* compare with <val>                                              */
        if ( EQ( elm, val ) )
            break;

    }

    /* return the position (0 if <val> was not found)                      */
    return (lenList < i ? 0 : i);
}

Int             PosPlistHomSort (
    Obj                 list,
    Obj                 val,
    Int                 start )
{
    UInt                lenList;        /* logical length of the set       */
    UInt                i, j, k;        /* loop variables                  */

    /* get a pointer to the set and the logical length of the set          */
    lenList = LEN_PLIST( list );

    /* perform the binary search to find the position                      */
    i = start;  k = lenList + 1;
    while ( i+1 < k ) {                 /* set[i] < elm && elm <= set[k]   */
        j = (i + k) / 2;                /* i < j < k                       */
        if ( LT( ELM_PLIST(list,j), val ) )  i = j;
        else                                 k = j;
    }

    /* test if the element was found at position k                         */
    if ( lenList < k || ! EQ( ELM_PLIST(list,k), val ) )
        k = 0;

    /* return the position                                                 */
    return k;
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
            "you can return an integer for <pos>" );
    }
    p = INT_INTOBJ(pos);
    if ( p < 0 ) {
        pos = ErrorReturnObj(
            "<pos> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(pos), 0,
            "you can return a positive integer for <pos>" );
        return FuncASS_PLIST_DEFAULT( self, plist, pos, val );
    }
    while ( ! IS_PLIST(plist) || ! IS_MUTABLE_PLIST(plist) ) {
        plist = ErrorReturnObj(
            "<list> must be a mutable plain list (not a %s)",
            (Int)TNAM_OBJ(plist), 0,
            "you can return a mutable plain list for <list>" );
    }

    /* call `AssPlistXXX'                                                  */
    AssPlistXXX( plist, p, val );
    return 0;
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
    T_PLIST_CYC,                      T_PLIST,
    T_PLIST_CYC       +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_CYC_NSORT,                T_PLIST,
    T_PLIST_CYC_NSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,
    T_PLIST_CYC_SSORT,                T_PLIST,
    T_PLIST_CYC_SSORT +IMMUTABLE,     T_PLIST +IMMUTABLE,

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
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NSORT,    0,

    /* a mutable list with holes                                           */
    T_PLIST_NDENSE,               FN_IS_MUTABLE,  1,
    T_PLIST_NDENSE,               FN_IS_EMPTY,    0,
    T_PLIST_NDENSE,               FN_IS_DENSE,    0,
    T_PLIST_NDENSE,               FN_IS_NDENSE,   1,
    T_PLIST_NDENSE,               FN_IS_HOMOG,    0,
    T_PLIST_NDENSE,               FN_IS_NHOMOG,   0,
    T_PLIST_NDENSE,               FN_IS_TABLE,    0,
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
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NSORT,    1,

    /* mutable dense list, which only contains objects of type <= T_CYC    */
    T_PLIST_CYC,                  FN_IS_MUTABLE,  1,
    T_PLIST_CYC,                  FN_IS_EMPTY,    0,
    T_PLIST_CYC,                  FN_IS_DENSE,    1,
    T_PLIST_CYC,                  FN_IS_NDENSE,   0,
    T_PLIST_CYC,                  FN_IS_HOMOG,    1,
    T_PLIST_CYC,                  FN_IS_NHOMOG,   0,
    T_PLIST_CYC,                  FN_IS_TABLE,    0,
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
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_SSORT,    0,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NSORT,    1,

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
    T_PLIST_EMPTY,                FN_IS_SSORT,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_NSORT,   -1,

    /* mutable empty list                                                  */
    T_PLIST_EMPTY,                FN_IS_MUTABLE, T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_EMPTY,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_DENSE,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_NDENSE,  -1,
    T_PLIST_EMPTY,                FN_IS_HOMOG,   T_PLIST_EMPTY,
    T_PLIST_EMPTY,                FN_IS_NHOMOG,  -1,
    T_PLIST_EMPTY,                FN_IS_TABLE,   -1,
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
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_SSORT,   T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NSORT,   -1,

    /* mutable dense list                                                  */
    T_PLIST_DENSE,                FN_IS_MUTABLE, T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_EMPTY,   T_PLIST_EMPTY,
    T_PLIST_DENSE,                FN_IS_DENSE,   T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_NDENSE,  -1,
    T_PLIST_DENSE,                FN_IS_HOMOG,   T_PLIST_HOM,
    T_PLIST_DENSE,                FN_IS_NHOMOG,  T_PLIST_DENSE,
    T_PLIST_DENSE,                FN_IS_TABLE,   T_PLIST_DENSE,
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
    T_PLIST_DENSE_NHOM,           FN_IS_SSORT,   T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM,           FN_IS_NSORT,   T_PLIST_DENSE_NHOM,

    /* immutable dense list, which is immutable and not homogeneous        */
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_MUTABLE, T_PLIST_DENSE_NHOM,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_EMPTY,   -1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_DENSE,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_HOMOG,   -1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_SSORT,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NSORT,   T_PLIST_DENSE_NHOM+IMMUTABLE,

    /* a mutable list with holes                                           */
    T_PLIST_NDENSE,               FN_IS_MUTABLE, T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_EMPTY,   -1,
    T_PLIST_NDENSE,               FN_IS_DENSE,   -1,
    T_PLIST_NDENSE,               FN_IS_NDENSE,  T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_HOMOG,   -1,
    T_PLIST_NDENSE,               FN_IS_NHOMOG,  T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_TABLE,   -1,
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
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_SSORT,   -1,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB_NSORT +IMMUTABLE,

    /* mutable dense list, which only contains objects of type <= T_CYC    */
    T_PLIST_CYC,                  FN_IS_MUTABLE, T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_EMPTY,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_DENSE,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_NDENSE,  -1,
    T_PLIST_CYC,                  FN_IS_HOMOG,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_NHOMOG,  -1,
    T_PLIST_CYC,                  FN_IS_TABLE,   -1,
    T_PLIST_CYC,                  FN_IS_SSORT,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC,                  FN_IS_NSORT,   T_PLIST_CYC_NSORT,

    /* immutable dense list, which only contains objects of type <= T_CYC  */
    T_PLIST_CYC       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_CYC,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_DENSE,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_TABLE,   -1,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_SSORT,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NSORT,   T_PLIST_CYC_NSORT +IMMUTABLE,

    /* ssort mutable dense list, which only contains objs of type <= T_CYC */
    T_PLIST_CYC_SSORT,            FN_IS_MUTABLE, T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_EMPTY,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_DENSE,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_NDENSE,  -1,
    T_PLIST_CYC_SSORT,            FN_IS_HOMOG,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_NHOMOG,  -1,
    T_PLIST_CYC_SSORT,            FN_IS_TABLE,   -1,
    T_PLIST_CYC_SSORT,            FN_IS_SSORT,   T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT,            FN_IS_NSORT,   -1,

    /* ssort immutable dense list, which contains objs of type <= T_CYC    */
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_CYC_SSORT,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_DENSE,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NDENSE,  -1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_HOMOG,   T_PLIST_CYC_SSORT +IMMUTABLE,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_NHOMOG,  -1,
    T_PLIST_CYC_SSORT +IMMUTABLE, FN_IS_TABLE,   -1,
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
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_SSORT,   -1,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_CYC_NSORT +IMMUTABLE,

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
    T_PLIST_EMPTY,                FN_IS_SSORT,   T_PLIST,
    T_PLIST_EMPTY,                FN_IS_NSORT,   T_PLIST_EMPTY,

    /* immutable empty list                                                */
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_EMPTY,   T_PLIST           +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_EMPTY     +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_HOMOG,   T_PLIST           +IMMUTABLE,
    T_PLIST_EMPTY     +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_EMPTY     +IMMUTABLE,
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
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_SSORT,   T_PLIST_DENSE_NHOM+IMMUTABLE,
    T_PLIST_DENSE_NHOM+IMMUTABLE, FN_IS_NSORT,   T_PLIST_DENSE_NHOM+IMMUTABLE,

    /* a mutable list with holes                                           */
    T_PLIST_NDENSE,               FN_IS_MUTABLE, T_PLIST_NDENSE    +IMMUTABLE,
    T_PLIST_NDENSE,               FN_IS_EMPTY,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_DENSE,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NDENSE,  T_PLIST,
    T_PLIST_NDENSE,               FN_IS_HOMOG,   T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_NHOMOG,  T_PLIST_NDENSE,
    T_PLIST_NDENSE,               FN_IS_TABLE,   T_PLIST_NDENSE,
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
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_TAB_NSORT +IMMUTABLE,
    T_PLIST_TAB_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_TAB       +IMMUTABLE,

    /* mutable dense list, which only contains objects of type <= T_CYC    */
    T_PLIST_CYC,                  FN_IS_MUTABLE, T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC,                  FN_IS_EMPTY,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_DENSE,   T_PLIST,
    T_PLIST_CYC,                  FN_IS_NDENSE,  T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_HOMOG,   T_PLIST,
    T_PLIST_CYC,                  FN_IS_NHOMOG,  T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_TABLE,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_SSORT,   T_PLIST_CYC,
    T_PLIST_CYC,                  FN_IS_NSORT,   T_PLIST_CYC,

    /* immutable dense list, which only contains objects of type <= T_CYC  */
    T_PLIST_CYC       +IMMUTABLE, FN_IS_MUTABLE, T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_EMPTY,   T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_DENSE,   T_PLIST           +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NDENSE,  T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_HOMOG,   T_PLIST           +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_NHOMOG,  T_PLIST_CYC       +IMMUTABLE,
    T_PLIST_CYC       +IMMUTABLE, FN_IS_TABLE,   T_PLIST_CYC       +IMMUTABLE,
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
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_SSORT,   T_PLIST_CYC_NSORT +IMMUTABLE,
    T_PLIST_CYC_NSORT +IMMUTABLE, FN_IS_NSORT,   T_PLIST_CYC       +IMMUTABLE,

    -1,                         -1,             -1

};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    { "IS_PLIST_REP", "obj", &IsPListFilt,
      FuncIS_PLIST_REP, "src/lists.c:IS_PLIST_REP" },

    { 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "ASS_PLIST_DEFAULT", 3, "list, pos, val",
      FuncASS_PLIST_DEFAULT, "src/lists.c:ASS_PLIST_DEFAULT" },

    { 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                t1, t2;         /* loop variables                  */

    /* check dependencies                                                  */
    RequireModule( module, "lists", 403600000UL );

    /* GASMAN marking functions and GASMAN names                           */
    InitBagNamesFromTable( BagNames );

    for ( t1 = T_PLIST;  t1 <= T_PLIST_CYC_SSORT;  t1 += 2 ) {
        InitMarkFuncBags( t1                     , MarkAllSubBags );
        InitMarkFuncBags( t1 +IMMUTABLE          , MarkAllSubBags );
        InitMarkFuncBags( t1            +COPYING , MarkAllSubBags );
        InitMarkFuncBags( t1 +IMMUTABLE +COPYING , MarkAllSubBags );
    }

    for ( t1 = T_PLIST;  t1 <= T_PLIST_CYC_SSORT;  t1 += 2 ) {
        SaveObjFuncs[ t1 ]             = SavePlist;
        SaveObjFuncs[ t1 + IMMUTABLE ] = SavePlist; 
        LoadObjFuncs[ t1 ]             = LoadPlist;
        LoadObjFuncs[ t1 + IMMUTABLE ] = LoadPlist; 
    }

    /* get the kinds (resp. kind functions)                                */
    ImportGVarFromLibrary( "TYPE_LIST_NDENSE_MUTABLE", 
                           &TYPE_LIST_NDENSE_MUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_NDENSE_IMMUTABLE", 
                           &TYPE_LIST_NDENSE_IMMUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_DENSE_NHOM_MUTABLE", 
                           &TYPE_LIST_DENSE_NHOM_MUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_DENSE_NHOM_IMMUTABLE", 
                           &TYPE_LIST_DENSE_NHOM_IMMUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_EMPTY_MUTABLE", 
                           &TYPE_LIST_EMPTY_MUTABLE );

    ImportGVarFromLibrary( "TYPE_LIST_EMPTY_IMMUTABLE", 
                           &TYPE_LIST_EMPTY_IMMUTABLE );

    ImportFuncFromLibrary( "TYPE_LIST_HOM",
                           &TYPE_LIST_HOM );

    /* install the kind methods                                            */
    TypeObjFuncs[ T_PLIST                       ] = TypePlist;
    TypeObjFuncs[ T_PLIST            +IMMUTABLE ] = TypePlist;
    TypeObjFuncs[ T_PLIST_NDENSE                ] = TypePlistNDenseMut;
    TypeObjFuncs[ T_PLIST_NDENSE     +IMMUTABLE ] = TypePlistNDenseImm;
    TypeObjFuncs[ T_PLIST_DENSE                 ] = TypePlistDenseMut;
    TypeObjFuncs[ T_PLIST_DENSE      +IMMUTABLE ] = TypePlistDenseImm;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM            ] = TypePlistDenseNHomMut;
    TypeObjFuncs[ T_PLIST_DENSE_NHOM +IMMUTABLE ] = TypePlistDenseNHomImm;
    TypeObjFuncs[ T_PLIST_EMPTY                 ] = TypePlistEmptyMut;
    TypeObjFuncs[ T_PLIST_EMPTY      +IMMUTABLE ] = TypePlistEmptyImm;
    for ( t1 = T_PLIST_HOM; t1 <= T_PLIST_TAB_SSORT; t1 += 2 ) {
        TypeObjFuncs[ t1            ] = TypePlistHom;
        TypeObjFuncs[ t1 +IMMUTABLE ] = TypePlistHom;
    }
    for ( t1 = T_PLIST_CYC; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        TypeObjFuncs[ t1            ] = TypePlistCyc;
        TypeObjFuncs[ t1 +IMMUTABLE ] = TypePlistCyc;
    }

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* initialise list tables                                              */
    InitClearFiltsTNumsFromTable   ( ClearFiltsTab );
    InitHasFiltListTNumsFromTable  ( HasFiltTab    );
    InitSetFiltListTNumsFromTable  ( SetFiltTab    );
    InitResetFiltListTNumsFromTable( ResetFiltTab  );


    /* install the shallow copy methods                                    */
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        ShallowCopyObjFuncs[ t1            ] = ShallowCopyPlist;
        ShallowCopyObjFuncs[ t1 +IMMUTABLE ] = ShallowCopyPlist;
    }


    /* install the copy list methods                                       */
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
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
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT+IMMUTABLE; t1++ ) {
        for ( t2 = T_PLIST; t2 <= T_PLIST_CYC_SSORT+IMMUTABLE; t2++ ) {
            EqFuncs[ t1 ][ t2 ] = EqPlist;
            LtFuncs[ t1 ][ t2 ] = LtPlist;
        }
    }


    /* install the list length methods                                     */
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        LenListFuncs[ t1            ] = LenPlist;
        LenListFuncs[ t1 +IMMUTABLE ] = LenPlist;
    }
    LenListFuncs[ T_PLIST_EMPTY           ] = LenPlistEmpty;
    LenListFuncs[ T_PLIST_EMPTY+IMMUTABLE ] = LenPlistEmpty;


    /* install the list element test methods                               */
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        IsbListFuncs  [ t1            ] = IsbPlist;
        IsbListFuncs  [ t1 +IMMUTABLE ] = IsbPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        IsbListFuncs  [ t1            ] = IsbPlistDense;
        IsbListFuncs  [ t1 +IMMUTABLE ] = IsbPlistDense;
    }
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        IsbvListFuncs [ t1            ] = IsbvPlist;
        IsbvListFuncs [ t1 +IMMUTABLE ] = IsbvPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        IsbvListFuncs [ t1            ] = IsbvPlistDense;
        IsbvListFuncs [ t1 +IMMUTABLE ] = IsbvPlistDense;
    }


    /* install the list element methods                                    */
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        Elm0ListFuncs [ t1            ] = Elm0Plist;
        Elm0ListFuncs [ t1 +IMMUTABLE ] = Elm0Plist;
    }
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        Elm0vListFuncs[ t1            ] = Elm0vPlist;
        Elm0vListFuncs[ t1 +IMMUTABLE ] = Elm0vPlist;
    }
    for ( t1 = T_PLIST; t1 <= T_PLIST_NDENSE; t1 += 2 ) {
        ElmListFuncs  [ t1            ] = ElmPlist;
        ElmListFuncs  [ t1 +IMMUTABLE ] = ElmPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        ElmListFuncs  [ t1            ] = ElmPlistDense;
        ElmListFuncs  [ t1 +IMMUTABLE ] = ElmPlistDense;
    }
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        ElmvListFuncs [ t1            ] = ElmvPlist;
        ElmvListFuncs [ t1 +IMMUTABLE ] = ElmvPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        ElmvListFuncs [ t1            ] = ElmvPlistDense;
        ElmvListFuncs [ t1 +IMMUTABLE ] = ElmvPlistDense;
    }
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        ElmwListFuncs [ t1            ] = ElmvPlistDense;
        ElmwListFuncs [ t1 +IMMUTABLE ] = ElmvPlistDense;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        ElmwListFuncs [ t1            ] = ElmvPlistDense;
        ElmwListFuncs [ t1 +IMMUTABLE ] = ElmvPlistDense;
    }


    /* install the list elements methods                                   */
    for ( t1 = T_PLIST; t1 <= T_PLIST_NDENSE; t1 += 2 ) {
        ElmsListFuncs   [ t1            ] = ElmsPlist;
        ElmsListFuncs   [ t1 +IMMUTABLE ] = ElmsPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        ElmsListFuncs   [ t1            ] = ElmsPlistDense;
        ElmsListFuncs   [ t1 +IMMUTABLE ] = ElmsPlistDense;
    }


    /* install the list unbind methods                                     */
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        UnbListFuncs    [ t1            ] = UnbPlist;
        UnbListFuncs    [ t1+IMMUTABLE  ] = UnbPlistImm;
    }


    /* install the list assignment methods                                 */
    AssListFuncs    [ T_PLIST           ] = AssPlist;
    AssListFuncs    [ T_PLIST+IMMUTABLE ] = AssPlistImm;
    AssListFuncs    [ T_PLIST_NDENSE    ] = AssPlistXXX;
    AssListFuncs    [ T_PLIST_NDENSE+IMMUTABLE ] = AssPlistImm;
    
    for ( t1 = T_PLIST_DENSE; t1 < T_PLIST_CYC; t1 += 2 ) {
      AssListFuncs[ t1+IMMUTABLE      ] = AssPlistImm;
      AssListFuncs[ t1                ] = AssPlistDense;
    }

    for ( t1 = T_PLIST_CYC; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
      AssListFuncs[ t1+IMMUTABLE      ] = AssPlistImm;
      AssListFuncs[ t1                ] = AssPlistCyc;
    }

    AssListFuncs    [ T_PLIST_EMPTY     ] = AssPlistEmpty;


    /* install the list assignments methods                                */
    AsssListFuncs   [ T_PLIST            ] = AsssPlist;
    AsssListFuncs   [ T_PLIST +IMMUTABLE ] = AsssPlistImm;
    for ( t1 = T_PLIST_NDENSE; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        AsssListFuncs   [ t1             ] = AsssPlistXXX;
        AsssListFuncs   [ t1 +IMMUTABLE  ] = AsssPlistImm;
    }


    /* install the dense list test methods                                 */
    IsDenseListFuncs[ T_PLIST                   ] = IsDensePlist;
    IsDenseListFuncs[ T_PLIST        +IMMUTABLE ] = IsDensePlist;
    IsDenseListFuncs[ T_PLIST_NDENSE            ] = IsDensePlistNot;
    IsDenseListFuncs[ T_PLIST_NDENSE +IMMUTABLE ] = IsDensePlistNot;
    for ( t1 = T_PLIST_DENSE; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        IsDenseListFuncs[ t1            ] = IsDensePlistYes;
        IsDenseListFuncs[ t1 +IMMUTABLE ] = IsDensePlistYes;
    }


    /* install the homogeneous list test methods                           */
    IsHomogListFuncs[ T_PLIST                       ] = IsHomogPlist;
    IsHomogListFuncs[ T_PLIST            +IMMUTABLE ] = IsHomogPlist;
    IsHomogListFuncs[ T_PLIST_NDENSE                ] = IsHomogPlistNot;
    IsHomogListFuncs[ T_PLIST_NDENSE     +IMMUTABLE ] = IsHomogPlistNot;
    IsHomogListFuncs[ T_PLIST_DENSE                 ] = IsHomogPlist;
    IsHomogListFuncs[ T_PLIST_DENSE      +IMMUTABLE ] = IsHomogPlist;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM            ] = IsHomogPlistNot;
    IsHomogListFuncs[ T_PLIST_DENSE_NHOM +IMMUTABLE ] = IsHomogPlistNot;
    IsHomogListFuncs[ T_PLIST_EMPTY                 ] = IsHomogPlistYes;
    IsHomogListFuncs[ T_PLIST_EMPTY      +IMMUTABLE ] = IsHomogPlistYes;
    for ( t1 = T_PLIST_HOM; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        IsHomogListFuncs[ t1            ] = IsHomogPlistYes;
        IsHomogListFuncs[ t1 +IMMUTABLE ] = IsHomogPlistYes;
    }


    /* install the equal length list test methods                          */
    IsTableListFuncs[ T_PLIST                       ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST            +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_NDENSE                ] = IsTablePlistNot;
    IsTableListFuncs[ T_PLIST_NDENSE     +IMMUTABLE ] = IsTablePlistNot;
    IsTableListFuncs[ T_PLIST_DENSE                 ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_DENSE      +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM            ] = IsTablePlistNot;
    IsTableListFuncs[ T_PLIST_DENSE_NHOM +IMMUTABLE ] = IsTablePlistNot;
    IsTableListFuncs[ T_PLIST_EMPTY                 ] = IsTablePlistNot;
    IsTableListFuncs[ T_PLIST_EMPTY      +IMMUTABLE ] = IsTablePlistNot;
    IsTableListFuncs[ T_PLIST_HOM                   ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM        +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM_NSORT             ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM_NSORT  +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM_SSORT             ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_HOM_SSORT  +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_TAB                   ] = IsTablePlistYes;
    IsTableListFuncs[ T_PLIST_TAB        +IMMUTABLE ] = IsTablePlistYes;
    IsTableListFuncs[ T_PLIST_TAB_NSORT             ] = IsTablePlistYes;
    IsTableListFuncs[ T_PLIST_TAB_NSORT  +IMMUTABLE ] = IsTablePlistYes;
    IsTableListFuncs[ T_PLIST_TAB_SSORT             ] = IsTablePlistYes;
    IsTableListFuncs[ T_PLIST_TAB_SSORT  +IMMUTABLE ] = IsTablePlistYes;
    IsTableListFuncs[ T_PLIST_CYC                   ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_CYC        +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_CYC_NSORT             ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_CYC_NSORT  +IMMUTABLE ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_CYC_SSORT             ] = IsTablePlist;
    IsTableListFuncs[ T_PLIST_CYC_SSORT  +IMMUTABLE ] = IsTablePlist;


    /* install the strictly sorted list test methods                       */
    IsSSortListFuncs[ T_PLIST                      ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST           +IMMUTABLE ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_NDENSE               ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_NDENSE    +IMMUTABLE ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_DENSE                ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_DENSE     +IMMUTABLE ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM           ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_DENSE_NHOM+IMMUTABLE ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_EMPTY                ] = IsSSortPlistYes;
    IsSSortListFuncs[ T_PLIST_EMPTY     +IMMUTABLE ] = IsSSortPlistYes;
    IsSSortListFuncs[ T_PLIST_HOM                  ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_HOM       +IMMUTABLE ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_HOM_NSORT            ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_HOM_NSORT +IMMUTABLE ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_HOM_SSORT            ] = IsSSortPlistYes;
    IsSSortListFuncs[ T_PLIST_HOM_SSORT +IMMUTABLE ] = IsSSortPlistYes;
    IsSSortListFuncs[ T_PLIST_TAB                  ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_TAB       +IMMUTABLE ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_TAB_NSORT            ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_TAB_NSORT +IMMUTABLE ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_TAB_SSORT            ] = IsSSortPlistYes;
    IsSSortListFuncs[ T_PLIST_TAB_SSORT +IMMUTABLE ] = IsSSortPlistYes;
    IsSSortListFuncs[ T_PLIST_CYC                  ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_CYC       +IMMUTABLE ] = IsSSortPlist;
    IsSSortListFuncs[ T_PLIST_CYC_NSORT            ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_CYC_NSORT +IMMUTABLE ] = IsSSortPlistNot;
    IsSSortListFuncs[ T_PLIST_CYC_SSORT            ] = IsSSortPlistYes;
    IsSSortListFuncs[ T_PLIST_CYC_SSORT +IMMUTABLE ] = IsSSortPlistYes;


    /* install the position list test methods                              */
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        IsPossListFuncs[ t1            ] = IsPossPlist;
        IsPossListFuncs[ t1 +IMMUTABLE ] = IsPossPlist;
    }


    /* install the position list methods                                   */
    for ( t1 = T_PLIST; t1 <= T_PLIST_NDENSE; t1 += 2 ) {
        PosListFuncs[ t1            ] = PosPlist;
        PosListFuncs[ t1 +IMMUTABLE ] = PosPlist;
    }
    for ( t1 = T_PLIST_DENSE; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        PosListFuncs[ t1            ] = PosPlistDense;
        PosListFuncs[ t1 +IMMUTABLE ] = PosPlistDense;
    }
    PosListFuncs[ T_PLIST_HOM_SSORT            ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_HOM_SSORT +IMMUTABLE ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_TAB_SSORT            ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_TAB_SSORT +IMMUTABLE ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_CYC_SSORT            ] = PosPlistHomSort;
    PosListFuncs[ T_PLIST_CYC_SSORT +IMMUTABLE ] = PosPlistHomSort;


    /* install the plain list methods                                      */
    for ( t1 = T_PLIST; t1 <= T_PLIST_CYC_SSORT; t1 += 2 ) {
        PlainListFuncs[ t1            ] = PlainPlist;
        PlainListFuncs[ t1 +IMMUTABLE ] = PlainPlist;
    }

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
    module.revision_c = Revision_plist_c;
    module.revision_h = Revision_plist_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  plist.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
