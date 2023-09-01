#
gap> G:=SmallGroup(4,2);;
gap> epi:=EpimorphismSchurCover(G,[2]);;
#I  Warning: EpimorphismSchurCover via Holt's algorithm is under construction
gap> Size(Kernel(epi));
2

#
gap> epi:=EpimorphismSchurCover(AlternatingGroup(5), [2,3,5,7]);;
#I  Warning: EpimorphismSchurCover via Holt's algorithm is under construction
gap> Size(Kernel(epi));
2

#
gap> epi:=EpimorphismSchurCover(AlternatingGroup(5), [3,5,7]);;
#I  Warning: EpimorphismSchurCover via Holt's algorithm is under construction
gap> Size(Kernel(epi));
1

#
gap> epi:=EpimorphismSchurCover(SylowSubgroup(AlternatingGroup(5),2), [2,3,5,7]);;
#I  Warning: EpimorphismSchurCover via Holt's algorithm is under construction
gap> Size(Kernel(epi));
2
