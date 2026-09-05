# For the trivial group the confluent monoid presentation has neither
# generators nor rules, which broke TwoCohomologyGeneric and FpGroupCocycle.
# H^2 is zero and the extension is just the module. Go through the permutation
# representation, as FpGroupCocycle only asserts the size of the fp group.
gap> triv:=function(G,d,F)
>      local coh,ext,p;
>      coh:=TwoCohomologyGeneric(G,GModuleByMats([],d,F));
>      ext:=FpGroupCocycle(coh,coh.zero,true);
>      p:=Image(IsomorphismPermGroup(ext));
>      return [Length(coh.cohomology),Size(p),AbelianInvariants(p)];
>    end;;
gap> triv(TrivialGroup(IsPermGroup),1,GF(2));
[ 0, 2, [ 2 ] ]
gap> triv(TrivialGroup(IsPermGroup),2,GF(2));
[ 0, 4, [ 2, 2 ] ]
gap> triv(TrivialGroup(IsPermGroup),3,GF(3));
[ 0, 27, [ 3, 3, 3 ] ]

# a trivial group that does have (redundant) generators
gap> triv(Group(()),2,GF(2));
[ 0, 4, [ 2, 2 ] ]
gap> triv(TrivialGroup(IsFpGroup),2,GF(2));
[ 0, 4, [ 2, 2 ] ]
gap> Unbind(triv);

# a module given without generators is acted on trivially, also by a bigger
# group: it must agree with the same module given by identity matrices
gap> G:=SymmetricGroup(3);;
gap> mats:=ListWithIdenticalEntries(Length(GeneratorsOfGroup(G)),
>            IdentityMat(2,GF(2)));;
gap> coh:=TwoCohomologyGeneric(G,GModuleByMats([],2,GF(2)));;
gap> coh.cohomology=TwoCohomologyGeneric(G,
>      GModuleByMats(mats,GF(2))).cohomology;
true

# H^2(S3,GF(2)) is one-dimensional for the trivial action, so twice that here.
# The nonzero classes give the central extension Dic3 x C2, the zero class the
# split one.
gap> Length(coh.cohomology);
2
gap> Set(coh.cohomology,c->IdGroup(Image(IsomorphismPermGroup(
>      FpGroupCocycle(coh,c,true)))));
[ [ 24, 7 ] ]
gap> IdGroup(Image(IsomorphismPermGroup(FpGroupCocycle(coh,coh.zero,true))));
[ 24, 14 ]
gap> Unbind(coh); Unbind(mats); Unbind(G);
