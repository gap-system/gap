/*****************************************************************************
**
**    tails.c                         NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/


#include "nq.h"

char *Warning3 = "Warning : This is not a tail in %s( %d, %d, %d )\n";
char *Warning2 = "Warning : This is not a tail in %s( %d, %d )\n";

int	tail_cba( c, b, a, ev )
gen	c, b, a;
expvec	*ev;

{	int	i, l = 0;
	expvec	ev1, ev2;

	/* (c b) a */
	ev1 = ExpVecWord( Generators[c] );
	Collect( ev1, Generators[b], (exp)1 );
	Collect( ev1, Generators[a], (exp)1 );

	/* c (b a) = c a b^a */
	ev2 = ExpVecWord( Generators[c] );
	Collect( ev2, Generators[a], (exp)1 );
	Collect( ev2, Conjugate[b][a], (exp)1 );

	for( i = 1; i <= NrPcGens; i++ ) {
          if( ev1[i] != ev2[i] ) printf( Warning3, "tail_cba", c, b, a );
          ev1[i] = (exp)0;
        }

        for( i = NrPcGens+1; i <= NrPcGens+NrCenGens; i++ ) {
            ev1[i] -= ev2[i];
            if( ev1[i] != (exp)0 && Exponent[i] != (exp)0 ) {
                ev1[i] %= Exponent[i];
                if( ev1[i] < (exp)0 ) ev1[i] += Exponent[i];
            }

	    if( ev1[i] != (exp)0 ) l++;
        }

	Free( ev2 );
	*ev = ev1;
	return l;
}

int	tail_cbn( c, b, ev )
gen	c, b;
expvec	*ev;

{	int	i, l = 0;
	expvec	ev1, ev2;

        /* (c b) b^(n-1) */
	ev1 = ExpVecWord( Generators[c] );
	Collect( ev1, Generators[b], Exponent[b] );

	/* c b^n */
	ev2 = ExpVecWord( Generators[c] );
	if( Power[b] != (word)0 ) Collect( ev2, Power[b], (exp)1 );

	for( i = 1; i <= NrPcGens; i++ ) {
            if( ev1[i] != ev2[i] ) printf( Warning2, "tail_cbn", c, b );
            ev1[i] = (exp)0;
        }

	for( i = NrPcGens+1; i <= NrPcGens+NrCenGens; i++ ) {
	    ev1[i] -= ev2[i];
            if( Exponent[i] != (exp)0 ) {
              ev1[i] %= Exponent[i];
              if( ev1[i] < (exp)0 ) ev1[i] += Exponent[i];
            }

	    if( ev1[i] != 0 ) l++;
        }

        Free( ev2 );

	*ev = ev1;
	return l;
}

int	tail_cnb( c, b, ev )
gen	c, b;
expvec	*ev;

{	int	i, l = 0;
	expvec	ev1, ev2;

        /* b (c^b)^n */
	ev1 = ExpVecWord( Generators[b] );
	Collect( ev1, Conjugate[c][b], Exponent[c] );

	/* c^n b */
	ev2 = ExpVecWord( Power[c] );
	Collect( ev2, Generators[b], (exp)1 );

	for( i = 1; i <= NrPcGens; i++ ) {
            if( ev1[i] != ev2[i] ) printf( Warning2, "tail_cnb", c, b );
            ev1[i] = (exp)0;
        }

	for( i = NrPcGens+1; i <= NrPcGens+NrCenGens; i++ ) {
	    ev1[i] -= ev2[i];
            if( ev1[i] != (exp)0 && Exponent[i] != (exp)0 ) {
                ev1[i] %= Exponent[i];
                if( ev1[i] < (exp)0 ) ev1[i] += Exponent[i];
            }

	    if( ev1[i] != 0 ) l++;
        }

        Free( ev2 );

	*ev = ev1;
	return l;
}

int	tail_cbb( c, b, ev )
gen	c, b;
expvec	*ev;

{	int	i, l = 0;
	expvec	ev1;

	/* (c b^-1) b */
	ev1 = ExpVecWord( Generators[c] );
	Collect( ev1, Generators[ b], (exp)1 );
	Collect( ev1, Generators[-b], (exp)1 );
	ev1[ c ] -= 1;

	for( i = 1; i <= NrPcGens; i++ ) {
            if( ev1[i] != (exp)0 ) printf( Warning2, "tail_cnb", c, b );
        }

	for( i = NrPcGens+1; i <= NrPcGens+NrCenGens; i++ ) {
            ev1[i] = -ev1[i];
            if( ev1[i] != (exp)0 && Exponent[i] != (exp)0 ) {
              ev1[i] %= Exponent[i];
              if( ev1[i] < (exp)0 ) ev1[i] += Exponent[i];
            }

	    if( ev1[i] != 0 ) l++;
        }

	*ev = ev1;
	return l;
}

int	tail_ccb( c, b, ev )
gen	c, b;
expvec	*ev;

{	int	i, l = 0;
	expvec	ev1;

	/* c^-1 (c b) = c^-1 b c^b */
	ev1 = ExpVecWord( Generators[c] );
	Collect( ev1, Generators[b], (exp)1 );
	Collect( ev1, Conjugate[-c][b], (exp)1 );
	ev1[abs(b)] -= sgn(b);

	for( i = 1; i <= NrPcGens; i++ ) {
            if( ev1[i] != (exp)0 ) printf( Warning2, "tail_cnb", c, b );
        }

	for( i = NrPcGens+1; i <= NrPcGens+NrCenGens; i++ ) {
            ev1[i] = -ev1[i];
            if( Exponent[i] != (exp)0 ) {
              ev1[i] %= Exponent[i];
              if( ev1[i] < (exp)0 ) ev1[i] += Exponent[i];
            }

	    if( ev1[i] != 0 ) l++;
        }

	*ev = ev1;
	return l;
}

Tail( n, m )
gen	n, m;

{	long	lw, lt;
	expvec	t;
	word	w;

	if( n > 0 )
	     if( m > 0 ) lt = tail_cba( n,Definition[m].h,Definition[m].g,&t);
	     else	 lt = tail_cbb( n, m, &t );
	else lt = tail_ccb(  n,  m, &t );

	lw = WordLength( Conjugate[n][m] );
	w  = (word)Allocate( (lt+lw+1)*sizeof(gpower) );

	WordCopy( Conjugate[n][m], w );
	WordCopyExpVec( t, w+lw );
	free( t );
	if( Conjugate[n][m] != Generators[n] ) free( Conjugate[n][m] );
	Conjugate[n][m] = w;
}

/*
**    The next nilpotency class to be calculated is Class+1. Therefore
**    commutators of weight Class+1, which are currently trivial, will
**    get tails.
*/
Tails() {

        int	*Dim = Dimension;
	long	b, c, i, j, time;
	long	m, M, n, N;

	if( Verbose ) time = RunTime();

        /* 
        ** Precompute exponents of the new generators which are defined
        ** as a commutator [h,g] with wt(h)=Class.  There is no conclusive
        ** evidence that is woth the effort.  One probably also has to use
        ** those power relations that have a non-trivial right hand side. 
        */
        if( 0 ) {
          int     l;
          gen     i, g, h, t;
          expvec  ev;

          for( t = NrPcGens+1; t <= NrPcGens+NrCenGens; t++ ) {
            h = Definition[t].h;
            g = Definition[t].g;
            if( h < 0 || Wt(h) < Class ) continue;
            if( g != (gen)0 && Exponent[h] != (exp)0 ) {
                l = tail_cnb( h, g, &ev );
                /* printf( "t: %d, ", t );
                   for( i = 1; i <= NrPcGens+NrCenGens; i++ )
                     if( ev[i] != (exp)0 ) printf( " %d^%Ld", i, ev[i] );
                   printf( "\n" );*/
                if( l == 1 ) {
                  if( ev[t] == (exp)0 )
                    printf( "Error, exponent zero\n" );
                  if( Verbose )
                    printf( "#    Setting exponent %Ld for %d\n", ev[t], t );
                  Exponent[t] = ev[t];
                  addRow( ev );
                }
            }
            if( g != (gen)0 && Exponent[g] != (exp)0 ) {
                l = tail_cbn( h, g, &ev );
                /* printf( "t: %d, ", t );
                for( i = 1; i <= NrPcGens+NrCenGens; i++ )
                  if( ev[i] != (exp)0 ) printf( " %d^%Ld", i, ev[i] );
                  printf( "\n" );*/
                if( l == 1 ) {
                  if( ev[t] == (exp)0 )
                    printf( "Error, exponent zero\n" );
                  if( Verbose )
                    printf( "#    Setting exponent %Ld for %d\n", ev[t], t );
                  Exponent[t] = ev[t];
                  addRow( ev );
                }
            }
          }
        }

	N  = NrPcGens;
	for( c = Class; c >= 1; c-- ) {
	    n  = N;
	    M  = 1;
	    for( b = 1; b <= c-b+1; b++ ) {
		/* tails for comutators [ <c-b+1>, <b> ] */
		for( j = Dim[c-b+1]; j >= 1; j-- ) {
		    m = M;
		    for( i = 1; n > m && i <= Dim[b]; i++ ) {
			if( b != 1 )
			    Tail(  n,  m );    
			if( Exponent[m] == (exp)0 )
			    Tail(  n, -m );
			if( Exponent[n] == (exp)0 )
			    Tail( -n,  m );
			if( Exponent[m]+Exponent[n] == (exp)0 )
			    Tail( -n, -m );
			m++;
		    }
		    n--;
		}
		M += Dim[b];
	    }
	    N  -= Dim[c];
	}


	if( Verbose )
	    printf("#    Computed tails (%d msec).\n",RunTime()-time);
}
