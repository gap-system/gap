/********************************************************************/
/*                                                                  */
/*  Module        : Group ring conjugation                          */
/*                                                                  */
/*  Description :                                                   */
/*     Allows to compute Z1 modulo cocycles stemming from conjuga-  */
/*     gation with 1 + I/I^n.                                       */
/*                                                                  */
/********************************************************************/

/* 	$Id: conju.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: conju.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:06:40  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: conju.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include <ctype.h>
#include "aglobals.h"
#include "fdecla.h"
#include	"pc.h"
#include	"grpring.h"
#include	"hgroup.h"
#include	"storage.h"
#include	"solve.h"

VEC gr_invers 				_(( VEC elem, int mod_id ));

extern PCGRPDESC *group_desc;
extern GRPRING *group_ring;
extern GRPDSC *h_desc;
extern int s_int;
extern int fend;
extern int new_xdim, new_cut;
extern IHEADER h_out;
extern int verbose;
extern FILE *proto;

#define MAXCENT 1024

VEC *centre;
VEC *i_centre;
int cent_dim;

VEC *central_involutions;
static int xd, cd, ci;

void centralizer ( VEC args[], int mod_id, int argn )
/* compute centralizer of args modulo I^(mod_id-1) */
{
	register int i, j, k;
	int pre_dim, xd, yd;
	VEC r_left, r_right, x;
	int offset;
	
	xd = FILTRATION[mod_id].i_start;
	pre_dim = FILTRATION[mod_id-1].i_start;
	yd = pre_dim * argn;
	absolut = CALLOCATE ( yd );
	inhom = ALLOCATE ( xd );
	x = ALLOCATE ( xd );
	for ( j = 0; j < xd; j++ ) {
		offset = 0;
		zero_vector ( x, xd );
		x[j] = 1;
		for ( i = argn; i--; ) {
			r_left = GROUP_MUL ( args[i], x, mod_id );
			r_right = GROUP_MUL ( x, args[i], mod_id );
			SUBA_VECTOR ( r_left, r_right, pre_dim );
			for ( k = pre_dim; k--; ) 
				matrix[(long)(k+offset)][(long)j] = r_right[k];
			offset += pre_dim;
		}
	}
	cent_dim = xd - solve_equations ( xd, yd );
	centre = ARRAY ( cent_dim, VEC );
	i_centre = ARRAY ( cent_dim, VEC );
	j = 0;
	for ( i = 0; i < xd; i++ ) {
		if ( fsolution[i] ) {
			centre[j] = ALLOCATE ( xd );
			copy_vector ( fsolution[i], centre[j], xd );
			centre[j][0] = 1;
			i_centre[j] = gr_invers ( centre[j], mod_id );
			j++;
		}
	}
	if ( proto != NULL )
		fprintf ( proto, "   dim of centre  = %d \n", cent_dim );
	if ( verbose )
		printf ( "dim of centralizer = %d\n", cent_dim );
}		

SPACE *e_centralizer ( VEC args[], int n_args, int mod_id )
{
	register int i, j, k;
	VEC r_left, r_right, x;
	int offset, xd, yd;
	char *old_top;
	long mem_offset;
	SPACE *v_cent = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	VEC p;

	xd = FILTRATION[mod_id].i_start;
	yd = xd * n_args;
	old_top = GET_TOP();
	p = ALLOCATE ( (long)xd * xd );
	v_cent->total_dim = xd;
	v_cent->b_flag = UPPER;
	v_cent->basis = p;
	
	absolut = CALLOCATE ( yd );
	inhom = ALLOCATE ( xd );
	x = ALLOCATE ( xd );
	for ( j = 0; j < xd; j++ ) {
		offset = 0;
		zero_vector ( x, xd );
		x[j] = 1;
		for ( i = n_args; i--; ) {
			r_left = GROUP_MUL ( args[i], x, mod_id );
			r_right = GROUP_MUL ( x, args[i], mod_id );
			SUBA_VECTOR ( r_left, r_right, xd );
			for ( k = xd; k--; ) 
				matrix[(long)(k+offset)][(long)j] = r_right[k];
			offset += xd;
		}
	}
	cent_dim = xd - solve_equations ( xd, yd );
	j = 0;
	for ( i = 0; i < xd; i++ ) {
		if ( fsolution[i] ) {
			copy_vector ( fsolution[i], p, xd );
			SMUL_VECTOR ( GPRIME-1, p, xd );
			j++;
			p += xd;
		}
	}
	v_cent->dimension = j;
	mem_offset = j * xd;
	mem_offset += ( mem_offset & 1L );
	SET_TOP ( old_top + mem_offset );

	return ( v_cent );
}		

int handle_conj ( VEC rho[] )
{
	int offset;
	register int i, j;
	int ydim = 0;
	VEC help, conj_vec, rhohom;

	conj_vec = ALLOCATE ( new_xdim );
	rhohom = CALLOCATE ( h_out.old_end );
	
	/* compute conjugates */
	for ( i = 1; i < cent_dim; i++ ) {
		offset = new_xdim;
		for ( j = NUMGEN; j--; ) {
			offset -= h_out.old_dim;
			copy_vector ( rho[j], rhohom, h_out.old_start );
			help = GROUP_MUL ( i_centre[i], rhohom, new_cut );
			help = GROUP_MUL ( help, centre[i], new_cut );
			copy_vector ( help+h_out.old_start, conj_vec+offset,
					  h_out.old_dim );
		}
		if ( !iszero ( conj_vec, new_xdim ) )
			copy_vector ( conj_vec, matrix[(long)ydim++], new_xdim );
	}
	return ( ydim );
}

int handle_central_involutions ( int ydim )
{
    int i, j;
    int iseg = FILTRATION[new_cut-1].i_start;
    int use_it;

    for ( i = 0; i < ci; i++ ) {
	   use_it = TRUE;
	   for ( j = 0; j < NUMGEN; j++ )
		  use_it &= iszero ( central_involutions[i]+j*xd, iseg );
	   if ( use_it ) {
		  for ( j = 0; j < NUMGEN; j++ ) 
			 copy_vector ( central_involutions[i]+j*xd+h_out.old_start, 
						matrix[(long)ydim]+j*h_out.old_dim, h_out.old_dim );
		  ydim++;
	   }
    }
    return ( ydim );
}

void get_central_involutions ( VEC rho[], int d, int cut )
{
    int i, j;
    SPACE *centre;
    VEC p, v, w;

    centre = e_centralizer ( rho, d, cut );
    xd = FILTRATION[cut].i_start;
    cd = centre->dimension;
    
    central_involutions = ARRAY ( (cd - 1)*d, VEC );
    for ( i = 0; i < (cd-1)*d; i++ )
	   central_involutions[i] = CALLOCATE ( xd * d );

    ci = 0;
    PUSH_STACK();
    for ( i = 1, p = centre->basis+xd; i < cd; i++, p += xd ) {
	   v = w = p;
	   while ( !iszero ( w, xd ) ) {
		  v = w;
		  w = GROUP_EXP ( v, GPRIME, cut );
	   }
	   for ( j = 0; j < d; j++ )
		  copy_vector ( v, central_involutions[ci++]+j*xd, xd );
    }
    POP_STACK();
}

/* end of module group ring conjugation */
