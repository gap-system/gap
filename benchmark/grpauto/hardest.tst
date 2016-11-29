#############################################################################
##
#W  grpauto.tst                 GAP tests                    Alexander Hulpke
#W                                                           Max Horn
##
##
#Y  Copyright (C)  2016
##
## Warning: most of the later tests need more than the default memory allocation

#
# Many Spaces
#
gap> G:=PcGroupCode(338681823291028181778801710348121147721184790127576437,
> 29160);;
gap> H:=PcGroupCode(338681822494525443798297952136327929199594863010776437,
> 29160);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#
# maximalAbelian took memory
#
gap> G:=PcGroupCode(
> 4241001241648612707217598260832611111859648363850009814061412466747,
> 18144);;
gap> H:=PcGroupCode(
> 8452751797183492013365034036870074746315874486014489856228688347195,
> 18144);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#
# Full GL on module needs to be reduced
#
gap> G:=PcGroupCode(1083775118752032412701115313901099867559962870543,
> 11664);;
gap> H:=PcGroupCode(542004979975587406537467217880858737939706807055,
> 11664);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#
gap> G:=PcGroupCode(731609193963915469349479836674438288113664000126400,
> 15744);;
gap> H:=PcGroupCode(11518455149767885147152053318976713124993564672000126400,
> 15744);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#
gap> G:=PcGroupCode(18738408935379049727906755356708168311565445686261463850856,
> 21952);;
gap> H:=PcGroupCode(18738408935359210460657231881739776911013615108923450662760,
> 21952);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#
gap> G:=PcGroupCode(49879636940338958988550512603242447645113136854728735,
> 15552);;
gap> H:=PcGroupCode(99756065499714436414025572353196660756647930654752799,
> 15552);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#
gap> G:=PcGroupCode(332848340429713177703937106393386549730621978799427644\
> 9522931868718664965834145193694164732290560710717, 15552);;
gap> H:=PcGroupCode(66567520563199644616783412765969002195501090553565952956323\
> 68577721969603293838088502897313780378654781, 15552);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#############################################################################
