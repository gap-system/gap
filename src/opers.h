/****************************************************************************
**
*W  opers.h                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the  filters, operations, attributes,
**  and properties package.
*/

#ifndef GAP_OPERS_H
#define GAP_OPERS_H

#include <src/system.h>
#include <src/calls.h>  // for ObjFunc

/****************************************************************************
**
*V  TRY_NEXT_METHOD . . . . . . . . . . . . . . . . . `TRY_NEXT_MESSAGE' flag
*/
extern Obj TRY_NEXT_METHOD;


/****************************************************************************
**
*F  IS_OPERATION( <obj> ) . . . . . . . . . . check if object is an operation
*/
#define IS_OPERATION(func) \
    (TNUM_OBJ(func) == T_FUNCTION && SIZE_OBJ(func) == SIZE_OPER )

/****************************************************************************
**
*F  FLAG1_FILT( <oper> )  . . . . . . . . . .  flag 1 list of an `and' filter
*/
#define FLAG1_FILT(oper)        (*            (ADDR_OBJ(oper) +16     ) )


/****************************************************************************
**
*F  FLAG2_FILT( <oper> )  . . . . . . . . . .  flag 2 list of an `and' filter
*/
#define FLAG2_FILT(oper)        (*            (ADDR_OBJ(oper) +17     ) )


/****************************************************************************
**
*F  FLAGS_FILT( <oper> )  . . . . . . . . . . . . . . . . . flags of a filter
*/
#define FLAGS_FILT(oper)        (*            (ADDR_OBJ(oper) +18     ) )


/****************************************************************************
**
*F  SETTER_FILT( <oper> ) . . . . . . . . . . . . . . . .  setter of a filter
*/
#define SETTR_FILT(oper)        (*            (ADDR_OBJ(oper) +19     ) )


/****************************************************************************
**
*F  TESTR_FILT( <oper> )  . . . . . . . . . . . . . . . .  tester of a filter
*/
#define TESTR_FILT(oper)        (*            (ADDR_OBJ(oper) +20     ) )


/****************************************************************************
**
*F  METHS_OPER( <oper> )  . . . . . . . . . . . . method list of an operation
*/
#define METHS_OPER(oper,i)      (*            (ADDR_OBJ(oper) +21+ (i)) )


/****************************************************************************
**
*F  CACHE_OPER( <oper> )  . . . . . . . . . . . . . . . cache of an operation
*/
#define CACHE_OPER(oper,i)      (*            (ADDR_OBJ(oper) +29+ (i)) )

/****************************************************************************
**
*F  ENABLED_ATTR( <oper> ) . . . . true if the operation is an attribute and
**                                 storing is enabled (default) else false
*/

#define ENABLED_ATTR(oper)                 ((UInt)(CONST_ADDR_OBJ(oper)[37]))

/****************************************************************************
**
*F  SET_ENABLED_ATTR( <oper>, <new> )  . set a new value that records whether 
**                                       storing is enabled for an operation
*/

#define SET_ENABLED_ATTR(oper, new)       ((ADDR_OBJ(oper)[37]) = (Obj)(new)) 

/****************************************************************************
**
*V  SIZE_OPER . . . . . . . . . . . . . . . . . . . . .  size of an operation
*/
#define SIZE_OPER               (38*sizeof(Bag))


/****************************************************************************
**
*F * * * * * * * * * * * * internal flags functions * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  NEW_FLAGS( <flags>, <size> )  . . . . . . . . . . . . . .  new flags list
*/
#define NEW_FLAGS( flags, size ) \
    ( flags = NewBag( T_FLAGS, SIZE_PLEN_FLAGS(size) ) )


/****************************************************************************
**
*F  SIZE_PLEN_FLAGS( <plen> ) . .  size for a flags list with physical length
*/
#define SIZE_PLEN_FLAGS(plen) \
  (4*sizeof(Obj)+(((plen)+BIPEB-1) >> LBIPEB)*sizeof(Obj))



/****************************************************************************
**
*F  TRUES_FLAGS( <flags> )  . . . . . . . . . . list of trues of a flags list
**
**  returns the list of trues of <flags> or 0 if the list is not known yet.
*/
#define TRUES_FLAGS(flags)              (CONST_ADDR_OBJ(flags)[0])


/****************************************************************************
**
*F  SET_TRUES_FLAGS( <flags>, <trues> ) . set number of trues of a flags list
*/
#define SET_TRUES_FLAGS(flags,trues)    (ADDR_OBJ(flags)[0] = trues)


/****************************************************************************
**
*F  HASH_FLAGS( <flags> ) . . . . . . . . . . . .  hash value of <flags> or 0
*/
#define HASH_FLAGS(flags)               (CONST_ADDR_OBJ(flags)[1])


/****************************************************************************
**
*F  SET_HASH_FLAGS( <flags>, <hash> ) . . . . . . . . . . . . . . .  set hash
*/
#define SET_HASH_FLAGS(flags,hash)      (ADDR_OBJ(flags)[1] = hash)


/****************************************************************************
**
*F  LEN_FLAGS( <flags> )  . . . . . . . . . . . . . .  length of a flags list
*/
#define LEN_FLAGS(list)                 (INT_INTOBJ(CONST_ADDR_OBJ(list)[2]))


/****************************************************************************
**
*F  SET_LEN_FLAGS( <flags>, <len> ) . . . . .  set the length of a flags list
*/
#define SET_LEN_FLAGS(flags,len)        (ADDR_OBJ(flags)[2]=INTOBJ_INT(len))


/****************************************************************************
**
*F  AND_CACHE_FLAGS( <flags> )  . . . . . . . . . `and' cache of a flags list
*/
#define AND_CACHE_FLAGS(list)           (CONST_ADDR_OBJ(list)[3])


/****************************************************************************
**
*F  SET_AND_CACHE_FLAGS( <flags>, <len> ) set the `and' cache of a flags list
*/
#define SET_AND_CACHE_FLAGS(flags,andc)  (ADDR_OBJ(flags)[3]=(andc))


/****************************************************************************
**
*F  NRB_FLAGS( <flags> )  . . . . . .  number of basic blocks of a flags lits
*/
#define NRB_FLAGS(flags)                ((LEN_FLAGS(flags)+BIPEB-1) >> LBIPEB)



/****************************************************************************
**
*F  BLOCKS_FLAGS( <flags> ) . . . . . . . . . . . . data area of a flags list
*/
#define BLOCKS_FLAGS(flags)             ((UInt*)(ADDR_OBJ(flags)+4))


/****************************************************************************
**
*F  BLOCK_ELM_FLAGS( <list>, <pos> )  . . . . . . . .  block  of a flags list
**
**  'BLOCK_ELM_FLAGS' return the block containing the <pos>-th element of the
**  flags list <list> as a UInt value, which is also a  valid left hand side.
**  <pos>  must be a positive  integer  less than or  equal  to the length of
**  <list>.
**
**  Note that 'BLOCK_ELM_FLAGS' is a macro, so do not call it  with arguments
**  that have side effects.
*/
#define BLOCK_ELM_FLAGS(list, pos)      (BLOCKS_FLAGS(list)[((pos)-1) >> LBIPEB])


/****************************************************************************
**
*F  MASK_POS_FLAGS( <pos> ) . . .  . .  bit mask for position of a flags list
**
**  MASK_POS_FLAGS(<pos>) returns  a UInt with a  single set  bit in position
**  (pos-1) % BIPEB, useful for accessing the pos'th element of a FLAGS
**
**  Note that 'MASK_POS_FLAGS'  is a macro, so  do not call it with arguments
**  that have side effects.
*/
#define MASK_POS_FLAGS(pos)             (((UInt) 1)<<(((pos)-1) & (BIPEB-1)))


/****************************************************************************
**
*F  ELM_FLAGS( <list>, <pos> )  . . . . . . . . . . . element of a flags list
**
**  'ELM_FLAGS' return the <pos>-th element of the flags list <list>, which
**  is either 'true' or 'false'.  <pos> must  be a positive integer less than
**  or equal to the length of <hdList>.
**
**  Note that 'ELM_FLAGS' is a macro, so do not call it  with arguments  that
**  have side effects.
**
**  C_ELM_FLAGS returns a result which it is better to use inside the kernel
**  since the C compiler can't know that True != False. Using C_ELM_FLAGS
**  gives slightly nicer C code and potential for a little more optimisation.
*/
#define C_ELM_FLAGS(list, pos)                                               \
    ((BLOCK_ELM_FLAGS(list, pos) & MASK_POS_FLAGS(pos)) ? 1 : 0)

#define ELM_FLAGS(list, pos) (C_ELM_FLAGS(list, pos) ? True : False)


/****************************************************************************
**
*F  SET_ELM_FLAGS( <list>, <pos>, <val> ) . .  set an element of a flags list
**
**  'SET_ELM_FLAGS' sets  the element at position <pos>   in the flags list
**  <list> to the value <val>.  <pos> must be a positive integer less than or
**  equal to the length of <hdList>.  <val> must be either 'true' or 'false'.
**
**  Note that  'SET_ELM_FLAGS' is  a macro, so do not  call it with arguments
**  that have side effects.
*/
#define SET_ELM_FLAGS(list,pos,val)  \
 ((val) == True ? \
  (BLOCK_ELM_FLAGS(list, pos) |= MASK_POS_FLAGS(pos)) : \
  (BLOCK_ELM_FLAGS(list, pos) &= ~MASK_POS_FLAGS(pos)))

/****************************************************************************
**
*F  FuncIS_SUBSET_FLAGS( <self>, <flags1>, <flags2> ) . . . . . . subset test
*/

extern Obj FuncIS_SUBSET_FLAGS( Obj self, Obj flags1, Obj flags2 );
     
/****************************************************************************
**
*F * * * * * * * * * * *  internal filter functions * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  CountFlags  . . . . . . . . . . . . . . . . . . . . next free flag number
*/
extern Int CountFlags;


/****************************************************************************
**
*V  SET_FILTER_OBJ  . . . . . . . . . . . .  library function to set a filter
*/
extern Obj SET_FILTER_OBJ;


/****************************************************************************
**
*V  RESET_FILTER_OBJ  . . . . . . . . . .  library function to reset a filter
*/
extern Obj RESET_FILTER_OBJ;



/****************************************************************************
**
*F  SetterFilter( <oper> )  . . . . . . . . . . . . . . .  setter of a filter
*/
extern Obj SetterFilter (
    Obj                 oper );


/****************************************************************************
**
*F  SetterAndFilter( <getter> )  . . . . . .  setter of a concatenated filter
*/
extern Obj DoSetAndFilter (
    Obj                 self,
    Obj                 obj,
    Obj                 val );

extern Obj SetterAndFilter (
    Obj                 getter );
        

/****************************************************************************
**
*F  TesterFilter( <oper> )  . . . . . . . . . . . . . . .  tester of a filter
*/
extern Obj TesterFilter (
    Obj                 oper );


/****************************************************************************
**
*F  TestAndFilter( <getter> )  . . . . . . . .tester of a concatenated filter
*/
extern Obj DoTestAndFilter (
    Obj                 self,
    Obj                 obj );

extern Obj TesterAndFilter (
    Obj                 getter );


/****************************************************************************
**
*F  NewFilter( <name>, <narg>, <nams>, <hdlr> )  . . . . .  make a new filter
*/
extern Obj NewTesterFilter (
    Obj                 getter );

extern Obj DoSetFilter (
    Obj                 self,
    Obj                 obj,
    Obj                 val );

extern Obj NewSetterFilter (
    Obj                 getter );

extern Obj DoFilter (
    Obj                 self,
    Obj                 obj );

extern Obj NewFilter (
    Obj                 name,
    Int                 narg,
    Obj                 nams,
    ObjFunc             hdlr );


extern Obj DoTestAttribute( Obj self, Obj obj);

/****************************************************************************
**
*F  NewAndFilter( <filt1>, <filt2> ) . . . . . make a new concatenated filter
*/
extern Obj DoAndFilter (
    Obj                 self,
    Obj                 obj );

extern Obj NewAndFilter (
    Obj                 oper1,
    Obj                 oper2 );


/****************************************************************************
**
*V  ReturnTrueFilter . . . . . . . . . . . . . . . . the return 'true' filter
*/
extern Obj ReturnTrueFilter;


/****************************************************************************
**
*F * * * * * * * * * *  internal operation functions  * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  NewOperation( <name> )  . . . . . . . . . . . . . .  make a new operation
*/
extern Obj DoOperation0Args (
            Obj                 oper );

extern Obj DoOperation1Args (
            Obj                 oper,
            Obj                 arg1 );

extern Obj DoOperation2Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2 );

extern Obj DoOperation3Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3 );

extern Obj DoOperation4Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4 );

extern Obj DoOperation5Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5 );

extern Obj DoOperation6Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5,
            Obj                 arg6 );

extern Obj DoOperationXArgs (
            Obj                 self,
            Obj                 args );

extern Obj DoVerboseOperation0Args (
            Obj                 oper );

extern Obj DoVerboseOperation1Args (
            Obj                 oper,
            Obj                 arg1 );

extern Obj DoVerboseOperation2Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2 );

extern Obj DoVerboseOperation3Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3 );

extern Obj DoVerboseOperation4Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4 );

extern Obj DoVerboseOperation5Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5 );

extern Obj DoVerboseOperation6Args (
            Obj                 oper,
            Obj                 arg1,
            Obj                 arg2,
            Obj                 arg3,
            Obj                 arg4,
            Obj                 arg5,
            Obj                 arg6 );

extern Obj DoVerboseOperationXArgs (
            Obj                 self,
            Obj                 args );

extern Obj NewOperation (
            Obj                 name,
            Int                 narg,
            Obj                 nams,
            ObjFunc             hdlr );


/****************************************************************************
**
*F  NewAttribute( <name> )  . . . . . . . . . . . . . .  make a new attribute
*/
extern  Obj DoAttribute (
            Obj                 self,
            Obj                 obj );

extern  Obj DoVerboseAttribute (
            Obj                 self,
            Obj                 obj );

extern  Obj NewAttribute (
            Obj                 name,
            Int                 narg,
            Obj                 nams,
            ObjFunc             hdlr );

/****************************************************************************
**
*F  NewProperty( <name> ) . . . . . . . . . . . . . . . . make a new property
*/
extern Obj DoProperty (
            Obj                 self,
            Obj                 obj );

extern Obj NewProperty (
            Obj                 name,
            Int                 narg,
            Obj                 nams,
            ObjFunc             hdlr );

/****************************************************************************
**
*F  InstallMethodArgs( <oper>, <func> ) . . . . . . . . . . .  clone function
**
**  There is a problem  with uncompleted functions: if  they are  cloned then
**  only   the orignal and not  the  clone will be  completed.  Therefore the
**  clone must postpone the real cloning.
*/
extern void InstallMethodArgs (
    Obj                 oper,
    Obj                 func );


/****************************************************************************
**
*F  ChangeDoOperations( <oper>, <verb> )
*/
extern void ChangeDoOperations (
            Obj                 oper,
            Int                 verb );

/****************************************************************************
**
*F  SaveOperationExtras( <oper> ) . . .  additional savng for functions which
**                                       are operations
**
**  This is called by SaveFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/

extern void SaveOperationExtras( Obj oper );

/****************************************************************************
**
*F  LoadOperationExtras( <oper> ) . .  additional loading for functions which
**                                       are operations
**
**  This is called by LoadFunction when the function bag is too large to be
**  a simple function, and so must be an operation
**
*/

extern void LoadOperationExtras( Obj oper );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoOpers() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoOpers ( void );


#endif // GAP_OPERS_H
