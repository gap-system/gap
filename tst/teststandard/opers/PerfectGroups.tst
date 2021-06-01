gap> START_TEST("PerfectGroups.tst");

#
gap> Sum(SizesPerfectGroups(),NrPerfectGroups);
15768
gap> l:=[61440, 86016, 122880, 172032, 245760, 344064, 368640, 491520,
> 688128, 737280, 983040 ];;
gap> List(l,NrPerfectGroups);
[ 98, 52, 258, 154, 582, 291, 46, 1004, 508, 54, 1880 ]
gap> gp:=List(l,x->PerfectGroup(IsPermGroup,x,30));;
gap> gp:=List(gp,x->Group(GeneratorsOfGroup(x)));;
gap> List(gp,Size)=l;
true
gap> ForAll(gp,IsPerfect);
true
gap> List(gp,NrMovedPoints);
[ 240, 28, 768, 128, 400, 224, 116, 80, 308, 1024, 560 ]

#
gap> STOP_TEST("PerfectGroups.tst",1);
