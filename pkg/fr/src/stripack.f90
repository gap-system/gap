!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! stripack.f90                                                  Robert Renka !!
!!
!! This code is distributed under the ACM Software License Agreement,
!! see http://www.acm.org/publications/policies/softwarecrnotice
!!
!! code modified by Laurent Bartholdi, 20090310
!! changed ADDNOD and TRMESH so that they return ier rather than
!! print an error message and stop
!!
!! original file at
!! http://people.sc.fsu.edu/~burkardt/f_src/stripack/stripack.html
!!
!! @(#)$Id: stripack.f90,v 1.5 2009/03/29 01:35:24 gap Exp $
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!
subroutine addnod ( nst, k, x, y, z, list, lptr, lend, lnew, ier )

!*****************************************************************************80
!
!! ADDNOD adds a node to a triangulation.
!
!  Discussion:
!
!    This subroutine adds node K to a triangulation of the
!    convex hull of nodes 1, ..., K-1, producing a triangulation
!    of the convex hull of nodes 1, ..., K.
!
!    The algorithm consists of the following steps:  node K
!    is located relative to the triangulation (TRFIND), its
!    index is added to the data structure (INTADD or BDYADD),
!    and a sequence of swaps (SWPTST and SWAP) are applied to
!    the arcs opposite K so that all arcs incident on node K
!    and opposite node K are locally optimal (satisfy the circumcircle test).
!
!    Thus, if a Delaunay triangulation of nodes 1 through K-1 is input,
!    a Delaunay triangulation of nodes 1 through K will be output.
!
!  Modified:
!
!    15 May 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) NST, the index of a node at which TRFIND
!    begins its search.  Search time depends on the proximity of this node to
!    K.  If NST < 1, the search is begun at node K-1.
!
!    Input, integer ( kind = 4 ) K, the nodal index (index for X, Y, Z, and
!    LEND) of the new node to be added.  4 <= K.
!
!    Input, real ( kind = 8 ) X(K), Y(K), Z(K), the coordinates of the nodes.
!
!    Input/output, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(K),
!    LNEW.  On input, the data structure associated with the triangulation of
!    nodes 1 to K-1.  On output, the data has been updated to include node
!    K.  The array lengths are assumed to be large enough to add node K.
!    Refer to TRMESH.
!
!    Output, integer ( kind = 4 ) IER, error indicator:
!     0 if no errors were encountered.
!    -1 if K is outside its valid range on input.
!    -2 if all nodes (including K) are collinear (lie on a common geodesic).
!     L if nodes L and K coincide for some L < K.
!
!  Local parameters:
!
!    B1,B2,B3 = Unnormalized barycentric coordinates returned by TRFIND.
!    I1,I2,I3 = Vertex indexes of a triangle containing K
!    IN1 =      Vertex opposite K:  first neighbor of IO2
!               that precedes IO1.  IN1,IO1,IO2 are in
!               counterclockwise order.
!    IO1,IO2 =  Adjacent neighbors of K defining an arc to
!               be tested for a swap
!    IST =      Index of node at which TRFIND begins its search
!    KK =       Local copy of K
!    KM1 =      K-1
!    L =        Vertex index (I1, I2, or I3) returned in IER
!               if node K coincides with a vertex
!    LP =       LIST pointer
!    LPF =      LIST pointer to the first neighbor of K
!    LPO1 =     LIST pointer to IO1
!    LPO1S =    Saved value of LPO1
!    P =        Cartesian coordinates of node K
!
  implicit none

  integer ( kind = 4 ) k

  real    ( kind = 8 ) b1
  real    ( kind = 8 ) b2
  real    ( kind = 8 ) b3
  integer ( kind = 4 ) i1
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) i3
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) in1
  integer ( kind = 4 ) io1
  integer ( kind = 4 ) io2
  integer ( kind = 4 ) ist
  integer ( kind = 4 ) kk
  integer ( kind = 4 ) km1
  integer ( kind = 4 ) l
  integer ( kind = 4 ) lend(k)
  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpf
  integer ( kind = 4 ) lpo1
  integer ( kind = 4 ) lpo1s
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) lstptr
  integer ( kind = 4 ) nst
  real    ( kind = 8 ) p(3)
  logical              swptst
  real    ( kind = 8 ) x(k)
  real    ( kind = 8 ) y(k)
  real    ( kind = 8 ) z(k)

  kk = k

  if ( kk < 4 ) then
    ier = -1
    return
  end if
!
!  Initialization:
!
  km1 = kk - 1
  ist = nst
  if ( ist < 1 ) then
    ist = km1
  end if

  p(1) = x(kk)
  p(2) = y(kk)
  p(3) = z(kk)
!
!  Find a triangle (I1,I2,I3) containing K or the rightmost
!  (I1) and leftmost (I2) visible boundary nodes as viewed
!  from node K.
!
  call trfind ( ist, p, km1, x, y, z, list, lptr, lend, b1, b2, b3, &
    i1, i2, i3 )
!
!  Test for collinear or duplicate nodes.
!
  if ( i1 == 0 ) then
    ier = -2
    return
  end if

  if ( i3 /= 0 ) then

    l = i1

    if ( p(1) == x(l) .and. p(2) == y(l)  .and. p(3) == z(l) ) then
      ier = l
      return
    end if

    l = i2

    if ( p(1) == x(l) .and. p(2) == y(l)  .and. p(3) == z(l) ) then
      ier = l
      return
    end if

    l = i3
    if ( p(1) == x(l) .and. p(2) == y(l)  .and. p(3) == z(l) ) then
      ier = l
      return
    end if

    call intadd ( kk, i1, i2, i3, list, lptr, lend, lnew )

  else

    if ( i1 /= i2 ) then
      call bdyadd ( kk, i1,i2, list, lptr, lend, lnew )
    else
      call covsph ( kk, i1, list, lptr, lend, lnew )
    end if

  end if

  ier = 0
!
!  Initialize variables for optimization of the triangulation.
!
  lp = lend(kk)
  lpf = lptr(lp)
  io2 = list(lpf)
  lpo1 = lptr(lpf)
  io1 = abs ( list(lpo1) )
!
!  Begin loop: find the node opposite K.
!
  do

    lp = lstptr ( lend(io1), io2, list, lptr )

    if ( 0 <= list(lp) ) then

      lp = lptr(lp)
      in1 = abs ( list(lp) )
!
!  Swap test:  if a swap occurs, two new arcs are
!  opposite K and must be tested.
!
      lpo1s = lpo1

      if ( .not. swptst ( in1, kk, io1, io2, x, y, z ) ) then

        if ( lpo1 == lpf .or. list(lpo1) < 0 ) then
          exit
        end if

        io2 = io1
        lpo1 = lptr(lpo1)
        io1 = abs ( list(lpo1) )
        cycle

      end if

      call swap ( in1, kk, io1, io2, list, lptr, lend, lpo1 )
!
!  A swap is not possible because KK and IN1 are already
!  adjacent.  This error in SWPTST only occurs in the
!  neutral case and when there are nearly duplicate nodes.
!
      if ( lpo1 /= 0 ) then
        io1 = in1
        cycle
      end if

      lpo1 = lpo1s

    end if
!
!  No swap occurred.  Test for termination and reset IO2 and IO1.
!
    if ( lpo1 == lpf .or. list(lpo1) < 0 ) then
      exit
    end if

    io2 = io1
    lpo1 = lptr(lpo1)
    io1 = abs ( list(lpo1) )

  end do

  return
end
function arc_cosine ( c )

!*****************************************************************************80
!
!! ARC_COSINE computes the arc cosine function, with argument truncation.
!
!  Discussion:
!
!    If you call your system ACOS routine with an input argument that is
!    outside the range [-1.0, 1.0 ], you may get an unpleasant surprise.
!    This routine truncates arguments outside the range.
!
!  Modified:
!
!    02 December 2000
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) C, the argument.
!
!    Output, real ( kind = 8 ) ARC_COSINE, an angle whose cosine is C.
!
  implicit none

  real    ( kind = 8 ) arc_cosine
  real    ( kind = 8 ) c
  real    ( kind = 8 ) c2

  c2 = c
  c2 = max ( c2, -1.0D+00 )
  c2 = min ( c2, +1.0D+00 )

  arc_cosine = acos ( c2 )

  return
end
function areas ( v1, v2, v3 )

!*****************************************************************************80
!
!! AREAS computes the area of a spherical triangle on the unit sphere.
!
!  Discussion:
!
!    This function returns the area of a spherical triangle
!    on the unit sphere.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) V1(3), V2(3), V3(3), the Cartesian coordinates
!    of unit vectors (the three triangle vertices in any order).  These
!    vectors, if nonzero, are implicitly scaled to have length 1.
!
!    Output, real ( kind = 8 ) AREAS, the area of the spherical triangle
!    defined by V1, V2, and V3, in the range 0 to 2*PI (the area of a
!    hemisphere).  AREAS = 0 (or 2*PI) if and only if V1, V2, and V3 lie in (or
!    close to) a plane containing the origin.
!
!  Local parameters:
!
!    A1,A2,A3 =    Interior angles of the spherical triangle.
!
!    CA1,CA2,CA3 = cos(A1), cos(A2), and cos(A3), respectively.
!
!    DV1,DV2,DV3 = Double Precision copies of V1, V2, and V3.
!
!    I =           DO-loop index and index for Uij.
!
!    S12,S23,S31 = Sum of squared components of U12, U23, U31.
!
!    U12,U23,U31 = Unit normal vectors to the planes defined by
!                 pairs of triangle vertices.
!
  implicit none

  real    ( kind = 8 ) a1
  real    ( kind = 8 ) a2
  real    ( kind = 8 ) a3
  real    ( kind = 8 ) areas
  real    ( kind = 8 ) ca1
  real    ( kind = 8 ) ca2
  real    ( kind = 8 ) ca3
  real    ( kind = 8 ) dv1(3)
  real    ( kind = 8 ) dv2(3)
  real    ( kind = 8 ) dv3(3)
  real    ( kind = 8 ) s12
  real    ( kind = 8 ) s23
  real    ( kind = 8 ) s31
  real    ( kind = 8 ) u12(3)
  real    ( kind = 8 ) u23(3)
  real    ( kind = 8 ) u31(3)
  real    ( kind = 8 ) v1(3)
  real    ( kind = 8 ) v2(3)
  real    ( kind = 8 ) v3(3)

  dv1(1:3) = v1(1:3)
  dv2(1:3) = v2(1:3)
  dv3(1:3) = v3(1:3)
!
!  Compute cross products Uij = Vi X Vj.
!
  u12(1) = dv1(2) * dv2(3) - dv1(3) * dv2(2)
  u12(2) = dv1(3) * dv2(1) - dv1(1) * dv2(3)
  u12(3) = dv1(1) * dv2(2) - dv1(2) * dv2(1)

  u23(1) = dv2(2) * dv3(3) - dv2(3) * dv3(2)
  u23(2) = dv2(3) * dv3(1) - dv2(1) * dv3(3)
  u23(3) = dv2(1) * dv3(2) - dv2(2) * dv3(1)

  u31(1) = dv3(2) * dv1(3) - dv3(3) * dv1(2)
  u31(2) = dv3(3) * dv1(1) - dv3(1) * dv1(3)
  u31(3) = dv3(1) * dv1(2) - dv3(2) * dv1(1)
!
!  Normalize Uij to unit vectors.
!
  s12 = dot_product ( u12(1:3), u12(1:3) )
  s23 = dot_product ( u23(1:3), u23(1:3) )
  s31 = dot_product ( u31(1:3), u31(1:3) )
!
!  Test for a degenerate triangle associated with collinear vertices.
!
  if ( s12 == 0.0D+00 .or. s23 == 0.0D+00 .or. s31 == 0.0D+00 ) then
    areas = 0.0D+00
    return
  end if

  s12 = sqrt ( s12 )
  s23 = sqrt ( s23 )
  s31 = sqrt ( s31 )

  u12(1:3) = u12(1:3) / s12
  u23(1:3) = u23(1:3) / s23
  u31(1:3) = u31(1:3) / s31
!
!  Compute interior angles Ai as the dihedral angles between planes:
!  CA1 = cos(A1) = -<U12,U31>
!  CA2 = cos(A2) = -<U23,U12>
!  CA3 = cos(A3) = -<U31,U23>
!
  ca1 = - dot_product ( u12(1:3), u31(1:3) )
  ca2 = - dot_product ( u23(1:3), u12(1:3) )
  ca3 = - dot_product ( u31(1:3), u23(1:3) )

  ca1 = max ( ca1, -1.0D+00 )
  ca1 = min ( ca1, +1.0D+00 )
  ca2 = max ( ca2, -1.0D+00 )
  ca2 = min ( ca2, +1.0D+00 )
  ca3 = max ( ca3, -1.0D+00 )
  ca3 = min ( ca3, +1.0D+00 )

  a1 = acos ( ca1 )
  a2 = acos ( ca2 )
  a3 = acos ( ca3 )
!
!  Compute AREAS = A1 + A2 + A3 - PI.
!
  areas = a1 + a2 + a3 - acos ( -1.0D+00 )

  if ( areas < 0.0D+00 ) then
    areas = 0.0D+00
  end if

  return
end
subroutine bdyadd ( kk, i1, i2, list, lptr, lend, lnew )

!*****************************************************************************80
!
!! BDYADD adds a boundary node to a triangulation.
!
!  Discussion:
!
!    This subroutine adds a boundary node to a triangulation
!    of a set of KK-1 points on the unit sphere.  The data
!    structure is updated with the insertion of node KK, but no
!    optimization is performed.
!
!    This routine is identical to the similarly named routine
!    in TRIPACK.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) KK, the index of a node to be connected to
!    the sequence of all visible boundary nodes.  1 <= KK and
!    KK must not be equal to I1 or I2.
!
!    Input, integer ( kind = 4 ) I1, the first (rightmost as viewed from KK)
!    boundary node in the triangulation that is visible from
!    node KK (the line segment KK-I1 intersects no arcs.
!
!    Input, integer ( kind = 4 ) I2, the last (leftmost) boundary node that
!    is visible from node KK.  I1 and I2 may be determined by TRFIND.
!
!    Input/output, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N),
!    LNEW, the triangulation data structure created by TRMESH.
!    Nodes I1 and I2 must be included
!    in the triangulation.  On output, the data structure is updated with
!    the addition of node KK.  Node KK is connected to I1, I2, and
!    all boundary nodes in between.
!
!  Local parameters:
!
!    K =     Local copy of KK
!    LP =    LIST pointer
!    LSAV =  LIST pointer
!    N1,N2 = Local copies of I1 and I2, respectively
!    NEXT =  Boundary node visible from K
!    NSAV =  Boundary node visible from K
!
  implicit none

  integer ( kind = 4 ) i1
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) k
  integer ( kind = 4 ) kk
  integer ( kind = 4 ) lend(*)
  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) lsav
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) next
  integer ( kind = 4 ) nsav

  k = kk
  n1 = i1
  n2 = i2
!
!  Add K as the last neighbor of N1.
!
  lp = lend(n1)
  lsav = lptr(lp)
  lptr(lp) = lnew
  list(lnew) = -k
  lptr(lnew) = lsav
  lend(n1) = lnew
  lnew = lnew + 1
  next = -list(lp)
  list(lp) = next
  nsav = next
!
!  Loop on the remaining boundary nodes between N1 and N2,
!  adding K as the first neighbor.
!
  do

    lp = lend(next)
    call insert ( k, lp, list, lptr, lnew )

    if ( next == n2 ) then
      exit
    end if

    next = -list(lp)
    list(lp) = next

  end do
!
!  Add the boundary nodes between N1 and N2 as neighbors of node K.
!
  lsav = lnew
  list(lnew) = n1
  lptr(lnew) = lnew + 1
  lnew = lnew + 1
  next = nsav

  do

    if ( next == n2 ) then
      exit
    end if

    list(lnew) = next
    lptr(lnew) = lnew + 1
    lnew = lnew + 1
    lp = lend(next)
    next = list(lp)

  end do

  list(lnew) = -n2
  lptr(lnew) = lsav
  lend(k) = lnew
  lnew = lnew + 1

  return
end
subroutine bnodes ( n, list, lptr, lend, nodes, nb, na, nt )

!*****************************************************************************80
!
!! BNODES returns the boundary nodes of a triangulation.
!
!  Discussion:
!
!    Given a triangulation of N nodes on the unit sphere created by TRMESH,
!    this subroutine returns an array containing the indexes (if any) of
!    the counterclockwise sequence of boundary nodes, that is, the nodes on
!    the boundary of the convex hull of the set of nodes.  The
!    boundary is empty if the nodes do not lie in a single
!    hemisphere.  The numbers of boundary nodes, arcs, and
!    triangles are also returned.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    3 <= N.
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N), the
!    data structure defining the triangulation, created by TRMESH.
!
!    Output, integer ( kind = 4 ) NODES(*), the ordered sequence of NB boundary
!    node indexes in the range 1 to N.  For safety, the dimension of NODES
!    should be N.
!
!    Output, integer ( kind = 4 ) NB, the number of boundary nodes.
!
!    Output, integer ( kind = 4 ) NA, NT, the number of arcs and triangles,
!    respectively, in the triangulation.
!
!  Local parameters:
!
!    K =   NODES index
!    LP =  LIST pointer
!    N0 =  Boundary node to be added to NODES
!    NN =  Local copy of N
!    NST = First element of nodes (arbitrarily chosen to be
!          the one with smallest index)
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) i
  integer ( kind = 4 ) k
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) n0
  integer ( kind = 4 ) na
  integer ( kind = 4 ) nb
  integer ( kind = 4 ) nn
  integer ( kind = 4 ) nodes(*)
  integer ( kind = 4 ) nst
  integer ( kind = 4 ) nt

  nn = n
!
!  Search for a boundary node.
!
  nst = 0

  do i = 1, nn

    lp = lend(i)

    if ( list(lp) < 0 ) then
      nst = i
      exit
    end if

  end do
!
!  The triangulation contains no boundary nodes.
!
  if ( nst == 0 ) then
    nb = 0
    na = 3 * ( nn - 2 )
    nt = 2 * ( nn - 2 )
    return
  end if
!
!  NST is the first boundary node encountered.
!
!  Initialize for traversal of the boundary.
!
  nodes(1) = nst
  k = 1
  n0 = nst
!
!  Traverse the boundary in counterclockwise order.
!
  do

    lp = lend(n0)
    lp = lptr(lp)
    n0 = list(lp)

    if ( n0 == nst ) then
      exit
    end if

    k = k + 1
    nodes(k) = n0

  end do
!
!  Store the counts.
!
  nb = k
  nt = 2 * n - nb - 2
  na = nt + n - 1

  return
end
subroutine circum ( v1, v2, v3, c, ier )

!*****************************************************************************80
!
!! CIRCUM returns the circumcenter of a spherical triangle.
!
!  Discussion:
!
!    This subroutine returns the circumcenter of a spherical triangle on the
!    unit sphere:  the point on the sphere surface that is equally distant
!    from the three triangle vertices and lies in the same hemisphere, where
!    distance is taken to be arc-length on the sphere surface.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) V1(3), V2(3), V3(3), the coordinates of the
!    three triangle vertices (unit vectors) in counter clockwise order.
!
!    Output, real ( kind = 8 ) C(3), the coordinates of the circumcenter unless
!    0 < IER, in which case C is not defined.  C = (V2-V1) X (V3-V1)
!    normalized to a unit vector.
!
!    Output, integer ( kind = 4 ) IER = Error indicator:
!    0, if no errors were encountered.
!    1, if V1, V2, and V3 lie on a common line:  (V2-V1) X (V3-V1) = 0.
!
!  Local parameters:
!
!    CNORM = Norm of CU:  used to compute C
!    CU =    Scalar multiple of C:  E1 X E2
!    E1,E2 = Edges of the underlying planar triangle:
!            V2-V1 and V3-V1, respectively
!    I =     DO-loop index
!
  implicit none

  real    ( kind = 8 ) c(3)
  real    ( kind = 8 ) cnorm
  real    ( kind = 8 ) cu(3)
  real    ( kind = 8 ) e1(3)
  real    ( kind = 8 ) e2(3)
  integer ( kind = 4 ) ier
  real    ( kind = 8 ) v1(3)
  real    ( kind = 8 ) v2(3)
  real    ( kind = 8 ) v3(3)

  ier = 0

  e1(1:3) = v2(1:3) - v1(1:3)
  e2(1:3) = v3(1:3) - v1(1:3)
!
!  Compute CU = E1 X E2 and CNORM**2.
!
  cu(1) = e1(2) * e2(3) - e1(3) * e2(2)
  cu(2) = e1(3) * e2(1) - e1(1) * e2(3)
  cu(3) = e1(1) * e2(2) - e1(2) * e2(1)

  cnorm = sqrt ( sum ( cu(1:3)**2 ) )
!
!  The vertices lie on a common line if and only if CU is the zero vector.
!
  if ( cnorm == 0.0D+00 ) then
    ier = 1
    return
  end if

  c(1:3) = cu(1:3) / cnorm

  return
end
subroutine covsph ( kk, n0, list, lptr, lend, lnew )

!*****************************************************************************80
!
!! COVSPH connects an exterior node to boundary nodes, covering the sphere.
!
!  Discussion:
!
!    This subroutine connects an exterior node KK to all
!    boundary nodes of a triangulation of KK-1 points on the
!    unit sphere, producing a triangulation that covers the
!    sphere.  The data structure is updated with the addition
!    of node KK, but no optimization is performed.  All
!    boundary nodes must be visible from node KK.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) KK = Index of the node to be connected to the
!    set of all boundary nodes.  4 <= KK.
!
!    Input, integer ( kind = 4 ) N0 = Index of a boundary node (in the range
!    1 to KK-1).  N0 may be determined by TRFIND.
!
!    Input/output, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N),
!    LNEW, the triangulation data structure created by TRMESH.  Node N0 must
!    be included in the triangulation.  On output, updated with the addition
!    of node KK as the last entry.  The updated triangulation contains no
!    boundary nodes.
!
!  Local parameters:
!
!    K =     Local copy of KK
!    LP =    LIST pointer
!    LSAV =  LIST pointer
!    NEXT =  Boundary node visible from K
!    NST =   Local copy of N0
!
  implicit none

  integer ( kind = 4 ) k
  integer ( kind = 4 ) kk
  integer ( kind = 4 ) lend(*)
  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) lsav
  integer ( kind = 4 ) n0
  integer ( kind = 4 ) next
  integer ( kind = 4 ) nst

  k = kk
  nst = n0
!
!  Traverse the boundary in clockwise order, inserting K as
!  the first neighbor of each boundary node, and converting
!  the boundary node to an interior node.
!
  next = nst

  do

    lp = lend(next)
    call insert ( k, lp, list, lptr, lnew )
    next = -list(lp)
    list(lp) = next

    if ( next == nst ) then
      exit
    end if

  end do
!
!  Traverse the boundary again, adding each node to K's adjacency list.
!
  lsav = lnew

  do

    lp = lend(next)
    list(lnew) = next
    lptr(lnew) = lnew + 1
    lnew = lnew + 1
    next = list(lp)

    if ( next == nst ) then
      exit
    end if

  end do

  lptr(lnew-1) = lsav
  lend(k) = lnew - 1

  return
end
subroutine crlist ( n, ncol, x, y, z, list, lend, lptr, lnew, &
  ltri, listc, nb, xc, yc, zc, rc, ier )

!*****************************************************************************80
!
!! CRLIST returns triangle circumcenters and other information.
!
!  Discussion:
!
!    Given a Delaunay triangulation of nodes on the surface
!    of the unit sphere, this subroutine returns the set of
!    triangle circumcenters corresponding to Voronoi vertices,
!    along with the circumradii and a list of triangle indexes
!    LISTC stored in one-to-one correspondence with LIST/LPTR
!    entries.
!
!    A triangle circumcenter is the point (unit vector) lying
!    at the same angular distance from the three vertices and
!    contained in the same hemisphere as the vertices.  (Note
!    that the negative of a circumcenter is also equidistant
!    from the vertices.)  If the triangulation covers the
!    surface, the Voronoi vertices are the circumcenters of the
!    triangles in the Delaunay triangulation.  LPTR, LEND, and
!    LNEW are not altered in this case.
!
!    On the other hand, if the nodes are contained in a
!    single hemisphere, the triangulation is implicitly extended
!    to the entire surface by adding pseudo-arcs (of length
!    greater than 180 degrees) between boundary nodes forming
!    pseudo-triangles whose 'circumcenters' are included in the
!    list.  This extension to the triangulation actually
!    consists of a triangulation of the set of boundary nodes in
!    which the swap test is reversed (a non-empty circumcircle
!    test).  The negative circumcenters are stored as the
!    pseudo-triangle 'circumcenters'.  LISTC, LPTR, LEND, and
!    LNEW contain a data structure corresponding to the
!    extended triangulation (Voronoi diagram), but LIST is not
!    altered in this case.  Thus, if it is necessary to retain
!    the original (unextended) triangulation data structure,
!    copies of LPTR and LNEW must be saved before calling this
!    routine.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    3 <= N.  Note that, if N = 3, there are only two Voronoi vertices
!    separated by 180 degrees, and the Voronoi regions are not well defined.
!
!    Input, integer ( kind = 4 ) NCOL, the number of columns reserved for LTRI.
!    This must be at least NB-2, where NB is the number of boundary nodes.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates of the nodes
!    (unit vectors).
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), the set of adjacency lists.
!    Refer to TRMESH.
!
!    Input, integer ( kind = 4 ) LEND(N), the set of pointers to ends of
!    adjacency lists.  Refer to TRMESH.
!
!    Input/output, integer ( kind = 4 ) LPTR(6*(N-2)), pointers associated
!    with LIST.  Refer to TRMESH.  On output, pointers associated with LISTC.
!    Updated for the addition of pseudo-triangles if the original triangulation
!    contains boundary nodes (0 < NB).
!
!    Input/output, integer ( kind = 4 ) LNEW.  On input, a pointer to the first
!    empty location in LIST and LPTR (list length plus one).  On output,
!    pointer to the first empty location in LISTC and LPTR (list length plus
!    one).  LNEW is not altered if NB = 0.
!
!    Output, integer ( kind = 4 ) LTRI(6,NCOL).  Triangle list whose first NB-2
!    columns contain the indexes of a clockwise-ordered sequence of vertices
!    (first three rows) followed by the LTRI column indexes of the triangles
!    opposite the vertices (or 0 denoting the exterior region) in the last
!    three rows. This array is not generally of any further use outside this
!    routine.
!
!    Output, integer ( kind = 4 ) LISTC(3*NT), where NT = 2*N-4 is the number
!    of triangles in the triangulation (after extending it to cover the entire
!    surface if necessary).  Contains the triangle indexes (indexes to XC, YC,
!    ZC, and RC) stored in 1-1 correspondence with LIST/LPTR entries (or entries
!    that would be stored in LIST for the extended triangulation):  the index
!    of triangle (N1,N2,N3) is stored in LISTC(K), LISTC(L), and LISTC(M),
!    where LIST(K), LIST(L), and LIST(M) are the indexes of N2 as a neighbor
!    of N1, N3 as a neighbor of N2, and N1 as a neighbor of N3.  The Voronoi
!    region associated with a node is defined by the CCW-ordered sequence of
!    circumcenters in one-to-one correspondence with its adjacency
!    list (in the extended triangulation).
!
!    Output, integer ( kind = 4 ) NB, the number of boundary nodes unless
!    IER = 1.
!
!    Output, real ( kind = 8 ) XC(2*N-4), YC(2*N-4), ZC(2*N-4), the coordinates
!    of the triangle circumcenters (Voronoi vertices).  XC(I)**2 + YC(I)**2
!    + ZC(I)**2 = 1.  The first NB-2 entries correspond to pseudo-triangles
!    if 0 < NB.
!
!    Output, real ( kind = 8 ) RC(2*N-4), the circumradii (the arc lengths or
!    angles between the circumcenters and associated triangle vertices) in
!    1-1 correspondence with circumcenters.
!
!    Output, integer ( kind = 4 ) IER = Error indicator:
!    0, if no errors were encountered.
!    1, if N < 3.
!    2, if NCOL < NB-2.
!    3, if a triangle is degenerate (has vertices lying on a common geodesic).
!
!  Local parameters:
!
!    C =         Circumcenter returned by Subroutine CIRCUM
!    I1,I2,I3 =  Permutation of (1,2,3):  LTRI row indexes
!    I4 =        LTRI row index in the range 1 to 3
!    IERR =      Error flag for calls to CIRCUM
!    KT =        Triangle index
!    KT1,KT2 =   Indexes of a pair of adjacent pseudo-triangles
!    KT11,KT12 = Indexes of the pseudo-triangles opposite N1
!                and N2 as vertices of KT1
!    KT21,KT22 = Indexes of the pseudo-triangles opposite N1
!                and N2 as vertices of KT2
!    LP,LPN =    LIST pointers
!    LPL =       LIST pointer of the last neighbor of N1
!    N0 =        Index of the first boundary node (initial
!                value of N1) in the loop on boundary nodes
!                used to store the pseudo-triangle indexes
!                in LISTC
!    N1,N2,N3 =  Nodal indexes defining a triangle (CCW order)
!                or pseudo-triangle (clockwise order)
!    N4 =        Index of the node opposite N2 -> N1
!    NM2 =       N-2
!    NN =        Local copy of N
!    NT =        Number of pseudo-triangles:  NB-2
!    SWP =       Logical variable set to TRUE in each optimization
!                loop (loop on pseudo-arcs) iff a swap is performed.
!
!    V1,V2,V3 =  Vertices of triangle KT = (N1,N2,N3) sent to subroutine
!                CIRCUM
!
  implicit none

  integer ( kind = 4 ) n
  integer ( kind = 4 ) ncol

  real    ( kind = 8 ) c(3)
  integer ( kind = 4 ) i1
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) i3
  integer ( kind = 4 ) i4
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) ierr
  integer ( kind = 4 ) kt
  integer ( kind = 4 ) kt1
  integer ( kind = 4 ) kt11
  integer ( kind = 4 ) kt12
  integer ( kind = 4 ) kt2
  integer ( kind = 4 ) kt21
  integer ( kind = 4 ) kt22
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) listc(6*(n-2))
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lpn
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) lstptr
  integer ( kind = 4 ) ltri(6,ncol)
  integer ( kind = 4 ) n0
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) n3
  integer ( kind = 4 ) n4
  integer ( kind = 4 ) nb
  integer ( kind = 4 ) nm2
  integer ( kind = 4 ) nn
  integer ( kind = 4 ) nt
  real    ( kind = 8 ) rc(2*n-4)
  logical swp
  logical swptst
  real    ( kind = 8 ) t
  real    ( kind = 8 ) v1(3)
  real    ( kind = 8 ) v2(3)
  real    ( kind = 8 ) v3(3)
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) xc(2*n-4)
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) yc(2*n-4)
  real    ( kind = 8 ) z(n)
  real    ( kind = 8 ) zc(2*n-4)

  nn = n
  nb = 0
  nt = 0

  if ( nn < 3 ) then
    ier = 1
    return
  end if
!
!  Search for a boundary node N1.
!
  lp = 0

  do n1 = 1, nn

    if ( list(lend(n1)) < 0 ) then
      lp = lend(n1)
      exit
    end if

  end do
!
!  The triangulation already covers the sphere.
!
  if ( lp == 0 ) then
    go to 9
  end if
!
!  There are 3 <= NB boundary nodes.  Add NB-2 pseudo-triangles (N1,N2,N3)
!  by connecting N3 to the NB-3 boundary nodes to which it is not
!  already adjacent.
!
!  Set N3 and N2 to the first and last neighbors,
!  respectively, of N1.
!
  n2 = -list(lp)
  lp = lptr(lp)
  n3 = list(lp)
!
!  Loop on boundary arcs N1 -> N2 in clockwise order,
!  storing triangles (N1,N2,N3) in column NT of LTRI
!  along with the indexes of the triangles opposite
!  the vertices.
!
  do

    nt = nt + 1

    if ( nt <= ncol ) then
      ltri(1,nt) = n1
      ltri(2,nt) = n2
      ltri(3,nt) = n3
      ltri(4,nt) = nt + 1
      ltri(5,nt) = nt - 1
      ltri(6,nt) = 0
    end if

    n1 = n2
    lp = lend(n1)
    n2 = -list(lp)

    if ( n2 == n3 ) then
      exit
    end if

  end do

  nb = nt + 2

  if ( ncol < nt ) then
    ier = 2
    return
  end if

  ltri(4,nt) = 0
!
!  Optimize the exterior triangulation (set of pseudo-
!  triangles) by applying swaps to the pseudo-arcs N1-N2
!  (pairs of adjacent pseudo-triangles KT1 and KT1 < KT2).
!  The loop on pseudo-arcs is repeated until no swaps are
!  performed.
!
  if ( nt /= 1 ) then

    do

      swp = .false.

      do kt1 = 1, nt-1

        do i3 = 1, 3

          kt2 = ltri(i3+3,kt1)

          if ( kt2 <= kt1 ) then
            cycle
          end if
!
!  The LTRI row indexes (I1,I2,I3) of triangle KT1 =
!  (N1,N2,N3) are a cyclical permutation of (1,2,3).
!
          if ( i3 == 1 ) then
            i1 = 2
            i2 = 3
          else if ( i3 == 2 ) then
            i1 = 3
            i2 = 1
          else
            i1 = 1
            i2 = 2
          end if

          n1 = ltri(i1,kt1)
          n2 = ltri(i2,kt1)
          n3 = ltri(i3,kt1)
!
!  KT2 = (N2,N1,N4) for N4 = LTRI(I,KT2), where LTRI(I+3,KT2) = KT1.
!
          if ( ltri(4,kt2) == kt1 ) then
            i4 = 1
          else if ( ltri(5,kt2 ) == kt1 ) then
            i4 = 2
          else
            i4 = 3
          end if

          n4 = ltri(i4,kt2)
!
!  The empty circumcircle test is reversed for the pseudo-
!  triangles.  The reversal is implicit in the clockwise
!  ordering of the vertices.
!
          if ( .not. swptst ( n1, n2, n3, n4, x, y, z ) ) then
            cycle
          end if
!
!  Swap arc N1-N2 for N3-N4.  KTij is the triangle opposite
!  Nj as a vertex of KTi.
!
          swp = .true.
          kt11 = ltri(i1+3,kt1)
          kt12 = ltri(i2+3,kt1)

          if ( i4 == 1 ) then
            i2 = 2
            i1 = 3
          else if ( i4 == 2 ) then
            i2 = 3
            i1 = 1
          else
            i2 = 1
            i1 = 2
          end if

          kt21 = ltri(i1+3,kt2)
          kt22 = ltri(i2+3,kt2)
          ltri(1,kt1) = n4
          ltri(2,kt1) = n3
          ltri(3,kt1) = n1
          ltri(4,kt1) = kt12
          ltri(5,kt1) = kt22
          ltri(6,kt1) = kt2
          ltri(1,kt2) = n3
          ltri(2,kt2) = n4
          ltri(3,kt2) = n2
          ltri(4,kt2) = kt21
          ltri(5,kt2) = kt11
          ltri(6,kt2) = kt1
!
!  Correct the KT11 and KT22 entries that changed.
!
          if ( kt11 /= 0 ) then
            i4 = 4
            if ( ltri(4,kt11) /= kt1 ) then
              i4 = 5
              if ( ltri(5,kt11) /= kt1 ) i4 = 6
            end if
            ltri(i4,kt11) = kt2
          end if

          if ( kt22 /= 0 ) then
            i4 = 4
            if ( ltri(4,kt22) /= kt2 ) then
              i4 = 5
              if ( ltri(5,kt22) /= kt2 ) then
                i4 = 6
              end if
            end if
            ltri(i4,kt22) = kt1
          end if

        end do

      end do

      if ( .not. swp ) then
        exit
      end if

    end do

  end if
!
!  Compute and store the negative circumcenters and radii of
!  the pseudo-triangles in the first NT positions.
!
  do kt = 1, nt

    n1 = ltri(1,kt)
    n2 = ltri(2,kt)
    n3 = ltri(3,kt)
    v1(1) = x(n1)
    v1(2) = y(n1)
    v1(3) = z(n1)
    v2(1) = x(n2)
    v2(2) = y(n2)
    v2(3) = z(n2)
    v3(1) = x(n3)
    v3(2) = y(n3)
    v3(3) = z(n3)

    call circum ( v1, v2, v3, c, ierr )

    if ( ierr /= 0 ) then
      ier = 3
      return
    end if
!
!  Store the negative circumcenter and radius (computed from <V1,C>).
!
    xc(kt) = c(1)
    yc(kt) = c(2)
    zc(kt) = c(3)

    t = dot_product ( v1(1:3), c(1:3) )
    t = max ( t, -1.0D+00 )
    t = min ( t, +1.0D+00 )

    rc(kt) = acos(t)

  end do
!
!  Compute and store the circumcenters and radii of the
!  actual triangles in positions KT = NT+1, NT+2, ...
!
!  Also, store the triangle indexes KT in the appropriate LISTC positions.
!
9 continue

  kt = nt
!
!  Loop on nodes N1.
!
  nm2 = nn - 2

  do n1 = 1, nm2

    lpl = lend(n1)
    lp = lpl
    n3 = list(lp)
!
!  Loop on adjacent neighbors N2,N3 of N1 for which N1 < N2 and N1 < N3.
!
    do

      lp = lptr(lp)
      n2 = n3
      n3 = abs ( list(lp) )

      if ( n1 < n2 .and. n1 < n3 ) then

        kt = kt + 1
!
!  Compute the circumcenter C of triangle KT = (N1,N2,N3).
!
        v1(1) = x(n1)
        v1(2) = y(n1)
        v1(3) = z(n1)
        v2(1) = x(n2)
        v2(2) = y(n2)
        v2(3) = z(n2)
        v3(1) = x(n3)
        v3(2) = y(n3)
        v3(3) = z(n3)

        call circum ( v1, v2, v3, c, ierr )

        if ( ierr /= 0 ) then
          ier = 3
          return
        end if
!
!  Store the circumcenter, radius and triangle index.
!
        xc(kt) = c(1)
        yc(kt) = c(2)
        zc(kt) = c(3)

        t = dot_product ( v1(1:3), c(1:3) )
        t = max ( t, -1.0D+00 )
        t = min ( t, +1.0D+00 )

        rc(kt) = acos(t)
!
!  Store KT in LISTC(LPN), where abs ( LIST(LPN) ) is the
!  index of N2 as a neighbor of N1, N3 as a neighbor
!  of N2, and N1 as a neighbor of N3.
!
        lpn = lstptr ( lpl, n2, list, lptr )
        listc(lpn) = kt
        lpn = lstptr ( lend(n2), n3, list, lptr )
        listc(lpn) = kt
        lpn = lstptr ( lend(n3), n1, list, lptr )
        listc(lpn) = kt

      end if

      if ( lp == lpl ) then
        exit
      end if

    end do

  end do

  if ( nt == 0 ) then
    ier = 0
    return
  end if
!
!  Store the first NT triangle indexes in LISTC.
!
!  Find a boundary triangle KT1 = (N1,N2,N3) with a boundary arc opposite N3.
!
  kt1 = 0

  do

    kt1 = kt1 + 1

    if ( ltri(4,kt1) == 0 ) then
      i1 = 2
      i2 = 3
      i3 = 1
      exit
    else if ( ltri(5,kt1) == 0 ) then
      i1 = 3
      i2 = 1
      i3 = 2
      exit
    else if ( ltri(6,kt1) == 0 ) then
      i1 = 1
      i2 = 2
      i3 = 3
      exit
    end if

  end do

  n1 = ltri(i1,kt1)
  n0 = n1
!
!  Loop on boundary nodes N1 in CCW order, storing the
!  indexes of the clockwise-ordered sequence of triangles
!  that contain N1.  The first triangle overwrites the
!  last neighbor position, and the remaining triangles,
!  if any, are appended to N1's adjacency list.
!
!  A pointer to the first neighbor of N1 is saved in LPN.
!
  do

    lp = lend(n1)
    lpn = lptr(lp)
    listc(lp) = kt1
!
!  Loop on triangles KT2 containing N1.
!
    do

      kt2 = ltri(i2+3,kt1)

      if ( kt2 == 0 ) then
        exit
      end if
!
!  Append KT2 to N1's triangle list.
!
      lptr(lp) = lnew
      lp = lnew
      listc(lp) = kt2
      lnew = lnew + 1
!
!  Set KT1 to KT2 and update (I1,I2,I3) such that LTRI(I1,KT1) = N1.
!
      kt1 = kt2

      if ( ltri(1,kt1) == n1 ) then
        i1 = 1
        i2 = 2
        i3 = 3
      else if ( ltri(2,kt1) == n1 ) then
        i1 = 2
        i2 = 3
        i3 = 1
      else
        i1 = 3
        i2 = 1
        i3 = 2
      end if

    end do
!
!  Store the saved first-triangle pointer in LPTR(LP), set
!  N1 to the next boundary node, test for termination,
!  and permute the indexes:  the last triangle containing
!  a boundary node is the first triangle containing the
!  next boundary node.
!
    lptr(lp) = lpn
    n1 = ltri(i3,kt1)

    if ( n1 == n0 ) then
      exit
    end if

    i4 = i3
    i3 = i2
    i2 = i1
    i1 = i4

  end do

  ier = 0

  return
end
subroutine delarc ( n, io1, io2, list, lptr, lend, lnew, ier )

!*****************************************************************************80
!
!! DELARC deletes a boundary arc from a triangulation.
!
!  Discussion:
!
!    This subroutine deletes a boundary arc from a triangulation
!    It may be used to remove a null triangle from the
!    convex hull boundary.  Note, however, that if the union of
!    triangles is rendered nonconvex, subroutines DELNOD, EDGE,
!    and TRFIND (and hence ADDNOD) may fail.  Also, function
!    NEARND should not be called following an arc deletion.
!
!    This routine is identical to the similarly named routine in TRIPACK.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    4 <= N.
!
!    Input, integer ( kind = 4 ) IO1, IO2, indexes (in the range 1 to N) of
!    a pair of adjacent boundary nodes defining the arc to be removed.
!
!    Input/output, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N),
!    LNEW, the triangulation data structure created by TRMESH.  On output,
!    updated with the removal of arc IO1-IO2 unless 0 < IER.
!
!    Output, integer ( kind = 4 ) IER, error indicator:
!    0, if no errors were encountered.
!    1, if N, IO1, or IO2 is outside its valid range, or IO1 = IO2.
!    2, if IO1-IO2 is not a boundary arc.
!    3, if the node opposite IO1-IO2 is already a boundary node, and thus IO1
!      or IO2 has only two neighbors or a deletion would result in two
!      triangulations sharing a single node.
!    4, if one of the nodes is a neighbor of the other, but not vice versa,
!      implying an invalid triangulation data structure.
!
!  Local parameters:
!
!    LP =       LIST pointer
!    LPH =      LIST pointer or flag returned by DELNB
!    LPL =      Pointer to the last neighbor of N1, N2, or N3
!    N1,N2,N3 = Nodal indexes of a triangle such that N1->N2
!               is the directed boundary edge associated with IO1-IO2
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) ier
  integer ( kind = 4 ) io1
  integer ( kind = 4 ) io2
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lph
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) lstptr
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) n3

  n1 = io1
  n2 = io2
!
!  Test for errors.
!
  if ( n < 4 ) then
    ier = 1
    return
  end if

  if ( n1 < 1 ) then
    ier = 1
    return
  end if

  if ( n < n1 ) then
    ier = 1
    return
  end if

  if ( n2 < 1 ) then
    ier = 1
    return
  end if

  if ( n < n2 ) then
    ier = 1
    return
  end if

  if ( n1 == n2 ) then
    ier = 1
    return
  end if
!
!  Set N1->N2 to the directed boundary edge associated with IO1-IO2:
!  (N1,N2,N3) is a triangle for some N3.
!
  lpl = lend(n2)

  if ( -list(lpl) /= n1 ) then
    n1 = n2
    n2 = io1
    lpl = lend(n2)
    if ( -list(lpl) /= n1 ) then
      ier = 2
      return
    end if
  end if
!
!  Set N3 to the node opposite N1->N2 (the second neighbor
!  of N1), and test for error 3 (N3 already a boundary node).
!
  lpl = lend(n1)
  lp = lptr(lpl)
  lp = lptr(lp)
  n3 = abs ( list(lp) )
  lpl = lend(n3)

  if ( list(lpl) <= 0 ) then
    ier = 3
    return
  end if
!
!  Delete N2 as a neighbor of N1, making N3 the first
!  neighbor, and test for error 4 (N2 not a neighbor
!  of N1).  Note that previously computed pointers may
!  no longer be valid following the call to DELNB.
!
  call delnb ( n1, n2, n, list, lptr, lend, lnew, lph )

  if ( lph < 0 ) then
    ier = 4
    return
  end if
!
!  Delete N1 as a neighbor of N2, making N3 the new last neighbor.
!
  call delnb ( n2, n1, n, list, lptr, lend, lnew, lph )
!
!  Make N3 a boundary node with first neighbor N2 and last neighbor N1.
!
  lp = lstptr ( lend(n3), n1, list, lptr )
  lend(n3) = lp
  list(lp) = -n1
!
!  No errors encountered.
!
  ier = 0

  return
end
subroutine delnb ( n0, nb, n, list, lptr, lend, lnew, lph )

!*****************************************************************************80
!
!! DELNB deletes a neighbor from the adjacency list.
!
!  Discussion:
!
!    This subroutine deletes a neighbor NB from the adjacency
!    list of node N0 (but N0 is not deleted from the adjacency
!    list of NB) and, if NB is a boundary node, makes N0 a
!    boundary node.
!
!    For pointer (LIST index) LPH to NB as a neighbor of N0, the empty
!    LIST, LPTR location LPH is filled in with the values at LNEW-1,
!    pointer LNEW-1 (in LPTR and possibly in LEND) is changed to LPH,
!    and LNEW is decremented.
!
!    This requires a search of LEND and LPTR entailing an
!    expected operation count of O(N).
!
!    This routine is identical to the similarly named routine in TRIPACK.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka,
!    Department of Computer Science,
!    University of North Texas,
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N0, NB, indexes, in the range 1 to N, of a
!    pair of nodes such that NB is a neighbor of N0.  (N0 need not be a
!    neighbor of NB.)
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    3 <= N.
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N), LNEW,
!    the data structure defining the triangulation.  On output, updated with
!    the removal of NB from the adjacency list of N0 unless LPH < 0.
!
!    Input, integer ( kind = 4 ) LPH, list pointer to the hole (NB as a
!    neighbor of N0) filled in by the values at LNEW-1 or error indicator:
!    >  0, if no errors were encountered.
!    = -1, if N0, NB, or N is outside its valid range.
!    = -2, if NB is not a neighbor of N0.
!
!  Local parameters:
!
!    I =   DO-loop index
!    LNW = LNEW-1 (output value of LNEW)
!    LP =  LIST pointer of the last neighbor of NB
!    LPB = Pointer to NB as a neighbor of N0
!    LPL = Pointer to the last neighbor of N0
!    LPP = Pointer to the neighbor of N0 that precedes NB
!    NN =  Local copy of N
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) i
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lnw
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpb
  integer ( kind = 4 ) lph
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lpp
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) n0
  integer ( kind = 4 ) nb
  integer ( kind = 4 ) nn

  nn = n
!
!  Test for error 1.
!
  if ( n0 < 1 ) then
    lph = -1
    return
  end if

  if ( nn < n0 .or. nb < 1  .or. &
      nn < nb .or. nn < 3 ) then
    lph = -1
    return
  end if
!
!  Find pointers to neighbors of N0:
!
!  LPL points to the last neighbor,
!  LPP points to the neighbor NP preceding NB, and
!  LPB points to NB.
!
  lpl = lend(n0)
  lpp = lpl
  lpb = lptr(lpp)

  do

    if ( list(lpb) == nb ) then
      go to 2
    end if

    lpp = lpb
    lpb = lptr(lpp)

    if ( lpb == lpl ) then
      exit
    end if

  end do
!
!  Test for error 2 (NB not found).
!
  if ( abs ( list(lpb) ) /= nb ) then
    lph = -2
    return
  end if
!
!  NB is the last neighbor of N0.  Make NP the new last
!  neighbor and, if NB is a boundary node, then make N0
!  a boundary node.
!
  lend(n0) = lpp
  lp = lend(nb)

  if ( list(lp) < 0 ) then
    list(lpp) = -list(lpp)
  end if

  go to 3
!
!  NB is not the last neighbor of N0.  If NB is a boundary
!  node and N0 is not, then make N0 a boundary node with
!  last neighbor NP.
!
2 continue

  lp = lend(nb)

  if ( list(lp) < 0 .and. 0 < list(lpl) ) then
    lend(n0) = lpp
    list(lpp) = -list(lpp)
  end if
!
!  Update LPTR so that the neighbor following NB now follows
!  NP, and fill in the hole at location LPB.
!
3 continue

  lptr(lpp) = lptr(lpb)
  lnw = lnew-1
  list(lpb) = list(lnw)
  lptr(lpb) = lptr(lnw)

  do i = nn, 1, -1
    if ( lend(i) == lnw ) then
      lend(i) = lpb
      exit
    end if
  end do

  do i = 1, lnw-1
    if ( lptr(i) == lnw ) then
      lptr(i) = lpb
    end if
  end do
!
!  No errors encountered.
!
  lnew = lnw
  lph = lpb

  return
end
subroutine delnod ( k, n, x, y, z, list, lptr, lend, lnew, lwk, iwk, ier )

!*****************************************************************************80
!
!! DELNOD deletes a node from a triangulation.
!
!  Discussion:
!
!    This subroutine deletes node K (along with all arcs incident on node K)
!    from a triangulation of N nodes on the unit sphere, and inserts arcs as
!    necessary to produce a triangulation of the remaining N-1 nodes.  If a
!    Delaunay triangulation is input, a Delaunay triangulation will result,
!    and thus, DELNOD reverses the effect of a call to ADDNOD.
!
!    Note that the deletion may result in all remaining nodes
!    being collinear.  This situation is not flagged.
!
!  Modified:
!
!    17 June 2002
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) K, index (for X, Y, and Z) of the node to be
!    deleted.  1 <= K <= N.
!
!    Input/output, integer ( kind = 4 ) N, the number of nodes in the
!    triangulation.  4 <= N.  Note that N will be decremented following the
!    deletion.
!
!    Input/output, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates of
!    the nodes in the triangulation.  On output, updated with elements
!    K+1,...,N+1 shifted up one position, thus overwriting element K,
!    unless 1 <= IER <= 4.
!
!    Input/output, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N),
!    LNEW, the data structure defining the triangulation, created by TRMESH.
!    On output, updated to reflect the deletion unless 1 <= IER <= 4.
!    Note that the data structure may have been altered if 3 < IER.
!
!    Input/output, integer ( kind = 4 ) LWK, the number of columns reserved for
!    IWK.  LWK must be at least NNB-3, where NNB is the number of neighbors of
!    node K, including an extra pseudo-node if K is a boundary node.
!    On output, the number of IWK columns required unless IER = 1 or IER = 3.
!
!    Output, integer ( kind = 4 ) IWK(2,LWK), indexes of the endpoints of the
!    new arcs added unless LWK = 0 or 1 <= IER <= 4.  (Arcs are associated with
!    columns.)
!
!    Output, integer ( kind = 4 ) IER, error indicator:
!    0, if no errors were encountered.
!    1, if K or N is outside its valid range or LWK < 0 on input.
!    2, if more space is required in IWK.  Refer to LWK.
!    3, if the triangulation data structure is invalid on input.
!    4, if K indexes an interior node with four or more neighbors, none of
!      which can be swapped out due to collinearity, and K cannot therefore
!      be deleted.
!    5, if an error flag (other than IER = 1) was returned by OPTIM.  An error
!      message is written to the standard output unit in this case.
!    6, if error flag 1 was returned by OPTIM.  This is not necessarily an
!      error, but the arcs may not be optimal.
!
!  Local parameters:
!
!    BDRY =    Logical variable with value TRUE iff N1 is a boundary node
!    I,J =     DO-loop indexes
!    IERR =    Error flag returned by OPTIM
!    IWL =     Number of IWK columns containing arcs
!    LNW =     Local copy of LNEW
!    LP =      LIST pointer
!    LP21 =    LIST pointer returned by SWAP
!    LPF,LPL = Pointers to the first and last neighbors of N1
!    LPH =     Pointer (or flag) returned by DELNB
!    LPL2 =    Pointer to the last neighbor of N2
!    LPN =     Pointer to a neighbor of N1
!    LWKL =    Input value of LWK
!    N1 =      Local copy of K
!    N2 =      Neighbor of N1
!    NFRST =   First neighbor of N1:  LIST(LPF)
!    NIT =     Number of iterations in OPTIM
!    NR,NL =   Neighbors of N1 preceding (to the right of) and
!              following (to the left of) N2, respectively
!    NN =      Number of nodes in the triangulation
!    NNB =     Number of neighbors of N1 (including a pseudo-
!              node representing the boundary if N1 is a
!              boundary node)
!    X1,Y1,Z1 = Coordinates of N1
!    X2,Y2,Z2 = Coordinates of N2
!    XL,YL,ZL = Coordinates of NL
!    XR,YR,ZR = Coordinates of NR
!
  implicit none

  integer ( kind = 4 ) n

  logical bdry
  integer ( kind = 4 ) i
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) ierr
  integer ( kind = 4 ) iwk(2,*)
  integer ( kind = 4 ) iwl
  integer ( kind = 4 ) j
  integer ( kind = 4 ) k
  logical left
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lnw
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lp21
  integer ( kind = 4 ) lpf
  integer ( kind = 4 ) lph
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lpl2
  integer ( kind = 4 ) lpn
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) lstptr
  integer ( kind = 4 ) lwk
  integer ( kind = 4 ) lwkl
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) nbcnt
  integer ( kind = 4 ) nfrst
  integer ( kind = 4 ) nit
  integer ( kind = 4 ) nl
  integer ( kind = 4 ) nn
  integer ( kind = 4 ) nnb
  integer ( kind = 4 ) nr
  real    ( kind = 8 ) x(*)
  real    ( kind = 8 ) x1
  real    ( kind = 8 ) x2
  real    ( kind = 8 ) xl
  real    ( kind = 8 ) xr
  real    ( kind = 8 ) y(*)
  real    ( kind = 8 ) y1
  real    ( kind = 8 ) y2
  real    ( kind = 8 ) yl
  real    ( kind = 8 ) yr
  real    ( kind = 8 ) z(*)
  real    ( kind = 8 ) z1
  real    ( kind = 8 ) z2
  real    ( kind = 8 ) zl
  real    ( kind = 8 ) zr
!
!  Set N1 to K and NNB to the number of neighbors of N1 (plus
!  one if N1 is a boundary node), and test for errors.  LPF
!  and LPL are LIST indexes of the first and last neighbors
!  of N1, IWL is the number of IWK columns containing arcs,
!  and BDRY is TRUE iff N1 is a boundary node.
!
  n1 = k
  nn = n

  if ( n1 < 1 ) then
    ier = 1
    return
  end if

  if ( nn < n1 ) then
    ier = 1
    return
  end if

  if ( nn < 4 ) then
    ier = 1
    return
  end if

  if ( lwk < 0 ) then
    ier = 1
    return
  end if

  lpl = lend(n1)
  lpf = lptr(lpl)
  nnb = nbcnt(lpl,lptr)
  bdry = list(lpl) < 0

  if ( bdry ) then
    nnb = nnb + 1
  end if

  if ( nnb < 3 ) then
    ier = 3
    return
  end if

  lwkl = lwk
  lwk = nnb - 3

  if ( lwkl < lwk ) then
    ier = 2
    return
  end if

  iwl = 0

  if ( nnb == 3 ) then
    go to 3
  end if
!
!  Initialize for loop on arcs N1-N2 for neighbors N2 of N1,
!  beginning with the second neighbor.  NR and NL are the
!  neighbors preceding and following N2, respectively, and
!  LP indexes NL.  The loop is exited when all possible
!  swaps have been applied to arcs incident on N1.
!
  x1 = x(n1)
  y1 = y(n1)
  z1 = z(n1)
  nfrst = list(lpf)
  nr = nfrst
  xr = x(nr)
  yr = y(nr)
  zr = z(nr)
  lp = lptr(lpf)
  n2 = list(lp)
  x2 = x(n2)
  y2 = y(n2)
  z2 = z(n2)
  lp = lptr(lp)
!
!  Top of loop:  set NL to the neighbor following N2.
!
  do

    nl = abs ( list(lp) )

    if ( nl == nfrst .and. bdry ) then
      exit
    end if

    xl = x(nl)
    yl = y(nl)
    zl = z(nl)
!
!  Test for a convex quadrilateral.  To avoid an incorrect
!  test caused by collinearity, use the fact that if N1
!  is a boundary node, then N1 LEFT NR->NL and if N2 is
!  a boundary node, then N2 LEFT NL->NR.
!
    lpl2 = lend(n2)
!
!  Nonconvex quadrilateral -- no swap is possible.
!
    if ( .not. ((bdry .or. left(xr,yr,zr,xl,yl,zl,x1,y1, &
        z1)) .and. (list(lpl2) < 0  .or. &
        left(xl,yl,zl,xr,yr,zr,x2,y2,z2))) ) then
      nr = n2
      xr = x2
      yr = y2
      zr = z2
      go to 2
    end if
!
!  The quadrilateral defined by adjacent triangles
!  (N1,N2,NL) and (N2,N1,NR) is convex.  Swap in
!  NL-NR and store it in IWK unless NL and NR are
!  already adjacent, in which case the swap is not
!  possible.  Indexes larger than N1 must be decremented
!  since N1 will be deleted from X, Y, and Z.
!
    call swap ( nl, nr, n1, n2, list, lptr, lend, lp21 )

    if ( lp21 == 0 ) then
      nr = n2
      xr = x2
      yr = y2
      zr = z2
      go to 2
    end if

    iwl = iwl + 1

    if ( nl <= n1 ) then
      iwk(1,iwl) = nl
    else
      iwk(1,iwl) = nl - 1
    end if

    if ( nr <= n1 ) then
      iwk(2,iwl) = nr
    else
      iwk(2,iwl) = nr - 1
    end if
!
!  Recompute the LIST indexes and NFRST, and decrement NNB.
!
    lpl = lend(n1)
    nnb = nnb - 1

    if ( nnb == 3 ) then
      exit
    end if

    lpf = lptr(lpl)
    nfrst = list(lpf)
    lp = lstptr ( lpl, nl, list, lptr )
!
!  NR is not the first neighbor of N1.
!  Back up and test N1-NR for a swap again:  Set N2 to
!  NR and NR to the previous neighbor of N1 -- the
!  neighbor of NR which follows N1.  LP21 points to NL
!  as a neighbor of NR.
!
    if ( nr /= nfrst ) then

      n2 = nr
      x2 = xr
      y2 = yr
      z2 = zr
      lp21 = lptr(lp21)
      lp21 = lptr(lp21)
      nr = abs ( list(lp21) )
      xr = x(nr)
      yr = y(nr)
      zr = z(nr)
      cycle

    end if
!
!  Bottom of loop -- test for termination of loop.
!
2   continue

    if ( n2 == nfrst ) then
      exit
    end if

    n2 = nl
    x2 = xl
    y2 = yl
    z2 = zl
    lp = lptr(lp)

  end do
!
!  Delete N1 and all its incident arcs.  If N1 is an interior
!  node and either 3 < NNB or NNB = 3 and N2 LEFT NR->NL,
!  then N1 must be separated from its neighbors by a plane
!  containing the origin -- its removal reverses the effect
!  of a call to COVSPH, and all its neighbors become
!  boundary nodes.  This is achieved by treating it as if
!  it were a boundary node (setting BDRY to TRUE, changing
!  a sign in LIST, and incrementing NNB).
!
3   continue

  if ( .not. bdry ) then

    if ( 3 < nnb ) then
      bdry = .true.
    else
      lpf = lptr(lpl)
      nr = list(lpf)
      lp = lptr(lpf)
      n2 = list(lp)
      nl = list(lpl)
      bdry = left ( x(nr), y(nr), z(nr), x(nl), y(nl), z(nl), &
        x(n2), y(n2), z(n2) )
    end if
!
!  If a boundary node already exists, then N1 and its
!  neighbors cannot be converted to boundary nodes.
!  (They must be collinear.)  This is a problem if 3 < NNB.
!
    if ( bdry ) then

      do i = 1, nn
        if ( list(lend(i)) < 0 ) then
          bdry = .false.
          go to 5
        end if
      end do

      list(lpl) = -list(lpl)
      nnb = nnb + 1

    end if

  end if

5 continue

  if ( .not. bdry .and. 3 < nnb ) then
    ier = 4
    return
  end if
!
!  Initialize for loop on neighbors.  LPL points to the last
!  neighbor of N1.  LNEW is stored in local variable LNW.
!
  lp = lpl
  lnw = lnew
!
!  Loop on neighbors N2 of N1, beginning with the first.
!
6   continue

    lp = lptr(lp)
    n2 = abs ( list(lp) )

    call delnb ( n2, n1, n, list, lptr, lend, lnw, lph )

    if ( lph < 0 ) then
      ier = 3
      return
    end if
!
!  LP and LPL may require alteration.
!
    if ( lpl == lnw ) then
      lpl = lph
    end if

    if ( lp == lnw ) then
      lp = lph
    end if

    if ( lp /= lpl ) then
      go to 6
    end if
!
!  Delete N1 from X, Y, Z, and LEND, and remove its adjacency
!  list from LIST and LPTR.  LIST entries (nodal indexes)
!  which are larger than N1 must be decremented.
!
  nn = nn - 1

  if ( nn < n1 ) then
    go to 9
  end if

  do i = n1, nn
    x(i) = x(i+1)
    y(i) = y(i+1)
    z(i) = z(i+1)
    lend(i) = lend(i+1)
  end do

  do i = 1, lnw-1

    if ( n1 < list(i) ) then
      list(i) = list(i) - 1
    end if

    if ( list(i) < -n1 ) then
      list(i) = list(i) + 1
    end if

  end do
!
!  For LPN = first to last neighbors of N1, delete the
!  preceding neighbor (indexed by LP).
!
!  Each empty LIST,LPTR location LP is filled in with the
!  values at LNW-1, and LNW is decremented.  All pointers
!  (including those in LPTR and LEND) with value LNW-1
!  must be changed to LP.
!
!  LPL points to the last neighbor of N1.
!
9 continue

  if ( bdry ) then
    nnb = nnb - 1
  end if

  lpn = lpl

  do j = 1, nnb

    lnw = lnw - 1
    lp = lpn
    lpn = lptr(lp)
    list(lp) = list(lnw)
    lptr(lp) = lptr(lnw)

    if ( lptr(lpn) == lnw ) then
      lptr(lpn) = lp
    end if

    if ( lpn == lnw ) then
      lpn = lp
    end if

    do i = nn, 1, -1
      if ( lend(i) == lnw ) then
        lend(i) = lp
        exit
      end if
    end do

    do i = lnw-1, 1, -1
      if ( lptr(i) == lnw ) then
        lptr(i) = lp
      end if
    end do

  end do
!
!  Update N and LNEW, and optimize the patch of triangles
!  containing K (on input) by applying swaps to the arcs in IWK.
!
  n = nn
  lnew = lnw

  if ( 0 < iwl ) then

    nit = 4 * iwl

    call optim ( x, y, z, iwl, list, lptr, lend, nit, iwk, ierr )

    if ( ierr /= 0 .and. ierr /= 1 ) then
      ier = 5
      return
    end if

    if ( ierr == 1 ) then
      ier = 6
      return
    end if

  end if

  ier = 0

  return
end
subroutine edge ( in1, in2, x, y, z, lwk, iwk, list, lptr, lend, ier )

!*****************************************************************************80
!
!! EDGE swaps arcs to force two nodes to be adjacent.
!
!  Discussion:
!
!    Given a triangulation of N nodes and a pair of nodal
!    indexes IN1 and IN2, this routine swaps arcs as necessary
!    to force IN1 and IN2 to be adjacent.  Only arcs which
!    intersect IN1-IN2 are swapped out.  If a Delaunay triangu-
!    lation is input, the resulting triangulation is as close
!    as possible to a Delaunay triangulation in the sense that
!    all arcs other than IN1-IN2 are locally optimal.
!
!    A sequence of calls to EDGE may be used to force the
!    presence of a set of edges defining the boundary of a
!    non-convex and/or multiply connected region, or to introduce
!    barriers into the triangulation.  Note that
!    GETNP will not necessarily return closest nodes if the
!    triangulation has been constrained by a call to EDGE.
!    However, this is appropriate in some applications, such
!    as triangle-based interpolation on a nonconvex domain.
!
!  Modified:
!
!    17 June 2002
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) IN1, IN2, indexes (of X, Y, and Z) in the
!    range 1 to N defining a pair of nodes to be connected by an arc.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates of the nodes.
!
!    Input/output, integer ( kind = 4 ) LWK.  On input, the number of columns
!    reserved for IWK.  This must be at least NI, the number of arcs that
!    intersect IN1-IN2.  (NI is bounded by N-3.)   On output, the number of
!    arcs which intersect IN1-IN2 (but not more than the input value of LWK)
!    unless IER = 1 or IER = 3.  LWK = 0 if and only if IN1 and IN2 were
!    adjacent (or LWK=0) on input.
!
!    Output, integer ( kind = 4 ) IWK(2*LWK), the indexes of the endpoints of
!    the new arcs other than IN1-IN2 unless 0 < IER or LWK = 0.  New arcs to
!    the left of IN1->IN2 are stored in the first K-1 columns (left portion
!    of IWK), column K contains zeros, and new arcs to the right of IN1->IN2
!    occupy columns K+1,...,LWK.  (K can be determined by searching IWK
!    for the zeros.)
!
!    Input/output, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N),
!    the data structure defining the triangulation, created by TRMESH.  On
!    output, updated if necessary to reflect the presence of an arc connecting
!    IN1 and IN2 unless 0 < IER.  The data structure has been altered if
!    4 <= IER.
!
!    Output, integer ( kind = 4 ) IER, error indicator:
!    0, if no errors were encountered.
!    1, if IN1 < 1, IN2 < 1, IN1 = IN2, or LWK < 0 on input.
!    2, if more space is required in IWK.  Refer to LWK.
!    3, if IN1 and IN2 could not be connected due to either an invalid
!      data structure or collinear nodes (and floating point error).
!    4, if an error flag other than IER = 1 was returned by OPTIM.
!    5, if error flag 1 was returned by OPTIM.  This is not necessarily
!      an error, but the arcs other than IN1-IN2 may not be optimal.
!
!  Local parameters:
!
!    DPij =     Dot product <Ni,Nj>
!    I =        DO-loop index and column index for IWK
!    IERR =     Error flag returned by Subroutine OPTIM
!    IWC =      IWK index between IWF and IWL -- NL->NR is
!               stored in IWK(1,IWC)->IWK(2,IWC)
!    IWCP1 =    IWC + 1
!    IWEND =    Input or output value of LWK
!    IWF =      IWK (column) index of the first (leftmost) arc
!               which intersects IN1->IN2
!    IWL =      IWK (column) index of the last (rightmost) are
!               which intersects IN1->IN2
!    LFT =      Flag used to determine if a swap results in the
!               new arc intersecting IN1-IN2 -- LFT = 0 iff
!               N0 = IN1, LFT = -1 implies N0 LEFT IN1->IN2,
!               and LFT = 1 implies N0 LEFT IN2->IN1
!    LP =       List pointer (index for LIST and LPTR)
!    LP21 =     Unused parameter returned by SWAP
!    LPL =      Pointer to the last neighbor of IN1 or NL
!    N0 =       Neighbor of N1 or node opposite NR->NL
!    N1,N2 =    Local copies of IN1 and IN2
!    N1FRST =   First neighbor of IN1
!    N1LST =    (Signed) last neighbor of IN1
!    NEXT =     Node opposite NL->NR
!    NIT =      Flag or number of iterations employed by OPTIM
!    NL,NR =    Endpoints of an arc which intersects IN1-IN2
!               with NL LEFT IN1->IN2
!    X0,Y0,Z0 = Coordinates of N0
!    X1,Y1,Z1 = Coordinates of IN1
!    X2,Y2,Z2 = Coordinates of IN2
!
  implicit none

  real    ( kind = 8 ) dp12
  real    ( kind = 8 ) dp1l
  real    ( kind = 8 ) dp1r
  real    ( kind = 8 ) dp2l
  real    ( kind = 8 ) dp2r
  integer ( kind = 4 ) i
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) ierr
  integer ( kind = 4 ) in1
  integer ( kind = 4 ) in2
  integer ( kind = 4 ) iwc
  integer ( kind = 4 ) iwcp1
  integer ( kind = 4 ) iwend
  integer ( kind = 4 ) iwf
  integer ( kind = 4 ) iwk(2,*)
  integer ( kind = 4 ) iwl
  logical left
  integer ( kind = 4 ) lend(*)
  integer ( kind = 4 ) lft
  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lp21
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) lwk
  integer ( kind = 4 ) n0
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n1frst
  integer ( kind = 4 ) n1lst
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) next
  integer ( kind = 4 ) nit
  integer ( kind = 4 ) nl
  integer ( kind = 4 ) nr
  real    ( kind = 8 ) x(*)
  real    ( kind = 8 ) x0
  real    ( kind = 8 ) x1
  real    ( kind = 8 ) x2
  real    ( kind = 8 ) y(*)
  real    ( kind = 8 ) y0
  real    ( kind = 8 ) y1
  real    ( kind = 8 ) y2
  real    ( kind = 8 ) z(*)
  real    ( kind = 8 ) z0
  real    ( kind = 8 ) z1
  real    ( kind = 8 ) z2
!
!  Store IN1, IN2, and LWK in local variables and test for errors.
!
  n1 = in1
  n2 = in2
  iwend = lwk

  if ( n1 < 1 .or. n2 < 1 .or. n1 == n2  .or. iwend < 0 ) then
    ier = 1
    return
  end if
!
!  Test for N2 as a neighbor of N1.  LPL points to the last neighbor of N1.
!
  lpl = lend(n1)
  n0 = abs ( list(lpl) )
  lp = lpl

  do

    if ( n0 == n2 ) then
      ier = 0
      return
    end if

    lp = lptr(lp)
    n0 = list(lp)

    if ( lp == lpl ) then
      exit
    end if

  end do
!
!  Initialize parameters.
!
  iwl = 0
  nit = 0
!
!  Store the coordinates of N1 and N2.
!
  do

    x1 = x(n1)
    y1 = y(n1)
    z1 = z(n1)

    x2 = x(n2)
    y2 = y(n2)
    z2 = z(n2)
!
!  Set NR and NL to adjacent neighbors of N1 such that
!  NR LEFT N2->N1 and NL LEFT N1->N2,
!  (NR Forward N1->N2 or NL Forward N1->N2), and
!  (NR Forward N2->N1 or NL Forward N2->N1).
!
!  Initialization:  Set N1FRST and N1LST to the first and
!  (signed) last neighbors of N1, respectively, and
!  initialize NL to N1FRST.
!
    lpl = lend(n1)
    n1lst = list(lpl)
    lp = lptr(lpl)
    n1frst = list(lp)
    nl = n1frst

    if ( n1lst < 0 ) then
      go to 4
    end if
!
!  N1 is an interior node.  Set NL to the first candidate
!  for NR (NL LEFT N2->N1).
!
    do

      if ( left ( x2, y2, z2, x1, y1, z1, x(nl), y(nl), z(nl) ) ) then
        go to 4
      end if

      lp = lptr(lp)
      nl = list(lp)

      if ( nl == n1frst ) then
        exit
      end if

    end do
!
!  All neighbors of N1 are strictly left of N1->N2.
!
    go to 5
!
!  NL = LIST(LP) LEFT N2->N1.  Set NR to NL and NL to the
!  following neighbor of N1.
!
4   continue

    do

      nr = nl
      lp = lptr(lp)
      nl = abs ( list(lp) )
!
!  NL LEFT N1->N2 and NR LEFT N2->N1.  The Forward tests
!  are employed to avoid an error associated with
!  collinear nodes.
!
      if ( left ( x1, y1, z1, x2, y2, z2, x(nl), y(nl), z(nl) ) ) then

        dp12 = x1 * x2 + y1 * y2 + z1 * z2
        dp1l = x1 * x(nl) + y1 * y(nl) + z1 * z(nl)
        dp2l = x2 * x(nl) + y2 * y(nl) + z2 * z(nl)
        dp1r = x1 * x(nr) + y1 * y(nr) + z1 * z(nr)
        dp2r = x2 * x(nr) + y2 * y(nr) + z2 * z(nr)

        if ( ( 0.0D+00 <= dp2l - dp12 * dp1l .or. &
               0.0D+00 <= dp2r - dp12 * dp1r )  .and. &
             ( 0.0D+00 <= dp1l - dp12 * dp2l .or.  &
               0.0D+00 <= dp1r - dp12 * dp2r ) ) then
          go to 6
        end if
!
!  NL-NR does not intersect N1-N2.  However, there is
!  another candidate for the first arc if NL lies on
!  the line N1-N2.
!
        if ( .not. left ( x2, y2, z2, x1, y1, z1, x(nl), y(nl), z(nl) ) ) then
          exit
        end if

      end if
!
!  Bottom of loop.
!
      if ( nl == n1frst ) then
        exit
      end if

    end do
!
!  Either the triangulation is invalid or N1-N2 lies on the
!  convex hull boundary and an edge NR->NL (opposite N1 and
!  intersecting N1-N2) was not found due to floating point
!  error.  Try interchanging N1 and N2 -- NIT > 0 iff this
!  has already been done.
!
5   continue

    if ( 0 < nit ) then
      ier = 3
      return
    end if

    nit = 1
    call i4_swap ( n1, n2 )

  end do
!
!  Store the ordered sequence of intersecting edges NL->NR in
!  IWK(1,IWL)->IWK(2,IWL).
!
6 continue

  iwl = iwl + 1

  if ( iwend < iwl ) then
    ier = 2
    return
  end if

  iwk(1,iwl) = nl
  iwk(2,iwl) = nr
!
!  Set NEXT to the neighbor of NL which follows NR.
!
  lpl = lend(nl)
  lp = lptr(lpl)
!
!  Find NR as a neighbor of NL.  The search begins with the first neighbor.
!
  do

    if ( list(lp) == nr ) then
      go to 8
    end if

    lp = lptr(lp)

    if ( lp == lpl ) then
      exit
    end if

  end do
!
!  NR must be the last neighbor, and NL->NR cannot be a boundary edge.
!
  if ( list(lp) /= nr ) then
    ier = 3
    return
  end if
!
!  Set NEXT to the neighbor following NR, and test for
!  termination of the store loop.
!
8 continue

  lp = lptr(lp)
  next = abs ( list(lp) )
!
!  Set NL or NR to NEXT.
!
  if ( next /= n2 ) then

    if ( left ( x1, y1, z1, x2, y2, z2, x(next), y(next), z(next) ) ) then
      nl = next
    else
      nr = next
    end if

    go to 6

  end if
!
!  IWL is the number of arcs which intersect N1-N2.
!  Store LWK.
!
9 continue

  lwk = iwl
  iwend = iwl
!
!  Initialize for edge swapping loop -- all possible swaps
!  are applied (even if the new arc again intersects
!  N1-N2), arcs to the left of N1->N2 are stored in the
!  left portion of IWK, and arcs to the right are stored in
!  the right portion.  IWF and IWL index the first and last
!  intersecting arcs.
!
  iwf = 1
!
!  Top of loop -- set N0 to N1 and NL->NR to the first edge.
!  IWC points to the arc currently being processed.  LFT
!  <= 0 iff N0 LEFT N1->N2.
!
10 continue

  lft = 0
  n0 = n1
  x0 = x1
  y0 = y1
  z0 = z1
  nl = iwk(1,iwf)
  nr = iwk(2,iwf)
  iwc = iwf
!
!  Set NEXT to the node opposite NL->NR unless IWC is the last arc.
!
11 continue

  if (iwc == iwl) then
    go to 21
  end if

  iwcp1 = iwc + 1
  next = iwk(1,iwcp1)

  if ( next /= nl ) then
    go to 16
  end if

  next = iwk(2,iwcp1)
!
!  NEXT RIGHT N1->N2 and IWC < IWL.  Test for a possible swap.
!
  if ( .not. left ( x0, y0, z0, x(nr), y(nr), z(nr), x(next), &
                  y(next), z(next) ) ) then
    go to 14
  end if

  if ( 0 <= lft ) then
    go to 12
  end if

  if ( .not. left ( x(nl), y(nl), z(nl), x0, y0, z0, x(next), &
                  y(next), z(next) ) ) then
    go to 14
  end if
!
!  Replace NL->NR with N0->NEXT.
!
  call swap ( next, n0, nl, nr, list, lptr, lend, lp21 )
  iwk(1,iwc) = n0
  iwk(2,iwc) = next
  go to 15
!
!  Swap NL-NR for N0-NEXT, shift columns IWC+1,...,IWL to
!  the left, and store N0-NEXT in the right portion of IWK.
!
12 continue

  call swap ( next, n0, nl, nr, list, lptr, lend, lp21 )

  do i = iwcp1, iwl
    iwk(1,i-1) = iwk(1,i)
    iwk(2,i-1) = iwk(2,i)
  end do

  iwk(1,iwl) = n0
  iwk(2,iwl) = next
  iwl = iwl - 1
  nr = next
  go to 11
!
!  A swap is not possible.  Set N0 to NR.
!
14 continue

  n0 = nr
  x0 = x(n0)
  y0 = y(n0)
  z0 = z(n0)
  lft = 1
!
!  Advance to the next arc.
!
15 continue

  nr = next
  iwc = iwc + 1
  go to 11
!
!  NEXT LEFT N1->N2, NEXT .NE. N2, and IWC < IWL.
!  Test for a possible swap.
!
16 continue

  if ( .not. &
    left ( x(nl), y(nl), z(nl), x0, y0, z0, x(next), y(next), z(next) ) ) then
    go to 19
  end if

  if ( lft <= 0 ) then
    go to 17
  end if

  if ( .not. &
    left ( x0, y0, z0, x(nr), y(nr), z(nr), x(next), y(next), z(next) ) ) then
    go to 19
  end if
!
!  Replace NL->NR with NEXT->N0.
!
  call swap ( next, n0, nl, nr, list, lptr, lend, lp21 )
  iwk(1,iwc) = next
  iwk(2,iwc) = n0
  go to 20
!
!  Swap NL-NR for N0-NEXT, shift columns IWF,...,IWC-1 to
!  the right, and store N0-NEXT in the left portion of IWK.
!
17 continue

  call swap ( next, n0, nl, nr, list, lptr, lend, lp21 )

  do i = iwc-1, iwf, -1
    iwk(1,i+1) = iwk(1,i)
    iwk(2,i+1) = iwk(2,i)
  end do

  iwk(1,iwf) = n0
  iwk(2,iwf) = next
  iwf = iwf + 1
  go to 20
!
!  A swap is not possible.  Set N0 to NL.
!
19 continue

  n0 = nl
  x0 = x(n0)
  y0 = y(n0)
  z0 = z(n0)
  lft = -1
!
!  Advance to the next arc.
!
20 continue

  nl = next
  iwc = iwc + 1
  go to 11
!
!  N2 is opposite NL->NR (IWC = IWL).
!
21 continue

  if ( n0 == n1 ) then
    go to 24
  end if

  if ( lft < 0 ) then
    go to 22
  end if
!
!  N0 RIGHT N1->N2.  Test for a possible swap.
!
  if ( .not. left ( x0, y0, z0, x(nr), y(nr), z(nr), x2, y2, z2 ) ) then
    go to 10
  end if
!
!  Swap NL-NR for N0-N2 and store N0-N2 in the right portion of IWK.
!
  call swap ( n2, n0, nl, nr, list, lptr, lend, lp21 )
  iwk(1,iwl) = n0
  iwk(2,iwl) = n2
  iwl = iwl - 1
  go to 10
!
!  N0 LEFT N1->N2.  Test for a possible swap.
!
22 continue

  if ( .not. left ( x(nl), y(nl), z(nl), x0, y0, z0, x2, y2, z2 ) ) then
    go to 10
  end if
!
!  Swap NL-NR for N0-N2, shift columns IWF,...,IWL-1 to the
!  right, and store N0-N2 in the left portion of IWK.
!
  call swap ( n2, n0, nl, nr, list, lptr, lend, lp21 )
  i = iwl

  do

    iwk(1,i) = iwk(1,i-1)
    iwk(2,i) = iwk(2,i-1)
    i = i - 1

    if ( i <= iwf ) then
      exit
    end if

  end do

  iwk(1,iwf) = n0
  iwk(2,iwf) = n2
  iwf = iwf + 1
  go to 10
!
!  IWF = IWC = IWL.  Swap out the last arc for N1-N2 and store zeros in IWK.
!
24 continue

  call swap ( n2, n1, nl, nr, list, lptr, lend, lp21 )
  iwk(1,iwc) = 0
  iwk(2,iwc) = 0
!
!  Optimization procedure.
!
!  Optimize the set of new arcs to the left of IN1->IN2.
!
  ier = 0

  if ( 1 < iwc ) then

    nit = 4 * ( iwc - 1 )

    call optim ( x, y, z, iwc-1, list, lptr, lend, nit, iwk, ierr )

    if ( ierr /= 0 .and. ierr /= 1 ) then
      ier = 4
      return
    end if

    if ( ierr == 1 ) then
      ier = 5
    end if

  end if
!
!  Optimize the set of new arcs to the right of IN1->IN2.
!
  if ( iwc < iwend ) then

    nit = 4 * ( iwend - iwc )

    call optim ( x, y, z, iwend-iwc, list, lptr, lend, nit, iwk(1,iwc+1), ierr )

    if ( ierr /= 0 .and. ierr /= 1) then
      ier = 4
      return
    end if

    if ( ierr == 1 ) then
      ier = 5
      return
    end if

  end if

  if ( ier == 5 ) then
    ier = 5
    return
  end if

  return
end
subroutine getnp ( x, y, z, list, lptr, lend, l, npts, df, ier )

!*****************************************************************************80
!
!! GETNP gets the next nearest node to a given node.
!
!  Discussion:
!
!    Given a Delaunay triangulation of N nodes on the unit
!    sphere and an array NPTS containing the indexes of L-1
!    nodes ordered by angular distance from NPTS(1), this
!    routine sets NPTS(L) to the index of the next node in the
!    sequence -- the node, other than NPTS(1),...,NPTS(L-1),
!    that is closest to NPTS(1).  Thus, the ordered sequence
!    of K closest nodes to N1 (including N1) may be determined
!    by K-1 calls to GETNP with NPTS(1) = N1 and L = 2,3,...,K
!    for K >= 2.
!
!    The algorithm uses the property of a Delaunay triangula-
!    tion that the K-th closest node to N1 is a neighbor of one
!    of the K-1 closest nodes to N1.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates of the nodes.
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N), the
!    triangulation data structure, created by TRMESH.
!
!    Input, integer ( kind = 4 ) L, the number of nodes in the sequence on
!    output.  2 <= L <= N.
!
!    Input/output, integer ( kind = 4 ) NPTS(L).  On input, the indexes of
!    the L-1 closest nodes to NPTS(1) in the first L-1 locations.  On output,
!    updated with the index of the L-th closest node to NPTS(1) in
!    position L unless IER = 1.
!
!    Output, real ( kind = 8 ) DF, value of an increasing function (negative
!    cosine) of the angular distance between NPTS(1) and NPTS(L) unless IER = 1.
!
!    Output, integer ( kind = 4 ) IER, error indicator:
!    0, if no errors were encountered.
!    1, if L < 2.
!
!  Local parameters:
!
!    DNB,DNP =  Negative cosines of the angular distances from
!               N1 to NB and to NP, respectively
!    I =        NPTS index and DO-loop index
!    LM1 =      L-1
!    LP =       LIST pointer of a neighbor of NI
!    LPL =      Pointer to the last neighbor of NI
!    N1 =       NPTS(1)
!    NB =       Neighbor of NI and candidate for NP
!    NI =       NPTS(I)
!    NP =       Candidate for NPTS(L)
!    X1,Y1,Z1 = Coordinates of N1
!
  implicit none

  integer ( kind = 4 ) l

  real    ( kind = 8 ) df
  real    ( kind = 8 ) dnb
  real    ( kind = 8 ) dnp
  integer ( kind = 4 ) i
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) lend(*)
  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) nb
  integer ( kind = 4 ) ni
  integer ( kind = 4 ) np
  integer ( kind = 4 ) npts(l)
  real    ( kind = 8 ) x(*)
  real    ( kind = 8 ) x1
  real    ( kind = 8 ) y(*)
  real    ( kind = 8 ) y1
  real    ( kind = 8 ) z(*)
  real    ( kind = 8 ) z1

  if ( l < 2 ) then
    ier = 1
    return
  end if

  ier = 0
!
!  Store N1 = NPTS(1) and mark the elements of NPTS.
!
  n1 = npts(1)
  x1 = x(n1)
  y1 = y(n1)
  z1 = z(n1)

  do i = 1, l-1
    ni = npts(i)
    lend(ni) = -lend(ni)
  end do
!
!  Candidates for NP = NPTS(L) are the unmarked neighbors
!  of nodes in NPTS.  DNP is initially greater than -cos(PI)
!  (the maximum distance).
!
  dnp = 2.0D+00
!
!  Loop on nodes NI in NPTS.
!
  do i = 1, l-1

    ni = npts(i)
    lpl = -lend(ni)
    lp = lpl
!
!  Loop on neighbors NB of NI.
!
    do

      nb = abs ( list(lp) )
!
!  NB is an unmarked neighbor of NI.  Replace NP if NB is closer to N1.
!
      if ( 0 <= lend(nb) ) then
        dnb = - ( x(nb) * x1 + y(nb) * y1 + z(nb) * z1 )
        if ( dnb < dnp ) then
          np = nb
          dnp = dnb
        end if
      end if

      lp = lptr(lp)

      if ( lp == lpl ) then
        exit
      end if

    end do

  end do

  npts(l) = np
  df = dnp
!
!  Unmark the elements of NPTS.
!
  do i = 1, l-1
    ni = npts(i)
    lend(ni) = -lend(ni)
  end do

  return
end
subroutine i4_swap ( i, j )

!*****************************************************************************80
!
!! I4_SWAP swaps two integer values.
!
!  Modified:
!
!    30 November 1998
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input/output, integer ( kind = 4 ) I, J.  On output, the values of I and
!    J have been interchanged.
!
  implicit none

  integer ( kind = 4 ) i
  integer ( kind = 4 ) j
  integer ( kind = 4 ) k

  k = i
  i = j
  j = k

  return
end
subroutine insert ( k, lp, list, lptr, lnew )

!*****************************************************************************80
!
!! INSERT inserts K as a neighbor of N1.
!
!  Discussion:
!
!    This subroutine inserts K as a neighbor of N1 following
!    N2, where LP is the LIST pointer of N2 as a neighbor of
!    N1.  Note that, if N2 is the last neighbor of N1, K will
!    become the first neighbor (even if N1 is a boundary node).
!
!    This routine is identical to the similarly named routine in TRIPACK.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) K, the index of the node to be inserted.
!
!    Input, integer ( kind = 4 ) LP, the LIST pointer of N2 as a neighbor of N1.
!
!    Input/output, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LNEW,
!    the data structure defining the triangulation, created by TRMESH.
!    On output, updated with the addition of node K.
!
  implicit none

  integer ( kind = 4 ) k
  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) lsav

  lsav = lptr(lp)
  lptr(lp) = lnew
  list(lnew) = k
  lptr(lnew) = lsav
  lnew = lnew + 1

  return
end
function inside ( p, lv, xv, yv, zv, nv, listv, ier )

!*****************************************************************************80
!
!! INSIDE determines if a point is inside a polygonal region.
!
!  Discussion:
!
!    This function locates a point P relative to a polygonal
!    region R on the surface of the unit sphere, returning
!    INSIDE = TRUE if and only if P is contained in R.  R is
!    defined by a cyclically ordered sequence of vertices which
!    form a positively-oriented simple closed curve.  Adjacent
!    vertices need not be distinct but the curve must not be
!    self-intersecting.  Also, while polygon edges are by definition
!    restricted to a single hemisphere, R is not so
!    restricted.  Its interior is the region to the left as the
!    vertices are traversed in order.
!
!    The algorithm consists of selecting a point Q in R and
!    then finding all points at which the great circle defined
!    by P and Q intersects the boundary of R.  P lies inside R
!    if and only if there is an even number of intersection
!    points between Q and P.  Q is taken to be a point immediately
!    to the left of a directed boundary edge -- the first
!    one that results in no consistency-check failures.
!
!    If P is close to the polygon boundary, the problem is
!    ill-conditioned and the decision may be incorrect.  Also,
!    an incorrect decision may result from a poor choice of Q
!    (if, for example, a boundary edge lies on the great circle
!    defined by P and Q).  A more reliable result could be
!    obtained by a sequence of calls to INSIDE with the vertices
!    cyclically permuted before each call (to alter the
!    choice of Q).
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) P(3), the coordinates of the point (unit vector)
!    to be located.
!
!    Input, integer ( kind = 4 ) LV, the length of arrays XV, YV, and ZV.
!
!    Input, real ( kind = 8 ) XV(LV), YV(LV), ZV(LV), the coordinates of unit
!    vectors (points on the unit sphere).
!
!    Input, integer ( kind = 4 ) NV, the number of vertices in the polygon.
!    3 <= NV <= LV.
!
!    Input, integer ( kind = 4 ) LISTV(NV), the indexes (for XV, YV, and ZV)
!    of a cyclically-ordered (and CCW-ordered) sequence of vertices that
!    define R.  The last vertex (indexed by LISTV(NV)) is followed by the
!    first (indexed by LISTV(1)).  LISTV entries must be in the range 1 to LV.
!
!    Output, logical INSIDE, TRUE if and only if P lies inside R unless
!    IER /= 0, in which case the value is not altered.
!
!    Output, integer ( kind = 4 ) IER, error indicator:
!    0, if no errors were encountered.
!    1, if LV or NV is outside its valid range.
!    2, if a LISTV entry is outside its valid range.
!    3, if the polygon boundary was found to be self-intersecting.  This
!      error will not necessarily be detected.
!    4, if every choice of Q (one for each boundary edge) led to failure of
!      some internal consistency check.  The most likely cause of this error
!      is invalid input:  P = (0,0,0), a null or self-intersecting polygon, etc.
!
!  Local parameters:
!
!    B =         Intersection point between the boundary and
!                the great circle defined by P and Q.
!
!    BP,BQ =     <B,P> and <B,Q>, respectively, maximized over
!                intersection points B that lie between P and
!                Q (on the shorter arc) -- used to find the
!                closest intersection points to P and Q
!    CN =        Q X P = normal to the plane of P and Q
!    D =         Dot product <B,P> or <B,Q>
!    EPS =       Parameter used to define Q as the point whose
!                orthogonal distance to (the midpoint of)
!                boundary edge V1->V2 is approximately EPS/
!                (2*Cos(A/2)), where <V1,V2> = Cos(A).
!    EVEN =      TRUE iff an even number of intersection points
!                lie between P and Q (on the shorter arc)
!    I1,I2 =     Indexes (LISTV elements) of a pair of adjacent
!                boundary vertices (endpoints of a boundary
!                edge)
!    IERR =      Error flag for calls to INTRSC (not tested)
!    IMX =       Local copy of LV and maximum value of I1 and I2
!    K =         DO-loop index and LISTV index
!    K0 =        LISTV index of the first endpoint of the
!                boundary edge used to compute Q
!    LFT1,LFT2 = Logical variables associated with I1 and I2 in
!                the boundary traversal:  TRUE iff the vertex
!                is strictly to the left of Q->P (<V,CN> > 0)
!    N =         Local copy of NV
!    NI =        Number of intersections (between the boundary
!                curve and the great circle P-Q) encountered
!    PINR =      TRUE iff P is to the left of the directed
!                boundary edge associated with the closest
!                intersection point to P that lies between P
!                and Q (a left-to-right intersection as
!                viewed from Q), or there is no intersection
!                between P and Q (on the shorter arc)
!    PN,QN =     P X CN and CN X Q, respectively:  used to
!                locate intersections B relative to arc Q->P
!    Q =         (V1 + V2 + EPS*VN/VNRM)/QNRM, where V1->V2 is
!                the boundary edge indexed by LISTV(K0) ->
!                LISTV(K0+1)
!    QINR =      TRUE iff Q is to the left of the directed
!                boundary edge associated with the closest
!                intersection point to Q that lies between P
!                and Q (a right-to-left intersection as
!                viewed from Q), or there is no intersection
!                between P and Q (on the shorter arc)
!    QNRM =      Euclidean norm of V1+V2+EPS*VN/VNRM used to
!                compute (normalize) Q
!    V1,V2 =     Vertices indexed by I1 and I2 in the boundary
!                traversal
!    VN =        V1 X V2, where V1->V2 is the boundary edge
!                indexed by LISTV(K0) -> LISTV(K0+1)
!    VNRM =      Euclidean norm of VN
!
  implicit none

  integer ( kind = 4 ) lv
  integer ( kind = 4 ) nv

  real    ( kind = 8 ) b(3)
  real    ( kind = 8 ) bp
  real    ( kind = 8 ) bq
  real    ( kind = 8 ) cn(3)
  real    ( kind = 8 ) d
  real    ( kind = 8 ), parameter :: eps = 0.001D+00
  logical even
  integer ( kind = 4 ) i1
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) ierr
  integer ( kind = 4 ) imx
  logical inside
  integer ( kind = 4 ) k
  integer ( kind = 4 ) k0
  logical lft1
  logical lft2
  integer ( kind = 4 ) listv(nv)
  integer ( kind = 4 ) n
  integer ( kind = 4 ) ni
  real    ( kind = 8 ) p(3)
  logical pinr
  real    ( kind = 8 ) pn(3)
  real    ( kind = 8 ) q(3)
  logical qinr
  real    ( kind = 8 ) qn(3)
  real    ( kind = 8 ) qnrm
  real    ( kind = 8 ) v1(3)
  real    ( kind = 8 ) v2(3)
  real    ( kind = 8 ) vn(3)
  real    ( kind = 8 ) vnrm
  real    ( kind = 8 ) xv(lv)
  real    ( kind = 8 ) yv(lv)
  real    ( kind = 8 ) zv(lv)
!
!  Store local parameters.
!
  imx = lv
  n = nv
!
!  Test for error 1.
!
  if ( n < 3 .or. imx < n ) then
    ier = 1
    return
  end if
!
!  Initialize K0.
!
  k0 = 0
  i1 = listv(1)

  if ( i1 < 1 .or. imx < i1 ) then
    ier = 2
    return
  end if
!
!  Increment K0 and set Q to a point immediately to the left
!  of the midpoint of edge V1->V2 = LISTV(K0)->LISTV(K0+1):
!  Q = (V1 + V2 + EPS*VN/VNRM)/QNRM, where VN = V1 X V2.
!
1 continue

  k0 = k0 + 1

  if ( n < k0 ) then
    ier = 4
    return
  end if

  i1 = listv(k0)

  if ( k0 < n ) then
    i2 = listv(k0+1)
  else
    i2 = listv(1)
  end if

  if ( i2 < 1 .or. imx < i2 ) then
    ier = 2
    return
  end if

  vn(1) = yv(i1) * zv(i2) - zv(i1) * yv(i2)
  vn(2) = zv(i1) * xv(i2) - xv(i1) * zv(i2)
  vn(3) = xv(i1) * yv(i2) - yv(i1) * xv(i2)
  vnrm = sqrt ( sum ( vn(1:3)**2 ) )

  if ( vnrm == 0.0D+00 ) then
    go to 1
  end if

  q(1) = xv(i1) + xv(i2) + eps * vn(1) / vnrm
  q(2) = yv(i1) + yv(i2) + eps * vn(2) / vnrm
  q(3) = zv(i1) + zv(i2) + eps * vn(3) / vnrm

  qnrm = sqrt ( sum ( q(1:3)**2 ) )

  q(1) = q(1) / qnrm
  q(2) = q(2) / qnrm
  q(3) = q(3) / qnrm
!
!  Compute CN = Q X P, PN = P X CN, and QN = CN X Q.
!
  cn(1) = q(2) * p(3) - q(3) * p(2)
  cn(2) = q(3) * p(1) - q(1) * p(3)
  cn(3) = q(1) * p(2) - q(2) * p(1)

  if ( cn(1) == 0.0D+00 .and. cn(2) == 0.0D+00  .and. cn(3) == 0.0D+00 ) then
    go to 1
  end if

  pn(1) = p(2) * cn(3) - p(3) * cn(2)
  pn(2) = p(3) * cn(1) - p(1) * cn(3)
  pn(3) = p(1) * cn(2) - p(2) * cn(1)
  qn(1) = cn(2) * q(3) - cn(3) * q(2)
  qn(2) = cn(3) * q(1) - cn(1) * q(3)
  qn(3) = cn(1) * q(2) - cn(2) * q(1)
!
!  Initialize parameters for the boundary traversal.
!
  ni = 0
  even = .true.
  bp = -2.0D+00
  bq = -2.0D+00
  pinr = .true.
  qinr = .true.
  i2 = listv(n)

  if ( i2 < 1 .or. imx < i2 ) then
    ier = 2
    return
  end if

  lft2 = 0.0D+00 < cn(1) * xv(i2) + cn(2) * yv(i2) + cn(3) * zv(i2)
!
!  Loop on boundary arcs I1->I2.
!
  do k = 1, n

    i1 = i2
    lft1 = lft2
    i2 = listv(k)

    if ( i2 < 1 .or. imx < i2 ) then
      ier = 2
      return
    end if

    lft2 = ( 0.0D+00 < cn(1) * xv(i2) + cn(2) * yv(i2) + cn(3) * zv(i2) )

    if ( lft1 .eqv. lft2 ) then
      cycle
    end if
!
!  I1 and I2 are on opposite sides of Q->P.  Compute the
!  point of intersection B.
!
    ni = ni + 1
    v1(1) = xv(i1)
    v1(2) = yv(i1)
    v1(3) = zv(i1)
    v2(1) = xv(i2)
    v2(2) = yv(i2)
    v2(3) = zv(i2)

    call intrsc ( v1, v2, cn, b, ierr )
!
!  B is between Q and P (on the shorter arc) iff
!  B Forward Q->P and B Forward P->Q       iff
!  <B,QN> > 0 and 0 < <B,PN>.
!
    if ( 0.0D+00 < dot_product ( b(1:3), qn(1:3) ) .and. &
         0.0D+00 < dot_product ( b(1:3), pn(1:3) ) ) then
!
!  Update EVEN, BQ, QINR, BP, and PINR.
!
      even = .not. even
      d = dot_product ( b(1:3), q(1:3) )

      if ( bq < d ) then
        bq = d
        qinr = lft2
      end if

      d = dot_product ( b(1:3), p(1:3) )

      if ( bp < d ) then
        bp = d
        pinr = lft1
      end if

    end if

  end do
!
!  Test for consistency:  NI must be even and QINR must be TRUE.
!
  if ( ni /= 2 * ( ni / 2 ) .or. .not. qinr ) then
    go to 1
  end if
!
!  Test for error 3:  different values of PINR and EVEN.
!
  if ( pinr .neqv. even ) then
    ier = 3
    return
  end if

  ier = 0
  inside = even

  return
end
subroutine intadd ( kk, i1, i2, i3, list, lptr, lend, lnew )

!*****************************************************************************80
!
!! INTADD adds an interior node to a triangulation.
!
!  Discussion:
!
!    This subroutine adds an interior node to a triangulation
!    of a set of points on the unit sphere.  The data structure
!    is updated with the insertion of node KK into the triangle
!    whose vertices are I1, I2, and I3.  No optimization of the
!    triangulation is performed.
!
!    This routine is identical to the similarly named routine in TRIPACK.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) KK, the index of the node to be inserted.
!    1 <= KK and KK must not be equal to I1, I2, or I3.
!
!    Input, integer ( kind = 4 ) I1, I2, I3, indexes of the
!    counterclockwise-ordered sequence of vertices of a triangle which contains
!    node KK.
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N), LNEW,
!    the data structure defining the triangulation, created by TRMESH.  Triangle
!    (I1,I2,I3) must be included in the triangulation.
!    On output, updated with the addition of node KK.  KK
!    will be connected to nodes I1, I2, and I3.
!
!  Local parameters:
!
!    K =        Local copy of KK
!    LP =       LIST pointer
!    N1,N2,N3 = Local copies of I1, I2, and I3
!
  implicit none

  integer ( kind = 4 ) i1
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) i3
  integer ( kind = 4 ) k
  integer ( kind = 4 ) kk
  integer ( kind = 4 ) lend(*)
  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) lstptr
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) n3

  k = kk
!
!  Initialization.
!
  n1 = i1
  n2 = i2
  n3 = i3
!
!  Add K as a neighbor of I1, I2, and I3.
!
  lp = lstptr ( lend(n1), n2, list, lptr )
  call insert ( k, lp, list, lptr, lnew )

  lp = lstptr ( lend(n2), n3, list, lptr )
  call insert ( k, lp, list, lptr, lnew )

  lp = lstptr ( lend(n3), n1, list, lptr )
  call insert ( k, lp, list, lptr, lnew )
!
!  Add I1, I2, and I3 as neighbors of K.
!
  list(lnew) = n1
  list(lnew+1) = n2
  list(lnew+2) = n3
  lptr(lnew) = lnew + 1
  lptr(lnew+1) = lnew + 2
  lptr(lnew+2) = lnew
  lend(k) = lnew + 2
  lnew = lnew + 3

  return
end
subroutine intrsc ( p1, p2, cn, p, ier )

!*****************************************************************************80
!
!! INTSRC finds the intersection of two great circles.
!
!  Discussion:
!
!    Given a great circle C and points P1 and P2 defining an
!    arc A on the surface of the unit sphere, where A is the
!    shorter of the two portions of the great circle C12
!    associated with P1 and P2, this subroutine returns the point
!    of intersection P between C and C12 that is closer to A.
!    Thus, if P1 and P2 lie in opposite hemispheres defined by
!    C, P is the point of intersection of C with A.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) P1(3), P2(3), the coordinates of unit vectors.
!
!    Input, real ( kind = 8 ) CN(3), the coordinates of a nonzero vector
!    which defines C as the intersection of the plane whose normal is CN
!    with the unit sphere.  Thus, if C is to be the great circle defined
!    by P and Q, CN should be P X Q.
!
!    Output, real ( kind = 8 ) P(3), point of intersection defined above
!    unless IER is not 0, in which case P is not altered.
!
!    Output, integer ( kind = 4 ) IER, error indicator.
!    0, if no errors were encountered.
!    1, if <CN,P1> = <CN,P2>.  This occurs iff P1 = P2 or CN = 0 or there are
!      two intersection points at the same distance from A.
!    2, if P2 = -P1 and the definition of A is therefore ambiguous.
!
!  Local parameters:
!
!    D1 =  <CN,P1>
!    D2 =  <CN,P2>
!    I =   DO-loop index
!    PP =  P1 + T*(P2-P1) = Parametric representation of the
!          line defined by P1 and P2
!    PPN = Norm of PP
!    T =   D1/(D1-D2) = Parameter value chosen so that PP lies
!          in the plane of C
!
  implicit none

  real    ( kind = 8 ) cn(3)
  real    ( kind = 8 ) d1
  real    ( kind = 8 ) d2
  integer ( kind = 4 ) i
  integer ( kind = 4 ) ier
  real    ( kind = 8 ) p(3)
  real    ( kind = 8 ) p1(3)
  real    ( kind = 8 ) p2(3)
  real    ( kind = 8 ) pp(3)
  real    ( kind = 8 ) ppn
  real    ( kind = 8 ) t

  d1 = dot_product ( cn(1:3), p1(1:3) )
  d2 = dot_product ( cn(1:3), p2(1:3) )

  if ( d1 == d2 ) then
    ier = 1
    return
  end if
!
!  Solve for T such that <PP,CN> = 0 and compute PP and PPN.
!
  t = d1 / ( d1 - d2 )

  pp(1:3) = p1(1:3) + t * ( p2(1:3) - p1(1:3) )

  ppn = dot_product ( pp(1:3), pp(1:3) )
!
!  PPN = 0 iff PP = 0 iff P2 = -P1 (and T = .5).
!
  if ( ppn == 0.0D+00 ) then
    ier = 2
    return
  end if

  ppn = sqrt ( ppn )
!
!  Compute P = PP/PPN.
!
  p(1:3) = pp(1:3) / ppn

  ier = 0

  return
end
function jrand ( n, ix, iy, iz )

!*****************************************************************************80
!
!! JRAND returns a random integer between 1 and N.
!
!  Discussion:
!
!   This function returns a uniformly distributed pseudorandom integer
!   in the range 1 to N.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Brian Wichmann, David Hill,
!    An Efficient and Portable Pseudo-random Number Generator,
!    Applied Statistics,
!    Volume 31, Number 2, 1982, pages 188-190.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the maximum value to be returned.
!
!    Input/output, integer ( kind = 4 ) IX, IY, IZ = seeds initialized to
!    values in the range 1 to 30,000 before the first call to JRAND, and
!    not altered between subsequent calls (unless a sequence of random
!    numbers is to be repeated by reinitializing the seeds).
!
!    Output, integer ( kind = 4 ) JRAND, a random integer in the range 1 to N.
!
!  Local parameters:
!
!    U = Pseudo-random number uniformly distributed in the interval (0,1).
!    X = Pseudo-random number in the range 0 to 3 whose fractional part is U.
!
  implicit none

  integer ( kind = 4 ) ix
  integer ( kind = 4 ) iy
  integer ( kind = 4 ) iz
  integer ( kind = 4 ) jrand
  integer ( kind = 4 ) n
  real    ( kind = 8 ) u
  real    ( kind = 8 ) x

  ix = mod ( 171 * ix, 30269 )
  iy = mod ( 172 * iy, 30307 )
  iz = mod ( 170 * iz, 30323 )

  x = ( real ( ix, kind = 8 ) / 30269.0D+00 ) &
    + ( real ( iy, kind = 8 ) / 30307.0D+00 ) &
    + ( real ( iz, kind = 8 ) / 30323.0D+00 )

  u = x - int ( x )
  jrand = real ( n, kind = 8 ) * u + 1.0D+00

  return
end
function left ( x1, y1, z1, x2, y2, z2, x0, y0, z0 )

!*****************************************************************************80
!
!! LEFT determines whether a node is to the left of a plane through the origin.
!
!  Discussion:
!
!    This function determines whether node N0 is in the
!    (closed) left hemisphere defined by the plane containing
!    N1, N2, and the origin, where left is defined relative to
!    an observer at N1 facing N2.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) X1, Y1, Z1 = Coordinates of N1.
!
!    Input, real ( kind = 8 ) X2, Y2, Z2 = Coordinates of N2.
!
!    Input, real ( kind = 8 ) X0, Y0, Z0 = Coordinates of N0.
!
!    Output, logical LEFT = TRUE if and only if N0 is in the closed
!    left hemisphere.
!
  implicit none

  logical left
  real    ( kind = 8 ) x0
  real    ( kind = 8 ) x1
  real    ( kind = 8 ) x2
  real    ( kind = 8 ) y0
  real    ( kind = 8 ) y1
  real    ( kind = 8 ) y2
  real    ( kind = 8 ) z0
  real    ( kind = 8 ) z1
  real    ( kind = 8 ) z2
!
!  LEFT = TRUE iff <N0,N1 X N2> = det(N0,N1,N2) >= 0.
!
  left = x0 * ( y1 * z2 - y2 * z1 ) &
       - y0 * ( x1 * z2 - x2 * z1 ) &
       + z0 * ( x1 * y2 - x2 * y1 ) >= 0.0D+00

  return
end
function lstptr ( lpl, nb, list, lptr )

!*****************************************************************************80
!
!! LSTPTR returns the index of NB in the adjacency list.
!
!  Discussion:
!
!    This function returns the index (LIST pointer) of NB in
!    the adjacency list for N0, where LPL = LEND(N0).
!
!    This function is identical to the similarly named function in TRIPACK.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) LPL, is LEND(N0).
!
!    Input, integer ( kind = 4 ) NB, index of the node whose pointer is to
!    be returned.  NB must be connected to N0.
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), the data
!    structure defining the triangulation, created by TRMESH.
!
!    Output, integer ( kind = 4 ) LSTPTR, pointer such that LIST(LSTPTR) = NB or
!    LIST(LSTPTR) = -NB, unless NB is not a neighbor of N0, in which
!    case LSTPTR = LPL.
!
!  Local parameters:
!
!    LP = LIST pointer
!    ND = Nodal index
!
  implicit none

  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) lstptr
  integer ( kind = 4 ) nb
  integer ( kind = 4 ) nd

  lp = lptr(lpl)

  do

    nd = list(lp)

    if ( nd == nb ) then
      exit
    end if

    lp = lptr(lp)

    if ( lp == lpl ) then
      exit
    end if

  end do

  lstptr = lp

  return
end
function nbcnt ( lpl, lptr )

!*****************************************************************************80
!
!! NBCNT returns the number of neighbors of a node.
!
!  Discussion:
!
!    This function returns the number of neighbors of a node
!    N0 in a triangulation created by TRMESH.
!
!    The number of neighbors also gives the order of the Voronoi
!    polygon containing the point.  Thus, a neighbor count of 6
!    means the node is contained in a 6-sided Voronoi region.
!
!    This function is identical to the similarly named function in TRIPACK.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) LPL = LIST pointer to the last neighbor of N0;
!    LPL = LEND(N0).
!
!    Input, integer ( kind = 4 ) LPTR(6*(N-2)), pointers associated with LIST.
!
!    Output, integer ( kind = 4 ) NBCNT, the number of neighbors of N0.
!
!  Local parameters:
!
!    K =  Counter for computing the number of neighbors.
!
!    LP = LIST pointer
!
  implicit none

  integer ( kind = 4 ) k
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) nbcnt

  lp = lpl
  k = 1

  do

    lp = lptr(lp)

    if ( lp == lpl ) then
      exit
    end if

    k = k + 1

  end do

  nbcnt = k

  return
end
function nearnd ( p, ist, n, x, y, z, list, lptr, lend, al )

!*****************************************************************************80
!
!! NEARND returns the nearest node to a given point.
!
!  Discussion:
!
!    Given a point P on the surface of the unit sphere and a
!    Delaunay triangulation created by TRMESH, this
!    function returns the index of the nearest triangulation
!    node to P.
!
!    The algorithm consists of implicitly adding P to the
!    triangulation, finding the nearest neighbor to P, and
!    implicitly deleting P from the triangulation.  Thus, it
!    is based on the fact that, if P is a node in a Delaunay
!    triangulation, the nearest node to P is a neighbor of P.
!
!    For large values of N, this procedure will be faster than
!    the naive approach of computing the distance from P to every node.
!
!    Note that the number of candidates for NEARND (neighbors of P)
!    is limited to LMAX defined in the PARAMETER statement below.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) P(3), the Cartesian coordinates of the point P to
!    be located relative to the triangulation.  It is assumed
!    that P(1)**2 + P(2)**2 + P(3)**2 = 1, that is, that the
!    point lies on the unit sphere.
!
!    Input, integer ( kind = 4 ) IST, the index of the node at which the search
!    is to begin.  The search time depends on the proximity of this
!    node to P.  If no good candidate is known, any value between
!    1 and N will do.
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    N must be at least 3.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the Cartesian coordinates of
!    the nodes.
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N),
!    the data structure defining the triangulation, created by TRMESH.
!
!    Output, real ( kind = 8 ) AL, the arc length between P and node NEARND.
!    Because both points are on the unit sphere, this is also
!    the angular separation in radians.
!
!    Output, integer ( kind = 4 ) NEARND, the index of the nearest node to P.
!    NEARND will be 0 if N < 3 or the triangulation data structure
!    is invalid.
!
!  Local parameters:
!
!    B1,B2,B3 =  Unnormalized barycentric coordinates returned by TRFIND
!    DS1 =       (Negative cosine of the) distance from P to N1
!    DSR =       (Negative cosine of the) distance from P to NR
!    DX1,..DZ3 = Components of vectors used by the swap test
!    I1,I2,I3 =  Nodal indexes of a triangle containing P, or
!                the rightmost (I1) and leftmost (I2) visible
!                boundary nodes as viewed from P
!    L =         Length of LISTP/LPTRP and number of neighbors of P
!    LMAX =      Maximum value of L
!    LISTP =     Indexes of the neighbors of P
!    LPTRP =     Array of pointers in 1-1 correspondence with LISTP elements
!    LP =        LIST pointer to a neighbor of N1 and LISTP pointer
!    LP1,LP2 =   LISTP indexes (pointers)
!    LPL =       Pointer to the last neighbor of N1
!    N1 =        Index of a node visible from P
!    N2 =        Index of an endpoint of an arc opposite P
!    N3 =        Index of the node opposite N1->N2
!    NN =        Local copy of N
!    NR =        Index of a candidate for the nearest node to P
!    NST =       Index of the node at which TRFIND begins the search
!
  implicit none

  integer ( kind = 4 ), parameter :: lmax = 25
  integer ( kind = 4 ) n

  real    ( kind = 8 ) al
  real    ( kind = 8 ) b1
  real    ( kind = 8 ) b2
  real    ( kind = 8 ) b3
  real    ( kind = 8 ) ds1
  real    ( kind = 8 ) dsr
  real    ( kind = 8 ) dx1
  real    ( kind = 8 ) dx2
  real    ( kind = 8 ) dx3
  real    ( kind = 8 ) dy1
  real    ( kind = 8 ) dy2
  real    ( kind = 8 ) dy3
  real    ( kind = 8 ) dz1
  real    ( kind = 8 ) dz2
  real    ( kind = 8 ) dz3
  integer ( kind = 4 ) i1
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) i3
  integer ( kind = 4 ) ist
  integer ( kind = 4 ) l
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) listp(lmax)
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lp1
  integer ( kind = 4 ) lp2
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) lptrp(lmax)
  integer ( kind = 4 ) lstptr
  integer ( kind = 4 ) nearnd
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) n3
  integer ( kind = 4 ) nn
  integer ( kind = 4 ) nr
  integer ( kind = 4 ) nst
  real    ( kind = 8 ) p(3)
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) z(n)

  nearnd = 0
  al = 0.0D+00
!
!  Store local parameters and test for N invalid.
!
  nn = n

  if ( nn < 3 ) then
    return
  end if

  nst = ist

  if ( nst < 1 .or. nn < nst ) then
    nst = 1
  end if
!
!  Find a triangle (I1,I2,I3) containing P, or the rightmost
!  (I1) and leftmost (I2) visible boundary nodes as viewed from P.
!
  call trfind ( nst, p, n, x, y, z, list, lptr, lend, b1, b2, b3, i1, i2, i3 )
!
!  Test for collinear nodes.
!
  if ( i1 == 0 ) then
    return
  end if
!
!  Store the linked list of 'neighbors' of P in LISTP and
!  LPTRP.  I1 is the first neighbor, and 0 is stored as
!  the last neighbor if P is not contained in a triangle.
!  L is the length of LISTP and LPTRP, and is limited to
!  LMAX.
!
  if ( i3 /= 0 ) then

    listp(1) = i1
    lptrp(1) = 2
    listp(2) = i2
    lptrp(2) = 3
    listp(3) = i3
    lptrp(3) = 1
    l = 3

  else

    n1 = i1
    l = 1
    lp1 = 2
    listp(l) = n1
    lptrp(l) = lp1
!
!  Loop on the ordered sequence of visible boundary nodes
!  N1 from I1 to I2.
!
    do

      lpl = lend(n1)
      n1 = -list(lpl)
      l = lp1
      lp1 = l+1
      listp(l) = n1
      lptrp(l) = lp1

      if ( n1 == i2 .or. lmax <= lp1 ) then
        exit
      end if

    end do

    l = lp1
    listp(l) = 0
    lptrp(l) = 1

  end if
!
!  Initialize variables for a loop on arcs N1-N2 opposite P
!  in which new 'neighbors' are 'swapped' in.  N1 follows
!  N2 as a neighbor of P, and LP1 and LP2 are the LISTP
!  indexes of N1 and N2.
!
  lp2 = 1
  n2 = i1
  lp1 = lptrp(1)
  n1 = listp(lp1)
!
!  Begin loop:  find the node N3 opposite N1->N2.
!
  do

    lp = lstptr ( lend(n1), n2, list, lptr )

    if ( 0 <= list(lp) ) then

      lp = lptr(lp)
      n3 = abs ( list(lp) )
!
!  Swap test:  Exit the loop if L = LMAX.
!
      if ( l == lmax ) then
        exit
      end if

      dx1 = x(n1) - p(1)
      dy1 = y(n1) - p(2)
      dz1 = z(n1) - p(3)

      dx2 = x(n2) - p(1)
      dy2 = y(n2) - p(2)
      dz2 = z(n2) - p(3)

      dx3 = x(n3) - p(1)
      dy3 = y(n3) - p(2)
      dz3 = z(n3) - p(3)
!
!  Swap:  Insert N3 following N2 in the adjacency list for P.
!  The two new arcs opposite P must be tested.
!
      if ( dx3 * ( dy2 * dz1 - dy1 * dz2 ) - &
           dy3 * ( dx2 * dz1 - dx1 * dz2 ) + &
           dz3 * ( dx2 * dy1 - dx1 * dy2 ) > 0.0D+00 ) then

        l = l+1
        lptrp(lp2) = l
        listp(l) = n3
        lptrp(l) = lp1
        lp1 = l
        n1 = n3
        cycle

      end if

    end if
!
!  No swap:  Advance to the next arc and test for termination
!  on N1 = I1 (LP1 = 1) or N1 followed by 0.
!
    if ( lp1 == 1 ) then
      exit
    end if

    lp2 = lp1
    n2 = n1
    lp1 = lptrp(lp1)
    n1 = listp(lp1)

    if ( n1 == 0 ) then
      exit
    end if

  end do
!
!  Set NR and DSR to the index of the nearest node to P and
!  an increasing function (negative cosine) of its distance
!  from P, respectively.
!
  nr = i1
  dsr = -( x(nr) * p(1) + y(nr) * p(2) + z(nr) * p(3) )

  do lp = 2, l

    n1 = listp(lp)

    if ( n1 == 0 ) then
      cycle
    end if

    ds1 = -( x(n1) * p(1) + y(n1) * p(2) + z(n1) * p(3) )

    if ( ds1 < dsr ) then
      nr = n1
      dsr = ds1
    end if

  end do

  dsr = -dsr
  dsr = min ( dsr, 1.0D+00 )

  al = acos ( dsr )
  nearnd = nr

  return
end
subroutine optim ( x, y, z, na, list, lptr, lend, nit, iwk, ier )

!*****************************************************************************80
!
!! OPTIM optimizes the quadrilateral portion of a triangulation.
!
!  Discussion:
!
!    Given a set of NA triangulation arcs, this subroutine
!    optimizes the portion of the triangulation consisting of
!    the quadrilaterals (pairs of adjacent triangles) which
!    have the arcs as diagonals by applying the circumcircle
!    test and appropriate swaps to the arcs.
!
!    An iteration consists of applying the swap test and
!    swaps to all NA arcs in the order in which they are
!    stored.  The iteration is repeated until no swap occurs
!    or NIT iterations have been performed.  The bound on the
!    number of iterations may be necessary to prevent an
!    infinite loop caused by cycling (reversing the effect of a
!    previous swap) due to floating point inaccuracy when four
!    or more nodes are nearly cocircular.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) X(*), Y(*), Z(*), the nodal coordinates.
!
!    Input, integer ( kind = 4 ) NA, the number of arcs in the set.  NA >= 0.
!
!    Input/output, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N),
!    the data structure defining the triangulation, created by TRMESH.
!    On output, updated to reflect the swaps.
!
!    Input/output, integer ( kind = 4 ) NIT.  On input, the maximum number of
!    iterations to be performed.  NIT = 4*NA should be sufficient.  NIT >= 1.
!    On output, the number of iterations performed.
!
!    Input/output, integer ( kind = 4 ) IWK(2,NA), the nodal indexes of the arc
!    endpoints (pairs of endpoints are stored in columns).  On output, endpoint
!    indexes of the new set of arcs reflecting the swaps.
!
!    Output, integer ( kind = 4 ) IER, error indicator:
!    0, if no errors were encountered.
!    1, if a swap occurred on the last of MAXIT iterations, where MAXIT is the
!      value of NIT on input.  The new set of arcs is not necessarily optimal
!      in this case.
!    2, if NA < 0 or NIT < 1 on input.
!    3, if IWK(2,I) is not a neighbor of IWK(1,I) for some I in the range 1
!      to NA.  A swap may have occurred in this case.
!    4, if a zero pointer was returned by subroutine SWAP.
!
!  Local parameters:
!
!    I =       Column index for IWK
!    IO1,IO2 = Nodal indexes of the endpoints of an arc in IWK
!    ITER =    Iteration count
!    LP =      LIST pointer
!    LP21 =    Parameter returned by SWAP (not used)
!    LPL =     Pointer to the last neighbor of IO1
!    LPP =     Pointer to the node preceding IO2 as a neighbor of IO1
!    MAXIT =   Input value of NIT
!    N1,N2 =   Nodes opposite IO1->IO2 and IO2->IO1, respectively
!    NNA =     Local copy of NA
!    SWP =     Flag set to TRUE iff a swap occurs in the optimization loop
!
  implicit none

  integer ( kind = 4 ) na

  integer ( kind = 4 ) i
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) io1
  integer ( kind = 4 ) io2
  integer ( kind = 4 ) iter
  integer ( kind = 4 ) iwk(2,na)
  integer ( kind = 4 ) lend(*)
  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lp21
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lpp
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) maxit
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) nit
  integer ( kind = 4 ) nna
  logical swp
  logical swptst
  real    ( kind = 8 ) x(*)
  real    ( kind = 8 ) y(*)
  real    ( kind = 8 ) z(*)

  nna = na
  maxit = nit

  if ( nna < 0 .or. maxit < 1 ) then
    nit = 0
    ier = 2
    return
  end if
!
!  Initialize iteration count ITER and test for NA = 0.
!
  iter = 0

  if ( nna == 0 ) then
    nit = 0
    ier = 0
    return
  end if
!
!  Top of loop.
!  SWP = TRUE iff a swap occurred in the current iteration.
!
  do

    if ( maxit <= iter ) then
      nit = iter
      ier = 1
      return
    end if

    iter = iter + 1
    swp = .false.
!
!  Inner loop on arcs IO1-IO2.
!
    do i = 1, nna

      io1 = iwk(1,i)
      io2 = iwk(2,i)
!
!  Set N1 and N2 to the nodes opposite IO1->IO2 and
!  IO2->IO1, respectively.  Determine the following:
!
!  LPL = pointer to the last neighbor of IO1,
!  LP = pointer to IO2 as a neighbor of IO1, and
!  LPP = pointer to the node N2 preceding IO2.
!
      lpl = lend(io1)
      lpp = lpl
      lp = lptr(lpp)

      do

        if ( list(lp) == io2 ) then
          go to 3
        end if

        lpp = lp
        lp = lptr(lpp)

        if ( lp == lpl ) then
          exit
        end if

      end do
!
!  IO2 should be the last neighbor of IO1.  Test for no
!  arc and bypass the swap test if IO1 is a boundary node.
!
      if ( abs ( list(lp) ) /= io2 ) then
        nit = iter
        ier = 3
        return
      end if

      if ( list(lp) < 0 ) then
        go to 4
      end if
!
!  Store N1 and N2, or bypass the swap test if IO1 is a
!  boundary node and IO2 is its first neighbor.
!
3     continue

      n2 = list(lpp)
!
!  Test IO1-IO2 for a swap, and update IWK if necessary.
!
      if ( 0 <= n2 ) then

        lp = lptr(lp)
        n1 = abs ( list(lp) )

        if ( swptst ( n1, n2, io1, io2, x, y, z ) ) then

          call swap ( n1, n2, io1, io2, list, lptr, lend, lp21 )

          if ( lp21 == 0 ) then
            nit = iter
            ier = 4
            return
          end if

          swp = .true.
          iwk(1,i) = n1
          iwk(2,i) = n2

        end if

      end if

4     continue

    end do

    if ( .not. swp ) then
      exit
    end if

  end do

  nit = iter
  ier = 0

  return
end
subroutine r83vec_normalize ( n, x, y, z )

!*****************************************************************************80
!
!! R83VEC_NORMALIZE normalizes each R83 in an R83VEC to have unit norm.
!
!  Modified:
!
!    25 June 2002
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of vectors.
!
!    Input/output, real ( kind = 8 ) X(N), Y(N), Z(N), the components of
!    the vectors.
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) i
  real    ( kind = 8 ) norm
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) z(n)

  do i = 1, n

    norm = sqrt ( x(i)**2 + y(i)**2 + z(i)**2 )

    if ( norm /= 0.0D+00 ) then
      x(i) = x(i) / norm
      y(i) = y(i) / norm
      z(i) = z(i) / norm
    end if

  end do

  return
end
subroutine scoord ( px, py, pz, plat, plon, pnrm )

!*****************************************************************************80
!
!! SCOORD converts from Cartesian to spherical coordinates.
!
!  Discussion:
!
!    This subroutine converts a point P from Cartesian (X,Y,Z) coordinates
!    to spherical ( LATITUDE, LONGITUDE, RADIUS ) coordinates.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) PX, PY, PZ, the coordinates of P.
!
!    Output, real ( kind = 8 ) PLAT, the latitude of P in the range -PI/2
!    to PI/2, or 0 if PNRM = 0.
!
!    Output, real ( kind = 8 ) PLON, the longitude of P in the range -PI to PI,
!    or 0 if P lies on the Z-axis.
!
!    Output, real ( kind = 8 ) PNRM, the magnitude (Euclidean norm) of P.
!
  implicit none

  real    ( kind = 8 ) plat
  real    ( kind = 8 ) plon
  real    ( kind = 8 ) pnrm
  real    ( kind = 8 ) px
  real    ( kind = 8 ) py
  real    ( kind = 8 ) pz

  pnrm = sqrt ( px * px + py * py + pz * pz )

  if ( px /= 0.0D+00 .or. py /= 0.0D+00 ) then
    plon = atan2 ( py, px )
  else
    plon = 0.0D+00
  end if

  if ( pnrm /= 0.0D+00 ) then
    plat = asin ( pz / pnrm )
  else
    plat = 0.0D+00
  end if

  return
end
function store ( x )

!*****************************************************************************80
!
!! STORE forces its argument to be stored.
!
!  Discussion:
!
!    This function forces its argument X to be stored in a
!    memory location, thus providing a means of determining
!    floating point number characteristics (such as the machine
!    precision) when it is necessary to avoid computation in
!    high precision registers.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) X, the value to be stored.
!
!    Output, real ( kind = 8 ) STORE, the value of X after it has been stored
!    and possibly truncated or rounded to the single precision word length.
!
  implicit none

  real    ( kind = 8 ) store
  real    ( kind = 8 ) x
  real    ( kind = 8 ) y

  common /stcom/ y

  y = x
  store = y

  return
end
subroutine swap ( in1, in2, io1, io2, list, lptr, lend, lp21 )

!*****************************************************************************80
!
!! SWAP replaces the diagonal arc of a quadrilateral with the other diagonal.
!
!  Discussion:
!
!    Given a triangulation of a set of points on the unit
!    sphere, this subroutine replaces a diagonal arc in a
!    strictly convex quadrilateral (defined by a pair of adja-
!    cent triangles) with the other diagonal.  Equivalently, a
!    pair of adjacent triangles is replaced by another pair
!    having the same union.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) IN1, IN2, IO1, IO2, nodal indexes of the
!    vertices of the quadrilateral.  IO1-IO2 is replaced by IN1-IN2.
!    (IO1,IO2,IN1) and (IO2,IO1,IN2) must be triangles on input.
!
!    Input/output, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N),
!    the data structure defining the triangulation, created by TRMESH.
!    On output, updated with the swap; triangles (IO1,IO2,IN1) an (IO2,IO1,IN2)
!    are replaced by (IN1,IN2,IO2) and (IN2,IN1,IO1) unless LP21 = 0.
!
!    Output, integer ( kind = 4 ) LP21, index of IN1 as a neighbor of IN2 after
!    the swap is performed unless IN1 and IN2 are adjacent on input, in which
!    case LP21 = 0.
!
!  Local parameters:
!
!    LP, LPH, LPSAV = LIST pointers
!
  implicit none

  integer ( kind = 4 ) in1
  integer ( kind = 4 ) in2
  integer ( kind = 4 ) io1
  integer ( kind = 4 ) io2
  integer ( kind = 4 ) lend(*)
  integer ( kind = 4 ) list(*)
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lp21
  integer ( kind = 4 ) lph
  integer ( kind = 4 ) lpsav
  integer ( kind = 4 ) lptr(*)
  integer ( kind = 4 ) lstptr
!
!  Test for IN1 and IN2 adjacent.
!
  lp = lstptr ( lend(in1), in2, list, lptr )

  if ( abs ( list(lp) ) == in2 ) then
    lp21 = 0
    return
  end if
!
!  Delete IO2 as a neighbor of IO1.
!
  lp = lstptr ( lend(io1), in2, list, lptr )
  lph = lptr(lp)
  lptr(lp) = lptr(lph)
!
!  If IO2 is the last neighbor of IO1, make IN2 the last neighbor.
!
  if ( lend(io1) == lph ) then
    lend(io1) = lp
  end if
!
!  Insert IN2 as a neighbor of IN1 following IO1 using the hole created above.
!
  lp = lstptr ( lend(in1), io1, list, lptr )
  lpsav = lptr(lp)
  lptr(lp) = lph
  list(lph) = in2
  lptr(lph) = lpsav
!
!  Delete IO1 as a neighbor of IO2.
!
  lp = lstptr ( lend(io2), in1, list, lptr )
  lph = lptr(lp)
  lptr(lp) = lptr(lph)
!
!  If IO1 is the last neighbor of IO2, make IN1 the last neighbor.
!
  if ( lend(io2) == lph ) then
    lend(io2) = lp
  end if
!
!  Insert IN1 as a neighbor of IN2 following IO2.
!
  lp = lstptr ( lend(in2), io2, list, lptr )
  lpsav = lptr(lp)
  lptr(lp) = lph
  list(lph) = in1
  lptr(lph) = lpsav
  lp21 = lph

  return
end
function swptst ( n1, n2, n3, n4, x, y, z )

!*****************************************************************************80
!
!! SWPTST decides whether to replace a diagonal arc by the other.
!
!  Discussion:
!
!    This function decides whether or not to replace a
!    diagonal arc in a quadrilateral with the other diagonal.
!    The decision will be to swap (SWPTST = TRUE) if and only
!    if N4 lies above the plane (in the half-space not contain-
!    ing the origin) defined by (N1,N2,N3), or equivalently, if
!    the projection of N4 onto this plane is interior to the
!    circumcircle of (N1,N2,N3).  The decision will be for no
!    swap if the quadrilateral is not strictly convex.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N1, N2, N3, N4, indexes of the four nodes
!    defining the quadrilateral with N1 adjacent to N2, and (N1,N2,N3) in
!    counterclockwise order.  The arc connecting N1 to N2 should be replaced
!    by an arc connecting N3 to N4 if SWPTST = TRUE.  Refer to subroutine SWAP.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates of the nodes.
!
!    Output, logical SWPTST, TRUE if and only if the arc connecting N1
!    and N2 should be swapped for an arc connecting N3 and N4.
!
!  Local parameters:
!
!    DX1,DY1,DZ1 = Coordinates of N4->N1
!    DX2,DY2,DZ2 = Coordinates of N4->N2
!    DX3,DY3,DZ3 = Coordinates of N4->N3
!    X4,Y4,Z4 =    Coordinates of N4
!
  implicit none

  real    ( kind = 8 ) dx1
  real    ( kind = 8 ) dx2
  real    ( kind = 8 ) dx3
  real    ( kind = 8 ) dy1
  real    ( kind = 8 ) dy2
  real    ( kind = 8 ) dy3
  real    ( kind = 8 ) dz1
  real    ( kind = 8 ) dz2
  real    ( kind = 8 ) dz3
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) n3
  integer ( kind = 4 ) n4
  logical swptst
  real    ( kind = 8 ) x(*)
  real    ( kind = 8 ) x4
  real    ( kind = 8 ) y(*)
  real    ( kind = 8 ) y4
  real    ( kind = 8 ) z(*)
  real    ( kind = 8 ) z4

  x4 = x(n4)
  y4 = y(n4)
  z4 = z(n4)
  dx1 = x(n1) - x4
  dx2 = x(n2) - x4
  dx3 = x(n3) - x4
  dy1 = y(n1) - y4
  dy2 = y(n2) - y4
  dy3 = y(n3) - y4
  dz1 = z(n1) - z4
  dz2 = z(n2) - z4
  dz3 = z(n3) - z4
!
!  N4 lies above the plane of (N1,N2,N3) iff N3 lies above
!  the plane of (N2,N1,N4) iff Det(N3-N4,N2-N4,N1-N4) =
!  (N3-N4,N2-N4 X N1-N4) > 0.
!
  swptst =  dx3 * ( dy2 * dz1 - dy1 * dz2 ) &
          - dy3 * ( dx2 * dz1 - dx1 * dz2 ) &
          + dz3 * ( dx2 * dy1 - dx1 * dy2 ) > 0.0D+00

  return
end
subroutine timestamp ( )

!*****************************************************************************80
!
!! TIMESTAMP prints the current YMDHMS date as a time stamp.
!
!  Example:
!
!    May 31 2001   9:45:54.872 AM
!
!  Modified:
!
!    26 February 2005
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    None
!
  implicit none

  character ( len = 8 ) ampm
  integer ( kind = 4 ) d
  integer ( kind = 4 ) h
  integer ( kind = 4 ) m
  integer ( kind = 4 ) mm
  character ( len = 9 ), parameter, dimension(12) :: month = (/ &
    'January  ', 'February ', 'March    ', 'April    ', &
    'May      ', 'June     ', 'July     ', 'August   ', &
    'September', 'October  ', 'November ', 'December ' /)
  integer ( kind = 4 ) n
  integer ( kind = 4 ) s
  integer ( kind = 4 ) values(8)
  integer ( kind = 4 ) y

  call date_and_time ( values = values )

  y = values(1)
  m = values(2)
  d = values(3)
  h = values(5)
  n = values(6)
  s = values(7)
  mm = values(8)

  if ( h < 12 ) then
    ampm = 'AM'
  else if ( h == 12 ) then
    if ( n == 0 .and. s == 0 ) then
      ampm = 'Noon'
    else
      ampm = 'PM'
    end if
  else
    h = h - 12
    if ( h < 12 ) then
      ampm = 'PM'
    else if ( h == 12 ) then
      if ( n == 0 .and. s == 0 ) then
        ampm = 'Midnight'
      else
        ampm = 'AM'
      end if
    end if
  end if

  write ( *, '(a,1x,i2,1x,i4,2x,i2,a1,i2.2,a1,i2.2,a1,i3.3,1x,a)' ) &
    trim ( month(m) ), d, y, h, ':', n, ':', s, '.', mm, trim ( ampm )

  return
end
subroutine trans ( n, rlat, rlon, x, y, z )

!*****************************************************************************80
!
!! TRANS transforms spherical coordinates to Cartesian coordinates.
!
!  Discussion:
!
!    This subroutine transforms spherical coordinates into
!    Cartesian coordinates on the unit sphere for input to
!    TRMESH.  Storage for X and Y may coincide with
!    storage for RLAT and RLON if the latter need not be saved.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of nodes (points on the unit
!    sphere) whose coordinates are to be transformed.
!
!    Input, real ( kind = 8 ) RLAT(N), latitudes of the nodes in radians.
!
!    Input, real ( kind = 8 ) RLON(N), longitudes of the nodes in radians.
!
!    Output, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates in the
!    range -1 to 1.  X(I)**2 + Y(I)**2 + Z(I)**2 = 1 for I = 1 to N.
!
!  Local parameters:
!
!    COSPHI = cos(PHI)
!    I =      DO-loop index
!    NN =     Local copy of N
!    PHI =    Latitude
!    THETA =  Longitude
!
  implicit none

  integer ( kind = 4 ) n

  real    ( kind = 8 ) cosphi
  integer ( kind = 4 ) i
  integer ( kind = 4 ) nn
  real    ( kind = 8 ) phi
  real    ( kind = 8 ) rlat(n)
  real    ( kind = 8 ) rlon(n)
  real    ( kind = 8 ) theta
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) z(n)

  nn = n

  do i = 1, nn
    phi = rlat(i)
    theta = rlon(i)
    cosphi = cos ( phi )
    x(i) = cosphi * cos ( theta )
    y(i) = cosphi * sin ( theta )
    z(i) = sin ( phi )
  end do

  return
end
subroutine trfind ( nst, p, n, x, y, z, list, lptr, lend, b1, b2, b3, i1, &
  i2, i3 )

!*****************************************************************************80
!
!! TRFIND locates a point relative to a triangulation.
!
!  Discussion:
!
!    This subroutine locates a point P relative to a triangulation
!    created by TRMESH.  If P is contained in
!    a triangle, the three vertex indexes and barycentric
!    coordinates are returned.  Otherwise, the indexes of the
!    visible boundary nodes are returned.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) NST, index of a node at which TRFIND begins
!    its search.  Search time depends on the proximity of this node to P.
!
!    Input, real ( kind = 8 ) P(3), the x, y, and z coordinates (in that order)
!    of the point P to be located.
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    3 <= N.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates of the
!    triangulation nodes (unit vectors).
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N), the
!    data structure defining the triangulation, created by TRMESH.
!
!    Output, real ( kind = 8 ) B1, B2, B3, the unnormalized barycentric
!    coordinates of the central projection of P onto the underlying planar
!    triangle if P is in the convex hull of the nodes.  These parameters
!    are not altered if I1 = 0.
!
!    Output, integer ( kind = 4 ) I1, I2, I3, the counterclockwise-ordered
!    vertex indexes of a triangle containing P if P is contained in a triangle.
!    If P is not in the convex hull of the nodes, I1 and I2 are the rightmost
!    and leftmost (boundary) nodes that are visible from P, and I3 = 0.  (If
!    all boundary nodes are visible from P, then I1 and I2 coincide.)
!    I1 = I2 = I3 = 0 if P and all of the nodes are coplanar (lie on a
!    common great circle.
!
!  Local parameters:
!
!    EPS =      Machine precision
!    IX,IY,IZ = Integer seeds for JRAND
!    LP =       LIST pointer
!    N0,N1,N2 = Nodes in counterclockwise order defining a
!               cone (with vertex N0) containing P, or end-
!               points of a boundary edge such that P Right
!               N1->N2
!    N1S,N2S =  Initially-determined values of N1 and N2
!    N3,N4 =    Nodes opposite N1->N2 and N2->N1, respectively
!    NEXT =     Candidate for I1 or I2 when P is exterior
!    NF,NL =    First and last neighbors of N0, or first
!               (rightmost) and last (leftmost) nodes
!               visible from P when P is exterior to the
!               triangulation
!    PTN1 =     Scalar product <P,N1>
!    PTN2 =     Scalar product <P,N2>
!    Q =        (N2 X N1) X N2  or  N1 X (N2 X N1) -- used in
!               the boundary traversal when P is exterior
!    S12 =      Scalar product <N1,N2>
!    TOL =      Tolerance (multiple of EPS) defining an upper
!               bound on the magnitude of a negative bary-
!               centric coordinate (B1 or B2) for P in a
!               triangle -- used to avoid an infinite number
!               of restarts with 0 <= B3 < EPS and B1 < 0 or
!               B2 < 0 but small in magnitude
!    XP,YP,ZP = Local variables containing P(1), P(2), and P(3)
!    X0,Y0,Z0 = Dummy arguments for DET
!    X1,Y1,Z1 = Dummy arguments for DET
!    X2,Y2,Z2 = Dummy arguments for DET
!
  implicit none

  integer ( kind = 4 ) n

  real    ( kind = 8 ) b1
  real    ( kind = 8 ) b2
  real    ( kind = 8 ) b3
  real    ( kind = 8 ) det
  real    ( kind = 8 ) eps
  integer ( kind = 4 ) i1
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) i3
  integer ( kind = 4 ), save :: ix = 1
  integer ( kind = 4 ), save :: iy = 2
  integer ( kind = 4 ), save :: iz = 3
  integer ( kind = 4 ) jrand
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) lstptr
  integer ( kind = 4 ) n0
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n1s
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) n2s
  integer ( kind = 4 ) n3
  integer ( kind = 4 ) n4
  integer ( kind = 4 ) next
  integer ( kind = 4 ) nf
  integer ( kind = 4 ) nl
  integer ( kind = 4 ) nst
  real    ( kind = 8 ) p(3)
  real    ( kind = 8 ) ptn1
  real    ( kind = 8 ) ptn2
  real    ( kind = 8 ) q(3)
  real    ( kind = 8 ) s12
  real    ( kind = 8 ) store
  real    ( kind = 8 ) tol
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) x0
  real    ( kind = 8 ) x1
  real    ( kind = 8 ) x2
  real    ( kind = 8 ) xp
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) y0
  real    ( kind = 8 ) y1
  real    ( kind = 8 ) y2
  real    ( kind = 8 ) yp
  real    ( kind = 8 ) z(n)
  real    ( kind = 8 ) z0
  real    ( kind = 8 ) z1
  real    ( kind = 8 ) z2
  real    ( kind = 8 ) zp
!
!  Statement function:
!
!  DET(X1,...,Z0) >= 0 if and only if (X0,Y0,Z0) is in the
!  (closed) left hemisphere defined by the plane containing (0,0,0),
!  (X1,Y1,Z1), and (X2,Y2,Z2), where left is defined relative to an
!  observer at (X1,Y1,Z1) facing (X2,Y2,Z2).
!
  det (x1,y1,z1,x2,y2,z2,x0,y0,z0) = x0*(y1*z2-y2*z1) &
       - y0*(x1*z2-x2*z1) + z0*(x1*y2-x2*y1)
!
!  Initialize variables.
!
  xp = p(1)
  yp = p(2)
  zp = p(3)
  n0 = nst

  if ( n0 < 1 .or. n < n0 ) then
    n0 = jrand ( n, ix, iy, iz )
  end if
!
!  Compute the relative machine precision EPS and TOL.
!
  eps = epsilon ( eps )
  tol = 100.0D+00 * eps
!
!  Set NF and NL to the first and last neighbors of N0, and initialize N1 = NF.
!
2 continue

  lp = lend(n0)
  nl = list(lp)
  lp = lptr(lp)
  nf = list(lp)
  n1 = nf
!
!  Find a pair of adjacent neighbors N1,N2 of N0 that define
!  a wedge containing P:  P LEFT N0->N1 and P RIGHT N0->N2.
!
  if ( 0 < nl ) then
!
!  N0 is an interior node.  Find N1.
!
3   continue

    if ( det ( x(n0),y(n0),z(n0),x(n1),y(n1),z(n1),xp,yp,zp ) < 0.0D+00 ) then
      lp = lptr(lp)
      n1 = list(lp)
      if ( n1 == nl ) then
        go to 6
      end if
      go to 3
    end if

  else
!
!  N0 is a boundary node.  Test for P exterior.
!
    nl = -nl
!
!  Is P to the right of the boundary edge N0->NF?
!
    if ( det(x(n0),y(n0),z(n0),x(nf),y(nf),z(nf), xp,yp,zp) < 0.0D+00 ) then
      n1 = n0
      n2 = nf
      go to 9
    end if
!
!  Is P to the right of the boundary edge NL->N0?
!
    if ( det(x(nl),y(nl),z(nl),x(n0),y(n0),z(n0),xp,yp,zp) < 0.0D+00 ) then
      n1 = nl
      n2 = n0
      go to 9
    end if

  end if
!
!  P is to the left of arcs N0->N1 and NL->N0.  Set N2 to the
!  next neighbor of N0 (following N1).
!
4 continue

    lp = lptr(lp)
    n2 = abs ( list(lp) )

    if ( det(x(n0),y(n0),z(n0),x(n2),y(n2),z(n2),xp,yp,zp) < 0.0D+00 ) then
      go to 7
    end if

    n1 = n2

    if ( n1 /= nl ) then
      go to 4
    end if

  if ( det ( x(n0), y(n0), z(n0), x(nf), y(nf), z(nf), xp, yp, zp ) &
    < 0.0D+00 ) then
    go to 6
  end if
!
!  P is left of or on arcs N0->NB for all neighbors NB
!  of N0.  Test for P = +/-N0.
!
  if ( store ( abs ( x(n0 ) * xp + y(n0) * yp + z(n0) * zp) ) &
    < 1.0D+00 - 4.0D+00 * eps ) then
!
!  All points are collinear iff P Left NB->N0 for all
!  neighbors NB of N0.  Search the neighbors of N0.
!  Note:  N1 = NL and LP points to NL.
!
    do
      if ( det(x(n1),y(n1),z(n1),x(n0),y(n0),z(n0),xp,yp,zp) < 0.0D+00 ) then
        exit
      end if

      lp = lptr(lp)
      n1 = abs ( list(lp) )

      if ( n1 == nl ) then
        i1 = 0
        i2 = 0
        i3 = 0
        return
      end if

    end do

  end if
!
!  P is to the right of N1->N0, or P = +/-N0.  Set N0 to N1 and start over.
!
  n0 = n1
  go to 2
!
!  P is between arcs N0->N1 and N0->NF.
!
6 continue

  n2 = nf
!
!  P is contained in a wedge defined by geodesics N0-N1 and
!  N0-N2, where N1 is adjacent to N2.  Save N1 and N2 to
!  test for cycling.
!
7 continue

  n3 = n0
  n1s = n1
  n2s = n2
!
!  Top of edge-hopping loop:
!
8 continue

  b3 = det ( x(n1),y(n1),z(n1),x(n2),y(n2),z(n2),xp,yp,zp )

  if ( b3 < 0.0D+00 ) then
!
!  Set N4 to the first neighbor of N2 following N1 (the
!  node opposite N2->N1) unless N1->N2 is a boundary arc.
!
    lp = lstptr ( lend(n2), n1, list, lptr )

    if ( list(lp) < 0 ) then
      go to 9
    end if

    lp = lptr(lp)
    n4 = abs ( list(lp) )
!
!  Define a new arc N1->N2 which intersects the geodesic N0-P.
!
    if ( det ( x(n0),y(n0),z(n0),x(n4),y(n4),z(n4),xp,yp,zp ) < 0.0D+00 ) then
      n3 = n2
      n2 = n4
      n1s = n1
      if ( n2 /= n2s .and. n2 /= n0 ) then
        go to 8
      end if
    else
      n3 = n1
      n1 = n4
      n2s = n2
      if ( n1 /= n1s .and. n1 /= n0 ) then
        go to 8
      end if
    end if
!
!  The starting node N0 or edge N1-N2 was encountered
!  again, implying a cycle (infinite loop).  Restart
!  with N0 randomly selected.
!
    n0 = jrand ( n, ix, iy, iz )
    go to 2

  end if
!
!  P is in (N1,N2,N3) unless N0, N1, N2, and P are collinear
!  or P is close to -N0.
!
  if ( b3 >= eps ) then
!
!  B3 /= 0.
!
    b1 = det(x(n2),y(n2),z(n2),x(n3),y(n3),z(n3),xp,yp,zp)
    b2 = det(x(n3),y(n3),z(n3),x(n1),y(n1),z(n1),xp,yp,zp)
!
!  Restart with N0 randomly selected.
!
    if ( b1 < -tol .or. b2 < -tol ) then
      n0 = jrand ( n, ix, iy, iz )
      go to 2
    end if

  else
!
!  B3 = 0 and thus P lies on N1->N2. Compute
!  B1 = Det(P,N2 X N1,N2) and B2 = Det(P,N1,N2 X N1).
!
    b3 = 0.0D+00
    s12 = x(n1) * x(n2) + y(n1) * y(n2) + z(n1) * z(n2)
    ptn1 = xp * x(n1) + yp * y(n1) + zp * z(n1)
    ptn2 = xp * x(n2) + yp * y(n2) + zp * z(n2)
    b1 = ptn1 - s12 * ptn2
    b2 = ptn2 - s12 * ptn1
!
!  Restart with N0 randomly selected.
!
    if ( b1 < -tol .or. b2 < -tol ) then
      n0 = jrand ( n, ix, iy, iz )
      go to 2
    end if

  end if
!
!  P is in (N1,N2,N3).
!
  i1 = n1
  i2 = n2
  i3 = n3
  b1 = max ( b1, 0.0D+00 )
  b2 = max ( b2, 0.0D+00 )
  return
!
!  P Right N1->N2, where N1->N2 is a boundary edge.
!  Save N1 and N2, and set NL = 0 to indicate that
!  NL has not yet been found.
!
9 continue

  n1s = n1
  n2s = n2
  nl = 0
!
!  Counterclockwise Boundary Traversal:
!
10 continue

  lp = lend(n2)
  lp = lptr(lp)
  next = list(lp)

  if ( det(x(n2),y(n2),z(n2),x(next),y(next),z(next),xp,yp,zp) >= 0.0D+00 ) then
!
!  N2 is the rightmost visible node if P Forward N2->N1
!  or NEXT Forward N2->N1.  Set Q to (N2 X N1) X N2.
!
    s12 = x(n1) * x(n2) + y(n1) * y(n2) + z(n1) * z(n2)

    q(1) = x(n1) - s12 * x(n2)
    q(2) = y(n1) - s12 * y(n2)
    q(3) = z(n1) - s12 * z(n2)

    if ( xp * q(1) + yp * q(2) + zp * q(3) >= 0.0D+00 ) then
      go to 11
    end if

    if ( x(next) * q(1) + y(next) * q(2) + z(next) * q(3) >= 0.0D+00 ) then
      go to 11
    end if
!
!  N1, N2, NEXT, and P are nearly collinear, and N2 is
!  the leftmost visible node.
!
    nl = n2
  end if
!
!  Bottom of counterclockwise loop:
!
  n1 = n2
  n2 = next

  if ( n2 /= n1s ) then
    go to 10
  end if
!
!  All boundary nodes are visible from P.
!
  i1 = n1s
  i2 = n1s
  i3 = 0
  return
!
!  N2 is the rightmost visible node.
!
11 continue

  nf = n2

  if ( nl == 0 ) then
!
!  Restore initial values of N1 and N2, and begin the search
!  for the leftmost visible node.
!
    n2 = n2s
    n1 = n1s
!
!  Clockwise Boundary Traversal:
!
12  continue

    lp = lend(n1)
    next = -list(lp)

    if ( det(x(next),y(next),z(next),x(n1),y(n1),z(n1),xp,yp,zp) >= 0.0D+00 ) then
!
!  N1 is the leftmost visible node if P or NEXT is
!  forward of N1->N2.  Compute Q = N1 X (N2 X N1).
!
      s12 = x(n1) * x(n2) + y(n1) * y(n2) + z(n1) * z(n2)
      q(1) = x(n2) - s12 * x(n1)
      q(2) = y(n2) - s12 * y(n1)
      q(3) = z(n2) - s12 * z(n1)

      if ( xp * q(1) + yp * q(2) + zp * q(3) >= 0.0D+00 ) then
        go to 13
      end if

      if ( x(next) * q(1) + y(next) * q(2) + z(next) * q(3) >= 0.0D+00 ) then
        go to 13
      end if
!
!  P, NEXT, N1, and N2 are nearly collinear and N1 is the rightmost
!  visible node.
!
      nf = n1
    end if
!
!  Bottom of clockwise loop:
!
    n2 = n1
    n1 = next

    if ( n1 /= n1s ) then
      go to 12
    end if
!
!  All boundary nodes are visible from P.
!
    i1 = n1
    i2 = n1
    i3 = 0
    return
!
!  N1 is the leftmost visible node.
!
13   continue

    nl = n1

  end if
!
!  NF and NL have been found.
!
  i1 = nf
  i2 = nl
  i3 = 0

  return
end
subroutine trlist ( n, list, lptr, lend, nrow, nt, ltri, ier )

!*****************************************************************************80
!
!! TRLIST converts a triangulation data structure to a triangle list.
!
!  Discussion:
!
!    This subroutine converts a triangulation data structure
!    from the linked list created by TRMESH to a triangle list.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    3 <= N.
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N), linked
!    list data structure defining the triangulation.  Refer to TRMESH.
!
!    Input, integer ( kind = 4 ) NROW, the number of rows (entries per triangle)
!    reserved for the triangle list LTRI.  The value must be 6 if only the
!    vertex indexes and neighboring triangle indexes are to be stored, or 9
!    if arc indexes are also to be assigned and stored.  Refer to LTRI.
!
!    Output, integer ( kind = 4 ) NT, the number of triangles in the
!    triangulation unless IER /=0, in which case NT = 0.  NT = 2N-NB-2 if
!    NB >= 3 or 2N-4 if NB = 0, where NB is the number of boundary nodes.
!
!    Output, integer ( kind = 4 ) LTRI(NROW,*).  The second dimension of LTRI
!    must be at least NT, where NT will be at most 2*N-4.  The J-th column
!    contains the vertex nodal indexes (first three rows), neighboring triangle
!    indexes (second three rows), and, if NROW = 9, arc indexes (last three
!    rows) associated with triangle J for J = 1,...,NT.  The vertices are
!    ordered counterclockwise with the first vertex taken to be the one
!    with smallest index.  Thus, LTRI(2,J) and LTRI(3,J) are larger than
!    LTRI(1,J) and index adjacent neighbors of node LTRI(1,J).  For
!    I = 1,2,3, LTRI(I+3,J) and LTRI(I+6,J) index the triangle and arc,
!    respectively, which are opposite (not shared by) node LTRI(I,J), with
!    LTRI(I+3,J) = 0 if LTRI(I+6,J) indexes a boundary arc.  Vertex indexes
!    range from 1 to N, triangle indexes from 0 to NT, and, if included,
!    arc indexes from 1 to NA, where NA = 3N-NB-3 if NB >= 3 or 3N-6 if
!    NB = 0.  The triangles are ordered on first (smallest) vertex indexes.
!
!    Output, integer ( kind = 4 ) IER, error indicator.
!    0, if no errors were encountered.
!    1, if N or NROW is outside its valid range on input.
!    2, if the triangulation data structure (LIST,LPTR,LEND) is invalid.
!      Note, however, that these arrays are not completely tested for validity.
!
!  Local parameters:
!
!    ARCS =     Logical variable with value TRUE iff are
!               indexes are to be stored
!    I,J =      LTRI row indexes (1 to 3) associated with
!               triangles KT and KN, respectively
!    I1,I2,I3 = Nodal indexes of triangle KN
!    ISV =      Variable used to permute indexes I1,I2,I3
!    KA =       Arc index and number of currently stored arcs
!    KN =       Index of the triangle that shares arc I1-I2 with KT
!    KT =       Triangle index and number of currently stored triangles
!    LP =       LIST pointer
!    LP2 =      Pointer to N2 as a neighbor of N1
!    LPL =      Pointer to the last neighbor of I1
!    LPLN1 =    Pointer to the last neighbor of N1
!    N1,N2,N3 = Nodal indexes of triangle KT
!    NM2 =      N-2
!
  implicit none

  integer ( kind = 4 ) n
  integer ( kind = 4 ) nrow

  logical arcs
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i1
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) i3
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) isv
  integer ( kind = 4 ) j
  integer ( kind = 4 ) ka
  integer ( kind = 4 ) kn
  integer ( kind = 4 ) kt
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lp2
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lpln1
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) ltri(nrow,*)
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) n3
  integer ( kind = 4 ) nm2
  integer ( kind = 4 ) nt
!
!  Test for invalid input parameters.
!
  if ( n < 3 .or. ( nrow /= 6 .and. nrow /= 9 ) ) then
    nt = 0
    ier = 1
    return
  end if
!
!  Initialize parameters for loop on triangles KT = (N1,N2,
!  N3), where N1 < N2 and N1 < N3.
!
!  ARCS = TRUE iff arc indexes are to be stored.
!  KA,KT = Numbers of currently stored arcs and triangles.
!  NM2 = Upper bound on candidates for N1.
!
  arcs = nrow == 9
  ka = 0
  kt = 0
  nm2 = n-2
!
!  Loop on nodes N1.
!
  do n1 = 1, nm2
!
!  Loop on pairs of adjacent neighbors (N2,N3).  LPLN1 points
!  to the last neighbor of N1, and LP2 points to N2.
!
    lpln1 = lend(n1)
    lp2 = lpln1

1   continue

      lp2 = lptr(lp2)
      n2 = list(lp2)
      lp = lptr(lp2)
      n3 = abs ( list(lp) )

      if ( n2 < n1 .or. n3 < n1 ) then
        go to 8
      end if
!
!  Add a new triangle KT = (N1,N2,N3).
!
      kt = kt + 1
      ltri(1,kt) = n1
      ltri(2,kt) = n2
      ltri(3,kt) = n3
!
!  Loop on triangle sides (I2,I1) with neighboring triangles
!  KN = (I1,I2,I3).
!
      do i = 1, 3

        if ( i == 1 ) then
          i1 = n3
          i2 = n2
        else if ( i == 2 ) then
          i1 = n1
          i2 = n3
        else
          i1 = n2
          i2 = n1
        end if
!
!  Set I3 to the neighbor of I1 that follows I2 unless
!  I2->I1 is a boundary arc.
!
        lpl = lend(i1)
        lp = lptr(lpl)

        do

          if ( list(lp) == i2 ) then
            go to 3
          end if

          lp = lptr(lp)

          if ( lp == lpl ) then
            exit
          end if

        end do
!
!  Invalid triangulation data structure:  I1 is a neighbor of
!  I2, but I2 is not a neighbor of I1.
!
        if ( abs ( list(lp) ) /= i2 ) then
          nt = 0
          ier = 2
          return
        end if
!
!  I2 is the last neighbor of I1.  Bypass the search for a neighboring
!  triangle if I2->I1 is a boundary arc.
!
        kn = 0

        if ( list(lp) < 0 ) then
          go to 6
        end if
!
!  I2->I1 is not a boundary arc, and LP points to I2 as
!  a neighbor of I1.
!
3       continue

        lp = lptr(lp)
        i3 = abs ( list(lp) )
!
!  Find J such that LTRI(J,KN) = I3 (not used if KT < KN),
!  and permute the vertex indexes of KN so that I1 is smallest.
!
        if ( i1 < i2 .and. i1 < i3 ) then
          j = 3
        else if ( i2 < i3 ) then
          j = 2
          isv = i1
          i1 = i2
          i2 = i3
          i3 = isv
        else
          j = 1
          isv = i1
          i1 = i3
          i3 = i2
          i2 = isv
        end if
!
!  Test for KT < KN (triangle index not yet assigned).
!
        if ( n1 < i1 ) then
          cycle
        end if
!
!  Find KN, if it exists, by searching the triangle list in
!  reverse order.
!
        do kn = kt-1, 1, -1
          if ( ltri(1,kn) == i1 .and. &
               ltri(2,kn) == i2 .and. &
               ltri(3,kn) == i3 ) then
            go to 5
          end if
        end do

        cycle
!
!  Store KT as a neighbor of KN.
!
5       continue

        ltri(j+3,kn) = kt
!
!  Store KN as a neighbor of KT, and add a new arc KA.
!
6       continue

        ltri(i+3,kt) = kn

        if ( arcs ) then
          ka = ka + 1
          ltri(i+6,kt) = ka
          if ( kn /= 0 ) then
            ltri(j+6,kn) = ka
          end if
        end if

        end do
!
!  Bottom of loop on triangles.
!
8     continue

      if ( lp2 /= lpln1 ) then
        go to 1
      end if

9     continue

  end do

  nt = kt
  ier = 0

  return
end
subroutine trlist2 ( n, list, lptr, lend, nt, ltri, ier )

!*****************************************************************************80
!
!! TRLIST2 converts a triangulation data structure to a triangle list.
!
!  Discussion:
!
!    This subroutine converts a triangulation data structure
!    from the linked list created by TRMESH to a triangle list.
!
!    It is a version of TRLIST for the special case where the triangle
!    list should only include the nodes that define each triangle.
!
!  Modified:
!
!    21 July 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    3 <= N.
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N), linked
!    list data structure defining the triangulation.  Refer to TRMESH.
!
!    Output, integer ( kind = 4 ) NT, the number of triangles in the
!    triangulation unless IER /=0, in which case NT = 0.  NT = 2N-NB-2 if
!    NB >= 3 or 2N-4 if NB = 0, where NB is the number of boundary nodes.
!
!    Output, integer ( kind = 4 ) LTRI(3,*).  The second dimension of LTRI
!    must be at least NT, where NT will be at most 2*N-4.  The J-th column
!    contains the vertex nodal indexes associated with triangle J for
!    J = 1,...,NT.  The vertices are ordered counterclockwise with the first
!    vertex taken to be the one with smallest index.  Thus, LTRI(2,J) and
!    LTRI(3,J) are larger than LTRI(1,J) and index adjacent neighbors of node
!    LTRI(1,J).  The triangles are ordered on first (smallest) vertex indexes.
!
!    Output, integer ( kind = 4 ) IER, error indicator.
!    0, if no errors were encountered.
!    1, if N is outside its valid range on input.
!    2, if the triangulation data structure (LIST,LPTR,LEND) is invalid.
!      Note, however, that these arrays are not completely tested for validity.
!
!  Local parameters:
!
!    I,J =      LTRI row indexes (1 to 3) associated with
!               triangles KT and KN, respectively
!    I1,I2,I3 = Nodal indexes of triangle KN
!    ISV =      Variable used to permute indexes I1,I2,I3
!    KA =       Arc index and number of currently stored arcs
!    KN =       Index of the triangle that shares arc I1-I2 with KT
!    KT =       Triangle index and number of currently stored triangles
!    LP =       LIST pointer
!    LP2 =      Pointer to N2 as a neighbor of N1
!    LPL =      Pointer to the last neighbor of I1
!    LPLN1 =    Pointer to the last neighbor of N1
!    N1,N2,N3 = Nodal indexes of triangle KT
!    NM2 =      N-2
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) i
  integer ( kind = 4 ) i1
  integer ( kind = 4 ) i2
  integer ( kind = 4 ) i3
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) isv
  integer ( kind = 4 ) j
  integer ( kind = 4 ) ka
  integer ( kind = 4 ) kn
  integer ( kind = 4 ) kt
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lp2
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lpln1
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) ltri(3,*)
  integer ( kind = 4 ) n1
  integer ( kind = 4 ) n2
  integer ( kind = 4 ) n3
  integer ( kind = 4 ) nm2
  integer ( kind = 4 ) nt
!
!  Test for invalid input parameters.
!
  if ( n < 3 ) then
    nt = 0
    ier = 1
    return
  end if
!
!  Initialize parameters for loop on triangles KT = (N1,N2,
!  N3), where N1 < N2 and N1 < N3.
!
!  KA,KT = Numbers of currently stored arcs and triangles.
!  NM2 = Upper bound on candidates for N1.
!
  ka = 0
  kt = 0
  nm2 = n-2
!
!  Loop on nodes N1.
!
  do n1 = 1, nm2
!
!  Loop on pairs of adjacent neighbors (N2,N3).  LPLN1 points
!  to the last neighbor of N1, and LP2 points to N2.
!
    lpln1 = lend(n1)
    lp2 = lpln1

1   continue

      lp2 = lptr(lp2)
      n2 = list(lp2)
      lp = lptr(lp2)
      n3 = abs ( list(lp) )

      if ( n2 < n1 .or. n3 < n1 ) then
        go to 8
      end if
!
!  Add a new triangle KT = (N1,N2,N3).
!
      kt = kt + 1
      ltri(1,kt) = n1
      ltri(2,kt) = n2
      ltri(3,kt) = n3
!
!  Loop on triangle sides (I2,I1) with neighboring triangles
!  KN = (I1,I2,I3).
!
      do i = 1, 3

        if ( i == 1 ) then
          i1 = n3
          i2 = n2
        else if ( i == 2 ) then
          i1 = n1
          i2 = n3
        else
          i1 = n2
          i2 = n1
        end if
!
!  Set I3 to the neighbor of I1 that follows I2 unless
!  I2->I1 is a boundary arc.
!
        lpl = lend(i1)
        lp = lptr(lpl)

        do

          if ( list(lp) == i2 ) then
            go to 3
          end if

          lp = lptr(lp)

          if ( lp == lpl ) then
            exit
          end if

        end do
!
!  Invalid triangulation data structure:  I1 is a neighbor of
!  I2, but I2 is not a neighbor of I1.
!
        if ( abs ( list(lp) ) /= i2 ) then
          nt = 0
          ier = 2
          return
        end if
!
!  I2 is the last neighbor of I1.  Bypass the search for a neighboring
!  triangle if I2->I1 is a boundary arc.
!
        kn = 0

        if ( list(lp) < 0 ) then
          go to 6
        end if
!
!  I2->I1 is not a boundary arc, and LP points to I2 as
!  a neighbor of I1.
!
3       continue

        lp = lptr(lp)
        i3 = abs ( list(lp) )
!
!  Find J such that LTRI(J,KN) = I3 (not used if KT < KN),
!  and permute the vertex indexes of KN so that I1 is smallest.
!
        if ( i1 < i2 .and. i1 < i3 ) then
          j = 3
        else if ( i2 < i3 ) then
          j = 2
          isv = i1
          i1 = i2
          i2 = i3
          i3 = isv
        else
          j = 1
          isv = i1
          i1 = i3
          i3 = i2
          i2 = isv
        end if
!
!  Test for KT < KN (triangle index not yet assigned).
!
        if ( n1 < i1 ) then
          cycle
        end if
!
!  Find KN, if it exists, by searching the triangle list in
!  reverse order.
!
        do kn = kt-1, 1, -1
          if ( ltri(1,kn) == i1 .and. &
               ltri(2,kn) == i2 .and. &
               ltri(3,kn) == i3 ) then
            go to 5
          end if
        end do

        cycle

5       continue

6       continue

        end do
!
!  Bottom of loop on triangles.
!
8     continue

      if ( lp2 /= lpln1 ) then
        go to 1
      end if

9     continue

  end do

  nt = kt
  ier = 0

  return
end
subroutine trlprt ( n, x, y, z, iflag, nrow, nt, ltri )

!*****************************************************************************80
!
!! TRLPRT prints a triangle list.
!
!  Discussion:
!
!    This subroutine prints the triangle list created by TRLIST
!    and, optionally, the nodal coordinates
!    (either latitude and longitude or Cartesian coordinates).
!    The numbers of boundary nodes, triangles, and arcs are also printed.
!
!  Modified:
!
!    06 June 2002
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    3 <= N <= 9999.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates of the nodes if
!    IFLAG = 0, or (X and Y only) longitude and latitude, respectively,
!    if 0 < IFLAG, or unused dummy parameters if IFLAG < 0.
!
!    Input, integer ( kind = 4 ) IFLAG, nodal coordinate option indicator:
!    = 0, if X, Y, and Z (assumed to contain Cartesian coordinates) are to
!      be printed (to 6 decimal places).
!    > 0, if only X and Y (assumed to contain longitude and latitude) are
!      to be printed (to 6 decimal places).
!    < 0, if only the adjacency lists are to be printed.
!
!    Input, integer ( kind = 4 ) NROW, the number of rows (entries per triangle)
!    reserved for the triangle list LTRI.  The value must be 6 if only the
!    vertex indexes and neighboring triangle indexes are stored, or 9
!    if arc indexes are also stored.
!
!    Input, integer ( kind = 4 ) NT, the number of triangles in the
!    triangulation.  1 <= NT <= 9999.
!
!    Input, integer ( kind = 4 ) LTRI(NROW,NT), the J-th column contains the
!    vertex nodal indexes (first three rows), neighboring triangle indexes
!    (second three rows), and, if NROW = 9, arc indexes (last three rows)
!    associated with triangle J for J = 1,...,NT.
!
!  Local parameters:
!
!    I =     DO-loop, nodal index, and row index for LTRI
!    K =     DO-loop and triangle index
!    NA =    Number of triangulation arcs
!    NB =    Number of boundary nodes
!    NL =    Number of lines printed on the current page
!    NLMAX = Maximum number of print lines per page (except
!            for the last page which may have two additional lines)
!    NMAX =  Maximum value of N and NT (4-digit format)
!
  implicit none

  integer ( kind = 4 ) n
  integer ( kind = 4 ) nrow
  integer ( kind = 4 ) nt

  integer ( kind = 4 ) i
  integer ( kind = 4 ) iflag
  integer ( kind = 4 ) k
  integer ( kind = 4 ) ltri(nrow,nt)
  integer ( kind = 4 ) na
  integer ( kind = 4 ) nb
  integer ( kind = 4 ) nl
  integer ( kind = 4 ), parameter :: nlmax = 58
  integer ( kind = 4 ), parameter :: nmax = 9999
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) z(n)
!
!  Print a heading and test for invalid input.
!
  write (*,100) n
  nl = 3

  if ( n < 3 .or. nmax < n .or. &
      ( nrow /= 6 .and. nrow /= 9)  .or. &
      nt < 1 .or. nmax < nt ) then
    write (*,110) n, nrow, nt
    return
  end if
!
!  Print X, Y, and Z.
!
  if ( iflag == 0 ) then

    write (*,101)
    nl = 6

    do i = 1, n
      if ( nlmax <= nl ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        nl = 0
      end if
      write (*,103) i, x(i), y(i), z(i)
      nl = nl + 1
    end do
!
!  Print X (longitude) and Y (latitude).
!
  else if ( 0 < iflag ) then

    write ( *, 102 )
    nl = 6

    do i = 1, n

      if ( nlmax <= nl ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        nl = 0
      end if

      write (*,104) i, x(i), y(i)
      nl = nl + 1

    end do

  end if
!
!  Print the triangulation LTRI.
!
  if ( nlmax / 2 < nl ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) ' '
    nl = 0
  end if

  if ( nrow == 6 ) then
    write (*,105)
  else
    write (*,106)
  end if

  nl = nl + 5

  do k = 1, nt
    if ( nlmax <= nl ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) ' '
      nl = 0
    end if
    write (*,107) k, ltri(1:nrow,k)
    nl = nl + 1
  end do
!
!  Print NB, NA, and NT (boundary nodes, arcs, and triangles).
!
  nb = 2 * n - nt - 2

  if ( nb < 3 ) then
    nb = 0
    na = 3 * n - 6
  else
    na = nt + n - 1
  end if

  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' ) '  Number of boundary nodes NB = ', nb
  write ( *, '(a,i8)' ) '  Number of arcs NA =           ', na
  write ( *, '(a,i8)' ) '  Number of triangles NT =      ', nt
  return
!
!  Print formats:
!
  100 format (///18x,'STRIPACK (TRLIST) output,  n = ',i4)
  101 format (//8x,'Node',10x,'X(node)',10x,'Y(node)',10x, &
          'Z(node)'//)
  102 format (//16x,'Node        Longitude         Latitude'//)
  103 format (8x,i4,3e17.6)
  104 format (16x,i4,2e17.6)
  105 format (//' triangle',8x,'vertices',12x,'neighbors'/ &
          4x,'kt',7x,'n1',5x,'n2',5x,'n3',4x,'kt1',4x, &
          'kt2',4x,'kt3'/)
  106 format (//'triangle',8x,'vertices',12x,'neighbors',14x,'arcs'/ &
          4x,'kt       n1     n2     n3    kt1',4x, &
          'kt2    kt3    ka1    ka2    ka3'/)
  107 format (2x,i4,2x,6(3x,i4),3(2x,i5))
  110 format (//1x,10x,'Invalid parameter:  N =',i5, &
          ', nrow =',i5,', nt =',i5,' ***')
end
subroutine trmesh ( n, x, y, z, list, lptr, lend, lnew, near, next, dist, ier )

!*****************************************************************************80
!
!! TRMESH creates a Delaunay triangulation on the unit sphere.
!
!  Discussion:
!
!    This subroutine creates a Delaunay triangulation of a
!    set of N arbitrarily distributed points, referred to as
!    nodes, on the surface of the unit sphere.  The Delaunay
!    triangulation is defined as a set of (spherical) triangles
!    with the following five properties:
!
!     1)  The triangle vertices are nodes.
!     2)  No triangle contains a node other than its vertices.
!     3)  The interiors of the triangles are pairwise disjoint.
!     4)  The union of triangles is the convex hull of the set
!           of nodes (the smallest convex set that contains
!           the nodes).  If the nodes are not contained in a
!           single hemisphere, their convex hull is the
!           entire sphere and there are no boundary nodes.
!           Otherwise, there are at least three boundary nodes.
!     5)  The interior of the circumcircle of each triangle
!           contains no node.
!
!    The first four properties define a triangulation, and the
!    last property results in a triangulation which is as close
!    as possible to equiangular in a certain sense and which is
!    uniquely defined unless four or more nodes lie in a common
!    plane.  This property makes the triangulation well-suited
!    for solving closest-point problems and for triangle-based
!    interpolation.
!
!    Provided the nodes are randomly ordered, the algorithm
!    has expected time complexity O(N*log(N)) for most nodal
!    distributions.  Note, however, that the complexity may be
!    as high as O(N**2) if, for example, the nodes are ordered
!    on increasing latitude.
!
!    Spherical coordinates (latitude and longitude) may be
!    converted to Cartesian coordinates by Subroutine TRANS.
!
!    The following is a list of the software package modules
!    which a user may wish to call directly:
!
!    ADDNOD - Updates the triangulation by appending a new node.
!
!    AREAS  - Returns the area of a spherical triangle.
!
!    BNODES - Returns an array containing the indexes of the
!             boundary nodes (if any) in counterclockwise
!             order.  Counts of boundary nodes, triangles,
!             and arcs are also returned.
!
!    CIRCUM - Returns the circumcenter of a spherical triangle.
!
!    CRLIST - Returns the set of triangle circumcenters
!             (Voronoi vertices) and circumradii associated
!             with a triangulation.
!
!    DELARC - Deletes a boundary arc from a triangulation.
!
!    DELNOD - Updates the triangulation with a nodal deletion.
!
!    EDGE   - Forces an arbitrary pair of nodes to be connected
!             by an arc in the triangulation.
!
!    GETNP  - Determines the ordered sequence of L closest nodes
!             to a given node, along with the associated distances.
!
!    INSIDE - Locates a point relative to a polygon on the
!             surface of the sphere.
!
!    INTRSC - Returns the point of intersection between a
!             pair of great circle arcs.
!
!    JRAND  - Generates a uniformly distributed pseudo-random integer.
!
!    LEFT   - Locates a point relative to a great circle.
!
!    NEARND - Returns the index of the nearest node to an
!             arbitrary point, along with its squared
!             distance.
!
!    SCOORD - Converts a point from Cartesian coordinates to
!             spherical coordinates.
!
!    STORE  - Forces a value to be stored in main memory so
!             that the precision of floating point numbers
!             in memory locations rather than registers is
!             computed.
!
!    TRANS  - Transforms spherical coordinates into Cartesian
!             coordinates on the unit sphere for input to
!             Subroutine TRMESH.
!
!    TRLIST - Converts the triangulation data structure to a
!             triangle list more suitable for use in a finite
!             element code.
!
!    TRLPRT - Prints the triangle list created by TRLIST.
!
!    TRMESH - Creates a Delaunay triangulation of a set of
!             nodes.
!
!    TRPLOT - Creates a level-2 Encapsulated Postscript (EPS)
!             file containing a triangulation plot.
!
!    TRPRNT - Prints the triangulation data structure and,
!             optionally, the nodal coordinates.
!
!    VRPLOT - Creates a level-2 Encapsulated Postscript (EPS)
!             file containing a Voronoi diagram plot.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    3 <= N.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates of distinct
!    nodes.  (X(K),Y(K), Z(K)) is referred to as node K, and K is referred
!    to as a nodal index.  It is required that X(K)**2 + Y(K)**2 + Z(K)**2 = 1
!    for all K.  The first three nodes must not be collinear (lie on a
!    common great circle).
!
!    Output, integer ( kind = 4 ) LIST(6*(N-2)), nodal indexes which, along
!    with LPTR, LEND, and LNEW, define the triangulation as a set of N
!    adjacency lists; counterclockwise-ordered sequences of neighboring nodes
!    such that the first and last neighbors of a boundary node are boundary
!    nodes (the first neighbor of an interior node is arbitrary).  In order to
!    distinguish between interior and boundary nodes, the last neighbor of
!    each boundary node is represented by the negative of its index.
!
!    Output, integer ( kind = 4 ) LPTR(6*(N-2)), = Set of pointers (LIST
!    indexes) in one-to-one correspondence with the elements of LIST.
!    LIST(LPTR(I)) indexes the node which follows LIST(I) in cyclical
!    counterclockwise order (the first neighbor follows the last neighbor).
!
!    Output, integer ( kind = 4 ) LEND(N), pointers to adjacency lists.
!    LEND(K) points to the last neighbor of node K.  LIST(LEND(K)) < 0 if and
!    only if K is a boundary node.
!
!    Output, integer ( kind = 4 ) LNEW, pointer to the first empty location
!    in LIST and LPTR (list length plus one).  LIST, LPTR, LEND, and LNEW are
!    not altered if IER < 0, and are incomplete if 0 < IER.
!
!    Workspace, integer ( kind = 4 ) NEAR(N),
!    used to efficiently determine the nearest triangulation node to each
!    unprocessed node for use by ADDNOD.
!
!    Workspace, integer ( kind = 4 ) NEXT(N),
!    used to efficiently determine the nearest triangulation node to each
!    unprocessed node for use by ADDNOD.
!
!    Workspace, real ( kind = 8 ) DIST(N),
!    used to efficiently determine the nearest triangulation node to each
!    unprocessed node for use by ADDNOD.
!
!    Output, integer ( kind = 4 ) IER, error indicator:
!     0, if no errors were encountered.
!    -1, if N < 3 on input.
!    -2, if the first three nodes are collinear.
!     L, if nodes L and M coincide for some L < M.  The data structure
!      represents a triangulation of nodes 1 to M-1 in this case.
!
!  Local parameters:
!
!    D =        (Negative cosine of) distance from node K to node I
!    D1,D2,D3 = Distances from node K to nodes 1, 2, and 3, respectively
!    I,J =      Nodal indexes
!    I0 =       Index of the node preceding I in a sequence of
!               unprocessed nodes:  I = NEXT(I0)
!    K =        Index of node to be added and DO-loop index: 3 < K
!    LP =       LIST index (pointer) of a neighbor of K
!    LPL =      Pointer to the last neighbor of K
!    NEXTI =    NEXT(I)
!    NN =       Local copy of N
!
  implicit none

  integer ( kind = 4 ) n

  real    ( kind = 8 ) d
  real    ( kind = 8 ) d1
  real    ( kind = 8 ) d2
  real    ( kind = 8 ) d3
  real    ( kind = 8 ) dist(n)
  integer ( kind = 4 ) i
  integer ( kind = 4 ) i0
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) j
  integer ( kind = 4 ) k
  logical left
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lnew
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) near(n)
  integer ( kind = 4 ) next(n)
  integer ( kind = 4 ) nexti
  integer ( kind = 4 ) nn
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) z(n)

  nn = n

  if ( nn < 3 ) then
    ier = -1
    return
  end if
!
!  Store the first triangle in the linked list.
!
  if ( .not. left (x(1),y(1),z(1),x(2),y(2),z(2), &
                   x(3),y(3),z(3) ) ) then
!
!  The first triangle is (3,2,1) = (2,1,3) = (1,3,2).
!
    list(1) = 3
    lptr(1) = 2
    list(2) = -2
    lptr(2) = 1
    lend(1) = 2

    list(3) = 1
    lptr(3) = 4
    list(4) = -3
    lptr(4) = 3
    lend(2) = 4

    list(5) = 2
    lptr(5) = 6
    list(6) = -1
    lptr(6) = 5
    lend(3) = 6

  else if ( .not. left ( x(2),y(2),z(2),x(1),y(1),z(1),x(3),y(3),z(3) ) ) then
!
!  The first triangle is (1,2,3):  3 Strictly Left 1->2,
!  i.e., node 3 lies in the left hemisphere defined by arc 1->2.
!
    list(1) = 2
    lptr(1) = 2
    list(2) = -3
    lptr(2) = 1
    lend(1) = 2

    list(3) = 3
    lptr(3) = 4
    list(4) = -1
    lptr(4) = 3
    lend(2) = 4

    list(5) = 1
    lptr(5) = 6
    list(6) = -2
    lptr(6) = 5
    lend(3) = 6
!
!  The first three nodes are collinear.
!
  else

    ier = -2
    return
  end if
!
!  Initialize LNEW and test for N = 3.
!
  lnew = 7

  if ( nn == 3 ) then
    ier = 0
    return
  end if
!
!  A nearest-node data structure (NEAR, NEXT, and DIST) is
!  used to obtain an expected-time (N*log(N)) incremental
!  algorithm by enabling constant search time for locating
!  each new node in the triangulation.
!
!  For each unprocessed node K, NEAR(K) is the index of the
!  triangulation node closest to K (used as the starting
!  point for the search in Subroutine TRFIND) and DIST(K)
!  is an increasing function of the arc length (angular
!  distance) between nodes K and NEAR(K):  -Cos(a) for arc
!  length a.
!
!  Since it is necessary to efficiently find the subset of
!  unprocessed nodes associated with each triangulation
!  node J (those that have J as their NEAR entries), the
!  subsets are stored in NEAR and NEXT as follows:  for
!  each node J in the triangulation, I = NEAR(J) is the
!  first unprocessed node in J's set (with I = 0 if the
!  set is empty), L = NEXT(I) (if 0 < I) is the second,
!  NEXT(L) (if 0 < L) is the third, etc.  The nodes in each
!  set are initially ordered by increasing indexes (which
!  maximizes efficiency) but that ordering is not main-
!  tained as the data structure is updated.
!
!  Initialize the data structure for the single triangle.
!
  near(1) = 0
  near(2) = 0
  near(3) = 0

  do k = nn, 4, -1

    d1 = -( x(k) * x(1) + y(k) * y(1) + z(k) * z(1) )
    d2 = -( x(k) * x(2) + y(k) * y(2) + z(k) * z(2) )
    d3 = -( x(k) * x(3) + y(k) * y(3) + z(k) * z(3) )

    if ( d1 <= d2 .and. d1 <= d3 ) then
      near(k) = 1
      dist(k) = d1
      next(k) = near(1)
      near(1) = k
    else if ( d2 <= d1 .and. d2 <= d3 ) then
      near(k) = 2
      dist(k) = d2
      next(k) = near(2)
      near(2) = k
    else
      near(k) = 3
      dist(k) = d3
      next(k) = near(3)
      near(3) = k
    end if

  end do
!
!  Add the remaining nodes.
!
  do k = 4, nn

    call addnod ( near(k), k, x, y, z, list, lptr, lend, lnew, ier )

    if ( ier /= 0 ) then
       return
    end if
!
!  Remove K from the set of unprocessed nodes associated with NEAR(K).
!
    i = near(k)

    if ( near(i) == k ) then

      near(i) = next(k)

    else

      i = near(i)

      do

        i0 = i
        i = next(i0)

        if ( i == k ) then
          exit
        end if

      end do

      next(i0) = next(k)

    end if

    near(k) = 0
!
!  Loop on neighbors J of node K.
!
    lpl = lend(k)
    lp = lpl

3   continue

    lp = lptr(lp)
    j = abs ( list(lp) )
!
!  Loop on elements I in the sequence of unprocessed nodes
!  associated with J:  K is a candidate for replacing J
!  as the nearest triangulation node to I.  The next value
!  of I in the sequence, NEXT(I), must be saved before I
!  is moved because it is altered by adding I to K's set.
!
    i = near(j)

    do

      if ( i == 0 ) then
        exit
      end if

      nexti = next(i)
!
!  Test for the distance from I to K less than the distance
!  from I to J.
!
      d = - ( x(i) * x(k) + y(i) * y(k) + z(i) * z(k) )
      if ( d < dist(i) ) then
!
!  Replace J by K as the nearest triangulation node to I:
!  update NEAR(I) and DIST(I), and remove I from J's set
!  of unprocessed nodes and add it to K's set.
!
        near(i) = k
        dist(i) = d

        if ( i == near(j) ) then
          near(j) = nexti
        else
          next(i0) = nexti
        end if

        next(i) = near(k)
        near(k) = i
      else
        i0 = i
      end if

      i = nexti

    end do
!
!  Bottom of loop on neighbors J.
!
5   continue

    if ( lp /= lpl ) then
      go to 3
    end if

6   continue

  end do

  return
end
subroutine trplot ( lun, pltsiz, elat, elon, a, n, x, y, z, list, lptr, &
  lend, title, numbr, ier )

!*****************************************************************************80
!
!! TRPLOT makes a PostScript image of a triangulation on a unit sphere.
!
!  Discussion:
!
!    This subroutine creates a level-2 Encapsulated Postscript (EPS)
!    file containing a graphical display of a triangulation of a set of
!    nodes on the unit sphere.  The visible nodes are projected onto the
!    plane that contains the origin and has normal defined by a
!    user-specified eye-position.  Projections of adjacent (visible) nodes
!    are connected by line segments.
!
!    The values in the data statements may be altered
!    in order to modify various plotting options.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) LUN, the logical unit number in the range 0
!    to 99.  The unit should be opened with an appropriate
!    file name before the call to this routine.
!
!    Input, real ( kind = 8 ) PLTSIZ, the plot size in inches.  A circular
!    window in the projection plane is mapped to a circular viewport with
!    diameter equal to 0.88 * PLTSIZ (leaving room for labels outside the
!    viewport).  The viewport is centered on the 8.5 by 11 inch page, and
!    its boundary is drawn.  1.0 <= PLTSIZ <= 8.5.
!
!    Input, real ( kind = 8 ) ELAT, ELON, the latitude and longitude
!    (in degrees) of the center of projection E (the center of the plot).
!    The projection plane is the plane that contains the origin and has
!    E as unit normal.  In a rotated coordinate system for which E is
!    the north pole, the projection plane contains the equator, and only
!    northern hemisphere nodes are visible (from the point at infinity in
!    the direction E).  These are projected orthogonally onto the
!    projection plane (by zeroing the z-component in the rotated coordinate
!    system).  ELAT and ELON must be in the range -90 to 90 and -180 to
!    180, respectively.
!
!    Input, real ( kind = 8 ) A, the angular distance in degrees from E
!    to the boundary of a circular window against which the triangulation
!    is clipped.  The projected window is a disk of radius R = Sin(A)
!    centered at the origin, and only visible nodes whose projections are
!    within distance R of the origin are included in the plot.  Thus, if
!    A = 90, the plot includes the entire hemisphere centered at E.
!    0 < A <= 90.
!
!    Input, integer ( kind = 4 ) N, the number of nodes in the triangulation.
!    3 <= N.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N). the coordinates of the
!    nodes (unit vectors).
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N), the
!    data structure defining the triangulation, created by TRMESH.
!
!    Input, character ( len = * ) TITLE, a string to be centered above the
!    plot.  The string must be enclosed in parentheses; i.e., the first and
!    last characters must be '(' and ')', respectively, but these are not
!    displayed.  TITLE may have at most 80 characters including the parentheses.
!
!    Input, logical NUMBR, option indicator:  If NUMBR = TRUE, the
!    nodal indexes are plotted next to the nodes.
!
!    Output, integer ( kind = 4 ) IER, error indicator:
!    0, if no errors were encountered.
!    1, if LUN, PLTSIZ, or N is outside its valid range.
!    2, if ELAT, ELON, or A is outside its valid range.
!    3, if an error was encountered in writing to unit LUN.
!
!  Local parameters:
!
!    ANNOT =     Logical variable with value TRUE iff the plot
!                is to be annotated with the values of ELAT,
!                ELON, and A
!    CF =        Conversion factor for degrees to radians
!    CT =        Cos(ELAT)
!    EX,EY,EZ =  Cartesian coordinates of the eye-position E
!    FSIZN =     Font size in points for labeling nodes with
!                their indexes if NUMBR = TRUE
!    FSIZT =     Font size in points for the title (and
!                annotation if ANNOT = TRUE)
!    IPX1,IPY1 = X and y coordinates (in points) of the lower
!                  left corner of the bounding box or viewport box
!    IPX2,IPY2 = X and y coordinates (in points) of the upper
!                right corner of the bounding box or viewport box
!    IR =        Half the width (height) of the bounding box or
!                viewport box in points -- viewport radius
!    LP =        LIST index (pointer)
!    LPL =       Pointer to the last neighbor of N0
!    N0 =        Index of a node whose incident arcs are to be drawn
!    N1 =        Neighbor of N0
!    R11...R23 = Components of the first two rows of a rotation
!                that maps E to the north pole (0,0,1)
!    SF =        Scale factor for mapping world coordinates
!                (window coordinates in [-WR,WR] X [-WR,WR])
!                to viewport coordinates in [IPX1,IPX2] X [IPY1,IPY2]
!    T =         Temporary variable
!    TX,TY =     Translation vector for mapping world coordi-
!                nates to viewport coordinates
!    WR =        Window radius r = Sin(A)
!    WRS =       WR**2
!    X0,Y0,Z0 =  Coordinates of N0 in the rotated coordinate
!                system or label location (X0,Y0)
!    X1,Y1,Z1 =  Coordinates of N1 in the rotated coordinate
!                system or intersection of edge N0-N1 with
!                the equator (in the rotated coordinate system)
!
  implicit none

  integer ( kind = 4 ) n

  real    ( kind = 8 ) a
  logical, parameter :: annot = .true.
  real    ( kind = 8 ) cf
  real    ( kind = 8 ) ct
  real    ( kind = 8 ) elat
  real    ( kind = 8 ) elon
  real    ( kind = 8 ) ex
  real    ( kind = 8 ) ey
  real    ( kind = 8 ) ez
  real    ( kind = 8 ), parameter :: fsizn = 10.0D+00
  real    ( kind = 8 ), parameter :: fsizt = 16.0D+00
  integer ( kind = 4 ) ier
  integer ( kind = 4 ) ipx1
  integer ( kind = 4 ) ipx2
  integer ( kind = 4 ) ipy1
  integer ( kind = 4 ) ipy2
  integer ( kind = 4 ) ir
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) lun
  integer ( kind = 4 ) n0
  integer ( kind = 4 ) n1
  logical numbr
  real    ( kind = 8 ) pltsiz
  real    ( kind = 8 ) r11
  real    ( kind = 8 ) r12
  real    ( kind = 8 ) r21
  real    ( kind = 8 ) r22
  real    ( kind = 8 ) r23
  real    ( kind = 8 ) sf
  real    ( kind = 8 ) t
  character ( len = * ) title
  real    ( kind = 8 ) tx
  real    ( kind = 8 ) ty
  real    ( kind = 8 ) wr
  real    ( kind = 8 ) wrs
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) x0
  real    ( kind = 8 ) x1
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) y0
  real    ( kind = 8 ) y1
  real    ( kind = 8 ) z(n)
  real    ( kind = 8 ) z0
  real    ( kind = 8 ) z1

  ier = 0
!
!  Test for invalid parameters.
!
  if ( lun < 0 ) then
    ier = 1
    return
  end if

  if ( 99 < lun ) then
    ier = 1
    return
  end if

  if ( pltsiz < 1.0D+00 ) then
    ier = 1
    return
  else if ( 8.5D+00 < pltsiz ) then
    ier = 1
    return
  else if ( n < 3 ) then
    ier = 1
    return
  end if

  if ( 90.0D+00 < abs ( elat ) ) then
    ier = 2
    return
  else if ( 180.0D+00 < abs ( elon ) ) then
    ier = 2
    return
  else if ( 90.0D+00 < a ) then
    ier = 2
    return
  end if
!
!  Compute a conversion factor CF for degrees to radians.
!
  cf = atan ( 1.0D+00 ) / 45.0D+00
!
!  Compute the window radius WR.
!
  wr = sin ( cf * a )
  wrs = wr * wr
!
!  Compute the lower left (IPX1,IPY1) and upper right
!  (IPX2,IPY2) corner coordinates of the bounding box.
!  The coordinates, specified in default user space units
!  (points, at 72 points/inch with origin at the lower
!  left corner of the page), are chosen to preserve the
!  square aspect ratio, and to center the plot on the 8.5
!  by 11 inch page.  The center of the page is (306,396),
!  and IR = PLTSIZ/2 in points.
!
  ir = nint ( 36.0D+00 * pltsiz )
  ipx1 = 306 - ir
  ipx2 = 306 + ir
  ipy1 = 396 - ir
  ipy2 = 396 + ir
!
!  Output header comments.
!
  write ( lun, '(a)' ) '%!ps-adobe-3.0 epsf-3.0'
  write ( lun, '(a,4i4)' ) '%%BoundingBox:', ipx1, ipy1, ipx2, ipy2
  write ( lun, '(a)' ) '%%title:  Triangulation'
  write ( lun, '(a)' ) '%%creator:  STRIPACK.F90'
  write ( lun, '(a)' ) '%%endcomments'
!
!  Set (IPX1,IPY1) and (IPX2,IPY2) to the corner coordinates
!  of a viewport box obtained by shrinking the bounding box
!  by 12% in each dimension.
!
  ir = nint ( 0.88D+00 * real ( ir, kind = 8 ) )
  ipx1 = 306 - ir
  ipx2 = 306 + ir
  ipy1 = 396 - ir
  ipy2 = 396 + ir
!
!  Set the line thickness to 2 points, and draw the
!  viewport boundary.
!
  t = 2.0D+00
  write ( lun, '(f12.6,a)' ) t, ' setlinewidth'
  write ( lun, '(a,i3,a)' ) '306 396 ', ir, ' 0 360 arc'
  write ( lun, '(a)' ) 'stroke'
!
!  Set up an affine mapping from the window box [-WR,WR] X
!  [-WR,WR] to the viewport box.
!
  sf = real ( ir, kind = 8 ) / wr
  tx = ipx1 + sf * wr
  ty = ipy1 + sf * wr
  write ( lun, '(2f12.6,a)' ) tx, ty, ' translate'
  write ( lun, '(2f12.6,a)' ) sf, sf, ' scale'
!
!  The line thickness must be changed to reflect the new
!  scaling which is applied to all subsequent output.
!  Set it to 1.0 point.
!
  t = 1.0D+00 / sf
  write ( lun, '(f12.6,a)' ) t, ' setlinewidth'
!
!  Save the current graphics state, and set the clip path to
!  the boundary of the window.
!
  write ( lun, '(a)' ) 'gsave'
  write ( lun, '(a,f12.6,a)' ) '0 0 ', wr, ' 0 360 arc'
  write ( lun, '(a)' ) 'clip newpath'
!
!  Compute the Cartesian coordinates of E and the components
!  of a rotation R which maps E to the north pole (0,0,1).
!  R is taken to be a rotation about the z-axis (into the
!  yz-plane) followed by a rotation about the x-axis chosen
!  so that the view-up direction is (0,0,1), or (-1,0,0) if
!  E is the north or south pole.
!
!           ( R11  R12  0   )
!       R = ( R21  R22  R23 )
!           ( EX   EY   EZ  )
!
  t = cf * elon
  ct = cos ( cf * elat )
  ex = ct * cos ( t )
  ey = ct * sin ( t )
  ez = sin ( cf * elat )

  if ( ct /= 0.0D+00 ) then
    r11 = -ey / ct
    r12 = ex / ct
  else
    r11 = 0.0D+00
    r12 = 1.0D+00
  end if

  r21 = -ez * r12
  r22 = ez * r11
  r23 = ct
!
!  Loop on visible nodes N0 that project to points (X0,Y0) in the window.
!
  do n0 = 1, n

    z0 = ex * x(n0) + ey * y(n0) + ez * z(n0)

    if ( z0 < 0.0D+00 ) then
      cycle
    end if

    x0 = r11 * x(n0) + r12 * y(n0)
    y0 = r21 * x(n0) + r22 * y(n0) + r23 * z(n0)

    if ( wrs < x0 * x0 + y0 * y0 ) then
      cycle
    end if

    lpl = lend(n0)
    lp = lpl
!
!  Loop on neighbors N1 of N0.  LPL points to the last
!  neighbor of N0.  Copy the components of N1 into P.
!
    do

      lp = lptr(lp)
      n1 = abs ( list(lp) )

      x1 = r11 * x(n1) + r12 * y(n1)
      y1 = r21 * x(n1) + r22 * y(n1) + r23 * z(n1)
      z1 = ex  * x(n1) + ey  * y(n1) + ez  * z(n1)
!
!  N1 is a 'southern hemisphere' point.  Move it to the
!  intersection of edge N0-N1 with the equator so that
!  the edge is clipped properly.  Z1 is implicitly set
!  to 0.
!
      if ( z1 < 0.0D+00 ) then
        x1 = z0 * x1 - z1 * x0
        y1 = z0 * y1 - z1 * y0
        t = sqrt ( x1 * x1 + y1 * y1 )
        x1 = x1 / t
        y1 = y1 / t
      end if
!
!  If node N1 is in the window and N1 < N0, bypass edge
!  N0->N1 (since edge N1->N0 has already been drawn).
!
!  Add the edge to the path.
!
      if ( z1 < 0.0D+00 .or. &
           wrs < x1 * x1 + y1 * y1 .or. &
           n0 <= n1 ) then

        write ( lun, '(2f12.6,a,2f12.6,a)' ) &
          x0, y0, ' moveto', x1, y1, ' lineto'

      end if

      if ( lp == lpl ) then
        exit
      end if

    end do

  end do
!
!  Paint the path and restore the saved graphics state (with
!  no clip path).
!
  write ( lun, '(a)' ) 'stroke'
  write ( lun, '(a)' ) 'grestore'

  if ( numbr ) then
!
!  Nodes in the window are to be labeled with their indexes.
!  Convert FSIZN from points to world coordinates, and
!  output the commands to select a font and scale it.
!
    t = fsizn / sf

    write ( lun, '(a)' ) '/Helvetica findfont'
    write ( lun, '(f12.6,a)' ) t, ' scalefont setfont'
!
!  Loop on visible nodes N0 that project to points (X0,Y0) in the window.
!
    do n0 = 1, n

      if ( ex * x(n0) + ey * y(n0) + ez * z(n0) < 0.0D+00 ) then
        cycle
      end if

      x0 = r11 * x(n0) + r12 * y(n0)
      y0 = r21 * x(n0) + r22 * y(n0) + r23 * z(n0)

      if ( wrs < x0 * x0 + y0 * y0 ) then
        cycle
      end if
!
!  Move to (X0,Y0) and draw the label N0.  The first char-
!  acter will will have its lower left corner about one
!  character width to the right of the nodal position.
!
      write ( lun, '(2f12.6,a)' ) x0, y0, ' moveto'
      write ( lun, '(a,i3,a)' ) '(', n0, ') show'

    end do

  end if
!
!  Convert FSIZT from points to world coordinates, and output
!  the commands to select a font and scale it.
!
  t = fsizt / sf
  write ( lun, '(a)' ) '/Helvetica findfont'
  write ( lun, '(f12.6,a)' ) t, ' scalefont setfont'
!
!  Display TITLE centered above the plot:
!
  y0 = wr + 3.0D+00 * t

  write ( lun, '(a)' ) title
  write ( lun, '(a,f12.6,a)' ) '  stringwidth pop 2 div neg ', y0, ' moveto'
  write ( lun, '(a)' ) title
  write ( lun, '(a)' ) '  show'
!
!  Display the window center and radius below the plot.
!
  if ( annot ) then

    x0 = -wr
    y0 = -wr - 50.0D+00 / sf
    write ( lun, '(2f12.6,a)' ) x0, y0, ' moveto'
    write ( lun, '(a,f7.2,a,f8.2,a)' ) '(Window center:  Latitude = ', elat, &
      ', Longitude = ', elon , ') show'
    y0 = y0 - 2.0D+00 * t
    write ( lun, '(2f12.6,a)' ) x0, y0, ' moveto'
    write ( lun, '(a,f5.2,a)' ) '(Angular extent = ', a, ') show'

  end if
!
!  Paint the path and output the showpage command and
!  end-of-file indicator.
!
  write ( lun, '(a)' ) 'stroke'
  write ( lun, '(a)' ) 'showpage'
  write ( lun, '(a)' ) '%%eof'

  ier = 0

  return
end
subroutine trprnt ( n, x, y, z, iflag, list, lptr, lend )

!*****************************************************************************80
!
!! TRPRNT prints the triangulation adjacency lists.
!
!  Discussion:
!
!    This subroutine prints the triangulation adjacency lists
!    created by TRMESH and, optionally, the nodal
!    coordinates (either latitude and longitude or Cartesian
!    coordinates) on logical unit LOUT.  The list of neighbors
!    of a boundary node is followed by index 0.  The numbers of
!    boundary nodes, triangles, and arcs are also printed.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N = Number of nodes in the triangulation.
!    3 <= N and N <= 9999.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the Cartesian coordinates of
!    the nodes if IFLAG = 0, or (X and Y only) containing longitude and
!    latitude, respectively, if 0  < IFLAG, or unused dummy parameters if
!    IFLAG < 0.
!
!    Input, integer ( kind = 4 ) IFLAG = Nodal coordinate option indicator:
!    = 0 if X, Y, and Z (assumed to contain Cartesian coordinates) are to be
!      printed (to 6 decimal places).
!    > 0 if only X and Y (assumed to contain longitude and latitude) are
!      to be printed (to 6 decimal places).
!    < 0 if only the adjacency lists are to be printed.
!
!    Input, integer ( kind = 4 ) LIST(6*(N-2)), LPTR(6*(N-2)), LEND(N), the
!    data structure defining the triangulation.  Refer to TRMESH.
!
!  Local parameters:
!
!    I =     NABOR index (1 to K)
!    INC =   Increment for NL associated with an adjacency list
!    K =     Counter and number of neighbors of NODE
!    LP =    LIST pointer of a neighbor of NODE
!    LPL =   Pointer to the last neighbor of NODE
!    NA =    Number of arcs in the triangulation
!    NABOR = Array containing the adjacency list associated
!            with NODE, with zero appended if NODE is a boundary node
!    NB =    Number of boundary nodes encountered
!    ND =    Index of a neighbor of NODE (or negative index)
!    NL =    Number of lines that have been printed on the current page
!    NLMAX = Maximum number of print lines per page (except
!            for the last page which may have two additional lines)
!    NMAX =  Upper bound on N (allows 4-digit indexes)
!    NODE =  Index of a node and DO-loop index (1 to N)
!    NN =    Local copy of N
!    NT =    Number of triangles in the triangulation
!
  implicit none

  integer ( kind = 4 ) n

  integer ( kind = 4 ) iflag
  integer ( kind = 4 ) inc
  integer ( kind = 4 ) k
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) list(6*(n-2))
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) na
  integer ( kind = 4 ) nabor(400)
  integer ( kind = 4 ) nb
  integer ( kind = 4 ) nd
  integer ( kind = 4 ) nl
  integer ( kind = 4 ), parameter :: nlmax = 58
  integer ( kind = 4 ), parameter :: nmax = 9999
  integer ( kind = 4 ) nn
  integer ( kind = 4 ) node
  integer ( kind = 4 ) nt
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) z(n)

  nn = n
!
!  Print a heading and test the range of N.
!
  write (*,100) nn

  if ( nn < 3 .or. nmax < nn ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'TRPRNT - Fatal error!'
    write ( *, '(a)' ) '  N is outside its valid range.'
    return
  end if
!
!  Initialize NL (the number of lines printed on the current
!  page) and NB (the number of boundary nodes encountered).
!
  nl = 6
  nb = 0
!
!  Print LIST only.  K is the number of neighbors of NODE
!  that have been stored in NABOR.
!
  if ( iflag < 0 ) then

    write (*,101)

    do node = 1, nn

      lpl = lend(node)
      lp = lpl
      k = 0

      do

        k = k + 1
        lp = lptr(lp)
        nd = list(lp)
        nabor(k) = nd

        if ( lp == lpl ) then
          exit
        end if

      end do
!
!  NODE is a boundary node.  Correct the sign of the last
!  neighbor, add 0 to the end of the list, and increment NB.
!
      if ( nd <= 0 ) then
        nabor(k) = -nd
        k = k + 1
        nabor(k) = 0
        nb = nb + 1

      end if
!
!  Increment NL and print the list of neighbors.
!
      inc = ( k - 1 ) / 14 + 2
      nl = nl + inc

      if ( nlmax < nl ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        nl = inc
      end if

      write (*,104) node, nabor(1:k)
      if ( k /= 14 ) then
        write ( *, '(a)' ) ' '
      end if

    end do

  else if ( 0 < iflag ) then
!
!  Print X (longitude), Y (latitude), and LIST.
!
    write (*,102)

    do node = 1, nn

      lpl = lend(node)
      lp = lpl
      k = 0

      do

        k = k + 1
        lp = lptr(lp)
        nd = list(lp)
        nabor(k) = nd

        if ( lp == lpl ) then
          exit
        end if

      end do

      if ( nd <= 0 ) then
!
!  NODE is a boundary node.
!
        nabor(k) = -nd
        k = k + 1
        nabor(k) = 0
        nb = nb + 1
      end if
!
!  Increment NL and print X, Y, and NABOR.
!
      inc = ( k - 1 ) / 8 + 2
      nl = nl + inc

      if ( nlmax < nl ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        nl = inc
      end if

      write (*,105) node, x(node), y(node), nabor(1:k)

      if ( k /= 8 ) then
        write ( *, '(a)' ) ' '
      end if

    end do

  else
!
!  Print X, Y, Z, and LIST.
!
    write (*,103)

    do node = 1, nn

      lpl = lend(node)
      lp = lpl
      k = 0

      do

        k = k + 1
        lp = lptr(lp)
        nd = list(lp)
        nabor(k) = nd

        if ( lp == lpl ) then
          exit
        end if

      end do
!
!  NODE is a boundary node.
!
      if ( nd <= 0 ) then
        nabor(k) = -nd
        k = k + 1
        nabor(k) = 0
        nb = nb + 1
      end if
!
!  Increment NL and print X, Y, Z, and NABOR.
!
      inc = ( k - 1 ) / 5 + 2
      nl = nl + inc

      if ( nlmax < nl ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) ' '
        nl = inc
      end if

      write (*,106) node, x(node), y(node), z(node), nabor(1:k)

      if ( k /= 5 ) then
        write ( *, '(a)' ) ' '
      end if

    end do

  end if
!
!  Print NB, NA, and NT (boundary nodes, arcs, and triangles).
!
  if ( nb /= 0 ) then
    na = 3 * nn - nb - 3
    nt = 2 * nn - nb - 2
  else
    na = 3 * nn - 6
    nt = 2 * nn - 4
  end if

  write ( *, '(a)' ) ' '
  write ( *, '(a,i8,a)' ) '  NB = ', nb, ' boundary arcs.'
  write ( *, '(a,i8,a)' ) '  NA = ', na, ' arcs.'
  write ( *, '(a,i8,a)' ) '  NT = ', nt, ' triangles.'

  return
!
!  Print formats:
!
  100 format (///15x,'STRIPACK triangulation data ', &
          'structure,  n = ',i5//)
  101 format (' node',31x,'neighbors of node'//)
  102 format (' Node    Longitude      Latitude', &
          18x,'neighbors of node'//)
  103 format (' node     x(node)        y(node)',8x, &
          'z(node)',11x,'neighbors of node'//)
  104 format (i5,4x,14i5/(1x,8x,14i5))
  105 format (i5,2e15.6,4x,8i5/(1x,38x,8i5))
  106 format (i5,3e15.6,4x,5i5/(1x,53x,5i5))
end
subroutine voronoi_poly_count ( n, lend, lptr, listc )

!*****************************************************************************80
!
!! VORONOI_POLY_COUNT counts the polygons of each size in the Voronoi diagram.
!
!  Modified:
!
!    06 June 2002
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of Voronoi polygons.
!
!    Input, integer ( kind = 4 ) LEND(N), some kind of pointer.
!
!    Input, integer ( kind = 4 ) LPTR(6*(N-2)), some other kind of pointer.
!
!    Input, integer ( kind = 4 ) LISTC(6*(N-2)), some other kind of pointer.
!
  implicit none

  integer ( kind = 4 ) n
  integer ( kind = 4 ), parameter :: side_max = 20

  integer ( kind = 4 ) count(side_max)
  integer ( kind = 4 ) edges
  integer ( kind = 4 ) i
  integer ( kind = 4 ) kv
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) listc(6*(n-2))
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) n0
  integer ( kind = 4 ) sides
  integer ( kind = 4 ) vertices

  count(1:side_max) = 0

  edges = 0
  vertices = 0

  do n0 = 1, n

    lpl = lend(n0)

    lp = lpl

    sides = 0

    do

      lp = lptr(lp)
      kv = listc(lp)

      vertices = max ( vertices, kv )
      sides = sides + 1
      edges = edges + 1

      if ( lp == lpl ) then
        exit
      end if

    end do

    if ( 0 < sides .and. sides < side_max ) then
      count(sides) = count(sides) + 1
    else
      count(side_max) = count(side_max) + 1
    end if

  end do

  edges = edges / 2

  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) 'VORONOI_POLY_COUNT'
  write ( *, '(a)' ) '  Number of polygons of each shape.'
  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' ) '  Faces =    ', n
  write ( *, '(a,i8)' ) '  Vertices = ', vertices
  write ( *, '(a,i8)' ) '  Edges =    ', edges
  write ( *, '(a)' ) ' '
  write ( *, '(a,i8)' ) '  F+V-E-2 =  ', n + vertices - edges - 2
  write ( *, '(a)' ) ' '
  write ( *, '(a)' ) ' Sides  Number'
  write ( *, '(a)' ) ' '

  do i = 1, side_max - 1
    if ( count(i) /= 0 ) then
      write ( *, '(2x,i8,2x,i8)' ) i, count(i)
    end if
  end do

  if ( count(side_max) /= 0 ) then
    write ( *, '(2x,i8,2x,i8)' ) side_max, count(side_max)
  end if


  return
end
subroutine vrplot ( lun, pltsiz, elat, elon, a, n, x, y, z, nt, listc, lptr, &
  lend, xc, yc, zc, title, numbr, ier )

!*****************************************************************************80
!
!! VRPLOT makes a PostScript image of a Voronoi diagram on the unit sphere.
!
!  Discussion:
!
!    This subroutine creates a level-2 Encapsulated Postscript
!    (EPS) file containing a graphical depiction of a
!    Voronoi diagram of a set of nodes on the unit sphere.
!    The visible vertices are projected onto the plane that
!    contains the origin and has normal defined by a user-
!    specified eye-position.  Projections of adjacent (visible)
!    Voronoi vertices are connected by line segments.
!
!    The parameters defining the Voronoi diagram may be computed by
!    subroutine CRLIST.
!
!  Modified:
!
!    16 June 2007
!
!  Author:
!
!    Robert Renka
!
!  Reference:
!
!    Robert Renka,
!    Algorithm 772: STRIPACK,
!    Delaunay Triangulation and Voronoi Diagram on the Surface of a Sphere,
!    ACM Transactions on Mathematical Software,
!    Volume 23, Number 3, September 1997, pages 416-434.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) LUN, the logical unit number in the range 0
!    to 99.  The unit should be opened with an appropriate
!    file name before the call to this routine.
!
!    Input, real ( kind = 8 ) PLTSIZ, the plot size in inches.  A circular
!    window in the projection plane is mapped to a circular viewport with
!    diameter equal to .88*PLTSIZ (leaving room for labels outside the
!    viewport).  The viewport is centered on the 8.5 by 11 inch page, and its
!    boundary is drawn.  1.0 <= PLTSIZ <= 8.5.
!
!    Input, real ( kind = 8 ) ELAT, ELON, the latitude and longitude (in
!    degrees) of the center of projection E (the center of the plot).  The
!    projection plane is the plane that contains the origin and has E as unit
!    normal.  In a rotated coordinate system for which E is the north pole, the
!    projection plane contains the equator, and only northern hemisphere
!    points are visible (from the point at infinity in the direction E).
!    These are projected orthogonally onto the projection plane (by zeroing
!    the z-component in the rotated coordinate system).  ELAT and ELON must
!    be in the range -90 to 90 and -180 to 180, respectively.
!
!    Input, real ( kind = 8 ) A, the angular distance in degrees from E to the
!    boundary of a circular window against which the Voronoi diagram is clipped.
!    The projected window is a disk of radius R = Sin(A) centered at the
!    origin, and only visible vertices whose projections are within distance
!    R of the origin are included in the plot.  Thus, if A = 90, the plot
!    includes the entire hemisphere centered at E.  0 < A <= 90.
!
!    Input, integer ( kind = 4 ) N, the number of nodes (Voronoi centers) and
!    Voronoi regions.  3 <= N.
!
!    Input, real ( kind = 8 ) X(N), Y(N), Z(N), the coordinates of the nodes
!    (unit vectors).
!
!    Input, integer ( kind = 4 ) NT, the number of Voronoi region vertices
!    (triangles, including those in the extended triangulation if the number
!    of boundary nodes NB is nonzero): NT = 2*N-4.
!
!    Input, integer ( kind = 4 ) LISTC(3*NT), containing triangle indexes
!    (indexes to XC, YC, and ZC) stored in 1-1 correspondence with LIST/LPTR
!    entries (or entries that would be stored in LIST for the extended
!    triangulation): the index of triangle (N1,N2,N3) is stored in LISTC(K),
!    LISTC(L), and LISTC(M), where LIST(K), LIST(L), and LIST(M) are the
!    indexes of N2 as a neighbor of N1, N3 as a neighbor of N2, and N1 as a
!    neighbor of N3.  The Voronoi region associated with a node is defined by
!    the CCW-ordered sequence of circumcenters in one-to-one correspondence
!    with its adjacency list (in the extended triangulation).
!
!    Input, integer ( kind = 4 ) LPTR(3*NT), where NT = 2*N-4, containing a
!    set of pointers (LISTC indexes) in one-to-one correspondence with the
!    elements of LISTC.  LISTC(LPTR(I)) indexes the triangle which follows
!    LISTC(I) in cyclical counterclockwise order (the first neighbor follows
!    the last neighbor).
!
!    Input, integer ( kind = 4 ) LEND(N), a set of pointers to triangle lists.
!    LP = LEND(K) points to a triangle (indexed by LISTC(LP)) containing node
!    K for K = 1 to N.
!
!    Input, real ( kind = 8 ) XC(NT), YC(NT), ZC(NT), the coordinates of the
!    triangle circumcenters (Voronoi vertices).
!    XC(I)**2 + YC(I)**2 + ZC(I)**2 = 1.
!
!    Input, character ( len = * ) TITLE, a string to be centered above the plot.
!    The string must be enclosed in parentheses; i.e., the first and last
!    characters must be '(' and ')', respectively, but these are not
!    displayed.  TITLE may have at most 80 characters including the parentheses.
!
!    Input, logical NUMBR, option indicator:  If NUMBR = TRUE, the nodal
!    indexes are plotted at the Voronoi region centers.
!
!    Output, integer ( kind = 4 ) IER = Error indicator:
!    0, if no errors were encountered.
!    1, if LUN, PLTSIZ, N, or NT is outside its valid range.
!    2, if ELAT, ELON, or A is outside its valid range.
!    3, if an error was encountered in writing to unit LUN.
!
!  Local parameters:
!
!    ANNOT =     Logical variable with value TRUE iff the plot
!                is to be annotated with the values of ELAT, ELON, and A
!    CF =        Conversion factor for degrees to radians
!    CT =        Cos(ELAT)
!    EX,EY,EZ =  Cartesian coordinates of the eye-position E
!    FSIZN =     Font size in points for labeling nodes with
!                their indexes if NUMBR = TRUE
!    FSIZT =     Font size in points for the title (and
!                annotation if ANNOT = TRUE)
!    IN1,IN2 =   Logical variables with value TRUE iff the
!                projections of vertices KV1 and KV2, respec-
!                tively, are inside the window
!    IPX1,IPY1 = X and y coordinates (in points) of the lower
!                left corner of the bounding box or viewport box
!    IPX2,IPY2 = X and y coordinates (in points) of the upper
!                right corner of the bounding box or viewport box
!    IR =        Half the width (height) of the bounding box or
!                viewport box in points -- viewport radius
!    KV1,KV2 =   Endpoint indexes of a Voronoi edge
!    LP =        LIST index (pointer)
!    LPL =       Pointer to the last neighbor of N0
!    N0 =        Index of a node
!    R11...R23 = Components of the first two rows of a rotation
!                that maps E to the north pole (0,0,1)
!    SF =        Scale factor for mapping world coordinates
!                (window coordinates in [-WR,WR] X [-WR,WR])
!                to viewport coordinates in [IPX1,IPX2] X [IPY1,IPY2]
!    T =         Temporary variable
!    TX,TY =     Translation vector for mapping world coordi-
!                nates to viewport coordinates
!    WR =        Window radius r = Sin(A)
!    WRS =       WR**2
!    X0,Y0 =     Projection plane coordinates of node N0 or label location
!    X1,Y1,Z1 =  Coordinates of vertex KV1 in the rotated coordinate system
!    X2,Y2,Z2 =  Coordinates of vertex KV2 in the rotated
!                coordinate system or intersection of edge
!                KV1-KV2 with the equator (in the rotated coordinate system)
!
  implicit none

  integer ( kind = 4 ) n
  integer ( kind = 4 ) nt

  real    ( kind = 8 ) a
  logical, parameter :: annot = .true.
  real    ( kind = 8 ) cf
  real    ( kind = 8 ) ct
  real    ( kind = 8 ) elat
  real    ( kind = 8 ) elon
  real    ( kind = 8 ) ex
  real    ( kind = 8 ) ey
  real    ( kind = 8 ) ez
  real    ( kind = 8 ), parameter :: fsizn = 10.0D+00
  real    ( kind = 8 ), parameter :: fsizt = 16.0D+00
  integer ( kind = 4 ) ier
  logical in1
  logical in2
  integer ( kind = 4 ) ipx1
  integer ( kind = 4 ) ipx2
  integer ( kind = 4 ) ipy1
  integer ( kind = 4 ) ipy2
  integer ( kind = 4 ) ir
  integer ( kind = 4 ) kv1
  integer ( kind = 4 ) kv2
  integer ( kind = 4 ) lend(n)
  integer ( kind = 4 ) listc(3*nt)
  integer ( kind = 4 ) lp
  integer ( kind = 4 ) lpl
  integer ( kind = 4 ) lptr(6*(n-2))
  integer ( kind = 4 ) lun
  integer ( kind = 4 ) n0
  logical              numbr
  real    ( kind = 8 ) pltsiz
  real    ( kind = 8 ) r11
  real    ( kind = 8 ) r12
  real    ( kind = 8 ) r21
  real    ( kind = 8 ) r22
  real    ( kind = 8 ) r23
  real    ( kind = 8 ) sf
  real    ( kind = 8 ) t
  character ( len = * ) title
  real    ( kind = 8 ) tx
  real    ( kind = 8 ) ty
  real    ( kind = 8 ) wr
  real    ( kind = 8 ) wrs
  real    ( kind = 8 ) x(n)
  real    ( kind = 8 ) x0
  real    ( kind = 8 ) x1
  real    ( kind = 8 ) x2
  real    ( kind = 8 ) xc(nt)
  real    ( kind = 8 ) y(n)
  real    ( kind = 8 ) y0
  real    ( kind = 8 ) y1
  real    ( kind = 8 ) y2
  real    ( kind = 8 ) yc(nt)
  real    ( kind = 8 ) z(n)
  real    ( kind = 8 ) z1
  real    ( kind = 8 ) z2
  real    ( kind = 8 ) zc(nt)

  ier = 0
!
!  Test for invalid parameters.
!
  if ( lun < 0 ) then
    ier = 1
    return
  end if

  if ( 99 < lun ) then
    ier = 1
    return
  end if

  if ( pltsiz < 1.0D+00 .or. 8.5D+00 < pltsiz .or. &
      n < 3 .or. nt /= 2*n-4) then
    ier = 1
    return
  end if

  if ( 90.0D+00 < abs ( elat ) .or. &
       180.0D+00 < abs ( elon ) .or. &
       90.0D+00 < a ) then
    ier = 2
    return
  end if
!
!  Compute a conversion factor CF for degrees to radians.
!
  cf = atan ( 1.0D+00 ) / 45.0D+00
!
!  Compute the window radius WR.
!
  wr = sin ( cf * a )
  wrs = wr * wr
!
!  Compute the lower left (IPX1,IPY1) and upper right
!  (IPX2,IPY2) corner coordinates of the bounding box.
!  The coordinates, specified in default user space units
!  (points, at 72 points/inch with origin at the lower
!  left corner of the page), are chosen to preserve the
!  square aspect ratio, and to center the plot on the 8.5
!  by 11 inch page.  The center of the page is (306,396),
!  and IR = PLTSIZ/2 in points.
!
  ir = nint ( 36.0D+00 * pltsiz )
  ipx1 = 306 - ir
  ipx2 = 306 + ir
  ipy1 = 396 - ir
  ipy2 = 396 + ir
!
!  Output header comments.
!
  write ( lun, '(a)' ) '%!ps-adobe-3.0 epsf-3.0'
  write ( lun, '(a,4i4)' ) '%%BoundingBox: ', ipx1, ipy1, ipx2, ipy2
  write ( lun, '(a)' ) '%%title:  Voronoi diagram'
  write ( lun, '(a)' ) '%%creator:  STRIPACK.F90'
  write ( lun, '(a)' ) '%%endcomments'
!
!  Set (IPX1,IPY1) and (IPX2,IPY2) to the corner coordinates
!  of a viewport box obtained by shrinking the bounding box
!  by 12% in each dimension.
!
  ir = nint ( 0.88D+00 * real ( ir, kind = 8 ) )
  ipx1 = 306 - ir
  ipx2 = 306 + ir
  ipy1 = 396 - ir
  ipy2 = 396 + ir
!
!  Set the line thickness to 2 points, and draw the viewport boundary.
!
  t = 2.0D+00
  write ( lun, '(f12.6,a)' ) t, ' setlinewidth'
  write ( lun, '(a,i3,a)' ) '306 396 ', ir, ' 0 360 arc'
  write ( lun, '(a)' ) 'stroke'
!
!  Set up an affine mapping from the window box [-WR,WR] X
!  [-WR,WR] to the viewport box.
!
  sf = real ( ir, kind = 8 ) / wr
  tx = ipx1 + sf * wr
  ty = ipy1 + sf * wr

  write ( lun, '(2f12.6,a)' ) tx, ty, ' translate'
  write ( lun, '(2f12.6,a)' ) sf, sf, ' scale'
!
!  The line thickness must be changed to reflect the new
!  scaling which is applied to all subsequent output.
!  Set it to 1.0 point.
!
  t = 1.0D+00 / sf
  write ( lun, '(f12.6,a)' ) t, ' setlinewidth'
!
!  Save the current graphics state, and set the clip path to
!  the boundary of the window.
!
  write ( lun, '(a)' ) 'gsave'
  write ( lun, '(a,f12.6,a)' ) '0 0 ', wr, ' 0 360 arc'
  write ( lun, '(a)' ) 'clip newpath'
!
!  Compute the Cartesian coordinates of E and the components
!  of a rotation R which maps E to the north pole (0,0,1).
!  R is taken to be a rotation about the z-axis (into the
!  yz-plane) followed by a rotation about the x-axis chosen
!  so that the view-up direction is (0,0,1), or (-1,0,0) if
!  E is the north or south pole.
!
!           ( R11  R12  0   )
!       R = ( R21  R22  R23 )
!           ( EX   EY   EZ  )
!
  t = cf * elon
  ct = cos ( cf * elat )
  ex = ct * cos ( t )
  ey = ct * sin ( t )
  ez = sin ( cf * elat )

  if ( ct /= 0.0D+00 ) then
    r11 = -ey / ct
    r12 = ex / ct
  else
    r11 = 0.0D+00
    r12 = 1.0D+00
  end if

  r21 = -ez * r12
  r22 = ez * r11
  r23 = ct
!
!  Loop on nodes (Voronoi centers) N0.
!  LPL indexes the last neighbor of N0.
!
  do n0 = 1, n

    lpl = lend(n0)
!
!  Set KV2 to the first (and last) vertex index and compute
!  its coordinates (X2,Y2,Z2) in the rotated coordinate system.
!
    kv2 = listc(lpl)
    x2 = r11 * xc(kv2) + r12 * yc(kv2)
    y2 = r21 * xc(kv2) + r22 * yc(kv2) + r23 * zc(kv2)
    z2 = ex * xc(kv2) + ey * yc(kv2) + ez * zc(kv2)
!
!  IN2 = TRUE iff KV2 is in the window.
!
    in2 = ( 0.0D+00 <= z2 ) .and. ( x2 * x2 + y2 * y2 <= wrs )
!
!  Loop on neighbors N1 of N0.  For each triangulation edge
!  N0-N1, KV1-KV2 is the corresponding Voronoi edge.
!
    lp = lpl

    do

      lp = lptr(lp)
      kv1 = kv2
      x1 = x2
      y1 = y2
      z1 = z2
      in1 = in2
      kv2 = listc(lp)
!
!  Compute the new values of (X2,Y2,Z2) and IN2.
!
      x2 = r11 * xc(kv2) + r12 * yc(kv2)
      y2 = r21 * xc(kv2) + r22 * yc(kv2) + r23 * zc(kv2)
      z2 = ex * xc(kv2) + ey * yc(kv2) + ez * zc(kv2)
      in2 = 0.0D+00 <= z2 .and. x2 * x2 + y2 * y2 <= wrs
!
!  Add edge KV1-KV2 to the path iff both endpoints are inside
!  the window and KV1 < KV2, or KV1 is inside and KV2 is
!  outside (so that the edge is drawn only once).
!
      if ( in1 .and. ( .not. in2 .or. kv1 < kv2 ) ) then
!
!  If KV2 is a 'southern hemisphere' point, move it to the
!  intersection of edge KV1-KV2 with the equator so that
!  the edge is clipped properly.  Z2 is implicitly set to 0.
!
        if ( z2 < 0.0D+00 ) then
          x2 = z1 * x2 - z2 * x1
          y2 = z1 * y2 - z2 * y1
          t = sqrt ( x2 * x2 + y2 * y2 )
          x2 = x2 / t
          y2 = y2 / t
        end if

        write ( lun, '(2f12.6,a,2f12.6,a)' ) &
          x1, y1, ' moveto', x2, y2, ' lineto'

      end if

      if ( lp == lpl ) then
        exit
      end if

    end do

  end do
!
!  Paint the path and restore the saved graphics state (with no clip path).
!
  write ( lun, '(a)' ) 'stroke'
  write ( lun, '(a)' ) 'grestore'

  if ( numbr ) then
!
!  Nodes in the window are to be labeled with their indexes.
!  Convert FSIZN from points to world coordinates, and
!  output the commands to select a font and scale it.
!
    t = fsizn / sf
    write ( lun, '(a)' ) '/Helvetica findfont'
    write ( lun, '(f12.6,a)' ) t, ' scalefont setfont'
!
!  Loop on visible nodes N0 that project to points (X0,Y0) in
!  the window.
!
    do n0 = 1, n

      if ( ex * x(n0) + ey * y(n0) + ez * z(n0) < 0.0D+00 ) then
        cycle
      end if

      x0 = r11 * x(n0) + r12 * y(n0)
      y0 = r21 * x(n0) + r22 * y(n0) + r23 * z(n0)
!
!  Move to (X0,Y0), and draw the label N0 with the origin
!  of the first character at (X0,Y0).
!
      if ( x0 * x0 + y0 * y0 <= wrs ) then
        write ( lun, '(2f12.6,a)' ) x0, y0, ' moveto'
        write ( lun, '(a,i3,a)' ) '(', n0, ') show'
      end if

    end do

  end if
!
!  Convert FSIZT from points to world coordinates, and output
!  the commands to select a font and scale it.
!
  t = fsizt / sf
  write ( lun, '(a)' ) '/Helvetica findfont'
  write ( lun, '(f12.6,a)' ) t, ' scalefont setfont'
!
!  Display TITLE centered above the plot:
!
  y0 = wr + 3.0D+00 * t
  write ( lun, '(a)' ) title
  write ( lun, '(a,g12.6,a)' ) '  stringwidth pop 2 div neg ', y0, ' moveto'
  write ( lun, '(a)' ) title
  write ( lun, '(a)' ) '  show'
!
!  Display the window center and radius below the plot.
!
  if ( annot ) then

    x0 = -wr
    y0 = -wr - 50.0D+00 / sf
    write ( lun, '(2f12.6,a)' ) x0, y0, ' moveto'
    write ( lun, '(a,f7.2,a,f8.2,a)' ) '(Window center:  Latitude = ', elat, &
      ', Longitude = ', elon , ') show'
    y0 = y0 - 2.0D+00 * t
    write ( lun, '(2f12.6,a)' ) x0, y0, ' moveto'
    write ( lun, '(a,f5.2,a)' ) '(Angular extent = ', a, ') show'

  end if
!
!  Paint the path and output the showpage command and end-of-file indicator.
!
  write ( lun, '(a)' ) 'stroke'
  write ( lun, '(a)' ) 'showpage'
  write ( lun, '(a)' ) '%%eof'

  return
end
