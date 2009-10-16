/********************************************************************/
/*                                                                  */
/*  Module        : SolveEquations                                  */
/*                                                                  */
/*  Description :                                                   */
/*     This module supplies a function for solving linear           */
/*     inhomogenous equations over F3. A special solution and a     */
/*     complete system of fundamental solutions are returned.       */
/*                                                                  */
/********************************************************************/

/* 	$Id: solve.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: solve.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.1  1995/08/01 16:29:07  pluto
 * 	Initialized 'rank' with 0 in 'dgauss_eliminate'.
 *
 * 	Revision 3.0  1995/06/23 09:55:42  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	New function 'dgauss_eliminate' using dynamic storage.
 *
 * Revision 1.3  1995/03/20  09:48:25  pluto
 * Added 'get_rank' function to compute bases for vector spaces.
 *
 * Revision 1.2  1995/01/05  17:11:28  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: solve.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#ifdef ANSI
#include <stdlib.h>
#endif
#include "aglobals.h"
#include "fdecla.h"
#include	"storage.h"
#define ALLOC
#include	"solve.h"

extern int prime;

static VEC indicator;
static long cxdim, cydim;
static char **Matrix;
static VEC Absolut, Inhom;

int fundamental_solutions	_(( void ));
int dfundamental_solutions 	_(( VEC **fs ));

void showm (void)
{
	long i, j;
      for ( i = 0; i < y_dim; i++ ) {
      	for ( j = 0; j < x_dim; j++ )
      		printf ( "%1d", Matrix[i][j] );
      	printf ( "\n" ); 
      }
      puts ( "Absolut" );
      write_vector ( Absolut, y_dim );
}

/* internal functions */

/* F2 routines */

/*
void zero2_col ( row, col )
long row, col;
{
      register long i = y_dim;
	 register int wid;
	 register VEC r = Matrix[row];
	 register VEC s;
	 
      while ( i-- ) {
            if ( i != row ) {
                  if ( Matrix[i][col] != 0 ) {
			   		s = Matrix[i];
			   		for ( wid = (int)col+1; wid--; )
						s[wid] ^= r[wid];
                       	Absolut[i] ^= Absolut[row];
                  }
            }
      }
} */

void zero2_col ( long row, long col )
{
 	register long i = y_dim;
	while ( i ) {
		i--;
		if ( i != row ) {
			if ( Matrix[i][col] != 0 ) {
				add2_vector ( Matrix[row], Matrix[i], (int)col+1 );
				Absolut[i] ^= Absolut[row];
			}
		}
	}
}

void zeroh2_col ( long row, long col, int fend )
{
      register long i = fend;
      do {
            if ( i != row ) {
                  if ( Matrix[i][col] != 0 )
                        add2_vector ( Matrix[row], Matrix[i], (int)cxdim );
            }
      } while ( ++i < cydim );
}

void zeroe2_col ( long row, long col, int cstart )
{
	register long i = cydim;
	while ( i-- ) {
		if ( i != row ) {
			if ( Matrix[i][col] != 0 )
				add2_vector ( Matrix[row], Matrix[i],
					(int)(cxdim+cstart) );
		}
	}
}

int gauss2_eliminate (void)
{
      register long ix;
      register long iy = 0;
      register char value;
      int rank = 0;
      int solvable = TRUE;
      
	 indicator = CALLOCATE ( x_dim );
      while ( iy < y_dim && solvable ) {
            ix = x_dim - 1;
            while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
            if ( value ) {
                  rank++;
                  indicator[ix] = TRUE;
                  zero2_col ( iy, ix );
            }
            else
            	solvable = !Absolut[iy];
		iy++;
      }
      if ( solvable )
	      return ( rank );
	else
		return ( -1 );
}

/* F3 routines */

void zero3_col ( long row, long col )
{
     register long i = y_dim;
     register char x;
	while ( i--) {
		if ( i != row ) {
                  switch ( Matrix[i][col] ) {
                        case 1:
                              x = Absolut[i] + 3;
                              subb3_vector ( Matrix[row], Matrix[i], (int)col+1 );
                             	x -= Absolut[row];
                             	Absolut[i] = x > 2 ? x - 3 : x;
                              break;
                        case 2:
                              x = Absolut[i];
                              add3_vector ( Matrix[row], Matrix[i], (int)col+1 );
                             	x += Absolut[row];
                             	Absolut[i] = x > 2 ? x - 3 : x;
                  }
            }
      }
}

void zeroh3_col ( long row, long col, int fend )
{
      register long i = fend;
      do {
            if ( i != row ) {
                  switch ( Matrix[i][col] ) {
                        case 1:
                              subb3_vector ( Matrix[row], Matrix[i], (int)cxdim );
                              break;
                        case 2:
                              add3_vector ( Matrix[row], Matrix[i], (int)cxdim );
                  }
            }
      } while ( ++i < cydim );
}

void zeroe3_col ( long row, long col, int cstart )
{
	register long i = cydim;
	while ( i-- ) {
		if ( i != row ) {
			switch ( Matrix[i][col] ) {
				case 1:
					subb3_vector ( Matrix[row], Matrix[i], (int)(cxdim+cstart) );
					break;
				case 2:
					add3_vector ( Matrix[row], Matrix[i], (int)(cxdim+cstart) );
			}
		}
	}
}

int gauss3_eliminate (void)
{
      register long ix;
      register long iy = 0;
      register char x, value;
      int rank = 0;
      int solvable = TRUE;
      
	 indicator = CALLOCATE ( x_dim );
      while ( iy < y_dim && solvable ) {
            ix = x_dim - 1;
            while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
            switch ( value ) {
                  case 2:
                        smul3_vector ( 2, Matrix[iy], x_dim );
                        rank++;
                        indicator[ix] = TRUE;
                        x = Absolut[iy] << 1;
                        Absolut[iy] = x > 3 ? 1 : x;
                        zero3_col ( iy, ix );
                        break;
                  case 1:
                        rank++;
                        indicator[ix] = TRUE;
                        zero3_col ( iy, ix );
                        break;
                  default:
                  	solvable = !Absolut[iy];
            }
		iy++;
      }
      if ( solvable )
	      return ( rank );
	else
		return ( -1 );
}

/* Fp routines */

void zerop_col ( long row, long col )
{
    register long i = y_dim;
    register char x, y;
    while ( i--) {
	   if ( i != row ) {
		  if ( (x = Matrix[i][col]) != 0 ) {
			 sub_mult ( x, Matrix[row], Matrix[i], (int)col+1 );
			 y = fp_mul ( x, Absolut[row] );
			 x = Absolut[i] + prime - y;
			 Absolut[i] = x >= prime ? x - prime : x;
		  }
	   }
    }
}

void zerohp_col ( long row, long col, int fend )
{
	register long i = fend;
	register char x;
	do {
		if ( i != row )
			if ( (x = Matrix[i][col]) != 0 ) 
				sub_mult ( x, Matrix[row], Matrix[i], (int)col+1 );
	} while ( ++i < cydim );
}

void zeroep_col ( long row, long col, int cstart )
{
    register long i = cydim;
    register char x;
    while ( i-- ) {
	   if ( i != row ) {
		  if ( (x = Matrix[i][col]) != 0 ) 
			 sub_mult ( x, Matrix[row], Matrix[i], (int)(cxdim+cstart) );
	   }
    }
}

int gaussp_eliminate (void)
{
	register long ix;
	register long iy = 0;
	register char value;
	int rank = 0;
	int solvable = TRUE;
	 
	indicator = CALLOCATE ( x_dim );
	while ( iy < y_dim && solvable ) {
		ix = x_dim - 1;
		while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
		if ( value != 0 ) {
			value = fp_inv ( value );
			smulp_vector ( value, Matrix[iy], x_dim );
			rank++;
			indicator[ix] = TRUE;
			Absolut[iy] = fp_mul ( value, Absolut[iy] );
			zerop_col ( iy, ix );
		}
		else
			solvable = !Absolut[iy];
		iy++;
	}
	if ( solvable )
		return ( rank );
	else
		return ( -1 );
}

/* common routines */

int fundamental_solutions (void)
{
      register long ix, iy;
      int solvable = TRUE;
      register char value;
      long j;

      for ( ix = 0; ix < x_dim; ix++ ) {
            if ( !indicator[ix] ) {
                  fsolution[ix] = CALLOCATE ( x_dim );
                  *(fsolution[ix]+ix) = prime-1;
            }
            else
                  fsolution[ix] = NIL;
      }
      iy = 0;
      while ( iy < y_dim && solvable ) {
            ix = x_dim - 1;
            while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
            if ( value )
                  Inhom[ix] = Absolut[iy];
            else
                  solvable = !Absolut[iy];
            for ( j = ix-1; j > -1; j-- ) {
                  if ( ( value = Matrix[iy][j] ) != 0 )
                        *(fsolution[j]+ix) = value;
            }
            iy++;
      }
      return ( solvable );
}

/* end of internal functions */

int solve_equations ( int x, int y )
{
      int rank;
      
	 x_dim = x;
	 y_dim = y;
	 Matrix = matrix;
	 Absolut = absolut;
	 Inhom = inhom;
      zero_vector ( Inhom, x_dim );
      rank = GAUSS_ELIMINATE();
      if ( ( rank != -1 ) && fundamental_solutions() )
		return ( rank );
      else
      	return ( -1 );
}

int gauss_p_eliminate (int x, int y)
{
	register long ix, iy, i;
	register char value;
	int rank = 0;

	Matrix = matrix;
	Absolut = absolut;
	Inhom = inhom;
	cxdim = x;
	cydim = y;
	
	for ( i = 0; i < y; i++ ) {
		zero_vector ( Matrix[i]+(long)x, y );
		Matrix[(long)i][(long)(x+i)] = 1;
	}

	for ( iy = 0; iy < y; iy++ ) {
		ix = x - 1;
		while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
		if ( value  ) {
			rank++;
			if ( value != 1 )
				SMUL_VECTOR ( fp_inv ( value ), Matrix[iy], (int)(x+y) );
			ZEROE_COL ( iy, ix, y );
		}
	}
	return ( rank );
}

int complement (int c_start, int cx_dim, int cy_dim)
                            
/*	Let {Matrix[c_start],..,Matrix[cy_dim-1]} be a generating set for a
	vector space V. Let S := {Matrix[0],...,Matrix[c_start-1]} be a subset
	of V. Then complement computes a basis for V/<S> (fsolution) and
	returns the dimension of this space (c_dim).
*/
{
     register long ix, iy, i;
     register char value;
     int c_dim = 0;

	Matrix = matrix;
	Absolut = absolut;
	Inhom = inhom;
     cxdim = cx_dim;
     cydim = cy_dim;
     for ( iy = 0; iy < cy_dim; iy++ ) {
            ix = cxdim - 1;
            while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
            if ( value  ) {
            	if ( value != 1 )
            		SMUL_VECTOR ( fp_inv ( value ), Matrix[iy], (int)cxdim );
                  if ( iy < c_start )
                        ZEROH_COL ( iy, ix, 0 );
                  else
                        ZEROH_COL ( iy, ix, c_start );
            }
      }
      for ( i = c_start; i < cy_dim; i++ ) {
            ix = cx_dim - 1;
            while ( ( value = Matrix[i][ix] ) == 0 && ix ) ix--;
            if ( value ) {
            	fsolution[c_dim] = ALLOCATE ( cx_dim );
                  copy_vector ( Matrix[i], fsolution[c_dim++], cx_dim );
		}
      }
      return ( c_dim );
}

void init_matrix (void)
{
	register int i;
	
	if ( (matrix = malloc ( YMAX * sizeof ( char *) )) == NULL )
		fprintf ( stderr, "matrix amount not available!!!\n" );
	for ( i = 0; i < YMAX; i++ )
		if ( (matrix[i] = malloc ( XMAX )) == NULL )
			fprintf ( stderr, "matrix[%1d] amount not available!!!\n", i );
}

void use_static_matrix (void)
{
	Matrix = matrix;
	Absolut = absolut;
	Inhom = inhom;
}

/* routines using dynamic storage */

int dfundamental_solutions ( VEC **fs )
{
    register long ix, iy;
    int solvable = TRUE;
    register char value;
    long j;
    VEC *fsol = *fs;
    int *map;
    int cnt = 0;

    map = CALLOCATE ( x_dim*sizeof ( int ) );
    for ( ix = 0; ix < x_dim; ix++ ) {
	   if ( !indicator[ix] ) {
		  map[ix] = cnt;
		  fsol[cnt] = CALLOCATE ( x_dim );
		  *(fsol[cnt++]+ix) = prime-1;
	   }
    }
    iy = 0;
    while ( iy < y_dim && solvable ) {
	   ix = x_dim - 1;
	   while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
	   if ( value )
		  Inhom[ix] = Absolut[iy];
	   else
		  solvable = !Absolut[iy];
	   for ( j = ix-1; j > -1; j-- ) {
		  if ( ( value = Matrix[iy][j] ) != 0 )
			 *(fsol[map[j]]+ix) = value;
	   }
	   iy++;
    }
    return ( solvable );
}

void get_sle_space ( char ***M, VEC *abs, VEC *inh, int x, int y )
/* get dynamic storage for system of linear equations with <x> variables
   and <y> equations.
   <M>   is the address of the coefficient matrix,
   <abs> is the address of the vector on the right hand side,
   <inh> is the address of the vector that will contain a special solution.
   */
{
    register int i;
    
    *M = ARRAY ( y, VEC );
    *abs = ALLOCATE ( y );
    *inh = ALLOCATE ( x );
    for ( i = 0; i < y; i++ )
	   (*M)[i] = ALLOCATE ( x );
}

int dsolve_equations ( char **M, VEC abs, VEC inh, int x, int y, VEC **fs )
/* solve inhomogeneous system of linear equations with coefficient matrix
   <M> and  right hand side <abs>. <inh> will contain a special solution
   and <fs> a system of fundamental solutions. The function returns the rank
   <M> or -1 if the system is insolvable. In the first case  <fs> will consist
   of <x> - rank elements.
   */
{
    int rank, rc;
    char **sMatrix = Matrix;
    VEC sAbsolut = Absolut;
    VEC sInhom = Inhom;
    
    x_dim = x;
    y_dim = y;
    Matrix = M;
    Absolut = abs;
    Inhom = inh;
    zero_vector ( Inhom, x );
    rank = GAUSS_ELIMINATE();
    *fs = ARRAY ( x-rank, VEC );
    if ( ( rank != -1 ) && dfundamental_solutions ( fs ) )
	   rc = rank;
    else
	   rc = -1;
    /* restore old values */
    Matrix = sMatrix;
    Absolut = sAbsolut;
    Inhom = sInhom;
    return ( rc );
}

int dgauss_eliminate ( char **M, int x, int y )
/* perform gaussian elimination on <x> x <y> matrix M */
{
    int rank = 0;
    int iy, ix;
    char **sMatrix = Matrix;
    VEC sAbsolut = Absolut;
    char value;
    
    Matrix = M;
    
    PUSH_STACK();
    Absolut = CALLOCATE ( y );
    for ( iy = 0; iy < y; iy++ ) {
	   ix = x - 1;
	   while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
	   if ( value  ) {
		  rank++;
		  if ( value != 1 )
			 SMUL_VECTOR ( fp_inv ( value ), Matrix[iy], x );
		  ZERO_COL ( iy, ix );
	   }
    }

    /* restore old values */
    Matrix = sMatrix;
    Absolut = sAbsolut;
    POP_STACK();
    return ( rank );
}

int dgauss_p_eliminate ( char **M, int x, int y )
{
    register long ix, iy, i;
    register char value;
    int rank = 0;
    char **sMatrix = Matrix;
    
    Matrix = M;
    cxdim = x;
    cydim = y;
    
    for ( i = 0; i < y; i++ ) {
	   zero_vector ( Matrix[i]+x, y );
	   Matrix[i][x+i] = 1;
    }
    
    for ( iy = 0; iy < y; iy++ ) {
	   ix = x - 1;
	   while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
	   if ( value  ) {
		  rank++;
		  if ( value != 1 )
			 SMUL_VECTOR ( fp_inv ( value ), Matrix[iy], (int)(x+y) );
		  ZEROE_COL ( iy, ix, y );
	   }
    }
    Matrix = sMatrix;
    return ( rank );
}

int dcomplement ( char **M, int c_start, int cx_dim, int cy_dim, VEC **fs )
/*	Let {Matrix[c_start],..,Matrix[cy_dim-1]} be a generating set for a
	vector space V. Let S := {Matrix[0],...,Matrix[c_start-1]} be a subset
	of V. Then complement computes a basis for V/<S> (fsolution) and
	returns the dimension of this space (c_dim).  On return <fs> contains
	a basis for the complement.
	*/
{
    register int ix, iy, i;
    register char value;
    int c_dim = 0;
    char **sMatrix = Matrix;
    
    Matrix = M;
    cxdim = cx_dim;
    cydim = cy_dim;
    for ( iy = 0; iy < cy_dim; iy++ ) {
	   ix = cxdim - 1;
	   while ( ( value = Matrix[iy][ix] ) == 0 && ix ) ix--;
	   if ( value  ) {
		  if ( value != 1 )
			 SMUL_VECTOR ( fp_inv ( value ), Matrix[iy], (int)cxdim );
		  if ( iy < c_start )
			 ZEROH_COL ( iy, ix, 0 );
		  else
			 ZEROH_COL ( iy, ix, c_start );
	   }
    }
    *fs = ARRAY ( cy_dim - c_start, VEC );
    for ( i = c_start; i < cy_dim; i++ ) {
	   ix = cx_dim - 1;
	   while ( ( value = Matrix[i][ix] ) == 0 && ix ) ix--;
	   if ( value ) {
		  (*fs)[c_dim] = ALLOCATE ( cx_dim );
		  copy_vector ( Matrix[i], (*fs)[c_dim++], cx_dim );
	   }
    }
    for ( i = c_dim; i < (cy_dim - c_start); i++ )
	   (*fs)[i] = NULL;
    Matrix = sMatrix;
    return ( c_dim );
}

int get_rank ( VEC v[], int len_v, int dim_v, int change, char **PM )
/* Given a list <v> of <len_v> vectors of dimension <dim_v>,
   compute the dimension of the vector space spanned by <v>.
   If <change> is TRUE, the first <rank> elements of <v> are
   replaced by a basis of the space.
   <PM> is either NULL or a pointer to a <len_v> x <len_v> matrix.
   In the latter case, a protocol matrix of the elimination process
   is returned in <PM>.
   */
{
    int rank, i, j;
    char **sMatrix = Matrix;
    VEC sAbsolut = Absolut;
    int dim_x = (PM == NULL)? dim_v : dim_v + len_v;
 
    x_dim = dim_v;
    y_dim = len_v;

    PUSH_STACK();
    Matrix = ARRAY ( len_v, VEC );
    Absolut = CALLOCATE ( len_v );

    for ( i = 0; i < len_v; i++ ) {
	   Matrix[i] = ALLOCATE ( dim_x );
	   copy_vector ( v[i], Matrix[i], dim_v );
    }
    
    if ( PM != NULL )
	   rank = dgauss_p_eliminate ( Matrix, dim_v, len_v );
    else
	   rank = GAUSS_ELIMINATE();
    if ( change ) {
	   j = 0;
	   for ( i = 0; i < len_v; i++ )
		  if ( !iszero ( Matrix[i], dim_v ) )
			 copy_vector ( Matrix[i], v[j++], dim_v );
    }  
    if ( PM != NULL ) {
	   for ( i = 0; i < len_v; i++ )
		  if ( !iszero ( Matrix[i], dim_v ) )
			 copy_vector ( Matrix[i]+dim_v, PM[i], len_v );
		  else
			 zero_vector ( PM[i], len_v );
    }
    POP_STACK();
    
    /* restore old values */
    Matrix = sMatrix;
    Absolut = sAbsolut;
    return ( rank );
}

/* end of module solveequations */








