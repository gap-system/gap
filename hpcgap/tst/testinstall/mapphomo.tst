#############################################################################
##
#W  mapphomo.tst                  GAP Tests                    Max Horn
##
gap> START_TEST("mapphomo.tst");
gap> G:=SymmetricGroup(4);; gens:=[(1,2,3), (2,3,4)];; G0 := Subgroup(G, gens);;
gap> H:=AbelianGroup(IsPcGroup, [3,3,4]);; imgs:=[H.1, H.2];; H0 := Subgroup(H, imgs);;
gap> Size(H0);
9
gap> hom:=GroupGeneralMappingByImages(G, H, gens, imgs);;
gap> Size(CoKernel(hom));
3
gap> Size(Kernel(hom));
4
gap> Size(ImagesSource(hom));
9
gap> H:=AbelianGroup(IsPermGroup, [3,3,4]);; imgs:=[H.1, H.2];; H0 := Subgroup(H, imgs);;
gap> Size(H0);
9
gap> hom:=GroupGeneralMappingByImages(G, H, gens, imgs);;
gap> Size(CoKernel(hom));
3
gap> Size(Kernel(hom));
4
gap> Size(ImagesSource(hom));
9
gap> H:=AbelianGroup(IsFpGroup, [3,3,4]);; imgs:=[H.1, H.2];; H0 := Subgroup(H, imgs);;
gap> Size(H0);
9
gap> hom:=GroupGeneralMappingByImages(G, H, gens, imgs);;
gap> Size(CoKernel(hom));
3
gap> Size(Kernel(hom));
4
gap> Size(ImagesSource(hom));
9
gap> # Another test: map is total, but not single valued
gap> G:=SymmetricGroup(4);;
gap> H:=AbelianGroup(IsPermGroup, [3,3,4]);;
gap> hom:=GroupGeneralMappingByImages(G, H, [(1,2,3), (2,3,4), (1,2)], [H.1, H.2, One(H)]);;
gap> a:=Group( (1,2,3) );;
gap> Size(a);
3
gap> b:=ImagesSet(hom, a);;
gap> Size(CoKernel(hom));
9
gap> not IsBound(StabChainOptions(b).limit) or StabChainOptions(b).limit>=9;
true
gap> Size(b) = Size(CoKernel(hom));
true
gap> G:=CyclicGroup(IsPermGroup,15);;
gap> hom:=GroupGeneralMappingByImages(G, G, GeneratorsOfGroup(G), [G.1^3]);;
gap> HasIsTotal(hom); IsTotal(hom);                                        
true
true
gap> HasIsSurjective(hom); IsSurjective(hom);                              
false
false
gap> hom:=GroupGeneralMappingByImages(G, G, [G.1^3], GeneratorsOfGroup(G));;
gap> HasIsTotal(hom); IsTotal(hom);
false
false
gap> HasIsSurjective(hom); IsSurjective(hom);
true
true
gap> STOP_TEST( "mapphomo.tst", 1);

#############################################################################
##
#E
