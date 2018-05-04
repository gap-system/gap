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
#include <src/calls.h>


/****************************************************************************
**
**
*/
typedef struct {
    // an operation is a T_FUNCTION with additional data
    FuncBag func;

    // flag 1 list of an 'and' filter
    Obj flag1;

    // flag 2 list of an 'and' filter
    Obj flag2;

    // flags of a filter
    Obj flags;

    // setter of a filter
    Obj setter;

    // tester of a filter
    Obj tester;

    // method list of an operation
    Obj methods[8];

    // cache of an operation
    Obj cache[8];

    // 1 if the operation is an attribute and storing is enabled (default) else 0
    Obj enabled;
} OperBag;


/****************************************************************************
**
*V  TRY_NEXT_METHOD . . . . . . . . . . . . . . . . .  'TRY_NEXT_METHOD' flag
*/
extern Obj TRY_NEXT_METHOD;


/****************************************************************************
**
*F  IS_OPERATION( <obj> ) . . . . . . . . . . check if object is an operation
*/
static inline Int IS_OPERATION(Obj func)
{
    return TNUM_OBJ(func) == T_FUNCTION && SIZE_OBJ(func) == sizeof(OperBag);
}


/****************************************************************************
**
*F  OPER
*/
static inline OperBag * OPER(Obj oper)
{
    GAP_ASSERT(IS_OPERATION(oper));
    return (OperBag *)ADDR_OBJ(oper);
}

static inline const OperBag * CONST_OPER(Obj oper)
{
    GAP_ASSERT(IS_OPERATION(oper));
    return (const OperBag *)CONST_ADDR_OBJ(oper);
}


/****************************************************************************
**
*F  FLAG1_FILT( <oper> )  . . . . . . . . . .  flag 1 list of an 'and' filter
*/
static inline Obj FLAG1_FILT(Obj oper)
{
    return CONST_OPER(oper)->flag1;
}

static inline void SET_FLAG1_FILT(Obj oper, Obj x)
{
    OPER(oper)->flag1 = x;
}


/****************************************************************************
**
*F  FLAG2_FILT( <oper> )  . . . . . . . . . .  flag 2 list of an 'and' filter
*/
static inline Obj FLAG2_FILT(Obj oper)
{
    return CONST_OPER(oper)->flag2;
}

static inline void SET_FLAG2_FILT(Obj oper, Obj x)
{
    OPER(oper)->flag2 = x;
}


/****************************************************************************
**
*F  FLAGS_FILT( <oper> )  . . . . . . . . . . . . . . . . . flags of a filter
*/
static inline Obj FLAGS_FILT(Obj oper)
{
    return CONST_OPER(oper)->flags;
}

static inline void SET_FLAGS_FILT(Obj oper, Obj x)
{
    OPER(oper)->flags = x;
}


/****************************************************************************
**
*F  SETTER_FILT( <oper> ) . . . . . . . . . . . . . . . .  setter of a filter
*/
static inline Obj SETTR_FILT(Obj oper)
{
    return CONST_OPER(oper)->setter;
}

static inline void SET_SETTR_FILT(Obj oper, Obj x)
{
    OPER(oper)->setter = x;
}


/****************************************************************************
**
*F  TESTR_FILT( <oper> )  . . . . . . . . . . . . . . . .  tester of a filter
*/
static inline Obj TESTR_FILT(Obj oper)
{
    return CONST_OPER(oper)->tester;
}

static inline void SET_TESTR_FILT(Obj oper, Obj x)
{
    OPER(oper)->tester = x;
}


/****************************************************************************
**
*F  METHS_OPER( <oper> )  . . . . . . . . . . . . method list of an operation
*/
static inline Obj METHS_OPER(Obj oper, Int i)
{
    GAP_ASSERT(0 <= i && i < 8);
    return CONST_OPER(oper)->methods[i];
}

static inline void SET_METHS_OPER(Obj oper, Int i, Obj x)
{
    GAP_ASSERT(0 <= i && i < 8);
    OPER(oper)->methods[i] = x;
}


/****************************************************************************
**
*F  CACHE_OPER( <oper> )  . . . . . . . . . . . . . . . cache of an operation
*/
static inline Obj CACHE_OPER(Obj oper, Int i)
{
    GAP_ASSERT(0 <= i && i < 8);
    return CONST_OPER(oper)->cache[i];
}

static inline void SET_CACHE_OPER(Obj oper, Int i, Obj x)
{
    GAP_ASSERT(0 <= i && i < 8);
    OPER(oper)->cache[i] = x;
}


/****************************************************************************
**
*F  ENABLED_ATTR( <oper> ) . . . . true if the operation is an attribute and
**                                 storing is enabled (default) else false
*/
static inline Int ENABLED_ATTR(Obj oper)
{
    Obj val = CONST_OPER(oper)->enabled;
    return val ? INT_INTOBJ(val) : 0;
}


/****************************************************************************
**
*F  SET_ENABLED_ATTR( <oper>, <new> )  . set a new value that records whether 
**                                       storing is enabled for an operation
*/
static inline void SET_ENABLED_ATTR(Obj oper, Int x)
{
    OPER(oper)->enabled = INTOBJ_INT(x);
}


/****************************************************************************
**
*F * * * * * * * * * * * * internal flags functions * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  NEW_FLAGS( <flags>, <len> ) . . . . . . . . . . . . . . .  new flags list
*/
static inline Obj NEW_FLAGS(UInt len)
{
    UInt size = (3 + ((len+BIPEB-1) >> LBIPEB)) * sizeof(Obj);
    Obj flags = NewBag(T_FLAGS, size);
    return flags;
}


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
static inline UInt LEN_FLAGS(Obj flags)
{
    return (SIZE_OBJ(flags) / sizeof(Obj) - 3) << LBIPEB;
};

/****************************************************************************
**
*F  AND_CACHE_FLAGS( <flags> )  . . . . . . . . . 'and' cache of a flags list
*/
#define AND_CACHE_FLAGS(list)           (CONST_ADDR_OBJ(list)[2])


/****************************************************************************
**
*F  SET_AND_CACHE_FLAGS( <flags>, <len> ) set the 'and' cache of a flags list
*/
#define SET_AND_CACHE_FLAGS(flags,andc)  (ADDR_OBJ(flags)[2]=(andc))


/****************************************************************************
**
*F  NRB_FLAGS( <flags> )  . . . . . .  number of basic blocks of a flags list
*/
static inline UInt NRB_FLAGS(Obj flags)
{
    return SIZE_OBJ(flags) / sizeof(Obj) - 3;
};


/****************************************************************************
**
*F  BLOCKS_FLAGS( <flags> ) . . . . . . . . . . . . data area of a flags list
*/
#define BLOCKS_FLAGS(flags)             ((UInt*)(ADDR_OBJ(flags)+3))


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
**  'MASK_POS_FLAGS(<pos>)' returns a UInt with a single set  bit in position
**  '(<pos>-1) % BIPEB',
**  useful for accessing the <pos>-th element of a 'FLAGS' list.
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
**  'C_ELM_FLAGS' returns a result which it is better to use inside the kernel
**  since the C compiler can't know that True != False. Using C_ELM_FLAGS
**  gives slightly nicer C code and potential for a little more optimisation.
*/
#define C_ELM_FLAGS(list, pos)                                               \
    ((BLOCK_ELM_FLAGS(list, pos) & MASK_POS_FLAGS(pos)) ? 1 : 0)

#define ELM_FLAGS(list, pos) (C_ELM_FLAGS(list, pos) ? True : False)

static inline Int SAFE_C_ELM_FLAGS(Obj flags, UInt pos)
{
    return (pos <= LEN_FLAGS(flags)) ? C_ELM_FLAGS(flags, pos) : 0;
}

#define SAFE_ELM_FLAGS(list, pos) (SAFE_C_ELM_FLAGS(list, pos) ? True : False)


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
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoOpers() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoOpers ( void );


#endif // GAP_OPERS_H
