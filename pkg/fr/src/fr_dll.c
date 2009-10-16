/****************************************************************************
 *
 * fr_dll.c                                                 Laurent Bartholdi
 *
 *   @(#)$Id: fr_dll.c,v 1.11 2009/10/09 15:07:08 gap Exp $
 *
 * Copyright (C) 2009, Laurent Bartholdi
 *
 ****************************************************************************
 *
 * call cpoly to compute the roots of a univariate polynomial
 * call trmesh_ to construct a Delaunay triangulation
 *
 ****************************************************************************/

#include "src/compiled.h"
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_multiroots.h>

#ifdef MALLOC_HACK
#include <malloc.h>
#endif

#undef DEBUG_DELAUNAY

/****************************************************************************
 * externals
 ****************************************************************************/
int cpoly(const double *opr, const double *opi, unsigned degree, double *zeror, double *zeroi, double *heap);

#ifndef NOFORTRAN
void trmesh_ (Int4 *n, double *x, double *y, double *z,
	     Int4 *list, Int4 *lptr, Int4 *lend, Int4 *lnew,
	     Int4 *__near, Int4 *__next, double *__dist, Int4 *ier);

void crlist_ (Int4 *n, Int4 *ncol, double *x, double *y, double *z,
	      Int4 *list, Int4 *lptr, Int4 *lend, Int4 *lnew,
	      Int4 *__ltri, Int4 *__listc, Int4 *nb,
	      double *xc, double *yc, double *zc, double *rc, Int4 *ier);

void trfind_ (Int4 *nst, double *p, Int4 *n, double *x, double *y, double *z,
	      Int4 *list, Int4 *lptr, Int4 *lend,
	      double *b1, double *b2, double *b3, Int4 *i1, Int4 *i2, Int4 *i3);

void bnodes_ (Int4 *n, Int4 *list, Int4 *lptr, Int4 *lend, Int4 *nodes,
	      Int4 *nb, Int4 *na, Int4 *nt);

void addnod_ (Int4 *nst, Int4 *k, double *x, double *y, double *z,
	      Int4 *list, Int4 *lptr, Int4 *lend, Int4 *lnew, Int4 *ier);

void graph_arc_min_span_tree_ (Int4 *nnode, Int4 *nedge, Int4 *inode,
			       Int4 *jnode, double *cost, Int4 *itree,
			       Int4 *jtree, double *tree_cost);
#endif

/****************************************************************************
 * stolen from src/float.c
 ****************************************************************************/
#define VAL_FLOAT(obj) (*(double *)ADDR_OBJ(obj))
#define SIZE_FLOAT   sizeof(double)
#ifndef T_FLOAT
#define T_FLOAT T_MACFLOAT
#endif
static inline Obj NEW_FLOAT (double val)
{
  Obj f = NewBag(T_FLOAT, SIZE_FLOAT);
  *(double *)ADDR_OBJ(f) = val;
  return f;
}

static inline Obj ALLOC_PLIST (UInt len)
{
  Obj f = NEW_PLIST(T_PLIST, len);
  SET_LEN_PLIST(f, len);
  return f;
}

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

   __result = Fail;

   __result = call_bad_function();
   exit(0);
*/

#endif

/****************************************************************************
 * COMPLEX_ROOTS of polynomial (as increasing-degree list of pairs (real,imag)
 ****************************************************************************/
static Obj COMPLEX_ROOTS (Obj self, Obj coeffs)
{
  Obj result, t, heap;
  UInt i, degree, numroots;
#define opr ((double *)ADDR_OBJ(heap))
#define opi (opr+degree+1)
#define zeror (opr+2*degree+2)
#define zeroi (opr+3*degree+2)
#define cpolyheap (opr+4*degree+2)

  degree = LEN_PLIST(coeffs)-1;

  heap = NewBag(T_DATOBJ, (14*degree+12)*sizeof(double));

  for (i = 0; i <= degree; i++) {
    opr[degree-i] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(coeffs,i+1),1));
    opi[degree-i] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(coeffs,i+1),2));
  }

  numroots = cpoly (opr, opi, degree, zeror, zeroi, cpolyheap);

  if (numroots == -1)
    return Fail;

  result = ALLOC_PLIST(numroots);
  for (i = 1; i <= numroots; i++) {
    t = ALLOC_PLIST(2);
    SET_ELM_PLIST(t,1, NEW_FLOAT(zeror[i-1]));
    SET_ELM_PLIST(t,2, NEW_FLOAT(zeroi[i-1]));
    SET_ELM_PLIST(result,i, t);
  }

  return result;
}

/****************************************************************************
 * DELAUNAY_TRMESH of points on the sphere (as list of (x,y,z))
 ****************************************************************************/
#define mesh_alloc ((Int4 *)CHARS_STRING(meshdata))
/* mesh_alloc is between n and n+3 */
#define mesh_n (mesh_alloc+1)
#define mesh_tol ((double *)(mesh_n+1))
#define mesh_x (mesh_tol+1)
#define mesh_y (mesh_x+*mesh_alloc)
#define mesh_z (mesh_y+*mesh_alloc)
#define mesh_list ((Int4 *)(mesh_z+*mesh_alloc))
#define mesh_lptr (mesh_list+6*(*mesh_alloc-2))
#define mesh_lend (mesh_lptr+6*(*mesh_alloc-2))
#define mesh_lnew (mesh_lend+*mesh_alloc)
#define meshdata_size ((3*n+10)*sizeof(double)+(13*n+40)*sizeof(Int4))

#ifndef NOFORTRAN
static void xprod(double a, double b, double c,
		  double d, double e, double f,
		  double *x, double *y, double *z)
{
  *x = b*f-c*e;
  *y = c*d-a*f;
  *z = a*e-b*d;
}

static double norm (double a, double b, double c)
{
  return sqrt(a*a+b*b+c*c);
}

static void normalize(double *x, double *y, double *z)
{
  double n = norm(*x, *y, *z);
  *x /= n; *y /= n; *z /= n;
}

static void spherexprod(double a, double b, double c,
			double d, double e, double f,
			double *x, double *y, double *z)
{
  xprod (a, b, c, d, e, f, x, y, z);
  normalize (x, y, z);
}

static double sprod(double a, double b, double c,
		    double d, double e, double f)
{
  return a*d+b*e+c*f;
}

#if 0
static double tprod(double a, double b, double c,
		    double d, double e, double f,
		    double g, double h, double i)
{
  return a*e*i+b*f*g+c*d*h-a*f*h-b*d*i-c*e*g;
}
#endif

static double angle(double a, double b, double c,
		    double d, double e, double f)
{
  double x, y, g, h, i;

  x = sprod(a, b, c, d, e, f);
  xprod (a, b, c, d, e, f, &g, &h, &i);
  y = norm(g, h, i);
  return fabs(atan2(y, x)); /* more precise than acos(x) */
}
#endif

#define SWAP(x,y) { typeof(x) z; z = x; x = y; y = z; }

static Obj DELAUNAY_TRIANGULATION (Obj self, Obj gap_tol, Obj convex, Obj points)
/* creates a triangulation on <points>.
 * if <convex> then add points so as to create a convex triangulation.
 * returns a list: [[list],[lptr],[lend],[extrapoints],[bdryvertices],
 *                  [listc],[[xc,yc,zc]],[rc],,"mesh"];
 * or an integer, in case of error
 */
{
#ifdef NOFORTRAN
  ErrorQuit("No fortran compiler -- DELAUNAY_TRIANGULATION is disabled",0,0);
  return Fail;
#else
  Int4 ier;
  UInt i, j, n = LEN_PLIST(points), n0 = n;

  if (n <= 1)
    return INTOBJ_INT(-1);

  Obj meshdata = NEW_STRING(meshdata_size);

  double tol = *mesh_tol = VAL_FLOAT(gap_tol), avg_x, avg_y, avg_z;
  *mesh_alloc = n+3; /* at worst 3 extra points */
  avg_x = avg_y = avg_z = 0.0;
  for (i = 0; i < n; i++) {
    mesh_x[i] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(points,i+1),1));
    mesh_y[i] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(points,i+1),2));
    mesh_z[i] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(points,i+1),3));
    avg_x += mesh_x[i]; avg_y += mesh_y[i]; avg_z += mesh_z[i];
  }
  avg_x /= n; avg_y /= n; avg_z /= n;

#ifdef DEBUG_DELAUNAY
  printf("Points received:");
  for (i = 0; i < n; i++)
    printf(" (%lg,%lg,%lg)", mesh_x[i], mesh_y[i], mesh_z[i]);
  printf(" barycenter (%lg,%lg,%lg)\n", avg_x, avg_y, avg_z);
  fflush(stdout);
#endif

  /* we'll have to swap gap point 1 with point <pt1>, and 2 with <pt2>
     before calling the fortran routine; and back. */
  Int4 pt1 = -1, pt2 = -1;

  if (convex == True) { /* add up to 3 points to make the mesh nicer */
    double angle1 = tol;
    for (i = 1; i < n; i++) {
      double a = angle(mesh_x[0], mesh_y[0], mesh_z[0],
		       mesh_x[i], mesh_y[i], mesh_z[i]);
      if (a > M_PI/2.0) a = M_PI - a;
      if (a > angle1) /* find most orthogonal one */
	angle1 = a, pt1 = i;
    }

    if (pt1 == -1) { /* all almost aligned. add three points */
      double a, x = 0.0, y = 0.0, z = 0.0, u, v, w;

      if (fabs(mesh_x[0]) > 0.5) y = 1.0; /* at least at 30 degrees away */
      else if (fabs(mesh_y[0]) > 0.5) z = 1.0;
      else x = 1.0;
      spherexprod (mesh_x[0], mesh_y[0], mesh_z[0], x, y, z,
		   &u, &v, &w); /* (u,v,w) is orthonormal */
      spherexprod (mesh_x[0], mesh_y[0], mesh_z[0], u, v, w,
		   &x, &y, &z); /* and (x,y,z) too! */

#ifdef DEBUG_DELAUNAY
      printf("Found normal vectors (%lg,%lg,%lg) and (%lg,%lg,%lg)\n",
	     x,y,z, u,v,w);
      fflush(stdout);
#endif

      srand48(0); /* UGLY!!! we choose a direction at "random", hoping
		     the new points won't be in the way of the tree arcs.
		     (worse, we always use the same 3 values of drand48() :)) */
      for (a = drand48(), i = 0; i < 3; a += M_PI / 1.5, i++) {
	mesh_x[n] = cos(a)*x + sin(a)*u;
	mesh_y[n] = cos(a)*y + sin(a)*v;
	mesh_z[n++] = cos(a)*z + sin(a)*w;
      }
      pt1 = n-2;
      pt2 = n-1;
    } else { /* check now if points are in a plane */
      double x, y, z, angle2 = tol;

      spherexprod (mesh_x[0], mesh_y[0], mesh_z[0],
		   mesh_x[pt1], mesh_y[pt1], mesh_z[pt1],
		   &x, &y, &z);

#ifdef DEBUG_DELAUNAY
      printf("Found normal vector (%lg,%lg,%lg)\n", x,y,z);
      fflush(stdout);
#endif

      for (i = 1; i < n; i++) {
	double a = angle (x, y, z, mesh_x[i], mesh_y[i], mesh_z[i]);
	a = fabs(a - M_PI/2.0);
	if (a > angle2)
	  angle2 = a, pt2 = i;
      }

      if (pt2 == -1) { /* all points are almost orthogonal to (x,y,z) */
	double a;
	for (a = 1.0, i = 0; i < 2; a = -1.0, i++) {
	  mesh_x[n] = -avg_x+a*x;
	  mesh_y[n] = -avg_y+a*y;
	  mesh_z[n] = -avg_z+a*z;
	  normalize (mesh_x+n, mesh_y+n, mesh_z+n);
	  n++;
	}
	pt2 = n-1;
      }
    }
  } else { /* don't do anything special, when convex=False */
    pt1 = 1; pt2 = 2;
  }

  if (pt1 == 2) { pt1 = pt2; pt2 = 2; } /* so permutation is really a swap */
  if (pt2 == 1) { pt2 = pt1; pt1 = 1; }

  for (i = 1, j = pt1; i <= 2; i++, j = pt2) {
    SWAP(mesh_x[i], mesh_x[j]);
    SWAP(mesh_y[i], mesh_y[j]);
    SWAP(mesh_z[i], mesh_z[j]);
  }

  *mesh_n = n;
  Int4 delaunay_near[n], delaunay_next[n];
  double delaunay_dist[n];

#ifdef DEBUG_DELAUNAY
  printf("Points passed to trmesh:");
  for (i = 0; i < n; i++)
    printf(" (%lg,%lg,%lg)", mesh_x[i], mesh_y[i], mesh_z[i]);
  printf(" swapping points (1,%ld), (2,%ld)\n", pt1, pt2);
  fflush(stdout);
#endif

  /* create mesh of convex hull of points */
  trmesh_ (mesh_n, mesh_x, mesh_y, mesh_z,
	   mesh_list, mesh_lptr, mesh_lend, mesh_lnew,
	   delaunay_near, delaunay_next, delaunay_dist, &ier);

  if (ier != 0)
    return INTOBJ_INT(100+ier);

  for (i = 0; i < *mesh_lnew-1; i++)
    if (mesh_list[i] < 0) /* something on the boundary */
      goto foundboundary;
  goto skipboundary;

 foundboundary:
  if (convex == True) {
    mesh_x[n] = -avg_x; mesh_y[n] = -avg_y; mesh_z[n] = -avg_z;
    normalize (mesh_x+n, mesh_y+n, mesh_z+n);
#ifdef DEBUG_DELAUNAY
    printf("Adding point to make set convex: (%lg,%lg,%lg)\n",
	   mesh_x[n], mesh_y[n], mesh_z[n]);
    fflush(stdout);
#endif
    *mesh_n = ++n;
    Int4 seed = 0;
    addnod_ (&seed, mesh_n, mesh_x, mesh_y, mesh_z,
	     mesh_list, mesh_lptr, mesh_lend, mesh_lnew, &ier);
    if (ier != 0)
      return INTOBJ_INT(ier+300);
  }
 skipboundary:

  /* swap back in place */
  for (i = 0; i < *mesh_lnew-1; i++) {
    j = abs(mesh_list[i])-1;
    if (j == 1) j = pt1;
    else if (j == 2) j = pt2;
    else if (j == pt1) j = 1;
    else if (j == pt2) j = 2;
    mesh_list[i] = (mesh_list[i] < 0 ? -(1+j) : (1+j));
  }
  for (i = 1, j = pt1; i <= 2; i++, j = pt2) {
    SWAP(mesh_lend[i], mesh_lend[j]);
    SWAP(mesh_x[i], mesh_x[j]);
    SWAP(mesh_y[i], mesh_y[j]);
    SWAP(mesh_z[i], mesh_z[j]);
  }

  Obj result = ALLOC_PLIST(10);

  SET_ELM_PLIST(result, 1, ALLOC_PLIST(*mesh_lnew-1));
  for (i = 1; i < *mesh_lnew; i++) {
    SET_ELM_PLIST(ELM_PLIST(result,1), i, INTOBJ_INT(mesh_list[i-1]));
  }

  SET_ELM_PLIST(result, 2, ALLOC_PLIST(*mesh_lnew-1));
  for (i = 1; i < *mesh_lnew; i++) {
    SET_ELM_PLIST(ELM_PLIST(result,2), i, INTOBJ_INT(mesh_lptr[i-1]));
  }

  SET_ELM_PLIST(result, 3, ALLOC_PLIST(n));
  for (i = 1; i <= n; i++) {
    SET_ELM_PLIST(ELM_PLIST(result,3), i, INTOBJ_INT(mesh_lend[i-1]));
  }

  SET_ELM_PLIST(result, 4, ALLOC_PLIST(n-n0));
  for (i = n0; i < n; i++) {
    Obj t = ALLOC_PLIST(3);
    SET_ELM_PLIST(t, 1, NEW_FLOAT(mesh_x[i]));
    SET_ELM_PLIST(t, 2, NEW_FLOAT(mesh_y[i]));
    SET_ELM_PLIST(t, 3, NEW_FLOAT(mesh_z[i]));
    SET_ELM_PLIST(ELM_PLIST(result,4), 1+i-n0, t);
  }

  Int4 delaunay_bdry[n], nb, na, nt;
  bnodes_ (mesh_n, mesh_list, mesh_lptr, mesh_lend, delaunay_bdry, &nb, &na, &nt);

  SET_ELM_PLIST(result, 5, ALLOC_PLIST(nb));
  for (i = 1; i <= n; i++) {
    SET_ELM_PLIST(ELM_PLIST(result,5), i, INTOBJ_INT(delaunay_bdry[i-1]));
  }

  /* additional heap for crlist_ */
  Int4 delaunay_ltri[6*n], delaunay_listc[3*nt];
  double delaunay_xc[nt], delaunay_yc[nt], delaunay_zc[nt], delaunay_rc[nt];

  /* complete mesh to whole sphere, compute cicumcenters and triangles */
  crlist_ (mesh_n, mesh_n, mesh_x, mesh_y, mesh_z,
	   mesh_list, mesh_lend, mesh_lptr, mesh_lnew,
	   delaunay_ltri, delaunay_listc, &nb,
	   delaunay_xc, delaunay_yc, delaunay_zc, delaunay_rc, &ier);

  if (ier != 0)
    return INTOBJ_INT(200+ier);

  SET_ELM_PLIST(result, 6, ALLOC_PLIST(3*nt));
  for (i = 1; i <= 3*nt; i++) {
    SET_ELM_PLIST(ELM_PLIST(result,6), i, INTOBJ_INT(delaunay_listc[i-1]));
  }

  SET_ELM_PLIST(result, 7, ALLOC_PLIST(nt));
  for (i = 1; i <= nt; i++) {
    Obj t = ALLOC_PLIST(3);
    SET_ELM_PLIST(t, 1, NEW_FLOAT(delaunay_xc[i-1]));
    SET_ELM_PLIST(t, 2, NEW_FLOAT(delaunay_yc[i-1]));
    SET_ELM_PLIST(t, 3, NEW_FLOAT(delaunay_zc[i-1]));
    SET_ELM_PLIST(ELM_PLIST(result,7), i, t);
  }

  SET_ELM_PLIST(result, 8, ALLOC_PLIST(nt));
  for (i = 1; i <= nt; i++) {
    SET_ELM_PLIST(ELM_PLIST(result,8), i, NEW_FLOAT(delaunay_rc[i-1]));
  }

  SET_ELM_PLIST(result, 10, meshdata);

  return result;
#endif
}

static Obj DELAUNAY_FIND (Obj self, Obj meshdata, Obj gap_seed, Obj gap_point)
{
#ifdef NOFORTRAN
  ErrorQuit("No fortran compiler -- DELAUNAY_FIND is disabled",0,0);
  return Fail;
#else
  Int4 triangle[3], seed = INT_INTOBJ(gap_seed);
  Int i;
  double point[3], coord[3];

  for (i = 0; i < 3; i++)
    point[i] = VAL_FLOAT(ELM_PLIST(gap_point,i+1));

  trfind_ (&seed, point, mesh_n, mesh_x, mesh_y, mesh_z,
	   mesh_list, mesh_lptr, mesh_lend,
	   coord, coord+1, coord+2, triangle, triangle+1, triangle+2);

  Obj result = ALLOC_PLIST(2);

  SET_ELM_PLIST(result, 1, ALLOC_PLIST(3));
  for (i = 0; i < 3; i++)
    SET_ELM_PLIST(ELM_PLIST(result,1), i+1, INTOBJ_INT(triangle[i]));

  SET_ELM_PLIST(result, 2, ALLOC_PLIST(3));
  for (i = 0; i < 3; i++)
    SET_ELM_PLIST(ELM_PLIST(result,2), i+1, NEW_FLOAT(coord[i]));

  return result;
#endif
}

/****************************************************************************
 * ARC_MIN_SPAN_TREE finds a minimal spanning tree in a graph
 ****************************************************************************/
static Obj ARC_MIN_SPAN_TREE (Obj self, Obj gap_n, Obj gap_edges)
{
#ifdef NOFORTRAN
  ErrorQuit("No fortran compiler -- ARC_MIN_SPAN_TREE is disabled",0,0);
  return Fail;
#else
  Int4 n = INT_INTOBJ(gap_n), e = LEN_PLIST(gap_edges);
  UInt i;
  Int4 inode[e], jnode[e], itree[n], jtree[n];
  double cost[e], total;

  for (i = 0; i < e; i++) {
    inode[i] = INT_INTOBJ(ELM_PLIST(ELM_PLIST(gap_edges,i+1),1));
    jnode[i] = INT_INTOBJ(ELM_PLIST(ELM_PLIST(gap_edges,i+1),2));
    cost[i] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(gap_edges,i+1),3));
  }

  graph_arc_min_span_tree_ (&n, &e, inode, jnode, cost, itree, jtree, &total);

  Obj result = ALLOC_PLIST(n);
  for (i = 0; i < n-1; i++) {
    SET_ELM_PLIST(result, i+1, ALLOC_PLIST(2));
    SET_ELM_PLIST(ELM_PLIST(result,i+1), 1, INTOBJ_INT(itree[i]));
    SET_ELM_PLIST(ELM_PLIST(result,i+1), 2, INTOBJ_INT(jtree[i]));
  }
  SET_ELM_PLIST(result, n, NEW_FLOAT(total));

  return result;
#endif
}

/****************************************************************************
 * FIND_BARYCENTER finds a mobius transformation that centers points
 ****************************************************************************/
typedef struct {
  int n;
  double points[][3];
} bparams;

#ifdef MALLOC_HACK
void *old_free_hook, *old_malloc_hook;

static void *
my_malloc_hook (size_t size, const void *caller)
{
  printf ("allocating %d\n", size);
  fflush(stdout);

  return NewBag(T_DATOBJ, size + sizeof(Int));
}

static void
my_free_hook (void *ptr, const void *caller)
{
  printf ("freeing pointer %p\n", ptr);
  fflush(stdout);
}
#endif

#define bpoints (((bparams *) param)->points)

int barycenter (const gsl_vector *x, void *param, gsl_vector *f)
{
  int i, j;
  const int n = ((bparams *) param)->n;
  double v[3];

  for (i = 0; i < 3; i++) v[i] = gsl_vector_get (x, i);
  double t = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
  v[0] /= t; v[1] /= t; v[2] /= t;

  double sum[3] = { 0.0, 0.0, 0.0 };

  for (j = 0; j < n; j++) {
    double x[3], z = 0.0;

    for (i = 0; i < 3; i++)
      z += bpoints[j][i] * v[i];

    double d = 1.0 + t*t + (1.0 - t*t)*z;
    for (i = 0; i < 3; i++)
      x[i] = (2.0*t*bpoints[j][i] + (1.0-t)*(1.0+t+(1.0-t)*z)*v[i]) / d;

    for (i = 0; i < 3; i++) sum[i] += x[i];
  }

  for (i = 0; i < 3; i++) gsl_vector_set (f, i, sum[i] / n);

  return GSL_SUCCESS;
}

#define bparam ((bparams *) ADDR_OBJ(heap))
static Obj FIND_BARYCENTER (Obj self, Obj gap_points, Obj gap_init, Obj gap_iter, Obj gap_tol)
{
#ifdef MALLOC_HACK
  old_malloc_hook = __malloc_hook;
  old_free_hook = __free_hook;
  __malloc_hook = my_malloc_hook;
  __free_hook = my_free_hook;
#endif

  UInt i, j, n = LEN_PLIST(gap_points);

  Obj heap = NewBag(T_DATOBJ, 3*n*sizeof(double)+sizeof(Int));

  ((bparams *) ADDR_OBJ(heap))->n = n;

  for (i = 0; i < n; i++)
    for (j = 0; j < 3; j++)
      bparam->points[i][j] = VAL_FLOAT(ELM_PLIST(ELM_PLIST(gap_points,i+1),j+1));

  const gsl_multiroot_fsolver_type *T;
  gsl_multiroot_fsolver *s;

  int status;
  size_t iter = 0, max_iter = INT_INTOBJ(gap_iter);
  double precision = VAL_FLOAT(gap_tol);

  gsl_multiroot_function f = {&barycenter, 3, ADDR_OBJ(heap)};
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
  Obj list = ALLOC_PLIST(3); SET_ELM_PLIST(result, 1, list);
  for (i = 0; i < 3; i++)
    SET_ELM_PLIST(list, i+1, NEW_FLOAT(gsl_vector_get (s->x, i)));
  list = ALLOC_PLIST(3); SET_ELM_PLIST(result, 2, list);
  for (i = 0; i < 3; i++)
    SET_ELM_PLIST(list, i+1, NEW_FLOAT(gsl_vector_get (s->f, i)));

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
 * interface to GAP
 ****************************************************************************/
static StructGVarFunc GVarFuncs [] = {
  { "COMPLEX_ROOTS", 1, "coeffs", COMPLEX_ROOTS, "fr_dll.c:COMPLEX_ROOTS" },
  { "DELAUNAY_TRIANGULATION", 3, "tol, convex, points", DELAUNAY_TRIANGULATION, "fr_dll.c:DELAUNAY_TRIANGULATION" },
  { "DELAUNAY_FIND", 3, "data, seed, point", DELAUNAY_FIND, "fr_dll.c:DELAUNAY_FIND" },
  { "ARC_MIN_SPAN_TREE", 2, "n, edges", ARC_MIN_SPAN_TREE, "fr_dll.c:ARC_MIN_SPAN_TREE" },
  { "FIND_BARYCENTER", 4, "points, init, iter, tol", FIND_BARYCENTER, "fr_dll.c:FIND_BARYCENTER" },
  { 0 }
};

static Int InitKernel ( StructInitInfo * module )
{
  InitHdlrFuncsFromTable( GVarFuncs );
  return 0;
}

/* 'InitLibrary' sets up gvars, rnams, functions */
static Int InitLibrary ( StructInitInfo * module )
{
  InitGVarFuncsFromTable( GVarFuncs );
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
