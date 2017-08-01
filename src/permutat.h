/****************************************************************************
**
*W  permutat.h                  GAP source                   Martin Schönert
**                                                           & Alice Niemeyer
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file defines the functions for permutations (small and large).
*/

#ifndef GAP_PERMUTAT_H
#define GAP_PERMUTAT_H

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

#define IMAGE(i,pt,dg)  (((i) < (dg)) ? (pt)[(i)] : (i))

#ifdef SYS_IS_64_BIT
#define MAX_DEG_PERM4 ((1L<<32)-1)
#else
#define MAX_DEG_PERM4 ((1L<<28)-1)
#endif

#define IS_PERM2(perm)  (TNUM_OBJ(perm) == T_PERM2)
#define IS_PERM4(perm)  (TNUM_OBJ(perm) == T_PERM4)

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
*F  LargestMovedPointPerm(perm) . . . . . . . . largest point moved by a perm
*/
UInt LargestMovedPointPerm(Obj perm);

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoPermutat()  . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPermutat ( void );


#endif // GAP_PERMUTAT_H
