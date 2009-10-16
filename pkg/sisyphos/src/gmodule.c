/********************************************************************/
/*                                                                  */
/*  Module        : G-Module                                        */
/*                                                                  */
/*  Description :                                                   */
/*     Supplies routines to deal with G-modules.                    */
/*                                                                  */
/********************************************************************/

/* 	$Id: gmodule.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: gmodule.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.1  1995/08/10 12:01:41  pluto
 * 	New routines 'gm_sum' and 'gm_dual'.
 *
 * 	Revision 3.0  1995/06/23 09:41:36  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:20:21  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: gmodule.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include "pc.h"
#include "hgroup.h"
#include "grpring.h"
#include "storage.h"
#include "solve.h"
#include "gmodule.h"

#ifdef ANSI
void exit ( int status );
#endif

int is_id 		_(( PCELEM el ));
int inc_el 		_(( PCELEM el ));
VEC Idmat           _(( void ));
VEC matrix_inv      _(( VEC mat ));

extern int prime;
extern PCGRPDESC *group_desc;
extern GRPDSC *h_desc;
extern int new_xdim, new_cut;
extern int dim, dquad;
extern int adim, adquad;
extern int bperelem;
extern PCELEM *rho;

GMODULE *triv_mod ( int dim, PCGRPDESC *g )
{
	int i, j;
	int dq = dim * dim;
	GMODULE *gm;
	
	gm = ALLOCATE ( sizeof ( GMODULE ) );
	gm->m = ARRAY ( g->num_gen, VEC );
	gm->echelon = ARRAY ( g->num_gen, VEC );
	gm->g = g;
	gm->dim = dim;
	for ( i = g->num_gen; i--; ) {
		gm->m[i] = CALLOCATE ( dq );
		gm->echelon[i] = CALLOCATE ( dq );
		for ( j = 0; j < dim; j++ )
			gm->m[i][j*dim+j] = gm->echelon[i][j*dim+j] = 1;
	}
	gm->T = CALLOCATE ( dq );
	gm->TI = CALLOCATE ( dq );
	for ( i = 0; i < dim; i++ )
	    gm->T[i*dim+i] = gm->TI[i*dim+i] = 1;
	return ( gm );
}

GMODULE *ig_op ( PCGRPDESC *g )
/* compute the right operation of g_i^(-1) on IG,
   this is needed for dimension shifting */
{
	int i, j;
	int dim;
	int dq;
	GMODULE *gm;
	PCELEM hi, el, pr;
     PCGRPDESC *old_pc_group;

     old_pc_group = group_desc;
     set_main_group ( g );
	
	dim = GCARD - 1;
	
	dq = dim * dim;
	
	gm = ALLOCATE ( sizeof ( GMODULE ) );
	gm->m = ARRAY ( bperelem, VEC );
	gm->g = g;
	gm->dim = dim;
	gm->echelon = NULL;
	gm->T = gm->TI = NULL;
	for ( i = 0; i < bperelem; i++ )
		gm->m[i] = CALLOCATE ( dq );
		
	PUSH_STACK();
	el = IDENTITY;
	j = 0;
	while ( inc_el ( el ) ) {
		PUSH_STACK();
		for ( i = 0; i < bperelem; i++ ) {
			hi = g_invers ( GNOM[i] );
			pr = monom_mul ( el, hi );
			if ( !is_id ( pr ) )
				gm->m[i][j*dim + nr ( monom_mul ( el, hi ) ) - 1] = 1;
			gm->m[i][j*dim + nr ( hi )- 1] = GPRIME - 1;
		}
		POP_STACK();
		j++;
	}
	POP_STACK();
	set_main_group ( old_pc_group );
	return ( gm );
}

GMODULE *gm_sum ( GMODULE *m1, GMODULE *m2 )
/* compute direct sum of G-modules <m1> and <m2> */
{
	int i, k;
	int dim;
	int dq;
	GMODULE *sm;
	int dim1, dim2, numgen;
	
	dim1 = m1->dim;
	dim2 = m2->dim;
	dim = dim1 + dim2;
	dq = dim*dim;
	numgen = m1->g->num_gen;
	
	sm = ALLOCATE ( sizeof ( GMODULE ) );
	sm->g = m1->g;
	sm->dim = dim;
	sm->echelon = NULL;
	sm->T = sm->TI = NULL;
	sm->m = ARRAY ( numgen, VEC );
	for ( i = 0; i < numgen; i++ ) {
		sm->m[i] = CALLOCATE ( dq );
		for ( k = 0; k < dim1; k++ )
		    copy_vector ( m1->m[i]+k*dim1, sm->m[i]+k*dim, dim1 );
		for ( k = 0; k < dim2; k++ )
		    copy_vector ( m2->m[i]+k*dim2, sm->m[i]+(k+dim1)*dim+dim1, dim2 );
	}
	return ( sm );
}

GMODULE *gm_dual ( GMODULE *m )
/* compute dual module of G-module <m>, the matrices describing
   the operation of G on the dual module are just the transposed
   inverses of the matrices belonging to <m>. */
{
	int i, j, k;
	GMODULE *dm;
	VEC help;
	int numgen, oprime;
	
	dim = m->dim;
	dquad = dim*dim;
	numgen = m->g->num_gen;
	
	oprime = prime;

	swap_arith ( m->g->prime );

	dm = ALLOCATE ( sizeof ( GMODULE ) );
	dm->g = m->g;
	dm->dim = dim;
	dm->echelon = NULL;
	dm->T = dm->TI = NULL;
	dm->m = ARRAY ( numgen, VEC );
	for ( i = 0; i < numgen; i++ ) {
		dm->m[i] = CALLOCATE ( dquad );
		PUSH_STACK();
		help = matrix_inv ( m->m[i] );
		for ( j = 0; j < dim; j++ )
		    for ( k = 0; k < dim; k++ )
			   dm->m[i][k*dim+j] = help[j*dim+k];
		POP_STACK();
	}
	swap_arith ( oprime );
	return ( dm );
}

GMODULE *tensor_prod ( GMODULE *m1, GMODULE *m2, int transpose )
/* compute tensor product of G-modules <m1> and <m2>, if <transpose>
   is 'true' the matrices describing the operation of G on <m1> are
   transposed. */
{
	int i, j, k, i1;
	int xoffset, yoffset;
	int dim;
	int dq, dq2;
	VEC help;
	VEC *M1, *M2;
	char val;
	GMODULE *tpm;
	int dim1, dim2, numgen, oprime;
	
	oprime = prime;

	swap_arith ( m1->g->prime );
	dim1 = m1->dim;
	dim2 = m2->dim;
	dim = dim1*dim2;
	dq = dim*dim;
	dq2 = dim2*dim2;
	numgen = m1->g->num_gen;
	
	tpm = ALLOCATE ( sizeof ( GMODULE ) );
	tpm->g = m1->g;
	tpm->dim = dim;
	tpm->echelon = NULL;
	tpm->T = tpm->TI = NULL;
	tpm->m = ARRAY ( numgen, VEC );
	for ( i = 0; i < numgen; i++ )
		tpm->m[i] = CALLOCATE ( dq );

	M1 = m1->echelon != NULL ? m1->echelon : m1->m;
	M2 = m2->echelon != NULL ? m2->echelon : m2->m;

	PUSH_STACK();
	help = ALLOCATE ( dq2 );
	for ( i = 0; i < dim1; i++ ) {
		yoffset = i*dim2*dim;
		for ( j = 0; j < dim1; j++ ) {
			xoffset = j*dim2;
			for ( k = 0; k < numgen; k++ ) {
				copy_vector ( M2[k], help, dq2 );
				if ( (val=transpose ? M1[k][j*dim1+i] : 
					 M1[k][i*dim1+j]) != 0 )
				    SMUL_VECTOR ( val, help, dq2 );
				else
				    zero_vector ( help, dq2 );
				for ( i1 = 0; i1 < dim2; i1++ )
					copy_vector ( help+i1*dim2,
						tpm->m[k]+yoffset+i1*dim+xoffset, dim2 );
			}
		}
	}
	POP_STACK();
	swap_arith ( oprime );
	return ( tpm );
}

void show_gmodule ( GMODULE *gm )
{
	register int i, j, k;

	for ( i = 0; i < gm->g->num_gen; i++ ) {
	    printf ( "\nm[%1d] = \n", i );
	    for ( j = 0; j < gm->dim; j++ ) {
		   for ( k = 0; k < gm->dim; k++ )
			  printf ( "%1d", gm->m[i][j*gm->dim+k] );
		   printf ( "\n" );
	    }
	}
	if ( gm->echelon != NULL ) {
	    printf ( "\ntriangular basis\n" );
	    for ( i = 0; i < gm->g->num_gen; i++ ) {
		   printf ( "\nm[%1d] = \n", i );
		   for ( j = 0; j < gm->dim; j++ ) {
			  for ( k = 0; k < gm->dim; k++ )
				 printf ( "%1d", gm->echelon[i][j*gm->dim+k] );
			  printf ( "\n" );
		   }
	    }
	    printf ( "\ntransformation matrix : \n" );
	    for ( j = 0; j < gm->dim; j++ ) {
		   for ( k = 0; k < gm->dim; k++ )
			  printf ( "%1d", gm->T[j*gm->dim+k] );
		   printf ( "\n" );
	    }
	    printf ( "\ninverse of transformation matrix : \n" );
	    for ( j = 0; j < gm->dim; j++ ) {
		   for ( k = 0; k < gm->dim; k++ )
			  printf ( "%1d", gm->TI[j*gm->dim+k] );
		   printf ( "\n" );
	    }
	}	    
}

VEC g_op_mat ( GMODULE *gm, PCELEM el, int use_echelon )
/* compute matrix representing the operation of group element <el> on
   G-module <gm>
   */
{
    int sdim = dim;
    int sdq = dquad;
    int numgen = gm->g->num_gen;
    int i;
    int e;
    VEC zw, res, el_m;
    VEC *M;

    dim = gm->dim;
    dquad = dim * dim;

    M = use_echelon ? gm->echelon : gm->m;

    res = el_m = Idmat();
    PUSH_STACK();
    for ( i = 0; i < numgen; i++ ) {
	   if ( (e=el[i]) != 0 ) {
		 zw = matrix_exp ( M[i], e );
		 res = MATRIX_MUL ( res, zw );
	   }
    }
    copy_vector ( res, el_m, dquad );
    dim = sdim;
    dquad = sdq;
    POP_STACK();
    return ( el_m );
}

VEC operation_image ( GMODULE *gm, VEC v, PCELEM el, int use_echelon )
/* For <v> an element of the G-module <gm> and <el> an element of G,
   compute <v>*<el>.
   */
{
    int i;
    char c;
    VEC el_m, v_el;
    
    v_el = CALLOCATE ( gm->dim );
    PUSH_STACK();
    el_m = g_op_mat ( gm, el, use_echelon );
    for ( i = 0; i < gm->dim; i++ )
	   if ( (c=v[i]) != 0 )
		  ADD_MULT ( c, el_m+i*gm->dim, v_el, gm->dim );
    POP_STACK();
    return ( v_el );
}
    
void echelonize_module ( GMODULE *gm )
/* compute a new basis for G-module <gm> such that all elements of G
   are represented by upper triangular matrices.
   */
{
    PCGRPDESC *g = gm->g;
    char **M;
    VEC Abs, Inh;
    VEC *fsol;
    VEC m_id, temp, T, TI;
    int xd, yd, i, j, k;
    int sd, sdq;
    int fixdim, compldim;
    PCGRPDESC *old_pc_group = group_desc;
    
    set_main_group ( g );
    sd = dim;
    sdq = dquad;

    compldim = gm->dim;
    fixdim = 0;
    xd = gm->dim;
    yd = g->num_gen * xd;
    dim = xd;
    dquad = dim * dim;

    if ( is_permanent ( gm ) ) {
	   gm->echelon = allocate ( g->num_gen * sizeof ( VEC ) );
	   gm->T = callocate ( dquad );
	   gm->TI = callocate ( dquad );
    }
    else {
	   gm->echelon = tallocate ( g->num_gen * sizeof ( VEC ) );
	   gm->T = tcallocate ( dquad );
	   gm->TI = tcallocate ( dquad );
    }
    for ( i = 0; i < g->num_gen; i++ ) {
	   gm->echelon[i] = is_permanent ( gm ) ? allocate ( dquad ) :
		  tallocate ( dquad );
	   copy_vector ( gm->m[i], gm->echelon[i], dquad );
    }
    for ( i = 0; i < dim; i++ )
	   gm->T[i*dim+i] = gm->TI[i*dim+i] = 1;

    PUSH_STACK();
    get_sle_space ( &M, &Abs, &Inh, xd, yd+dim );
    zero_vector ( Abs, yd+dim );
    
    /* coefficient matrix is (gm->m[0] - id,...,gm->m[d-1] - id)^T */
    m_id = CALLOCATE ( dquad );
    for ( i = 0; i < dim; i++ )
	   m_id[i*dim+i] = GPRIME-1;
    
    /* compute sequence of modules M1 < M2 < ... < Mt = M
	  where M1 = Fix(M), M(i+1) = Fix(M/Mi)
	  */
    while ( compldim != 0 ) {
	   
	   PUSH_STACK();
        /* compute fixpoints */
	   for ( k = 0; k < bperelem; k++ ) {
		  temp = ALLOCATE ( dquad );
		  copy_vector ( gm->echelon[k], temp, dquad );
		  ADD_VECTOR ( m_id, temp, dquad );
		  for ( i = 0; i < dim; i++ ) {
			 /* only fixpoints modulo last submodule already 
		 	    constructed are to be considered */
			 zero_vector ( temp+i*dim+compldim, fixdim );
			 for ( j = 0; j < dim; j++ )
			 M[j+k*dim][i] = temp[i*dim+j];
		  }
	   }
	   
	   fixdim  = xd - dsolve_equations ( M, Abs, Inh, xd, yd, &fsol );

	   /* compute a complement for fixmodule */
	   for ( i = fixdim; i--; )
		  copy_vector ( fsol[i], M[i], dim );
	   for ( i = 0; i < dim; i++ )
		  copy_vector ( m_id + i*dim, M[fixdim+i], dim );
	   
	   compldim = dcomplement ( M, fixdim, dim, fixdim+dim, &fsol );
    
	   /* setup transformation matrix */
	   T = ALLOCATE ( dquad );
	   for ( i = 0; i < compldim; i++ )
		  copy_vector ( fsol[i], T+i*dim, dim );
	   for ( i = compldim; i < dim; i++ )
		  copy_vector ( M[i-compldim], T+i*dim, dim );
	   
	   TI = matrix_inv ( T );
	   
	   copy_vector ( MATRIX_MUL ( T, gm->T ), gm->T, dquad );
	   copy_vector ( MATRIX_MUL ( gm->TI, TI ), gm->TI, dquad );

	   /* transform operation matrices */
	   for ( i = 0; i < bperelem; i++ ) {
		  temp = MATRIX_MUL ( T, gm->echelon[i] );
		  copy_vector ( MATRIX_MUL ( temp, TI ), gm->echelon[i], dquad );
	   }
	   POP_STACK();
    }

    set_main_group ( old_pc_group );
    dim = sd;
    dquad = sdq;
    POP_STACK();
}

/* end of module g-module */



