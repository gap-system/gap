/* 	$Id: agsupp.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: agsupp.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:21:14  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: agsupp.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include <ctype.h>
#include	<string.h>
#include "aglobals.h"
#include "pc.h"
#include	"aggroup.h"
#include "fdecla.h"
#include	"storage.h"
#include	"error.h"
#include	"solve.h"

#define POWERS					aggroup->powers
#define POTS					aggroup->p_list
#define CONJUGATES				aggroup->conjugates
#define AVEC					aggroup->avec

extern int prime;
extern int bperelem;
extern AGGRPDESC *aggroup;

VEC *conj_list 		_(( PCELEM *rho, int s, int *l ));
int inc_ag 			_(( PCELEM el, int len, int *powers ));

PCELEM **Stab;
PCELEM **Orbgen;
int *Stablen;
int *Orbgenlen;
int **Lind;

static PCELEM *id;
static int *pag_w;
static PCELEM *words;
static int nwords = 0;
static int *marked;
static PCELEM *T;
static int *tps;
static int tlen = 0;

int insert_cgs ( PCELEM w  )
{
	int i, j, k;
	int ej = 0;
	int sprime = prime;
	PCELEM h, new_w;
	char *old_top;
	
	old_top = GET_TOP();
	new_w = ALLOCATE ( bperelem );
	PUSH_STACK();
	for ( j = 0; j < nwords; j++ ) {
		if ( (ej=w[pag_w[j]]) != 0 ) {
			h = ag_expo ( words[j], POWERS[pag_w[j]] - ej );
			w = agcollect ( w, h );
		}
	}
	if ( !iszero ( w, bperelem ) ) {
		for ( j = 0; j < bperelem; j++ )
			if ( (ej=w[j]) != 0 ) break;
		prime = POWERS[j];
		w = ag_expo ( w, fp_inv ( ej ) );
		prime = sprime;
		i = 0;
		if ( nwords != 0 )
			while ( pag_w[i] < j ) i++;
		for ( k = nwords; k > i; k-- ) {
			words[k] = words[k-1];
			pag_w[k] = pag_w[k-1];
			marked[k] = marked[k-1];
		}
		copy_vector ( w, new_w, bperelem );
		words[i] = new_w;
		pag_w[i] = j;
		marked[i] = FALSE;
		nwords++;
		POP_STACK();
		return ( j );
	}
	else {
		POP_STACK();
		SET_TOP ( old_top );
		return ( -1 );
	}
}

int exist_unmarked ( int *n )
{
	int i;
	
	for ( i = 0; i < nwords; i++ ) {
		if ( !marked[i] ) {
			*n = i;
			return ( TRUE );
		}
	}
	return ( FALSE );
}

void merge_cgs (  PCELEM w  )
{
	int i, j, k, cnr;
	PCELEM h1, h2;
	char v;
		
	insert_cgs ( w );
	
	while ( exist_unmarked ( &i ) ) {
		j = pag_w[i];
		if ( aggroup->p_len[j] != 0 ) {
			h1 = ag_expo ( words[i], POWERS[j] );
			insert_cgs ( h1 );
		}
		for ( k = 0; k < nwords; k++ ) {
			if ( marked[k] ) {
				cnr = pag_w[k] > j ?  CN ( pag_w[k], j ) : CN ( j, pag_w[k] );
				if ( aggroup->c_len[cnr] != 0 ) {
					if ( pag_w[k] > j )
						h1 = ag_comm ( words[pag_w[k]], words[j] );
					else
						h1 = ag_comm ( words[j], words[pag_w[k]] );
					insert_cgs ( h1 );
				}
			}
		}
		marked[i] = TRUE;
	}

	for ( i = 1; i < nwords; i++ ) {
		j = pag_w[i];
		for ( k = 0; k < i; k++ ) {
			if ( (v = words[k][j]) != 0 ) {
				PUSH_STACK();
				h1 = ag_invers ( words[i] );
				h1 = ag_expo ( h1, v );
				h2 = agcollect ( words[k], h1 );
				copy_vector ( h2, words[k], bperelem );
				POP_STACK();
			}
		}
	}
}
			
PCELEM *conj_id ( PCELEM g, int s )
{
	PCELEM *conjid;
	PCELEM h;
	int j;
	
	conjid = ARRAY ( ANUMGEN, PCELEM );

	/* conjugate identity with gi */
	for ( j = 0; j <= ELAB_SERIES[s].i_end; j++ ) {
		h = ag_invers ( g );
		h = agcollect ( h, id[j] );
		conjid[j] = agcollect ( h, g );
	}
	return ( conjid );
}
	
PCELEM is_in_orbit ( PCELEM *cid, int s )
{
	PCELEM x, y;
	PCELEM index, h;
	PCELEM *cid2;
	char val;
	int i, j, equal;
	int e = ELAB_SERIES[s].i_end+1;
	
	y = AIDENTITY;
	index = CALLOCATE ( tlen );
	
	do {
		PUSH_STACK();
/*		for ( i = 0; i < tlen; i++ )
			x[T[i]] = index[i]; */
		
		x = y;
		zero_vector ( x, ANUMGEN );
		for ( i = 0; i < tlen; i++ ) {
			if ( (val=index[i]) != 0 ) {
				h = ag_expo ( T[i], val );
				x = agcollect ( x, h );
			}
		}
		
		cid2 = conj_id ( x, s );
		
		equal = TRUE;
		j = 0;
		while ( equal && (j < e) ) {
			if ( memcmp ( cid[j], cid2[j], e ) != 0 )
				equal = FALSE;
			j++;
		}
		if ( equal ) {
			if ( y != x )
				copy_vector ( x, y, ANUMGEN );
			POP_STACK();
			return ( y );
		}
		POP_STACK();
	} while ( inc_ag ( index, tlen, tps ) );
	return ( NULL );
}

/* void ag_centre1( AGGRPDESC *ag_group )
{
	AGGRPDESC *old_ag_group;
	PCELEM gi, x;
	PCELEM *cid;
	int i;

	old_ag_group = set_ag_group ( ag_group );

	S = ARRAY ( ANUMGEN, PCELEM );
	T = ARRAY ( ANUMGEN, int );
	tps = ARRAY ( ANUMGEN, int );
	
	id = ARRAY ( ANUMGEN, PCELEM );
	
	for ( i = 0; i < ANUMGEN; i++ ) {
		id[i] = AIDENTITY;
		id[i][i] = 1;
	}
	
	for ( i = ANUMGEN; i--; ) {
		gi = ANOM[i];
		cid = conj_id ( gi );
		
		if ( (x = is_in_orbit ( cid )) != NULL )
			S[slen++] = agcollect ( gi, ag_invers ( x ) );
		else {
			tps[tlen] = POWERS[i];
			T[tlen++] = i;
		}
	}
			
	set_ag_group ( old_ag_group );	
} */

void ag_centre ( AGGRPDESC *ag_group )
{
	AGGRPDESC *old_ag_group;
	PCELEM gi, x;
	PCELEM *cid;
	PCELEM **stab;
	PCELEM **orbgen;
	int **lind;
	int *stablen;
	int *orbgenlen;
	int i, j, s, maxel;

	old_ag_group = set_ag_group ( ag_group );
	
	PUSH_STACK();
	pag_w = ARRAY ( ANUMGEN, int );
	marked = ARRAY ( ANUMGEN, int );
	
	id = ARRAY ( ANUMGEN, PCELEM );
	
	for ( i = 0; i < ANUMGEN; i++ ) {
		id[i] = AIDENTITY;
		id[i][i] = 1;
	}
	
	stab = ARRAY ( ELAB_LENGTH + 1, PCELEM* );
	orbgen = ARRAY ( ELAB_LENGTH + 1, PCELEM* );
	stablen = ARRAY ( ELAB_LENGTH + 1, int );
	lind = ARRAY ( ELAB_LENGTH + 1, int* );
	orbgenlen = ARRAY ( ELAB_LENGTH + 1, int );
	
	/* case s= 1 */
	stab[1] = ARRAY ( ELAB_SERIES[1].i_dim, PCELEM );
	orbgen[1] = NULL;
	for ( i = 0; i < ELAB_SERIES[1].i_dim; i++ ) {
		stab[1][i] = AIDENTITY;
		copy_vector ( ANOM[i], stab[1][i], bperelem );
	}
	stablen[1] = ELAB_SERIES[1].i_dim;
	orbgenlen[1] = 0;
		
	for ( s = 2; s <= ELAB_LENGTH; s++ ) {
		maxel = stablen[s-1] + ELAB_SERIES[s].i_dim;
		stab[s] = ARRAY ( maxel, PCELEM );
		orbgen[s] = ARRAY ( maxel, PCELEM );
		lind[s] = ARRAY ( maxel, int );
		words = stab[s];
		tps = lind[s];
		T = orbgen[s];
		nwords = 0;
		tlen = 0;	
		
		/* start with generators of N */
		for ( i = ELAB_SERIES[s].i_start; i <= ELAB_SERIES[s].i_end; i++ ) {
			gi = ANOM[i];
			cid = conj_id ( gi, s );
			
			if ( (x = is_in_orbit ( cid, s )) != NULL )
				merge_cgs ( agcollect ( gi, ag_invers ( x ) ) );
			else {
				tps[tlen] = POWERS[i];
				T[tlen++] = ANOM[i];
			}
		}
			
		/* continue with Z(G/N) */
		for ( i = 0; i < stablen[s-1]; i++ ) {
			gi = stab[s-1][i];
			cid = conj_id ( gi, s );
			
			if ( (x = is_in_orbit ( cid, s )) != NULL )
				merge_cgs ( agcollect ( gi, ag_invers ( x ) ) );
			else {
				for ( j = 0; j < ANUMGEN; j++ )
					if ( gi[j] != 0 ) break;
				tps[tlen] = POWERS[j];
				T[tlen++] = gi;
			}
		}
		stablen[s] = nwords;
		orbgenlen[s] = tlen;
			
	}
	use_permanent_stack();
	Stab = ARRAY ( ELAB_LENGTH + 1, PCELEM* );
	Orbgen = ARRAY ( ELAB_LENGTH + 1, PCELEM* );
	Stablen = ARRAY ( ELAB_LENGTH + 1, int );
	Orbgenlen = ARRAY ( ELAB_LENGTH + 1, int );
	Lind = ARRAY ( ELAB_LENGTH + 1, int* );
	memcpy ( Stablen, stablen, (ELAB_LENGTH + 1) * sizeof ( int ) );
	memcpy ( Orbgenlen, orbgenlen, (ELAB_LENGTH + 1) * sizeof ( int ) );
	
	for ( s = 1; s <= ELAB_LENGTH; s++ ) {
		Stab[s] = ARRAY ( stablen[s], PCELEM );
		Orbgen[s] = ARRAY ( orbgenlen[s], PCELEM );
		Lind[s] = ARRAY ( orbgenlen[s], int );
		for ( i = 0; i < stablen[s]; i++ ) {
			Stab[s][i] = AIDENTITY;
			copy_vector ( stab[s][i], Stab[s][i], ANUMGEN );
		}
		for ( i = 0; i < orbgenlen[s]; i++ ) {
			memcpy ( Lind[s], lind[s], orbgenlen[s] * sizeof ( int ) );
			Orbgen[s][i] = AIDENTITY;
			copy_vector ( orbgen[s][i], Orbgen[s][i], ANUMGEN );
		}
	}
	use_temporary_stack();
	POP_STACK();
	set_ag_group ( old_ag_group );	
}

VEC *conj_list ( PCELEM *rho, int s, int *l )
{
	int i, j, st, e, d, n;
	PCELEM g, h;
	VEC *cmods, index;
	char val;
	
	e = ELAB_SERIES[s].i_end + 1;
	st = ELAB_SERIES[s].i_start;
	d = ELAB_SERIES[s].i_dim;
	
	n = 1;
	for ( i = 0; i < Orbgenlen[s]; i++ )
		n *= Lind[s][i];
	*l = n;
	cmods = ARRAY ( n, VEC );
	for ( i = 0; i < n; i++ ) 
		cmods[i] = ALLOCATE ( d*e );

	PUSH_STACK();
	index = CALLOCATE ( Orbgenlen[s] );
	
	n = 0;
	do {
		PUSH_STACK();

		g = AIDENTITY;
		for ( i = 0; i < Orbgenlen[s]; i++ ) {
			if ( (val=index[i]) != 0 ) {
				h = ag_expo ( Orbgen[s][i], val );
				g = agcollect ( g, h );
			}
		}
		for ( j = 0; j < e; j++ ) {
			h = ag_invers ( g );
			h = agcollect ( h, rho[j] );
			copy_vector ( agcollect ( h, g ) + st, cmods[n]+j*d, d );
			
		}
		n++;
		POP_STACK();
	} while ( inc_ag ( index, Orbgenlen[s], Lind[s] ) );

	POP_STACK();

	return ( cmods );
}

