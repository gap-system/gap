/********************************************************************/
/*                                                                  */
/*  Module        : Input Output                                    */
/*                                                                  */
/*  Description :                                                   */
/*     Supplies the input/output procedures for group and group     */
/*     ring informations                                            */
/*                                                                  */
/********************************************************************/

/* 	$Id: inout.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: inout.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 1.3  1995/08/03 14:45:36  pluto
 * 	Added version information printing in 'show_logo'.
 *
 * 	Revision 1.2  1995/01/05 17:09:09  pluto
 * 	Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: inout.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include <ctype.h>
#include	"pc.h"
#include	"hgroup.h"
#include	"storage.h"
#include	"aut.h"
#ifndef SUN3
#include <stdlib.h>
#endif

void show_version           _(( void ));

extern GRPRING *group_ring;
extern PCGRPDESC *group_desc;
extern GRPDSC *h_desc;
extern VEC *can_to_new;
extern VEC *new_to_can;
extern int s_int;

extern char baut_file[256];
extern int **aut;
extern int aut_num;
extern int have_aut, have_stab;
extern int **stabs;
extern char out_n[13];
extern char in_n[13];
extern FILE *out_f, *in_f;
extern long n_rho[MAXGRAD];
extern long amount, tamount;

static FILE *aut_f;
char full_path[256];
char root_path[256];
static char proto_path[256];
static char ideal_path[256];
static char group_path[256];

void show_logo(void)
{
	puts ( "\n\n" );
	puts ( "          SSSS  I  SSSS  Y   Y  PPPP  H  H  OOOO  SSSS" );
	puts ( "          S     I  S     Y   Y  P  P  H  H  O  O  S   " );
	puts ( "          SSSS  I  SSSS   Y Y   PPPP  HHHH  O  O  SSSS" );
	puts ( "             S  I     S    Y    P     H  H  O  O     S" );
	puts ( "          SSSS  I  SSSS    Y    P     H  H  OOOO  SSSS" );
	puts ( "" );
	puts ( "                   or the age of absurdity" );
	puts ( "                   a computer adventure by" );
	puts ( "                        K.W. Roggenkamp,");
	puts ( "                        L.L. Scott and" );
	puts ( "                         M. Wursthorn" );
	puts ( "\n" );
	show_version();
}
	
void
show_settings(void)
{
#ifdef DEBUG
	printf ( "max. number of columns in matrix (XMAX) : %d\n", XMAX );
	printf ( "max. number of   rows  in matrix (YMAX) : %d\n", YMAX );
	printf ( "max. order of group            (MAXCARD): %d\n", MAXCARD );
	printf ( "max. Loewy - length            (MAXGRAD): %d\n", MAXGRAD );
	printf ( "max. dimension of H1            (H1MAX) : %d\n", H1MAX );
#endif
	printf ( "size of permanent memory heap           : %ld\n", amount );
	printf ( "size of temporary memory heap           : %ld\n", tamount );
	printf ( "root directory                          : %s\n\n\n", root_path );
}

void set_paths (void)
{
	long rlen = strlen ( root_path );
	char *path;
	
	if ( rlen == 0 )
		if ( (path = getenv ( "SISLIB" )) != NULL ) {
			strcpy ( root_path, path );
			rlen = strlen ( root_path );
		}
	/* strncpy ( proto_path, root_path, rlen );
	strncpy ( ideal_path, root_path, rlen ); */
	strncpy ( group_path, root_path, rlen );

#ifdef UNIX
	/* strcpy ( proto_path+rlen, "proto/" );
	strcpy ( ideal_path+rlen, "ideal/" ); */
	strcpy ( group_path+rlen, "groups/" );
#else
	/* strcpy ( proto_path+rlen, "proto\\" );
	strcpy ( ideal_path+rlen, "ideal\\" ); */
	strcpy ( group_path+rlen, "groups\\" );
#endif

}

char *add_path ( char *env_var, char *filename )
{
	char *help;
	
	if ( strcmp ( "PROTO", env_var ) == 0 )
		strcpy ( full_path, proto_path );
	else
		full_path[0] = '\0';
	if ( strcmp ( "IDEAL", env_var ) == 0 )
		strcpy ( full_path, ideal_path );
	else
		full_path[0] = '\0';
	if ( strcmp ( "GROUPDSC", env_var ) == 0 )
		strcpy ( full_path, group_path );
	
	help = strcat ( full_path, filename );
	return ( help );
}

FILE *FOpenb ( char *env, char file_n[], char *mode )
{
	char *nmode = "bb";
	
#ifdef SUN3
	nmode[0] = mode[0];
	nmode[1] = '\0';
#else	
#ifdef ANSI
	nmode[0] = mode[0];
#else
	nmode[1] = mode[0];
#endif
#endif
	
	return ( fopen ( add_path ( env, file_n ), nmode ) );
}
 
VEC c_n_trans (VEC c_vec, int mod_id)
{
	VEC res;
	register int i;
	register int fend = FILTRATION[mod_id].i_start;
	register char val;
	
	res = CALLOCATE ( fend );
	for ( i = GCARD; i--; ) {
		if ( (val=c_vec[i]) != 0 )
			ADD_MULT ( val, can_to_new[i], res, fend );
	}
	return ( res );
}

VEC n_c_trans (VEC n_vec, int mod_id)
{
	VEC res;
	register int i;
	register int fend = FILTRATION[mod_id].i_start;
	register char val;
	
	res = CALLOCATE ( GCARD );
	for ( i = fend; i--; ) {
		if ( (val=n_vec[i]) != 0 )
			ADD_MULT ( val, new_to_can[i], res, GCARD );
	}
	return ( res );
}

void aut_write ( char file_n[], HOM *maps )
{
	register int i, j;
	int nq, autord;
	int flag;
	int mod_id = maps->g->max_id;

	aut_f = FOpenb ( "GROUPDSC", file_n, "w" );

	nq = maps->g->num_gen * maps->g->num_gen;
	fwrite ( &maps->auts, s_int, 1, aut_f );	
	fwrite ( &maps->inn_log, s_int, 1, aut_f );	
	fwrite ( &maps->out_log, s_int, 1, aut_f );	
	fwrite ( &maps->elements, s_int, 1, aut_f );	
	fwrite ( &maps->g->exp_p_class, s_int, 1, aut_f );	

	fwrite ( maps->aut_gens_dim, s_int, maps->g->exp_p_class+1, aut_f );
	for ( i = 1; i <= maps->g->exp_p_class; i++ ) {
		for ( j = 0; j < maps->aut_gens_dim[i]; j++ ) {
			fwrite ( maps->aut_gens[i][j], nq, 1, aut_f );
		}
	}
	if ( maps->stabs != NULL ) {
		flag = 1;
		autord = maps->aut_gens_dim[1];
		fwrite ( &flag, s_int, 1, aut_f );
		for ( ;mod_id > 1; mod_id-- )
			fwrite ( maps->stabs[mod_id], s_int, autord+1, aut_f );
	}
	else {
		flag = 0;
		fwrite ( &flag, s_int, 1, aut_f );
	}
	fclose ( aut_f );
}

HOM *aut_read ( char file_n[], PCGRPDESC *g_desc )
{
	register int i, j;
	HOM *maps;
	int flag, nq, autord;
	int mod_id = g_desc->max_id;

	aut_f = FOpenb ( "GROUPDSC", file_n, "r" );

	maps = ALLOCATE ( sizeof ( HOM ) );
	maps->g = g_desc;
	
	nq = g_desc->num_gen * g_desc->num_gen;
	fread ( &maps->auts, s_int, 1, aut_f );	
	fread ( &maps->inn_log, s_int, 1, aut_f );	
	fread ( &maps->out_log, s_int, 1, aut_f );	
	fread ( &maps->elements, s_int, 1, aut_f );	

	maps->aut_gens_dim = ALLOCATE ( (g_desc->exp_p_class+1) * sizeof ( int ) );
	fread ( maps->aut_gens_dim, s_int, g_desc->exp_p_class+1, aut_f );
	maps->aut_gens = ARRAY ( g_desc->exp_p_class+1, VEC* );
	for ( i = 1; i <= g_desc->exp_p_class; i-- ) {
		maps->aut_gens[i] = ARRAY ( maps->aut_gens_dim[i], VEC );
		for ( j = 0; j < maps->aut_gens_dim[i]; j++ ) {
			maps->aut_gens[i][j] = ALLOCATE ( nq );
			fread ( maps->aut_gens[i][j], nq, 1, aut_f );
		}
	}
	
	fread ( &flag, s_int, 1, aut_f );
	if ( flag == 1 ) {
		autord = maps->aut_gens_dim[1];
		maps->stabs = ARRAY ( mod_id+1, int* );
		for ( ;mod_id > 1; mod_id-- ) {
			maps->stabs[mod_id] = (int *)CALLOCATE ( (autord+1)*s_int );
			fread ( maps->stabs[mod_id], s_int, autord+1, aut_f );
		}
	}
	else
		maps->stabs = NULL;
	fclose ( aut_f );
	return ( maps );
}

int get_rho (VEC *rho, VEC *h1, int fend, IHEADER *inf_header, FILE *in_f)
{
	int h1dim, i;
	register int o_xdim = inf_header->old_dim * NUMGEN;
	register int rest = fend - inf_header->old_end;

	fread ( &h1dim, s_int, 1, in_f );
	for ( i = NUMGEN; i--; ) { 
		fread ( rho[i], inf_header->old_end, 1, in_f );
		zero_vector ( rho[i]+inf_header->old_end, rest );
	}
	for ( i = h1dim; i--; ) {
		h1[i] = ALLOCATE ( o_xdim );
		fread ( h1[i], o_xdim, 1, in_f );
	}
	return ( h1dim );
}

FILE *get_header (char *f_name, IHEADER *inf_header)
{
	FILE *in_f;
	f_name = add_path ( "IDEAL", f_name );
	
#ifdef SUN3
	in_f	= fopen ( f_name, "r" );
#else
#ifdef ANSI
	in_f	= fopen ( f_name, "rb" );
#else
	in_f	= fopen ( f_name, "br" );
#endif
#endif

	if ( in_f ) 		
		fread ( inf_header, sizeof ( IHEADER ), 1, in_f );
	else
		puts ( "ERROR - couldn't open RHO file" );
	return ( in_f );
}

void put_rho (VEC *rho, VEC *h1, int h1dim, IHEADER *inf_header, FILE *out_f)
{
	register int i;
	register o_xdim = inf_header->old_dim * NUMGEN;
	
	fwrite ( &h1dim, s_int, 1, out_f );
	for ( i = NUMGEN; i--; )
		fwrite ( rho[i], inf_header->old_end, 1, out_f );
	for ( i = h1dim; i--; )
		fwrite ( h1[i], o_xdim, 1, out_f );
}

FILE *put_header (char *f_name, IHEADER *inf_header)
{
	FILE *out_f;
	f_name = add_path ( "IDEAL", f_name );
	
#ifdef SUN3
	out_f	= fopen ( f_name, "w" );
#else
#ifdef ANSI
	out_f	= fopen ( f_name, "wb" );
#else
	out_f	= fopen ( f_name, "bw" );
#endif
#endif

	if ( out_f )
		fwrite ( inf_header, sizeof ( IHEADER ), 1, out_f );
	else
		puts ( "ERROR - couldn't open RHO file" );
	return ( out_f );
}

void show_homomorphisms ( GRPDSC *h, int n, long count, char *file_n )
{
	FILE *rho_f;
	char *old_top;
	VEC h1_vec;
	VEC *old_rho;
	int j, i, h1_dim;
	int old_dim, old_start, old_end, old_xdim;
	GRPDSC *old_p_group;
	long k, rho;
	char *in_fp;
	
	old_p_group = h_desc;
	set_h_group ( h );

	if ( file_n == NULL )
		rho_f = stdout;
	else {
		file_n = add_path ( "PROTO", file_n );
		rho_f = fopen ( file_n, "w" );
	}
	
	PUSH_STACK();
	old_rho = ARRAY ( NUMGEN, VEC );
	old_top = GET_TOP();
	if ( n > 1 && n < MAX_ID+2 ) {
		fprintf ( rho_f, "\nList of homomorphisms into I^%1d :\n", n );
		set_files ( n, n+1 );
		
		in_fp = add_path ( "IDEAL", in_n );
#ifdef ANSI
		in_f = fopen ( in_fp, "rb" );
#else
#ifdef SUN3
		in_f = fopen ( in_fp, "r" );
#else
		in_f = fopen ( in_fp, "br" );
#endif
#endif
		fread ( &old_end, s_int, 1, in_f );
		fread ( &old_dim, s_int, 1, in_f );
		fread ( &old_start, s_int, 1, in_f );
		fprintf ( rho_f, "length of rho	    : %1d \n", old_end );
		fprintf ( rho_f, "dimension of H1	    : %d \n", old_dim );
		fprintf ( rho_f, "start of modification : %d \n", old_start );
		old_xdim = old_dim * NUMGEN;
		for ( i = NUMGEN; i--; ) 
			old_rho[i] = ALLOCATE ( old_end );
		h1_vec = ALLOCATE ( old_xdim );
		rho = 0;
		printf ( "n_rho[%1d] = %ld \n", n, n_rho[n] );
		for ( k = count; k--; ) {
			fread ( &h1_dim, s_int, 1, in_f );
			printf ( "h1_dim = %d \n", h1_dim );
			fprintf ( rho_f, "\n\nrho nr. %ld : \n", ++rho );
			for ( j = NUMGEN; j--; ) {
				fprintf ( rho_f, "gen.%1d : ", j );
				fread ( old_rho[j], old_end, 1, in_f );
				     group_write ( old_rho[j], n, rho_f );
			}				
			fprintf ( rho_f, "\nBasis for H1 : \n" );
			while ( h1_dim-- ) {
				fread ( h1_vec, old_xdim, 1, in_f );
				for ( j = 0; j < old_xdim; j++ )
					fprintf ( rho_f, "%1d", h1_vec[j] );
				fprintf ( rho_f, "\n" );
			}
		}
		fclose ( in_f );
		if ( rho_f != stdout )
			fclose ( rho_f );
		SET_TOP ( old_top );
	}
	POP_STACK();
	set_h_group ( old_p_group );
}

