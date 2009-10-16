/********************************************************************/
/*                                                                  */
/*  Module	     : Lift control                                  */
/*                                                                  */
/*  Description :                                                   */
/*    Main module for testing lifting routines.                     */
/*                                                                  */
/********************************************************************/

/* 	$Id: lcontrol.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: lcontrol.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 1.7  1995/05/05 13:03:57  pluto
 * 	Added prototype for 'get_central_involutions'.
 *
 * Revision 1.6  1995/01/11  16:00:09  pluto
 * Removed call to new version routines from lift_control.
 *
 * Revision 1.5  1995/01/07  17:38:44  pluto
 * Added <lift_limit> parameter to gr_comp_aut.
 *
 * Revision 1.4  1995/01/05  17:05:11  pluto
 * Changed header to new style.
 *
 * Revision 1.3  1995/01/05  16:47:30  pluto
 * Nothing special.
 *
 * Revision 1.2  1994/12/29  13:07:50  pluto
 * Enabled new version.
 *	 */

#ifndef lint
static char vcid[] = "$Id: lcontrol.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include	"pc.h"
#include	"hgroup.h"
#include	"grpring.h"
#include	"storage.h"
#include	"solve.h"

void get_op_mats 		_(( void ));
void save_set			_(( void ));
void restore_set		_(( void ));
VEC sn_group_mul		_(( VEC vec1, VEC vec2, int cut ));
VEC sngroup_exp		_(( VEC vector, int power, int cut ));
void small_grpring		_(( VEC mask ));
void get_central_involutions    _(( VEC rho[], int d, int cut ));

extern FILE *proto;
extern int verbose;
extern char out_n[];
extern char in_n[];
extern FILE *out_f, *in_f;
extern int cut, fend, prime, card;
extern int s_int;
extern VEC *l_matrix, *r_matrix;
extern PCGRPDESC *group_desc;
extern GRPRING *group_ring;
extern GRPDSC *h_desc;

VEC h1[H1MAX];
VEC old_rho[MAXGEN], org_rho[MAXGEN];
long n_rho[MAXGRAD];
int start, part_start, rho_dim, dim, dquad;
int new_xdim, new_cut;
VEC h1_mod;
int param_dim, red_param, all_liftable;
int elim_central_involutions = FALSE;  /* !!! new version !!! */
IHEADER h_in, h_out;
int old_xdim;
int small_groupring = FALSE;
VEC svec;

static long lif_rho, bad_rho;
int test_new_version = TRUE; /* !!! new version !!! */

void set_files ( int from, int to )
{
	char c1, c2;
	char *dot;

	dot = strchr ( in_n, '.' );
	dot -= 3;
	c1 = from % 10;
	c2 = from / 10;
	dot[1] = c2 + '0';
	dot[2] = c1 + '0';
	dot = strchr ( out_n, '.' );
	dot -= 3;
	c1 = to % 10;
	c2 = to / 10;
	dot[1] = c2 + '0';
	dot[2] = c1 + '0';
}

void mod_with_h1 ( VEC index, int len )
{
	register int i, offset;
	register int odim = h_in.old_dim;
	register char val;
		
	zero_vector ( h1_mod, old_xdim );
	for ( i = len; i--; ) {
		if ( ( val = index[i] ) != 0 ) {
			ADD_MULT ( val, h1[i], h1_mod, old_xdim );
		}
	}
	offset = old_xdim;
	for ( i = NUMGEN; i--; ) {
		offset -= odim;
		ADD_VECTOR ( h1_mod+offset, old_rho[i]+h_in.old_start, odim );
	}
}

void debug (VEC *args, int cnt, int last)
{
	int i;
	for ( i = 0; i < cnt; i++ )
		n_group_write ( args[i], last );
}

long fetch_nrho (int mod_id)
{
	long num;
	
	if ( (num = n_rho[mod_id]) == 0 ) {
		printf ( "number of liftings mod I^%d :", mod_id );
		scanf ( "%ld", &num );
		n_rho[mod_id] = num;
	}
	return ( num );
}

void extract_rho(void)
{
	char in_file[13], rho_file[13];
	FILE *inf, *rhf;
	int k, i, n_bl;
	IHEADER i1, i2;
	
	printf ( "file to extract from : " );
	scanf ( "%13s", in_file );
	printf ( "rho file		 : " );
	scanf ( "%13s", rho_file );
	printf ( "number of blocks : " );
	scanf ( "%d", &n_bl );

	inf = get_header ( in_file, &i1 );
	i2 = i1;
	i2.old_end = i1.old_start;
	rhf = put_header ( rho_file, &i2 );
	
	PUSH_STACK();
	/* storage for rhos */
	for ( i = NUMGEN; i--; )
		old_rho[i] = ALLOCATE ( i1.old_end );
	for ( k = n_bl; k--; ) {
		PUSH_STACK();
		get_rho ( old_rho, h1, i1.old_end, &i1, inf );
		put_rho ( old_rho, h1, 0, &i2, rhf );
		POP_STACK();
	}
	fclose ( inf );
	fclose ( rhf );
	POP_STACK();
}

/* lift modulo conjugation */
void do_control ( int sublift )
{
	VEC ind_vec;
	int h1_dim, j, lift;
	long k;

	new_cut = part_start + 1;
	set_files ( part_start, new_cut );
	start = rho_dim = FILTRATION[part_start].i_start;
	fend	= FILTRATION[cut].i_start;
	dim = fend - start;
	dquad = dim * dim;
	h_out.old_start = start;
	h_out.old_end = FILTRATION[new_cut].i_start;
	h_out.old_dim = h_out.old_end - h_out.old_start;
	new_xdim = NUMGEN * h_out.old_dim;
	
	if ( verbose ) {
		printf ( "part_start = %d \n", part_start );
		printf ( "cut	   = %d \n", cut );
		printf ( "new_cut	   = %d \n", new_cut );
		printf ( "start	   = %d \n", start );
		printf ( "fend	   = %d \n", fend );
		printf ( "rho_dim    = %d \n", rho_dim );
		printf ( "dimension  = %d \n", dim );
	}

	if ( proto != NULL ) {
		fprintf ( proto, "lifting from FG/I^%d to FG/I^%d \n", part_start, part_start+1 );
		fprintf ( proto, "   part_start = %d \n", part_start );
		fprintf ( proto, "   cut        = %d \n", cut );
		fprintf ( proto, "   new_cut    = %d \n", new_cut );
		fprintf ( proto, "   start      = %d \n", start );
		fprintf ( proto, "   fend        = %d \n", fend );
		fprintf ( proto, "   rho_dim    = %d \n", rho_dim );
		fprintf ( proto, "   dimension  = %d \n", dim );
	}

	if ( !sublift )
		centralizer ( NGEN_VEC, new_cut, GMINGEN );
	
	x_dim = dim * NUMGEN;
	y_dim = dim * NUMREL;
	absolut = CALLOCATE ( y_dim );
	inhom = CALLOCATE ( x_dim );

	lif_rho = bad_rho = 0;

	/* read file header, write file header of new file */
	in_f = get_header ( in_n, &h_in );
	old_xdim = h_in.old_dim * NUMGEN;
	out_f = put_header ( out_n, &h_out );
		
	/* get storage for old rhos and transformation matrices */
	for ( j = NUMGEN; j--; ) {
		org_rho[j] = ALLOCATE ( fend );
		old_rho[j] = ALLOCATE ( fend );
	}
	l_matrix = ARRAY ( rho_dim, VEC );
	r_matrix = ARRAY ( rho_dim, VEC );
	for ( j = rho_dim; j--; ) {
		l_matrix[j] = ALLOCATE ( dquad );
		r_matrix[j] = ALLOCATE ( dquad );
	}
	get_op_mats();
	h1_mod = ALLOCATE ( old_xdim );
	param_dim = red_param = 0;
	all_liftable = TRUE;		

	for ( k = n_rho[part_start]; k--; ) {
		PUSH_STACK();
		if ( verbose )
			printf ( "current block : %ld \n\n", k );
		if ( proto != NULL )
			fprintf ( proto, "current block : %ld \n\n", k );
		h1_dim = get_rho ( org_rho, h1, fend, &h_in, in_f );
		ind_vec = CALLOCATE ( h1_dim );
		do  {
			for ( j = NUMGEN; j--; ) 
				copy_vector ( org_rho[j], old_rho[j], fend );
			mod_with_h1 ( ind_vec, h1_dim ); 
			if ( sublift ) {
				save_set();
				centralizer ( old_rho, new_cut, NUMGEN );
				restore_set();
			}
			lift = try_to_lift ( old_rho );
			if ( lift )
				lif_rho++;
			else
				bad_rho++;
		} while ( inc_count ( ind_vec, h1_dim ) );
		POP_STACK();
	}
	n_rho[new_cut] = lif_rho;
	fclose ( in_f );
	fclose ( out_f );
	printf ( "to FG/I^%2d liftable rho's  : %ld \n", new_cut, lif_rho );
	printf ( "not liftable rho's	        : %ld \n", bad_rho );
	printf ( "sum of old rho's	        : %ld \n\n", n_rho[part_start] );
	if ( proto != NULL ) {
		fprintf ( proto, "   to FG/I^%2d liftable rho's : %ld \n", new_cut, lif_rho );
		fprintf ( proto, "   not liftable rho's	   : %ld \n", bad_rho );
		fprintf ( proto, "   sum of old rho's	         : %ld \n", n_rho[part_start] );
		fprintf ( proto, "   dimension of Z^1(FH,I^%d/I^%d) : %d\n",
			part_start, cut, param_dim );
		fprintf ( proto, "   dimension of H^1(FH,I^%d/I^%d) : %d\n\n",
			part_start, part_start+1, red_param );
	}
	if ( (param_dim == dim * NUMGEN) && (all_liftable == TRUE ) ) {
		puts ( "completely liftable !!!!!" );
		if ( proto != NULL )
			fputs ( "completely liftable !!!!!\n\n", proto );
	}
}

void small_grpring ( VEC mask )
/* set a mask of length |G| for computing in small group rings. All monomials 
   of a given element for which the mask is zero will have coefficient zero.
   The mask is specified as an element of KG which has coefficient one for 
   those monomials for which the mask shall be one. If <mask> is NULL a
   default mask is used where all monomials belonging to I(G_n)*I(G) are set 
   to zero. */
{
	int i, j;
	int gcard = group_desc->group_card;
	
	svec = ALLOCATE ( gcard );
	if ( mask != NULL )
	    copy_vector ( mask, svec, gcard );
	else {
	    memset ( svec, 1, gcard );
	    for ( i = 0; i < gcard; i += GPRIME )
		   for ( j = 1; j < GPRIME; j++ )
			  svec[i+j] = 0;
	    svec[1] = 1;
	    svec = re_order ( svec );
	}
	printf ( "svec: " );
	n_group_write ( svec, MAX_ID );
	small_groupring = TRUE;
}

void lift_control ( GRPDSC *h, int first, int last, int lookahead, 
				int sublift, int smallgrpring )
{
	int i;
	GRPDSC *old_p_group;
	char *out_f2;
	int old_cut = cut;


	old_p_group = h_desc;
	set_h_group ( h );

	if ( smallgrpring ) {
	    group_mul = sn_group_mul;
	    group_exp = sngroup_exp;
	    small_grpring ( NULL );
	}
	
	if ( elim_central_involutions )
	    get_central_involutions ( NGEN_VEC, GMINGEN, MAX_ID );

	part_start = first;
	
	/* handle case I^2 */
	if ( part_start < 2 ) {
		dim = FILTRATION[1].i_dim;
		x_dim = dim;
		y_dim = NUMGEN;
		out_n[7] = 2 + '0';
		out_f2 = add_path ( "IDEAL", out_n );

#ifdef SUN3
		out_f = fopen ( out_f2, "w" );
#else
#ifdef ANSI
		out_f = fopen ( out_f2, "wb" );
#else
		out_f = fopen ( out_f2, "bw" );
#endif
#endif

		i = dim + 1;
		fwrite ( &i, sizeof ( int ), 1, out_f );
		i = 0;
		fwrite ( &i, sizeof ( int ), 1, out_f );
		i = dim + 1;
		fwrite ( &i, sizeof ( int ), 1, out_f );
		n_rho[2] = test_mod2 ( sublift );
		if ( proto != NULL ) 
			fprintf ( proto, "to FG/I^2 liftable rho's : %ld \n\n", n_rho[2] );
		printf ( "to FG/I^2 liftable rho's : %ld \n", n_rho[2] );
		fclose ( out_f );
		part_start = 2;
	}

	/* set global values for ideal I^first_id */
	
	fetch_nrho ( part_start );	
	
	/* lifting loop */
	while ( (part_start < last) && (n_rho[part_start] != 0L) ) {
		PUSH_STACK();
		/* set global values */
		if ( (cut = lookahead) == 0 )
			cut = part_start<<1;
		if ( cut > MAX_ID )
			cut = MAX_ID;
		do_control ( sublift );
		part_start++;
		POP_STACK();
	}
	cut = old_cut;
	set_h_group ( old_p_group );
	if ( smallgrpring ) {
	    group_mul = n_group_mul;
	    group_exp = ngroup_exp;
	}
}

/* should be revised */
void lift_one_step (void)
{
	int j, k;
	int h1_dim;
	long lif_rho, bad_rho;
	VEC ind_vec;

	/* get file and ideal */
	printf ( "input file : " );
	scanf ( "%13s", in_n );
	printf ( "test ideal nr. ( cut ) : " );
	scanf ( "%d", &cut );
	printf ( "number of blocks : " );
	scanf ( "%d", &k );
	
	/* set global values */
	if ( cut > MAX_ID )
		cut = MAX_ID;
	start = FILTRATION[cut-1].i_start;
	fend	= FILTRATION[cut].i_start;
	bad_rho = lif_rho = 0;

	PUSH_STACK();
	
	/* read file header, write file header of new file */ 
	in_f = get_header ( in_n, &h_in );
	old_xdim = h_in.old_dim * NUMGEN;
		
	/* get storage for old rhos */
	for ( j = NUMGEN; j--; ) {
		org_rho[j] = ALLOCATE ( fend );
		old_rho[j] = ALLOCATE ( fend );
	}
	h1_mod = ALLOCATE ( old_xdim );
		
	PUSH_STACK(); 		
	while ( k-- ) {
		h1_dim = get_rho ( org_rho, h1, fend, &h_in, in_f );
		ind_vec = ALLOCATE ( h1_dim );
		zero_vector ( ind_vec, h1_dim );
		do  {
			for ( j = NUMGEN; j--; ) 
				copy_vector ( org_rho[j], old_rho[j], fend );
			mod_with_h1 ( ind_vec, h1_dim );
			if ( check_next_obs ( old_rho ) ) {
				puts ( ">>>>>>>>>> liftable <<<<<<<<<<" );				
				lif_rho++;
			}
			else {
				puts ( "########## not liftable ##########" );
				bad_rho++;
			}
		} while ( inc_count ( ind_vec, h1_dim ) );
		POP_STACK();
	}
	fclose ( in_f );
	POP_STACK();
}

void
cut_first_id (int ideal)
{
	int new_h1_dim, h1_dim, i, j;
	long k;
	char nonzero;
	
	PUSH_STACK();
	printf ( "use liftings mod I^" );
	scanf ( "%d", &part_start );
	set_files ( part_start, ideal );

	in_f = get_header ( in_n, &h_in );
	h_out.old_end = FILTRATION[ideal].i_start;
	h_out.old_dim = FILTRATION[ideal-1].i_dim;
	h_out.old_start = h_in.old_start;
	out_f = put_header ( out_n, &h_out );
	old_xdim = h_in.old_dim * NUMGEN;
	x_dim = h_out.old_dim * NUMGEN;
	absolut = CALLOCATE ( YMAX );
	inhom = ALLOCATE ( x_dim );
	
	for ( i = NUMGEN; i--; ) 
		old_rho[i] = ALLOCATE ( h_in.old_end );

	k = fetch_nrho ( part_start );
	n_rho[ideal] = k;
	
	for ( ; k--; ) {
		PUSH_STACK();
		h1_dim = get_rho ( old_rho, h1, h_in.old_end, &h_in, in_f );
		y_dim = h1_dim;
		for ( i = h1_dim; i--; ) {
			for ( j = 0; j < NUMGEN; j++ )
				copy_vector ( h1[i]+j*h_in.old_dim,
				              matrix[i]+j*h_out.old_dim,
						  h_out.old_dim );
		}
		new_h1_dim = GAUSS_ELIMINATE();
		fwrite ( &new_h1_dim, s_int, 1, out_f );
		for ( i = NUMGEN; i--; )
			fwrite ( old_rho[i], h_out.old_end, 1, out_f );
		for ( i = y_dim; i--; ) {
			nonzero = 0;
			j = 0;
			while ( !nonzero && ( j < x_dim ) ) 
				nonzero |= matrix[i][j++];
			if ( nonzero )
				fwrite ( matrix[i], x_dim, 1, out_f );
		}
		POP_STACK();
	}
	POP_STACK();
	fclose ( in_f );
	fclose ( out_f );
}

void verify ( GRPDSC *h, int ideal )
{
	int j, i;
	VEC rel_obs[30];
	long k;
	GRPDSC *old_p_group;
	char not_okay;
	int old_cut = cut;

	old_p_group = h_desc;
	set_h_group ( h );

	part_start = cut = ideal;
	strcpy ( out_n, "WRONG000.LST" );
	set_files ( part_start, cut );
	start = rho_dim = FILTRATION[part_start].i_start;
	fend = FILTRATION[cut].i_start;
	dim = fend - start;
	dquad = dim * dim;

	in_f = get_header ( in_n, &h_in );
	out_f = put_header ( out_n, &h_in );
	old_xdim = h_in.old_dim * NUMGEN;

	for ( j = NUMGEN; j--; ) 
		org_rho[j] = ALLOCATE ( fend );
		
	printf ( "fend = %d \n", fend );
	k = fetch_nrho ( part_start );
	printf ( "n_rho[%2d] = %ld \n", part_start, k );
	for ( ; k--; ) {
		PUSH_STACK();
		printf ( "testing rho no. %ld \n", k );
		get_rho ( org_rho, h1, fend, &h_in, in_f );
		for ( i = 0; i < NUMGEN; i++ )
			n_group_write ( org_rho[i], cut );
		for ( i = NUMREL; i--; ) 
			rel_obs[i] = obstruct ( RELATION[i], org_rho );
		not_okay = 0;
		i = NUMREL;
		while ( i-- && !not_okay ) {
			j = fend;
			while ( --j && !not_okay ) {
				if ( rel_obs[i][j] ) {
					printf ( "i = %d j = %d\n", i, j );
					n_group_write ( rel_obs[i], cut );
				}
				not_okay |= rel_obs[i][j];
			}
		}
		if ( !not_okay )
			puts ( ">>>>>>>>>> okay! <<<<<<<<<<" );
		else {
			put_rho ( org_rho, h1, 0, &h_in, out_f );
			puts ( "########## error! ##########" );
		}
		POP_STACK();
	}
	fclose ( in_f );
	fclose ( out_f );
	strcpy ( out_n, "IDEAL000.LIF" );
	cut = old_cut;
	set_h_group ( old_p_group );
}

/* end of module lift control */









