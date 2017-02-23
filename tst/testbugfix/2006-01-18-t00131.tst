# 2006/01/18 (AH)
gap> G:=WreathProduct(CyclicGroup(3),Group((1,2,3),(4,5,6)));;
gap> Assert(0,Size(Group(GeneratorsOfGroup(G)))=6561);
