# For the trivial group the confluent monoid presentation has neither
# generators nor rules, which broke TwoCohomologyGeneric and FpGroupCocycle.
# H^2 is zero and the extension is just the module.
gap> triv:=function(G,d,F)
>      local coh,ext;
>      coh:=TwoCohomologyGeneric(G,GModuleByMats([],d,F));
>      ext:=FpGroupCocycle(coh,coh.zero,true);
>      return [Length(coh.cohomology),Size(ext),AbelianInvariants(ext)];
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

# a module given without generators acts trivially, also on a bigger group
gap> coh:=TwoCohomologyGeneric(SymmetricGroup(3),GModuleByMats([],2,GF(2)));;
gap> Length(coh.cohomology);
2
gap> Size(FpGroupCocycle(coh,coh.cohomology[1],true));
24
gap> Unbind(coh);
