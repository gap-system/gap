# Reported by Izumi Miyamoto on 2011/12/17, added by MH on 2011/12/18
# Computing normalizers inside the trivial group could error out.
gap> Normalizer(Group(()),Group((1,2,3)));
Group(())
gap> Normalizer(Group(()),TransitiveGroup(3,1));
Group(())
