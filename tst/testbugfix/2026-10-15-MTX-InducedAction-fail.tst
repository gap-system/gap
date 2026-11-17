# MTX induced actions must return fail if sub does not span a submodule
gap> pm:=PermutationGModule(SymmetricGroup(4),GF(2));;
gap> e:=IdentityMat(4,GF(2));;
gap> MTX.InducedActionSubmodule(pm,e{[1]});
fail
gap> MTX.InducedActionSubmodule(pm,e{[1..3]});
fail
gap> MTX.InducedActionSubmoduleNB(pm,e{[1..3]});
fail
gap> MTX.InducedActionFactorModule(pm,e{[1]});
fail
gap> MTX.InducedAction(pm,e{[1]});
fail
gap> MTX.InducedAction(pm,e{[1]},1);
fail
gap> MTX.InducedAction(pm,e{[1..3]},2);
fail

# a genuine submodule still works
gap> sub:=[[1,1,1,1]]*Z(2);;
gap> MTX.Dimension(MTX.InducedActionSubmodule(pm,sub));
1
gap> MTX.Dimension(MTX.InducedActionFactorModule(pm,sub));
3
gap> List(MTX.InducedAction(pm,sub){[1..3]},MTX.Dimension);
[ 1, 3, 4 ]
