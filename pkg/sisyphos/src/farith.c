/********************************************************************/
/*                                                                  */
/*  Module        : FpArith                                         */
/*                                                                  */
/*  Description :                                                   */
/*     The basic routines for addition, subtraction, scalar         */
/*     multiplication as well as input and output are contained in  */
/*     this module.                                                 */
/*                                                                  */
/********************************************************************/

/* 	$Id: farith.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: farith.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 1.3  1995/12/15 09:10:44  pluto
 * 	Changed to array indexing instead of pointer usage.
 *
 * 	Revision 1.2  1995/01/05 17:10:25  pluto
 * 	Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: farith.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include	"solve.h"

char (*add)				_(( char, char ));
char (*mul)				_(( char, char ));
void (*add_vector)			_(( VEC, VEC, register int ));
void (*suba_vector) 		_(( VEC, VEC, register int ));
void (*subb_vector) 		_(( VEC, VEC, register int ));
void (*smul_vector) 		_(( char, VEC, register int ));
void (*add_mult)			_(( char, VEC, VEC, register int ));
VEC (*matrix_mul)			_(( VEC, VEC ));

int prime;

#ifndef TT

/* elementary arithmetic routines for F2 */

char f2_add ( register char v1, register char v2 )
{
    return ( v1 ^ v2 );
}

char f2_mul ( register char v1, register char v2 )
{
    return ( v1 & v2 );
}

void add2_vector (VEC vector1, VEC vector2, register int dim)
{
	register int i;
	for ( i = 0; i < dim; i++ )
		vector2[i] ^= vector1[i];
}

/* suba : vector1 - vector2 -> vector2
   subb : vector2 - vector1 -> vector2 */

void suba2_vector (VEC vector1, VEC vector2, register int dim)
{
	register int i;
	for ( i = 0; i < dim; i++ )
		vector2[i] ^= vector1[i];
}

void subb2_vector (VEC vector1, VEC vector2, register int dim)
{
	register int i;
	for ( i = 0; i < dim; i++ )
		vector2[i] ^= vector1[i];
}

void smul2_vector ( char value, VEC vector, register int dim )
{
	register int i;
	for ( i = 0; i < dim; i++ )
        vector[i] &= value;
}

void add2_mult ( register char val, VEC vector1, VEC vector2,
			  register int dim )
{
	register int i;
	for ( i = 0; i < dim; i++ )
	   vector2[i] ^= (vector1[i] & val);
}

/* elementary arithmetic routines for F3 */

char f3_add ( register char v1, register char v2 )
{
    register char x;
    x = v1 + v2;
    return ( x > 2 ? x-3 : x );
}

char f3_mul ( register char v1, register char v2 )
{
    register char x;
    if ( v1 && v2 ) {
	   x = v1 ^ v2;
	   return ( x ? 2 : 1 );
    }
    else
	   return ( 0 );
}

void add3_vector (VEC vector1, VEC vector2, register int dim)
{
	register char x;
	register int i;
	for ( i = 0; i < dim; i++ ) {
	   x = vector1[i] + vector2[i];
	   vector2[i] = x > 2 ? x - 3 : x;
	}
}

/* suba : vector1 - vector2 -> vector2 
   subb : vector2 - vector1 -> vector2 */

void suba3_vector (VEC vector1, VEC vector2, register int dim)
{
	register char x;
	register int i;
	for ( i = 0; i < dim; i++ ) {
	   x = vector1[i] - vector2[i] + 3;
	   vector2[i] = x > 2 ? x - 3 : x;
	}
}

void subb3_vector (VEC vector1, VEC vector2, register int dim)
{
	register char x;
	register int i;
	for ( i = 0; i < dim; i++ ) {
	   x = vector2[i] - vector1[i] + 3;
	   vector2[i] = x > 2 ? x - 3 : x;
	}
}

void smul3_vector ( char value, VEC vector, register int dim )
{
	register char x;
	register int i;
	for ( i = 0; i < dim; i++ ) {
		x = vector[i];
		if ( x ) {
			x ^= value;
			vector[i] = x ? 2 : 1;
		}
	}
}

void add3_mult ( register char val, VEC vector1, VEC vector2,
			  register int dim )
{
	register char x, y;
	register int i;
	for ( i = 0; i < dim; i++ ) {
		y = f3_mul ( vector1[i], val );	
		x = vector2[i] + y;
		vector2[i] = x > 2 ? x - 3 : x;
	}
}

#endif /* ifndef TT */


/* elementary arithmetic routines for Fp, p != 2,3 */

char fp_add ( register char v1, register char v2 )
{
    register char x;
    x = v1 + v2;
    return ( x >= prime ? x-prime : x );
}

char fp_mul ( register char v1, register char v2 )
{
    register char x;
    if ( v1 && v2 ) {
	   x = v1 * v2;
	   return ( x % prime );
    }
    else
	   return ( 0 );
}

char fp_inv ( register char v1 )
{
    register int x = v1;
    register int y = 1;
    while ( x != 1 ) {
	   y = x;
	   x *= v1;
	   x %= prime;
    }
    return ( y );
}

void addp_vector (VEC vector1, VEC vector2, register int dim)
{
	register char x;
	register int i;
	for ( i = 0; i < dim; i++ ) {
		x = vector1[i] + vector2[i];
		vector2[i] = x >= prime ? x - prime : x;
	}
}

/* suba : vector1 - vector2 -> vector2 
   subb : vector2 - vector1 -> vector2 */

void subap_vector (VEC vector1, VEC vector2, register int dim)
{
	register char x;
	register int i;
	for ( i = 0; i < dim; i++ ) {
		x = vector1[i] - vector2[i] + prime;
		vector2[i] = x >= prime ? x - prime : x;
	}
}

void subbp_vector (VEC vector1, VEC vector2, register int dim)
{
	register char x;
	register int i;
	for ( i = 0; i < dim; i++ ) {
		x = vector2[i] - vector1[i] + prime;
		vector2[i] = x >= prime ? x - prime : x;
	}
}

void sub_mult ( register char val, VEC vector1, VEC vector2, register int dim )
{
	register char x, y;
	register int i;
	for ( i = 0; i < dim; i++ ) {
		y = fp_mul ( vector1[i], val );	
		x = vector2[i] - y + prime;
		vector2[i] = x >= prime ? x - prime : x;
	}
}

void addp_mult ( register char val, VEC vector1, VEC vector2,
			  register int dim )
{
	register char x, y;
	register int i;
	for ( i = 0; i < dim; i++ ) {
		y = fp_mul ( vector1[i], val );	
		x = vector2[i] + y;
		vector2[i] = x >= prime ? x - prime : x;
	}
}

void smulp_vector ( char value, VEC vector, register int dim )
{
	register char x;
	register int i;
	for ( i = 0; i < dim; i++ ) {
		x = vector[i];
		if ( x ) {
			x *= value;
			vector[i] = x % prime;
		}
	}
}

/* common routines */

int read_vector (VEC vector)
{
    register int dim = 0;
    short elem;
    do {
	   printf ( "vector[%d] = ", dim );
	   scanf ( "%hd", &elem );
	   if ( elem != prime ) {
		  vector[dim++] = elem;
	   }
    } while ( elem != prime );
    return ( dim );
}

void write_vector ( VEC vector, int dim )
{
    register int i;
    for ( i = 0; i < dim; i++ )
	   printf ( "%2d", vector[i] );
    printf ( "\n" );
}

void swap_arith (int p)
{
    switch ( p ) {
    case 2:
	   add = f2_add;
	   mul = f2_mul;
	   add_vector = add2_vector;
	   suba_vector = suba2_vector;
	   subb_vector = subb2_vector;
	   smul_vector = smul2_vector;
	   add_mult = add2_mult;
	   zero_col = zero2_col;
	   zeroh_col = zeroh2_col;
	   zeroe_col = zeroe2_col;
	   gauss_eliminate = gauss2_eliminate;
	   matrix_mul = matrix2_mul;
	   break;
    case 3:
	   add = f3_add;
	   mul = f3_mul;
	   add_vector = add3_vector;
	   suba_vector = suba3_vector;
	   subb_vector = subb3_vector;
	   smul_vector = smul3_vector;
	   add_mult = add3_mult;
	   zero_col = zero3_col;
	   zeroh_col = zeroh3_col;
	   zeroe_col = zeroe3_col;
	   gauss_eliminate = gauss3_eliminate;
	   matrix_mul = matrixp_mul;
	   break;
    default:
	   add = fp_add;
	   mul = fp_mul;
	   add_vector = addp_vector;
	   suba_vector = subap_vector;
	   subb_vector = subbp_vector;
	   smul_vector = smulp_vector;
	   add_mult = addp_mult;
	   zero_col = zerop_col;
	   zeroh_col = zerohp_col;
	   zeroe_col = zeroep_col;
	   gauss_eliminate = gaussp_eliminate;
	   matrix_mul = matrixp_mul;
    }
    prime = p;
}

/* end of module fparith */

