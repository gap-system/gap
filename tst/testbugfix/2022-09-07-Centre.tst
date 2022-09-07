# Centre for PcGroups sometimes returned wrong results.
# See https://github.com/gap-system/gap/issues/3940
#
gap> G:=SmallGroup(2^9,261648);;
gap> Size(Center(G)); # This used to return 4
8
