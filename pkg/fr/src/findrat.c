/****************************************************************************
 *
 * findrat.c                                                Laurent Bartholdi
 *
 *   @(#)$Id: findrat.c,v 1.2 2010/04/16 19:07:03 gap Exp $
 *
 * Copyright (C) 2010, Laurent Bartholdi
 *
 ****************************************************************************
 *
 * find a rational function, and its critical points, that map to given
 * critical values with given degrees
 *
 ****************************************************************************/

#undef DEBUG_FINDRAT

#ifdef DEBUG_FINDRAT
#include <stdlib.h>
#include <stdio.h>
#endif
#include "fr_dll.h"

/****************************************************************
 * complex polynomials
 ****************************************************************/
gsl_complex poly_eval (polynomial *p, gsl_complex z)
{
  gsl_complex u = p->data[p->degree];
  int i;

  for (i = p->degree-1; i >= 0; i--)
    u = gsl_complex_add (gsl_complex_mul(u, z), p->data[i]);
  return u;
}

void poly_mul_lin (polynomial *p, gsl_complex c) /* multiply by (z-c) */
{
  size_t i = p->degree++;
  
  p->data[i+1] = p->data[i];
  for (; i > 0; i--)
    p->data[i] = gsl_complex_sub (p->data[i-1], gsl_complex_mul (p->data[i], c));
  p->data[0] = gsl_complex_negative(gsl_complex_mul (p->data[0], c));
}

#ifdef DEBUG_FINDRAT
void poly_print (FILE *f, polynomial *p)
{
  int i;
  for (i = 0; i <= p->degree; i++)
    fprintf(f, "%s(%g+I*(%g))*z^%d", i ? "+" : "", GSL_REAL(p->data[i]), GSL_IMAG(p->data[i]), i);
}
#endif

/****************************************************************
 * we look for critical points, and a rational map num/den of
 * given degree;
 * it has s critical points, with critical values v[0]...v[s-1].
 * it is normalized 0->0, 1->1, 8->8.
 * by convention, v[s-3]=1, v[s-2]=0, v[s-1]=8.
 ****************************************************************/
typedef struct {
  size_t degree, s;
  size_t *d;
  gsl_complex *v;
  polynomial *num, *den;
  size_t max_iter;
  double eps1, eps2;
} hurwitz_param;
#define hparam_degree (((hurwitz_param *) param)->degree)
#define hparam_s (((hurwitz_param *) param)->s)
#define hparam_v (((hurwitz_param *) param)->v)
#define hparam_d (((hurwitz_param *) param)->d)
#define hparam_num (((hurwitz_param *) param)->num)
#define hparam_den (((hurwitz_param *) param)->den)
#define hparam_max_iter (((hurwitz_param *) param)->max_iter)
#define hparam_eps1 (((hurwitz_param *) param)->eps1)
#define hparam_eps2 (((hurwitz_param *) param)->eps2)

/****************************************************************
 * we look for a normalized rational map num/den of degree degree;
 * the degrees at 0,8 are respectively d0, d8. 
 * furthermore num'*den - num*den' = diff*z^(d0-1).
 ****************************************************************/
typedef struct {
  size_t degree, d0, d8;
  polynomial diff;
} rat_param;
#define rparam_degree (((rat_param *) param)->degree)
#define rparam_d0 (((rat_param *) param)->d0)
#define rparam_d8 (((rat_param *) param)->d8)
#define rparam_diff (((rat_param *) param)->diff)

/****************************************************************
 * debug
 ****************************************************************/
#ifdef DEBUG_FINDRAT
void print_state (size_t iter, gsl_multiroot_fsolver *solver)
{
  size_t i;

  printf("iter = %u\tx =", (unsigned) iter);
  for (i = 0; i < solver->function->n; i += 2)
    printf(" %f+I*%f", gsl_vector_get(solver->x, i), gsl_vector_get (solver->x, i+1));
  printf("\tf =");
  for (i = 0; i < solver->function->n; i += 2)
    printf(" %.2e+I*%.2e", gsl_vector_get(solver->f, i), gsl_vector_get(solver->f, i+1));
  printf("\n");
}
#endif

/****************************************************************
 * find normalized rational function with given critical values
 ****************************************************************/
int rat_iter (const gsl_vector *coeff_real, void *param, gsl_vector *delta_real)
{
  size_t degree = rparam_degree, d0 = rparam_d0, d8 = rparam_d8;
  gsl_vector_complex *coeff = (gsl_vector_complex *) coeff_real,
    *delta = (gsl_vector_complex *) delta_real;
  int i, j, k;

  /* compute leading coefficient of denominator */
  gsl_complex lden = {{0.0, 0.0}};
  for (i = 0; i <= degree-d0; i++)
    lden = gsl_complex_add (lden, gsl_vector_complex_get (coeff, i));
  for (i = degree-d0+1; i < 2*degree-d0-d8+1; i++)
    lden = gsl_complex_sub (lden, gsl_vector_complex_get (coeff, i));

  /* compute num'*den - den'*num */
  for (k = d0; k <= 2*degree-d8; k++) {
    gsl_complex c = {{0.0, 0.0}};
    for (j = 0; j <= k; j++) {
      i = k-j;
      if (i < d0 || i > degree || j > degree-d8)
	continue;
      c = gsl_complex_add (c, gsl_complex_mul_real (gsl_complex_mul (gsl_vector_complex_get (coeff, i-d0), j == degree-d8 ? lden : gsl_vector_complex_get (coeff, degree+1-d0+j)), i-j));
    }
    gsl_vector_complex_set (delta, k-d0, gsl_complex_sub (c, rparam_diff.data[k-d0]));
  }
  return GSL_SUCCESS;
}

int solve_rat (const size_t degree, const size_t s, const size_t d[], const gsl_vector_complex *c,
	       polynomial *num, polynomial *den, size_t max_iter, double eps1, double eps2)
{
  const gsl_complex complex_one = {{1.0, 0.0}};
  gsl_complex diffdata[degree];
  rat_param param = { degree, d[s-2], d[s-1], { 0, diffdata } };
  int i, j, iter = 0, status, dim = 2*degree - d[s-2] - d[s-1] + 1;

  /* compute param.diff = prod((z-c[i])^(d[i]-1)) */
  param.diff.data[0] = complex_one;
  for (i = 0; i < s-3; i++)
    for (j = 1; j < d[i]; j++)
      poly_mul_lin (&param.diff, gsl_vector_complex_get (c, i));
  for (j = 1; j < d[s-3]; j++)
    poly_mul_lin (&param.diff, complex_one);

  /* initial vector */
  gsl_vector *rat_real = gsl_vector_alloc (2*dim);
  for (i = param.d0; i <= degree; i++)
    gsl_vector_complex_set ((gsl_vector_complex *) rat_real, i-param.d0, num->data[i]);
  for (i = 0; i < degree-param.d8; i++)
    gsl_vector_complex_set ((gsl_vector_complex *) rat_real, i+degree+1-param.d0, den->data[i]);

  /* solver */
  const gsl_multiroot_fsolver_type *T = gsl_multiroot_fsolver_hybrids;
  gsl_multiroot_function f = { &rat_iter, 2*dim, &param };
  gsl_multiroot_fsolver *solver = gsl_multiroot_fsolver_alloc (T, f.n);
  gsl_multiroot_fsolver_set (solver, &f, rat_real);

  do {
#ifdef DEBUG_FINDRAT
    print_state (iter, solver);
#endif
    iter++;
    status = gsl_multiroot_fsolver_iterate (solver);
    
    if (status)   /* check if solver is stuck */
      break;
    
    status = gsl_multiroot_test_delta (solver->dx, solver->x, eps1, eps2);
  } while (status == GSL_CONTINUE && iter < max_iter);

#ifdef DEBUG_FINDRAT
  if (status != GSL_SUCCESS)
    printf("solve_rat status = %s\n", gsl_strerror(status));
#endif

  gsl_complex sum = {{0.0, 0.0}};
  num->degree = degree;
  for (i = 0; i < param.d0; i++)
    GSL_SET_COMPLEX (&num->data[i], 0.0, 0.0);
  for (i = param.d0; i <= degree; i++) {
    num->data[i] = gsl_vector_complex_get ((gsl_vector_complex *) solver->x, i-param.d0);
    sum = gsl_complex_add (sum, num->data[i]);
  }
  den->degree = degree - param.d8;
  for (i = 0; i < degree-param.d8; i++) {
    den->data[i] = gsl_vector_complex_get ((gsl_vector_complex *) solver->x, i+degree+1-param.d0);
    sum = gsl_complex_sub (sum, den->data[i]);
  }
  den->data[degree-param.d8] = sum;
  gsl_multiroot_fsolver_free (solver);
  gsl_vector_free (rat_real);

  return status;
}

/****************************************************************
 * find rational function, and critical points, given hurwitz data
 ****************************************************************/
int hurwitz_iter (const gsl_vector *c_real, void *param, gsl_vector *v_real)
{
  size_t s = hparam_s;
  gsl_vector_complex *c = (gsl_vector_complex *) c_real,
    *v = (gsl_vector_complex *) v_real;
  int i;

  /* get rational function f with critical points c of multiplicities d */
  i = solve_rat (hparam_degree, hparam_s, hparam_d, c, hparam_num, hparam_den, hparam_max_iter, hparam_eps1, hparam_eps2);

  if (i != GSL_SUCCESS)
    return i;

  for (i = 0; i < s-3; i++) {
    /* compute (f(c_i) - paramv_i)) / (1+|paramv_i|^2) */
    gsl_complex n = poly_eval (hparam_num, gsl_vector_complex_get(c,i)),
                d = poly_eval (hparam_den, gsl_vector_complex_get(c,i));
    n = gsl_complex_sub(gsl_complex_div (n, d), hparam_v[i]);
    gsl_vector_complex_set (v, i, gsl_complex_div_real (n, gsl_complex_abs2 (hparam_v[i])+1.0));
  }
  return GSL_SUCCESS;
}

int solve_hurwitz (const size_t degree, const size_t s, const size_t d[], const gsl_complex v[],
		   gsl_complex c[], polynomial *num, polynomial *den, size_t max_iter, double eps1, double eps2)
{
  hurwitz_param param = { degree, s, (size_t *) d, (gsl_complex *) v,
			  num, den, max_iter, eps1, eps2 };
  int i, iter = 0, status, dim = s-3;
  for (i = 0; i < s; i++)
    iter += d[i]-1;

  if (iter != 2*degree-2)
    return -1;

  /* initial vector */
  gsl_vector *c_real = gsl_vector_alloc (2*dim);
  for (i = 0; i < dim; i++)
    gsl_vector_complex_set ((gsl_vector_complex *) c_real, i, c[i]);

  /* solver */
  const gsl_multiroot_fsolver_type *T = gsl_multiroot_fsolver_hybrids;
  gsl_multiroot_function f = { &hurwitz_iter, 2*dim, &param };
  gsl_multiroot_fsolver *solver = gsl_multiroot_fsolver_alloc (T, f.n);
  gsl_multiroot_fsolver_set (solver, &f, c_real);

  do {
#ifdef DEBUG_FINDRAT
    print_state (iter, solver);
#endif
    iter++;
    status = gsl_multiroot_fsolver_iterate (solver);
    
    if (status)   /* check if solver is stuck */
      break;
    
    status = gsl_multiroot_test_delta (solver->dx, solver->x, eps1, eps2);
  } while (status == GSL_CONTINUE && iter < max_iter);

#ifdef DEBUG_FINDRAT
  if (status != GSL_SUCCESS)
    printf("solve_hurwitz status = %s\n", gsl_strerror(status));
#endif

  for (i = 0; i < dim; i++)
    c[i] = gsl_vector_complex_get ((gsl_vector_complex *) solver->x, i);

  gsl_multiroot_fsolver_free (solver);
  gsl_vector_free (c_real);

  return status;
}

#ifdef MAIN_FINDRAT
/****************************************************************
 * tester
 ****************************************************************/
int main (int argc, char *argv[])
{
  const size_t degree = 4, s = 4;
  const size_t d[] = { 2, 3, 3, 2 };
  const gsl_complex v[] = { {{0.0,1.0}}, {{1.0,0.0}}, {{0.0,0.0}}, {{HUGE_VAL,HUGE_VAL}} };
  gsl_complex c[s-3];
  GSL_SET_COMPLEX (&c[0], -0.302, 0.405);
  polynomial num, den;
  int i;

  num.degree = den.degree = degree;
  for (i = 0; i <= degree; i++) {
    GSL_SET_COMPLEX(&num.data[i], i+0.5, 1.0);
    GSL_SET_COMPLEX(&den.data[i], i+0.5, 2.0);
  }
  GSL_SET_COMPLEX(&num.data[0], 0.0,0.0);
  GSL_SET_COMPLEX(&num.data[1], 0.0,0.0);
  GSL_SET_COMPLEX(&num.data[2], 0.0,0.0);
  GSL_SET_COMPLEX(&num.data[3], 0.06, 1.2);
  GSL_SET_COMPLEX(&num.data[4],-0.05,-0.4);
  den.degree = 2;
  GSL_SET_COMPLEX(&den.data[0],-0.1,-0.08);
  GSL_SET_COMPLEX(&den.data[1], 0.2,-0.2);
  GSL_SET_COMPLEX(&den.data[2],-0.1, 1.0);

  solve_hurwitz (degree, s, d, v, c, &num, &den);

  printf("p := [x$i=1..%d,1,0,infinity]:", s-3);
  for (i = 0; i < s-3; i++)
    printf(" p[%d] := %g+I*(%g);", i+1, GSL_REAL(c[i]), GSL_IMAG(c[i]));
  printf("\n");
  printf("f := ("); poly_print (stdout, &num); printf(") / ("); poly_print (stdout, &den); printf(");\n");

  printf("fsolve(numer(diff(f,z)));\n");
  printf("seq(limit(f,z=p[i]),i=1..nops(p));\n");

  return 0;
}
#endif

/* findrat.c . . . . . . . . . . . . . . . . . . . . . . . . . . .ends here */
