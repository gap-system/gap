gap> G:=Group((1,2),(2,3),(3,4));;
gap> H:=Image(IsomorphismFpGroup(G));;
gap> MinimalGeneratingSet(H);
[ F1^-1*F2*F1^-1*F3^-1, F1^-1*F2^-1*F3^-1 ]
