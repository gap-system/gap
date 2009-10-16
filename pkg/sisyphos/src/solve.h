/* 	$Id: solve.h,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: solve.h,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 16:57:30  pluto
 * 	*** empty log message ***
 *
 * Revision 1.4  1995/03/03  14:59:38  pluto
 * Changed prototype for <get_rank>.
 *
 * Revision 1.3  1995/03/03  14:50:33  pluto
 * Added prototype for <get_rank>.
 *
 * Revision 1.2  1995/01/05  17:28:46  pluto
 * Initial version under RCS control.
 *	 */

#undef ALLOC_CLS
#ifdef ALLOC
#	define ALLOC_CLS /* empty */
#else
#	define ALLOC_CLS extern
#endif

#define XMAX		400
#define YMAX		1000

ALLOC_CLS char **matrix;
ALLOC_CLS int  x_dim, y_dim, yh_dim;
ALLOC_CLS VEC  absolut, inhom;
ALLOC_CLS VEC  fsolution[XMAX];
ALLOC_CLS void (*zero_col)			_(( long row, long col ));
ALLOC_CLS void (*zeroh_col)			_(( long row, long col, int end ));
ALLOC_CLS void (*zeroe_col)			_(( long row, long col, int end ));
ALLOC_CLS int (*gauss_eliminate)		_(( void ));

#define ZERO_COL (*zero_col)
#define ZEROH_COL (*zeroh_col)
#define ZEROE_COL (*zeroe_col)
#define GAUSS_ELIMINATE (*gauss_eliminate)

void zero2_col 			_(( long row, long col ));
void zeroh2_col			_(( long row, long col, int end ));
void zeroe2_col			_(( long row, long col, int end ));
void zero3_col 			_(( long row, long col ));
void zeroh3_col			_(( long row, long col, int end ));
void zeroe3_col			_(( long row, long col, int end ));
void zerop_col 			_(( long row, long col ));
void zerohp_col			_(( long row, long col, int end ));
void zeroep_col			_(( long row, long col, int end ));
int gauss2_eliminate		_(( void ));
int gauss3_eliminate		_(( void ));
int gaussp_eliminate		_(( void ));
int gauss_p_eliminate 		_(( int x, int y ));
int solve_equations 		_(( int x, int y ));
int complement 			_(( int c_start, int cx_dim, int cy_dim ));
void init_matrix 			_(( void ));
void use_static_matrix 		_(( void ));

void get_sle_space 			_(( char ***M, VEC *abs, VEC *inh, int x, 
						    int y ));
int dsolve_equations 		_(( char **M, VEC abs, VEC inh, int x, int y, 
						    VEC **fs ));
int dgauss_p_eliminate 		_(( char **M, int x, int y ));
int dgauss_eliminate          _(( char **M, int x, int y ));
int dcomplement 			_(( char **M, int c_start, int cx_dim, 
						    int cy_dim, VEC **fs ));
int get_rank                  _(( VEC v[], int len_v, int dim_v, int change, 
						    char **PM ));











