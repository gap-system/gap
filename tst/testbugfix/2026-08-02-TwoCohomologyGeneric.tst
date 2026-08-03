# TwoCohomologyGeneric used the wrong dimension for the space of cocycles
# in case no conditions on the tails were found, which made it error out
# (or return a wrong answer) for modules of dimension > 1.
gap> triv:=function(G,d,F)
>      local mo;
>      mo:=GModuleByMats(List(GeneratorsOfGroup(G),x->IdentityMat(d,F)),d,F);
>      return Length(TwoCohomologyGeneric(G,mo).cohomology);
>    end;;
gap> List([1..3],d->triv(CyclicGroup(2),d,GF(2)));
[ 1, 2, 3 ]
gap> List([1..3],d->triv(ElementaryAbelianGroup(8),d,GF(2)));
[ 6, 12, 18 ]
gap> List([1..3],d->triv(DihedralGroup(8),d,GF(2)));
[ 3, 6, 9 ]
gap> List([1..3],d->triv(CyclicGroup(3),d,GF(3)));
[ 1, 2, 3 ]
gap> Unbind(triv);
