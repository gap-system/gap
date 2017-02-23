#2016/05/30 (CJ, bug reported github #798)
gap> sc := StabChainOp(Group((1,2)), rec(base := [3,2], reduced := false));;
gap> SCRSift(sc, (1,2));
()
