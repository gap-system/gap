#############################################################################
##
##  derived.gi        recog package                       Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2006 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Implementation stuff for derived subgroup method
##
##  $Id: derived.gi,v 1.5 2006/10/13 04:36:26 gap Exp $
##
#############################################################################

RECOG.DerivedSubgroupMonteCarlo := function(g)
  local gens,gens2,i,x,y;
  gens := [];
  for i in [1..10] do
      x := PseudoRandom(g);
      y := PseudoRandom(g);
      Add(gens,Comm(x,y));
  od;
  gens2 := FastNormalClosure(g,gens,10);
  return GroupWithGenerators(gens2);
end;

FindHomMethodsProjective.Derived :=
  function(ri,G)
    # We assume G to act absolutely irreducible
    local H,a,basis,collf,conjgensG,f,hom,homcomp,homs,homsimg,kro,o,r,subdim;
    f := FieldOfMatrixGroup(G);
    if not(IsBound(ri!.derived)) then
      ri!.derived := RECOG.DerivedSubgroupMonteCarlo(G);
      ri!.derived_mtx := GModuleByMats(GeneratorsOfGroup(ri!.derived),f);
    fi;
    if ForAll(GeneratorsOfGroup(ri!.derived),IsOneProjective) then
        Info(InfoRecog,1,"Derived subgroup is trivial.");
        return false;
    fi;
    if MTX.IsIrreducible(ri!.derived_mtx) then
        if not(MTX.IsAbsolutelyIrreducible(ri!.derived_mtx)) then
            # FIXME: Check for field automorphisms:
            Error("not yet done");
        fi;
        return false;
    fi;
    collf := MTX.CollectedFactors(ri!.derived_mtx);
    if Length(collf) = 1 then
        if MTX.Dimension(collf[1][1]) = 1 then
            Error("This should never have happened (2), tell Max.");
            # This should have been caught by the triviality test above.
        fi;
        Info(InfoRecog,1,"Restriction to derived subgroup is homogeneous.");
        homs := MTX.Homomorphisms(collf[1][1],ri!.derived_mtx);
        basis := Concatenation(homs);
        ConvertToMatrixRep(basis);
        subdim := MTX.Dimension(collf[1][1]);
        r := rec(t := basis, ti := basis^-1, 
                 blocksize := MTX.Dimension(collf[1][1]));
        # Note that we already checked for semilinear, so we know that
        # the irreducible N-submodule is absolutely irreducible!
        # Now we believe to have a tensor decomposition:
        conjgensG := List(GeneratorsOfGroup(G),x->r.t * x * r.ti);
        kro := List(conjgensG,g->RECOG.IsKroneckerProduct(g,r.blocksize));
        if not(ForAll(kro,k->k[1] = true)) then
            Info(InfoRecog,1,"VERY, VERY, STRANGE!");
            Info(InfoRecog,1,"False alarm, was not a tensor decomposition.");
            return false;
        fi;

        H := GroupWithGenerators(conjgensG);
        hom := GroupHomByFuncWithData(G,H,RECOG.HomDoBaseChange,r);
        Sethomom(ri,hom);

        # Hand down information:
        forfactor(ri).blocksize := r.blocksize;
        forfactor(ri).generatorskronecker := kro;
        Add( forfactor(ri).hints,
             rec( method := FindHomMethodsProjective.KroneckerProduct, 
                  rank := 2000, stamp := "KroneckerProduct" ), 1 );
        # This is an isomorphism:
        findgensNmeth(ri).method := FindKernelDoNothing;
        return true;
    fi;
    Info(InfoRecog,1,"Using action on the set of homogeneous components",
         " (",Length(collf)," elements)...");
    # Now find a homogeneous component to act on it:
    homs := MTX.Homomorphisms(collf[1][1],ri!.derived_mtx);
    homsimg := BasisVectors(Basis(VectorSpace(f,Concatenation(homs))));
    homcomp := MutableCopyMat(homsimg);
    # FIXME: This will go:
    ConvertToMatrixRep(homcomp);
    TriangulizeMat(homcomp);
    o := Orb(G,homcomp,OnSubspacesByCanonicalBasis,rec(storenumbers := true));
    Enumerate(o);
    a := OrbActionHomomorphism(G,o);
    Sethomom(ri,a);
    Setmethodsforfactor(ri,FindHomDbPerm);

    return true;
  end;


