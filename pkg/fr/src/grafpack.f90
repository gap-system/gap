!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! removed all of grafpack.f90 except the following routine.
!!
!! original file at
!! http://people.sc.fsu.edu/~burkardt/f_src/grafpack/grafpack.html
!!
!! @(#)$Id: grafpack.f90,v 1.2 2009/03/27 19:28:53 gap Exp $
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!
subroutine graph_arc_min_span_tree ( nnode, nedge, inode, jnode, cost, &
  itree, jtree, tree_cost )

!*****************************************************************************80
!
!! GRAPH_ARC_MIN_SPAN_TREE finds a minimum spanning tree of a graph.
!
!  Discussion:
!
!    The input graph is represented by a list of edges.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license.
!
!  Modified:
!
!    21 July 2000
!
!  Reference:
!
!    Hang Tong Lau,
!    Combinatorial Heuristic Algorithms in FORTRAN,
!    Springer Verlag, 1986.
!
!  Parameters:
!
!    Input, integer NNODE, the number of nodes in the graph.
!
!    Input, integer NEDGE, the number of edges in the graph.
!
!    Input, integer INODE(NEDGE), JNODE(NEDGE), the start and end nodes
!    of the edges.
!
!    Input, real ( kind = 8 ) COST(NEDGE), the cost or length of each edge.
!
!    Output, integer ITREE(NNODE-1), JTREE(NNODE-1), the pairs of nodes that
!    form the edges of the spanning tree.
!
!    Output, real ( kind = 8 ) TREE_COST, the total cost or length
!    of the spanning tree.
!
  implicit none

  integer nedge
  integer nnode

  integer best
  real ( kind = 8 ) cost(nedge)
  real ( kind = 8 ) d
  logical free(nnode)
  integer i
  integer ic
  integer ij
  integer inode(nedge)
  integer itr
  integer itree(nnode-1)
  integer iwork1(nnode)
  integer iwork2(nnode)
  integer iwork4(nedge)
  integer iwork5(nedge)
  integer j
  integer jnode(nedge)
  integer jtree(nnode-1)
  integer jj
  integer k
  integer kk
  integer l
  real ( kind = 8 ) tree_cost
  real ( kind = 8 ) wk6(nnode)

  wk6(1:nnode) = huge ( wk6(1) )
  free(1:nnode) = .true.
  iwork1(1:nnode) = 0
  iwork2(1:nnode) = 0
  itree(1:nnode-1) = 0
  jtree(1:nnode-1) = 0
!
!  Find the first non-zero arc.
!
  do ij = 1, nedge
    if ( inode(ij) /= 0 ) then
      i = inode(ij)
      exit
    end if
  end do

  wk6(i) = 0.0D+00
  free(i) = .false.

  tree_cost = 0.0D+00

  do jj = 1, nnode - 1

    wk6(1:nnode) = huge ( wk6(1) )

    do i = 1, nnode
!
!  For each forward arc originating at node I
!  calculate the length of the path to node I.
!
      if ( .not. free(i) ) then

        ic = 0

        do k = 1, nedge

          if ( inode(k) == i ) then
            ic = ic + 1
            iwork5(ic) = k
            iwork4(ic) = jnode(k)
          end if

          if ( jnode(k) == i ) then
            ic = ic + 1
            iwork5(ic) = k
            iwork4(ic) = inode(k)
          end if

        end do

        if ( 0 < ic ) then

          do l = 1, ic

            k = iwork5(l)
            j = iwork4(l)

            if ( free(j) ) then

              d = tree_cost + cost(k)

              if ( d < wk6(j) ) then
                wk6(j) = d
                iwork1(j) = i
                iwork2(j) = k
              end if

            end if

          end do

        end if

      end if

    end do
!
!  Identify the free node of minimum potential.
!
    d = huge ( d )
    best = 0

    do i = 1, nnode

      if ( free(i) ) then
        if ( wk6(i) < d ) then
          d = wk6(i)
          best = i
          itr = iwork1(i)
          kk = iwork2(i)
        end if
      end if

    end do
!
!  Add that node to the tree.
!
    if ( d < huge ( d ) ) then
      free(best) = .false.
      tree_cost = tree_cost + cost(kk)
      itree(jj) = itr
      jtree(jj) = best
    end if

  end do

  return
end
