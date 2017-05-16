/****************************************************************************
**
*W  gasman.h                    GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares  the functions of  Gasman,  the  GAP  storage manager.
**
**  {\Gasman} is a storage manager for applications written in C.  That means
**  that an application requests blocks  of storage from {\Gasman}, which are
**  called bags.   After using a bag   to store data,  the application simply
**  forgets the  bag,  and  we  say that  such a  block  is dead.   {\Gasman}
**  implements   an   automatic,  cooperating,   compacting,    generational,
**  conservative storage manager.  Automatic  means that the application only
**  allocates  bags,   but need  not  explicitly   deallocate them.   This is
**  important for large or  complex application, where explicit  deallocation
**  is difficult.  Cooperating means  that the allocation must cooperate with
**  {\Gasman}, i.e., must follow certain rules.  This information provided by
**  the   application makes  {\Gasman}   use  less  storage and   run faster.
**  Compacting  means that {\Gasman} always compacts  live bags such that the
**  free storage is  one large block.  Because  there is  no fragmentation of
**  the  free  storage   {\Gasman} uses   as   little storage   as  possible.
**  Generational  means  that {\Gasman}  usually assumes  that bags that have
**  been live for some  time are still live.  This   means that it can  avoid
**  most of the tests whether a bag is still live or already dead.  Only when
**  not enough storage can be reclaimed under this assumption does it perform
**  all the  tests.  Conservative means  that {\Gasman} may  keep bags longer
**  than necessary because   the  C compiler   does  not provide   sufficient
**  information to distinguish true references to bags from other values that
**  happen to  look like references.
*/

#ifndef GAP_GASMAN_H
#define GAP_GASMAN_H

/* This definition switches to the bigger bag header, supporting bags up to
   4GB in length (lists limited to 1GB for other reasons) */

/* Experimental 16+48 bit type/size word for 64 bit systems */

/****************************************************************************
**
*V  autoconf  . . . . . . . . . . . . . . . . . . . . . . . .  use "config.h"
*/
#include <gen/config.h>

#include <src/hpc/atomic.h>

/* on 64 bit systems use only two words for bag header */

#if SIZEOF_VOID_P == 8
#define USE_NEWSHAPE
#elif !defined(SIZEOF_VOID_P) && !defined(USE_PRECOMPILED)
/* If SIZEOF_VOID_P has not been defined, and we are not currently
   re-making the dependency list (via cnf/Makefile), then trigger
   an error. */
#error Something is wrong with this GAP installation: SIZEOF_VOID_P not defined
#endif


/****************************************************************************
**

*T  Bag . . . . . . . . . . . . . . . . . . . type of the identifier of a bag
**
**  'Bag'
**
**  Each bag is identified by its  *bag identifier*.  That  is each bag has a
**  bag identifier and no  two live bags have the  same identifier.  'Bag' is
**  the type of bag identifiers.
**
**  0 is a  valid value of the type  'Bag', but is guaranteed  not to be  the
**  identifier of any bag.
**
**  'NewBag'  returns  the identifier of   the newly   allocated bag and  the
**  application passes this identifier to every {\Gasman} function to tell it
**  which bag  it should  operate  on (see "NewBag",  "TNUM_BAG", "SIZE_BAG",
**  "PTR_BAG", "CHANGED_BAG", "RetypeBag", and "ResizeBag").
**
**  Note that the  identifier of a  bag is different from  the address of the
**  data area  of  the  bag.  This  address  may   change during  a   garbage
**  collection while the identifier of a bag never changes.
**
**  Bags  that contain references  to   other bags  must  always contain  the
**  identifiers of these other bags, never the addresses of the data areas of
**  the bags.
**
**  Note that bag identifiers are recycled.  That means that after a bag dies
**  its identifier may be reused for a new bag.
**
**  The following is defined in "system.h"
**
typedef UInt * *        Bag;
*/


/****************************************************************************
**
*F  TNUM_BAG(<bag>) . . . . . . . . . . . . . . . . . . . . . . type of a bag
**
**  'TNUM_BAG( <bag> )'
**
**  'TNUM_BAG' returns the type of the bag with the identifier <bag>.
**
**  Each bag has a certain type that identifies its structure.  The type is a
**  integer between 0  and  253.  The types 254   and  255 are  reserved  for
**  {\Gasman}.  The application specifies the type of a bag when it allocates
**  it with 'NewBag'  and may later  change it with 'RetypeBag' (see "NewBag"
**  and "RetypeBag").
**
**  {\Gasman} needs to know the type of a bag so that it knows which function
**  to  call  to  mark all subbags  of a  given bag (see "InitMarkFuncBags").
**  Apart from that {\Gasman} does not care at all about types.
**
**  Note  that 'TNUM_BAG' is a macro, so do not call  it with arguments  that
**  have side effects.
*/

#ifdef USE_NEWSHAPE
#define BAG_TNUM_OFFSET (-2)
#else
#define BAG_TNUM_OFFSET (-3)
#endif

#define TNUM_BAG(bag)  (*(*(bag) + BAG_TNUM_OFFSET) & 0xFFL)


/****************************************************************************
**
*F  TEST_OBJ_FLAG(<bag>, <flag>) . . . . . . . . . . . . . . test object flag
*F  SET_OBJ_FLAG(<bag>, <flag>) . . . . . . . . . . . . . . . set object flag
*F  CLEAR_OBJ_FLAG(<bag>, <flag>) . . . . . . . . . . . . . clear object flag
**
**  These three macros test, set, and clear object flags, respectively.
**  Object flags are stored in the object header. Multiple flags can be ored
**  together using '|' to set or clear multiple flags at once.
**
**  TEST_OBJ_FLAG() will return the ored version of all tested flags. To
**  test that one of them is set, check if the result is not equal to zero.
**  To test that all of them are set, compare the result to the original
**  flags, e.g.
**
** 	if (TEST_OBJ_FLAG(obj, FLAG1 | FLAG2 ) == (FLAG1 | FLAG2)) ...
**
**  Similary, if you wish to test that FLAG1 is set and FLAG2 is not set,
**  use:
**
** 	if (TEST_OBJ_FLAG(obj, FLAG1 | FLAG2 ) == FLAG1) ...
**
**  Each flag must be a an integer with exactly one bit set, e.g. a value
**  of the form (1 << i). Currently, 'i' must be in the range from 8 to
**  15 (inclusive).
*/

#define TEST_OBJ_FLAG(bag, flag) \
	(*(*(bag) + BAG_TNUM_OFFSET) & (flag))

#define SET_OBJ_FLAG(bag, flag) \
	(*(*(bag) + BAG_TNUM_OFFSET) |= (flag))

#define CLEAR_OBJ_FLAG(bag, flag) \
	(*(*(bag) + BAG_TNUM_OFFSET) &= ~(flag))


/****************************************************************************
**
*F  SIZE_BAG(<bag>) . . . . . . . . . . . . . . . . . . . . . . size of a bag
**
**  'SIZE_BAG( <bag> )'
**
**  'SIZE_BAG' returns  the  size of the bag   with the identifier  <bag> in
**  bytes.
**
**  Each bag has a  certain size.  The size  of a bag  is measured  in bytes.
**  The  size must  be a   value between   0 and $2^{24}-1$.  The application
**  specifies the size of a bag when it  allocates  it  with 'NewBag' and may
**  later change it with 'ResizeBag' (see "NewBag" and "ResizeBag").
**
**  Note that  'SIZE_BAG' is  a macro,  so do not call it with arguments that
**  have side effects.
*/
#ifdef USE_NEWSHAPE
#define SIZE_BAG(bag)   (*(*(bag)-2) >> 16)
#else
#define SIZE_BAG(bag)   (*(*(bag)-2))
#endif

/****************************************************************************
**
*F  SIZE_BAG_CONTENTS(<ptr>)  . . . . . . . . . . . . . . . . . size of a bag
**
**  'SIZE_BAG_CONTENTS' performs the same function as 'SIZE_BAG', but takes
**  a pointer to the contents of the bag instead. This is useful for certain
**  atomic operations that require a memory barrier in between dereferencing
**  the bag pointer and accessing the contents of the bag.
*/
#ifdef USE_NEWSHAPE
#define SIZE_BAG_CONTENTS(bag)   (*((UInt *)(bag)-2) >> 16)
#else
#define SIZE_BAG_CONTENTS(bag)   (*((UInt *)(bag)-2))
#endif


/****************************************************************************
**
*F  LINK_BAG(<bag>) . . . . . . . . . . . . . . . . . . . link field of a bag
**
**  TODO: document this
**
*/
#define LINK_BAG(bag)   (*(Bag *)(*(bag)-1))


/****************************************************************************
**
*F  PTR_BAG(<bag>)  . . . . . . . . . . . . . . . . . . . .  pointer to a bag
**
**  'PTR_BAG( <bag> )'
**
**  'PTR_BAG' returns the address of the data area of the bag with identifier
**  <bag>.  Using  this pointer the application  can then  read data from the
**  bag or write  data  into it.  The  pointer   is of  type pointer  to  bag
**  identifier, i.e., 'PTR_BAG(<bag>)[0]' is   the  identifier of the   first
**  subbag of the bag, etc.  If the bag contains  data in a different format,
**  the  application has  to  cast the pointer  returned  by 'PTR_BAG', e.g.,
**  '(long\*)PTR_BAG(<bag>)'.
**
**  Note  that the address  of the data area  of a  bag  may change  during a
**  garbage collection.  That is  the  value returned by 'PTR_BAG' may differ
**  between two calls, if 'NewBag', 'ResizeBag', 'CollectBags', or any of the
**  application\'s functions  or macros that may   call   those functions, is
**  called in between (see "NewBag", "ResizeBag", "CollectBags").
**
**  The first rule for using {\Gasman} is{\:} *The  application must not keep
**  any pointers to or into the data area of any  bag over calls to functions
**  that may cause a garbage collection.*
**
**  That means that the following code is incorrect{\:}
**
**      ptr = PTR_BAG( old );
**      new = NewBag( typeNew, sizeNew );
**      *ptr = new;
**
**  because  the creation of  the new bag may  move the  old bag, causing the
**  pointer to  point  no longer to  the  data area of  the bag.   It must be
**  written as follows{\:}
**
**      new = NewBag( typeNew, sizeNew );
**      ptr = PTR_BAG( old );
**      *ptr = new;
**
**  Note that even the following is incorrect{\:}
**
**      PTR_BAG(old)[0] = NewBag( typeNew, sizeNew );
**
**  because a C compiler is free to compile it to  a sequence of instructions
**  equivalent to first example.  Thus whenever  the evaluation of a function
**  or  a macro  may cause a  garbage collection  there  must be   no call to
**  'PTR_BAG' in the same expression, except as argument  to this function or
**  macro.
**
**  Note that  after writing   a bag  identifier,  e.g.,  'new' in the  above
**  example, into the  data area of another  bag, 'old' in the above example,
**  the application  must inform {\Gasman}  that it  has changed  the bag, by
**  calling 'CHANGED_BAG(old)' in the above example (see "CHANGED_BAG").
**
**  Note that 'PTR_BAG' is a macro, so  do  not call it with  arguments  that
**  have side effects.
*/
#define PTR_BAG(bag)    (*(Bag**)(bag))


/****************************************************************************
**
*F  CHANGED_BAG(<bag>)  . . . . . . . .  notify Gasman that a bag has changed
**
**  'CHANGED_BAG( <bag> )'
**
**  'CHANGED_BAG'  informs {\Gasman} that the bag   with identifier <bag> has
**  been changed by an assignment of another bag identifier.
**
**  The  second rule for using  {\Gasman} is{\:} *After  each assignment of a
**  bag identifier into a  bag the application  must inform {\Gasman} that it
**  has changed the bag before the next garbage collection can happen.*
**
**  Note that the  application need not inform {\Gasman}  if it changes a bag
**  by assigning something that is not an identifier of another bag.
**
**  For example to copy all entries from  one list into another the following
**  code must be used{\:}
**
**      for ( i = 0; i < SIZE-BAG(old)/sizeof(Bag); i++ )
**          PTR_BAG(new)[i] = PTR_BAG(old)[i];
**      CHANGED_BAG( new );
**
**  On the other  hand  when the  application  allocates a matrix,  where the
**  allocation of each row may cause a garbage collection, the following code
**  must be used{\:}
**
**      mat = NewBag( T_MAT, n * sizeof(Bag) );
**      for ( i = 0; i < n; i++ ) {
**          row = NewBag( T_ROW, n * sizeof(Bag) );
**          PTR_BAG(mat)[i] = row;
**          CHANGED_BAG( mat );
**      }
**
**  Note that  writing 'PTR_BAG(mat)[i] = NewBag( T_ROW, n\*\ sizeof(Bag) );'
**  is incorrect as mentioned in the section for 'PTR_BAG' (see "PTR_BAG").
**
**  Note that 'CHANGED_BAG' is a macro, so do not call it with arguments that
**  have side effects.
*/

#ifdef BOEHM_GC

#define CHANGED_BAG(bag) ((void) 0)

#else

extern  Bag *                   YoungBags;

extern  Bag                     ChangedBags;

/*****
**  MEMORY_CANARY provides (basic) support for catching out-of-bounds memory
**  problems in GAP. This is done through the excellent 'valgrind' program.
**  valgrind is of limited use in GAP normally, because it doesn't understand
**  GAP's memory manager. Enabling MEMORY_CANARY will make an executable where
**  valgrind will detect memory issues.
**
**  At the moment the detection is limited to only writing off the last allocated
**  block.
*/

#ifdef MEMORY_CANARY
extern void CHANGED_BAG_IMPL(Bag b);
#define CHANGED_BAG(bag) CHANGED_BAG_IMPL(bag);
#else
#define CHANGED_BAG(bag)                                                    \
                if (   PTR_BAG(bag) <= YoungBags                              \
                  && PTR_BAG(bag)[-1] == (bag) ) {                          \
                    PTR_BAG(bag)[-1] = ChangedBags; ChangedBags = (bag);    }

#endif // MEMORY_CANARY

#endif // BOEHM_GC


/****************************************************************************
**
*F  NewBag(<type>,<size>) . . . . . . . . . . . . . . . .  allocate a new bag
**
**  'NewBag( <type>, <size> )'
**
**  'NewBag' allocates a new bag  of type <type> and  <size> bytes.  'NewBag'
**  returns the  identifier  of the new  bag,  which must be  passed as first
**  argument to all other {\Gasman} functions.
**
**  <type> must be a  value  between 0 and 253.    The types 254 and  255 are
**  reserved for {\Gasman}.  The application can find the type  of a bag with
**  'TNUM_BAG'    and change   it  with  'RetypeBag'     (see  "TNUM_BAG" and
**  "RetypeBag").
**
**  It is probably a good idea to define symbolic constants  for all types in
**  a  system wide   header  file,  e.g.,  'types.h', if   only  to avoid  to
**  accidently use the same value for two different types.
**
**  <size> is the size of the new bag in bytes and must be a value  between 0
**  and $2^{24}-1$.  The   application can find  the    size  of a   bag with
**  'SIZE_BAG'    and  change   it  with  'ResizeBag'   (see   "SIZE_BAG" and
**  "ResizeBag").
**
**  If the initialization flag <dirty> is 0, all entries of  the new bag will
**  be initialized to 0; otherwise the  entries  of the  new bag will contain
**  random values (see "InitBags").
**
**  What  happens if {\Gasman}  cannot  get  enough  storage  to perform   an
**  allocation     depends on  the  behavior    of   the allocation  function
**  <alloc-func>.  If <alloc-func>  returns 0  when it   cannot do a   needed
**  extension  of  the  workspace, then 'NewBag'   may  return 0  to indicate
**  failure, and the  application has to check the  return  value of 'NewBag'
**  for this.  If <alloc-func> aborts when it cannot do a needed extension of
**  the workspace,  then the  application will  abort if  'NewBag' would  not
**  succeed.  So in  this case whenever 'NewBag'  returns,  it succeeded, and
**  the application need  not check    the return  value of 'NewBag'     (see
**  "InitBags").
**
**  Note that 'NewBag'  will perform a garbage collection  if no free storage
**  is available.  During  the  garbage  collection the addresses of the data
**  areas of all bags may  change.  So you  must not keep any  pointers to or
**  into the data areas of bags over calls to 'NewBag' (see "PTR_BAG").
*/
extern  Bag             NewBag (
            UInt                type,
            UInt                size );


/****************************************************************************
**
*F  RetypeBag(<bag>,<new>)  . . . . . . . . . . . .  change the type of a bag
**
**  'RetypeBag( <bag>, <new> )'
**
**  'RetypeBag' changes the type of the bag with identifier <bag>  to the new
**  type <new>.  The identifier, the size,  and also the  address of the data
**  area of the bag do not change.
**
**  'Retype' is usually  used to set or  reset  flags that are stored  in the
**  type of  a bag.   For  example in {\GAP}  there are  two  types of  large
**  integers, one for  positive integers and  one for negative  integers.  To
**  compute the difference of a positive integer and  a negative, {\GAP} uses
**  'RetypeBag'  to temporarily change   the second argument into  a positive
**  integer, and then adds the two operands.  For another example when {\GAP}
**  detects that a list is sorted and contains  no duplicates, it changes the
**  type  of the bag  with 'RetypeBag', and the new  type indicates that this
**  list has this property, so that this need not be tested again.
**
**  It is, as usual, the responsibility of the application to ensure that the
**  data stored in the bag makes sense when the  bag is interpreted  as a bag
**  of type <type>.
*/
extern  void            RetypeBag (
            Bag                 bag,
            UInt                new_type );

#ifdef HPCGAP
extern  void            RetypeBagIfWritable (
            Bag                 bag,
            UInt                new_type );
#else
#define RetypeBagIfWritable(x,y)     RetypeBag(x,y)
#endif

/****************************************************************************
**
*F  ResizeBag(<bag>,<new>)  . . . . . . . . . . . .  change the size of a bag
**
**  'ResizeBag( <bag>, <new> )'
**
**  'ResizeBag' changes the size of the bag with  identifier <bag> to the new
**  size <new>.  The identifier  of the bag  does not change, but the address
**  of the data area  of the bag  may change.  If  the new size <new> is less
**  than the old size,  {\Gasman} throws away any data  in the bag beyond the
**  new size.  If the new size  <new> is larger than  the old size, {\Gasman}
**  extends the bag.
**
**  If the initialization flag <dirty> is 0, all entries of an extension will
**  be initialized to 0; otherwise the  entries of an  extension will contain
**  random values (see "InitBags").
**
**  What happens  if {\Gasman} cannot   get   enough storage to  perform   an
**  extension depends   on   the   behavior   of the   allocation    function
**  <alloc-func>.  If <alloc-func>   returns 0 when   it cannot do a   needed
**  extension of the  workspace, then  'ResizeBag'  may return 0 to  indicate
**  failure, and the application has to check the return value of 'ResizeBag'
**  for this.  If <alloc-func> aborts when it cannot do a needed extension of
**  the workspace, then  the application will abort  if 'ResizeBag' would not
**  succeed.  So in this case whenever 'ResizeBag' returns, it succeeded, and
**  the application   need not check   the return value  of  'ResizeBag' (see
**  "InitBags").
**
**  Note   that  'ResizeBag' will  perform a garbage   collection  if no free
**  storage is available.  During the garbage collection the addresses of the
**  data areas of all bags may change.  So you must not keep  any pointers to
**  or into the data areas of bags over calls to 'ResizeBag' (see "PTR_BAG").
*/
extern  UInt            ResizeBag (
            Bag                 bag,
            UInt                new_size );


/****************************************************************************
**
*F  CollectBags(<size>,<full>)  . . . . . . . . . . . . . . collect dead bags
**
**  'CollectBags( <size>, <full> )'
**
**  'CollectBags' performs a  garbage collection.  This means  it deallocates
**  the dead   bags and  compacts the  live   bags at the  beginning   of the
**  workspace.   If    <full>  is 0, then   only   the  dead young  bags  are
**  deallocated, otherwise all dead bags are deallocated.
**
**  If the application calls 'CollectBags', <size> must be 0, and <full> must
**  be 0  or 1 depending on whether  it wants to perform  a partial or a full
**  garbage collection.
**
**  If 'CollectBags'  is called from  'NewBag' or 'ResizeBag',  <size> is the
**  size of the bag that is currently allocated, and <full> is zero.
**
**  Note that  during the garbage collection the  addresses of the data areas
**  of all bags may change.  So you must not keep any pointers to or into the
**  data areas of bags over calls to 'CollectBags' (see "PTR_BAG").
*/
extern  UInt            CollectBags (
            UInt                size,
            UInt                full );


/****************************************************************************
**
*F  SwapMasterPoint( <bag1>, <bag2> ) . . . swap pointer of <bag1> and <bag2>
*/
extern void SwapMasterPoint (
    Bag                 bag1,
    Bag                 bag2 );


/****************************************************************************
**
*V  NrAllBags . . . . . . . . . . . . . . . . .  number of all bags allocated
*V  SizeAllBags . . . . . . . . . . . . . .  total size of all bags allocated
*V  NrLiveBags  . . . . . . . . . .  number of bags that survived the last gc
*V  SizeLiveBags  . . . . . . .  total size of bags that survived the last gc
*V  NrDeadBags  . . . . . . . number of bags that died since the last full gc
*V  SizeDeadBags  . . . . total size of bags that died since the last full gc
**
**  'NrAllBags'
**
**  'NrAllBags' is the number of bags allocated since Gasman was initialized.
**  It is incremented for each 'NewBag' call.
**
**  'SizeAllBags'
**
**  'SizeAllBags'  is the  total  size  of bags   allocated since Gasman  was
**  initialized.  It is incremented for each 'NewBag' call.
**
**  'NrLiveBags'
**
**  'NrLiveBags' is the number of bags that were  live after the last garbage
**  collection.  So after a full  garbage collection it is simply  the number
**  of bags that have been found to be still live by this garbage collection.
**  After a partial garbage collection it is the sum of the previous value of
**  'NrLiveBags', which is the number  of live old  bags, and  the number  of
**  bags that  have been found to  be still live  by this garbage collection,
**  which is  the number of live   young  bags.   This  value  is used in the
**  information messages,  and to find  out  how  many  free  identifiers are
**  available.
**
**  'SizeLiveBags'
**
**  'SizeLiveBags' is  the total size of bags  that were  live after the last
**  garbage collection.  So after a full garbage  collection it is simply the
**  total size of bags that have been found to  be still live by this garbage
**  collection.  After  a partial  garbage  collection it  is the sum  of the
**  previous value of  'SizeLiveBags', which is the total   size of live  old
**  bags, and the total size of bags that have been found to be still live by
**  this garbage  collection,  which is  the  total size of  live young bags.
**  This value is used in the information messages.
**
**  'NrDeadBags'
**
**  'NrDeadBags' is  the number of bags that died since the last full garbage
**  collection.   So after a  full garbage  collection this is zero.  After a
**  partial  garbage  collection it  is  the  sum  of the  previous value  of
**  'NrDeadBags' and the  number of bags that  have been found to be dead  by
**  this garbage collection.  This value is used in the information messages.
**
**  'SizeDeadBags'
**
**  'SizeDeadBags' is  the total size  of bags that  died since the last full
**  garbage collection.  So  after a full   garbage collection this  is zero.
**  After a partial garbage collection it is the sum of the previous value of
**  'SizeDeadBags' and the total size of bags that have been found to be dead
**  by  this garbage  collection.   This  value  is used  in the  information
**  message.
**
**  'NrHalfDeadBags'
** 
**  'NrHalfDeadBags'  is  the number of  bags  that  have  been  found to  be
**  reachable only by way of weak pointers since the last garbage collection.
**  The bodies of these bags are deleted, but their identifiers are marked so
**  that weak pointer objects can recognize this situation.  
*/

extern  UInt                    NrAllBags;
extern  UInt                    SizeAllBags;
extern  UInt                    NrLiveBags;
extern  UInt                    SizeLiveBags;
extern  UInt                    NrDeadBags;
extern  UInt                    SizeDeadBags;
extern  UInt                    NrHalfDeadBags;


/****************************************************************************
**
*V  InfoBags[<type>]  . . . . . . . . . . . . . . . . .  information for bags
**
**  'InfoBags[<type>]'
**
**  'InfoBags[<type>]'  is a structure containing information for bags of the
**  type <type>.
**
**  'InfoBags[<type>].name' is the name of the type <type>.   Note that it is
**  the responsibility  of  the  application using  {\Gasman}   to enter this
**  name.
**
**  'InfoBags[<type>].nrLive' is the number of  bags of type <type> that  are
**  currently live.
**
**  'InfoBags[<type>].nrAll' is the total  number of all  bags of <type> that
**  have been allocated.
**
**  'InfoBags[<type>].sizeLive' is the sum of the  sizes of  the bags of type
**  <type> that are currently live.
**
**  'InfoBags[<type>].sizeAll'  is the sum of the  sizes of all  bags of type
**  <type> that have been allocated.
**
**  This  information is only  kept if {\Gasman} is  compiled with the option
**  '-DCOUNT_BAGS', e.g., with 'make <target> COPTS=-DCOUNT_BAGS'.
*/
typedef struct  {
    const Char *            name;
    UInt                    nrLive;
    UInt                    nrAll;
    UInt                    sizeLive;
    UInt                    sizeAll;
} TNumInfoBags;

extern  TNumInfoBags            InfoBags [ 256 ];


#ifdef HPCGAP
void MakeBagTypePublic(int type);
void MakeBagTypeProtected(int type);
Bag MakeBagPublic(Bag bag);
Bag MakeBagReadOnly(Bag bag);
#else
#define MakeBagTypePublic(type)     do { } while(0)
#define MakeBagTypeProtected(type)  do { } while(0)
#define MakeBagPublic(bag)          do { } while(0)
#define MakeBagReadOnly(bag)        do { } while(0)
#endif

/****************************************************************************
**
*F  InitMsgsFuncBags(<msgs-func>) . . . . . . . . .  install message function
**
**  'InitMsgsFuncBags( <msgs-func> )'
**
**  'InitMsgsFuncBags' installs the function <msgs-func> as function used  by
**  {\Gasman} to print messages during garbage collections.  <msgs-func> must
**  be a function of  three 'unsigned  long'  arguments <full>,  <phase>, and
**  <nr>.   <msgs-func> should format  this information and  display it in an
**  appropriate way.   In fact you will usually  want to ignore  the messages
**  for partial  garbage collections, since there are  so many  of those.  If
**  you do not install a  messages  function  with  'InitMsgsFuncBags',  then
**  'CollectBags' will be silent.
**
**  If <full> is 1, the current garbage collection is a full one.  If <phase>
**  is 0, the garbage collection has just started and  <nr> should be ignored
**  in this case.  If <phase> is 1 respectively 2, the garbage collection has
**  completed the mark phase  and <nr> is  the total number  respectively the
**  total  size of live bags.   If <phase> is  3  respectively 4, the garbage
**  collection  has completed  the  sweep  phase,   and <nr>  is   the number
**  respectively the total size of bags that died since the last full garbage
**  collection.  If <phase> is  5 respectively 6,  the garbage collection has
**  completed the check phase   and <nr> is    the size of the free   storage
**  respectively the size of the workspace.  All sizes are measured in KByte.
**
**  If  <full> is 0,  the current garbage  collection  is a  partial one.  If
**  <phase> is 0, the garbage collection has just  started and <nr> should be
**  ignored  in  this  case.  If  <phase>  is 1  respectively 2,  the garbage
**  collection  has   completed the  mark   phase  and  <nr>   is the  number
**  respectively the  total size  of bags allocated  since  the last  garbage
**  collection that  are still  live.   If <phase> is  3 respectively  4, the
**  garbage collection has completed  the sweep phase and  <nr> is the number
**  respectively the   total size of   bags allocated since  the last garbage
**  collection that are already dead (thus the sum of the values from phase 1
**  and 3  is the  total number of   bags  allocated since the  last  garbage
**  collection).  If <phase> is 5 respectively 6,  the garbage collection has
**  completed the  check phase  and <nr>  is   the size of  the  free storage
**  respectively the size of the workspace.  All sizes are measured in KByte.
**
**  The message  function  should display   the information  for each   phase
**  immediatly, i.e.,  by calling 'flush' if the  output device is a file, so
**  that the user has some indication how much time each phase used.
**
**  For example {\GAP} displays messages for  full garbage collections in the
**  following form{\:}
**
**    #G  FULL  47601/ 2341KB live  70111/ 5361KB dead   1376/ 4096KB free
**
**  where 47601 is the total number of bags surviving the garbage collection,
**  using 2341 KByte, 70111 is  the total number  of bags that died since the
**  last full garbage  collection, using 5361  KByte, 1376 KByte are free and
**  the total size of the workspace is 4096 KByte.
**
**  And partial garbage collections are displayed in  {\GAP} in the following
**  form{\:}
**
**    #G  PART     34/   41KB+live   3016/  978KB+dead   1281/ 4096KB free
**
**  where  34 is the  number of young bags that  were live after this garbage
**  collection, all the old bags survived it  anyhow, using 41 KByte, 3016 is
**  the number of young bags that died since  the last garbage collection, so
**  34+3016 is the  number  of bags allocated  between  the last two  garbage
**  collections, using 978 KByte and the other two numbers are as above.
*/
typedef void            (* TNumMsgsFuncBags) (
            UInt                full,
            UInt                phase,
            Int                 nr );

extern  void            InitMsgsFuncBags (
            TNumMsgsFuncBags    msgs_func );


/****************************************************************************
**
*F  InitMarkFuncBags(<type>,<mark-func>)  . . . . .  install marking function
*F  MarkNoSubBags(<bag>)  . . . . . . . . marking function that marks nothing
*F  MarkOneSubBags(<bag>) . . . . . .  marking function that marks one subbag
*F  MarkTwoSubBags(<bag>) . . . . . . marking function that marks two subbags
*F  MarkAllSubBags(<bag>) . . . . . .  marking function that marks everything
*F  MARK_BAG(<bag>) . . . . . . . . . . . . . . . . . . .  mark a bag as live
**
**  'InitMarkFuncBags( <type>, <mark-func> )'
**
**  'InitMarkFuncBags' installs the function <mark-func>  as marking function
**  for bags  of  type <type>.   The  application  *must* install  a  marking
**  function for a  type before it allocates  any  bag  of  that type.  It is
**  probably best to install all marking functions before allocating any bag.
**
**  A marking function  is a function  that takes a  single  argument of type
**  'Bag' and returns nothing, i.e., has return type 'void'.  Such a function
**  must apply the  macro 'MARK_BAG' to each bag  identifier that  appears in
**  the bag (see below).
**
**  Those functions are applied during the garbage  collection to each marked
**  bag, i.e., bags  that are assumed to be  still live,  to also mark  their
**  subbags.  The ability to use the correct marking function is the only use
**  that {\Gasman} has for types.
**
**  'MARK_BAG( <bag> )'
**
**  'MARK_BAG' marks the <bag> as live so that it is  not thrown away during
**  a garbage collection.  'MARK_BAG' should only be called from the marking
**  functions installed with 'InitMarkFuncBags'.
**
**  'MARK_BAG' tests  if <bag> is  a valid identifier of a  bag  in the young
**  bags  area.  If it is not,  then 'MARK_BAG' does nothing,  so there is no
**  harm in  calling 'MARK_BAG' for  something   that is not actually  a  bag
**  identifier.
**
**  Note that 'MARK_BAG' is a macro, so do not call it with an argument that
**  has side effects.
**
**  'MarkBagWeakly( <bag> )'
**
**  'MarkBagWeakly' is an alternative to MARK_BAG, intended to be used by the
**  marking functions  of weak pointer objects.  A  bag which is  marked both
**  weakly and strongly  is treated as strongly marked.   A bag which is only
**  weakly marked will be recovered by garbage collection, but its identifier
**  remains, marked      in   a    way    which   can     be   detected    by
**  "IS_WEAK_DEAD_BAG". Which should  always be   checked before copying   or
**  using such an identifier.
**
**
**  {\Gasman} already provides the following marking functions.
**
**  'MarkNoSubBags( <bag> )'
**
**  'MarkNoSubBags'  is a marking function   for types whose  bags contain no
**  identifier of other   bags.  It does nothing,  as  its name implies,  and
**  simply returns.  For example   in  {\GAP} the  bags for   large  integers
**  contain only the digits and no identifiers of bags.
**
**  'MarkOneSubBags( <bag> )'
**
**  'MarkOneSubBags'  is  a  marking  function for types   whose bags contain
**  exactly one identifier of another bag as  the first entry.  It marks this
**  subbag and returns.  For example in {\GAP} bags for finite field elements
**  contain exactly one  bag  identifier  for the  finite field   the element
**  belongs to.
**
**  'MarkTwoSubBags( <bag> )'
**
**  'MarkTwoSubBags' is  a  marking function   for types  whose bags  contain
**  exactly two identifiers of other bags as  the first and second entry such
**  as the binary operations bags.  It marks those  subbags and returns.  For
**  example  in {\GAP}  bags for  rational   numbers contain exactly two  bag
**  identifiers for the numerator and the denominator.
**
**  'MarkAllSubBags( <bag> )'
**
**  'MarkAllSubBags'  is  the marking function  for  types whose bags contain
**  only identifier of other bags.  It marks every entry of such a bag.  Note
**  that 'MarkAllSubBags' assumes that  all  identifiers are at offsets  from
**  the    address of the    data area   of  <bag>   that  are divisible   by
**  'sizeof(Bag)'.  Note also that since   it does not do   any harm to  mark
**  something   which  is not    actually a   bag identifier  one   could use
**  'MarkAllSubBags' for all  types  as long as  the identifiers  in the data
**  area are  properly aligned as  explained above.  This  would however slow
**  down 'CollectBags'.  For example  in {\GAP} bags  for lists contain  only
**  bag identifiers for the elements  of the  list or 0   if an entry has  no
**  assigned value.
** */


typedef void            (* TNumMarkFuncBags ) (
            Bag                 bag );

extern  void            InitMarkFuncBags (
            UInt                type,
            TNumMarkFuncBags    mark_func );

extern  void            MarkNoSubBags (
            Bag                 bag );

extern  void            MarkOneSubBags (
            Bag                 bag );

extern  void            MarkTwoSubBags (
            Bag                 bag );

extern  void            MarkThreeSubBags (
            Bag                 bag );

extern  void            MarkFourSubBags (
            Bag                 bag );

extern  void            MarkAllSubBags (
            Bag                 bag );

extern void             MarkBagWeakly (
            Bag                 bag );

extern  Bag *                   MptrBags;
extern  Bag *                   OldBags;
extern  Bag *                   AllocBags;
extern  Bag                     MarkedBags;

#define MARKED_DEAD(x)  (x)
#define MARKED_ALIVE(x) ((Bag)(((Char *)(x))+1))
#define MARKED_HALFDEAD(x) ((Bag)(((Char *)(x))+2))
#define IS_MARKED_ALIVE(bag) ((PTR_BAG(bag)[-1]) == MARKED_ALIVE(bag))
#define IS_MARKED_DEAD(bag) ((PTR_BAG(bag)[-1]) == MARKED_DEAD(bag))
#define IS_MARKED_HALFDEAD(bag) ((PTR_BAG(bag)[-1]) == MARKED_HALFDEAD(bag))
#define UNMARKED_DEAD(x)  (x)
#define UNMARKED_ALIVE(x) ((Bag)(((Char *)(x))-1))
#define UNMARKED_HALFDEAD(x) ((Bag)(((Char *)(x))-2))


#ifndef BOEHM_GC

#define MARK_BAG(bag)                                                       \
                if ( (((UInt)(bag)) & (sizeof(Bag)-1)) == 0                 \
                  && (Bag)MptrBags <= (bag)    && (bag) < (Bag)OldBags      \
                  && YoungBags < PTR_BAG(bag)  && PTR_BAG(bag) <= AllocBags \
                  && (IS_MARKED_DEAD(bag) || IS_MARKED_HALFDEAD(bag)) ) \
                  {                                                          \
                    PTR_BAG(bag)[-1] = MarkedBags; MarkedBags = (bag);      }

#else

/* MARK_BAG does nothing when using Boehm GC. We use sizeof(bag) to
   prevent compiler warnings about unused variables (note that sizeof
   "usually" does not evaluate its arguments, so this is safe.
*/
#define MARK_BAG(bag)   do { } while(0 == sizeof(bag));

#endif

extern void MarkAllSubBagsDefault ( Bag );


/****************************************************************************
**
*F
*/

#ifndef BOEHM_GC
#define IS_WEAK_DEAD_BAG(bag) ( (((UInt)bag & (sizeof(Bag)-1)) == 0) && \
                                (Bag)MptrBags <= (bag)    &&          \
                                (bag) < (Bag)OldBags  &&              \
                                (((UInt)*bag) & (sizeof(Bag)-1)) == 1)
#else
#define IS_WEAK_DEAD_BAG(bag) (!(bag))
#define REGISTER_WP(loc, obj) \
	GC_general_register_disappearing_link((void **)(loc), (obj))
#define FORGET_WP(loc) \
	GC_unregister_disappearing_link((void **)(loc))
#endif
             
/****************************************************************************
**
*F  InitSweepFuncBags(<type>,<sweep-func>)  . . . . install sweeping function
**
**  'InitSweepFuncBags( <type>, <sweep-func> )'
**
**  'InitSweepFuncBags' installs the function <sweep-func> as sweeping
**  function for bags of type <type>.  
**
**  A sweeping function is a function that takes two arguments src and dst of
**  type Bag *, and  a third, length of type  UInt, and returns nothing. When
**  it  is called, src points to  the start of the data  area of one bag, and
**  dst to another. The function should copy the  data from the source bag to
**  the destination, making any appropriate changes.
**
**  Those functions are applied during  the garbage collection to each marked
**  bag, i.e., bags that are assumed  to be still live  to move them to their
**  new  position. The  intended  use is  for  weak  pointer bags, which must
**  remove references to identifiers of  any half-dead objects. 
**
**  If no function  is installed for a TNum,  then the data is  simply copied
**  unchanged and this is done particularly quickly 
*/

typedef void            (* TNumSweepFuncBags ) (
            Bag  *               src,
            Bag *                dst,
            UInt                 length);

extern  void            InitSweepFuncBags (
            UInt                tnum,
            TNumSweepFuncBags    sweep_func );
 

#ifdef BOEHM_GC
typedef void 		(* FinalizerFunction) (
	    Bag bag );

extern void		InitFinalizerFuncBags (
	    UInt		tnum,
	    FinalizerFunction finalizer_func );
#endif

/****************************************************************************
**
*V  GlobalBags  . . . . . . . . . . . . . . . . . . . . . list of global bags
*/
#ifndef NR_GLOBAL_BAGS
#define NR_GLOBAL_BAGS  20000L
#endif


typedef struct {
    Bag *                   addr [NR_GLOBAL_BAGS];
    const Char *            cookie [NR_GLOBAL_BAGS];
    UInt                    nr;
} TNumGlobalBags;

extern TNumGlobalBags GlobalBags;


/****************************************************************************
**
*F  InitGlobalBag(<addr>) . . . . . inform Gasman about global bag identifier
**
**  'InitGlobalBag( <addr>, <cookie> )'
**
**  'InitGlobalBag'  informs {\Gasman} that there is  a bag identifier at the
**  address <addr>, which must be of  type '(Bag\*)'.  {\Gasman} will look at
**  this address for a bag identifier during a garbage collection.
**
**  The application *must* call 'InitGlobalBag' for every global variable and
**  every entry of a  global array that may hold  a bag identifier.  It is no
**  problem  if  such a  variable does not   actually  hold a bag identifier,
**  {\Gasman} will simply ignore it then.
**
**  There is a limit on the number of calls to 'InitGlobalBag', which is 512
**  by default.   If the application has  more global variables that may hold
**  bag  identifier, you  have to  compile  {\Gasman} with a  higher value of
**  'NR_GLOBAL_BAGS', i.e., with 'make COPTS=-DNR_GLOBAL_BAGS=<nr>'.
**
**  <cookie> is a C string, which should uniquely identify this global
**  bag from all others.  It is used  in reconstructing  the Workspace
**  after a save and load
*/

extern Int WarnInitGlobalBag;

extern void InitGlobalBag (
            Bag *               addr,
            const Char *        cookie );

extern void SortGlobals( UInt byWhat );

extern Bag * GlobalByCookie(
            const Char *        cookie );


extern void StartRestoringBags( UInt nBags, UInt maxSize);


extern Bag NextBagRestoring( UInt size,  UInt type);


extern void FinishedRestoringBags( void );



/****************************************************************************
**
*F  InitFreeFuncBag(<type>,<free-func>) . . . . . .  install freeing function
**
**  'InitFreeFuncBag( <type>, <free-func> )'
**
**  'InitFreeFuncBag' installs  the function <free-func>  as freeing function
**  for bags of type <type>.
**
**  A freeing function is  a function that  takes  a single argument of  type
**  'Bag' and  returns nothing,  i.e., has return  type  'void'.  If  such  a
**  function is installed for a type <type> then it is called for each bag of
**  that type that is about to be deallocated.
**
**  A freeing function must *not* call 'NewBag', 'ResizeBag', or 'RetypeBag'.
**
**  When such  a function is  called for a bag <bag>,  its subbags  are still
**  accessible.  Note that it it not specified, whether the freeing functions
**  for the subbags of   <bag> (if there   are freeing functions for  bags of
**  their types) are called before or after the freeing function for <bag>.
*/
typedef void            (* TNumFreeFuncBags ) (
            Bag                 bag );

extern  void            InitFreeFuncBag (
            UInt                type,
            TNumFreeFuncBags    free_func );


/****************************************************************************
**
*F  InitCollectFuncBags(<bfr-func>,<aft-func>) . install collection functions
**
**  'InitCollectFuncBags( <before-func>, <after-func> )'
**
**  'InitCollectFuncBags' installs       the   functions  <before-func>   and
**  <after-func> as collection functions.
**
**  The  <before-func> will be  called   before each garbage collection,  the
**  <after-func>  will be called after each  garbage  collection.  One use of
**  the   <before-func> is to  call 'CHANGED_BAG'  for bags  that change very
**  often, so you do not have to call 'CHANGED_BAG'  for them every time they
**  change.  One use of the <after-func> is to update a pointer for a bag, so
**  you do not have to update that pointer after every operation that might
**  cause a garbage collection.
*/
typedef void            (* TNumCollectFuncBags) ( void );

extern  void            InitCollectFuncBags (
            TNumCollectFuncBags before_func,
            TNumCollectFuncBags after_func );


/****************************************************************************
**
*F  CheckMasterPointers() . . . . . . . . . . . . .do some consistency checks
**
**  'CheckMasterPointers()' tests for masterpoinetrs which are not one of the
**  following:
**
**  0                       denoting the end of the free chain
**  NewWeakDeadBagMarker    denoting the relic of a bag that was weakly
**  OldWeakDeadBagMarker    but not strongly linked at the last garbage
**                          collection
**  a pointer into the masterpointer area   a link on the free chain
**  a pointer into the bags area            a real object
**
*/

extern void CheckMasterPointers( void );

/****************************************************************************
**
*F  InitBags(...) . . . . . . . . . . . . . . . . . . . . . initialize Gasman
**
**  InitBags( <alloc-func>, <initial-size>,
**            <stack-func>, <stack-start>, <stack-align>,
**            <dirty>, <abort-func> )
**
**  'InitBags'  initializes {\Gasman}.  It  must be called from a application
**  using {\Gasman} before any bags can be allocated.
**
**  <alloc-func> must  be the function that  {\Gasman}  uses to  allocate the
**  initial workspace and to extend the workspace.  It must accept two 'long'
**  arguments  <size> and <need>.   <size> is  the amount of  storage that it
**  must allocate, and <need>  indicates  whether {\Gasman} really needs  the
**  storage or only wants it to have a reasonable amount of free storage.
**
**  *Currently   this function must  return    immediately adjacent areas  on
**  subsequent  calls*.  So 'sbrk'  will  work on most  systems, but 'malloc'
**  will not.
**
**  If  <need> is 0,  <alloc-func> must  either  return  the  address of  the
**  extension to indicate success or return  0 if it  cannot or does not want
**  to extend the workspace.  If <need>  is 1, <alloc-func> must again return
**  the address of the extension to indicate success and can either  return 0
**  or abort if it cannot or does not  want  to  extend the workspace.   This
**  choice determines  whether  'NewBag'  and  'ResizeBag' may  fail.  If  it
**  returns 0, then  'NewBag' and  'ResizeBag' can fail.  If  it aborts, then
**  'NewBag' and 'ResizeBag' can never fail (see "NewBag" and "ResizeBag").
**
**  <size>  may also be   negative if {\Gasman} has   a large amount  of free
**  space, and wants to return  some of it  to the operating system.  In this
**  case <need>   will  always be  0.   <alloc-func>  can either  accept this
**  reduction of  the  workspace and return  a nonzero  value  and return the
**  storage to the operating system, or refuse this reduction and return 0.
**
**  <initial-size> must be the size of  the initial workspace that 'InitBags'
**  should allocate.  This   value is automatically rounded   up to the  next
**  multiple of 1/2 MByte by 'InitBags'.
**
**  <stack-func>  must be   a    function    that  applies  'MARK_BAG'   (see
**  "InitMarkFuncBags") to each possible bag identifier on the application\'s
**  stack, i.e., the stack where the applications local variables  are saved.
**  This should be a function of no  arguments  and return type 'void'.  This
**  function   is  called  from  'CollectBags'  to  mark   all bags  that are
**  accessible from  local variables.   There  is a generic function for this
**  purpose, which is called  when the application passes  0 as <stack-func>,
**  which will work all right on most machines, but *may* fail on some of the
**  more exotic machines.
**
**  If the application passes 0 as value for <stack-func>, <stack-start> must
**  be the start of the stack.   Note that the  start of the  stack is either
**  the bottom or the top of the stack, depending  on whether the stack grows
**  upward  or downward.  A  value that usually works is  the address  of the
**  argument  'argc'   of the  'main' function    of the  application,  i.e.,
**  '(Bag\*)\&argc'.  If  the application   provides  another   <stack-func>,
**  <stack-start> is ignored.
**
**  If the application passes 0 as value for <stack-func>, <stack-align> must
**  be  the alignment  of items  of  type 'Bag' on the  stack.   It must be a
**  divisor of 'sizeof(Bag)'.  The addresses of  all identifiers on the stack
**  must be a multiple  of <stack-align>.  So if  it is 1, identifiers may be
**  anywhere on the stack, and  if it is  'sizeof(Bag)', identifiers may only
**  be at addresses that are a multiple of 'sizeof(Bag)'.  This value depends
**  on  the   machine,  the  operating system,   and   the compiler.   If the
**  application provides another <stack-func>, <stack-align> is ignored.
**
**  The initialization  flag  <dirty> determines  whether  bags allocated  by
**  'NewBag' are initialized to contain only 0 or not.   If <dirty> is 0, the
**  bags are  initialized to  contain only 0.    If  <dirty> is  1, the  bags
**  initially contain  random values.  Note that {\Gasman}  will be  a little
**  bit faster if bags need not be initialized.
**
**  <abort-func> should be a function that {\Gasman} should call in case that
**  something goes  wrong, e.g.,     if it  cannot allocation    the  initial
**  workspace.  <abort-func> should be a function of one string argument, and
**  it  might want to display this   message before aborting the application.
**  This function should never return.
*/
typedef Bag *           (* TNumAllocFuncBags) (
                                Int             size,
                                UInt            need );

typedef void            (* TNumStackFuncBags) ( void );

typedef void            (* TNumAbortFuncBags) (
                                const Char *    msg );

extern  void            InitBags (
            TNumAllocFuncBags   alloc_func,
            UInt                initial_size,
            TNumStackFuncBags   stack_func,
            Bag *               stack_bottom,
            UInt                stack_align,
            UInt                dirty,
            TNumAbortFuncBags   abort_func );

/****************************************************************************
**
*F  FinishBags() end GASMAN and free memory
*/

extern void FinishBags( void );

/****************************************************************************
**
*F  CallbackForAllBags( <func> ) call a C function on all non-zero mptrs
**
** This calls a   C  function on every    bag, including ones  that  are  not
** reachable from    the root, and    will  be deleted  at the   next garbage
** collection, by simply  walking the masterpointer area. Not terribly safe
** 
*/

extern void CallbackForAllBags(
     void (*func)(Bag) );

#ifdef HPCGAP

typedef struct
{
    void *lock;       /* void * so that we don't have to include pthread.h always */
    Bag obj;          /* references a unique T_REGION object per region */
    Bag name;         /* name of the region, or a null pointer */
    Int prec;         /* locking precedence */
    int fixed_owner;
    void *owner;      /* opaque thread descriptor */
    void *alt_owner;  /* for paused threads */
    int count_active; /* whether we counts number of (contended) locks */
    AtomicUInt locks_acquired;    /* number of times the lock was acquired successfully */
    AtomicUInt locks_contended;   /* number of failed attempts at acuiring the lock */
    unsigned char readers[];     /* this field extends with number of threads
                                     don't add any fields after it */
} Region;

/****************************************************************************
**
*F  NewRegion() . . . . . . . . . . . . . . . . allocate a new region
*/

Region *NewRegion(void);

/****************************************************************************
**
*F  REGION(<bag>)  . . . . . . . .  return the region containing the bag
*F  RegionBag(<bag>)   . . . . . .  return the region containing the bag
**
**  RegionBag() also contains a memory barrier.
*/
#define REGION(bag) (((Region **)(bag))[1])

Region *RegionBag(Bag bag);

#endif // HPCGAP


#ifdef BOEHM_GC
void *AllocateMemoryBlock(UInt size);
#endif

#endif // GAP_GASMAN_H

/****************************************************************************
**

*E  gasman.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
