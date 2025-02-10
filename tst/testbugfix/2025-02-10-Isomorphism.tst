# Fix #5931 Isomorphism test / Characteristic matching
gap> G:= PcGroupCode( 7081272684613405169270145749707713769178346454326033042960705194376896383, 512 );;
gap> H:= PcGroupCode( 13830610712135556969734175751921406466451196220671918889959595223883643, 512 );;
gap> IsomorphismGroups(G,H);
fail
gap> IsomorphismGroups(H,G);
fail
gap> GG:=PcGroupWithPcgs(SpecialPcgs(G));; # different isomorphic
gap> IsGeneralMapping(IsomorphismGroups(G,GG)); # so isomorphism works
true
gap> HH:=PcGroupWithPcgs(SpecialPcgs(H));;
gap> IsGeneralMapping(IsomorphismGroups(H,HH));
true
gap> IsGeneralMapping(IsomorphismGroups(HH,H));
true
