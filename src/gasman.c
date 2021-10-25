/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains  the functions of  Gasman,  the  GAP  storage manager.
**
**  {\Gasman} is a storage manager for applications written in C.  That means
**  that  an application  using {\Gasman}  requests  blocks  of  storage from
**  {\Gasman}.   Those   blocks of  storage are    called  *bags*.  Then  the
**  application writes data into and reads data from the bags.  Finally a bag
**  is no longer needed  and the application  simply forgets it.  We say that
**  such a bag that is no longer needed is *dead*.  {\Gasman} cares about the
**  allocation of bags and deallocation of  dead bags.  Thus these operations
**  are  transparent    to  the application,  enabling   the    programmer to
**  concentrate on algorithms instead of caring  about storage allocation and
**  deallocation.
**
**  {\Gasman} implements an automatic, cooperating, compacting, generational,
**  conservative storage management
**
**  *Automatic* means that the application only allocates  bags.  It need not
**  explicitly  deallocate them.    {\Gasman} automatically determines  which
**  bags are  dead and deallocates them.  This   is done by a  process called
**  *garbage  collection*.   Garbage refers to   the bags that  are dead, and
**  collection refers to the process of deallocating them.
**
**  *Cooperating* means  that the application  must cooperate with {\Gasman},
**  that is it must follow two rules.  One rule is that  it must not remember
**  the addresses of the data area of a bag for  too long.  The other rule is
**  that it must inform {\Gasman} when it has changed a bag.
**
**  *Compacting* means that after a garbage collection {\Gasman} compacts the
**  bags  that are   still  live,  so  that the  storage  made  available  by
**  deallocating the dead  bags  becomes one  large  contiguous  block.  This
**  helps to avoid *fragmentation* of the free storage.  The downside is that
**  the address of  the data  area  of a  bag  may  change during  a  garbage
**  collection,  which is the  reason why  the  application must not remember
**  this address for too long,  i.e., must not keep  pointers to or into  the
**  data area of a bag over a garbage collection.
**
**  *Generational*  means that {\Gasman}  distinguishes between old and young
**  bags.  Old bags have been allocated some time ago, i.e., they survived at
**  least one garbage collection.  During a garbage collection {\Gasman} will
**  first find and  deallocate the dead young  bags.   Only if that  does not
**  produce enough free storage, {\Gasman} will find  and deallocate the dead
**  old  bags.  The idea behind this  is that usually most  bags  have a very
**  short life, so  that  they will die young.    The downside is that   this
**  requires {\Gasman} to quickly  find  the young  bags that are  referenced
**  from   old bags, which  is  the  reason  why  an  application must inform
**  {\Gasman} when it has changed a bag.
**
**  *Conservative* means that there are  situations in which {\Gasman} cannot
**  decide with  absolute certainty whether  a bag is   still live or already
**  dead.  In these situations {\Gasman} has to  assume that the bag is still
**  live, and may thus keep a bag longer than it is necessary.
**
**  What follows describes the reasons for this  design, and at the same time
**  the assumptions that were  made about the application.   This is given so
**  you can make an educated guess as to whether  {\Gasman} is an appropriate
**  storage manager for your application.
**
**  {\Gasman} is automatic, because  this makes it  easier to use in large or
**  complex applications.  Namely in with a non-automatic storage manager the
**  application must  decide when  to  deallocate  a  bag.  This  requires in
**  general global knowledge, i.e., it is not sufficient  to know whether the
**  current function may still need  the bag, one also  needs to know whether
**  any  other  function may  still   need the   bag.  With growing   size or
**  complexity of the application it gets harder to obtain this knowledge.
**
**  {\Gasman} is cooperating,  because this is  a requirement  for compaction
**  and generations (at least without cooperation, compaction and generations
**  are very  difficult).  As described  below, the  former is  important for
**  storage efficiency,   the  latter for  time efficiency.     Note that the
**  cooperation requires only local knowledge, i.e., whether or not a certain
**  function of the application follows the two  rules can be decided by just
**  looking   at the function  without any  knowledge about the   rest of the
**  application.
**
**  {\Gasman} is  compacting, because this allows the  efficient usage of the
**  available storage by applications where the ratio between the size of the
**  smallest   and the largest bag is   large.   Namely with a non-compacting
**  storage manager,  a  part  of  the free  storage   may become unavailable
**  because it is fragmented into  many small pieces,  each  of which is  too
**  small to serve an allocation.
**
**  {\Gasman} is generational,  because this  makes it  very much faster,  at
**  least  for those  applications where   most bags  will indeed  die young.
**  Namely a non-generational storage manager must test  for each bag whether
**  or  not it  is still live  during  each garbage collection.  However with
**  many applications  the probability   that  an  old bag,  i.e.,  one  that
**  survived at least one  garbage  collection, will  also survive  the  next
**  garbage  collection  is  high.   A  generational  storage manager  simply
**  assumes that each old bag is still  live during most garbage collections.
**  Thereby it avoids  the expensive tests for most  bags during most garbage
**  collections.
**
**  {\Gasman}  is conservative, because  for most applications  only few bags
**  are incorrectly  assumed to be still live  and the additional cooperation
**  required   to make  {\Gasman} (more)     precise   would slow down    the
**  application.  Note that the problem appears since the C compiler provides
**  not enough information to distinguish between true references to bags and
**  other values  that just happen to look  like  references.  Thus {\Gasman}
**  has to assume that everything that could be interpreted as a reference to
**  a bag  is  indeed such  a reference, and  that  this bag is  still  live.
**  Therefore  some bags  may  be  kept by  {\Gasman}, even   though they are
**  already dead.
*/

#include "gasman.h"
#include "gasman_intern.h"

#include "error.h"
#include "gaptime.h"
#include "gaputils.h"
#include "io.h"
#include "sysfiles.h"
#include "sysmem.h"
#include "sysstr.h"

#include "bags.inc"

#include "config.h"

#include <setjmp.h>
#include <string.h>

#ifdef GAP_MEM_CHECK
#include <sys/mman.h>
#endif

/****************************************************************************
**
*F  WORDS_BAG( <size> ) . . . . . . . . . . words used by a bag of given size
**
**  The structure of a bag is a follows{\:}
**
**    <identifier>
**      __/
**     /
**    V
**    +---------+
**    |<masterp>|
**    +---------+
**          \________________________
**                                   \
**                                    V
**    +------+-------+------+---------+--------------------------------+----+
**    |<size>|<flags>|<type>|  <link> |         .         .         ...| pad|
**    +------+-------+------+---------+--------------------------------+----+
**
**  A bag consists of a masterpointer, and a body.
**
**  The *masterpointer* is a pointer  to the data  area of the bag.  During a
**  garbage collection  the masterpointer is the  only active  pointer to the
**  data area of the bag, because of the rule that no pointers to or into the
**  data  area of a  bag may be remembered  over calls  to functions that may
**  cause a garbage  collection.  It is the job  of the garbage collection to
**  update the masterpointer of a bag when it moves the bag.
**
**  The *identifier*  of  the  bag is a   pointer  to (the  address   of) the
**  masterpointer  of  the bag.   Thus   'PTR_BAG(<bag>)' is simply '\*<bag>'
**  plus a cast.
**
**  The *body* of a bag consists of a header, the data area, and the padding.
**
**  The header in turn consists of the *type byte*, *flags byte* and the
**  *size field*, which is either 32 bits or 48 bits (on 32 resp. 64 bit systems),
**  followed by a link word.  The 'BagHeader' struct describes the exact
**  structure of the header.
**
**  The  *link word* usually   contains the identifier of  the  bag,  i.e., a
**  pointer to the masterpointer of the bag.  Thus the garbage collection can
**  find  the masterpointer of a  bag through the link  word if  it knows the
**  address of the  data area of the bag.    The link word   is also used  by
**  {\Gasman} to  keep   bags  on  two linked  lists  (see  "ChangedBags" and
**  "MarkedBags").
**
**  The *data area* of a  bag is the area  that  contains the data stored  by
**  the application in this bag.
**
**  The *padding* consists  of up to 'sizeof(Bag)-1' bytes  and pads the body
**  so that the size of a  body is always  a multiple of 'sizeof(Bag)'.  This
**  is to ensure that bags are always aligned.  The macro 'WORDS_BAG(<size>)'
**  returns the number  of words occupied  by the data  area and padding of a
**  bag of size <size>.
**
**  A body in the workspace whose type byte contains the value T_DUMMY is the
**  remainder of a 'ResizeBag'. That is it consists either of the unused words
**  after a bag has been shrunk, or of the old body of the bag after the
**  contents of the body have been copied elsewhere for an extension. The
**  size field in the bag header contains the number of bytes in
**  this area excluding the first word itself. Note that such a body  has no
**  link  word, because such a remainder does not correspond to a bag (see
**  "Implementation of ResizeBag").
**
**  A masterpointer with a value  congruent to 1  mod 4 is   the relic of  an
**  object  that was  weakly but not   strongly  marked in  a recent  garbage
**  collection.   These persist until  after the next full garbage collection
**  by which time all references to them should have been removed.
**
*/

enum {
    SIZE_MPTR_BAGS = 1,

    T_DUMMY = NUM_TYPES - 1,
};


// BAG_SLACK is used to define a block of empty space at the end of each
// bag, which can then be marked as "not accessible" in the memory checker
// Valgrind

enum { BAG_SLACK = 0 };

// TIGHT_WORDS_BAG defines the actual amount of space a Bag requires,
// without BAG_SLACK.
static inline UInt TIGHT_WORDS_BAG(UInt size)
{
    return (size + sizeof(Bag) - 1) / sizeof(Bag);
}

static inline UInt WORDS_BAG(UInt size)
{
    return TIGHT_WORDS_BAG(size) + BAG_SLACK;
}

static inline Bag *DATA(BagHeader *bag)
{
    return (Bag *)(bag + 1);
}


/****************************************************************************
**
*V  MptrBags  . . . . . . . . . . . . . . beginning of the masterpointer area
*V  MptrEndBags  . . . . . . . . . . . . . . .  end of the masterpointer area
*V  OldBags . . . . . . . . . . . . . . . . .  beginning of the old bags area
*V  YoungBags . . . . . . . . . . . . . . .  beginning of the young bags area
*V  AllocBags . . . . . . . . . . . . . . .  beginning of the allocation area
*V  AllocSizeBags . . . . . . . . . . . . . . . . size of the allocation area
*V  EndBags . . . . . . . . . . . . . . . . . . . . . .  end of the workspace
**
**  {\Gasman} manages one large block of storage called the *workspace*.  The
**  layout of the workspace is as follows{\:}
**
**  +----------------+----------+----------+-----------------+--------------+
**  |  masterpointer |  unused  | old bags |   young bags    |  allocation  |
**  |      area      |   area   |   area   |      area       |     area     |
**  +----------------+----------+----------+-----------------+--------------+
**  ^                ^          ^          ^                 ^              ^
**  MptrBags    MptrEndBags  OldBags   YoungBags         AllocBags    EndBags
**
**  The *masterpointer area*  contains  all the masterpointers  of  the bags.
**  'MptrBags' points to the beginning of this area and 'MptrEndBags' to the
**  end.
**
**  Between MptrEndBags and OldBags is an *unused area*. This exists so the
**  master points, and bags area, can be moved independently. MptrEndBags
**  will always come earlier in memory than OldBags. GASMAN should not touch
**  this memory, as it may be used for other purposes.
**
**  The *old bags area* contains the bodies of all the  bags that survived at
**  least one  garbage collection.  This area is  only  scanned for dead bags
**  during a full garbage collection.  'OldBags'  points to the  beginning of
**  this area and 'YoungBags' to the end.
**
**  The *young bags area* contains the bodies of all  the bags that have been
**  allocated since the  last garbage collection.  This  area is scanned  for
**  dead  bags during  each garbage  collection.  'YoungBags'  points  to the
**  beginning of this area and 'AllocBags' to the end.
**
**  The *allocation area* is the storage  that is available for allocation of
**  new bags.  When a new bag is allocated the storage for  the body is taken
**  from  the beginning of   this area,  and  this  area  is  correspondingly
**  reduced.   If  the body does not   fit in the  allocation  area a garbage
**  collection is  performed.  'AllocBags' points   to the beginning of  this
**  area and 'EndBags' to the end.
**
**  Note that  the  borders between the areas are not static.  In  particular
**  each allocation increases the size of the young bags area and reduces the
**  size of the  allocation area.  On the other hand each garbage  collection
**  empties the young bags area.
*/
Bag *                   MptrBags;
Bag *                   MptrEndBags;
static Bag *            OldBags;
Bag *                   YoungBags;
Bag *                   AllocBags;
static UInt             AllocSizeBags;
static Bag *            EndBags;

/* These macros, are (a) for more readable code, but more importantly
   (b) to ensure that unsigned subtracts and divides are used (since
   we know the ordering of the pointers. This is needed on > 2GB
   workspaces on 32 but systems. The Size****Area functions return an
   answer in units of a word (ie sizeof(UInt) bytes), which should
   therefore be small enough not to cause problems. */

static inline UInt SpaceBetweenPointers(const Bag * a, const Bag * b)
{
    GAP_ASSERT(b <= a);
    UInt res = (((UInt)((UInt)(a) - (UInt)(b))) / sizeof(Bag));
    return res;
}

#define SizeMptrsArea SpaceBetweenPointers(MptrEndBags, MptrBags)
// #define SizeOldBagsArea SpaceBetweenPointers(YoungBags, OldBags)
// #define SizeYoungBagsArea SpaceBetweenPointers(AllocBags, YoungBags)
#define SizeAllocationArea SpaceBetweenPointers(EndBags, AllocBags)

#define SizeAllBagsArea SpaceBetweenPointers(AllocBags, OldBags)
#define SizeWorkspace SpaceBetweenPointers(EndBags, MptrBags)

#if defined(GAP_KERNEL_DEBUG)
static int SanityCheckGasmanPointers(void)
{
    return MptrBags <= MptrEndBags &&
           MptrEndBags <= OldBags &&
           OldBags <= YoungBags &&
           YoungBags <= AllocBags &&
           AllocBags <= EndBags;
}
#endif

/****************************************************************************
**
*V  FreeMptrBags  . . . . . . . . . . . . . . .  list of free bag identifiers
**
**  'FreeMptrBags' is the  first free bag identifier, i.e., it points  to the
**  first  available  masterpointer.   If 'FreeMptrBags'  is 0  there are  no
**  available masterpointers.  The available masterpointers are  managed in a
**  forward linked list,  i.e., each available  masterpointer  points  to the
**  next available masterpointer, except for the last, which contains 0.
**
**  When a new  bag is allocated  it gets the identifier  'FreeMptrBags', and
**  'FreeMptrBags' is set to the value stored in this masterpointer, which is
**  the next available masterpointer.  When a bag is deallocated by a garbage
**  collection  its  masterpointer  is  added   to  the  list  of   available
**  masterpointers again.
*/
static Bag FreeMptrBags;


/****************************************************************************
**
*V  ChangedBags . . . . . . . . . . . . . . . . . .  list of changed old bags
**
**  'ChangedBags' holds a  list of old bags that  have been changed since the
**  last garbage collection, i.e., for  which either 'CHANGED_BAG' was called
**  or which have been resized.
**
**  This list starts with the bag  whose identifier is 'ChangedBags', and the
**  link word of each bag on the list contains the identifier of the next bag
**  on the list.  The link word of the  last bag on the list  contains 0.  If
**  'ChangedBags' has the value 0, the list is empty.
**
**  The garbage collection needs to know which young  bags are subbags of old
**  bags, since  it  must  not  throw   those away    in a partial    garbage
**  collection.  Only  those old bags that  have been changed  since the last
**  garbage collection can contain references to  young bags, which have been
**  allocated since the last garbage  collection.  The application cooperates
**  by informing {\Gasman} with 'CHANGED_BAG' which bags it has changed.  The
**  list of changed old  bags is scanned by a  partial garbage collection and
**  the young subbags of the old bags on this list are marked with 'MarkBag'
**  (see "MarkedBags").  Without this  list 'CollectBags' would have to  scan
**  all old bags for references to young bags, which would take too much time
**  (see "Implementation of CollectBags").
**
**  'CHANGED_BAG' puts a bag on the list  of changed old bags.  'CHANGED_BAG'
**  first checks that <bag> is an old bag by checking that 'PTR_BAG( <bag> )'
**  is smaller than 'YoungBags'.  Then it checks that  the bag is not already
**  on the list of changed bags by checking that the link word still contains
**  the identifier of <bag>.  If <bag> is an  old bag that  is not already on
**  the list of changed bags, 'CHANGED_BAG' puts <bag> on the list of changed
**  bags,  by  setting  the  link word of   <bag>   to the   current value of
**  'ChangedBags' and then setting 'ChangedBags' to <bag>.
*/
Bag                     ChangedBags;


/****************************************************************************
**
*V  MarkedBags  . . . . . . . . . . . . . . . . . . . . . list of marked bags
**
**  'MarkedBags' holds a list of bags that have already  been marked during a
**  garbage collection by 'MarkBag'.  This list is only used  during garbage
**  collections, so it is  always empty outside  of  garbage collections (see
**  "Implementation of CollectBags").
**
**  This list starts with the  bag whose identifier  is 'MarkedBags', and the
**  link word of each bag on the list contains the identifier of the next bag
**  on the list.  The link word of the  last bag on the list  contains 0.  If
**  'MarkedBags' has the value 0, the list is empty.
**
**  Note that some other  storage managers do not use  such a list during the
**  mark phase.   Instead  they simply let the  marking   functions call each
**  other.  While this is  somewhat simpler it  may use an unbound  amount of
**  space on the stack.  This is particularly  bad on systems where the stack
**  is not in a separate segment of the address space, and thus may grow into
**  the workspace, causing disaster.
**
**  'MarkBag'   puts a  bag <bag>  onto  this list.    'MarkBag'  has to be
**  careful, because it can be called  with an argument that  is not really a
**  bag identifier, and may  point  outside the programs  address space.   So
**  'MarkBag' first checks that <bag> points  to a properly aligned location
**  between 'MptrBags' and 'OldBags'.   Then 'MarkBag' checks that <bag>  is
**  the identifier  of a young bag by  checking that the masterpointer points
**  to  a  location between  'YoungBags'  and  'AllocBags'  (if <bag>  is the
**  identifier of an   old bag, the  masterpointer will  point to a  location
**  between  'OldBags' and 'YoungBags',  and if <bag>   only appears to be an
**  identifier, the masterpointer could be on the free list of masterpointers
**  and   point   to a  location  between  'MptrBags'  and  'OldBags').  Then
**  'MarkBag' checks  that <bag> is not  already marked by checking that the
**  link  word of <bag>  contains the identifier of the   bag.  If any of the
**  checks fails, 'MarkBag' does nothing.  If all checks succeed, 'MarkBag'
**  puts <bag> onto the  list of marked bags by  putting the current value of
**  'ChangedBags' into the link word  of <bag>  and setting 'ChangedBags'  to
**  <bag>.  Note that since bags are always placed  at the front of the list,
**  'CollectBags' will   mark the bags   in a  depth-first  order.   This  is
**  probably good to improve the locality of reference.
*/
static Bag MarkedBags;


/****************************************************************************
**
*V  NrAllBags . . . . . . . . . . . . . . . . .  number of all bags allocated
**
**  'NrAllBags' is the number of bags allocated since Gasman was initialized.
**  It is incremented for each 'NewBag' call.
*/
static UInt NrAllBags;


/****************************************************************************
**
*V  NrLiveBags  . . . . . . . . . .  number of bags that survived the last gc
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
*/
static UInt NrLiveBags;


/****************************************************************************
**
*V  SizeLiveBags  . . . . . . .  total size of bags that survived the last gc
**
**  'SizeLiveBags' is  the total size of bags  that were  live after the last
**  garbage collection.  So after a full garbage  collection it is simply the
**  total size of bags that have been found to  be still live by this garbage
**  collection.  After  a partial  garbage  collection it  is the sum  of the
**  previous value of  'SizeLiveBags', which is the total   size of live  old
**  bags, and the total size of bags that have been found to be still live by
**  this garbage  collection,  which is  the  total size of  live young bags.
**  This value is used in the information messages.
*/
static UInt SizeLiveBags;


/****************************************************************************
**
*V  NrDeadBags  . . . . . . . number of bags that died since the last full gc
**
**  'NrDeadBags' is  the number of bags that died since the last full garbage
**  collection.   So after a  full garbage  collection this is zero.  After a
**  partial  garbage  collection it  is  the  sum  of the  previous value  of
**  'NrDeadBags' and the  number of bags that  have been found to be dead  by
**  this garbage collection.  This value is used in the information messages.
*/
static UInt NrDeadBags;


/****************************************************************************
**
*V  SizeDeadBags  . . . . total size of bags that died since the last full gc
**
**  'SizeDeadBags' is  the total size  of bags that  died since the last full
**  garbage collection.  So  after a full   garbage collection this  is zero.
**  After a partial garbage collection it is the sum of the previous value of
**  'SizeDeadBags' and the total size of bags that have been found to be dead
**  by  this garbage  collection.   This  value  is used  in the  information
**  message.
*/
static UInt8 SizeDeadBags;


/****************************************************************************
**
*V  NrDeadBags . . . . . . . . . . number of bags only reachable by weak ptrs
**
**  'NrHalfDeadBags'  is  the number of  bags  that  have  been  found to  be
**  reachable only by way of weak pointers since the last garbage collection.
**  The bodies of these bags are deleted, but their identifiers are marked so
**  that weak pointer objects can recognize this situation.
*/
static UInt NrHalfDeadBags;


/****************************************************************************
**
*F  IS_BAG_ID -- check if a value looks like a masterpointer id
*/
static inline BOOL IS_BAG_ID(void * ptr)
{
    return (((void *)MptrBags <= ptr) && (ptr < (void *)MptrEndBags) &&
            ((UInt)ptr & (sizeof(Bag) - 1)) == 0);
}

/****************************************************************************
**
*F  IS_BAG_BODY -- check if value like a pointer to a bag body
*/
static inline BOOL IS_BAG_BODY(void * ptr)
{
    return (((void *)OldBags <= ptr) && (ptr < (void *)AllocBags) &&
            ((UInt)ptr & (sizeof(Bag) - 1)) == 0);
}

#if defined(GAP_MEMORY_CANARY)

#include <valgrind/valgrind.h>
#include <valgrind/memcheck.h>

// tell valgrind that the masterpointer, bag contents and bag header of Bag
// should all be accessible
static void CANARY_ALLOW_ACCESS_BAG(Bag bag)
{
    VALGRIND_MAKE_MEM_DEFINED(bag, sizeof(Bag));
    char * ptr = (char *)PTR_BAG(bag);
    Int    bagLength = SIZE_BAG(bag);
    VALGRIND_MAKE_MEM_DEFINED(ptr, bagLength);

    const BagHeader * header = CONST_BAG_HEADER(bag);
    VALGRIND_MAKE_MEM_DEFINED(
        header, sizeof(*header) - sizeof(header->memory_canary_padding));
}

// Reverse CANARY_ALL_ACCESS_BAG, making the masterpointer, bag contents and
// bag header all inaccessible
static void CANARY_FORBID_ACCESS_BAG(Bag bag)
{
    VALGRIND_MAKE_MEM_NOACCESS(bag, sizeof(Bag));
    char * ptr = (char *)PTR_BAG(bag);
    Int    bagLength = SIZE_BAG(bag);
    VALGRIND_MAKE_MEM_NOACCESS(ptr, bagLength);

    const BagHeader * header = CONST_BAG_HEADER(bag);
    VALGRIND_MAKE_MEM_NOACCESS(
        header, sizeof(*header) - sizeof(header->memory_canary_padding));
}

// Mark all bags as accessible
static void CANARY_ALLOW_ACCESS_ALL_BAGS(void)
{
    CallbackForAllBags(CANARY_ALLOW_ACCESS_BAG);
}

// Mark all bags as inaccessible
static void CANARY_FORBID_ACCESS_ALL_BAGS(void)
{
    VALGRIND_MAKE_MEM_NOACCESS(MptrBags, (EndBags - MptrBags) * sizeof(Bag));
}

// Temporarily disable valgrind checking. This is used while creating bags or
// adjusting any internal GASMAN structures
#define CANARY_DISABLE_VALGRIND() VALGRIND_DISABLE_ERROR_REPORTING

// Renable valgrind checking.
#define CANARY_ENABLE_VALGRIND() VALGRIND_ENABLE_ERROR_REPORTING

// CHANGED_BAG must be here to disable/enable valgrind
void CHANGED_BAG(Bag bag)
{
    CANARY_DISABLE_VALGRIND();
    if (CONST_PTR_BAG(bag) <= YoungBags && LINK_BAG(bag) == bag) {
        LINK_BAG(bag) = ChangedBags;
        ChangedBags = bag;
    }
    CANARY_ENABLE_VALGRIND();
}
#else
#define CANARY_DISABLE_VALGRIND()
#define CANARY_ENABLE_VALGRIND()
#define CANARY_ALLOW_ACCESS_BAG(b)
#define CANARY_FORBID_ACCESS_BAG(b)
#define CANARY_ALLOW_ACCESS_ALL_BAGS()
#define CANARY_FORBID_ACCESS_ALL_BAGS()
#endif


/****************************************************************************
**
*F  InitSweepFuncBags(<type>,<mark-func>)  . . . .  install sweeping function
*/

static TNumSweepFuncBags TabSweepFuncBags[NUM_TYPES];


void InitSweepFuncBags (
    UInt                type,
    TNumSweepFuncBags    sweep_func )
{
    if ( TabSweepFuncBags[type] != 0 ) {
        Pr("warning: sweep function for type %d already installed\n", type, 0);
    }

    TabSweepFuncBags[type] = sweep_func;
}


/****************************************************************************
**
*F  MarkAllSubBagsDefault(<bag>) . . . marking function that marks everything
**
**  'MarkAllSubBagsDefault' is the same  as 'MarkAllSubBags' but is used as
**  the initial default marking function. This allows to catch cases where
**  'InitMarkFuncBags' is called twice for the same type: the first time is
**  accepted because the marking function is still 'MarkAllSubBagsDefault';
**  the second time raises a warning, because a non-default marking function
**  is being replaced.
*/
static void MarkAllSubBagsDefault(Bag bag)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), SIZE_BAG(bag) / sizeof(Bag));
}


/****************************************************************************
**
*F  InitMarkFuncBags(<type>,<mark-func>)  . . . . .  install marking function
*/

TNumMarkFuncBags TabMarkFuncBags [ NUM_TYPES ];

void InitMarkFuncBags (
    UInt                type,
    TNumMarkFuncBags    mark_func )
{
    if ( TabMarkFuncBags[type] != MarkAllSubBagsDefault ) {
        Pr("warning: mark function for type %d already installed\n", type, 0);
    }

    TabMarkFuncBags[type] = mark_func;
}

enum {
    DEAD = 0,
    ALIVE = 1,
    HALFDEAD = 2,
};

static inline UInt GET_MARK_BITS(Bag x)
{
    return (UInt)x & (sizeof(Bag) - 1);
}

static inline Bag MARKED_DEAD(Bag x)
{
    return x;
}

static inline Bag MARKED_ALIVE(Bag x)
{
    return (Bag)((UInt)x | ALIVE);
}

static inline Bag MARKED_HALFDEAD(Bag x)
{
    return (Bag)((UInt)x | HALFDEAD);
}

static inline BOOL IS_MARKED_DEAD(Bag x)
{
    return LINK_BAG(x) == MARKED_DEAD(x);
}

// static inline BOOL IS_MARKED_ALIVE(Bag x)
// {
//     return LINK_BAG(x) == MARKED_ALIVE(x);
// }

static inline BOOL IS_MARKED_HALFDEAD(Bag x)
{
    return LINK_BAG(x) == MARKED_HALFDEAD(x);
}

#ifdef GAP_MEM_CHECK
static inline Bag UNMARKED_DEAD(Bag x)
{
    GAP_ASSERT(GET_MARK_BITS(x) == DEAD);
    return x;
}
#endif

static inline Bag UNMARKED_ALIVE(Bag x)
{
    GAP_ASSERT(GET_MARK_BITS(x) == ALIVE);
    return (Bag)(((UInt)x) & ~ALIVE);
}

static inline Bag UNMARKED_HALFDEAD(Bag x)
{
    GAP_ASSERT(GET_MARK_BITS(x) == HALFDEAD);
    return (Bag)(((UInt)x) & ~HALFDEAD);
}


#ifdef DEBUG_GASMAN_MARKING
static UInt BadMarksCounter = 0;
static Int  DisableMarkBagValidation = 0;
#endif


// We define MarkBag as a inline function here so that
// the compiler can optimize the marking functions using it in the
// "current translation unit", i.e. inside gasman.c.
// Other marking functions don't get to inline MarkBag calls anymore,
// but luckily these are rare (and usually not performance critical
// to start with).
inline void MarkBag(Bag bag)
{
  if ( IS_BAG_ID(bag)
       && YoungBags < CONST_PTR_BAG(bag)    /*  points to a young bag */
       && CONST_PTR_BAG(bag) <= AllocBags   /*    "     " "  "     "  */
       && (IS_MARKED_DEAD(bag) || IS_MARKED_HALFDEAD(bag)) )
    {
        LINK_BAG(bag) = MarkedBags;
        MarkedBags = bag;
    }
#ifdef DEBUG_GASMAN_MARKING
    else if (!DisableMarkBagValidation) {
        if (bag != 0 && !((UInt)bag & 3) && !IS_BAG_ID(bag)) {
            BadMarksCounter++;
        }
    }
#endif
}

void MarkBagWeakly(Bag bag)
{
  if ( IS_BAG_ID(bag)
       && YoungBags < CONST_PTR_BAG(bag)    /*  points to a young bag */
       && CONST_PTR_BAG(bag) <= AllocBags   /*    "     " "  "     "  */
       && IS_MARKED_DEAD(bag) )             /*  and not marked already */
    {
      // mark it now as we don't have to recurse
      LINK_BAG(bag) = MARKED_HALFDEAD(bag);
    }
}

BOOL IsWeakDeadBag(Bag bag)
{
    CANARY_DISABLE_VALGRIND();
    BOOL isWeakDeadBag = (((UInt)bag & (sizeof(Bag) - 1)) == 0) &&
                         (Bag)MptrBags <= bag && bag < (Bag)MptrEndBags &&
                         (((UInt)*bag) & (sizeof(Bag) - 1)) == 1;
    CANARY_ENABLE_VALGRIND();
    return isWeakDeadBag;
}


/****************************************************************************
**
*F  CallbackForAllBags( <func> ) call a C function on all non-zero mptrs
**
**  This calls a C function on every bag, including garbage ones, by simply
**  walking the masterpointer area. Not terribly safe.
**
*/
void CallbackForAllBags(void (*func)(Bag))
{
    for (Bag bag = (Bag)MptrBags; bag < (Bag)MptrEndBags; bag++) {
        CANARY_DISABLE_VALGRIND();
        BOOL is_bag = IS_BAG_BODY(*bag);
        CANARY_ENABLE_VALGRIND();
        if (is_bag) {
            (*func)(bag);
        }
    }
}


/****************************************************************************
**
*V  GlobalBags  . . . . . . . . . . . . . . . . . . . . . list of global bags
*/
TNumGlobalBags GlobalBags;


/****************************************************************************
**
*F  InitGlobalBag(<addr>, <cookie>) inform Gasman about global bag identifier
**
**  'InitGlobalBag' simply leaves the address <addr> in a global array, where
**  it is used by 'CollectBags'. <cookie> is also recorded to allow things to
**  be matched up after loading a saved workspace.
*/
static UInt GlobalsAreSorted;

static void ClearGlobalBags(void)
{
  UInt i;
  for (i = 0; i < GlobalBags.nr; i++)
    {
      GlobalBags.addr[i] = 0;
      GlobalBags.cookie[i] = 0;
    }
  GlobalBags.nr = 0;
  GlobalsAreSorted = 0;
}

void InitGlobalBag (
    Bag *               addr,
    const Char *        cookie )
{

    if ( GlobalBags.nr == NR_GLOBAL_BAGS ) {
        Panic("Gasman cannot handle so many global variables");
    }

    if (cookie == 0) {
        Panic("Gasman got a NULL cookie");
    }

    for (UInt i = 0; i < GlobalBags.nr; i++) {
        if (streq(GlobalBags.cookie[i], cookie)) {
            if (GlobalBags.addr[i] == addr)
                Pr("Duplicate global bag entry %s\n", (Int)cookie, 0);
            else
                Pr("Duplicate global bag cookie %s\n", (Int)cookie, 0);
        }
    }

    GlobalBags.addr[GlobalBags.nr] = addr;
    GlobalBags.cookie[GlobalBags.nr] = cookie;
    GlobalBags.nr++;
    GlobalsAreSorted = 0;
}


void SortGlobals(void)
{
  const Char *tmpcookie;
  Bag * tmpaddr;
  UInt len, h, i, k;
  if (GlobalsAreSorted)
      return;
  len = GlobalBags.nr;
  h = 1;
  while ( 9*h + 4 < len )
    { h = 3*h + 1; }
  while ( 0 < h ) {
    for ( i = h; i < len; i++ ) {
      tmpcookie = GlobalBags.cookie[i];
      tmpaddr = GlobalBags.addr[i];
      k = i;
      while (h <= k && strcmp(tmpcookie, GlobalBags.cookie[k - h]) < 0) {
          GlobalBags.cookie[k] = GlobalBags.cookie[k-h];
          GlobalBags.addr[k] = GlobalBags.addr[k-h];
          k -= h;
      }
      GlobalBags.cookie[k] = tmpcookie;
      GlobalBags.addr[k] = tmpaddr;
    }
    h = h / 3;
  }
  GlobalsAreSorted = 1;
}



Bag * GlobalByCookie(
       const Char * cookie )
{
  UInt i,top,bottom,middle;
  Int res;
  if (cookie == 0)
      Panic("zero cookie passed to GlobalByCookie");
  if (!GlobalsAreSorted) {
      for (i = 0; i < GlobalBags.nr; i++)
        {
          if (streq(cookie, GlobalBags.cookie[i]))
            return GlobalBags.addr[i];
        }
      return (Bag *)0;
  }
  else
    {
      top = GlobalBags.nr;
      bottom = 0;
      while (top >= bottom) {
        middle = (top + bottom)/2;
        res = strcmp(cookie,GlobalBags.cookie[middle]);
        if (res < 0)
          top = middle-1;
        else if (res > 0)
          bottom = middle+1;
        else
          return GlobalBags.addr[middle];
      }
      return (Bag *)0;
    }
}


static Bag NextMptrRestoring;

void StartRestoringBags( UInt nBags, UInt maxSize)
{
  UInt target;
  Bag *newmem;
/*Bag *ptr; */
  target = (8*nBags)/7 + (8*maxSize)/7; /* ideal workspace size */
  target = (target * sizeof (Bag) + (512L*1024L) - 1)/(512L*1024L)*(512L*1024L)/sizeof (Bag);
              /* make sure that the allocated amount of memory is divisible by 512 * 1024 */
  if (SizeWorkspace < target)
    {
      newmem  = SyAllocBags(sizeof(Bag)*(target- SizeWorkspace)/1024, 0);
      if (newmem == 0)
        {
          target = nBags + maxSize; /* absolute requirement */
          target = (target * sizeof (Bag) + (512L*1024L) - 1)/(512L*1024L)*(512L*1024L)/sizeof (Bag);
               /* make sure that the allocated amount of memory is divisible by 512 * 1024 */
          if (SizeWorkspace < target)
            SyAllocBags(sizeof(Bag)*(target- SizeWorkspace)/1024, 1);
        }
      EndBags = MptrBags + target;
    }
  OldBags = MptrBags + nBags + (SizeWorkspace - nBags - maxSize)/8;
  MptrEndBags = OldBags;
  AllocBags = OldBags;
  NextMptrRestoring = (Bag)MptrBags;
  SizeAllBags = 0;
  NrAllBags = 0;
}

Bag NextBagRestoring( UInt type, UInt flags, UInt size )
{
  Bag bag;
  UInt i;
  BagHeader * header = (BagHeader *)AllocBags;
  *(Bag **)NextMptrRestoring = AllocBags = DATA(header);
  bag = NextMptrRestoring;
  header->type = type;
  header->flags = flags;
  header->size = size;
  header->link = NextMptrRestoring;

  NextMptrRestoring++;

  if ((Bag *)NextMptrRestoring >= MptrEndBags)
    Panic("Overran Masterpointer area");

  for (i = 0; i < WORDS_BAG(size); i++)
    *AllocBags++ = (Bag)0;

  if (AllocBags > EndBags)
    Panic("Overran data area");

#ifdef COUNT_BAGS
  InfoBags[type].nrLive   += 1;
  InfoBags[type].nrAll    += 1;
  InfoBags[type].sizeLive += size;
  InfoBags[type].sizeAll  += size;
#endif
  SizeAllBags += size;
  NrAllBags ++;
  return bag;
}

void FinishedRestoringBags( void )
{
  Bag p;
/*  Bag *ptr; */
  YoungBags = AllocBags;
  FreeMptrBags = NextMptrRestoring;
  for (p = NextMptrRestoring; p +1 < (Bag)MptrEndBags; p++)
    *(Bag *)p = p+1;
  *p = 0;
  NrLiveBags = NrAllBags;
  SizeLiveBags = SizeAllBags;
  NrDeadBags = 0;
  SizeDeadBags = 0;
  NrHalfDeadBags = 0;
  ChangedBags = 0;
}


/****************************************************************************
**
*F  InitFreeFuncBag(<type>,<free-func>) . . . . . .  install freeing function
**
**  'InitFreeFuncBag' is really too simple for an explanation.
*/
static TNumFreeFuncBags TabFreeFuncBags[NUM_TYPES];

void            InitFreeFuncBag (
    UInt                type,
    TNumFreeFuncBags    free_func )
{
    TabFreeFuncBags[type] = free_func;
}


/****************************************************************************
**
*/
static struct {
    UInt nrBefore;
    UInt nrAfter;

    TNumCollectFuncBags before[16];
    TNumCollectFuncBags after[16];
} CollectFuncBags = { 0, 0, { 0 }, { 0 } };

int RegisterBeforeCollectFuncBags(TNumCollectFuncBags func)
{
    if (CollectFuncBags.nrBefore >= ARRAY_SIZE(CollectFuncBags.before))
        return 1;
    CollectFuncBags.before[CollectFuncBags.nrBefore++] = func;
    return 0;
}

int RegisterAfterCollectFuncBags(TNumCollectFuncBags func)
{
    if (CollectFuncBags.nrAfter >= ARRAY_SIZE(CollectFuncBags.after))
        return 1;
    CollectFuncBags.after[CollectFuncBags.nrAfter++] = func;
    return 0;
}


/***************************************************************
 * GAP_MEM_CHECK
 *
 * One of the hardest categories of bugs to fix in GAP are where
 * a reference to the internals of a GAP object are kept across
 * a garbage collection (which moves GAP objects around).
 *
 * GAP_MEM_CHECK provides a method of detecting such problems, at
 * the cost of GREATLY decreased performance (Starting GAP in
 * --enableMemCheck mode takes days, rather than seconds).
 *
 * The fundamental idea behind GAP_MEM_CHECK is, whenever NewBag
 * or ResizeBag is called, then the contents of every Bag in
 * GAP is moved, and the memory previously being used is marked
 * as not readable or writable using 'mprotect'.
 *
 * Actually copying all GAP's memory space would be extremely
 * expensive, so instead we use 'mmap' to set up a set of copies
 * of the GAP memory space, which are represented by the same
 * underlying physical memory.
 *
 * The 0th such copy (which we also ensure is the one at the
 * lowest memory address) is special -- this is where we
 * reference the master pointers (which can't move). We do not
 * 'mprotect' any of this memory.
 *
 * Every time we call 'NewBag' or 'ResizeBag', we change which
 * copy of the GASMAN memory space the master pointers point
 * to, disabling access to the previous copy, and enabling access
 * to the new one.
 *
 * We never use the master pointers in any copy other than the
 * 0th, and we never refer to the Bag area in the 0th copy. However,
 * it simplifies things to not try to separate the master pointer
 * and Bag areas, because the master pointer area can grow as GAP
 * runs.
 *
 * Because this code is VERY slow, it can be turned on and off.
 * At run time, call GASMAN_MEM_CHECK(1) to enable, and
 * GASMAN_MEM_CHECK(0) to disable. Start GAP with --enableMemCheck
 * to enable from when GAP starts.
 */

#ifdef GAP_MEM_CHECK

Int EnableMemCheck = 0;

Int enableMemCheck(Char ** argv, void * dummy)
{
    SyFputs( "# Warning: --enableMemCheck causes SEVERE slowdowns. Starting GAP may take several days!\n", 3 );
    EnableMemCheck = 1;
    return 1;
}

static void MoveBagMemory(char * oldbase, char * newbase)
{
    Int moveSize = (newbase - oldbase) / sizeof(Bag);
    // update the masterpointers
    for (Bag * p = MptrBags; p < MptrEndBags; p++) {
        if ((Bag)MptrEndBags <= *p)
            *p += moveSize;
    }

    // update 'OldBags', 'YoungBags', 'AllocBags', and 'EndBags'
    OldBags += moveSize;
    YoungBags += moveSize;
    AllocBags += moveSize;
    EndBags += moveSize;
}

static void MaybeMoveBags(void)
{
    static Int oldBase = 0;

    if (!EnableMemCheck)
        return;

    Int newBase = oldBase + 1;
    // Memory buffer 0 is special, as we use that
    // copy for the master pointers. Therefore never
    // block access to it, and skip it when cycling.
    if (newBase >= GetMembufCount())
        newBase = 1;

    // call the before functions (if any)
    UInt i;
    for (i = 0; i < CollectFuncBags.nrBefore; ++i)
        CollectFuncBags.before[i]();

    MoveBagMemory(GetMembuf(oldBase), GetMembuf(newBase));

    // Enable access to new memory
    mprotect(GetMembuf(newBase), GetMembufSize(), PROT_READ | PROT_WRITE);
    // Block access to old memory (except block 0, which will only occur
    // on the first call).
    if (oldBase != 0) {
        mprotect(GetMembuf(oldBase), GetMembufSize(), PROT_NONE);
    }

    // call the after functions (if any)
    for (i = 0; i < CollectFuncBags.nrAfter; ++i)
        CollectFuncBags.after[i]();

    oldBase = newBase;
}

#endif

/****************************************************************************
**
*F  ReportOutOfMemory_
**
**  The '1 << 27' check ensures we only try to recover when a large
**  allocation fails.
*/
static void ReportOutOfMemory_(int line, UInt size, const char * reason)
{
    // if a small allocation failed, we are in serious trouble
    if (size <= (1 << 27))
        Panic_(__FILE__, line, "%s", reason);

    // If a SyStorOverrun message is scheduled, mark it as already printed
    if (SyStorOverrun == SY_STOR_OVERRUN_TO_REPORT)
        SyStorOverrun = SY_STOR_OVERRUN_REPORTED;
    ErrorMayQuit("Cannot allocate %d bytes: %s", size, (Int)reason);
}

/****************************************************************************
**
*F  ReportOutOfMemory(size, reason) . . . . . .  handle running out of memory
**
**  `ReportOutOfMemory' is called by gasman when a too large allocation
**  occurs. It is implemented a macro so we can get the line of the caller.
**  The actual work is done by `ReportOutOfMemory_`.
*/
#define ReportOutOfMemory(size, reason)                                      \
    ReportOutOfMemory_(__LINE__, size, reason)

/****************************************************************************
**
*F  FinishBags() . . . . . . . . . . . . . . . . . . . . . . .finalize GASMAN
**
** `FinishBags()' ends GASMAN and returns all memory to the OS pool
**
*/

void FinishBags( void )
{
    SyFreeAllBags();
}

/****************************************************************************
**
*F  InitBags(...) . . . . . . . . . . . . . . . . . . . . . initialize Gasman
**
**  'InitBags' stores <stack-bottom> in a global variable. It also allocates
**  the initial workspace, and sets up the linked list of available
**  masterpointers.
*/
static Bag * StackBottomBags;

static TNumExtraMarkFuncBags ExtraMarkFuncBags;
void SetExtraMarkFuncBags(TNumExtraMarkFuncBags func)
{
    ExtraMarkFuncBags = func;
}

GAP_STATIC_ASSERT((sizeof(BagHeader) % sizeof(Bag)) == 0, "BagHeader size must be multiple of word size");


void SetStackBottomBags(void * StackBottom)
{
    StackBottomBags = StackBottom;
}


void InitBags(UInt initial_size, Bag * stack_bottom)
{
    Bag *               p;              /* loop variable                   */
    UInt                i;              /* loop variable                   */

    ClearGlobalBags();

    /* install the allocator and the abort function                        */
    ExtraMarkFuncBags = 0;

    // install the stack values
    StackBottomBags = stack_bottom;

    /* first get some storage from the operating system                    */
    initial_size    = (initial_size + 511) & ~(511);
    MptrBags = SyAllocBags( initial_size, 1 );
    GAP_ASSERT(MptrBags);
    EndBags = MptrBags + 1024*(initial_size / sizeof(Bag*));

    // In GAP_MEM_CHECK we want as few master pointers as possible, as we
    // have to loop over them very frequently.
#ifdef GAP_MEM_CHECK
    UInt initialBagCount = 100000;
#else
    UInt initialBagCount = 1024*initial_size/8/sizeof(Bag*);
#endif
    /* 1/8th of the storage goes into the masterpointer area               */
    FreeMptrBags = (Bag)MptrBags;
    for ( p = MptrBags;
          p + 2*(SIZE_MPTR_BAGS) <= MptrBags+initialBagCount;
          p += SIZE_MPTR_BAGS )
    {
        *p = (Bag)(p + SIZE_MPTR_BAGS);
    }

    /* the rest is for bags                                                */
    MptrEndBags = MptrBags + initialBagCount;
    // Add a small gap between the end of the master pointers and OldBags
    // This is mainly here to ensure we do not break allowing OldBags and
    // MptrEndBags to differ.
    OldBags   = MptrEndBags + 10;
    YoungBags = OldBags;
    AllocBags = OldBags;

    AllocSizeBags = 256;

    /* install the marking functions                                       */
    for ( i = 0; i < NUM_TYPES; i++ )
        TabMarkFuncBags[i] = MarkAllSubBagsDefault;

    /* Set ChangedBags to a proper initial value */
    ChangedBags = 0;

    GAP_ASSERT(SanityCheckGasmanPointers());
    CANARY_FORBID_ACCESS_ALL_BAGS();
}


/****************************************************************************
**
*F  NewBag( <type>, <size> )  . . . . . . . . . . . . . .  allocate a new bag
**
**  'NewBag' is actually quite simple.
**
**  It first tests whether enough storage is available in the allocation area
**  and  whether a free   masterpointer is available.   If  not, it  starts a
**  garbage collection by calling 'CollectBags' passing <size> as the size of
**  the bag it is currently allocating and 0 to indicate  that only a partial
**  garbage collection is called for.   If 'CollectBags' fails and returns 0,
**  'NewBag' also fails and also returns 0.
**
**  Then it takes the first free  masterpointer from the  linked list of free
**  masterpointers (see "FreeMptrBags").
**
**  Then it  writes  the  size and the   type  into the word   pointed to  by
**  'AllocBags'.  Then  it writes the identifier,  i.e.,  the location of the
**  masterpointer, into the next word.
**
**  Then it advances 'AllocBags' by '2 + WORDS_BAG(<size>)'.
**
**  Finally it returns the identifier of the new bag.
**
**  All entries of  the new bag will be initialized to 0.
**
**  If {\Gasman} was compiled with the option 'COUNT_BAGS' then 'NewBag' also
**  updates the information in 'InfoBags' (see "InfoBags").
**
**  'NewBag'  is implemented as  a  function  instead of a  macro  for  three
**  reasons.  It  reduces the size of  the program, improving the instruction
**  cache  hit ratio.   The compiler  can do  anti-aliasing analysis  for the
**  local  variables  of the function.  To  enable  statistics only {\Gasman}
**  needs to be recompiled.
*/
Bag NewBag (
    UInt                type,
    UInt                size )
{
    Bag                 bag;            /* identifier of the new bag       */

#ifdef GAP_MEM_CHECK
    MaybeMoveBags();
#endif

#ifdef TREMBLE_HEAP
    CollectBags(0,0);
#endif

    CANARY_DISABLE_VALGRIND();

    /* check that a masterpointer and enough storage are available         */
    if ( (FreeMptrBags == 0 || SizeAllocationArea < WORDS_BAG(sizeof(BagHeader)+size))
      && CollectBags( size, 0 ) == 0 )
    {
        ReportOutOfMemory(size, "cannot extend the workspace any more!!");
    }

    GAP_ASSERT(type < T_DUMMY);

#ifdef COUNT_BAGS
    /* update the statistics                                               */
    NrAllBags               += 1;
    InfoBags[type].nrLive   += 1;
    InfoBags[type].nrAll    += 1;
    InfoBags[type].sizeLive += size;
    InfoBags[type].sizeAll  += size;
#endif
    SizeAllBags             += size;

    /* get the identifier of the bag and set 'FreeMptrBags' to the next    */
    bag          = FreeMptrBags;
    FreeMptrBags = *(Bag*)bag;

    /* allocate the storage for the bag                                    */
    BagHeader * header = (BagHeader *)AllocBags;
    AllocBags = DATA(header) + WORDS_BAG(size);

    // enter bag header
    header->type = type;
    header->flags = 0;
    header->size = size;

    /* enter link word                                                     */
    header->link = bag;

    /* set the masterpointer                                               */
    SET_PTR_BAG(bag, DATA(header));

    CANARY_ALLOW_ACCESS_BAG(bag);

    GAP_ASSERT(SanityCheckGasmanPointers());

    CANARY_ENABLE_VALGRIND();

    /* return the identifier of the new bag                                */
    return bag;
}


/****************************************************************************
**
*F  RetypeBag(<bag>,<new>)  . . . . . . . . . . . .  change the type of a bag
**
**  'RetypeBag' is very simple.
**
**  All it has to do is to change type word of the bag.
**
**  If  {\Gasman} was compiled with the  option 'COUNT_BAGS' then 'RetypeBag'
**  also updates the information in 'InfoBags' (see "InfoBags").
*/
void RetypeBagIntern(Bag bag, UInt new_type)
{
    BagHeader * header = BAG_HEADER(bag);
    UInt        old_type = header->type;

    // exit early if nothing is to be done
    if (old_type == new_type)
        return;

#ifdef COUNT_BAGS
    /* update the statistics      */
    {
          UInt                size;

          size = header->size;
          InfoBags[old_type].nrLive   -= 1;
          InfoBags[new_type].nrLive   += 1;
          InfoBags[old_type].nrAll    -= 1;
          InfoBags[new_type].nrAll    += 1;
          InfoBags[old_type].sizeLive -= size;
          InfoBags[new_type].sizeLive += size;
          InfoBags[old_type].sizeAll  -= size;
          InfoBags[new_type].sizeAll  += size;
    }
#endif

    header->type = new_type;
}


/****************************************************************************
**
*F  ResizeBag(<bag>,<new>)  . . . . . . . . . . . .  change the size of a bag
**
**  Basically 'ResizeBag' is rather  simple, but there  are a few  traps that
**  must be avoided.
**
**  If the size of the bag changes only a little bit, so that  the  number of
**  words needed for the data area does not  change, 'ResizeBag' only changes
**  the size word of the bag.
**
**  If  the bag  is  to be  shrunk  and at  least   one  word becomes   free,
**  'ResizeBag'  changes  the  size word of  the bag, and stores a magic
**  size-type word in  the first free word.  This  magic size-type  word  has
**  type T_DUMMY and the size is the number of following free bytes, which is
**  always divisible by 'sizeof(Bag)'. The type T_DUMMY allows 'CollectBags'
**  to detect that this body is the remainder of a resize operation, and the
**  size allows  it  to know how  many  bytes  there  are  in this  body (see
**  "Implementation of CollectBags").
**
**  So for example if 'ResizeBag' shrinks a bag of type 7 from 18 bytes to 10
**  bytes the situation before 'ResizeBag' is as follows{\:}
**
**    +---------+
**    |<masterp>|
**    +---------+
**         \_____________
**                       \
**                        V
**    +---------+---------+--------------------------------------------+----+
**    | 18  . 7 |  <link> |         .         .         .         .    | pad|
**    +---------+---------+--------------------------------------------+----+
**
**  And after 'ResizeBag' the situation is as follows{\:}
**
**    +---------+
**    |<masterp>|
**    +---------+
**         \_____________
**                       \
**                        V
**    +---------+---------+------------------------+----+-------------+-----+
**    | 10  . 7 |  <link> |         .         .    | pad| 4 . T_DUMMY |     |
**    +---------+---------+------------------------+----+-------------+-----+
**
**  If the bag is to be extended and it  is that last  allocated bag, so that
**  it  is  immediately adjacent  to the allocation  area, 'ResizeBag' simply
**  increments  'AllocBags' after making  sure that enough space is available
**  in the allocation area (see "Layout of the Workspace").
**
**  If the bag  is to be   extended and it  is not  the  last allocated  bag,
**  'ResizeBag'  first allocates a  new bag  similar to 'NewBag', but without
**  using  a new masterpointer.   Then it copies the old  contents to the new
**  bag.  Finally it resets the masterpointer of the bag to  point to the new
**  address. Then it changes the type of the old body to T_DUMMY, so that the
**  garbage collection can detect that this body is the remainder of a resize
**  (see "Implementation of NewBag" and "Implementation of CollectBags").
**
**  When an old bag is extended, it  will now reside  in the young bags area,
**  and thus appear  to be young.   Since old bags are   supposed to  survive
**  partial garbage  collections 'ResizeBag'  must   somehow protect this bag
**  from partial garbage collections.  This is  done by putting this bag onto
**  the linked  list  of  changed bags (see   "ChangedBags").  When a partial
**  garbage collection sees a young bag on the list of changed bags, it knows
**  that it is the result of 'ResizeBag' of an old bag, and does not throw it
**  away (see "Implementation of CollectBags").  Note  that  when 'ResizeBag'
**  tries this, the bag may already be on the linked  list, either because it
**  has been resized earlier, or because  it has been  changed.  In this case
**  'ResizeBag' simply keeps the bag on this linked list.
**
**  If {\Gasman}  was compiled with the  option 'COUNT_BAGS' then 'ResizeBag'
**  also updates the information in 'InfoBags' (see "InfoBags").
*/
UInt ResizeBag (
    Bag                 bag,
    UInt                new_size )
{

#ifdef GAP_MEM_CHECK
    MaybeMoveBags();
#endif

#ifdef TREMBLE_HEAP
    CollectBags(0,0);
#endif

    CANARY_DISABLE_VALGRIND();

    CANARY_FORBID_ACCESS_BAG(bag);

    BagHeader * header = BAG_HEADER(bag);
    UInt type     = header->type;
    UInt flags    = header->flags;
    UInt old_size = header->size;

#ifdef COUNT_BAGS
    /* update the statistics                                               */
    InfoBags[type].sizeLive += new_size - old_size;
#endif
    
    const Int diff = WORDS_BAG(new_size) - WORDS_BAG(old_size);

    // if the real size of the bag doesn't change, not much needs to be done
    if ( diff == 0 ) {

        header->size = new_size;
    }

    // if the bag is shrunk we insert a magic marker into the heap
    // Note: if the bag is the last bag, we could in theory also shrink it
    // by moving 'AllocBags', however this is not correct as the "freed"
    // memory may not be zero filled, and zeroing it out would cost us
    else if ( diff < 0 ) {

        // leave magic size-type word for the sweeper, type must be T_DUMMY
        BagHeader * freeHeader = (BagHeader *)(DATA(header) + WORDS_BAG(new_size));
        freeHeader->type = T_DUMMY;
        if ( diff == -1 ) {
            // if there is only one free word, avoid setting the size in
            // the header: there is no space for it on 32bit systems;
            // instead set flags to 1 to inform the sweeper.
            freeHeader->flags = 1;
        }
        else {
            freeHeader->flags = 0;
            freeHeader->size = (-diff-1)*sizeof(Bag);
        }

        header->size = new_size;
    }

    // if the last bag is enlarged ...
    else if (CONST_PTR_BAG(bag) + WORDS_BAG(old_size) == AllocBags) {
        // check that enough storage for the new bag is available
        if (SpaceBetweenPointers(EndBags, CONST_PTR_BAG(bag)) < WORDS_BAG(new_size)
              && CollectBags( new_size-old_size, 0 ) == 0 ) {
            ReportOutOfMemory(new_size,
                              "cannot extend the workspace any more!!!");
        }

        // update header pointer in case bag moved
        header = BAG_HEADER(bag);

        // simply increase the free pointer
        if ( YoungBags == AllocBags )
            YoungBags += diff;
        AllocBags += diff;

        // and increase the total amount allocated by the difference 
#ifdef COUNT_BAGS
        InfoBags[type].sizeAll  += new_size - old_size;
#endif
        SizeAllBags             += new_size - old_size;

        header->size = new_size;
    }

    // if the bag is enlarged ...
    else {

        /* check that enough storage for the new bag is available          */
        if ( SizeAllocationArea <  WORDS_BAG(sizeof(BagHeader)+new_size)
              && CollectBags( new_size, 0 ) == 0 ) {
            ReportOutOfMemory(new_size,
                              "cannot extend the workspace any more!!!!");
        }

        // update header pointer in case bag moved
        header = BAG_HEADER(bag);

        // leave magic size-type word  for the sweeper, type must be T_DUMMY
        header->type = T_DUMMY;
        header->flags = 0;
        header->size =
            sizeof(BagHeader) + (TIGHT_WORDS_BAG(old_size) - 1) * sizeof(Bag);

        /* allocate the storage for the bag                                */
        BagHeader * newHeader = (BagHeader *)AllocBags;
        AllocBags = DATA(newHeader) + WORDS_BAG(new_size);

        newHeader->type = type;
        newHeader->flags = flags;
        newHeader->size = new_size;


#ifdef COUNT_BAGS
        InfoBags[type].sizeAll  += new_size;
#endif
        SizeAllBags             += new_size;

        
        CANARY_DISABLE_VALGRIND();
        /* if the bag is already on the changed bags list, keep it there   */
        if ( header->link != bag ) {
             newHeader->link = header->link;
        }

        /* if the bag is old, put it onto the changed bags list            */
        else if (CONST_PTR_BAG(bag) <= YoungBags) {
            newHeader->link = ChangedBags;
            ChangedBags = bag;
        }

        /* if the bag is young, enter the normal link word                 */
        else {
            newHeader->link = bag;
        }
        CANARY_ENABLE_VALGRIND();

        /* set the masterpointer                                           */
        Bag * dst = DATA(newHeader);
        SET_PTR_BAG(bag, dst);

        /* copy the contents of the bag                                    */
        SyMemmove((void *)dst, (void *)DATA(header),
                sizeof(Obj) * WORDS_BAG(old_size));
    }

    GAP_ASSERT(SanityCheckGasmanPointers());
    CANARY_ALLOW_ACCESS_BAG(bag);
    CANARY_ENABLE_VALGRIND();
    return 1;
}


/****************************************************************************
**
*F  CollectBags( <size>, <full> ) . . . . . . . . . . . . . collect dead bags
**
**  'CollectBags' is the function that does most of the work of {\Gasman}.
**
**  A partial garbage collection where  every bag is  young is clearly a full
**  garbage    collection.  So  to     perform  a  full  garbage  collection,
**  'CollectBags' first sets 'YoungBags'  to   'OldBags', making every    bag
**  young, and empties the list  of changed old bags, since  there are no old
**  bags anymore, there  can be no changed old  bags anymore.  So from now on
**  we    can   assume that  'CollectBags'     is doing   a  partial  garbage
**  collection.   In  addition,    the   values 'NewWeakDeadBagMarker'    and
**  'OldWeakDeadBagMarker'  are exchanged, so  that bag identifiers that have
**  been  halfdead  since    before  this full    garbage  collection can  be
**  distinguished from those which have died on this pass.
**
**  Garbage collection  is  performed in  three phases.  The  mark phase, the
**  sweep phase, and the check phase.
**
**  In the  *mark phase*, 'CollectBags' finds  all young bags that  are still
**  live and builds a linked list of those bags (see "MarkedBags").  A bag is
**  put on  this  list  of  marked bags   by   applying  'MarkBag' to    its
**  identifier.  Note that 'MarkBag' checks that a bag is not already on the
**  list of marked bags, before it puts it on the list, so  no bag can be put
**  twice on this list.
**
**  First, 'CollectBags' marks  all  young bags that are  directly accessible
**  through global   variables,  i.e.,  it   marks those young     bags whose
**  identifiers  appear  in  global variables.   It    does this  by applying
**  'MarkBag'  to the values at the  addresses  of global variables that may
**  hold bag identifiers provided by 'InitGlobalBag' (see "InitGlobalBag").
**
**  Next,  'CollectBags' marks  all  young bags  that are directly accessible
**  through   local  variables, i.e.,    it  marks those  young   bags  whose
**  identifiers appear in the  stack.   It  does  this by calling  the  stack
**  marking  function  <stack-func>  (see  "InitBags").   The   generic stack
**  marking function, which is called if <stack-func> (see "InitBags") was 0,
**  is described below.  The problem is  that there is usually not sufficient
**  information  available to decide  if a value on   the stack is really the
**  identifier of a bag, or is a  value of another  type that only appears to
**  be the  identifier  of a bag.  The  position  usually taken by  the stack
**  marking function is that everything  on the stack  that could possibly be
**  interpreted  as the identifier of  a bag is an  identifier of  a bag, and
**  that this bag is therefore live.  This position is what makes {\Gasman} a
**  conservative storage manager.
**
**  The generic stack marking function 'GenStackFuncBags', which is called if
**  <stack-func> (see "InitBags") was 0, works by  applying 'MarkBag' to all
**  the values on the stack,  which is supposed to extend  from <stack-start>
**  (see  "InitBags") to the address of  a local variable of   the  function.
**  Note that some local variables may  not  be stored on the  stack, because
**  they are  still in the processors registers.    'GenStackFuncBags' uses a
**  jump buffer 'RegsBags', filled by the C library function 'setjmp', marking
**  all bags  whose  identifiers appear in 'RegsBags'.  This  is a dirty hack,
**  that need not work, but actually works on a  surprisingly large number of
**  machines.  But it will not work on Sun  Sparc machines, which have larger
**  register  files, of which  only the part  visible to the current function
**  will be saved  by  'setjmp'.  For those machines 'GenStackFuncBags' first
**  calls the operating system to flush the whole register file.  Note that a
**  compiler may save  a register  somewhere else  if   it wants to  use this
**  register for something else.  Usually  this register is saved  further up
**  the  stack,  i.e.,   beyond the   address  of  the  local variable,   and
**  'GenStackFuncBags' would not see this value any more.   To deal with this
**  problem, 'setjmp' must be called *before* 'GenStackFuncBags'  is entered,
**  i.e.,  before the  registers may have been saved  elsewhere.   Thus it is
**  called from 'CollectBags'.
**
**  Next 'CollectBags' marks all young bags that are directly accessible from
**  old bags, i.e.,  it marks all young bags  whose identifiers appear in the
**  data areas  of  old bags.  It  does  this by applying 'MarkBag'  to each
**  identifier appearing in changed old bags, i.e., in those bags that appear
**  on the list of changed old bags (see "ChangedBags").   To be more precise
**  it calls the  marking function for the appropriate  type to  each changed
**  old bag (see "InitMarkFuncBags").  It need not apply the marking function
**  to each old  bag, because old bags that  have not been changed  since the
**  last garbage  collection cannot contain identifiers  of young bags, which
**  have been allocated since the last garbage collection.  Of course marking
**  the subbags of only  the changed old  bags is more efficient than marking
**  the subbags of  all old bags only  if the number of  changed old  bags is
**  smaller than the total number of old bags, but this  is a very reasonable
**  assumption.
**
**  Note that there may also be bags that  appear to be  young on the list of
**  changed old bags.  Those bags  are old bags that  were extended since the
**  last garbage  collection and therefore have their  body in the young bags
**  area (see "Implementation of  ResizeBag").  When 'CollectBags' finds such
**  a bag  on  the list of  changed  old bags  it  applies 'MarkBag'  to its
**  identifier and thereby  ensures that this bag will  not be thrown away by
**  this garbage collection.
**
**  Next,  'CollectBags'    marks all  young    bags  that  are  *indirectly*
**  accessible, i.e., it marks the subbags of  the already marked bags, their
**  subbags  and  so on.  It  does  so by walking   along the list of already
**  marked bags and applies  the marking function  of the appropriate type to
**  each bag on this list (see  "InitMarkFuncBags").  Those marking functions
**  then apply 'MarkBag' or 'MarkBagWeakly'  to each identifier appearing in
**  the bag.
**
**  After  the marking function has  been  applied to a   bag on the list  of
**  marked bag, this bag is removed from the list.  Thus the marking phase is
**  over when the list  of marked bags   has become empty.  Removing the  bag
**  from the list of marked  bags must be done  at  this time, because  newly
**  marked bags are *prepended* to the list of  marked bags.  This is done to
**  ensure that bags are marked in a  depth first order, which should usually
**  improve locality of   reference.  When a bag is   taken from the list  of
**  marked bags it is *tagged*.  This tag serves two purposes.  A bag that is
**  tagged is not put on the list  of marked bags  when 'MarkBag' is applied
**  to its identifier.  This ensures that  no bag is put  more than once onto
**  the list of marked bags, otherwise endless marking loops could happen for
**  structures that contain circular  references.  Also the sweep phase later
**  uses the presence of  the tag to decide the  status of the bag. There are
**  three possible statuses: LIVE, DEAD and  HALFDEAD. The default state of a
**  bag with its identifier in the link word, is  the tag for DEAD. Live bags
**  are tagged    with  MARKED_ALIVE(<identifier>)  in the   link   word, and
**  half-dead bags (ie bags pointed to weakly but not strongly) with the tage
**  MARKED_HALFDEAD(<identifier>).
**
**  Note that 'CollectBags' cannot put a random or magic  value into the link
**  word, because the sweep phase must be able to find the masterpointer of a
**  bag by only looking at the link word of a bag. This is done using the macros
**  UNMARKED_XXX(<link word contents>).
**
**  In the   *sweep  phase*, 'CollectBags'   deallocates all dead   bags  and
**  compacts the live bags at the beginning of the workspace.
**
**  In this  phase 'CollectBags'   uses  a destination pointer   'dst', which
**  points to  the address a  body  will be copied to,   and a source pointer
**  'src',  which points to the address  a body currently has.  Both pointers
**  initially   point to  the   beginning  of  the   young bags area.    Then
**  'CollectBags' looks at the body pointed to by the source pointer.
**
**  If this body has type T_DUMMY, it is the remainder of a resize operation.
**  In this case 'CollectBags' simply moves the source pointer to the next
**  body (see "Implementation of ResizeBag").
**
**
**  Otherwise, if the  link word contains the  identifier of the bag  itself,

**  marked dead,  'CollectBags' first adds the masterpointer   to the list of
**  available masterpointers (see  "FreeMptrBags") and then simply  moves the
**  source pointer to the next bag.
**
**  Otherwise, if the link  word contains  the  identifier of the  bag marked
**  alive, this   bag is still  live.  In  this case  'CollectBags' calls the
**  sweeping function for this bag, if one  is installed, or otherwise copies
**  the body from  the source address to the  destination address, stores the
**  address of the masterpointer   without the tag  in   the link word,   and
**  updates the masterpointer to point to the new address of the data area of
**  the bag.   After the copying  the source pointer points  to the next bag,
**  and the destination pointer points just past the copy.
**
**  Finally, if the link word contains the identifier of  the bag marked half
**  dead, then  'CollectBags' puts  the special value  'NewWeakDeadBagMarker'
**  into the masterpointer corresponding to the bag, to signify that this bag
**  has been collected as garbage.
**
**  This is repeated until  the source pointer  reaches the end of  the young
**  bags area, i.e., reaches 'AllocBags'.
**
**  The new free storage now is the area between  the destination pointer and
**  the source pointer.  If the initialization flag  <dirty> (see "InitBags")
**  was 0, this area is now cleared.
**
**  Next, 'CollectBags' sets   'YoungBags'  and 'AllocBags'  to   the address
**  pointed to by the destination  pointer.  So all the  young bags that have
**  survived this garbage  collection are now  promoted  to be old  bags, and
**  allocation of new bags will start at the beginning of the free storage.
**
**  Finally, the *check phase* checks  whether  the garbage collection  freed
**  enough storage and masterpointers.
**
**  After a partial garbage collection,  'CollectBags' wants at least '<size>
**  + AllocSizeBags' bytes  of free  storage  available, where <size> is  the
**  size of the bag that 'NewBag' is  currently trying to allocate.  Also the
**  number  of free masterpointers should be  larger than the  number of bags
**  allocated since   the  previous garbage collection  plus 4096  more to be
**  safe.   If less free   storage  or  fewer masterpointers  are  available,
**  'CollectBags' calls itself for a full garbage collection.
**
**  After a  full  garbage collection,  'CollectBags' wants at   least <size>
**  bytes of free storage available, where <size> is the size of the bag that
**  'NewBag' is  currently trying  to allocate.  Also it  wants  at least one
**  free  masterpointer.    If less free    storage or   no masterpointer are
**  available, 'CollectBags'  tries   to   extend  the  workspace   using the
**  allocation   function <alloc-func> (see    "InitBags").   If <alloc-func>
**  refuses  to extend  the   workspace,  'CollectBags' returns 0 to indicate
**  failure to 'NewBag'.  In  any case 'CollectBags' will  try to  extend the
**  workspace so that at least one eigth of the storage is free, that is, one
**  eight of the storage between 'OldBags' and 'EndBags' shall be  free.   If
**  <alloc-func> refuses this extension of the workspace, 'CollectBags' tries
**  to get along with  what it  got.   Also 'CollectBags' wants at least  one
**  masterpointer per 8 words of free storage available.  If  this is not the
**  case, 'CollectBags'  extends the masterpointer area  by moving the bodies
**  of all bags and readjusting the masterpointers.
**
**  Also,  after   a  full  garbage   collection,  'CollectBags'   scans  the
**  masterpointer area for  identifiers containing 'OldWeakDeadBagMarker'. If
**  the sweep functions have done their work then no  references to these bag
**  identifiers can exist, and so 'CollectBags' frees these masterpointers.
*/

static jmp_buf RegsBags;

#if defined(SPARC)
static void SparcStackFuncBags(void)
{
  asm (" ta 0x3 ");
  asm (" mov %sp,%o0" );
}
#endif

static NOINLINE void GenStackFuncBags(void)
{
    Bag *               top;            /* top of stack                    */
    Bag *               p;              /* loop variable                   */
    UInt                i;              /* loop variable                   */

#ifdef DEBUG_GASMAN_MARKING
    DisableMarkBagValidation = 1;
#endif

    top = (Bag*)((void*)&top);
    if ( StackBottomBags < top ) {
        for (i = 0; i < sizeof(Bag *); i += C_STACK_ALIGN) {
            for (p = (Bag *)((char *)StackBottomBags + i); p < top; p++) {
                Bag * pcpy = p;
#if defined(GAP_MEMORY_CANARY)
                // Need to mark this pointer as readable for valgrind
                VALGRIND_MAKE_MEM_DEFINED(&pcpy, sizeof(pcpy));
#endif
                MarkBag(*pcpy);
            }
        }
    }
    else {
        for (i = 0; i < sizeof(Bag *); i += C_STACK_ALIGN) {
            for (p = (Bag *)((char *)StackBottomBags - i); top < p; p--) {
                Bag * pcpy = p;
#if defined(GAP_MEMORY_CANARY)
                // Need to mark this pointer as readable for valgrind
                VALGRIND_MAKE_MEM_DEFINED(&pcpy, sizeof(pcpy));
#endif
                MarkBag(*pcpy);
            }
        }
    }

    // mark from registers, dirty dirty hack: we treat the jmp_buf as a
    // sequence of Bag values. Note that sizeof(jmp_buf) need not be a
    // multiple of sizeof(Bag), hence the end condition looks slightly.
    // unusual.
    for (p = (Bag *)RegsBags; p + 1 <= (Bag *)(RegsBags + 1); p++)
        MarkBag( *p );

#ifdef DEBUG_GASMAN_MARKING
    DisableMarkBagValidation = 0;
#endif
}

/*  These are used to overwrite masterpointers which may still be
linked from weak pointer objects but whose bag bodies have been
collected.  Two values are used so that old masterpointers of this
kind can be reclaimed after a full garbage collection. The values must
not look like valid pointers, and should be congruent to 1 mod sizeof(Bag),
to ensure that IsWeakDeadBag works correctly.
*/

static Bag * NewWeakDeadBagMarker = (Bag *)(1000*sizeof(Bag) + 1);
static Bag * OldWeakDeadBagMarker = (Bag *)(1001*sizeof(Bag) + 1);

static UInt CollectBags_Mark(UInt FullBags)
{
    Bag                 first;          /* first bag on a linked list      */
    UInt                nrLiveBags;     /* number of live new bags         */
    UInt                sizeLiveBags;   /* total size of live new bags     */
    UInt                i;              /* loop variable                   */

    /* prepare the list of marked bags for the future                      */
    MarkedBags = 0;

    /* mark from the static area                                           */
    for ( i = 0; i < GlobalBags.nr; i++ )
        MarkBag( *GlobalBags.addr[i] );

    /* allow installing a custom marking function. This is used for integrating
       GAP (possibly linked as a shared library) with other code bases which use
       their own form of garbage collection. For example, with Python (for
       SageMath) or Julia. */
    if (ExtraMarkFuncBags) {
        (*ExtraMarkFuncBags)();
    }

    /* mark from the stack                                                 */
    _setjmp(RegsBags);
#if defined(SPARC)
    SparcStackFuncBags();
#endif
    GenStackFuncBags();

    /* mark the subbags of the changed old bags                            */
    while ( ChangedBags != 0 ) {
        // extract the head from the linked list
        first = ChangedBags;
        ChangedBags = LINK_BAG(first);
        LINK_BAG(first) = first;

        // mark subbags - we need to distinguish between young and old bags:
        // For old bags, we invoke the marking function for bags with the
        // given TNUM.
        // Young bags normally are never put onto the changed list, because
        // CHANGED_BAGS ignores young bags. However, it can happen if we
        // resize an old bag and it needs to be moved as a result, or if we
        // swap the masterpointers of an old and a young bag. In that case,
        // we must be careful to not collect the young bag (which was old
        // before the masterpointer swap; see the comment on
        // 'SwapMasterPoint' for a detailed explanation why that is so). To
        // facilitate this, 'SwapMasterPoint' forces that bag onto the
        // ChangedBags list. Then, we put such a young bag onto the list of
        // marked bags (via MarkBag), which ensures it is not collected.
        //
        // Note that it doesn't help to use 'MarkBag' on an old bags, as it
        // ignores old bags (which are always assumed to be marked).
        // Conversely, using TabMarkFuncBags on a young bag is no good,
        // because that function only puts subbags on the list of marked
        // bag, which does not prevent the young bag itself from being
        // collected (which is what we need).
        if (CONST_PTR_BAG(first) <= YoungBags)
            (*TabMarkFuncBags[TNUM_BAG(first)])( first );
        else
            MarkBag(first);
    }


    /* tag all marked bags and mark their subbags                          */
    nrLiveBags = 0;
    sizeLiveBags = 0;
    while ( MarkedBags != 0 ) {
        // extract the head from the linked list
        first = MarkedBags;
        MarkedBags = LINK_BAG(first);
        // Gasman in some places treats as bag where
        // CONST_PTR_BAG(bag) == YoungBags as a young bag, and in other
        // places as an old bag. However, this is not a problem because
        // it is not possible for such a bag to exist. Sanity check
        // this condition.
        GAP_ASSERT(CONST_PTR_BAG(first) != YoungBags);

        if (CONST_PTR_BAG(first) > YoungBags) {
            LINK_BAG(first) = MARKED_ALIVE(first);
        }
        else {
            LINK_BAG(first) = first;
        }

        // mark subbags
        (*TabMarkFuncBags[TNUM_BAG(first)])( first );

        // collect some statistics
        nrLiveBags++;
        sizeLiveBags += SIZE_BAG(first);
    }

    /* information after the mark phase                                    */
    NrLiveBags += nrLiveBags;
    SyMsgsBags(FullBags, 1, nrLiveBags);
    SizeLiveBags += sizeLiveBags;
    SyMsgsBags(FullBags, 2, sizeLiveBags / 1024);

    return nrLiveBags;
}

static UInt CollectBags_Sweep(UInt FullBags)
{
    Bag *               dst;            /* destination in sweeping         */
    Bag *               src;            /* source in sweeping              */
    Bag *               end;            /* end of a bag in sweeping        */
    UInt                nrDeadBags;     /* number of dead new bags         */
    UInt                nrHalfDeadBags; /* number of half dead new bags    */
    UInt                sizeDeadBags;   /* total size of dead new bags     */

    /* sweep through the young generation                                  */
    nrDeadBags = 0;
    nrHalfDeadBags = 0;
    sizeDeadBags = 0;
    dst = YoungBags;
    src = YoungBags;
    while ( src < AllocBags ) {
        BagHeader * header = (BagHeader *)src;

        /* leftover of a resize of <n> bytes                               */
        if ( header->type == T_DUMMY ) {

            /* advance src                                                 */
            if (header->flags == 1)
              src++;
            else
              src += 1 + WORDS_BAG(header->size);

        }

        /* dead bag                                                        */
        else if (GET_MARK_BITS(header->link) == DEAD) {
#ifdef GAP_MEM_CHECK
            if (CONST_PTR_BAG(UNMARKED_DEAD(header->link)) != DATA(header)) {
                Panic("incorrectly marked DEAD bag");
            }
#endif


            /* call freeing function                                       */
            if (TabFreeFuncBags[ header->type ] != 0) {
              (*TabFreeFuncBags[ header->type ])( header->link );
            }

            /* update count                                                */
            nrDeadBags += 1;
            sizeDeadBags += header->size;

#ifdef COUNT_BAGS
            /* update the statistics                                       */
            InfoBags[header->type].nrLive -= 1;
            InfoBags[header->type].sizeLive -= header->size;
#endif

            /* free the identifier                                         */
            *(Bag*)(header->link) = FreeMptrBags;
            FreeMptrBags = header->link;

            /* advance src                                                 */
            src = DATA(header) + WORDS_BAG( header->size ) ;

        }

        /* half-dead bag                                                   */
        else if (GET_MARK_BITS(header->link) == HALFDEAD) {
#ifdef GAP_MEM_CHECK
            if (CONST_PTR_BAG(UNMARKED_HALFDEAD(header->link)) != DATA(header)) {
                Panic("incorrectly marked HALFDEAD bag");
            }
#endif

            /* update count                                                */
            nrDeadBags += 1;
            sizeDeadBags += header->size;

#ifdef COUNT_BAGS
            /* update the statistics                                       */
            InfoBags[header->type].nrLive -= 1;
            InfoBags[header->type].sizeLive -= header->size;
#endif

            /* don't free the identifier                                   */
            if (((UInt)UNMARKED_HALFDEAD(header->link)) % 4 != 0)
                Panic("align error in halfdead bag");

            *(Bag**)(UNMARKED_HALFDEAD(header->link)) = NewWeakDeadBagMarker;
            nrHalfDeadBags ++;

            /* advance src                                                 */
            src = DATA(header) + WORDS_BAG( header->size );

        }

        /* live bag                                                        */
        else if (GET_MARK_BITS(header->link) == ALIVE) {
#ifdef GAP_MEM_CHECK
            if (CONST_PTR_BAG(UNMARKED_ALIVE(header->link)) != DATA(header)) {
                Panic("incorrectly marked ALIVE bag");
            }
#endif

            BagHeader * dstHeader = (BagHeader *)dst;

            // update identifier, copy bag header
            SET_PTR_BAG( UNMARKED_ALIVE(header->link), DATA(dstHeader));
            end = DATA(header) + WORDS_BAG( header->size );
            dstHeader->type = header->type;
            dstHeader->flags = header->flags;
            dstHeader->size = header->size;

            dstHeader->link = (Bag)UNMARKED_ALIVE(header->link);
            dst = DATA(dstHeader);

            /* copy data area                                */
            if (TabSweepFuncBags[header->type] != 0) {
                /* Call the installed sweeping function */
                (*(TabSweepFuncBags[header->type]))(DATA(header), dst, end - DATA(header));
                dst += end - DATA(header);
            }

            /* Otherwise do the default thing */
            else if ( dst != DATA(header) ) {
                SyMemmove(dst, DATA(header), (end - DATA(header))*sizeof(Bag));
                dst += end - DATA(header);
            }
            else {
                dst = end;
            }
            src = end;
        }

        /* oops                                                            */
        else {
            Panic("Gasman found a bogus header");
        }

    }

    /* reset the pointer to the free storage                               */
    AllocBags = YoungBags = dst;

    /* clear the new free area                                             */
    memset(dst, 0, ((Char *)src)-((Char *)dst));

    /* information after the sweep phase                                   */
    NrDeadBags += nrDeadBags;
    NrHalfDeadBags += nrHalfDeadBags;
    SyMsgsBags(FullBags, 3, (FullBags ? NrDeadBags : nrDeadBags));
    if ( FullBags )
        NrDeadBags = 0;
    SizeDeadBags += sizeDeadBags;
    SyMsgsBags(FullBags, 4, (FullBags ? SizeDeadBags : sizeDeadBags) / 1024);
    if ( FullBags )
        SizeDeadBags = 0;

    return nrDeadBags + nrHalfDeadBags;
}

static Int CollectBags_Check(UInt size, UInt FullBags, UInt nrBags)
{
    UInt                done;           /* do we have to make a full gc    */
    Bag *               p;              /* loop variable                   */
    UInt                i;              /* loop variable                   */

    // Check if this allocation would even fit into memory
    if (SIZE_MAX - (size_t)(sizeof(BagHeader) + size) < (size_t)AllocBags) {
        return 2; // signal error
    }

    // store in 'stopBags' where this allocation takes us
    Bag * stopBags = AllocBags + WORDS_BAG(sizeof(BagHeader)+size);


    /* if we only performed a partial garbage collection                   */
    if ( ! FullBags ) {

        /* maybe adjust the size of the allocation area                    */
        if ( nrBags < 512

             /* The test below should stop AllocSizeBags
                growing uncontrollably when all bags are big */
             && stopBags > OldBags + 4*1024*WORDS_BAG(AllocSizeBags))
            AllocSizeBags += 256;
        else if ( 4096 < nrBags
               && 256 < AllocSizeBags )
            AllocSizeBags -= 256;

        /* if we don't get enough free storage or masterpointers do full gc */
        if ( EndBags < stopBags + WORDS_BAG(1024*AllocSizeBags)
          || SizeMptrsArea <

             /*      nrBags+ 4096 */
             /*      If this test triggered, but the one below didn't
                     then a full collection would ensue which wouldn't
                     do anything useful. Possibly a version of the
                     above test should be moved into the full collection also
                     but I wasn't sure it always made sense         SL */

             /* change the test to avoid subtracting unsigned integers */

             WORDS_BAG(AllocSizeBags*1024)/7 +(NrLiveBags + NrHalfDeadBags)
             ) {
            done = 0;
        }
        else {
            done = 1;
        }

    }

    /* if we already performed a full garbage collection                   */
    else {

      /* Clean up old half-dead bags
         also reorder the free masterpointer linked list
         to get more locality */
      FreeMptrBags = 0;
      for (p = MptrBags; p < MptrEndBags; p+= SIZE_MPTR_BAGS)
        {
          Bag *mptr = (Bag *)*p;
          if ( mptr == OldWeakDeadBagMarker)
            NrHalfDeadBags--;
          if (mptr == OldWeakDeadBagMarker || IS_BAG_ID(mptr) || mptr == 0) {
              *p = FreeMptrBags;
              FreeMptrBags = (Bag)p;
            }
        }


        /* get the storage we absolutely need                              */
        if (EndBags < stopBags) {
            size_t bytes = (char *)stopBags - (char *)EndBags;
            // Increment in blocks of 512K
            size_t blocks = bytes / 1024 / 512;
            if (blocks * 1024 * 512 < bytes) {
                blocks++;
            }
            if (SyAllocBags(blocks * 512, 0)) {
                EndBags += WORDS_BAG(blocks * 512 * 1024);
            }
        }

        /* if not enough storage is free, fail                             */
        if ( EndBags < stopBags )
            return 2; // signal error

        /* if less than 1/8th is free, get more storage (in 1/2 MBytes)    */
        while ( ( SpaceBetweenPointers(EndBags, stopBags) <  SpaceBetweenPointers(stopBags, OldBags)/7 ||
                  SpaceBetweenPointers(EndBags, stopBags) < WORDS_BAG(AllocSizeBags) )
             && SyAllocBags(512,0) )
            EndBags += WORDS_BAG(512*1024L);

        /* If we are having trouble, then cut our cap to fit our cloth *.
        if ( EndBags - stopBags < AllocSizeBags )
        AllocSizeBags = 7*(Endbags - stopBags)/8; */

        /* if less than 1/16th is free, prepare for an interrupt           */
        if (SpaceBetweenPointers(stopBags,MptrEndBags)/15 < SpaceBetweenPointers(EndBags,stopBags) ) {
            /*N 1993/05/16 martin must change 'gap.c'                      */
            ;
        }

        /* if more than 1/8th is free, give back storage (in 1/2 MBytes)   */
        while (SpaceBetweenPointers(stopBags,MptrEndBags)/7 <= SpaceBetweenPointers(EndBags,stopBags)-WORDS_BAG(512*1024L)
                && SpaceBetweenPointers(EndBags,stopBags) > WORDS_BAG(AllocSizeBags) + WORDS_BAG(512*1024L)
             && SyFreeBags(512) )
            EndBags -= WORDS_BAG(512*1024L);

#ifdef GAP_MEM_CHECK
        UInt SpareMasterPointers = 100000;
#else
        UInt SpareMasterPointers = SpaceBetweenPointers(EndBags, stopBags)/7;
#endif
        /* if we want to increase the masterpointer area                   */
        if ( SizeMptrsArea-NrLiveBags < SpareMasterPointers ) {
            /* this is how many new masterpointers we want                 */
            i = SpareMasterPointers - (SizeMptrsArea-NrLiveBags);
            /* move the bags area                                          */
            SyMemmove(OldBags+i, OldBags, SizeAllBagsArea*sizeof(*OldBags));

            /* update the masterpointers                                   */
            for ( p = MptrBags; p < MptrEndBags; p++ ) {
              if ( (Bag)MptrEndBags <= *p)
                    *p += i;
            }

            /* link the new part of the masterpointer area                 */
            for ( p = MptrEndBags;
                  p + 2*SIZE_MPTR_BAGS <= MptrEndBags+i;
                  p += SIZE_MPTR_BAGS ) {
                *p = (Bag)(p + SIZE_MPTR_BAGS);
            }
            *p = (Bag)FreeMptrBags;
            FreeMptrBags = (Bag)MptrEndBags;

            /* update 'MptrEndBags', 'OldBags', 'YoungBags', 'AllocBags', and 'stopBags'  */
            MptrEndBags += i;
            OldBags   += i;
            YoungBags += i;
            AllocBags += i;
            stopBags  += i;
        }

        /* now we are done                                                 */
        done = 1;

    }

    /* information after the check phase                                   */
    SyMsgsBags(FullBags, 5, (EndBags - stopBags) / (1024 / sizeof(Bag)));
    SyMsgsBags(FullBags, 6, SizeWorkspace / (1024 / sizeof(Bag)));

    return done;
}

static UInt totalTime;

UInt TotalGCTime(void)
{
    return totalTime;
}

UInt CollectBags (
    UInt                size,
    UInt                full )
{
    UInt                nrBags;         /* number of new bags              */
    UInt                done;           /* do we have to make a full gc    */
    UInt                i;              /* loop variable                   */

    UInt startTime = SyTime();

    GAP_ASSERT(SanityCheckGasmanPointers());
    CANARY_DISABLE_VALGRIND();
    CANARY_FORBID_ACCESS_ALL_BAGS();
#ifdef GAP_MEM_CHECK
    CheckMasterPointers();
#endif


    // call the before functions (if any)
    for (i = 0; i < CollectFuncBags.nrBefore; ++i)
        CollectFuncBags.before[i]();

    /* do we want to make a full garbage collection?                       */
    do {
        if (full) {

            // then every bag is considered to be a young bag
            YoungBags = OldBags;
            NrLiveBags = 0;
            SizeLiveBags = 0;

            // empty the list of changed old bags
            while ( ChangedBags != 0 ) {
                Bag first = ChangedBags;
                ChangedBags = LINK_BAG(first);
                LINK_BAG(first) = first;
            }

            // Also time to change the tag for dead children of weak pointer
            // objects. After this collection, there can be no more weak pointer
            // objects pointing to anything with OldWeakDeadBagMarker in it.
            SWAP(Bag *, OldWeakDeadBagMarker, NewWeakDeadBagMarker);
        }

        // information at the beginning of garbage collections
        SyMsgsBags(full, 0, 0);

        // mark phase
        nrBags = CollectBags_Mark(full);

        // sweep phase
        nrBags += CollectBags_Sweep(full);

        // check phase
        done = CollectBags_Check(size, full, nrBags);

        // the variable done can take on several values:
        // 0: not yet finished, try again with a full collection
        // 1: finished successfully to allocate the request memory
        // 2: giving up, we are out of memory

        // if there is another iteration of this loop, then we should perform
        // a full collection
        full = 1;

    } while (!done);

    // call the after functions (if any)
    for (i = 0; i < CollectFuncBags.nrAfter; ++i)
        CollectFuncBags.after[i]();


#ifdef GAP_MEM_CHECK
    CheckMasterPointers();
#endif

    /* Possibly advise the operating system about unused pages:            */
    SyMAdviseFree();

    CANARY_ALLOW_ACCESS_ALL_BAGS();
    CANARY_ENABLE_VALGRIND();

    GAP_ASSERT(SanityCheckGasmanPointers());

    totalTime += SyTime() - startTime;

    return done != 2;
}


/****************************************************************************
**
*F  CheckMasterPointers() . . . . do consistency checks on the masterpointers
**
*/
void CheckMasterPointers( void )
{
    Bag bag;

    // iterate over all bag identifiers
    for (Bag * ptr = MptrBags; ptr < MptrEndBags; ptr++) {
        bag = (Bag)ptr;

        // weakly dead bag?
        if (*ptr == (Bag)NewWeakDeadBagMarker ||
            *ptr == (Bag)OldWeakDeadBagMarker)
            continue;

        // part of chain of free master pointers?
        if (*ptr == 0 || IS_BAG_ID(*ptr)) {
            continue;
        }

        // none of the above, so it must be an active master pointer
        // otherwise, error out
        if (!IS_BAG_BODY(*ptr))
            Panic("Bad master pointer detected");

        if (GET_MARK_BITS(LINK_BAG(bag))) {
            Panic("Master pointer with Mark bits detected");
        }

        // sanity check: the link pointer must either point back; or else
        // this bag must be part of the chain of changed bags (which thus
        // must be non-empty)
        if (ChangedBags == 0 && LINK_BAG(bag) != bag) {
            Panic("Master pointer with bad link word detected");
        }

    }

    // check the chain of free master pointers
    bag = FreeMptrBags;
    while (bag != 0) {
        if (!IS_BAG_ID(bag))
            Panic("Bad chain of free master pointers detected");
        bag = (Bag)*bag;
    }
}


// Swap the master pointers of bag1 and bag2
//
// We need to make sure the correct bags are garbage collected, so we always put
// *both* bags on the ChangedBags linked-list, rather than pick through the
// exact cases, as it is never incorrect to mark something changed.
//
// For completeness and future reference here are the necessary points to
// consider.
//
// When swapping two master pointers, we have to take into account whether the
// bags they refer are on the ChangedBags list, as we otherwise may end up in an
// inconsistent state, where a bag is referenced, but GASMAN does not know this.
// GASMAN then collects this bag, resulting in a corrupted workspace.
//
// We consider the following three cases:
//
// 1. Both bags are old. Then if the original bag1 had been previously marked as
//    changed (by having been put into the ChangedBags singly linked list), then
//    we must make sure to mark the new bag2 as changed, too (and vice-versa).
//
// 2. Both bags are young. Then they typically will not be on the list of
//    changed bags, as CHANGED_BAGS just skips them.
//    However, while CHANGED_BAG will never put a young bag on the list of
//    changed bags, young bags can still be put on the ChangedBags list in
//    step 3, so we need to do something similar as in step 1.
//
// 3. bag1 is young and bag2 is old (or vice-versa), then after swapping, bag1
//    is old and bag2 is young, as the 'young'ness moves with the contents, so
//    we must mark bag1 changed if bag2 was previously changed.
//
//    More importantly, bag2 is now young, but the only references to bag2 might
//    be in an old bag, that is not marked changed. Thus bag2 would get
//    (incorrectly) collected, because these bags are not considered in a
//    garbage collection.
//
//    To avoid this we force bag2 onto the ChangedBags list, but we can't use
//    CHANGED_BAG, as it skips young bags.
//
void SwapMasterPoint(Bag bag1, Bag bag2)
{
    Bag * swapptr;
    Bag   swapbag;

    if (bag1 == bag2)
        return;

    // First make sure both bags are in change list
    // We can't use CHANGED_BAG as it skips young bags
    if (LINK_BAG(bag1) == bag1) {
        LINK_BAG(bag1) = ChangedBags;
        ChangedBags = bag1;
    }
    if (LINK_BAG(bag2) == bag2) {
        LINK_BAG(bag2) = ChangedBags;
        ChangedBags = bag2;
    }

    // get the pointers & swap them
    swapptr = PTR_BAG(bag1);
    SET_PTR_BAG(bag1, PTR_BAG(bag2));
    SET_PTR_BAG(bag2, swapptr);

    // Now swap links, so in the end the list will go
    // through the bags in the same order.
    swapbag = LINK_BAG(bag1);
    LINK_BAG(bag1) = LINK_BAG(bag2);
    LINK_BAG(bag2) = swapbag;
}
