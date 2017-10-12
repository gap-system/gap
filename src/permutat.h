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

static inline UInt SIZEBAG_PERM2(UInt deg) {
  return sizeof(Obj) + deg*sizeof(UInt2);
}

static inline Obj NEW_PERM2(UInt deg) {
  return NewBag( T_PERM2, SIZEBAG_PERM2(deg));
}

static inline UInt DEG_PERM2(Obj perm)  {
  return (SIZE_OBJ(perm) - sizeof(Obj)) / sizeof(UInt2);
}

static inline UInt2 *ADDR_PERM2(Obj perm) {
  return (UInt2*)(ADDR_OBJ(perm) + 1);
}

static inline const UInt2* CONST_ADDR_PERM2(Obj perm) {
  return (const UInt2*)(CONST_ADDR_OBJ(perm) + 1);
}

static inline UInt SIZEBAG_PERM4(UInt deg) {
  return sizeof(Obj) + deg*sizeof(UInt4);
}

static inline Obj NEW_PERM4(UInt deg) {
  return NewBag( T_PERM4, SIZEBAG_PERM4(deg));
}

static inline UInt DEG_PERM4(Obj perm)   {
  return (SIZE_OBJ(perm) - sizeof(Obj)) / sizeof(UInt4);
}

static inline UInt4* ADDR_PERM4(Obj perm) {
  return (UInt4*)(ADDR_OBJ(perm)+1);
}

static inline const UInt4* CONST_ADDR_PERM4(Obj perm) {
  return (const UInt4*)(CONST_ADDR_OBJ(perm)+1);
}

static inline Obj STOREDINV_PERM(Obj perm) {
  return ADDR_OBJ(perm)[0];
}

static inline void SET_STOREDINV_PERM(Obj perm, Obj inv) {
  if (TNUM_OBJ(inv) == TNUM_OBJ(perm)) {
    ADDR_OBJ(perm)[0] = inv;
    CHANGED_BAG(perm);
    ADDR_OBJ(inv)[0] = perm;
    CHANGED_BAG(inv);
  }
}


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
**  permutation <perm>.  It is called from 'FuncOnTuples'.
*/
extern  Obj             OnTuplesPerm (
            Obj                 tup,
            Obj                 perm );


/****************************************************************************
**
*F  OnSetsPerm( <set>, <perm> ) . . . . . . . .  operations on sets of points
**
**  'OnSetsPerm' returns the  image of the  tuple <set> under the permutation
**  <perm>.  It is called from 'FuncOnSets'.
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
