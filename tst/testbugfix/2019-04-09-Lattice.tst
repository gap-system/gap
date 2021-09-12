# see https://github.com/gap-system/gap/pull/3397
# and https://github.com/gap-system/gap/issues/3496
gap> l:=AllSmallGroups(960,IsSolvableGroup,false);;g:=l[5];;
gap> nat:=NaturalHomomorphismByNormalSubgroup(g,SolvableRadical(g));;
gap> fpi:=IsomorphismFpGroup(Group(GeneratorsOfGroup(Range(nat))));;
gap> fpi:=GroupHomomorphismByImages(Range(nat),Range(fpi),
> GeneratorsOfGroup(Range(nat)),List(GeneratorsOfGroup(Range(nat)),
> x->ImagesRepresentative(fpi,x)));;
gap> SetIsomorphismFpGroup(ImagesSource(nat),fpi);;
gap> StructureDescription(g);;t:=TableOfMarks(g);;
