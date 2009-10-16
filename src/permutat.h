/****************************************************************************
**
*W  permutat.h                  GAP source                   Martin Schoenert
**                                                           & Alice Niemeyer
**
*H  @(#)$Id: permutat.h,v 4.8 2002/04/15 10:03:54 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file defines the functions for permutations (small and large).
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_permutat_h =
   "@(#)$Id: permutat.h,v 4.8 2002/04/15 10:03:54 sal Exp $";
#endif


/****************************************************************************
**

*F  NEW_PERM2(<deg>)  . . . . . . . . . . . .  make a new (small) permutation
*F  DEG_PERM2(<perm>) . . . . . . . . . . . . . degree of (small) permutation
*F  ADDR_PERM2(<perm>)  . . . . . . . absolute address of (small) permutation
*F  NEW_PERM4(<deg>)  . . . . . . . . . . . .  make a new (large) permutation
*F  DEG_PERM4(<perm>) . . . . . . . . . . . . . degree of (large) permutation
*F  ADDR_PERM4(<perm>)  . . . . . . . absolute address of (large) permutation
*/
#define NEW_PERM2(deg)          NewBag( T_PERM2, (deg) * sizeof(UInt2))
#define DEG_PERM2(perm)         (SIZE_OBJ(perm) / sizeof(UInt2))
#define ADDR_PERM2(perm)        ((UInt2*)ADDR_OBJ(perm))
#define NEW_PERM4(deg)          NewBag( T_PERM4, (deg) * sizeof(UInt4))
#define DEG_PERM4(perm)         (SIZE_OBJ(perm) / sizeof(UInt4))
#define ADDR_PERM4(perm)        ((UInt4*)ADDR_OBJ(perm))


/****************************************************************************
**
*V  IdentityPerm  . . . . . . . . . . . . . . . . . . .  identity permutation
**
**  'IdentityPerm' is an identity permutation.
*/
extern  Obj             IdentityPerm;


/****************************************************************************
**
*F  OnTuplesPerm( <tup>, <perm> )  . . . .  operations on tuples of points
**
**  'OnTuplesPerm'  returns  the  image  of  the  tuple  <tup>   under  the
**  permutation <perm>.  It is called from 'FunOnTuples'.
*/
extern  Obj             OnTuplesPerm (
            Obj                 tup,
            Obj                 perm );


/****************************************************************************
**
*F  OnSetsPerm( <set>, <perm> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsPerm' returns the  image of the  tuple <set> under the permutation
**  <perm>.  It is called from 'FunOnSets'.
*/
extern  Obj             OnSetsPerm (
            Obj                 set,
            Obj                 perm );


/****************************************************************************
**
*F  Array2Perm( <array> ) . . . . . . . . . convert array of cycles into perm
*/
extern Obj Array2Perm (
    Obj                 array );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoPermutat()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPermutat ( void );


/****************************************************************************
**

*E  permutat.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
