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

#
# Another problem related to this: Using `Image` to apply an intermediate nice
# monomorphism for a FFE matrix group would raise an error if testing inputs
# outside its domain; changing this to use ImageElm instead produces `fail`,
# which is what we need for e.g. membership tests.
# See <https://github.com/gap-system/gap/issues/6142>
#
gap> G:=Group([ [ [ 1, 0, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ 0, 1, 0, 0 ] ], [ [ 0, 1/2*E(5)+1/2*E(5)^4, 1/2, 1/2*E(5)^2+1/2*E(5)^3 ], [ 1/2*E(5)+1/2*E(5)^4, -1/2*E(5)^2-1/2*E(5)^3, -1/2, 0 ], [ 1/2, -1/2, -1/2, -1/2 ], [ 1/2*E(5)^2+1/2*E(5)^3, 0, -1/2, -1/2*E(5)-1/2*E(5)^4 ] ] ]);;
gap> g:=[ [ 1, 0, 0, 0 ], [ 0, -1/2, 1/2*E(5)^2+1/2*E(5)^3, -1/2*E(5)-1/2*E(5)^4 ], [ 0, 1/2*E(5)^2+1/2*E(5)^3, 1/2*E(5)+1/2*E(5)^4, 1/2 ], [ 0, -1/2*E(5)-1/2*E(5)^4, 1/2, 1/2*E(5)^2+1/2*E(5)^3 ] ];;
gap> g in G;
false
