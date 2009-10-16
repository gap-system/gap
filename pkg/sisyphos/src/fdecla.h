/********************************************************************/
/*                                                                  */
/*  Module        : F-Arithmetik declarations                       */
/*                                                                  */
/*  Description :                                                   */
/*     Declarations of function pointers for Fp arithmetik.         */
/*                                                                  */
/********************************************************************/

/* 	$Id: fdecla.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: fdecla.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:25:28  pluto
 * Initial version under RCS control.
 *	 */

#ifdef ANSI
extern char (*add)( char, char );
extern char (*mul)( char, char );
extern void (*add_vector)( VEC, VEC, register int );
extern void (*suba_vector)( VEC, VEC, register int );
extern void (*subb_vector)( VEC, VEC, register int );
extern void (*smul_vector)( char, VEC, register int );
extern void (*add_mult)( char, VEC, VEC, register int );
extern void (*zero_col)( long row, long col );
extern void (*zeroh_col)( long row, long col, int end );
extern void (*zeroe_col)( long row, long col, int end );
extern int (*gauss_eliminate)( void );
extern VEC (*matrix_mul)( VEC mat1, VEC mat2 );
#else
extern char (*add)();
extern char (*mul)();
extern void (*add_vector)();
extern void (*suba_vector)();
extern void (*subb_vector)();
extern void (*smul_vector)();
extern void (*add_mult)();
extern void (*zero_col)();
extern void (*zeroh_col)();
extern void (*zeroe_col)();
extern int (*gauss_eliminate)();
extern VEC (*matrix_mul)();
#endif

