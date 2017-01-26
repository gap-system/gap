# Reported by Radoslav Kirov on 2011/06/11, added by MH on 2011/09/29
gap> H := [
> [ Z(5)^3, Z(5)^0, Z(5)^0, 0*Z(5), 0*Z(5), 0*Z(5) ],
> [ Z(5)^0, Z(5)^0, 0*Z(5), Z(5)^0, 0*Z(5), 0*Z(5) ],
> [ Z(5)^2, Z(5), 0*Z(5), 0*Z(5), Z(5)^0, 0*Z(5) ],
> [ Z(5)^3, Z(5), 0*Z(5), 0*Z(5), 0*Z(5), Z(5)^0 ]] ;;
gap> cl:=CosetLeadersMatFFE(H, GF(5));; Size(cl);
625
gap> [0,0,3,0,0,2]*Z(5)^0 in cl;
true
gap> [4,0,1,1,4,0]*Z(5)^0 in cl;
false
