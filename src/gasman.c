/****************************************************************************
**
*W  gasman.c                    GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
char *          Revision_gasman_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */

#define INCLUDE_DECLARATION_PART
#include        "gasman.h"              /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#ifdef DEBUG_DEADSONS_BAGS
#include        "objects.h"             /* Obj                             */
#include        "scanner.h"             /* Pr                              */
#include        "code.h"                /* T_LVARS                         */
#endif


/****************************************************************************
**

*F  WORDS_BAG(<size>) . . . . . . . . . . . words used by a bag of given size
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
**          \____________
**                       \
**                        V
**    +---------+---------+--------------------------------------------+----+
**    |<sz>.<tp>|  <link> |         .         .         .         .    | pad|
**    +---------+---------+--------------------------------------------+----+
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
**  The *body* of a  bag consists of  the size-type word,  the link word, the
**  data area, and the padding.
**
**  The *size-type word* contains the size of the bag in the upper  (at least
**  24) bits, and the type (abbreviated as <tp> in the  above picture) in the
**  lower 8  bits.  Thus 'SIZE_BAG'   simply extracts the size-type  word and
**  shifts it 8 bits to the right, and 'TYPE_BAG' extracts the size-type word
**  and masks out everything except the lower 8 bits.
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
**  A body in the workspace  whose  size-type word contains  the value 255 in
**  the lower 8 bits is the remainder of a 'ResizeBag'.  That  is it consists
**  either of the unused words after a bag has been shrunk or of the old body
**  of the bag after the contents of the body have  been copied elsewhere for
**  an extension.  The upper (at least 24) bits of the first word contain the
**  number of bytes in this area excluding the first  word itself.  Note that
**  such a body   has no link   word,  because  such  a  remainder  does  not
**  correspond to a bag (see "Implementation of ResizeBag").
*/
#ifndef C_PLUS_PLUS_BAGS
#define SIZE_MPTR_BAGS  1
#endif
#ifdef  C_PLUS_PLUS_BAGS
#define SIZE_MPTR_BAGS  2
#endif

#define WORDS_BAG(size) (((size) + (sizeof(Bag)-1)) / sizeof(Bag))


/****************************************************************************
**
*V  MptrBags  . . . . . . . . . . . . . . beginning of the masterpointer area
*V  OldBags . . . . . . . . . . . . . . . . .  beginning of the old bags area
*V  YoungBags . . . . . . . . . . . . . . .  beginning of the young bags area
*V  AllocBags . . . . . . . . . . . . . . .  beginning of the allocation area
*V  AllocSizeBags . . . . . . . . . . . . . . . . size of the allocation area
*V  StopBags  . . . . . . . . . . . . . . . beginning of the unavailable area
*V  EndBags . . . . . . . . . . . . . . . . . . . . . .  end of the workspace
**
**  {\Gasman} manages one large block of storage called the *workspace*.  The
**  layout of the workspace is as follows{\:}
**
**  +-------------+-----------------+------------+------------+-------------+
**  |masterpointer|    old bags     | young bags | allocation | unavailable |
**  |    area     |      area       |    area    |    area    |    area     |
**  +-------------+-----------------+------------+------------+-------------+
**  ^             ^                 ^            ^            ^             ^
**  MptrBags    OldBags         YoungBags    AllocBags     StopBags   EndBags
**
**  The *masterpointer area*  contains  all the masterpointers  of  the bags.
**  'MptrBags' points to the beginning of this area and 'OldBags' to the end.
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
**  area and 'StopBags' to the end.
**
**  The *unavailable  area* is  the free  storage that  is not  available for
**  allocation.   'StopBags'  points  to  the  beginning  of  this  area  and
**  'EndBags' to the end.
**
**  If <cache-size>  (see "InitBags") was 0,  'CollectBags' makes all of  the
**  free storage available for allocations by setting 'StopBags' to 'EndBags'
**  after garbage collections.   In   this case garbage  collections are only
**  performed when no  free storage   is left.  If <cache-size> was  nonzero,
**  'CollectBags' makes 'AllocSizeBags' bytes available by setting 'StopBags'
**  to  'AllocBags   + 2+WORDS_BAG(<size>) +  WORDS_BAG(AllocSizeBags)' after
**  garbage  collections, where <size>   is the  size  of the bag 'NewBag' is
**  currently allocating.  'AllocSizeBags'  is  usually <cache-size>,  but is
**  increased if only very few large bags have been  allocated since the last
**  garbage collection and decreased  again  if sufficiently many  bags  have
**  been allocated since the  last  garbage collection.  The  idea is to keep
**  the allocation area small enough so that it fits in the processor cache.
**
**  Note that  the  borders between the areas are not static.  In  particular
**  each allocation increases the size of the young bags area and reduces the
**  size of the  allocation area.  On the other hand each garbage  collection
**  empties the young bags area.
*/
Bag *                   MptrBags;
Bag *                   OldBags;
Bag *                   YoungBags;
Bag *                   AllocBags;
UInt                    AllocSizeBags;
Bag *                   StopBags;
Bag *                   EndBags;


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
Bag                     FreeMptrBags;


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
**  the young subbags of the old bags on this list are marked with 'MARK_BAG'
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
**  garbage collection by 'MARK_BAG'.  This list is only used  during garbage
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
**  'MARK_BAG'   puts a  bag <bag>  onto  this list.    'MARK_BAG'  has to be
**  careful, because it can be called  with an argument that  is not really a
**  bag identifier, and may  point  outside the programs  address space.   So
**  'MARK_BAG' first checks that <bag> points  to a properly aligned location
**  between 'MptrBags' and 'OldBags'.   Then 'MARK_BAG' checks that <bag>  is
**  the identifier  of a young bag by  checking that the masterpointer points
**  to  a  location between  'YoungBags'  and  'AllocBags'  (if <bag>  is the
**  identifier of an   old bag, the  masterpointer will  point to a  location
**  between  'OldBags' and 'YoungBags',  and if <bag>   only appears to be an
**  identifier, the masterpointer could be on the free list of masterpointers
**  and   point   to a  location  between  'MptrBags'  and  'OldBags').  Then
**  'MARK_BAG' checks  that <bag> is not  already marked by checking that the
**  link  word of <bag>  contains the identifier of the   bag.  If any of the
**  checks fails, 'MARK_BAG' does nothing.  If all checks succeed, 'MARK_BAG'
**  puts <bag> onto the  list of marked bags by  putting the current value of
**  'ChangedBags' into the link word  of <bag>  and setting 'ChangedBags'  to
**  <bag>.  Note that since bags are always placed  at the front of the list,
**  'CollectBags' will   mark the bags   in a  depth-first  order.   This  is
**  probably good to improve the locality of reference.
*/
Bag                     MarkedBags;


/****************************************************************************
**
*V  NrAllBags . . . . . . . . . . . . . . . . .  number of all bags allocated
*V  SizeAllBags . . . . . . . . . . . . . .  total size of all bags allocated
*V  NrLiveBags  . . . . . . . . . .  number of bags that survived the last gc
*V  SizeLiveBags  . . . . . . .  total size of bags that survived the last gc
*V  NrDeadBags  . . . . . . . number of bags that died since the last full gc
*V  SizeDeadBags  . . . . total size of bags that died since the last full gc
*/
UInt                    NrAllBags;
UInt                    SizeAllBags;
UInt                    NrLiveBags;
UInt                    SizeLiveBags;
UInt                    NrDeadBags;
UInt                    SizeDeadBags;


/****************************************************************************
**
*V  InfoBags[<type>]  . . . . . . . . . . . . . . . . .  information for bags
*/
TypeInfoBags            InfoBags [ 256 ];


/****************************************************************************
**
*F  InitMsgsFuncBags(<msgs-func>) . . . . . . . . .  install message function
**
**  'InitMsgsFuncBags'  simply  stores  the  printing  function  in a  global
**  variable.
*/
TypeMsgsFuncBags        MsgsFuncBags;

void            InitMsgsFuncBags (
    TypeMsgsFuncBags    msgs_func )
{
    MsgsFuncBags = msgs_func;
}


/****************************************************************************
**
*F  InitMarkFuncBags(<type>,<mark-func>)  . . . . .  install marking function
*F  MarkNoSubBags(<bag>)  . . . . . . . . marking function that marks nothing
*F  MarkOneSubBags(<bag>) . . . . . .  marking function that marks one subbag
*F  MarkTwoSubBags(<bag>) . . . . . . marking function that marks two subbags
*F  MarkAllSubBags(<bag>) . . . . . .  marking function that marks everything
**
**  'InitMarkFuncBags', 'MarkNoSubBags', 'MarkOneSubBags',  'MarkTwoSubBags',
**  and 'MarkAllSubBags' are really too simple for an explanation.
**
**  'MarkAllSubBagsDefault' is the same  as 'MarkAllSubBags' but is only used
**  by GASMAN as default.  This will allow to catch type clashes.
*/
TypeMarkFuncBags TabMarkFuncBags [ 256 ];

extern void MarkAllSubBagsDefault ( Bag );

void InitMarkFuncBags (
    UInt                type,
    TypeMarkFuncBags    mark_func )
{
#ifdef CHECK_FOR_CLASH_IN_INIT_MARK_FUNC
    char                str[256];

    if ( TabMarkFuncBags[type] != MarkAllSubBagsDefault ) {
	str[0] = 0;
	SyStrncat( str, "warning: mark function for type ", 32 );
	str[32] = '0' + ((type/100) % 10);
	str[33] = '0' + ((type/ 10) % 10);
	str[34] = '0' + ((type/  1) % 10);
	str[35] = 0;
	SyStrncat( str, " already installed\n", 19 );
	SyFputs( str, 0 );
    }
#endif
    TabMarkFuncBags[type] = mark_func;
}

void MarkNoSubBags (
    Bag                 bag )
{
}

void MarkOneSubBags (
    Bag                 bag )
{
    Bag                 sub;            /* one subbag identifier           */
    sub = PTR_BAG(bag)[0];
    MARK_BAG( sub );
}

void MarkTwoSubBags (
    Bag                 bag )
{
    Bag                 sub;            /* one subbag identifier           */
    sub = PTR_BAG(bag)[0];
    MARK_BAG( sub );
    sub = PTR_BAG(bag)[1];
    MARK_BAG( sub );
}

void MarkAllSubBags (
    Bag                 bag )
{
    Bag *               ptr;            /* pointer into the bag            */
    Bag                 sub;            /* one subbag identifier           */
    UInt                i;              /* loop variable                   */

    /* mark everything                                                     */
    ptr = PTR_BAG( bag );
    for ( i = SIZE_BAG(bag)/sizeof(Bag); 0 < i; i-- ) {
        sub = ptr[i-1];
        MARK_BAG( sub );
    }

}

void MarkAllSubBagsDefault (
    Bag                 bag )
{
    Bag *               ptr;            /* pointer into the bag            */
    Bag                 sub;            /* one subbag identifier           */
    UInt                i;              /* loop variable                   */

    /* mark everything                                                     */
    ptr = PTR_BAG( bag );
    for ( i = SIZE_BAG(bag)/sizeof(Bag); 0 < i; i-- ) {
        sub = ptr[i-1];
        MARK_BAG( sub );
    }

}


/****************************************************************************
**
*F  InitGlobalBag(<addr>) . . . . . inform Gasman about global bag identifier
**
**  'InitGlobalBag' simply leaves the address <addr> in a global array, where
**  it is used by 'CollectBags'.
*/
#ifndef NR_GLOBAL_BAGS
#define NR_GLOBAL_BAGS  512L
#endif

typedef struct {
    Bag *                   addr [NR_GLOBAL_BAGS];
    UInt                    nr;
}                       TypeGlobalBags;

TypeGlobalBags          GlobalBags;

void            InitGlobalBag (
    Bag *               addr )
{
    extern  TypeAbortFuncBags   AbortFuncBags;
    if ( GlobalBags.nr == NR_GLOBAL_BAGS ) {
        (*AbortFuncBags)(
            "Panic: Gasman cannot handle so many global variables" );
    }
    GlobalBags.addr[GlobalBags.nr++] = addr;
}


/****************************************************************************
**
*F  InitFreeFuncBag(<type>,<free-func>) . . . . . .  install freeing function
**
**  'InitFreeFuncBag' is really too simple for an explanation.
*/
TypeFreeFuncBags        TabFreeFuncBags [ 256 ];

UInt                    NrTabFreeFuncBags;

void            InitFreeFuncBag (
    UInt                type,
    TypeFreeFuncBags    free_func )
{
    if ( free_func != 0 ) {
        NrTabFreeFuncBags = NrTabFreeFuncBags + 1;
    }
    else {
        NrTabFreeFuncBags = NrTabFreeFuncBags - 1;
    }
    TabFreeFuncBags[type] = free_func;
}


/****************************************************************************
**
*F  InitCollectFuncBags(<bfr-func>,<aft-func>) . install collection functions
**
**  'InitCollectFuncBags' is really too simple for an explanation.
*/
TypeCollectFuncBags     BeforeCollectFuncBags;

TypeCollectFuncBags     AfterCollectFuncBags;

void            InitCollectFuncBags (
    TypeCollectFuncBags before_func,
    TypeCollectFuncBags after_func )
{
    BeforeCollectFuncBags = before_func;
    AfterCollectFuncBags  = after_func;
}


/****************************************************************************
**
*F  InitBags(...) . . . . . . . . . . . . . . . . . . . . . initialize Gasman
**
**  'InitBags'   remembers   <alloc-func>,  <stack-func>,     <stack-bottom>,
**  <stack-align>, <cache-size>,  <dirty>,    and   <abort-func>  in   global
**  variables.   It also  allocates  the initial workspace,   and sets up the
**  linked list of available masterpointer.
*/
TypeAllocFuncBags       AllocFuncBags;

TypeStackFuncBags       StackFuncBags;

Bag *                   StackBottomBags;

UInt                    StackAlignBags;

UInt                    CacheSizeBags;

UInt                    DirtyBags;

TypeAbortFuncBags       AbortFuncBags;

void            InitBags (
    TypeAllocFuncBags   alloc_func,
    UInt                initial_size,
    TypeStackFuncBags   stack_func,
    Bag *               stack_bottom,
    UInt                stack_align,
    UInt                cache_size,
    UInt                dirty,
    TypeAbortFuncBags   abort_func )
{
    Bag *               p;              /* loop variable                   */
    UInt                i;              /* loop variable                   */

    /* install the allocator and the abort function                        */
    AllocFuncBags   = alloc_func;
    AbortFuncBags   = abort_func;

    /* install the stack marking function and values                       */
    StackFuncBags   = stack_func;
    StackBottomBags = stack_bottom;
    StackAlignBags  = stack_align;

    /* first get some storage from the operating system                    */
    initial_size    = (initial_size + (512*1024L-1)) & ~(512*1024L-1);
    MptrBags = (*AllocFuncBags)( initial_size, 1 );
    if ( MptrBags == 0 )
        (*AbortFuncBags)("cannot get storage for the initial workspace.");
    EndBags = MptrBags + initial_size / sizeof(Bag*);

    /* 1/8th of the storage goes into the masterpointer area               */
    FreeMptrBags = (Bag)MptrBags;
    for ( p = MptrBags;
          p + 2*(SIZE_MPTR_BAGS) <= MptrBags+initial_size/8/sizeof(Bag*);
          p += SIZE_MPTR_BAGS ) {
        *p = (Bag)(p + SIZE_MPTR_BAGS);
    }

    /* the rest is for bags                                                */
    OldBags   = MptrBags + initial_size/8/sizeof(Bag*);
    YoungBags = OldBags;
    AllocBags = OldBags;

    /* remember the cache size                                             */
    CacheSizeBags = cache_size;
    if ( ! CacheSizeBags ) {
        AllocSizeBags = 256*1024L;
        StopBags = EndBags;
    }
    else {
        AllocSizeBags = CacheSizeBags;
        StopBags  = AllocBags + WORDS_BAG(AllocSizeBags) <= EndBags ?
                    AllocBags + WORDS_BAG(AllocSizeBags) :  EndBags;
    }

    /* remember whether bags should be clean                               */
    DirtyBags = dirty;

    /* install the marking functions                                       */
    for ( i = 0; i < 255; i++ )
        TabMarkFuncBags[i] = MarkAllSubBagsDefault;

}


/****************************************************************************
**
*F  NewBag(<type>,<size>) . . . . . . . . . . . . . . . .  allocate a new bag
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
**  Note that 'NewBag' never  initializes the new bag  to contain only 0.  If
**  this is desired because  the initialization flag <dirty> (see "InitBags")
**  was  0, it is the job  of 'CollectBags'  to initialize the new free space
**  after a garbage collection.
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
Bag             NewBag (
    UInt                type,
    UInt                size )
{
    Bag                 bag;            /* identifier of the new bag       */
    Bag *               dst;            /* destination of the new bag      */

    /* check that a masterpointer and enough storage are available         */
    if ( (FreeMptrBags == 0 || StopBags < AllocBags+2+WORDS_BAG(size))
      && CollectBags( size, 0 ) == 0 ) {
            return 0;
    }

#ifdef  COUNT_BAGS
    /* update the statistics                                               */
    NrAllBags               += 1;
    SizeAllBags             += size;
    InfoBags[type].nrLive   += 1;
    InfoBags[type].nrAll    += 1;
    InfoBags[type].sizeLive += size;
    InfoBags[type].sizeAll  += size;
#endif

    /* get the identifier of the bag and set 'FreeMptrBags' to the next    */
    bag          = FreeMptrBags;
    FreeMptrBags = *(Bag*)bag;

    /* allocate the storage for the bag                                    */
    dst       = AllocBags;
    AllocBags = dst + 2 + WORDS_BAG(size);

    /* enter size-type word                                                */
    *dst++ = (Bag)(((size) << 8) | type);

    /* enter link word                                                     */
    *dst++ = bag;

    /* set the masterpointer                                               */
    PTR_BAG(bag) = dst;

    /* return the identifier of the new bag                                */
    return bag;
}


/****************************************************************************
**
*F  RetypeBag(<bag>,<new>)  . . . . . . . . . . . .  change the type of a bag
**
**  'RetypeBag' is very simple.
**
**  All it has to do is to change the size-type word of the bag.
**
**  If  {\Gasman} was compiled with the  option 'COUNT_BAGS' then 'RetypeBag'
**  also updates the information in 'InfoBags' (see "InfoBags").
*/
void            RetypeBag (
    Bag                 bag,
    UInt                new_type )
{
    UInt                old_type;       /* old type of the bag             */
    UInt                size;           /* size of the bag                 */

    /* get old type and size of the bag                                    */
    old_type = TYPE_BAG(bag);
    size     = SIZE_BAG(bag);

#ifdef  COUNT_BAGS
    /* update the statistics                                               */
    InfoBags[old_type].nrLive   -= 1;    InfoBags[new_type].nrLive   += 1;
    InfoBags[old_type].nrAll    -= 1;    InfoBags[new_type].nrAll    += 1;
    InfoBags[old_type].sizeLive -= size; InfoBags[new_type].sizeLive += size;
    InfoBags[old_type].sizeAll  -= size; InfoBags[new_type].sizeAll  += size;
#endif

    /* change the size-type word                                           */
    *(*bag-2) = (size << 8) | new_type;
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
**  the size-type word of the bag.
**
**  If  the bag  is  to be  shrunk  and at  least   one  word becomes   free,
**  'ResizeBag'  changes  the  size-type word of  the bag, and stores a magic
**  size-type word in  the first free word.  This  magic size-type  word  has
**  type 255 and the size  is the number  of  following  free bytes, which is
**  always divisible by 'sizeof(Bag)'.  The  type 255 allows 'CollectBags' to
**  detect that  this body  is the remainder of a   resize operation, and the
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
**    +---------+---------+------------------------+----+---------+---------+
**    | 10  . 7 |  <link> |         .         .    | pad|  4  .255|         |
**    +---------+---------+------------------------+----+---------+---------+
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
**  address.  Then it changes the type of the old body  to  255,  so that the
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
UInt            ResizeBag (
    Bag                 bag,
    UInt                new_size )
{
    UInt                type;           /* type of the bag                 */
    UInt                old_size;       /* old size of the bag             */
    Bag *               dst;            /* destination in copying          */
    Bag *               src;            /* source in copying               */
    Bag *               end;            /* end in copying                  */

    /* get type and old size of the bag                                    */
    type     = TYPE_BAG(bag);
    old_size = SIZE_BAG(bag);

#ifdef  COUNT_BAGS
    /* update the statistics                                               */
    SizeAllBags             += new_size - old_size;
    InfoBags[type].sizeLive += new_size - old_size;
    InfoBags[type].sizeAll  += new_size - old_size;
#endif

    /* if the real size of the bag doesn't change                          */
    if ( WORDS_BAG(new_size) == WORDS_BAG(old_size) ) {

        /* change the size word                                            */
        *(*bag-2) = (new_size << 8) | type;

    }

    /* if the bag is shrunk                                                */
    /* we must not shrink the last bag by moving 'AllocBags',              */
    /* since the remainder may not be zero filled                          */
    else if ( WORDS_BAG(new_size) < WORDS_BAG(old_size) ) {

        /* leave magic size-type word for the sweeper, type must be 255    */
        *(UInt*)(PTR_BAG(bag) + WORDS_BAG(new_size))
          = ((((WORDS_BAG(old_size)-WORDS_BAG(new_size)-1)*sizeof(Bag)) << 8)
          | 255);

        /* change the size-type word                                       */
        *(*bag-2) = (new_size << 8) | type;

    }

    /* if the last bag is to be enlarged                                   */
    else if ( PTR_BAG(bag) + WORDS_BAG(old_size) == AllocBags ) {

        /* check that enough storage for the new bag is available          */
        if ( StopBags < PTR_BAG(bag)+WORDS_BAG(new_size)
          && CollectBags( new_size-old_size, 0 ) == 0 ) {
            return 0;
        }

        /* simply increase the free pointer                                */
        if ( YoungBags == AllocBags )
            YoungBags += WORDS_BAG(new_size) - WORDS_BAG(old_size);
        AllocBags += WORDS_BAG(new_size) - WORDS_BAG(old_size);

        /* change the size-type word                                       */
        *(*bag-2) = (new_size << 8) | type;

    }

    /* if the bag is enlarged                                              */
    else {

        /* check that enough storage for the new bag is available          */
        if ( StopBags < AllocBags+2+WORDS_BAG(new_size)
          && CollectBags( new_size, 0 ) == 0 ) {
            return 0;
        }

        /* allocate the storage for the bag                                */
        dst       = AllocBags;
        AllocBags = dst + 2 + WORDS_BAG(new_size);

        /* leave magic size-type word  for the sweeper, type must be 255   */
        *(*bag-2) = ((((WORDS_BAG(old_size)+1) * sizeof(Bag)) << 8) | 255);

        /* enter the new size-type word                                    */
        *dst++ = (Bag)((new_size << 8) | type);

        /* if the bag is already on the changed bags list, keep it there   */
        if ( PTR_BAG(bag)[-1] != bag ) {
            *dst++ = PTR_BAG(bag)[-1];
        }

        /* if the bag is old, put it onto the changed bags list            */
        else if ( PTR_BAG(bag) <= YoungBags ) {
            *dst++ = ChangedBags;  ChangedBags = bag;
        }

        /* if the bag is young, enter the normal link word                 */
        else {
            *dst++ = bag;
        }

        /* set the masterpointer                                           */
        src = PTR_BAG(bag);
        end = src + WORDS_BAG(old_size);
        PTR_BAG(bag) = dst;

        /* copy the contents of the bag                                    */
        while ( src < end )
            *dst++ = *src++;

    }

    /* return success                                                      */
    return 1;
}


/****************************************************************************
**
*F  CollectBags(<size>,<full>)  . . . . . . . . . . . . . . collect dead bags
**
**  'CollectBags' is the function that does most of the work of {\Gasman}.
**
**  A partial garbage  collection where every bag is  young is clearly a full
**  garbage    collection.   So  to   perform    a full  garbage  collection,
**  'CollectBags' first  sets  'YoungBags'  to 'OldBags',  making   every bag
**  young, and empties  the list of changed old  bags, since there are no old
**  bags anymore, there can  be no changed old  bags anymore.  So from now on
**  we can assume that 'CollectBags' is doing a partial garbage collection.
**
**  Garbage collection  is  performed in  three phases.  The  mark phase, the
**  sweep phase, and the check phase.
**
**  In the  *mark phase*, 'CollectBags' finds  all young bags that  are still
**  live and builds a linked list of those bags (see "MarkedBags").  A bag is
**  put on  this  list  of  marked bags   by   applying  'MARK_BAG' to    its
**  identifier.  Note that 'MARK_BAG' checks that a bag is not already on the
**  list of marked bags, before it puts it on the list, so  no bag can be put
**  twice on this list.
**
**  First, 'CollectBags' marks  all  young bags that are  directly accessible
**  through global   variables,  i.e.,  it   marks those young     bags whose
**  identifiers  appear  in  global variables.   It    does this  by applying
**  'MARK_BAG'  to the values at the  addresses  of global variables that may
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
**  <stack-func> (see "InitBags") was 0, works by  applying 'MARK_BAG' to all
**  the values on the stack,  which is supposed to extend  from <stack-start>
**  (see  "InitBags") to the address of  a local variable of   the  function.
**  Note that some local variables may  not  be stored on the  stack, because
**  they are  still in the processors registers.    'GenStackFuncBags' uses a
**  jump buffer 'RegBags', filled by the C library function 'setjmp', marking
**  all bags  whose  identifiers appear in 'RegBags'.  This  is a dirty hack,
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
**  data areas  of  old bags.  It  does  this by applying 'MARK_BAG'  to each
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
**  a bag  on  the list of  changed  old bags  it  applies 'MARK_BAG'  to its
**  identifier and thereby  ensures that this bag will  not be thrown away by
**  this garbage collection.
**
**  Next, 'CollectBags' marks     all  young  bags that   are    *indirectly*
**  accessible, i.e., it marks the subbags of  the already marked bags, their
**  subbags  and so on.   It does  so by walking   along the list of  already
**  marked  bags and applies the marking  function of the appropriate type to
**  each  bag on this list (see "InitMarkFuncBags").  Those marking functions
**  then apply 'MARK_BAG' to each identifier appearing in the bag.
**
**  After  the marking function  has  been applied to a  bag  on the list  of
**  marked bag, this bag is removed from the list.  Thus the marking phase is
**  over  when the list  of marked bags has  become  empty.  Removing the bag
**  from the  list of marked  bags must be done at  this time,  because newly
**  marked bags are *prepended* to the list of  marked bags.  This is done to
**  ensure that bags are marked in a depth first  order, which should usually
**  improve  locality of reference.    When a bag is  taken  from the list of
**  marked bags it is *tagged*.  This tag serves two purposes.  A bag that is
**  tagged is not put on the list  of marked bags  when 'MARK_BAG' is applied
**  to its identifier.  This ensures  that no bag is put  more than once onto
**  the list of marked bags, otherwise endless marking loops could happen for
**  structures that contain circular references.  Also  the sweep phase later
**  uses the presence of the tag to decide if a bag is  still live or already
**  dead.  'CollectBags' tags a bag by putting the identifier of the bag plus
**  1 into the  link word of the bag.   Note that 'CollectBags'  cannot put a
**  random or magic value into the link word, because the sweep phase must be
**  able to find the masterpointer of a bag by only looking  at the link word
**  of a bag.
**
**  Thus after the mark phase the  live bags have their  identifier plus 1 in
**  the  link  word.  Conversely all bags  that  have their identifier in the
**  link word are dead.
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
**  If this body has type 255, it is the remainder of a resize operation.  In
**  this case 'CollectBags' simply moves the source pointer to the  next body
**  (see "Implementation of ResizeBag").
**
**  Otherwise, if the  link word contains  the identifier of  the bag itself,
**  which means that the masterpointer  pointed to by  the link word contains
**  the address of the data area of the  current body, this  bag is dead.  In
**  this case   'CollectBags'  first adds the masterpointer    to the list of
**  available masterpointers (see  "FreeMptrBags") and then simply moves  the
**  source pointer to the next bag.
**
**  Otherwise, if the  link word contains the  identifier of the bag  plus 1,
**  which means  that the masterpointer *before*   the one pointed  to by the
**  link word contains the address of the data area of the current body, this
**  bag is still  live.  In this case  'CollectBags' copies the body from the
**  source address to  the  destination address,  stores  the address of  the
**  masterpointer  without the  tag   in the   link word,   and  updates  the
**  masterpointer to point  to the new address of  the data area of  the bag.
**  After  the copying the  source  pointer points to   the next bag, and the
**  destination pointer points just past the copy.
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
*/
#include        <setjmp.h>

jmp_buf         RegsBags;

#ifdef          SPARC
        asm("           .globl  _SparcStackFuncBags             ");
        asm("   _SparcStackFuncBags:                            ");
        asm("           ta      0x3     ! ST_FLUSH_WINDOWS      ");
        asm("           mov     %sp,%o0                         ");
        asm("           retl                                    ");
        asm("           nop                                     ");
#endif

void            GenStackFuncBags ()
{
    Bag *               top;            /* top of stack                    */
    Bag *               p;              /* loop variable                   */
    UInt                i;              /* loop variable                   */

    top = (Bag*)&top;
    if ( StackBottomBags < top ) {
        for ( i = 0; i < sizeof(Bag*); i += StackAlignBags ) {
            for ( p = (Bag*)((char*)StackBottomBags + i); p < top; p++ )
                MARK_BAG( *p );
        }
    }
    else {
        for ( i = 0; i < sizeof(Bag*); i += StackAlignBags ) {
            for ( p = (Bag*)((char*)StackBottomBags - i); top < p; p-- )
                MARK_BAG( *p );
        }
    }

    /* mark from registers, dirty dirty hack                               */
    for ( p = (Bag*)RegsBags;
          p < (Bag*)RegsBags+sizeof(RegsBags)/sizeof(Bag);
          p++ )
        MARK_BAG( *p );

}

UInt            FullBags;

#ifdef  DEBUG_DEADSONS_BAGS
Bag             OldMarkedBags;
#endif

UInt            CollectBags (
    UInt                size,
    UInt                full )
{
    Bag                 first;          /* first bag on a linked list      */
    Bag *               p;              /* loop variable                   */
    Bag *               dst;            /* destination in sweeping         */
    Bag *               src;            /* source in sweeping              */
    Bag *               end;            /* end of a bag in sweeping        */
    UInt                nrLiveBags;     /* number of live new bags         */
    UInt                sizeLiveBags;   /* total size of live new bags     */
    UInt                nrDeadBags;     /* number of dead new bags         */
    UInt                sizeDeadBags;   /* total size of dead new bags     */
    UInt                done;           /* do we have to make a full gc    */
    UInt                i;              /* loop variable                   */
    Bag *               last;
    Char                type;
#ifdef DEBUG_DEADSONS_BAGS
    UInt                pos;
#endif

    /* call the before function (if any)                                   */
    if ( BeforeCollectFuncBags != 0 )
        (*BeforeCollectFuncBags)();

    /* copy 'full' into a global variable, to avoid warning from GNU C     */
    FullBags = full;

    /* do we want to make a full garbage collection?                       */
  again:
    if ( FullBags ) {

        /* then every bag is considered to be a young bag                  */
        YoungBags = OldBags;
        NrLiveBags = 0;
        SizeLiveBags = 0;

        /* empty the list of changed old bags                              */
        while ( ChangedBags != 0 ) {
            first = ChangedBags;
            ChangedBags = PTR_BAG(first)[-1];
            PTR_BAG(first)[-1] = first;
        }

    }

    /* information at the beginning of garbage collections                 */
    if ( MsgsFuncBags )
        (*MsgsFuncBags)( FullBags, 0, 0 );

    /* * * * * * * * * * * * * * *  mark phase * * * * * * * * * * * * * * */

    /* prepare the list of marked bags for the future                      */
    MarkedBags = 0;

    /* mark from the static area                                           */
    for ( i = 0; i < GlobalBags.nr; i++ )
        MARK_BAG( *GlobalBags.addr[i] );

    /* mark from the stack                                                 */
    if ( StackFuncBags ) {
        (*StackFuncBags)();
    }
    else {
        setjmp( RegsBags );
#ifdef  SPARC
        SparcStackFuncBags();
#endif
        GenStackFuncBags();
    }

    /* mark the subbags of the changed old bags                            */
    while ( ChangedBags != 0 ) {
        first = ChangedBags;
        ChangedBags = PTR_BAG(first)[-1];
        PTR_BAG(first)[-1] = first;
        if ( PTR_BAG(first) <= YoungBags )
            (*TabMarkFuncBags[TYPE_BAG(first)])( first );
        else
            MARK_BAG(first);
    }

#ifdef  DEBUG_DEADSONS_BAGS
    /* check for old bags pointing to new unmarked bags                    */
    p = OldBags;
    OldMarkedBags = MarkedBags;
    while ( p < YoungBags ) {
        if ( (*(UInt*)p & 0xFFL) == 255 ) {
            p += 1 + WORDS_BAG( *(UInt*)p >> 8 );
        }
        else if ( (*(UInt*)p & 0xFFL) == 29 ) {
            p += 2 + WORDS_BAG( *(UInt*)p >> 8 );
        }
        else {
            (*TabMarkFuncBags[TYPE_BAG(p[1])])( p[1] );
	    pos = 0;
            while ( MarkedBags != OldMarkedBags ) {
		Pr( "#W  Old bag (type %s, size %d, ",
		    (Int)InfoBags[ TYPE_BAG(p[1]) ].name,
		    (Int)SIZE_BAG(p[1]) );
		Pr( "handle %d, pos %d) points to\n",
		    (Int)p[1],
		    (Int)pos );
		Pr( "#W    new bag (type %s, size %d, ",
		    (Int)InfoBags[ TYPE_BAG(MarkedBags) ].name,
		    (Int)SIZE_BAG(MarkedBags) );
		Pr( "handle %d)\n",
		    (Int)MarkedBags,
		    (Int)0 );
		pos++;
                first = PTR_BAG(MarkedBags)[-1];
                PTR_BAG(MarkedBags)[-1] = MarkedBags;
                MarkedBags = first;
            }
            p += 2 + WORDS_BAG( *(UInt*)p >> 8 );
        }
    }
#endif

    /* tag all marked bags and mark their subbags                          */
    nrLiveBags = 0;
    sizeLiveBags = 0;
    while ( MarkedBags != 0 ) {
        first = MarkedBags;
        MarkedBags = PTR_BAG(first)[-1];
        PTR_BAG(first)[-1] = first + 1;
        (*TabMarkFuncBags[TYPE_BAG(first)])( first );
        nrLiveBags++;
        sizeLiveBags += SIZE_BAG(first);
    }

    /* information after the mark phase                                    */
    NrLiveBags += nrLiveBags;
    if ( MsgsFuncBags )
        (*MsgsFuncBags)( FullBags, 1, nrLiveBags );
    SizeLiveBags += sizeLiveBags;
    if ( MsgsFuncBags )
        (*MsgsFuncBags)( FullBags, 2, sizeLiveBags/1024 );

    /* * * * * * * * * * * * * * * sweep phase * * * * * * * * * * * * * * */

    /* call freeing function for all dead bags                             */
    if ( NrTabFreeFuncBags ) {

        /* run through the young generation                                */
        src = YoungBags;
        while ( src < AllocBags ) {

            /* leftover of a resize of <n> bytes                           */
            if ( (*(UInt*)src & 0xFFL) == 255 ) {

                /* advance src                                             */
                src += 1 + WORDS_BAG( *(UInt*)src >> 8 );

            }

            /* dead bag                                                    */
            else if ( PTR_BAG( src[1] ) == src+2 ) {

                /* call freeing function                                   */
                if ( TabFreeFuncBags[ *(UInt*)src & 0xFFL ] != 0 )
                    (*TabFreeFuncBags[ *(UInt*)src & 0xFFL ])( src[1] );

                /* advance src                                             */
                src += 2 + WORDS_BAG( *(UInt*)src >> 8 ) ;

            }

            /* live bag                                                    */
            else if ( PTR_BAG( src[1]-1 ) == src+2 ) {

                /* advance src                                             */
                src += 2 + WORDS_BAG( *(UInt*)src >> 8 );

            }

            /* oops                                                        */
            else {

                (*AbortFuncBags)("Panic: Gasman found a bogus header");

            }

        }

    }

    /* sweep through the young generation                                  */
    nrDeadBags = 0;
    sizeDeadBags = 0;
    dst = YoungBags;
    src = YoungBags;
    while ( src < AllocBags ) {

        /* leftover of a resize of <n> bytes                               */
        if ( (*(UInt*)src & 0xFFL) == 255 ) {
            last = src;  type = 'r';

            /* advance src                                                 */
            src += 1 + WORDS_BAG( *(UInt*)src >> 8 );

        }

        /* dead bag                                                        */
        else if ( PTR_BAG( src[1] ) == src+2 ) {
            last = src;  type = 'd';

            /* update count                                                */
            nrDeadBags += 1;
            sizeDeadBags += (*(UInt*)src >> 8);

#ifdef  COUNT_BAGS
            /* update the statistics                                       */
            InfoBags[*(UInt*)src & 0xFFL].nrLive -= 1;
            InfoBags[*(UInt*)src & 0xFFL].sizeLive
                -= *(UInt*)src >> 8;
#endif

            /* free the identifier                                         */
            *(Bag*)(src[1]) = FreeMptrBags;
            FreeMptrBags = src[1];

            /* advance src                                                 */
            src += 2 + WORDS_BAG( *(UInt*)src >> 8 ) ;

        }

        /* live bag                                                        */
        else if ( PTR_BAG( src[1]-1 ) == src+2 ) {
            last = src;  type = 'l';

            /* update identifier, copy size-type and link field            */
            PTR_BAG( src[1]-1 ) = dst+2;
            end = src + 2 + WORDS_BAG( *(UInt*)src >> 8 );
            *dst++ = *src++;
            *dst++ = *src++ - 1;

            /* copy data area (if necessary)                               */
            if ( dst != src ) {
                while ( src < end )
                    *dst++ = *src++;
            }
            else {
                dst = end;
                src = end;
            }

        }

        /* oops                                                            */
        else {

            (*AbortFuncBags)("Panic: Gasman found a bogus header");

        }

    }

    /* reset the pointer to the free storage                               */
    AllocBags = YoungBags = dst;

    /* clear the new free area                                             */
    if ( ! DirtyBags ) {
        while ( dst < src )
            *dst++ = 0;
    }

    /* information after the sweep phase                                   */
    NrDeadBags += nrDeadBags;
    if ( MsgsFuncBags )
        (*MsgsFuncBags)( FullBags, 3,
                         (FullBags ? NrDeadBags:nrDeadBags) );
    if ( FullBags )
        NrDeadBags = 0;
    SizeDeadBags += sizeDeadBags;
    if ( MsgsFuncBags )
        (*MsgsFuncBags)( FullBags, 4,
                         (FullBags ? SizeDeadBags:sizeDeadBags)/1024 );
    if ( FullBags )
        SizeDeadBags = 0;

    /* * * * * * * * * * * * * * * check phase * * * * * * * * * * * * * * */

    /* temporarily store in 'StopBags' where this allocation takes us      */
    StopBags = AllocBags + 2 + WORDS_BAG(size);

    /* if we only performed a partial garbage collection                   */
    if ( ! FullBags ) {

        /* maybe adjust the size of the allocation area                    */
        if ( ! CacheSizeBags ) {
            if ( nrLiveBags+nrDeadBags < 512 )
                AllocSizeBags += 256*1024L;
            else if ( 4096 < nrLiveBags+nrDeadBags
                   && 256*1024L < AllocSizeBags )
                AllocSizeBags -= 256*1024L;
        }
        else {
            if ( nrLiveBags+nrDeadBags < 512 )
                AllocSizeBags += CacheSizeBags;
            else if ( 4096 < nrLiveBags+nrDeadBags
                   && CacheSizeBags < AllocSizeBags )
                AllocSizeBags -= CacheSizeBags;
        }

        /* if we dont get enough free storage or masterpointers do full gc */
        if ( EndBags < StopBags + WORDS_BAG(AllocSizeBags)
          || (OldBags-MptrBags)-NrLiveBags < nrLiveBags+nrDeadBags+4096 ) {
            done = 0;
        }
        else {
            done = 1;
        }

    }

    /* if we already performed a full garbage collection                   */
    else {

        /* get the storage we absolutly need                               */
        while ( EndBags < StopBags
             && (*AllocFuncBags)(512*1024L,1) )
            EndBags += WORDS_BAG(512*1024L);

        /* if not enough storage is free, fail                             */
        if ( EndBags < StopBags )
            return 0;

        /* if less than 1/8th is free, get more storage (in 1/2 MBytes)    */
        while ( EndBags < StopBags + (StopBags-OldBags)/7
             && (*AllocFuncBags)(512*1024L,0) )
            EndBags += WORDS_BAG(512*1024L);

        /* if less than 1/16th is free, prepare for an interrupt           */
        if ( StopBags + (StopBags-OldBags)/15 < EndBags ) {
            /*N 1993/05/16 martin must change 'gap.c'                      */
            ;
        }

        /* if more than 1/8th is free, give back storage (in 1/2 MBytes)   */
        while ( StopBags+(StopBags-OldBags)/7 <= EndBags-WORDS_BAG(512*1024L)
             && (*AllocFuncBags)(-512*1024L,0) )
            EndBags -= WORDS_BAG(512*1024L);

        /* if we want to increase the masterpointer area                   */
        if ( (OldBags-MptrBags)-NrLiveBags < (EndBags-StopBags)/7 ) {

            /* this is how many new masterpointers we want                 */
            i = (EndBags-StopBags)/7 - ((OldBags-MptrBags)-NrLiveBags);

            /* move the bags area                                          */
            dst = AllocBags + i;
            src = AllocBags;
            end = OldBags;
            while ( end < src )
                *--dst = *--src;

            /* update the masterpointers                                   */
            for ( p = MptrBags; p < OldBags; p++ ) {
                if ( (Bag)OldBags <= *p )
                    *p += i;
            }

            /* link the new part of the masterpointer area                 */
            for ( p = OldBags;
                  p + 2*SIZE_MPTR_BAGS <= OldBags+i;
                  p += SIZE_MPTR_BAGS ) {
                *p = (Bag)(p + SIZE_MPTR_BAGS);
            }
            *p = (Bag)FreeMptrBags;
            FreeMptrBags = (Bag)OldBags;

            /* update 'OldBags', 'YoungBags', 'AllocBags', and 'StopBags'  */
            OldBags   += i;
            YoungBags += i;
            AllocBags += i;
            StopBags  += i;

        }

        /* now we are done                                                 */
        done = 1;

    }

    /* information after the check phase                                   */
    if ( MsgsFuncBags )
        (*MsgsFuncBags)( FullBags, 5,
                         ((char*)EndBags-(char*)StopBags)/1024 );
    if ( MsgsFuncBags )
        (*MsgsFuncBags)( FullBags, 6,
                         ((char*)EndBags-(char*)MptrBags)/1024 );

    /* reset the stop pointer                                              */
    if ( ! CacheSizeBags || EndBags < StopBags+WORDS_BAG(AllocSizeBags) )
        StopBags = EndBags;
    else
        StopBags = StopBags + WORDS_BAG(AllocSizeBags);

    /* if we are not done, then true again                                 */
    if ( ! done ) {
        FullBags = 1;
        goto again;
    }

    /* call the after function (if any)                                    */
    if ( AfterCollectFuncBags != 0 )
        (*AfterCollectFuncBags)();

    /* return success                                                      */
    return 1;
}


#ifdef  DEBUG_FUNCTIONS_BAGS
/****************************************************************************
**
*F  BID(<bag>)  . . . . . . . . . . . .  bag identifier (as unsigned integer)
*F  IS_BAG(<bid>) . . . . . .  test whether a bag identifier identifies a bag
*F  BAG(<bid>)  . . . . . . . . . . . . . . . . . . bag (from bag identifier)
*F  TYPE_BAG(<bag>) . . . . . . . . . . . . . . . . . . . . . . type of a bag
*F  SIZE_BAG(<bag>) . . . . . . . . . . . . . . . . . . . . . . size of a bag
*F  PTR_BAG(<bag>)  . . . . . . . . . . . . . . . . . . . .  pointer to a bag
*F  ELM_BAG(<bag>,<i>)  . . . . . . . . . . . . . . . <i>-th element of a bag
*F  SET_ELM_BAG(<bag>,<i>,<elm>)  . . . . . . . . set <i>-th element of a bag
**
**  'BID', 'IS_BAG', 'BAG', 'TYPE_BAG', 'TNAM_BAG', 'PTR_BAG', 'ELM_BAG', and
**  'SET_ELM_BAG' are functions to support  debugging.  They are not intended
**  to be used  in an application  using {\Gasman}.  Note  that the functions
**  'TYPE_BAG', 'SIZE_BAG', and 'PTR_BAG' shadow the macros of the same name,
**  which are usually not available in a debugger.
*/
#undef  TYPE_BAG
#undef  SIZE_BAG
#undef  PTR_BAG

UInt            BID (
    Bag                 bag )
{
    return (UInt) bag;
}

UInt            IS_BAG (
    UInt                bid )
{
    return (((UInt)MptrBags <= bid)
         && (bid < (UInt)OldBags)
         && (bid & (sizeof(Bag)-1)) == 0);
}

Bag             BAG (
    UInt                bid )
{
    if ( IS_BAG(bid) )
        return (Bag) bid;
    else
        return (Bag) 0;
}

UInt            TYPE_BAG (
    Bag                 bag )
{
    return (*(*(bag)-2) & 0xFFL);
}

Char *          TNAM_BAG (
    Bag                 bag )
{
    return InfoBags[ (*(*(bag)-2) & 0xFFL) ].name;
}

UInt            SIZE_BAG (
    Bag                 bag )
{
    return (*(*(bag)-2) >> 8);
}

Bag *           PTR_BAG (
    Bag                 bag )
{
    return (*(Bag**)(bag));
}

UInt            ELM_BAG (
    Bag                 bag,
    UInt                i )
{
    return (UInt) ((*(Bag**)(bag))[i]);
}

UInt            SET_ELM_BAG (
    Bag                 bag,
    UInt                i,
    UInt                elm )
{
    (*(Bag**)(bag))[i] = (Bag) elm;
    return elm;
}

#endif



