/*****************************************************************************
**
**    combicol.c                      NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include "config.h"

#include "mem.h"
#include "pc.h"
#include "pcarith.h"
#include "macro.h"
#include "collect.h"
#include "time.h"
#include "system.h"

static int Error(const char *str, gen g) {
	printf("Error in CombiCollect() while treating generator %d:\n",
	       (int)g);
	printf("      %s\n", str);

	CombiCollectionTime += RunTime();

	/*      exit( 7 );*/

	return 7;
}

/*
**    Combinatorial Collection from the left uses the same stacks as the plain
**    from the left collector.
*/

extern word     WordStack[];
extern expo     WordExpStack[];
extern word     GenStack[];
extern expo     GenExpStack[];
extern word     *Generators;

int             Sp;

#define STACKHEIGHT     (1 << 16)

#define CheckOverflow( n ) \
        if( (((n) << 1) >> 1) != n ) Error( "Possible integer overflow", n )

static void AddWord(expvec lhs, word w, expo we);


static void ReduceExponent(expvec ev, gen g) {

	if (ev[ g ] >= Exponent[ g ]) {

		if (Power[g] != (word)0) AddWord(ev, Power[g], ev[ g ] / Exponent[ g ]);

		ev[ g ] %= Exponent[ g ];
	}
}

static void StackReduceExponent(expvec ev, gen g) {

	gen    h;

	if (ev[ g ] >= Exponent[ g ]) {

		if (Power[ g ] != (word)0) {

			/* Need to put part of the exponent vector on the stack. */
			for (h = Commute[ g ]; h > g; h--)
				if (ev[ h ] != (expo)0) {
					if (++Sp == STACKHEIGHT) {
						Error("Out of stack space", g);
						return;
					}

					if (ev[ h ] > (expo)0) {
						WordStack[ Sp ]    = Generators[  h ];
						WordExpStack[ Sp ] = 1;
						GenExpStack[ Sp ] = ev[ h ];
					} else {
						WordStack[ Sp ]    = Generators[ -h ];
						WordExpStack[ Sp ] = 1;
						GenExpStack[ Sp ] = -ev[ h ];
					}
					ev[ h ] = (expo)0;
					GenStack[ Sp ]    = WordStack[ Sp ];
					GenStack[ Sp ]->e; /* FIXME: statement with no effect */
				}

			AddWord(ev, Power[ g ], ev[ g ] / Exponent[ g ]);
		}

		ev[ g ] %= Exponent[ g ];
	}
}

static void AddWord(expvec lhs, word w, expo we) {

	gen    g;

	for (; w->g != EOW && w->g <= NrPcGensList[Class + 1]; w++) {

		if (w->g > (gen)0) { g =  w->g; lhs[ g ] += we * w->e; }
		else                { g = -w->g; lhs[ g ] -= we * w->e; }

		CheckOverflow(lhs[ g ]);
		if (Exponent[ g ] != (expo)0) ReduceExponent(lhs, g);

	}
}

int   CombiCollect(expvec lhs, word rhs, expo e) {

	word  *ws  = WordStack;
	expo  *wes = WordExpStack;
	word  *gs  = GenStack;
	expo  *ges = GenExpStack;
	word  **C  = Conjugate;
	word   *P  = Power;

	word   w;
	gen    ag,  g,  h,  hh;

	CombiCollectionTime -= RunTime();

	Sp = 0;

	ws[ Sp ] = rhs;
	gs[ Sp ] = rhs;
	wes[ Sp ] = e;
	ges[ Sp ] = rhs->e;

	while (Sp >= 0)
		if ((g = gs[ Sp ]->g) != EOW && g <= NrPcGensList[Class + 1]) {

			ag = abs(g);
			if (g < 0 && Exponent[-g] != (expo)0)
				return Error("Inverse of a generator with power relation", ag);

			if (Commute[ag] == ag) {
				/* Take the exponent of the first generator from the stack not from
				   the word.  Both are identical if the word is a conjugate.  They
				   differ if a generator-exponent pair was pushed onto the stack.
				   In that case w->e is 1 and ges[ Sp ] is the exponent. */
				w = gs[ Sp ];
				if (w->g > (gen)0) { g =  w->g; lhs[ g ] += ges[ Sp ]; }
				else                { g = -w->g; lhs[ g ] -= ges[ Sp ]; }

				CheckOverflow(lhs[ g ]);
				if (Exponent[ g ] != (expo)0) ReduceExponent(lhs, g);

				for (w++; w->g != EOW && w->g <= NrPcGensList[Class + 1]; w++) {

					if (w->g > (gen)0) { g =  w->g; lhs[ g ] += w->e; }
					else                { g = -w->g; lhs[ g ] -= w->e; }

					CheckOverflow(lhs[ g ]);
					if (Exponent[ g ] != (expo)0) ReduceExponent(lhs, g);
				}
				gs[ Sp ] = w;

				continue;
			}

			else if (3 * Wt(ag) > Class + 1) {
				/* Move the generator g to its correct position in the exponent
				   vector without stacking conjugates.  Because of the class
				   condition we can add the necessary *commutators* into the
				   exponent vector. */
				for (h = Commute[ ag ]; h > ag; h--)
					if (lhs[ h ] != (expo)0) {
						if (lhs[ h ] > (expo)0)
							AddWord(lhs, C[  h ][ g ] + 1,  lhs[ h ] * ges[ Sp ]);
						else
							AddWord(lhs, C[ -h ][ g ] + 1, -lhs[ h ] * ges[ Sp ]);
					}

				lhs[ ag ] += sgn(g) * ges[ Sp ];
				CheckOverflow(lhs[ ag ]);

				gs[ Sp ]++;
				ges[ Sp ] = gs[ Sp ]->e;

				if (Exponent[ ag ] != (expo)0) StackReduceExponent(lhs, ag);

				continue;
			}

			else {

				lhs[ ag ] += sgn(g);

				if (--ges[ Sp ] == (expo)0) {
					/* The power of the generator g will have been moved
					   completely to its correct position after this
					   collection step. Therefore advance the generator
					   pointer. */
					gs[ Sp ]++;
					ges[ Sp ] = gs[ Sp ]->e;
				}

				/* Add in commutators until Wt([h,g,h]) <= Class+1 */
				for (h = Commute[ ag ]; h > Commute2[ ag ]; h--)
					if (lhs[ h ] != (expo)0) {
						if (lhs[ h ] > (expo)0)
							AddWord(lhs, C[  h ][ g ] + 1,  lhs[ h ]);
						else
							AddWord(lhs, C[ -h ][ g ] + 1, -lhs[ h ]);
					}

				/* If we still have to move across generators, then we have to put
				   generators onto the stack.  Find the point from where collection
				   has to happen.
				*/
				while (h > ag) {
					if (lhs[ h ] != (expo)0 &&
					        C[h][ag] != (word)0 &&
					        (C[h][ag] + 1)->g != EOW) break;
					h--;
				}

				/* Now put generator exponent pairs on the stack. */
				if (h > ag || (Exponent[ ag ] > (expo)0 &&
				               lhs[ ag ] >= Exponent[ ag ] &&
				               Power[ ag ] != (word)0)) {

					for (hh = Commute[ag]; hh > h; hh--)
						if (lhs[ hh ] != (expo)0) {
							if (++Sp == STACKHEIGHT)
								return Error("Out of stack space", ag);
							if (lhs[ hh ] > (expo)0) {
								gs[ Sp ]  = ws[ Sp ] = Generators[ hh ];
								wes[ Sp ] = 1;
								ges[ Sp ] = lhs[ hh ];
							} else {
								gs[ Sp ]  = ws[ Sp ] = Generators[ -hh ];
								wes[ Sp ] = 1;
								ges[ Sp ] = -lhs[ hh ];
							}
							lhs[hh] = (expo)0;
						}
				}

				/* Now move the generator g to its correct position
				   in the exponent vector lhs. */
				for (; h > ag; h--)
					if (lhs[h] != (expo)0) {
						if (++Sp == STACKHEIGHT)
							return Error("Out of stack space", ag);
						if (lhs[ h ] > (expo)0) {
							gs[ Sp ]  = ws[ Sp ] = C[ h ][ g ];
							wes[ Sp ] = lhs[h];
							lhs[ h ] = (expo)0;
							ges[ Sp ] = gs[ Sp ]->e;
						} else {
							gs[ Sp ]  = ws[ Sp ] = C[ -h ][ g ];
							wes[ Sp ] = -lhs[h];
							lhs[ h ] = (expo)0;
							ges[ Sp ] = gs[ Sp ]->e;
						}
					}

			}

			CheckOverflow(lhs[ag]);

			if (Exponent[ag] != (expo)0)
				while (lhs[ag] >= Exponent[ag]) {
					if ((rhs = P[ ag ]) != (word)0) {
						if (++Sp == STACKHEIGHT)
							return Error("Out of stack space", ag);
						gs[ Sp ] = ws[ Sp ] = rhs;
						wes[ Sp ] = (expo)1;
						ges[ Sp ] = gs[ Sp ]->e;
					}
					lhs[ ag ] -= Exponent[ ag ];
				}
		} else {
			/* the top word on the stack has been examined completely,
			   now check if its exponent is zero. */
			if (--wes[ Sp ] == (expo)0) {
				/* All powers of this word have been treated, so
				   we have to move down the stack. */
				Sp--;
			} else {
				gs[ Sp ] = ws[ Sp ];
				ges[ Sp ] = gs[ Sp ]->e;
			}
		}

	CombiCollectionTime += RunTime();

	return 0;
}


