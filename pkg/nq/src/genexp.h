/****************************************************************************
**
**    genexp.h                        PC                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
**
**
**    A generator is a positive integer. The inverse of a generator is
**    denoted by its negative.
**
**    The exponent of a generator is a short integer. The exponent of
**    a generator or its inverses is always positive. The exponent
**    vector is the sequence of exponents corresponding to a normed
**    word. The entries in an exponent vector can be negative.
**
**    A word is a generator exponent string terminated by 0.
*/
#ifndef GENEXP_H
#define GENEXP_H

#include "config.h"

typedef short   gen;

/*
**    GNU cc has the data type long long.  We can switch it on by
**    defining the macro HAVE_LONG_LONG_INT in the Makefile.
*/
#ifdef HAVE_LONG_LONG_INT
typedef long long       expo;
#define EXP_FORMAT	"%lld"
#else
typedef long            expo;
#define EXP_FORMAT	"%ld"
#endif

typedef expo             *expvec;

#define EOW     ((gen)0)

struct  gpower {
	gen     g;      /* the generator */
	expo    e;      /* its exponent  */
};
typedef struct gpower   gpower;

typedef gpower  *word;

#endif
