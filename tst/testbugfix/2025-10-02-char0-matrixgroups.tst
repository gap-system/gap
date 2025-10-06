# \in incorrectly returned 'false' for finite rational matrix groups if the
# matrix being tested was not integral.
# See <https://github.com/gap-system/gap/issues/6133>.
#
gap> G:=Group([ 1/2 * [[-1+1*E(4), -1+1*E(4)], [1+1*E(4), -1-1*E(4)]], E(4) * [[0,1],[-1,0]] ]);;
gap> g:=List(G)[9];;
gap> g in G;
true

#
gap> H:=Group( 1/2*[[-1,1,-1,1],[-1,-1,-1,-1],[1,1,-1,-1],[-1,1,1,-1]],
>                  [[0,0,0,1],[0,0,-1,0],[0,-1,0,0],[1,0,0,0]] );;
gap> h := 1/2*[[-1,-1,1,-1],[1,-1,1,1],[-1,-1,-1,1],[1,-1,-1,-1]];;
gap> h in H;
true

#
# Moreover, if given a matrix outside the original group, it may happen that
# the chosen prime p used for reduction to a prime field divides the
# denominator of one of the matrix entries, in which case mapping the matrix
# to GF(p) does not work; we need to catch that.
# See <https://github.com/gap-system/gap/issues/6139>.
#
gap> G := Group([[[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]],
>  [[1, 0, 0, 0], [0, 0, 1, 0], [0, -1, 0, 0], [0, 0, 0, 1]],
>  [[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, 0, 1], [0, 0, 1, 0]]]);
<matrix group with 3 generators>
gap> Centralizer(G,[[0, 0, 0, 0], [0, 1/3, 1/3, 1/3], [0, 1/3, 1/3, 1/3], [0, 1/3, 1/3, 1/3]]);
<matrix group with 4 generators>
gap> Size(last);
24
