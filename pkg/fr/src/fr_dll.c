/****************************************************************************
 *
 * fr_dll.c                                                 Laurent Bartholdi
 *
 *   @(#)$id: fr_dll.c,v 1.18 2010/10/26 05:19:40 gap exp $
 *
 * Copyright (c) 2009, 2010, Laurent Bartholdi
 *
 ****************************************************************************
 *
 * Call cpoly to compute the roots of a univariate polynomial
 * Call gsl_solver to normalize barycenter of points on S^2
 * Call gsl_solver to construct a rational map from its critical values
 *
 ****************************************************************************/

#undef DEBUG_COMPLEX_ROOTS

#include "fr_dll.h"
#include <complex.h>

#ifdef MALLOC_HACK
#include <malloc.h>
#endif

/****************************************************************************
 * capture code that exits uncleanly rather than returning error message
 ****************************************************************************/
#ifdef CAPTURE_EXITS
static jmp_buf e_t_go_home;

static void baby_please_dont_go (void) {
  longjmp(e_t_go_home, 1);
}

/* in code:

   atexit (baby_please_dont_go);
   if (setjmp(e_t_go_home))
     return __result;

   __result = fail;

   __result = call_bad_function();
   exit(0);
*/

#endif

/****************************************************************************
 * complex_roots of polynomial (as increasing-degree list of pairs (real,imag)
 ****************************************************************************/
#define cpoly cpoly_Cdouble
typedef double xreal;
typedef _Complex double xcomplex;
static const struct { Cdouble ZERO, INFIN; int MIN_EXP, MAX_EXP; }
  xdata = { 0.0, DBL_MAX, DBL_MIN_EXP, DBL_MAX_EXP };
static xreal xnorm(xcomplex z) { return __real__(z)*__real(z)+__imag__(z)*__imag__(z);}
static xreal xabs(xcomplex z) { return sqrt(xnorm(z)); }
static xreal xroot(xreal x, int n) { return pow(x,1.0/n); }
static int xlogb(xcomplex z) { return ilogb(xnorm(z)) / 2; }
#define xbits(z) DBL_MANT_DIG
#define xeta(z) DBL_EPSILON
typedef enum { false = 0, true = 1 } bool;
static void xscalbln (xcomplex *z, int e) {
  __real__(*z) = scalbln(__real__(*z), e);
  __imag__(*z) = scalbln(__imag__(*z), e);
}
#include "cpoly.C"

static Obj COMPLEX_ROOTS (Obj self, Obj coeffs)
{
  Obj result;
  Int i, numroots, degree = LEN_PLIST(coeffs)-1;
  xcomplex op[degree+1], zero[degree];

  if (degree < 1)
    return Fail;

  for (i = 0; i <= degree; i++) {
    __real__(op)[degree-i] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(coeffs,i+1),1));
    __imag__(op)[degree-i] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(coeffs,i+1),2));
    if (isnan(__real__(op)[degree-i]) || isnan(__imag__(op)[degree-i]))
      return Fail;
  }

#ifdef DEBUG_COMPLEX_ROOTS
  fprintf(stderr,"coeffs");
  for (i = 0; i <= degree; i++)
    fprintf(stderr," %g+I*%g",(double)opr[i],(double)opi[i]);
   /* __asm__ __volatile__ ("int3"); */
  fprintf(stderr,"\n");
#endif

  numroots = cpoly (degree, op, zero);

  if (numroots == -1)
    return Fail;

#ifdef DEBUG_COMPLEX_ROOTS
  fprintf(stderr,"roots");
  for (i = 0; i < numroots; i++)
    fprintf(stderr," %g+I*%g",(double)zeror[i],(double)zeroi[i]);
  fprintf(stderr,"\n");
#endif

  result = ALLOC_PLIST(numroots);
  for (i = 1; i <= numroots; i++) {
    Obj t = ALLOC_PLIST(2);
    set_elm_plist(t,1, NEW_FLOAT(__real__(zero)[i-1]));
    set_elm_plist(t,2, NEW_FLOAT(__imag__(zero)[i-1]));
    set_elm_plist(result,i, t);
  }

  return result;
}

/****************************************************************************
 * complex_roots of polynomial (as increasing-degree list of pairs (real,imag)
 ****************************************************************************/
static Obj REAL_ROOTS (Obj self, Obj coeffs)
{
  Obj result;
  Int i, numroots;
  int degree = LEN_PLIST(coeffs)-1;
  Cdouble opr[degree+1], zeror[degree], zeroi[degree];

  if (degree < 1)
    return Fail;

  for (i = 0; i <= degree; i++) {
    opr[degree-i] = VAL_FLOAT(ELM_PLIST(coeffs,i+1));
    if (isnan(opr[degree-i]))
      return Fail;
  }

  rpoly (opr, &degree, zeror, zeroi);
  numroots = degree;

  if (numroots < 0)
    return Fail;

  result = ALLOC_PLIST(numroots);
  for (i = 1; i <= numroots; i++) {
    if (zeroi[i-1] == 0.0)
      set_elm_plist(result,i, NEW_FLOAT(zeror[i-1]));
    else {
      Obj t = ALLOC_PLIST(2);
      set_elm_plist(t,1, NEW_FLOAT(zeror[i-1]));
      set_elm_plist(t,2, NEW_FLOAT(zeroi[i-1]));
      set_elm_plist(result,i, t);
    }
  }
  return result;
}

/****************************************************************************
 * NFFUNCTION reduces a list according to an IMG relation
 ****************************************************************************/
#define PUSH_LETTER(__v) {				\
    Int v = __v;					\
    Obj w = INTOBJ_INT(v);				\
    if (resulti && v == -INT_INTOBJ(ELM_PLIST(result,resulti)))	\
      resulti--;					\
    else {						\
      resulti++;					\
      if (resulti > allocn) {				\
        allocn *= 2;					\
	GROW_PLIST(result,allocn);			\
      }							\
      SET_ELM_PLIST(result,resulti,w);			\
    }							\
  }

#define MATCH_POS(p,__v) {					\
    Int v = __v;						\
    if (v > 0)							\
      p = INT_INTOBJ(ELM_PLIST(posind,v));			\
    else							\
      p = INT_INTOBJ(ELM_PLIST(negind,-v));			\
  }

static Obj NFFUNCTION(Obj self, Obj rel, Obj dir, Obj word)
{
  /* word is an integer lists. dir is true/false.
     rel is a list of lists: square of positive relator+square of negative
     relator; positions in 1st of letter i; position in 1st of letter -i
   * if dir=true, replace all (>=1/2)-cyclic occurrences of rel in word by the shorter half
   * if dir=false, replace all occurrences of the last generator in word by the corresponding bit of rel
   */

  Obj posind = ELM_PLIST(rel,2), negind = ELM_PLIST(rel,3);
  rel = ELM_PLIST(rel,1);
  Int n = LEN_PLIST(posind), allocn = n, i = 0, resulti = 0, match = 0, matchlen = 0, j;
  Obj result = ALLOC_PLIST(allocn);

  while (i < LEN_PLIST(word)) {
    /* we produced result[1..resulti] as the compressed version of word[1..i].
       additionally, matchlen is maximal such that
       rel[match..match+matchlen-1] = result[resulti-matchlen+1..resulti]
    */
    i++;
    Obj wi = ELM_PLIST(word,i);
    Int vi = INT_INTOBJ(wi);
    if (dir == False) {
      if (vi == n) {
	match = INT_INTOBJ(ELM_PLIST(negind,n));
	for (j = 1; j < n; j++)
	  PUSH_LETTER(INT_INTOBJ(ELM_PLIST(rel,j+match)));
      } else if (vi == -n) {
	match = INT_INTOBJ(ELM_PLIST(posind,n));
	for (j = 1; j < n; j++)
	  PUSH_LETTER(INT_INTOBJ(ELM_PLIST(rel,j+match)));
      } else
	PUSH_LETTER(vi);
    } else {
      if (resulti && vi == -INT_INTOBJ(ELM_PLIST(result,resulti))) {
	/* pop letter, and update match */
	resulti--;
	matchlen--;
	if (matchlen == 0 && resulti) {
	  MATCH_POS(match,INT_INTOBJ(ELM_PLIST(result,resulti)));
	  matchlen = 1;
	  while (resulti > matchlen && ELM_PLIST(result,resulti-matchlen) == ELM_PLIST(rel,match+n-1)) {
	    matchlen++;
	    if (!--match)
	      match = n;
	  }
	} else
	  match = 0;
      } else {
	PUSH_LETTER(vi);
	if (match && wi == ELM_PLIST(rel,match+matchlen)) {
	  matchlen++;
	  if (matchlen >= (n+1+(match < 2*n))/2) { /* more than half, or exactly half and negatives */
	    resulti -= matchlen;
	    for (j = n-1; j >= matchlen; j--)
	      PUSH_LETTER(-INT_INTOBJ(ELM_PLIST(rel,j+match)));
	    matchlen = n-matchlen;
	    match = 4*n+1 - (match+n-1);
	  }
	} else {
	  matchlen = 1;
	  MATCH_POS(match,vi);
	}
      }
    }
  }
  SET_LEN_PLIST(result,resulti);
  return result;
}

/****************************************************************************
 * FIND_BARYCENTER finds a mobius transformation that centers points
 ****************************************************************************/
typedef struct {
  int n;
  Double (*points)[3];
} bparams;

#ifdef MALLOC_HACK
void *old_free_hook, *old_malloc_hook;

static void *
my_malloc_hook (size_t size, const void *caller)
{
  fprintf(stderr,"allocating %d\n", size);

  return *NewBag(T_DATOBJ, size + sizeof(Int));
}

static void
my_free_hook (void *ptr, const void *caller)
{
  fprintf(stderr,"freeing pointer %p\n", ptr);
}
#endif

#define bpoints (((bparams *) param)->points)

static int barycenter (const gsl_vector *x, void *param, gsl_vector *f)
{
  /* x is a "shifting" parameter; it is a vector in R^3, and
     describes the M\"obius transformation with north-south dynamics.
     more precisely, let t=|x|. in R^3, the transformation sends
     P to (2(1-t)P+(2-t+(v*P))v)/(1+(1-t)^2+(2-t)(v*P)).
     In particular, for t=0 it sends everything to v, and for t=1 it fixes P.

     The M\"obius transformation is 
  */
  int i, j;
  const int n = ((bparams *) param)->n;
  long double v[3];

  for (i = 0; i < 3; i++) v[i] = gsl_vector_get (x, i);
  long double t = sqrtl(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
  long double sum[3] = { 0.0, 0.0, 0.0 };

  for (j = 0; j < n; j++) {
    long double x[3], z = 0.0;

    for (i = 0; i < 3; i++) /* z = v*P */
      z += bpoints[j][i] * v[i];

    long double d = 1.0 + (1.0-t)*(1.0-t) + (2.0 - t)*z;
    for (i = 0; i < 3; i++)
      x[i] = (2.0*(1.0-t)*bpoints[j][i] + (2.0-t+z)*v[i]) / d;

    for (i = 0; i < 3; i++) sum[i] += x[i];
  }

  for (i = 0; i < 3; i++) gsl_vector_set (f, i, sum[i] / n);

  return GSL_SUCCESS;
}

/* given a set of points on S^2 \subset R^3, there is, up to rotations
   of the sphere, a unique M\"obius transformation that centers these
   points, i.e. such that their barycentre is (0,0,0). This follows
   from GIT, as Burt Totaro told me:

   Dear Laurent,

   Geometric invariant theory (GIT) gives a complete answer to your
   question. More concretely, the answer follows from the Kempf-Ness
   theorem in GIT, as I think Frances Kirwan first observed.

   Namely, given a sequence of N points p_1,...,p_N on the 2-sphere,
   there is a Mobius transformation that moves these points
   to have center of mass at the origin of R^3 if and only if either
   (1) fewer than N/2 of the points are equal to any given point
   in the 2-sphere; or
   (2) N is even, N/2 of the points are equal to one point
   in the 2-sphere, and the other N/2 points are equal
   to a different point in the 2-sphere.
   (In GIT terminology, condition (1) describes which
   N-tuples of points in S^2 = CP^1 are "stable",
   and (2) describes which N-tuples are "polystable"
   but not stable.) In particular, if p_1,...,p_N are all distinct
   and N is at least 2, then they can be centered
   by some Mobius transformation.
   
   This result was the beginning of many developments in GIT,
   such as Donaldson's notion of "balanced" metrics.
   Here is a good survey (where Theorem 4.13 is the statement
   above).

   R. P. Thomas. Notes on GIT and symplectic reduction for bundles
   and varieties. arXiv:math/0512411

   Burt Totaro
*/

static Obj FIND_BARYCENTER (Obj self, Obj gap_points, Obj gap_init, Obj gap_iter, Obj gap_tol)
{
#ifdef MALLOC_HACK
  old_malloc_hook = __malloc_hook;
  old_free_hook = __free_hook;
  __malloc_hook = my_malloc_hook;
  __free_hook = my_free_hook;
#endif

  UInt i, j, n = LEN_PLIST(gap_points);

  Double __points[n][3];
  bparams bparam = { n, __points };
  
  for (i = 0; i < n; i++)
    for (j = 0; j < 3; j++)
      bparam.points[i][j] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(gap_points,i+1),j+1));

  const gsl_multiroot_fsolver_type *T;
  gsl_multiroot_fsolver *s;

  int status;
  size_t iter = 0, max_iter = INT_INTOBJ(gap_iter);
  double precision = VAL_FLOAT(gap_tol);

  gsl_multiroot_function f = {&barycenter, 3, &bparam};
  gsl_vector *x = gsl_vector_alloc (3);

  for (i = 0; i < 3; i++) gsl_vector_set (x, i, VAL_FLOAT(ELM_PLIST(gap_init,i+1)));

  T = gsl_multiroot_fsolver_hybrids;
  s = gsl_multiroot_fsolver_alloc (T, 3);
  gsl_multiroot_fsolver_set (s, &f, x);

  do {
    iter++;
    status = gsl_multiroot_fsolver_iterate (s);

    if (status)   /* check if solver is stuck */
      break;

    status = gsl_multiroot_test_residual (s->f, precision);
  }
  while (status == GSL_CONTINUE && iter < max_iter);

  Obj result = ALLOC_PLIST(2);
  Obj list = ALLOC_PLIST(3); set_elm_plist(result, 1, list);
  for (i = 0; i < 3; i++)
    set_elm_plist(list, i+1, NEW_FLOAT(gsl_vector_get (s->x, i)));
  list = ALLOC_PLIST(3); set_elm_plist(result, 2, list);
  for (i = 0; i < 3; i++)
    set_elm_plist(list, i+1, NEW_FLOAT(gsl_vector_get (s->f, i)));

  gsl_multiroot_fsolver_free (s);
  gsl_vector_free (x);

  if (status != 0) {
    const char *s = gsl_strerror (status);
    C_NEW_STRING(result, strlen(s), s);
  }

#ifdef MALLOC_HACK
  __malloc_hook = old_malloc_hook;
  __free_hook = old_free_hook;
#endif
  return result;
}

/****************************************************************************
 * FIND_RATIONALFUNCTION solves the Hurwitz problem
 ****************************************************************************/
static Obj FIND_RATIONALFUNCTION (Obj self, Obj gap_degrees, Obj gap_values, Obj gap_c, Obj gap_num, Obj gap_den, Obj params)
{
  size_t degree = 2, s;

  s = LEN_PLIST(gap_degrees);

  if (s != LEN_PLIST(gap_values)+3 || s != LEN_PLIST(gap_c)+3)
    return Fail;

  size_t d[s], i;
  gsl_complex c[s-3], v[s];

  for (i = 0; i < s; i++) {
    d[i] = INT_INTOBJ(ELM_PLIST(gap_degrees,i+1));
    degree += d[i]-1;
    if (i < s-3) {
      v[i] = VAL_GSL_COMPLEX(ELM_PLIST(gap_values,i+1));
      c[i] = VAL_GSL_COMPLEX(ELM_PLIST(gap_c,i+1));
    } else if (i == s-3)
      GSL_SET_COMPLEX(v+i, 1.0, 0.0);
    else if (i == s-2)
      GSL_SET_COMPLEX(v+i, 0.0, 0.0);
    else if (i == s-1)
      GSL_SET_COMPLEX(v+i, HUGE_VAL, HUGE_VAL);
  }
  degree /= 2;

  gsl_complex num_data[degree+1], den_data[degree+1];
  polynomial num = { LEN_PLIST(gap_num)-1, num_data },
    den = { LEN_PLIST(gap_den)-1, den_data };
    
  for (i = 0; i <= num.degree; i++)
    num.data[i] = VAL_GSL_COMPLEX(ELM_PLIST(gap_num,i+1));
  for (i = 0; i <= den.degree; i++)
    den.data[i] = VAL_GSL_COMPLEX(ELM_PLIST(gap_den,i+1));
    
  int status = solve_hurwitz (degree, s, d, v, c, &num, &den,
    INT_INTOBJ(ELM_PLIST(params,1)), VAL_FLOAT(ELM_PLIST(params,2)), VAL_FLOAT(ELM_PLIST(params,3)));

  if (status != GSL_SUCCESS)
    return INTOBJ_INT(status);

  for (i = 0; i < s-3; i++)
    set_elm_plist(gap_c,i+1, NEW_COMPLEX_GSL(c+i));

  GROW_PLIST(gap_num, num.degree+1);
  SET_LEN_PLIST(gap_num, num.degree+1);
  for (i = 0; i <= num.degree; i++)
    set_elm_plist(gap_num,i+1, NEW_COMPLEX_GSL(num.data+i));

  GROW_PLIST(gap_den, den.degree+1);
  SET_LEN_PLIST(gap_den, den.degree+1);
  for (i = 0; i <= den.degree; i++)
    set_elm_plist(gap_den,i+1, NEW_COMPLEX_GSL(den.data+i));

  return INTOBJ_INT(status);
}

/****************************************************************************
 * other
 ****************************************************************************/

/****************************************************************************
 * interface to GAP
 ****************************************************************************/
static StructGVarFunc GVarFuncs [] = {
  { "COMPLEX_ROOTS", 1, "coeffs", COMPLEX_ROOTS, "fr_dll.c:COMPLEX_ROOTS" },
  { "REAL_ROOTS", 1, "coeffs", REAL_ROOTS, "fr_dll.c:REAL_ROOTS" },
  { "NFFUNCTION_FR", 3, "rel, dir, word", NFFUNCTION, "fr_dll.c:NFFUNCTION" },
  { "FIND_BARYCENTER", 4, "points, init, iter, tol", FIND_BARYCENTER, "fr_dll.c:FIND_BARYCENTER" },
  { "FIND_RATIONALFUNCTION", 6, "degrees, values, points, num, den, params", FIND_RATIONALFUNCTION, "fr_dll.c:FIND_RATIONALFUNCTION" },
  { 0 }
};

static Int InitKernel ( StructInitInfo * module )
{
  InitHdlrFuncsFromTable( GVarFuncs );
  InitP1Kernel();
  return 0;
}

/* 'InitLibrary' sets up gvars, rnams, functions */
static Int InitLibrary ( StructInitInfo * module )
{
  InitGVarFuncsFromTable( GVarFuncs );
  InitP1Library();
  return 0;
}

static StructInitInfo module = {
 /* type        = */ MODULE_DYNAMIC,
 /* name        = */ "fr_dll.c",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 0,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ 0
};

StructInitInfo * Init__Dynamic ( void )
{
 return &module;
}
/* fr_dll.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here */
