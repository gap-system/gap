/* 	$Id: storage.h,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: storage.h,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:25:52  pluto
 * Initial version under RCS control.
 *	 */

#undef ALLOC_CLS
#ifdef ALLOC
#	define ALLOC_CLS /* empty */
#else
#	define ALLOC_CLS extern
#endif

ALLOC_CLS void (*(*gallocate)(long));
ALLOC_CLS void (*(*gcallocate)(long));
ALLOC_CLS void (*gpush_stack)(void);
ALLOC_CLS void (*gpop_stack)(void);
ALLOC_CLS void (*gset_top)(void *);
ALLOC_CLS void (*(*gget_top)(void));

#define ALLOCATE (*gallocate)
#define CALLOCATE (*gcallocate)
#define PUSH_STACK (*gpush_stack)
#define POP_STACK (*gpop_stack)
#define SET_TOP (*gset_top)
#define GET_TOP (*gget_top)

void *get_memblock 			_(( long amount ));
void *tget_memblock 		_(( long amount ));
void free_memblock 			_(( void *pointer ));
void tfree_memblock 		_(( void *pointer ));
void *allocate				_(( long nbytes ));
void *tallocate			_(( long nbytes ));
void *callocate			_(( long nbytes ));
void *tcallocate 			_(( long nbytes ));
void *get_top				_(( void ));
void *tget_top				_(( void ));
void set_top 				_(( void *newtop ));
void tset_top 				_(( void *newtop ));
void clear				_(( void ));
void clear_t				_(( void ));
void push_stack			_(( void ));
void pop_stack				_(( void ));
void tpush_stack			_(( void ));
void tpop_stack			_(( void ));
void save_memory_stack 		_(( void ));
void restore_memory_stack 	_(( void ));
void use_temporary_stack 	_(( void ));
void use_permanent_stack 	_(( void ));
void init_memory_stack 		_(( void ));
void get_memory_info 		_(( long *mem_bottom, long *mem_top, long *mem_maxtop, long *mem_free ));
void show_memory_info 		_(( void ));
int is_temporary 			_(( void *pointer ));
int is_permanent			_(( void *pointer ));

