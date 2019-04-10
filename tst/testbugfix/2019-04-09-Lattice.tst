# see https://github.com/gap-system/gap/pull/3397
gap> l:=AllSmallGroups(960,IsSolvableGroup,false);;g:=l[5];;
gap> StructureDescription(g);;t:=TableOfMarks(g);;
