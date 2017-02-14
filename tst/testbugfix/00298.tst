# 2013/11/02 (AH)
gap> f:=FreeGroup(2);; id:=Group(Identity(f));; Id:=TrivialSubgroup(f);;
gap> LowIndexSubgroupsFpGroup(f,Id,2)=LowIndexSubgroupsFpGroup(f,id,2);
true
