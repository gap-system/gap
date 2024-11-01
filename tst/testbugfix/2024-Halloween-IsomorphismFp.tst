# Fix for bug in IsomorphismFp
# reported by Andries Brouwer, 10/31/24

gap> G:=PSL(3,7);;
gap> maxes := MaximalSubgroupClassReps(G);;
gap> maxes1 := MaximalSubgroupClassReps(maxes[1]);;
gap> maxes12:= maxes1[2];;
gap> StructureDescription(maxes12:short);;
