/********************************************************************/
/*                                                                  */
/*  Module        : Cohomology                                      */
/*                                                                  */
/*  Description :                                                   */
/*     This module is used to compute the first and second coho-    */
/*     mology groups of agiven p-group.                             */
/*                                                                  */
/********************************************************************/

/* 	$Id: cohomol.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: cohomol.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.3  1995/07/17 15:21:22  pluto
 * 	Switched to dynamic version of 'az1_mat'.
 * 	Corrected typo in 'calc_b1'.
 *
 * 	Revision 3.2  1995/07/04 15:18:31  pluto
 * 	Added 'transpose' argument to call of 'tensor_prod'.
 *
 * 	Revision 3.1  1995/07/03 11:36:18  pluto
 * 	Added support for GAP interface.
 *
 * 	Revision 3.0  1995/06/23 09:41:18  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:19:54  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: cohomol.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include "pc.h"
#include "aut.h"
#include "hgroup.h"
#include "grpring.h"
#include "storage.h"
#include "solve.h"
#include "gmodule.h"
#include "cohomol.h"

void az1_mat_old         _(( int homogeneous ));
void az1_mat             _(( int homogeneous, char **M, VEC abs, 
					    int dimension ));
PCGRPDESC *p_quotient    _(( PCGRPDESC *g_desc, int class ));
VEC *calc_h1             _(( VEC g_op[], int dimension, int *z1_dim, int *h1_dim ));
COHOMOLOGY *cohomology   _(( GMODULE *gm, int n ));
VEC expand_two_cocycle   _(( GMODULE *gm, VEC z1, PCELEM e1, PCELEM e2,
					    int use_echelon ));
PCELEM g_comm            _(( PCELEM el, PCELEM er ));
void sc_monom_write      _(( PCELEM el, PCGRPDESC *g ));
int iszero               _(( VEC vector, int len ));

extern PCGRPDESC *group_desc;
extern GRPDSC *h_desc;
extern GRPRING *group_ring;
extern int start, bperelem;
extern int dim, dquad;
extern int adim, adquad;
extern PCELEM *rho;
extern VEC *opmatrix;    
extern HOM *dgroup_auts;
extern DSTYLE displaystyle;

VEC *calc_b1 ( VEC g_op[], int dimension, int *b1_dim )
/* compute B^1(G,M), where G <-> group_desc, M is a F-vector space of
   dimension <dimension> and <g_op> represents the right operation of
   G on M.
   The dimension of B^1(G,M) is returned in <b1_dim> */
{
    VEC *b1;
    VEC m_id, temp;
    int i, j, k, dq, xd, yd;
    char **M;
    VEC Abs, Inh;
    
    xd = dimension * bperelem;
    yd = dimension;

    b1 = ARRAY ( dimension, VEC );
    for ( i = 0; i < dimension; i++ )
	   b1[i] = ALLOCATE ( xd );

    PUSH_STACK();

    dq = dimension * dimension;

    m_id = CALLOCATE ( dq );
    
    /* b \in B^1(G,M) if b(g) = ag -a for a \in M */
    for ( i = 0; i < dimension; i++ )
	   m_id[i*dimension+i] = GPRIME-1;
    
    get_sle_space ( &M, &Abs, &Inh, xd, yd );

    /* compute generating set for B^1(G,M) */
    for ( k = 0; k < bperelem; k++ ) {
	   temp = ALLOCATE ( dq );
	   copy_vector ( g_op[k], temp, dq );
	   ADD_VECTOR ( m_id, temp, dq );
	   for ( i = 0; i < dimension; i++ ) {
		  for ( j = 0; j < dimension; j++ )
			 M[i][j+k*dimension] = temp[i*dimension+j];
	   }
    }

    /* compute basis from generating set by Gaussian elimination */
    k = dgauss_eliminate ( M, xd, yd );
    
    j = 0;
    for ( i = 0; i < dimension; i++ ) {
	   if ( !iszero ( M[i], xd ) ) {
		  copy_vector ( M[i], b1[j++], xd );
	   }
    }
    
    POP_STACK();
    *b1_dim = k;
    return ( b1 );
}

VEC *calc_z1 ( VEC g_op[], int dimension, int *z1_dim )
/* compute Z^1(G,M), where G <-> group_desc, M is a F-vector space of
   dimension <dimension> and <g_op> represents the right operation of
   G on M.
   The dimension of Z^1(G,M) is returned in <z1_dim> */
{
    int i, j, xd, yd;
    int sdim, sdquad;
    VEC *z1;
    char **M;
    VEC Abs, Inh;
    VEC *fsol;
    char *old_top, *new_top;
    unsigned long amount;
    
    start = bperelem;
    
    old_top = GET_TOP();
     
    /* save old values of dim and dquad */
    sdim = dim;
    sdquad = dquad;
    dim = adim = dimension;
    dquad = adquad = adim * adim;

    /* get space for operating matrices */
    opmatrix = ARRAY ( start, VEC );
    for ( j = start; j--; ) {
	   opmatrix[j] = g_op[j];
    }

    xd = bperelem * dim;
    yd = NUMREL * dim;
    
    get_sle_space ( &M, &Abs, &Inh, xd, yd );
    
    rho = ARRAY ( bperelem, PCELEM );
     
    /* get space for operating group elements */
    for ( i = 0; i < bperelem; i++ ) {
	   rho[i] = IDENTITY;
	   rho[i][i] = 1;
    }

    /* set up system of linear equations for Z^1(G,M) */
    az1_mat_old ( TRUE );
    new_top = GET_TOP();

    *z1_dim = xd - dsolve_equations ( M, Abs, Inh, xd, yd, &fsol );
     
    amount = (*z1_dim)*( sizeof ( VEC ) + xd + 4 ) + 4;
    if ( (unsigned long)new_top - (unsigned long)old_top > amount )
	   SET_TOP ( old_top );
    else 
	   fprintf ( stderr, "INFO: memory problems in calc_z1\n" );
    
    /* save basis for Z^1 in array <z1> */
    z1 = ARRAY ( *z1_dim, VEC );
    for ( i = 0; i < *z1_dim; i++ ) {
	   z1[i] = ALLOCATE ( xd );
	   copy_vector ( fsol[i], z1[i], xd );
     }
    
    /* restore old values of dim and dquad */
    dim = sdim;
    dquad = sdquad;
    
    return ( z1 );
}

VEC *calc_h1 ( VEC g_op[], int dimension, int *z1_dim, int *h1_dim )
/* compute H^1(G,M) as Z^1(G,m)/B^1(G,m), where G <-> group_desc, M is
   a F-vector space of dimension <dimension> and <g_op> represents the
   right operation of G on M.
   The dimension of Z^1(G,M) is returned in <z1_dim>, 
   the dimension of H^1(G,M) in <h1_dim> */
{
    int i, j, k;
    int sdim, sdquad;
    int xs, ys, xd, yd;
    VEC *h1;
    VEC m_id, temp;
    char **M;
    VEC Abs, Inh;
    VEC *fsol;
    char *old_top, *new_top;
    unsigned long amount;
    
    start = bperelem;
    
    old_top = GET_TOP();
     
    /* save old values of dim and dquad */
    sdim = dim;
    sdquad = dquad;
    dim = adim = dimension;
    dquad = adquad = adim * adim;

    /* get space for operating matrices */
    opmatrix = ARRAY ( start, VEC );
    for ( j = start; j--; ) {
	   opmatrix[j] = g_op[j];
    }
    
    xd = NUMGEN * dim;
    yd = dim * NUMREL;
    get_sle_space ( &M, &Abs, &Inh, xd, yd+dim );
    
    rho = ARRAY ( NUMGEN, PCELEM );
    
    /* get space for operating group elements */
    for ( i = 0; i < NUMGEN; i++ ) {
	   rho[i] = IDENTITY;
	   rho[i][i] = 1;
    }
    
    /* set up system of linear equations for Z^1(G,M) */
    az1_mat ( TRUE, M, Abs, dim );
    
    *z1_dim  = xd - dsolve_equations ( M, Abs, Inh, xd, yd, &fsol );
    
    /* compute generating set for B^1(G,M) */
    m_id = CALLOCATE ( dquad );
    for ( i = 0; i < dim; i++ )
	   m_id[i*dim+i] = GPRIME-1;
    for ( k = 0; k < bperelem; k++ ) {
	   temp = ALLOCATE ( dquad );
	   copy_vector ( g_op[k], temp, dquad );
	   ADD_VECTOR ( m_id, temp, dquad );
	   for ( i = 0; i < dim; i++ ) {
		  for ( j = 0; j < dim; j++ )
			 M[i][j+k*dim] = temp[i*dim+j];
	   }
    }
    
    /* basis for Z^1(G,M) */
    k = dim;
    for ( i = *z1_dim; i--; ) {
	   copy_vector ( fsol[i], M[k], xd );
	   k++;
    }
    
    xs = x_dim;
    ys = y_dim;
    x_dim = xd;
    y_dim = k;
    
    /* compute H^1(G,m) as complement of B^1(G,M) in Z^1(G,M) */
    new_top = GET_TOP();
    *h1_dim = dcomplement ( M, dim, xd, k, &fsol );
    
    amount = (*h1_dim)* ( sizeof ( VEC ) + xd + 4 ) + 4;
    if ( (unsigned long)new_top - (unsigned long)old_top > amount )
	   SET_TOP ( old_top );
    else 
	   fprintf ( stderr, "INFO: memory problems in calc_h1\n" );
    
    /* save basis for H^1(G.M) in <h1> */
    h1 = ARRAY ( *h1_dim, VEC );
    for ( i = 0; i < *h1_dim; i++ ) {
	   h1[i] = ALLOCATE ( xd );
	   copy_vector ( fsol[i], h1[i], xd );
    }
    
    /* restore old values of dim and dquad */
    dim = sdim;
    dquad = sdquad;
    
    x_dim = xs;
    y_dim = ys;
    return ( h1 );
}

     
static int dimension;         /* dimension of right G-module M */
static int ig_dim;            /* dimension of IG */
static int c2len;             /* number of values mu(x,y) necessary to represent 
                                 2-cocycle. The length of a representimg vector
                                 for such a cocycle is then c2len * dimension */
static VEC zindex;            /* zindex[i] is true, iff t[i] is a zero row */
static VEC *t;                /* matrix representing Gaussion elimination of 
                                 generating set for B^2(G,M) */

VEC expand_two_cocycle ( GMODULE *gm, VEC z1, PCELEM e1, PCELEM e2,
					int use_echelon )
/* compute value of mu(<e1>, <e2>) \in Z^2(G,M) from corresponding 1-cocycle
   <z1> \in Z^1(G,Hom(IG,M)), where M is given as <gm>.
*/
{
    int i, j, k, len;
    VEC val, help;
    PCELEM f1, f2;
    char pi;
     
    val = CALLOCATE ( dimension );

    PUSH_STACK();
    /* if either <e1> or <e2> is the identity return zero */
    if ( iszero ( e1, bperelem ) || iszero ( e2, bperelem ) ) {
	   POP_STACK();
	   return ( val );
    }
    
    /* compute i and j, such that <e1> = g_i^pi*...*g_j^pj */
    i = 0;
    while ( e1[i] == 0 ) i++;
    j = bperelem - 1;
    while ( e1[j] == 0 ) j--;
    len = j - i + 1;
    
    /* if <e1> = g_i then mu(g_i, <e2>) is just z1(g_i)(<e2>^(-1)-1)*<e2> */
    pi = e1[i];
    if ( (len == 1) && (pi == 1) ) {
	   k = IND ( g_invers ( e2 ) );
	   copy_vector ( z1+i*dimension*ig_dim+(k-1)*dimension, val, dimension );
	   help = operation_image ( gm, val, e2, use_echelon );
	   copy_vector ( help, val, dimension );
    }
    else {
	   
	   /* use formula mu(xy,z) = mu(x,yz) + mu(y,z) - mu(x,y)*z 
		 here: x = g_i = f1 , y = g_i^(pi-1) = f2,  z = e2       */ 

	   PUSH_STACK();
	   f1 = IDENTITY;
	   f1[i] = 1;
	   f2 = IDENTITY;
	   copy_vector ( e1+i+1, f2+i+1, bperelem - i - 1 );
	   f2[i] = pi -1;
	   copy_vector ( expand_two_cocycle ( gm, z1, f2, e2, use_echelon ), val,
				  dimension );
	   ADD_VECTOR ( expand_two_cocycle ( gm, z1, f1, monom_mul ( f2, e2 ),
								  use_echelon), 
				 val, dimension );
	   
	   help = expand_two_cocycle ( gm, z1, f1, f2, use_echelon );
	   help = operation_image ( gm, help, e2, use_echelon );
	   SUBB_VECTOR ( help, val, dimension );
	   POP_STACK();
    }
    POP_STACK();
    return ( val );
}
          
/* assume trivial module !!! */
VEC corr_one_cocycle ( VEC fs, int dim )
/* compute corresponding 1-cocycle for <fs> \in Z^2(G,M)
   using the formula fs(x,y) = f(x)(y^(-1) - 1),
   <dim> = dim_F(M),                                      */ 
{
    int d = dim * (GCARD - 1);
    int i, k, ki;
    PCELEM el2;
    VEC z1;
    
    z1 = ALLOCATE ( bperelem * d );
    
    PUSH_STACK();
    el2 = IDENTITY;
    k = 0;
    while ( inc_count ( el2, bperelem ) ) {
	   k++;
	   ki = IND ( g_invers ( el2 ) );
	   for ( i = 0; i < bperelem; i++ ) {
		  copy_vector ( fs+((k-1)*bperelem+i)*dim, z1+i*d+(ki-1)*dim, dim );
	   }
    }
    POP_STACK();
    return ( z1 );
}    

VEC corr_two_cocycle ( GMODULE *gm, VEC z1, VEC alpha )
/* compute corresponding 2-cocycle for <z1> \in Z^1(G,M)
   using the formula mu(x,y) = z1(x)(y^(-1) - 1), <dim> = dim_F(M).
   If <alpha> <> NULL, <alpha> is assumed to be an automorphism of G
   and the twisted cocycle <alpha>fs with (<alpha>fs)(x,y) = 
   fs(<alpha>x,<alpha>y) is computed.                                  */ 
{
    int i, j;
    PCELEM el1, el2;
    VEC value;
    VEC fs;
     
    fs = ALLOCATE ( dimension * c2len );
    
    PUSH_STACK();
    el1 = IDENTITY;
    el2 = IDENTITY;
    j = 0;
    while ( inc_count ( el2, bperelem ) ) {
	   PUSH_STACK();
	   for ( i = 0; i < bperelem; i++ ) {
		  zero_vector ( el1, bperelem );
		  el1[i] = 1;
		  if ( alpha == NULL )
			 value = expand_two_cocycle ( gm, z1, el1, el2, TRUE  );
		  else 
			 value = expand_two_cocycle ( gm, z1, image ( alpha, el1 ), 
									image ( alpha, el2 ), TRUE );
		  copy_vector ( value, fs + j*dimension, dimension );
		  j++;
	   }
	   POP_STACK();
    }
    POP_STACK();
    return ( fs );
}

VEC factor_set ( PCGRPDESC *g_desc )
/* compute the factor set belonging to the extension
   1 -> M -> E -> G -> 1, where G is the p-class c-1 quotient of E */
{
    PCGRPDESC *old_pc_group;
    PCELEM el1, el2, r1, r2;
    int i, j, start, dim, entries;
    VEC fs;
    
    old_pc_group = group_desc;
    set_main_group ( g_desc );
    
    /* M is generated by generators g_start, ..., g_(bperelem-1) */
    start = EXP_P_LCS[EXP_P_CLASS].i_start;
    dim = GNUMGEN - start;
    entries = start;
    for ( i = 0; i < start; i++ )
	   entries *= GPRIME;
    entries -= start;
    fs = ALLOCATE ( dim * entries );
    
    PUSH_STACK();
    el1 = IDENTITY;
    el2 = IDENTITY;
    j = 0;
    while ( inc_count ( el2, start ) ) {
	   PUSH_STACK();
	   for ( i = 0; i < start; i++ ) {
		  
		  /* If s is a section G -> E then 
			mu(g,h) = s(gh)^(-1)*s(g)*s(h)   */
		  
		  zero_vector ( el1, bperelem );
		  el1[i] = 1;
		  r1 = monom_mul ( el1, el2 );
		  r2 = IDENTITY;
		  copy_vector ( r1, r2, start );
		  r1 = monom_mul ( g_invers ( r2 ) , r1 );
		  copy_vector ( r1+start, fs + j*dim, dim );
		  j++;
	   }
	   POP_STACK();
    }
    POP_STACK();
    set_main_group ( old_pc_group );
    return ( fs );
}

VEC gr_factor_set (void)
/* compute the factor set belonging to the extension
   1 -> I(C)FG -> FG -> FG' -> 1, where G' is the p-class c-1 quotient of G */
{
    PCELEM el1, el2, r1, r2;
    int i, j, start, dim;
    VEC s1, s2, s3;
    
    /* M is generated by generators g_start, ..., g_(bperelem-1) */
    start = EXP_P_LCS[EXP_P_CLASS].i_start;
    dim = GNUMGEN - start;
    
    PUSH_STACK();
    el1 = IDENTITY;
    el2 = IDENTITY;
    j = 0;
    while ( inc_count ( el2, start ) ) {
	   PUSH_STACK();
	   for ( i = 0; i < start; i++ ) {
		  
		  /* If s is a section G' -> G then 
			mu(g,h) = (s(g)*s(h) - s(gh))*(gh)^(-1)  */
		  
		  zero_vector ( el1, bperelem );
		  el1[i] = 1;
		  /* s(g)*s(h) */
		  r1 = monom_mul ( el1, el2 );
		  s1 = CALLOCATE ( GCARD );
		  s1[nr ( r1 )] = 1;
		  /* s(gh) */
		  r2 = IDENTITY;
		  copy_vector ( r1, r2, start );
		  s2 = CALLOCATE ( GCARD );
		  s2[nr ( r2 )] = 1;
		  SUBA_VECTOR ( s1, s2, GCARD );
		  /* multiply with (gh)^(-1) */
		  r2 = g_invers ( r1 );
		  s3 = CALLOCATE ( GCARD );
		  s3[nr ( r2 )] = 1;
		  s3 = C_GROUP_MUL ( s2, s3 );
		  printf ( "f(" );
		  c_monom_write ( C_MONOM[nr(el1)] );
		  printf ( "," );
		  c_monom_write ( C_MONOM[nr(el2)] );
		  printf ( ") = " );
		  cgroup_write ( s3 );
		  j++;
          }
	   POP_STACK();
    }
    POP_STACK();
    return ( NULL );
}

VEC *calc_c2 ( GMODULE *gm, VEC z1[], int z1_dim )
/* given a list of elements <z1> of Z^1(G,Hom(IG,M)) of length <z1_dim>,
   compute the corresponding list of elements of Z^2(G,M)               */
{
    int i, j, k, entries;
    PCELEM el1, el2;
    VEC value;
    VEC *fs;
    
    entries = bperelem;
    for ( i = 0; i < bperelem; i++ )
	   entries *= GPRIME;
    entries -= bperelem;
    
    c2len = entries;
    fs = ARRAY ( z1_dim, VEC );
    for ( i = 0; i < z1_dim; i++ )
	   fs[i] = ALLOCATE ( dimension * entries );
    
    for ( k = 0; k < z1_dim; k++ ) {
	   PUSH_STACK();
	   el1 = IDENTITY;
	   el2 = IDENTITY;
	   j = 0;
	   while ( inc_count ( el2, bperelem ) ) {
		  PUSH_STACK();
		  for ( i = 0; i < bperelem; i++ ) {
			 zero_vector ( el1, bperelem );
			 el1[i] = 1;
			 value = expand_two_cocycle ( gm, z1[k], el1, el2, TRUE );
			 copy_vector ( value, fs[k] + j*dimension, dimension );
			 j++;
		  }
		  POP_STACK();
	   }
	   POP_STACK();
    }
    return ( fs );
}

void get_trafo_mat ( VEC *b2l, int bdim )
/* compute the matrix <t> representing the Gaussian elimination of the
   list <b2l> of 2-cobounadries of length <bdim>. <zindex> indicates zero
   rows of <t> */
{
    int i, j;
    int xd, yd;
    
    xd = bdim;
    yd = c2len;
    
    PUSH_STACK();
    for ( i = 0; i < yd; i++ )
	   for ( j = 0; j < xd; j++ )
		  matrix[(long)i][(long)j] = b2l[j][i];
    gauss_p_eliminate ( xd, yd );
    POP_STACK();
    
    t = ARRAY ( yd, VEC );
    zindex = CALLOCATE ( yd );
    for ( i = 0; i < yd; i++ ) {
	   t[i] = ALLOCATE ( yd );
	   copy_vector ( matrix[(long)i]+(long)xd, t[i], yd );
	   zindex[i] = ( iszero ( matrix[(long)i], xd ) );
    }
}

void addlist ( VEC *orbit, int *offset, VEC fs, int bdim )
/* add <fs> \in Z^2(G,M) to orbit of Aut(G), if it is not already in
   this orbit. <*offset> is the current length of the orbit, <bdim> the
   dimension of B^2(G,M).  */
{
    int i, j, k, isnew;
    int xd, yd;
    register int val;
    VEC tt;
    
    PUSH_STACK();
    xd = bdim;
    yd = c2len;
    
    absolut = ALLOCATE ( yd );
    inhom = ALLOCATE ( xd );
    
    isnew = TRUE;
    
    /* check if orbit(k) - alpha(fs) \in B^2(G,M) by comuting
	  t*(orbit(k)-alpha(fs)) and checking if i-th component of
	  this vector is zero when t[i] is zero */
    
    for ( k = 0; k < *offset; k++ ) {
	   isnew = FALSE;
	   copy_vector ( fs, absolut, c2len );
	   SUBB_VECTOR ( orbit[k], absolut, c2len );
	   for ( i = 0; i < yd; i++ ) {
		  if ( zindex[i] ) {
			 tt = t[i];
			 val = 0;
			 for ( j = 0; j < yd; j++ )
				val += (tt[j]*absolut[j]);
			 if ( (isnew = ( (val % GPRIME)!= 0 )) ) break;
		  }
		  
          }
	   if ( !isnew ) break; 
    } 
    
    POP_STACK();
    
    if ( isnew ) {
	   orbit[*offset] = ALLOCATE ( c2len );
	   copy_vector ( fs, orbit[*offset], c2len );
	   ++(*offset);
    }
}

void two_coboundaries ( PCGRPDESC *g_desc, GMODULE *gm )
/* compute orbit of Aut(G) acting on H^2(G,M), where G is the p-class
   c-1 quotient of E = <g_desc> and E/M = G. The module M must be a trivial
   G-module of dimension <dim>. <g_op> represents the right operation of G
   on M. */
{
    GMODULE *aug;
    GMODULE *ng_op;
    VEC *b1, *b2, *orbit, z1fs, alpha, fs;
    int b1_dim, orbit_len, i, auts, dim;
    PCGRPDESC *old_pc_group, *gg;
    GRPDSC *old_p_group;
    
    /* calculate fact0or set of extension 1 -> M -> E -> G -> 1 */
    fs = factor_set ( g_desc );
    
    dim = gm->dim;
    old_pc_group = group_desc;
    old_p_group = h_desc;
    
    /* G = E/M = <gg> */
    gg = p_quotient ( g_desc, g_desc->exp_p_class - 1);
    set_main_group ( gg );
    set_h_group (  conv_rel ( gg ) );
    
    /* compute B^1(G, Hom(IG,M)) */
    aug = ig_op ( gg );
    ig_dim = GCARD - 1;
    ng_op = tensor_prod ( aug, gm, TRUE );
    dimension = dim * ig_dim;
    b1 = calc_b1 ( ng_op->m, dimension, &b1_dim );
    
    /* compute generating set for B^2(G,M) */
    dimension = 1;
    b2 = calc_c2 ( gm, b1, b1_dim );
    
    /* compute basis for B^2(G,M) from generating set and
	  elimination matrix */
    get_trafo_mat ( b2, b1_dim );
    
    /* <z1fs> \in Z^1(G,Hom(IG,M) corresponds to <fs> \in Z^2(G,M) */
    z1fs = corr_one_cocycle ( fs, dimension );
    
    /* compute elements of Aut(G) */
    dgroup_auts = automorphisms ( gg, 0 );
    dgroup_auts = generate_automorphism_group ( dgroup_auts, FALSE );
    
    auts = dgroup_auts->aut_gens_dim[1];
    orbit = ARRAY ( auts, VEC );
    orbit_len = 0;
    
    /* generate orbit of Aut(G) on H^2(G,M) containing <fs> */
    for ( i = 0; i < auts; i++ ) {
	   alpha = dgroup_auts->aut_gens[1][i];
	   fs = corr_two_cocycle ( gm, z1fs, alpha );
	   addlist ( orbit, &orbit_len, fs, b1_dim );
    }
    
    printf ( "length of orbit: %d\n", orbit_len );
    /* for ( i = 0; i < orbit_len; i++ )
	  write_vector ( orbit[i], c2len ); */
    set_main_group ( old_pc_group );
    set_h_group ( old_p_group );
}

COHOMOLOGY *cohomology ( GMODULE *gm, int n )
/* compute H^<n>(G,<gm>), where G is a p-group given via a pc-presentation
   and <gm> is a right F_pG-module. 
   The routine returns a structure containing a basis for H^<n>(G,<gm>) along
   with the dimensions of Z^<n>(G,<gm>) and H^<n>(G,<gm>).
   */
{
    GMODULE *aug;
    GMODULE *ngm;
    int d_aug, dim;
    int i;
    int hn_dim, zn_dim;
    COHOMOLOGY *cohomol;
    PCGRPDESC *old_pc_group;
    GRPDSC *old_p_group;
    
    old_pc_group = group_desc;
    old_p_group = h_desc;
    set_main_group ( gm->g );
    set_h_group (  conv_rel ( gm->g ) );
    
    if ( gm->echelon == NULL )
	   echelonize_module ( gm );
    cohomol = ALLOCATE ( sizeof ( COHOMOLOGY ) );
    cohomol->gm = gm;
    cohomol->degree = n;

    /* H^1 can be computed directly */
    if ( n == 1 ) {
	   cohomol->basis = calc_h1 ( gm->echelon, gm->dim, &zn_dim, &hn_dim );
	   cohomol->dim = hn_dim;
	   cohomol->z_dim = zn_dim;
	   cohomol->module_dim = gm->dim;
    }
    else {
	   
	   /* compute H^n by dimension shifting using the formula
		 H^n(G,M) = H^(n-1)(G, Hom(IG,M)) */
	   
	   aug = ig_op ( gm->g );
	   d_aug = GCARD - 1;
	   dim = gm->dim;
	   ngm = gm;
	   for ( i = 2; i <= n; i++ ) {
		  ngm = tensor_prod ( aug, ngm, TRUE );
		  dim *= d_aug;
		  /* printf ( "dimension of g-module : %d\n", dim ); */
	   }
	   cohomol->basis = calc_h1 ( ngm->m, ngm->dim, &zn_dim, &hn_dim );
	   cohomol->dim = hn_dim;
	   cohomol->z_dim = zn_dim;
	   cohomol->module_dim = ngm->dim;
    }
    set_main_group ( old_pc_group );
    set_h_group ( old_p_group );
    return ( cohomol );
}

void calc_cohomology ( int n, PCGRPDESC *g )
/* compute H^n(G,M), where G is the p-class
   c-1 quotient of E = <g> and E/M = G. The module M must be a trivial
   G-module of dimension <dim>. */
{
    int dim2;
    /* int zd, hd; */
    GMODULE *gm;
    PCGRPDESC *gg;

    PUSH_STACK();
    dim2 = g->exp_p_lcs[g->exp_p_class].i_dim;
    gg = p_quotient ( g, g->exp_p_class - 1);
    gm = triv_mod ( dim2, gg );
    
    cohomology ( gm, n ); 
    /* printf ( "dimension of Z%1d : %d\n", n, zd );
    printf ( "dimension of H%1d : %d\n", n, hd ); */
    POP_STACK();
}

void calc_extorbit ( PCGRPDESC *g )
/* compute orbit of Aut(G) acting on H^2(G,M), where G is the p-class
   c-1 quotient of E = <g> and E/M = G. The module M must be a trivial
   G-module of dimension <dim>. */
{
    int dim2;
    GMODULE *gm;
    
    PUSH_STACK();
    dim2 = g->exp_p_lcs[g->exp_p_class].i_dim;
    gm = triv_mod ( dim2, g );
    
    two_coboundaries ( g, gm );
    POP_STACK();
}

void print_module_word ( VEC w, int d, char *n )
{
    int i;
    char v;

    for ( i = 0; i < d; i++ ) {
	   if ( (v=w[i]) != 0 )
		  if ( v == 1 )
			 printf ( "%s%1d", n, i+1 );
		  else
			 printf ( "%s%1d^%1d", n, i+1, v );
    }
}

PCGRPDESC *group_extension ( COHOMOLOGY *cohomol, VEC select, char *gname )
{
    VEC z1, val, help, word;
    int i, j, len, numrel, c;
    char v;
    PCGRPDESC *g, *old_pc_group;
    GRPDSC *E;
    PCELEM x, y, xi, yi, xy, z;
    /* int print_it */
    int defs;
    node no1, no2, no3, no4;
    unsigned long sl;

    old_pc_group = group_desc;
    g = cohomol->gm->g;
    set_main_group ( g );

    
    defs = g->defs;
    g->defs = FALSE;

    /* initialize static variables */
    dimension = cohomol->gm->dim;
    ig_dim = GCARD - 1;

    len = cohomol->module_dim * cohomol->gm->g->num_gen;

    E = CALLOCATE ( sizeof ( GRPDSC ) );
    E->prime = g->prime;
    E->num_gen = g->num_gen + dimension;
    sprintf ( E->group_name, "Ext(%s)", g->group_name );
    E->is_minimal = FALSE;
    E->pc_pres = NULL;
    E->isog = NULL;

    E->num_rel = numrel = E->num_gen + (((E->num_gen)*(E->num_gen-1))>>1);
    E->rel_list = ARRAY ( numrel, node );
    E->gen = ARRAY ( E->num_gen, char* );
    for ( i = 0; i < bperelem; i++ ) {
	   E->gen[i] = ALLOCATE ( strlen ( g->gen[i] )+1 );
	   strcpy ( E->gen[i], g->gen[i] );
    }
    sl = strlen ( gname ) + 2 + 1;
    for ( i = bperelem; i < E->num_gen; i++ ) {
	   E->gen[i] = ALLOCATE ( sl );
	   sprintf ( E->gen[i], "%s%1d", gname, i+1-bperelem );
    }
	   
    
    /* get requested element of H^2(G,M) */
    z1 = CALLOCATE ( len );
    for ( i = 0; i < cohomol->dim; i++ ) 
	   if ( (v=select[i]) != 0 )
		  ADD_MULT ( v, cohomol->basis[i], z1, len );
    
    x = IDENTITY;
    y = IDENTITY;
    val = ALLOCATE ( dimension );
    word = ALLOCATE ( E->num_gen );

    /* modifications for power relators */
    for ( i = 0; i < bperelem; i++ ) {
	   zero_vector ( x, bperelem );
	   zero_vector ( y, bperelem );
	   zero_vector ( val, dimension );
	   x[i] = 1;
	   
	   /* powers are modified by \sum_{i=1}^{prime-1} f(x,x^i) */
	   for ( j = 1; j < GPRIME; j++ ) {
		  y[i] = j;
		  ADD_VECTOR ( expand_two_cocycle ( cohomol->gm, z1, x, y, TRUE ),
					val, dimension );
	   }
	   
	   zero_vector ( word, E->num_gen );
/*	   printf ( "%s^%1d = ", g->gen[i], GPRIME ); */
	   z = g_expo ( x, GPRIME );
	   copy_vector ( z, word, bperelem );

/*	   if ( !iszero ( z, bperelem ) )
		  sc_monom_write ( z, g );
	   if ( !iszero ( val, dimension ) )
		  print_module_word ( val, dimension, gname );
	   else
		  printf ( "1" );
	   printf ( "\n" );  */
	
	   copy_vector ( val, word+bperelem, dimension );
	   G_NODE ( no1, i );
	   E_NODE ( no2, no1, GPRIME );
	   no3 = word_to_node ( word, E->num_gen );
	   R_NODE ( E->rel_list[i], no2, no3 );
    }

    /* powers for new pc-generators */
    for ( i = 0; i < dimension; i++ ) {
	   /* all of these powers are trivial */
	   /* printf ( "%s%1d^%1d = 1\n", gname, i+1, GPRIME ); */
	   G_NODE ( no1, i+bperelem );
	   E_NODE ( no2, no1, GPRIME );
	   R_NODE ( E->rel_list[i+bperelem], no2, NULL );
    }

    /* modifications for commutator relations */
    for ( i = 0; i < bperelem; i++ ) {
	   /* the modification for [x,y] is f(x^-1*y^-1,x*y) +
	      f(x^-1,y^-1)*x*y - f(x,x^-1)*y^-1*x*y - f(y,y^-1)*x*y
		 + f(x,y) */
	   zero_vector ( y, bperelem );
	   y[i] = 1;
	   yi = g_invers ( y );
	   for ( j = i+1; j < bperelem; j++ ) {
		  zero_vector ( x, bperelem );
		  x[j] = 1;
		  xi = g_invers ( x );
		  xy = monom_mul ( x, y );
		  zero_vector ( val, dimension );
		  ADD_VECTOR ( expand_two_cocycle ( cohomol->gm, z1,
	                    monom_mul ( xi, yi ), xy, TRUE ),
					val, dimension );
		  help = expand_two_cocycle ( cohomol->gm, z1, xi, yi, TRUE );
		  ADD_VECTOR ( operation_image ( cohomol->gm, help, xy, TRUE ),
					val, dimension );
		  ADD_VECTOR ( expand_two_cocycle ( cohomol->gm, z1,
	                    x, y, TRUE ),
					val, dimension );
		  help = expand_two_cocycle ( cohomol->gm, z1, y, yi, TRUE );
		  SUBB_VECTOR ( operation_image ( cohomol->gm, help, xy, TRUE ),
					val, dimension );
		  
		  help = expand_two_cocycle ( cohomol->gm, z1, x, xi, TRUE );
		  SUBB_VECTOR ( operation_image ( cohomol->gm, help, 
					monom_mul ( yi, xy ), TRUE ), val, dimension );
		  
		  z = g_comm ( x, y );
		  copy_vector ( z, word, bperelem );
		  c = CN(j,i);

/*		  print_it = FALSE;
		  if ( !iszero ( z, bperelem ) ) {
			 printf ( "[%s,%s] = ", g->gen[j], g->gen[i]  );
			 sc_monom_write ( z, g );
			 print_it = TRUE;
		  }
		  else {
			 if ( !iszero ( val, dimension ) ) {
				printf ( "[%s,%s] = ", g->gen[j], g->gen[i]  );
				print_it = TRUE;
			 }
		  }
		  if ( print_it ) {
			 print_module_word ( val, dimension, gname );
			 printf ( "\n" );
		  }  */
		 
		  copy_vector ( val, word+bperelem, dimension );
		  G_NODE ( no1, j );
		  G_NODE ( no2, i );
		  C_NODE ( no3, no1, no2 );
		  no4 = word_to_node ( word, E->num_gen );
		  R_NODE ( E->rel_list[E->num_gen+c], no3, no4 );
	   }
    }

    /* commutators with new pc-generators */
    zero_vector ( word, bperelem );
    for ( i = 0; i < bperelem; i++ )
	   /* the modification for [m,x] with m \in M is just 
		 m*x - m  */
	   for ( j = 0; j < dimension; j++ ) {
		  copy_vector ( cohomol->gm->echelon[i]+j*dimension, val,
					 dimension );
		  val[j] = 0;

/*		  if ( !iszero ( val, dimension ) ) {
			 printf ( "[%s%1d,%s] = ", gname, j+1, g->gen[i]  );
			 print_module_word ( val, dimension, gname );
			 printf ( "\n" );
		  }  */

		  c = CN((bperelem+j),i);
		  copy_vector ( val, word+bperelem, dimension );
		  G_NODE ( no1, j+bperelem );
		  G_NODE ( no2, i );
		  C_NODE ( no3, no1, no2 );
		  no4 = word_to_node ( word, E->num_gen );
		  R_NODE ( E->rel_list[E->num_gen+c], no3, no4 );
	   }

    /* commutators between new generators */
    for ( i = bperelem+1; i < E->num_gen; i++ )
	   /* these commutators are trivial */
	   for ( j = bperelem; j < i; j++ ) {
		  c = CN(i,j);
		  G_NODE ( no1, i );
		  G_NODE ( no2, j );
		  C_NODE ( no3, no1, no2 );
		  R_NODE ( E->rel_list[E->num_gen+c], no3, NULL );
	   }

    g->defs = defs;
    set_main_group ( old_pc_group );
    return ( grp_to_pcgrp ( E ) );
}

PCGRPDESC *split_extension ( GMODULE *gm, char *gname )
{
    VEC val, word;
    int i, j, numrel, c;
    PCGRPDESC *g, *old_pc_group;
    GRPDSC *E;
    PCELEM x, y;
    int defs;
    node no1, no2, no3, no4;
    unsigned long sl;

    old_pc_group = group_desc;
    g = gm->g;
    set_main_group ( g );

    
    defs = g->defs;
    g->defs = FALSE;

    /* initialize static variables */
    dimension = gm->dim;
    
    /* get triangular basis for module */
    if ( gm->echelon == NULL )
	   echelonize_module ( gm );
    E = CALLOCATE ( sizeof ( GRPDSC ) );
    E->prime = g->prime;
    E->num_gen = g->num_gen + dimension;
    sprintf ( E->group_name, "Ext(%s)", g->group_name );
    E->is_minimal = FALSE;
    E->pc_pres = NULL;
    E->isog = NULL;

    E->num_rel = numrel = E->num_gen + (((E->num_gen)*(E->num_gen-1))>>1);
    E->rel_list = ARRAY ( numrel, node );
    E->gen = ARRAY ( E->num_gen, char* );
    for ( i = 0; i < bperelem; i++ ) {
	   E->gen[i] = ALLOCATE ( strlen ( g->gen[i] )+1 );
	   strcpy ( E->gen[i], g->gen[i] );
    }
    sl = strlen ( gname ) + 2 + 1;
    for ( i = bperelem; i < E->num_gen; i++ ) {
	   E->gen[i] = ALLOCATE ( sl );
	   sprintf ( E->gen[i], "%s%1d", gname, i+1-bperelem );
    }
	   
    x = IDENTITY;
    y = IDENTITY;
    val = ALLOCATE ( dimension );
    word = ALLOCATE ( E->num_gen );

    /* new power relators (no modifications) */
    for ( i = 0; i < bperelem; i++ ) {
	   zero_vector ( x, bperelem );
	   x[i] = 1;
	   zero_vector ( word, E->num_gen );
	   copy_vector ( g_expo ( x, GPRIME ), word, bperelem );
	   G_NODE ( no1, i );
	   E_NODE ( no2, no1, GPRIME );
	   no3 = word_to_node ( word, E->num_gen );
	   R_NODE ( E->rel_list[i], no2, no3 );
    }

    /* powers for new pc-generators */
    for ( i = 0; i < dimension; i++ ) {
	   /* all of these powers are trivial */
	   G_NODE ( no1, i+bperelem );
	   E_NODE ( no2, no1, GPRIME );
	   R_NODE ( E->rel_list[i+bperelem], no2, NULL );
    }

    /* modifications for commutator relations (no modifications) */
    for ( i = 0; i < bperelem; i++ ) {
	   zero_vector ( y, bperelem );
	   y[i] = 1;
	   for ( j = i+1; j < bperelem; j++ ) {
		  zero_vector ( word, dimension );
		  zero_vector ( x, bperelem );
		  x[j] = 1;
		  copy_vector ( g_comm ( x, y ), word, bperelem );
		  c = CN(j,i);
		  G_NODE ( no1, j );
		  G_NODE ( no2, i );
		  C_NODE ( no3, no1, no2 );
		  no4 = word_to_node ( word, E->num_gen );
		  R_NODE ( E->rel_list[E->num_gen+c], no3, no4 );
	   }
    }

    /* commutators with new pc-generators */
    zero_vector ( word, bperelem );
    for ( i = 0; i < bperelem; i++ )
	   /* the modification for [m,x] with m \in M is just 
		 m*x - m  */
	   for ( j = 0; j < dimension; j++ ) {
		  copy_vector ( gm->echelon[i]+j*dimension, val,
					 dimension );
		  val[j] = 0;
		  c = CN((bperelem+j),i);
		  copy_vector ( val, word+bperelem, dimension );
		  G_NODE ( no1, j+bperelem );
		  G_NODE ( no2, i );
		  C_NODE ( no3, no1, no2 );
		  no4 = word_to_node ( word, E->num_gen );
		  R_NODE ( E->rel_list[E->num_gen+c], no3, no4 );
	   }

    /* commutators between new generators */
    for ( i = bperelem+1; i < E->num_gen; i++ )
	   /* these commutators are trivial */
	   for ( j = bperelem; j < i; j++ ) {
		  c = CN(i,j);
		  G_NODE ( no1, i );
		  G_NODE ( no2, j );
		  C_NODE ( no3, no1, no2 );
		  R_NODE ( E->rel_list[E->num_gen+c], no3, NULL );
	   }

    g->defs = defs;
    set_main_group ( old_pc_group );
    return ( grp_to_pcgrp ( E ) );
}

void show_cohomology ( COHOMOLOGY *cohomol )
{
    /* char *rec_prefx, *rec_postfx; */
    
    if ( displaystyle == GAP ) {
	   printf ( "SISYPHOS.COHOMOLOGY.dimension:=%d;\n", cohomol->dim );
	   printf ( "SISYPHOS.COHOMOLOGY.cycleDimension:=%d;\n", cohomol->z_dim );
    }
    else {
	   printf ( "degree           : %d\n", cohomol->degree );
	   printf ( "dim(H^%1d(G,M))    : %d\n", cohomol->degree, cohomol->dim );
	   printf ( "dim(Z^%1d(G,M))    : %d\n", cohomol->degree, 
			  cohomol->z_dim );
	   printf ( "dim(M)           : %d\n", cohomol->gm->dim );
    }
}

/* end of modulo cohomology */






