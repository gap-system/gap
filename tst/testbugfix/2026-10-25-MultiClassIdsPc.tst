# Regression test for https://github.com/gap-system/gap/issues/6783
# SmallGroup(7^5, 68), whose p-central series must not be merged into
# non-central steps when identifying classes
gap> G := PcGroupCode(4630002057748, 7^5);;
gap> Length(Irr(G));
679
