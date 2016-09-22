#############################################################################
##
#W  grpauto.tst                 GAP tests                    Alexander Hulpke
#W                                                           Max Horn
##
##
#Y  Copyright (C)  2016
##
## Warning: Later tests need more than the default memory allocation


gap> START_TEST("grpauto.tst");

#
# hard-iso
#
gap> G:=PcGroupCode(589146814442329838036024080610343654876506937853710969\
> 448924603190236492427673556989072961847,11664);;
gap> H:=PcGroupCode(801562094435225650939080918450186172844860829657513982\
> 80193370111859863168020375597783858966368416055,11664);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#
# hard-iso2
#
gap> G:=PcGroupCode(409374400436488159632156475187687419052272443300404477\
> 8304456449542618727,11664);;
gap> H:=PcGroupCode(409362703022669659121228158166302826716273465648729361\
> 3630709080224464487,11664);;
gap> K:=PcGroupCode(409374400436488159632788450059215346119864636722303267\
> 1585655861072658023,11664);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,K);
fail
gap> IsomorphismGroups(H,K);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#
# hard-iso3
#
gap> G:=PcGroupCode(
> 47230783805023816758284073850775753212570866553716206981615555,20000);;
gap> H:=PcGroupCode(                                                          
> 2361539190251190837914203692538788582942691934753704906691,20000);;
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
gap> G:=PcGroupCode(731609193963915469349479836674438288113664000126400,
> 15744);;
gap> H:=PcGroupCode(11518455149767885147152053318976713124993564672000126400,
> 15744);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

gap> G:=PcGroupCode(18738408935379049727906755356708168311565445686261463850856,
> 21952);;
gap> H:=PcGroupCode(18738408935359210460657231881739776911013615108923450662760,
> 21952);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false

#
# Too hard work for permiso
#
gap> G:=Group((1,3,8,21,37,43,36,35)(2,6,15,30,41,29,19,4)(5,7,18,34,46,
> 32,38,25)(9,23,39,28,27,42,12,14)(10,26,17,20,24,33,13,11)(16,31,45,48,
> 44,47,40,22)(50,53)(51,52)(55,56)(57,58), (1,4,11,28,37,30,20,14)
> (2,3,9,24,41,43,27,10)(5,13,26,31,46,17,33,47)(6,16,32,15,29,44,7,19)
> (8,22,38,21,36,48,18,35)(12,23,40,25,39,42,45,34)(49,51)(50,52)(54,55)
> (56,57),(1,2,5,12,26)(3,7,17,6,14)(4,10,25,35,42)(8,20,9,18,15)
> (11,27,38,19,36)(13,29,28,43,32)(21,23,30,24,34)(33,37,41,46,39)
> (49,50,52,51,53));;
gap> Size(AutomorphismGroup(G)); 
2880000

#
# from here on needs 4GB
#
# hard-iso4
#
gap> G:=PcGroupCode(
> 741231213963541373679312045151639276850536621925972119311,11664);;
gap> H:=PcGroupCode(
> 888658311993669104086576972570546890038187728096037768975,11664);;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(G,PcGroupCode(CodePcGroup(G),Size(G)))=fail;
false




gap> STOP_TEST( "grpauto.tst", 1814420000);

