# if ExteriorPower(V,n) is called with n > Dimension(V), the space returned is marked
# as 1-dimensional rather than 0-dimensional.

gap> wedge := ExteriorPower(Rationals^10,11);;
gap> Dimension(wedge);
0
