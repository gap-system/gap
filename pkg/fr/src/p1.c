/****************************************************************************
 *
 * p1.c                                                     Laurent Bartholdi
 *
 *   @(#)$Id: p1.c,v 1.29 2011/11/10 08:33:38 gap Exp $
 *
 * Copyright (c) 2009, 2010, Laurent Bartholdi
 *
 ****************************************************************************
 *
 * handle points on P1:
 * compute points to and from complex number; point antipode, barycentre;
 * rational maps, including Möbius transformations; convert to and from
 * rational map. Compose, invert, evaluate, compute preimages;
 * compute intersections of algebraic curves.
 ****************************************************************************/

#undef DEBUG_DELAUNAY
#undef DEBUG_COMPLEX_ROOTS

#include <math.h>
#include <complex.h>
#include "fr_dll.h"
#define IS_MACFLOAT(obj) (TNUM_OBJ(obj) == T_MACFLOAT)

typedef long double ldouble;
typedef _Complex long double ldcomplex;
typedef ldcomplex p1point;

Obj TYPE_P1POINT, TYPE_P1MAP, IsP1Point, IsP1Map,
  Complex, COMPLEX_0, COMPLEX_1, P1infinity;

static void guarantee(Obj filter, const char *name, Obj obj)
{
  while (!IS_DATOBJ(obj) || DoFilter(filter, obj) != True) {
    obj = ErrorReturnObj("FR: object must be a %s, not a %s",
			 (Int) name, (Int)(InfoBags[TNUM_OBJ(obj)].name),
			 "You can return an appropriate object to continue");
  }
}

static int cisfinite(ldcomplex c)
{
#ifdef isfinite
  return isfinite(creall(c));
#else
  return __finitel(creall(c));
#endif
}

static ldouble cnorm (ldcomplex c)
{
  if (cisfinite(c))
    return c*~c;
  else
    return FLT_MAX;
}

static ldcomplex p1map_eval (int deg, ldcomplex *numer, ldcomplex *denom, p1point p);

/****************************************************************
 * points
 ****************************************************************/
static p1point GET_P1POINT(Obj obj) {
  guarantee(IsP1Point, "P1 point", obj);
  return * (p1point *) (ADDR_OBJ(obj)+1);
}

static Obj NEW_P1POINT (p1point p)
{
  Obj obj = NewBag(T_DATOBJ,sizeof(Obj)+sizeof p);
  SET_TYPE_DATOBJ(obj,TYPE_P1POINT);
  * (p1point *) (ADDR_OBJ(obj)+1) = p;
  return obj;
}

static Obj NEW_P1POINT2 (ldcomplex n, ldcomplex d)
{
  if (d == 0.)
    return P1infinity;
  else
    return NEW_P1POINT(n/d);
}

static Obj NEW_COMPLEX (ldcomplex c) {
  Obj r = NEW_FLOAT(creal(c));
  Obj i = NEW_FLOAT(cimag(c));
  return CALL_2ARGS(Complex,r,i);
}

static Obj P1POINT2STRING(Obj self, Obj objprec, Obj obj)
{
  p1point q = GET_P1POINT(obj);
  Obj str = NEW_STRING(100);
  int len;
  int prec = INT_INTOBJ(objprec);

  if (cisfinite(q))
    len = sprintf(CSTR_STRING(str),"%.*Lg%+.*Lgi",prec,creall(q),prec,cimagl(q));
  else
    len = sprintf(CSTR_STRING(str),"P1infinity");

  SET_LEN_STRING(str, len);
  SHRINK_STRING(str);
  return str;
}

static void p1point_c2 (ldcomplex *c, p1point p)
{
  if (!cisfinite(p))
    c[0] = 1.0, c[1] = 0.0;
  else if (cnorm(p) <= 1.0)
    c[0] = p, c[1] = 1.0;
  else
    c[0] = 1.0, c[1] = 1.0/p;
}

static Obj P1POINT2C2(Obj self, Obj obj)
{
  p1point q = GET_P1POINT(obj);
  obj = ALLOC_PLIST(2);
  if (!cisfinite(q)) {
    set_elm_plist(obj,1, COMPLEX_1);
    set_elm_plist(obj,2, COMPLEX_0);
  } else if (cnorm(q) <= 1.0) {
    set_elm_plist(obj,1, NEW_COMPLEX(q));
    set_elm_plist(obj,2, COMPLEX_1);
  } else {
    set_elm_plist(obj,1, COMPLEX_1);
    set_elm_plist(obj,2, NEW_COMPLEX(1.0/q));
  }
  return obj;
}

static ldcomplex VAL_COMPLEX(Obj obj)
{
  return VAL_FLOAT(ELM_PLIST(obj,1)) + 1.0i*VAL_FLOAT(ELM_PLIST(obj,2));
}

static Obj C22P1POINT(Obj self, Obj obj)
{
  ldcomplex n = VAL_COMPLEX(ELM_PLIST(obj,1)), d = VAL_COMPLEX(ELM_PLIST(obj,2));
  if (d == 0.)
    return P1infinity;
  else
    return NEW_P1POINT2(n,d);
}

static Obj EQ_P1POINT(Obj self, Obj p, Obj q)
{
  p1point pp = GET_P1POINT(p), pq = GET_P1POINT(q);
  if (!cisfinite(pp) || !cisfinite(pq))
    return cisfinite(pp) == cisfinite(pq) ? True : False;
  return pp == pq ? True : False;
}

static Obj LT_P1POINT(Obj self, Obj p, Obj q)
{
  p1point pp = GET_P1POINT(p), pq = GET_P1POINT(q);
  if (!cisfinite(pp)) return False;
  if (!cisfinite(pq)) return True;
  if (creall(pp) < creall(pq)) return True;
  if (creall(pp) > creall(pq)) return False;
  return cimagl(pp) < cimagl(pq) ? True : False;
}

p1point p1point_sphere (ldouble u[3])
{
  ldouble n = sqrtl(u[0]*u[0] + u[1]*u[1] + u[2]*u[2]);
  ldouble v[3] = { u[0]/n, u[1]/n, u[2]/n };

  if (v[2] > 0.0)
    return (v[0] + v[1]*1.0i) / (1.0 + v[2]);
  else if (v[0] == 0.0 && v[1] == 0.0)
    return 1.0/0.0;
  else
    return (1.0-v[2]) / (v[0] - v[1]*1.0i);  
}

static Obj P1Sphere(Obj self, Obj obj)
{
  while (!IS_PLIST(obj) || LEN_PLIST(obj)!=3 || !IS_MACFLOAT(ELM_PLIST(obj,1))
	 || !IS_MACFLOAT(ELM_PLIST(obj,2)) || !IS_MACFLOAT(ELM_PLIST(obj,3))) {
    obj = ErrorReturnObj("FR: object must be a floatean list of length 3, not a %s",
                       (Int)(InfoBags[TNUM_OBJ(obj)].name),0,
                       "You can return an appropriate object to continue");
  }
  ldouble v[3];
  int i;
  for (i = 0; i < 3; i++)
    v[i] = VAL_FLOAT(ELM_PLIST(obj,i+1));
  return NEW_P1POINT(p1point_sphere(v));
}

void sphere_p1point (p1point p, ldouble s[3])
{
  if (cisfinite(p)) {
    ldouble n = cnorm(p);
    s[0] = 2.0*creall(p)/(1.0+n);
    s[1] = 2.0*cimagl(p)/(1.0+n);
    s[2] = (1.0-n)/(1.0+n);
  } else
    s[0] = s[1] = 0.0, s[2] = -1.0;
}

static Obj SphereP1(Obj self, Obj obj)
{
  ldouble s[3];
  int i;
  sphere_p1point (GET_P1POINT(obj), s);
  obj = ALLOC_PLIST(3);
  for (i = 0; i < 3; i++)
    set_elm_plist(obj,i+1, NEW_FLOAT((Double)s[i]));
  return obj;
}

static Obj SphereP1Y(Obj self, Obj obj)
{
  p1point p = GET_P1POINT(obj);
  if (cisfinite(p))
    return NEW_FLOAT((Double)2.0*cimagl(p)/(1.0+cnorm(p)));
  else
    return NEW_FLOAT(0.0);
}

static Obj P1Antipode(Obj self, Obj obj)
{
  p1point p = GET_P1POINT(obj);
  if (p == 0.)
    p = 1.0/0.0;
  else if (cisfinite(p))
    p = -~(1.0/p);
  else
    p = 0.0;
  return NEW_P1POINT(p);
}

void clean_complex (ldcomplex *v, ldouble prec)
{
  if (cisfinite(*v)) {
    if (fabsl(cimagl(*v)) < prec*fabsl(creall(*v))) {
      ldouble z = creall(*v);
      if (fabsl(z-1.0) < prec)
	z = 1.0;
      if (fabsl(z+1.0) < prec)
	z = -1.0;
      *v = z;
    }
    if (fabsl(creall(*v)) < prec*fabsl(cimagl(*v))) {
      ldouble z = cimagl(*v);
      if (fabsl(z-1.0) < prec)
	z = 1.0;
      if (fabsl(z+1.0) < prec)
	z = -1.0;
      *v = z*1.0i;
    }
  }
}

static Obj CLEANEDP1POINT(Obj self, Obj objp, Obj objprec)
{
  ldcomplex p = GET_P1POINT(objp);
  ldouble prec = VAL_FLOAT(objprec);
  clean_complex(&p, prec);
  ldouble n = cnorm(p);
  if (n > 0.5/(prec*prec))
    return P1infinity;
  if (n < 2.0*prec*prec)
    p = 0.0;
  return NEW_P1POINT(p);
}

static Obj P1BARYCENTRE(Obj self, Obj list)
{
  int n = LEN_PLIST(list), i, j;
  ldouble s[3] = { 0.0, 0.0, 0.0 }, t[3];
  for (i = 0; i < n; i++) {
    sphere_p1point (GET_P1POINT(ELM_PLIST(list,i+1)), t);
    for (j = 0; j < 3; j++) s[j] += t[j];
  }
  for (j = 0; j < 3; j++) s[j] /= n;
  return NEW_P1POINT(p1point_sphere(s));
}

static Obj P1Midpoint(Obj self, Obj objp, Obj objq)
{
  p1point p = GET_P1POINT(objp), q = GET_P1POINT(objq);
  if (!cisfinite(p) && !cisfinite(q))
    return P1infinity;
  else if (!cisfinite(p)) {
    if (q == 0.0) return Fail;
    return NEW_P1POINT(q*(1.0+sqrtl(1.0+1.0/cnorm(q))));
  } else if (!cisfinite(q)) {
    if (p == 0.0) return Fail;
    return NEW_P1POINT(p*(1.0+sqrtl(1.0+1.0/cnorm(p))));
  } else {
    ldcomplex d = 1.0 + q*~p;
    if (d == 0.0) return Fail;
    ldouble a = sqrtl((1.0+cnorm(p))/(1.0+cnorm(q))*cnorm(d));
    return NEW_P1POINT2(a*q+d*p,a+d);
  }
}

static Obj P1Distance(Obj self, Obj objp, Obj objq)
{
  p1point p = GET_P1POINT(objp);
  p1point q = GET_P1POINT(objq);
  ldouble v;

  if (p == q)
    return NEW_FLOAT(0.0);
  else if (!cisfinite(p)) {
    v = 1.0/cabsl(q);
  } else if (!cisfinite(q))
    v = 1.0/cabsl(p);
  else {
    ldcomplex d = 1.0+(~p)*q;
    if (d == 0.)
      v = 1.0/0.0;
    else
      v = cabsl((p-q)/d);
  }
  return NEW_FLOAT((Double)2.0*atan(v));
}

static Obj P1XRatio(Obj self, Obj p1, Obj p2, Obj p3, Obj p4)
{
  ldcomplex x[4][2];
  p1point_c2 (x[0], GET_P1POINT(p1));
  p1point_c2 (x[1], GET_P1POINT(p2));
  p1point_c2 (x[2], GET_P1POINT(p3));
  p1point_c2 (x[3], GET_P1POINT(p4));

  return NEW_COMPLEX ((x[0][0]*x[2][1]-x[2][0]*x[0][1])
		      / (x[1][0]*x[2][1]-x[2][0]*x[1][1])
		      * (x[1][0]*x[3][1]-x[3][0]*x[1][1])
		      / (x[0][0]*x[3][1]-x[3][0]*x[0][1]));
}

static Obj P1Circumcentre(Obj self, Obj obja, Obj objb, Obj objc)
{
/* circumcentre := function(a,b,c)
 * local p;
 * p := Norm(a)*(b-c)+Norm(b)*(c-a)+Norm(c)*(a-b);
 * q := a*~b*(1+Norm(c))+b*~c*(1+Norm(a))+c*~a*(1+Norm(b));
 * centres := solve(p+(q-~q)*z+~p*z^2);
 * d := P1Distance(centres[1],a);
 * if d<pi/2 then
 *     return [centres[1],d];
 * else
 *     return [centres[2],pi-d];
 * fi;
 */
  ldcomplex p, q, v[3][2];
  int i;
  p1point_c2 (v[0], GET_P1POINT(obja));
  p1point_c2 (v[1], GET_P1POINT(objb));
  p1point_c2 (v[2], GET_P1POINT(objc));

  p = q = 0.0;
  for (i = 0; i < 3; i++) {
    ldcomplex *a = v[i], *b = v[(i+1)%3], *c = v[(i+2)%3];
    p += cnorm(a[0])*b[1]*c[1]*~(b[0]*c[1]-c[0]*b[1]);
    q += a[0]*~b[0]*~a[1]*b[1]*(cnorm(c[0])+cnorm(c[1]));
  }
  q = (q - ~q) / 2.0;

  ldcomplex centre;

  if (p == 0.0)
    centre = 0.0;
  else
    centre = (-q + csqrtl(q*q-cnorm(p))) / p;

  ldouble d = cabsl(centre*v[0][1] - v[0][0]) / cabsl(~centre*v[0][0]+v[0][1]);
  if (d > 1.0)
    d = 1.0/d, centre = -1.0/~centre;

  Obj result = ALLOC_PLIST(2);
  set_elm_plist(result,1, NEW_P1POINT(centre));
  set_elm_plist(result,2, NEW_FLOAT((Double)2.0*atan(d)));

  return result;
}

/****************************************************************
 * rational maps
 ****************************************************************/
static int p1map_degree(Obj obj) {
  guarantee (IsP1Map, "P1 map", obj);
  return (SIZE_OBJ(obj)-sizeof(Obj))/2/sizeof(ldcomplex)-1;
}

static ldcomplex *p1map_numer(Obj obj) {
  guarantee (IsP1Map, "P1 map", obj);
  return (ldcomplex *) (ADDR_OBJ(obj)+1);
}

static ldcomplex *p1map_denom(Obj obj) {
  guarantee (IsP1Map, "P1 map", obj);
  return (ldcomplex *) ((char *) (ADDR_OBJ(obj)+1) + (SIZE_OBJ(obj)-sizeof(Obj))/2);
}

static Obj NEW_P1MAP (int degree, ldcomplex *oldnumer, ldcomplex *olddenom)
{
  Obj obj;
  int i;
  obj = NewBag(T_DATOBJ,sizeof(Obj)+(degree+1)*2*sizeof(ldcomplex));
  SET_TYPE_DATOBJ(obj,TYPE_P1MAP);
  ldcomplex *numer = p1map_numer(obj), *denom = p1map_denom(obj);
  for (i = 0; i <= degree; i++)
    numer[i] = oldnumer[i], denom[i] = olddenom[i];
  return obj;
}

static Obj MAT2P1MAP(Obj self, Obj obj)
{
  int deg = LEN_PLIST(ELM_PLIST(obj,1))-1, i, j;
  ldcomplex coeff[2][deg+1];
  for (i = 0; i < 2; i++)
    for (j = 0; j <= deg; j++)
      coeff[i][j] = VAL_COMPLEX(ELM_PLIST(ELM_PLIST(obj,i+1),j+1));
  return NEW_P1MAP(deg, coeff[0], coeff[1]);
}

static Obj P1MAP2MAT(Obj self, Obj map)
{
  Obj mat = ALLOC_PLIST(2);
  int deg = p1map_degree(map);
  Obj objnumer = ALLOC_PLIST(deg+1), objdenom = ALLOC_PLIST(deg+1);
  ldcomplex *numer = p1map_numer(map), *denom = p1map_denom(map);
  int i;
  for (i = 0; i <= deg; i++) {
    set_elm_plist(objnumer,i+1, NEW_COMPLEX(numer[i]));
    set_elm_plist(objdenom,i+1, NEW_COMPLEX(denom[i]));
  }
  set_elm_plist(mat,1, objnumer);
  set_elm_plist(mat,2, objdenom);
  return mat;
}

static Obj P1MAPDEGREE(Obj self, Obj obj)
{
  return INTOBJ_INT(p1map_degree(obj));
}

static Obj P1MAP3(Obj self, Obj objp, Obj objq, Obj objr)
{ /* Möbius transformation 0->p, 1->q, infty->r */
  ldcomplex p[2], q[2], r[2];
  p1point_c2 (p, GET_P1POINT(objp));
  p1point_c2 (q, GET_P1POINT(objq));
  p1point_c2 (r, GET_P1POINT(objr));
  ldcomplex pq = q[0]*p[1]-p[0]*q[1], qr = r[0]*q[1]-q[0]*r[1];
  ldcomplex numer[2] = { p[0]*qr, r[0]*pq }, denom[2] = { p[1]*qr, r[1]*pq };
  return NEW_P1MAP(1, numer, denom);
}

static Obj P1PATH(Obj self, Obj objp, Obj objq)
{ /* Möbius transformation 0->p, 1->q, infty->P1Antipode(p) */
  ldcomplex p[2], q[2], r[2];
  p1point_c2 (p, GET_P1POINT(objp));
  p1point_c2 (q, GET_P1POINT(objq));
  r[0] = -~p[1]; r[1] = ~p[0];
  ldcomplex pq = q[0]*p[1]-p[0]*q[1], qr = r[0]*q[1]-q[0]*r[1];
  ldcomplex numer[2] = { p[0]*qr, r[0]*pq }, denom[2] = { p[1]*qr, r[1]*pq };
  return NEW_P1MAP(1, numer, denom);
}

static Obj P1MAP2(Obj self, Obj objp, Obj objq)
{ /* Möbius transformation 0->p, infty->q */
  ldcomplex p[2], q[2];
  p1point_c2 (p, GET_P1POINT(objp));
  p1point_c2 (q, GET_P1POINT(objq));
  ldcomplex numer[2] = { p[0], q[0] }, denom[2] = { p[1], q[1] };
  return NEW_P1MAP(1, numer, denom);
}

static void copy_poly (int deg, ldcomplex *coeff, int dega, ldcomplex *coeffa)
{ /* coeff = coeffa */
  int i;
  for (i = 0; i <= dega; i++)
    coeff[i] = coeffa[i];
  for (i = dega+1; i <= deg; i++)
    coeff[i] = 0.0;
}

static void der_poly (int deg, ldcomplex *coeff, int dega, ldcomplex *coeffa)
{ /* coeff = coeffa' */
  int i;
  for (i = 1; i <= dega; i++)
    coeff[i-1] = i*coeffa[i];
  for (i = dega; i <= deg; i++)
    coeff[i] = 0.0;
}

static void mul_poly (int deg, ldcomplex *coeff, int dega, ldcomplex *coeffa, int degb, ldcomplex *coeffb)
{ /* coeff = coeffa * coeffb */
  int i, j;
  for (i = 0; i <= deg; i++) {
    ldcomplex sum = 0.0;
    for (j = 0; j <= i; j++)
      if (j <= dega && i-j <= degb) sum += coeffa[j]*coeffb[i-j];
    coeff[i] = sum;
  }
}

static void xplusequalay_poly (int deg, ldcomplex *coeff, ldcomplex k, int dega, ldcomplex *coeffa)
{ /* coeff += k*coeffa */
  int i;
  for (i = 0; i <= dega; i++)
    coeff[i] += k*coeffa[i];
}

static ldcomplex eval_poly (int deg, ldcomplex *coeff, ldcomplex x)
{ /* evaluate coeff at x */
  ldcomplex v = coeff[deg];
  int i;
  for (i = deg-1; i >= 0; i--)
    v = v*x + coeff[i];
  return v;
}

static ldcomplex eval_ylop (int deg, ldcomplex *coeff, ldcomplex x)
{ /* evaluate x^deg*coeff at 1/x */
  ldcomplex v = coeff[0];
  int i;
  for (i = 1; i <= deg; i++)
    v = v*x + coeff[i];
  return v;
}

static ldcomplex eval_d_poly (int deg, ldcomplex *coeff, ldcomplex x)
{ /* evaluate coeff' at x */
  ldcomplex v = deg*coeff[deg];
  int i;
  for (i = deg-1; i >= 1; i--)
    v = v*x + i*coeff[i];
  return v;
}

static Obj CLEANUPP1MAP(Obj self, Obj map, Obj objprec)
{
  int deg = p1map_degree(map), i, j;
  ldouble prec = VAL_FLOAT(objprec);
  ldcomplex coeff[2][deg+1];

  copy_poly (deg, coeff[0], deg, p1map_numer(map));
  copy_poly (deg, coeff[1], deg, p1map_denom(map));

  ldouble m;
  for (i = 0; i < 2; i++) {
    ldouble norm[deg+1];
    m = 0.0;
    for (j = 0; j <= deg; j++) {
      norm[j] = cnorm(coeff[i][j]);
      if (norm[j] > m) m = norm[j];
    }
    for (j = 0; j <= deg; j++)
      if (norm[j] < prec*m)
	coeff[i][j] = 0.0;
  }

  for (i = 0; i < deg && coeff[1][i] == 0.0; i++);
  ldcomplex c = coeff[1][i];
  for (i = 0; i < 2; i++)
    for (j = 0; j <= deg; j++) {
      coeff[i][j] /= c;
      clean_complex(&coeff[i][j], prec);
    }

  return NEW_P1MAP(deg, coeff[0], coeff[1]);
}

void compose_rat (int deg, ldcomplex *numer, ldcomplex *denom, int dega, ldcomplex *numera, ldcomplex *denoma, int degb, ldcomplex *numerb, ldcomplex *denomb)
{ /* compute numer/denom = numera/denoma @ numerb/denomb */
  int i, j;
  ldcomplex powb[dega+1][deg+1], temp[deg+1]; /* powb[i] will be numerb^i denomb^(dega-i) */
  copy_poly(deg, powb[0], degb, denomb);
  copy_poly(deg, powb[1], degb, numerb);
  for (i = 2; i <= dega; i++) {
    for (j = i; j > 0; j--)
      mul_poly (deg, powb[j], deg, powb[j-1], degb, numerb);
    mul_poly (deg, temp, deg, powb[0], degb, denomb);
    copy_poly (deg, powb[0], deg, temp);
  }
  copy_poly (deg, numer, -1, NULL);
  copy_poly (deg, denom, -1, NULL);
  for (i = 0; i <= dega; i++) {
    xplusequalay_poly (deg, numer, numera[i], deg, powb[i]);
    xplusequalay_poly (deg, denom, denoma[i], deg, powb[i]);
  }
}

static Obj COMPOSEP1MAP(Obj self, Obj a, Obj b)
{
  int dega = p1map_degree(a), degb = p1map_degree(b), deg = dega*degb;
  ldcomplex numer[deg+1], denom[deg+1];

  compose_rat (deg, numer, denom, dega, p1map_numer(a), p1map_denom(a), degb, p1map_numer(b), p1map_denom(b));
  return NEW_P1MAP(deg, numer, denom);
}

void invert_rat (ldcomplex *numer, ldcomplex *denom, ldcomplex *numera, ldcomplex *denoma)
{
  numer[0] = -numera[0];
  numer[1] = denoma[0];
  denom[0] = numera[1];
  denom[1] = -denoma[1];
}

static Obj INVERTP1MAP(Obj self, Obj map)
{
  if (p1map_degree(map) != 1)
    return Fail;
  ldcomplex numer[2], denom[2];
  invert_rat (numer, denom, p1map_numer(map), p1map_denom(map));
  return NEW_P1MAP(1, numer, denom);
}

static ldcomplex p1map_eval (int deg, ldcomplex *numer, ldcomplex *denom, p1point p)
{
  if (!cisfinite(p))
    return numer[deg] / denom[deg];
  if (cnorm(p) <= 1.0)
    return eval_poly (deg, numer, p) / eval_poly(deg, denom, p);
  p = 1.0 / p;
  return eval_ylop (deg, numer, p) / eval_ylop(deg, denom, p);
}

static Obj P1IMAGE(Obj self, Obj map, Obj objp)
{
  return NEW_P1POINT(p1map_eval(p1map_degree(map), p1map_numer(map), p1map_denom(map),
				GET_P1POINT(objp)));
}

#define cpoly cpoly_ldouble
typedef ldouble xreal;
typedef ldcomplex xcomplex;
static const struct { Cdouble ZERO, INFIN; int MIN_EXP, MAX_EXP; }
  xdata = { 0.0, LDBL_MAX, LDBL_MIN_EXP, LDBL_MAX_EXP };
static xreal xnorm(xcomplex z) { return __real__(z)*__real(z)+__imag__(z)*__imag__(z);}
static xreal xabs(xcomplex z) { return sqrtl(xnorm(z)); }
static xreal xroot(xreal x, int n) { return powl(x,1.0l/n); }
static int xlogb(xcomplex z) { return ilogbl(xnorm(z)) / 2; }
#define xbits(z) DBL_MANT_DIG
#define xeta(z) DBL_EPSILON
typedef enum { false = 0, true = 1 } bool;
static void xscalbln (xcomplex *z, int e) {
  __real__(*z) = scalblnl(__real__(*z), e);
  __imag__(*z) = scalblnl(__imag__(*z), e);
}
#include "cpoly.C"
static int roots_poly (int degree, ldcomplex *coeff, ldcomplex *zero)
{
  xcomplex op[degree+1];
  int i;
  for (i = 0; i <= degree; i++) /* high-degree coefficient first for cpoly */
    op[i] = coeff[degree-i];
  return cpoly_ldouble (degree, op, zero);
}

static int roots_rpoly (int degree, ldouble *coeff, ldcomplex *zero)
{
  long double opr[degree+1], zeror[degree], zeroi[degree];
  int i;
  while (degree > 0 && coeff[degree] == 0.0)
    degree--;
  for (i = 0; i <= degree; i++)
    opr[i] = coeff[degree-i];
  rpoly (opr, &degree, zeror, zeroi);
  for (i = 0; i < degree; i++)
    zero[i] = zeror[i] + 1.0i*zeroi[i];
  return degree;
}

static Obj P1PREIMAGES(Obj self, Obj map, Obj objp)
{
  ldcomplex p[2];
  p1point_c2 (p, GET_P1POINT(objp));
  int deg = p1map_degree(map), i;
  ldcomplex poly[deg+1], zero[deg];
  copy_poly (deg, poly, -1, NULL);
  xplusequalay_poly (deg, poly, p[1], deg, p1map_numer(map));
  xplusequalay_poly (deg, poly, -p[0], deg, p1map_denom(map));

  int numroots = roots_poly (deg, poly, zero);
  if (numroots < 0)
    return Fail;

  Obj obj = ALLOC_PLIST(deg);
  for (i = 0; i < numroots; i++)
    set_elm_plist(obj,i+1, NEW_P1POINT(zero[i]));
  for (i = numroots; i < deg; i++)
    set_elm_plist(obj,i+1, P1infinity);
  return obj;
}

static Obj P1CRITICAL(Obj self, Obj map)
{
  int deg = p1map_degree(map), i;
  ldcomplex poly[2*deg], temp[2*deg], der[deg], zero[2*deg-2];
  der_poly (deg-1, der, deg, p1map_numer(map));
  mul_poly (2*deg-1, poly, deg-1, der, deg, p1map_denom(map));
  der_poly (deg-1, der, deg, p1map_denom(map));
  mul_poly (2*deg-1, temp, deg-1, der, deg, p1map_numer(map));
  xplusequalay_poly (2*deg-2, poly, -1.0, 2*deg-2, temp);
  int numroots = roots_poly (2*deg-2, poly, zero);
  if (numroots < 0)
    return Fail;
  Obj obj = ALLOC_PLIST(2*deg-2);
  for (i = 0; i < numroots; i++)
    set_elm_plist(obj,i+1, NEW_P1POINT(zero[i]));
  for (i = numroots; i < 2*deg-2; i++)
    set_elm_plist(obj,i+1, P1infinity);
  return obj;
}

static Obj P1INTERSECT(Obj self, Obj gamma, Obj ratmap, Obj delta)
{ /* computes the (t,u) in [t0,1]x[0,1] such that gamma(t) = ratmap(delta(u)).
   * returns a list of [t,u,Im(gamma^-1*ratmap*delta)'(u),gamma(t),delta(u)]
   * gamma, delta are Möbius transformations, and ratmap is a rational map.
   */
  const ldouble eps = 1.0e-8;

  if (p1map_degree(gamma) != 1 || p1map_degree(delta) != 1)
    return Fail;

  int deg = p1map_degree(ratmap), i;
  ldcomplex numer[deg+1], denom[deg+1]; /* numer/denom = gamma^-1*ratmap*delta */
  {
    ldcomplex numer2[deg+1], denom2[deg+1];
    invert_rat (numer, denom, p1map_numer(gamma), p1map_denom(gamma));
    compose_rat (deg, numer2, denom2, 1, numer, denom, deg, p1map_numer(ratmap), p1map_denom(ratmap));
    compose_rat (deg, numer, denom, deg, numer2, denom2, 1, p1map_numer(delta), p1map_denom(delta));
  }

  ldcomplex poly[2*deg+1], zero[2*deg], conjdenom[deg+1]; /* poly = numer*~denom */
  for (i = 0; i <= deg; i++)
    conjdenom[i] = ~denom[i];
  mul_poly (2*deg, poly, deg, numer, deg, conjdenom);

  ldouble rpoly[2*deg+1]; /* rpoly = imag(poly) */
  for (i = 0; i <= 2*deg; i++)
    rpoly[i] = cimagl(poly[i]);
  int numroots = roots_rpoly (2*deg, rpoly, zero);
  if (numroots < 0)
    return Fail;

  Obj res = ALLOC_PLIST(0);
  for (i = 0; i < numroots; i++)
    if (cimagl(zero[i]) == 0.0 && creall(zero[i]) >= -eps && creall(zero[i]) <= 1.0+eps) {
      ldcomplex t = p1map_eval (deg, numer, denom, zero[i]); /* t = gamma^-1*ratmap*delta(u) */
      
      if (cisfinite(t) && cimagl(t) >= -1.0 && cimagl(t) <= 1.0 && creall(t) >= -eps && creall(t) <= 1.0+eps) { /* in fact, cimag(t) is microscopic; just avoid infinity */
	Obj tu = ALLOC_PLIST(5);
	set_elm_plist(tu,1, NEW_FLOAT(creal(t))); /* t */
	set_elm_plist(tu,2, NEW_FLOAT(creal(zero[i]))); /* u */
	ldcomplex d = eval_d_poly(2*deg, poly, zero[i]);
	ldouble y = cimagl(d) / cabsl(d); /* direction of approach */
	set_elm_plist(tu,3, INTOBJ_INT(y < -eps ? -1 : (y > eps ? 1 : 0)));
	set_elm_plist(tu,4, NEW_P1POINT(p1map_eval(1, p1map_numer(gamma), p1map_denom(gamma), t)));
	set_elm_plist(tu,5, NEW_P1POINT(p1map_eval(1, p1map_numer(delta), p1map_denom(delta), zero[i])));
	AddPlist(res,tu);
      }
    }
  return res;
}

static Obj P1ROTATION(Obj self, Obj points, Obj extra)
{ /* find a Möbius transformation that sends the last of points to
   * P1infinity, and either
   * - matches points and extra as well as possible, if extra is a list;
   * - does a dilatation around infinity of amplitude extra, if it is a real.
   */
  int len = LEN_PLIST(points), i;
  p1point p = GET_P1POINT(ELM_PLIST(points,len));
  p1point mat[2][2];

  if (cisfinite(p)) {
    if (cnorm(p) <= 1.0)
      mat[0][0] = mat[1][1] = 1.0, mat[0][1] = ~p, mat[1][0] = -p;
    else {
      p = 1.0/p;
      mat[0][1] = mat[1][0] = 1.0, mat[0][0] = ~p, mat[1][1] = -p;
    }
  } else
    mat[0][1] = mat[1][0] = 1.0, mat[0][0] = mat[1][1] = 0.0;

  ldcomplex proj[len];
  for (i = 0; i < len; i++) {
    ldcomplex p = p1map_eval (1, mat[0], mat[1], GET_P1POINT(ELM_PLIST(points,i+1)));
    if (cisfinite(p))
      proj[i] = 2.0*p / (1.0 + cnorm(p));
    else
      proj[i] = 0.0;
  }

  ldcomplex theta = 0.0;

  if (IS_PLIST(extra)) {
    ldcomplex oldproj[len];
    for (i = 0; i < len; i++) {
      ldcomplex p = GET_P1POINT(ELM_PLIST(extra,i+1));
      if (cisfinite(p))
	oldproj[i] = 2.0*p / (1.0 + cnorm(p));
      else
	oldproj[i] = 0.0;
    }
    ldouble n = 0.0;
    for (i = 0; i < len; i++)
      theta += ~proj[i]*oldproj[i], n += cnorm(proj[i]);
    theta /= n;

    if (n == 0.0 || cnorm(theta) < 0.7) /* no good rotation */
      theta = 0.0;
  }

  if (theta == 0.0) { /* now just force the point of largest projection to be
			 on the positive real axis */
    ldouble q = 0.1;
    theta = 1.0;
    for (i = 0; i < len; i++) {
      ldouble n = cnorm(proj[i]);
      if (n > q)
	q = n, theta = ~proj[i];
    }
  }    
  theta /= cabsl(theta); /* make it of norm 1 */

  if (TNUM_OBJ(extra) == T_MACFLOAT)
    theta *= VAL_FLOAT(extra);

  mat[0][0] *= theta;
  mat[0][1] *= theta;
  return NEW_P1MAP(1, mat[0], mat[1]);
}

/* data to be passed to fr_dll */
static StructGVarFunc GVarFuncs[] = {
  { "P1POINT2C2", 1, "p1point", P1POINT2C2, "p1.c:P1POINT2C2" },
  { "C22P1POINT", 1, "c2vect", C22P1POINT, "p1.c:C22P1POINT" },
  { "P1POINT2STRING", 2, "digits, p1point", P1POINT2STRING, "p1.c:P1POINT2STRING" },
  { "EQ_P1POINT", 2, "p1point, p1point", EQ_P1POINT, "p1.c:EQ_P1POINT" },
  { "LT_P1POINT", 2, "p1point, p1point", LT_P1POINT, "p1.c:LT_P1POINT" },
  { "P1Sphere", 1, "list", P1Sphere, "p1.c:P1Sphere" },
  { "SphereP1", 1, "p1point", SphereP1, "p1.c:SphereP1" },
  { "SphereP1Y", 1, "p1point", SphereP1Y, "p1.c:SphereP1Y" },
  { "CleanedP1Point", 2, "p1point, prec", CLEANEDP1POINT, "p1.c:CLEANEDP1POINT" },
  { "P1Antipode", 1, "p1point", P1Antipode, "p1.c:P1Antipode" },
  { "P1BARYCENTRE", 1, "list", P1BARYCENTRE, "p1.c:P1BARYCENTRE" },
  { "P1Midpoint", 2, "p1point, p1point", P1Midpoint, "p1.c:P1Midpoint" },
  { "P1Distance", 2, "p1point, p1point", P1Distance, "p1.c:P1Distance" },
  { "P1XRatio", 4, "p1point, p1point, p1point, p1point", P1XRatio, "p1.c:P1XRatio" },
  { "P1Circumcentre", 3, "p1point, p1point, p1point", P1Circumcentre, "p1.c:P1Circumcentre" },

  { "MAT2P1MAP", 1, "matrix", MAT2P1MAP, "p1.c:MAT2P1MAP" },
  { "P1MAP2MAT", 1, "p1map", P1MAP2MAT, "p1.c:P1MAP2MAT" },
  { "DegreeOfP1Map", 1, "p1map", P1MAPDEGREE, "p1.c:P1MAPDEGREE" },
  { "P1MAP2", 2, "p1point, p1point", P1MAP2, "p1.c:P1MAP2" },
  { "P1Path", 2, "p1point, p1point", P1PATH, "p1.c:P1PATH" },
  { "P1MAP3", 3, "p1point, p1point, p1point", P1MAP3, "p1.c:P1MAP3" },
  { "CleanedP1Map", 2, "p1map, float", CLEANUPP1MAP, "p1.c:CLEANUPP1MAP" },
  { "COMPOSEP1MAP", 2, "p1map, p1map", COMPOSEP1MAP, "p1.c:COMPOSEP1MAP" },
  { "INVERTP1MAP", 1, "p1map", INVERTP1MAP, "p1.c:INVERTP1MAP" },
  { "P1Image", 2, "p1map, p1point", P1IMAGE, "p1.c:P1IMAGE" },
  { "P1PreImages", 2, "p1map, p1point", P1PREIMAGES, "p1.c:P1PREIMAGES" },
  { "P1MapCriticalPoints", 1, "p1map", P1CRITICAL, "p1.c:P1CRITICAL" },
  { "P1INTERSECT", 3, "p1map, p1map, p1map", P1INTERSECT, "p1.c:P1INTERSECT" },
  { "P1ROTATION", 2, "p1points, p1points/float", P1ROTATION, "p1.c:P1ROTATION" },
  { 0 } };

void InitP1Kernel(void)
{
  InitHdlrFuncsFromTable (GVarFuncs);

  ImportGVarFromLibrary ("TYPE_P1POINT", &TYPE_P1POINT);
  ImportGVarFromLibrary ("TYPE_P1MAP", &TYPE_P1MAP);  
  ImportGVarFromLibrary ("IsP1Point", &IsP1Point);
  ImportGVarFromLibrary ("IsP1Map", &IsP1Map);
  ImportGVarFromLibrary ("Complex", &Complex);  
  ImportGVarFromLibrary ("COMPLEX_0", &COMPLEX_0);  
  ImportGVarFromLibrary ("COMPLEX_1", &COMPLEX_1);  
  ImportGVarFromLibrary ("P1infinity", &P1infinity);
}

void InitP1Library(void)
{
  InitGVarFuncsFromTable (GVarFuncs);
}

/* p1.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here */
