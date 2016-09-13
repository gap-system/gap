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

