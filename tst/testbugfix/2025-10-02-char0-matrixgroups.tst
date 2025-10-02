# \in incorrectly returned 'false' for finite rational matrix groups
# if the matrix being tested was not integral.
# See <https://github.com/gap-system/gap/issues/6133>
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
