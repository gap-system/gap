/********************************************************************/
/*                                                                  */
/*  Module        : Storage                                         */
/*                                                                  */
/*  Description :                                                   */
/*     This module supplies the basic routines for dynamic storage  */
/*     management, i.e. routines for reservation of memory blocks,  */
/*     for allocation and deallocation of parts of those blocks,    */
/*     for getting and setting pointers into the blocks.            */
/*                                                                  */
/********************************************************************/

/* 	$Id: storage.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: storage.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:09:45  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: storage.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#ifdef ANSI
#include <stdlib.h>
#endif
#include "aglobals.h"
#include "fdecla.h"
# include	"error.h"
#define ALLOC
# include	"storage.h"

#ifdef LASER
char *lmalloc();
int bcopy();
#define malloc( a ) lmalloc (a ) 
#define memcpy( a, b, c ) bcopy ( a, b, c )
#endif

#define MSTATS

/* global variables */

struct stack_item {
	long sav_top;
	long sav_free;
};

#define MSTACKSIZE 128

static struct stack_item m_stack[MSTACKSIZE];
static long bottom; 		  /* start of memory block   */
static long t_bottom;		  /* start of temporary block */
static long top;			  /* current top of block    */
static long t_top;			  /* current top of temporary block */
static long maxtop; 		  /* end of memory block     */
static long t_maxtop;		  /* end of temporary block */
static long free_b	= 0; 	  /* number of deleted bytes */
static long t_free_b = 0;	  /* number of deleted bytes of temporary heap */
static int  mtop = 0;		  /* stack pointer of mark stack */

#ifdef MSTATS
static long max_t_usage = 0;	  /* maximal runtime top of temporary heap */
static long max_m_usage = 0;	  /* maximal runtime top of permanent heap */
#endif

static  void (*(*sgalloc)(long));
static  void (*(*sgcalloc)(long));
static  void (*sgpustack)(void);
static  void (*sgpostack)(void);
static  void (*sgset_top)(void *);
static  void (*(*sgget_top)(void));

void *get_memblock (long int amount)
{
	bottom = top = ( long ) malloc ( amount );
	maxtop = bottom + amount - 1;
	return ( (char *) bottom );
}

void *tget_memblock (long int amount)
{
	t_bottom = t_top = ( long ) malloc ( amount );
	t_maxtop = t_bottom + amount - 1;
	return ( (char *) t_bottom );
}

void free_memblock (void *pointer)
{
	bottom = maxtop = 0L;
	free ( (void *) pointer );
}

void tfree_memblock (void *pointer)
{
	t_bottom = t_maxtop = 0L;
	free ( (void *) pointer );
}

int is_temporary ( void *pointer )
{
	return ( (void *)t_bottom <= pointer && pointer <= (void *)t_top );
}

int is_permanent ( void *pointer )
{
	return ( (void *)bottom <= pointer && pointer <= (void *)top );
}

void *allocate (long int nbytes)
{
	register char *pointer;

	nbytes = ALIGN4 ( nbytes );
	if ( top + nbytes > maxtop ) {
		fprintf ( stderr, "fatal error: memory exhausted\n" ); 
		exit ( -1 );
	}
	pointer = (char *) top;
	top += nbytes;
#ifdef MSTATS
	if ( top > max_m_usage )
		max_m_usage = top;
#endif
	return ( pointer );
}

void *tallocate (long int nbytes)
{
	register char *pointer;

	nbytes = ALIGN4 ( nbytes );
	if ( t_top + nbytes > t_maxtop ) {
		fprintf ( stderr, "fatal error: temporary memory exhausted\n" ); 
		exit ( -1 );
	}
	pointer = (char *) t_top;
	t_top += nbytes;
#ifdef MSTATS
	if ( t_top > max_t_usage )
		max_t_usage = t_top;
#endif
	return ( pointer );
}

void *callocate (long int nbytes)
{
	register char *pointer;
	register long dim = nbytes;

	nbytes = ALIGN4 ( nbytes );
	if ( top + nbytes > maxtop ) {
		fprintf ( stderr, "fatal error: memory exhausted\n" ); 
		exit ( -1 );
	}
	pointer = (char *) top;
	top += nbytes;
#ifndef LASER
	memset ( (void *)pointer, 0, dim );
#else
	bzero ( (char *)pointer, dim );
#endif
#ifdef MSTATS
	if ( top > max_m_usage )
		max_m_usage = top;
#endif
	return ( pointer );
}

void *tcallocate (long int nbytes)
{
	register char *pointer;
	register long dim = nbytes;

	nbytes = ALIGN4 ( nbytes );
	if ( t_top + nbytes > t_maxtop ) {
		fprintf ( stderr, "fatal error: temporary memory exhausted\n" ); 
		exit ( -1 );
	}
	pointer = (char *) t_top;
	t_top += nbytes;
#ifndef LASER
	memset ( (void *)pointer, 0, dim );
#else
	bzero ( (char *)pointer, dim );
#endif
#ifdef MSTATS
	if ( t_top > max_t_usage )
		max_t_usage = t_top;
#endif
	return ( pointer );
}

void *get_top (void)
{
	return ( (char *) top ); 
}

void *tget_top (void)
{
	return ( (char *) t_top ); 
}

void set_top (void *newtop)
{
	top = ( long ) newtop;
}

void tset_top (void *newtop)
{
	t_top = ( long ) newtop;
}

void clear (void)
{
	top = bottom;
}

void clear_t (void)
{
	t_top = t_bottom;
}

void push_stack(void)
{
	m_stack[mtop].sav_top  = top;
	m_stack[mtop++].sav_free = free_b;
}

void pop_stack(void)
{
	top	  = m_stack[--mtop].sav_top;
	free_b = m_stack[mtop].sav_free;
}

void tpush_stack(void)
{
	m_stack[mtop].sav_top  = t_top;
	m_stack[mtop++].sav_free = t_free_b;
}

void tpop_stack(void)
{
	t_top	  = m_stack[--mtop].sav_top;
	t_free_b = m_stack[mtop].sav_free;
}

void save_memory_stack (void)
{
	sgalloc = gallocate;
	sgcalloc = gcallocate;
	sgpustack = gpush_stack;
	sgpostack = gpop_stack;
	sgset_top = gset_top;
	sgget_top = gget_top;
}

void restore_memory_stack (void)
{
	gallocate = sgalloc;
	gcallocate = sgcalloc;
	gpush_stack = sgpustack;
	gpop_stack = sgpostack;
	gset_top = sgset_top;
	gget_top = sgget_top;
}
	
void use_temporary_stack (void)
{
	gallocate = tallocate;
	gcallocate = tcallocate;
	gpush_stack = tpush_stack;
	gpop_stack = tpop_stack;
	gset_top = tset_top;
	gget_top = tget_top;
}

void use_permanent_stack (void)
{
	gallocate = allocate;
	gcallocate = callocate;
	gpush_stack = push_stack;
	gpop_stack = pop_stack;
	gset_top = set_top;
	gget_top = get_top;
}
	
void init_memory_stack (void)
{
	gallocate = sgalloc = tallocate;
	gcallocate = sgcalloc = tcallocate;
	gpush_stack = sgpustack = tpush_stack;
	gpop_stack = sgpostack = tpop_stack;
	gset_top = sgset_top = tset_top;
	gget_top = sgget_top = tget_top;
	mtop = 0;
}

void get_memory_info (long int *mem_bottom, long int *mem_top, long int *mem_maxtop, long int *mem_free)
{
	*mem_bottom = bottom;
	*mem_top    = top;
	*mem_maxtop = maxtop;
	*mem_free   = free_b;
}

void show_memory_info (void)
{
	printf ( "bottom of permanent memory heap : %ld\n", bottom );
	printf ( "top of permanent memory heap    : %ld\n", top );
	printf ( "used                            : %ld\n\n", top - bottom );
	printf ( "bottom of temporary memory heap : %ld\n", t_bottom );
	printf ( "top of temporary memory heap    : %ld\n", t_top );
	printf ( "used                            : %ld\n", t_top - t_bottom );
}

void init_mem_stats (void)
{
#ifdef MSTATS
	max_m_usage = top;
	max_t_usage = t_top;
#endif
}

void memory_usage (void)
{
#ifdef MSTATS
	printf ( "memory usage:\n" );
	printf ( "%12ld bytes of permanent heap\n", max_m_usage - bottom );
	printf ( "%12ld bytes of temporary heap\n", max_t_usage - t_bottom );
#endif
}

/* end of module Storage */
