# 2007/07/27 (AH)
gap> H:=GroupByPcgs(Pcgs(AbelianGroup([6,6])));;
gap> K:=SmallGroup(IdGroup(H));;
gap> 1H:=TrivialGModule(H,GF(3));;
gap> 1K:=TrivialGModule(K,GF(3));;
gap> Assert(1,Rank(TwoCohomologySQ(CollectorSQ(H,1H,true),H,1H))=
> Rank(TwoCohomologySQ(CollectorSQ(K,1K,true),K,1K)));
