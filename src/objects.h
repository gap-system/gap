/****************************************************************************
**
*W  objects.h                   GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file defines the functions of the objects package.
**
**  The objects package is the part that defines the 'Obj' type,  the objects
**  types  (i.e., the numbers  that  Gasman needs  to distinguish types), the
**  dispatcher for the printing of objects, etc.
*/
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_objects_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*T  Obj . . . . . . . . . . . . . . . . . . . . . . . . . . . type of objects
**
**  'Obj' is the type of objects.
*/
#define Obj             Bag


/****************************************************************************
**

*F  IS_INTOBJ( <o> )  . . . . . . . .  test if an object is an integer object
**
**  'IS_INTOBJ' returns 1 if the object <o> is an (immediate) integer object,
**  and 0 otherwise.
*/
#define IS_INTOBJ(o) \
    ((Int)(o) & 0x01)



/****************************************************************************
**
*F  ARE_INTOBJS( <o1>, <o2> ) . . . . test if two objects are integer objects
**
**  'ARE_INTOBJS' returns 1 if the objects <o1> and <o2> are both (immediate)
**  integer objects.
*/
#define ARE_INTOBJS(o1,o2) \
    ((Int)(o1) & (Int)(o2) & 0x01)


/****************************************************************************
**
*F  INTOBJ_INT( <i> ) . . . . . . .  convert a C integer to an integer object
**
**  'INTOBJ_INT' converts the C integer <i> to an (immediate) integer object.
*/
#define INTOBJ_INT(i) \
    ((Obj)(((Int)(i) << 2) + 0x01))


/****************************************************************************
**
*F  INT_INTOBJ( <o> ) . . . . . . .  convert an integer object to a C integer
**
**  'INT_INTOBJ' converts the (immediate) integer object <o> to a C integer.
*/
#define INT_INTOBJ(o) \
    ((Int)(o) >> 2)



/****************************************************************************
**
*F  EQ_INTOBJS( <o>, <l>, <r> ) . . . . . . . . . compare two integer objects
**
**  'EQ_INTOBJS' returns 'True' if the  (immediate)  integer  object  <l>  is
**  equal to the (immediate) integer object <r> and  'False'  otherwise.  The
**  result is also stored in <o>.
*/
#define EQ_INTOBJS(o,l,r) \
    ((o) = (((Int)(l)) == ((Int)(r)) ? True : False))


/****************************************************************************
**
*F  LT_INTOBJS( <o>, <l>, <r> ) . . . . . . . . . compare two integer objects
**
**  'LT_INTOBJS' returns 'True' if the  (immediate)  integer  object  <l>  is
**  less than the (immediate) integer object <r> and  'False' otherwise.  The
**  result is also stored in <o>.
*/
#define LT_INTOBJS(o,l,r) \
    ((o) = (((Int)(l)) <  ((Int)(r)) ? True : False))


/****************************************************************************
**
*F  SUM_INTOBJS( <o>, <l>, <r> )  . . . . . . . .  sum of two integer objects
**
**  'SUM_INTOBJS' returns  1  if  the  sum  of  the  (imm.)  integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The sum itself is stored in <o>.
*/
#define SUM_INTOBJS(o,l,r)             \
    ((o) = (Obj)((Int)(l)+(Int)(r)-1), \
    (((Int)(o) << 1) >> 1) == (Int)(o) )


/****************************************************************************
**
*F  DIFF_INTOBJS( <o>, <l>, <r> ) . . . . . difference of two integer objects
**
**  'DIFF_INTOBJS' returns 1 if the difference of the (imm.) integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The difference itself is stored in <o>.
*/
#define DIFF_INTOBJS(o,l,r)            \
    ((o) = (Bag)((Int)(l)-(Int)(r)+1), \
    (((Int)(o) << 1) >> 1) == (Int)(o) )


/****************************************************************************
**
*F  PROD_INTOBJS( <o>, <l>, <r> ) . . . . . .  product of two integer objects
**
**  'PROD_INTOBJS' returns 1 if the product of  the  (imm.)  integer  objects
**  <l> and <r> can be stored as (immediate) integer object  and 0 otherwise.
**  The product itself is stored in <o>.
*/
#define PROD_INTOBJS(o,l,r)                            \
    ((o) = (Obj)(((Int)(l)>>2) * ((Int)(r)-1) + 1),    \
     (((Int)(o) << 1) >> 1) == (Int)(o)                \
      && (((Int)(l)>>2) == 0                           \
      || ((Int)(o)-1) / ((Int)(l)>>2) == ((Int)(r)-1)))


/****************************************************************************
**
*F  IS_FFE( <o> ) . . . . . . . . test if an object is a finite field element
**
**  'IS_FFE'  returns 1  if the  object <o>  is  an  (immediate) finite field
**  element and 0 otherwise.
*/
#define IS_FFE(o)               \
                        ((Int)(o) & 0x02)


/****************************************************************************
**

*S  T_<name>  . . . . . . . . . . . . . . . . symbolic names for object types
*S  FIRST_CONSTANT_TYPE, LAST_CONSTANT_TYPE . . . . range of constant   types
*S  FIRST_RECORD_TYPE,   LAST_RECORD_TYPE . . . . . range of record     types
*S  FIRST_LIST_TYPE,     LAST_LIST_TYPE . . . . . . range of list       types
*S  FIRST_EXTERNAL_TYPE, LAST_EXTERNAL_TYPE . . . . range of external   types
*S  FIRST_REAL_TYPE,     LAST_REAL_TYPE . . . . . . range of real       types
*S  FIRST_VIRTUAL_TYPE,  LAST_VIRTUAL_TYPE  . . . . range of virtual    types
*S  FIRST_IMM_MUT_TYPE,  LAST_IMM_MUT_TYPE  . . . . range of im/mutable types
**
**  For every type of objects there is a symbolic name defined for this type.
**
**  'FIRST_CONSTANT_TYPE'  is  the first   type  of constant  objects,  e.g.,
**  integers, booleans, and functions.  'LAST_CONSTANT_TYPE' is the last type
**  of constant objects.
**
**  'FIRST_RECORD_TYPE' is the first type of record objects,  currently  only
**  plain records.  'LAST_RECORD_TYPE' is the last type of record objects.
**
**  'FIRST_LIST_TYPE' is the first type of list objects, e.g.,  plain  lists,
**  ranges, boolean lists, and strings.  'LAST_LIST_TYPE' is the last type of
**  list objects.
**
**  'FIRST_EXTERNAL_TYPE' is the  first type  of external objects,  currently
**  only   component   objects,  positional   objects,    and data   objects.
**  'LAST_EXTERNAL_TYPE' is the last type of external objects.
**
**  'FIRST_REAL_TYPE' is the first  real  type, namely 'FIRST_CONSTANT_TYPE'.
**  'LAST_REAL_TYPE'  is the last   real  type, namely  'LAST_EXTERNAL_TYPE'.
**
**  'FIRST_VIRTUAL_TYPE' is   the first virtual type.  'LAST_VIRTUAL_TYPE' is
**  the last virtual type.
**
**  'FIRST_IMM_MUT_TYPE'  is the first  real  internal type of objects  which
**  might be mutable, 'LAST_IMM_MUT_TYPE' is the last such type.
**
**  The types *must* be sorted in this order, i.e., first the constant types,
**  then the record types, then the list types,  then the external types, and
**  finally the virtual types.
*/
#define FIRST_REAL_TYPE         0

#define FIRST_CONSTANT_TYPE     0
#define T_INT                   (FIRST_CONSTANT_TYPE+ 0)    /* immediate */
#define T_INTPOS                (FIRST_CONSTANT_TYPE+ 1)
#define T_INTNEG                (FIRST_CONSTANT_TYPE+ 2)
#define T_RAT                   (FIRST_CONSTANT_TYPE+ 3)
#define T_CYC                   (FIRST_CONSTANT_TYPE+ 4)
#define T_FFE                   (FIRST_CONSTANT_TYPE+ 5)    /* immediate */
#define T_PERM2                 (FIRST_CONSTANT_TYPE+ 6)
#define T_PERM4                 (FIRST_CONSTANT_TYPE+ 7)
#define T_BOOL                  (FIRST_CONSTANT_TYPE+ 8)
#define T_CHAR                  (FIRST_CONSTANT_TYPE+ 9)
#define T_FUNCTION              (FIRST_CONSTANT_TYPE+10)
#define T_FLAGS                 (FIRST_CONSTANT_TYPE+11)
#define LAST_CONSTANT_TYPE      T_FLAGS

#define IMMUTABLE               1

#define FIRST_IMM_MUT_TYPE      (LAST_CONSTANT_TYPE+1)
#define FIRST_RECORD_TYPE       FIRST_IMM_MUT_TYPE
#define T_PREC                  (FIRST_RECORD_TYPE+ 0)
#define LAST_RECORD_TYPE        (T_PREC+IMMUTABLE)

#define FIRST_LIST_TYPE         (LAST_RECORD_TYPE+1)
#define FIRST_PLIST_TYPE        FIRST_LIST_TYPE
#define T_PLIST                 (FIRST_LIST_TYPE+ 0)
#define T_PLIST_NDENSE          (FIRST_LIST_TYPE+ 2)
#define T_PLIST_DENSE           (FIRST_LIST_TYPE+ 4)
#define T_PLIST_DENSE_NHOM      (FIRST_LIST_TYPE+ 6)
#define T_PLIST_EMPTY           (FIRST_LIST_TYPE+ 8)
#define T_PLIST_HOM             (FIRST_LIST_TYPE+10)
#define T_PLIST_HOM_NSORT       (FIRST_LIST_TYPE+12)
#define T_PLIST_HOM_SSORT       (FIRST_LIST_TYPE+14)
#define T_PLIST_TAB             (FIRST_LIST_TYPE+16)
#define T_PLIST_TAB_NSORT       (FIRST_LIST_TYPE+18)
#define T_PLIST_TAB_SSORT       (FIRST_LIST_TYPE+20)
#define T_PLIST_CYC             (FIRST_LIST_TYPE+22)
#define T_PLIST_CYC_NSORT       (FIRST_LIST_TYPE+24)
#define T_PLIST_CYC_SSORT       (FIRST_LIST_TYPE+26)
#define LAST_PLIST_TYPE		(T_PLIST_CYC_SSORT+IMMUTABLE)
#define T_RANGE_NSORT           (FIRST_LIST_TYPE+28)
#define T_RANGE_SSORT           (FIRST_LIST_TYPE+30)
#define T_VECFFE                (FIRST_LIST_TYPE+32)
#define T_VECFFE_NSORT          (FIRST_LIST_TYPE+34)
#define T_VECFFE_SSORT          (FIRST_LIST_TYPE+36)
#define T_BLIST                 (FIRST_LIST_TYPE+38)
#define T_BLIST_NSORT           (FIRST_LIST_TYPE+40)
#define T_BLIST_SSORT           (FIRST_LIST_TYPE+42)
#define T_STRING                (FIRST_LIST_TYPE+44)
#define T_STRING_NSORT          (FIRST_LIST_TYPE+46)
#define T_STRING_SSORT          (FIRST_LIST_TYPE+48)
#define LAST_LIST_TYPE          (T_STRING_SSORT+IMMUTABLE)
#define LAST_IMM_MUT_TYPE       LAST_LIST_TYPE

#define FIRST_EXTERNAL_TYPE     (LAST_LIST_TYPE+1)
#define T_COMOBJ                (FIRST_EXTERNAL_TYPE+ 0)
#define T_POSOBJ                (FIRST_EXTERNAL_TYPE+ 1)
#define T_DATOBJ                (FIRST_EXTERNAL_TYPE+ 2)
#define LAST_EXTERNAL_TYPE      T_DATOBJ
#define LAST_REAL_TYPE          LAST_EXTERNAL_TYPE

#define FIRST_VIRTUAL_TYPE      (LAST_EXTERNAL_TYPE+1)
#define T_OBJECT                (FIRST_VIRTUAL_TYPE+ 0)
#define T_MAT_CYC               (FIRST_VIRTUAL_TYPE+ 1)
#define T_MAT_FFE               (FIRST_VIRTUAL_TYPE+ 2)
#define LAST_VIRTUAL_TYPE       T_MAT_FFE

#define FIRST_COPYING_TYPE      (LAST_REAL_TYPE + 1)
#define COPYING                 (FIRST_COPYING_TYPE - FIRST_RECORD_TYPE)
#define LAST_COPYING_TYPE       (LAST_REAL_TYPE + COPYING)

#define FIRST_PRINTING_TYPE     (LAST_COPYING_TYPE + 1)
#define PRINTING                (FIRST_PRINTING_TYPE - FIRST_RECORD_TYPE)
#define LAST_PRINTING_TYPE      (LAST_LIST_TYPE + PRINTING)


/****************************************************************************
**

*F  TYPE_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . type of an object
**
**  'TYPE_OBJ' returns the type of the object <obj>.
*/
#define TYPE_OBJ(obj)   (IS_INTOBJ( obj ) ? T_INT : \
                         (IS_FFE( obj ) ? T_FFE : TYPE_BAG( obj )))


/****************************************************************************
**
*F  SIZE_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . size of an object
**
**  'SIZE_OBJ' returns the size of the object <obj>.
*/
#define SIZE_OBJ        SIZE_BAG


/****************************************************************************
**
*F  ADDR_OBJ( <obj> ) . . . . . . . . . . . . . absolute address of an object
**
**  'ADDR_OBJ' returns the absolute address of the memory block of the object
**  <obj>.
*/
#define ADDR_OBJ        PTR_BAG


/****************************************************************************
**

*F  FAMILY_KIND( <kind> ) . . . . . . . . . . . . . . . . .  family of a kind
**
**  'FAMILY_KIND' returns the family of the kind <kind>.
*/
#define FAMILY_KIND(kind)	ELM_PLIST( kind, 1 )


/****************************************************************************
**
*F  FAMILY_OBJ( <obj> ) . . . . . . . . . . . . . . . . . family of an object
*/
#define FAMILY_OBJ(obj)		FAMILY_KIND( KIND_OBJ(obj) )


/****************************************************************************
**
*F  FLAGS_KIND( <kind> )  . . . . . . . . . . .  flags boolean list of a kind
**
**  'FLAGS_KIND' returns the flags boolean list of the kind <kind>.
*/
#define FLAGS_KIND(kind)	ELM_PLIST( kind, 2 )


/****************************************************************************
**
*F  SHARED_KIND( <kind> ) . . . . . . . . . . . . . . . shared data of a kind
**
**  'SHARED_KIND' returns the shared data of the kind <kind>.
*/
#define SHARED_KIND(kind)	ELM_PLIST( kind, 3 )
                        
                        
/****************************************************************************
**
*F  ID_KIND( <kind> ) . . . . . . . . . . . . . . . . . . . . .  id of a kind
**
**  'ID_KIND' returns the ID of  a kind.  Warning: if  GAP runs out of ID  it
**  will renumber all IDs.  Therefore the  corresponding routine must excatly
**  know where such numbers are stored.
*/
#define ID_KIND(kind)		ELM_PLIST( kind, 4 )


/****************************************************************************
**
*F  KIND_OBJ( <obj> ) . . . . . . . . . . . . . . . . . . . kind of an object
**
**  'KIND_OBJ' returns the kind of the object <obj>.
*/
#define KIND_OBJ(obj)   ((*KindObjFuncs[ TYPE_OBJ(obj) ])( obj ))

extern Obj (*KindObjFuncs[ LAST_REAL_TYPE+1 ]) ( Obj obj );


/****************************************************************************
**

*F  MUTABLE_TYPE( <type> )  . . . . . . . . . . mutable type of internal type
*/
#define MUTABLE_TYPE(type) \
    ( ( (type) < FIRST_IMM_MUT_TYPE ? (type) : \
       ( LAST_IMM_MUT_TYPE < (type) ? (type) : \
	( ((((type)-T_PLIST)&(~IMMUTABLE))+T_PLIST) ) ) ) )


/****************************************************************************
**
*F  IMMUTABLE_TYPE( <type> )  . . . . . . . . immutable type of internal type
*/
#define IMMUTABLE_TYPE(type) \
    ( ( (type) < FIRST_IMM_MUT_TYPE ? (type) : \
       ( LAST_IMM_MUT_TYPE < (type) ? (type) : \
	( ((((type)-T_PLIST)|IMMUTABLE)+T_PLIST) ) ) ) )


/****************************************************************************
**
*F  IS_MUTABLE_OBJ( <obj> ) . . . . . . . . . . . . . .  is an object mutable
**
**  'IS_MUTABLE_OBJ' returns   1 if the object  <obj> is mutable   (i.e., can
**  change due to assignments), and 0 otherwise.
*/
#define IS_MUTABLE_OBJ(obj) \
                        ((*IsMutableObjFuncs[ TYPE_OBJ(obj) ])( obj ))

extern Int (*IsMutableObjFuncs[ LAST_REAL_TYPE+1 ]) ( Obj obj );


/****************************************************************************
**
*F  IS_COPYABLE_OBJ( <obj> )  . . . . . . . . . . . . . is an object copyable
**
**  'IS_COPYABLE_OBJ' returns 1 if the object <obj> is copyable (i.e., can be
**  copied into a mutable object), and 0 otherwise.
*/
#define IS_COPYABLE_OBJ(obj) \
                        ((IsCopyableObjFuncs[ TYPE_OBJ(obj) ])( obj ))

extern Int (*IsCopyableObjFuncs[ LAST_REAL_TYPE+1 ]) ( Obj obj );


/****************************************************************************
**

*F  SHALLOW_COPY_OBJ( <obj> ) . . . . . . .  make a shallow copy of an object
**
**  'SHALLOW_COPY_OBJ' makes a shallow copy of the object <obj>.
*/
#define SHALLOW_COPY_OBJ(obj) \
                        ((*ShallowCopyObjFuncs[ TYPE_OBJ(obj) ])( obj ))


/****************************************************************************
**
*V  ShallowCopyObjFuncs[<type>] . . . . . . . . . .  shallow copier functions
*/
extern Obj (*ShallowCopyObjFuncs[ LAST_REAL_TYPE+1 ]) ( Obj obj );


/****************************************************************************
**

*F  CopyObj( <obj> )  . . . . . . . . . . make a structural copy of an object
**
**  'CopyObj' returns a  structural (deep) copy  of the object <obj>, i.e., a
**  recursive copy that preserves the structure.
*/
extern Obj CopyObj (
    Obj                 obj,
    Int                 mut );


/****************************************************************************
**
*F  COPY_OBJ(<obj>) . . . . . . . . . . . make a structural copy of an object
**
**  'COPY_OBJ'  implements  the first pass  of  'CopyObj', i.e., it makes the
**  structural copy of <obj> and marks <obj> as already copied.
**
**  Note that 'COPY_OBJ' and 'CLEAN_OBJ' are macros, so do not call them with
**  arguments that have sideeffects.
*/
#define COPY_OBJ(obj,mut) \
                        ((*CopyObjFuncs[ TYPE_OBJ(obj) ])( obj, mut ))


/****************************************************************************
**
*F  CLEAN_OBJ(<obj>)  . . . . . . . . . . . . . clean up object after copying
**
**  'CLEAN_OBJ' implements the second pass of 'CopyObj', i.e., it removes the
**  mark <obj>.
**
**  Note that 'COPY_OBJ' and 'CLEAN_OBJ' are macros, so do not call them with
**  arguments that have sideeffects.
*/
#define CLEAN_OBJ(obj) \
                        ((*CleanObjFuncs[ TYPE_OBJ(obj) ])( obj ))



/****************************************************************************
**
*V  CopyObjFuncs[<type>]  . . . . . . . . . . . .  table of copying functions
**
**  A package implementing a nonconstant object type <type> must provide such
**  functions      and     install them     in    'CopyObjFuncs[<type>]'  and
**  'CleanObjFuncs[<type>]'.
**
**  The function called  by 'COPY_OBJ' should  first create a  copy of <obj>,
**  somehow mark   <obj> as having  already been  copied, leave  a forwarding
**  pointer  to  the  copy  in <obj>,   and  then  copy all  subobjects  with
**  'COPY_OBJ'  recursively.  If  called   for an already  marked  object, it
**  should simply return the value  of the forward  pointer.  It should *not*
**  clear the mark, this is the job of 'CLEAN_OBJ' later.
**
**  The function  called by 'CLEAN_OBJ' should   clear the mark  left by the
**  corresponding 'COPY_OBJ' function,   remove the forwarding  pointer, and
**  then call 'CLEAN_OBJ'  for all subobjects recursively.  If called for an
**  already unmarked object, it should simply return.
*/
extern Obj (*CopyObjFuncs[ LAST_REAL_TYPE+COPYING+1 ]) ( Obj obj, Int mut );



/****************************************************************************
**
*V  CleanObjFuncs[<type>] . . . . . . . . . . . . table of cleaning functions
*/
extern void (*CleanObjFuncs[ LAST_REAL_TYPE+COPYING+1 ]) ( Obj obj );


/****************************************************************************
**

*F  PrintObj( <obj> ) . . . . . . . . . . . . . . . . . . . . print an object
**
**  'PrintObj' prints the object <obj>.
*/
extern void PrintObj (
            Obj                 obj );


/****************************************************************************
**
*V  PrintObjFuncs[<type>] . . . . . . . .  printer for objects of type <type>
**
**  'PrintObjFuncs' is  the dispatch  table that  contains  for every type of
**  objects a pointer to the printer for objects of this  type.  The  printer
**  is the function '<func>(<obj>)' that should be called to print the object
**  <obj> of this type.
*/
extern Obj  PrintObjThis;

extern Int  PrintObjIndex;

extern Int  PrintObjFull;

extern void (* PrintObjFuncs [ LAST_REAL_TYPE+PRINTING+1 ]) ( Obj obj );


/****************************************************************************
**
*V  PrintPathFuncs[<type>]  . . . . . . printer for subobjects of type <type>
**
**  'PrintPathFuncs'  is   the   dispatch table  that     contains for  every
**  appropriate type of objects a pointer to  the path printer for objects of
**  that type.  The path  printer is the function '<func>(<obj>,<indx>)' that
**  should be  called  to print  the  selector   that selects  the  <indx>-th
**  subobject of the object <obj> of this type.
*/
extern void (* PrintPathFuncs [ LAST_REAL_TYPE+PRINTING+1 ]) (
    Obj			obj,
    Int			indx );


/****************************************************************************
**

*F  IS_COMOBJ( <obj> )	. . . . . . . . . . . is an object a component object
*/
#define IS_COMOBJ(obj)            (TYPE_OBJ(obj) == T_COMOBJ)


/****************************************************************************
**
*F  KIND_COMOBJ( <obj> )  . . . . . . . . . . . .  kind of a component object
*/
#define KIND_COMOBJ(obj)          ADDR_OBJ(obj)[0]


/****************************************************************************
**
*F  SET_KIND_COMOBJ( <obj>, <val> ) . . .  set the kind of a component object
*/
#define SET_KIND_COMOBJ(obj,val)  (ADDR_OBJ(obj)[0] = (val))


/****************************************************************************
**

*F  IS_POSOBJ( <obj> )  . . . . . . . . . .  is an object a positional object
*/
#define IS_POSOBJ(obj)            (TYPE_OBJ(obj) == T_POSOBJ)


/****************************************************************************
**
*F  KIND_POSOBJ( <obj> )  . . . . . . . . . . . . kind of a positional object
*/
#define KIND_POSOBJ(obj)          ADDR_OBJ(obj)[0]


/****************************************************************************
**
*F  SET_KIND_POSOBJ( <obj>, <val> ) . . . set the kind of a positional object
*/
#define SET_KIND_POSOBJ(obj,val)  (ADDR_OBJ(obj)[0] = (val))
 

/****************************************************************************
**

*F  IS_DATOBJ( <obj> )	. . . . . . . . . . . . .  is an object a data object
*/
#define IS_DATOBJ(obj)            (TYPE_OBJ(obj) == T_DATOBJ)


/****************************************************************************
**
*F  KIND_DATOBJ( <obj> )  . . . . . . . . . . . . . . . kind of a data object
*/
#define KIND_DATOBJ(obj)          ADDR_OBJ(obj)[0]


/****************************************************************************
**
*F  SET_KIND_DATOBJ( <obj>, <val> )  . . . . .  set the kind of a data object
*/
#define SET_KIND_DATOBJ(obj,val)  (ADDR_OBJ(obj)[0] = (val))


/****************************************************************************
**

*F  InitObjects() . . . . . . . . . . . . . .  initialize the objects package
**
**  'InitObjects' initializes the objects package.
*/
extern void InitObjects ( void );


/****************************************************************************
**

*E  objects.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
