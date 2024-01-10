#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#F FpGroupPcGroupSQ( G ). . . . . . . . .relators according to sq-algorithmus
##
InstallGlobalFunction( FpGroupPcGroupSQ, function( G )
    local F, f, g, n, rels, i, j, w, v, p, k;

    F := FreeGroup(IsSyllableWordsFamily, Length(Pcgs(G)) );
    f := GeneratorsOfGroup( F );
    g := Pcgs( G );
    n := Length( g );
    rels := List( [1..n], x -> List( [1..x], ReturnFalse ) );
    for i in [1..n] do
        for j in [1..i-1] do
            w := f[j]^-1 * f[i] * f[j];
            v := ExponentsOfPcElement( g, g[j]^-1 * g[i] * g[j] );
            for k in Reversed( [1..n] ) do
                w := w * f[k]^(-v[k]);
            od;
            rels[i][j] := w;
        od;
        p := RelativeOrderOfPcElement( g, g[i] );
        w := f[i]^p;
        v := ExponentsOfPcElement( g, g[i]^p );
        for k in Reversed( [1..n] ) do
            w := w * f[k]^(-v[k]);
        od;
        rels[i][i] := w;
    od;
    return rec( group := F, relators := Concatenation( rels ) );
end );

#############################################################################
##
#F MappedPcElement( elm, pcgs, list )
##
InstallGlobalFunction(MappedPcElement,function( elm, pcgs, list )
    local vec, new, i;
    if Length( list ) = 0 then return fail; fi;
    vec := ExponentsOfPcElement( pcgs, elm );
    if Length( list ) < Length( vec ) then return fail; fi;
    new := false;
    for i in [1..Length(vec)] do
      if vec[i]>0 then
        if new=false then
          new := list[i]^vec[i];
        else
          new := new * list[i]^vec[i];
        fi;
      fi;
    od;
    if new=false then
      new:=One(list[1]);
    fi;
    return new;
end);

#############################################################################
##
#F TracedPointPcElement( elm, pcgs, imgs,pt )
##
InstallGlobalFunction(TracedPointPcElement,function( elm, pcgs, list,pt )
local vec, i,j;
  if Length( list ) = 0 then return pt; fi;
  vec := ExponentsOfPcElement( pcgs, elm );
  if Length( list ) < Length( vec ) then return fail; fi;
  for i in [1..Length(vec)] do
    if vec[i]>0 then
      for j in [1..vec[i]] do
        pt:=pt^list[i];
      od;
    fi;
  od;
  return pt;
end);

#############################################################################
##
#F  ExtensionSQ( C, G, M, c )
##
##  If <c> is zero,  construct the split extension of <G> and <M>
##
InstallGlobalFunction( ExtensionSQ, function( C, G, M, c )
    local field, d, n, rels, i, j, w, p, k, l, v, F, m, relators, H, orders,
          Mgens;

    # construct module generators
    field := M.field;
    Mgens := M.generators;
    d := M.dimension;
    orders := List([1..d], x -> Characteristic(M.field));
    if Length(Mgens) = 0 then
        return AbelianGroup( orders );
    fi;
    n := Length(Pcgs( G ));

    # add tails to presentation
    if c = 0  then
        rels := ShallowCopy( C.relators );
    else
        rels := [];
        for i  in [ 1 .. n ]  do
            rels[i] := [];
            for j  in [ 1 .. i ]  do
                if C.relators[i][j] = 0  then
                    w := [];
                else
                    w := ShallowCopy(C.relators[i][j]);
                fi;
                p := (i^2-i)/2 + j - 1;
                for k  in [ 1 .. d ]  do
                    l := c[p*d+k];
                    if not IsZero( l ) then
                        Add( w, n+k );
                        Add( w, IntFFE(l) );
                    fi;
                od;
                if 0 = Length(w)  then
                    w := 0;
                fi;
                rels[i][j] := w;
            od;
        od;
    fi;

    # add module
    for j  in [ 1 .. d ]  do
        rels[n+j] := [];
        for i  in [ 1 .. j-1 ]  do
            rels[n+j][n+i] := [ n+j, 1 ];
        od;
        rels[n+j][n+j] := 0;
    od;

    # add operation of <G> on module
    for i  in [ 1 .. n ]  do
        for j  in [ 1 .. d ]  do
            v := Mgens[i][j];
            w := [];
            for k  in [ 1 .. d ]  do
                l := v[k];
                if not IsZero( l ) then
                    Add( w, n+k );
                    Add( w, IntFFE(l) );
                fi;
            od;
            rels[n+j][i] := w;
        od;
    od;

    orders := Concatenation( C.orders, orders );

    # create extension as fp group
    F := FreeGroup(IsSyllableWordsFamily, n+d );
    m := GeneratorsOfGroup( F );

    # and construct new presentation from collector
    relators := [];
    for i  in [ 1 .. d+n ]  do
        for j  in [ i .. d+n ]  do
            if i = j  then
                w := m[i]^orders[i];
            else
                w := m[j]^m[i];
            fi;
            v := rels[j][i];
            if 0 <> v  then
                for k  in [ Length(v)-1, Length(v)-3 .. 1 ]  do
                    w := w * m[v[k]]^(-v[k+1]);
                od;
            fi;
            Add( relators, w );
        od;
    od;

#    Error("A");
    H := PcGroupFpGroup( F / relators );




    SetModuleOfExtension( H, Subgroup(H, Pcgs(H){[n+1..n+d]} ) );
    return H;
end );

#############################################################################
##
#F  FastExtSQ( G, M, c,check )
##
##
BindGlobal( "FastExtSQ", function( G, M, c,check )
    local field, d, n, i, j, w, p, k, l, v, F, H, orders,
          Mgens,pcgs,z,fam,col,exp;

    pcgs:=Pcgs(G);

    # construct module generators
    field := M.field;
    z:=Zero(field);
    Mgens := M.generators;
    if Length(Mgens) = 0 then
        return AbelianGroup( List([1..M.dimension],
                              x -> Characteristic(M.field)));
    fi;
    d := Length(Mgens[1]);
    n := Length(pcgs);

    F:=FreeGroup(IsSyllableWordsFamily,d+n);
    fam:=FamilyObj(One(F));

    orders := Concatenation( RelativeOrders(pcgs), List( [1..d],
                                       x -> Characteristic( field ) ) );

    col:=SingleCollector(GeneratorsOfGroup(F),orders);

    for i in [1..n] do
      for j in [1..i] do
        if i=j then
          exp:=ExponentsOfRelativePower(pcgs,i);
        else
          exp:=ExponentsOfConjugate(pcgs,i,j);
        fi;
        w:=[];
        # start at j -- there cannot be earlier entries.
        for k in [j..n] do
          if exp[k]<>0 then
            Add(w,k);
            Add(w,exp[k]);
          fi;
        od;

        if not IsInt(c) then # add cocycle info
          p := (i^2-i)/2 + j - 1;
          for k  in [ 1 .. d ]  do
            l := c[p*d+k];
            if l <> z then
              Add( w, n+k );
              Add( w, IntFFE(l) );
            fi;
          od;
        fi;

        if Length(w)>0 then # other relators are considered trivial
          if i=j then
            w:=ObjByExtRep(fam,w);
            SetPower(col,i,w);
          elif w<>[i,1] then
            w:=ObjByExtRep(fam,w);
            SetConjugate(col,i,j,w);
          fi;
        fi;
      od;
    od;

    # module relations do not need to be written down -- they are all
    # trivial

    # add operation of <G> on module
    for i  in [ 1 .. n ]  do
      for j  in [ 1 .. d ]  do
        v := Mgens[i][j];
        w := [];
        for k  in [ 1 .. d ]  do
          l := v[k];
          if l <> z then
            Add( w, n+k );
            Add( w, IntFFE(l) );
          fi;
        od;
        if Length(w)>0 and w<>[n+j,1] then
          w:=ObjByExtRep(fam,w);
          SetConjugate(col,n+j,i,w);
        fi;
      od;
    od;

    if check then
      H := GroupByRws(col);
    else
      H := GroupByRwsNC(col);
    fi;

    SetModuleOfExtension( H, Subgroup(H, Pcgs(H){[n+1..n+d]} ) );
    return H;
end );

#############################################################################
##
#M  Extension( G, M, c )
##
InstallMethod( Extension, "generic method for pc groups", true,
    [ CanEasilyComputePcgs, IsObject, IsVector ], 0,
function(G,M,c)
  return FastExtSQ(G, M, c,true );
#was:
#C := CollectorSQ( G, M, false );
#return ExtensionSQ(C,G,M,c);
end);

#############################################################################
##
#M  ExtensionNC( G, M, c )
##
InstallMethod( ExtensionNC, "generic method for pc groups", true,
    [ CanEasilyComputePcgs, IsObject, IsVector ], 0,
function(G,M,c)
  return FastExtSQ(G, M, c,false );
end);

#############################################################################
##
#M  Extensions( G, M )
##
InstallMethod( Extensions,
    "generic method for pc groups",
    true,
    [ CanEasilyComputePcgs, IsObject],
    0,
function( G, M )
    local C, ext, co, cc, c, i;

    C := CollectorSQ( G, M, false );
    ext := [ ExtensionSQ( C, G, M, 0 ) ];

    # compute the two cocycles
    co := TwoCohomologySQ( C, G, M );
    if Length( co ) = 0 then return
        [SplitExtension(G,M)];
    fi;

    cc := VectorSpace( M.field, co );
    for i in [2..Size(cc)] do
        c := AsList( cc )[i];
        Add( ext, ExtensionSQ( C, G, M, c ) );
    od;
    return ext;
end );

InstallGlobalFunction(EXPermutationActionPairs,function(D)
local ag, p1iso, agp, p2iso, DP, p1, p2, gens, genimgs, triso,s,i,u,opt,
      gp2,pc1,pc2;
  if HasDirectProductInfo(D) then
    ag:=DirectProductInfo(D).groups[1];
    s:=Size(ag);
    if not HasNiceMonomorphism(ag) then
      # If this is the first time we use it,
      # copy group to avoid carrying too much cruft later.
      ag:=Group(GeneratorsOfGroup(ag),One(ag));
      SetIsGroupOfAutomorphismsFiniteGroup(ag,true);
      SetSize(ag,s);
    fi;
    IsGroupOfAutomorphismsFiniteGroup(ag);
    p1iso:=IsomorphismPermGroup(ag);
    agp:=Image(p1iso);

    # are both groups solvable?
    p2iso:=IsomorphismPermGroup(DirectProductInfo(D).groups[2]);
    gp2:=ImagesSource(p2iso);
    if IsSolvableGroup(gp2) and IsSolvableGroup(agp) then
      # both groups are solvable -- go solvable
      pc1:=IsomorphismPcGroup(agp);
      pc2:=IsomorphismPcGroup(gp2);
      DP:=DirectProduct(ImagesSource(pc1),ImagesSource(pc2));
      p1:=Projection(DP,1);
      p2:=Projection(DP,2);
      gens:=Pcgs(DP);

      genimgs:=List(gens,
          i->ImagesRepresentative(Embedding(D,1),
          PreImagesRepresentative(p1iso,
            PreImagesRepresentative(pc1,ImagesRepresentative(p1,i))))
            *ImagesRepresentative(Embedding(D,2),
                PreImagesRepresentative(p2iso,
                PreImagesRepresentative(pc2,ImagesRepresentative(p2,i)))) );

    else
      opt:=rec(limit:=s,random:=1);
      if HasBaseOfGroup(agp) then
        opt.knownBase:=BaseOfGroup(agp);
      fi;
      #p1iso:=p1iso*SmallerDegreePermutationRepresentation(agp:cheap);
      EraseNaturalHomomorphismsPool(agp);
      if s>1 then
        repeat
          u:=Group(());
          gens:=[];
          for i in GeneratorsOfGroup(agp) do
            if Size(u)<s and not i in u then
              Add(gens,i);
              u:=DoClosurePrmGp(u,[i],opt);
            fi;
          od;
          if HasBaseOfGroup(agp) then
            SetBaseOfGroup(u,BaseOfGroup(agp));
          fi;
          #Print("rep ",Size(u)," ",s,"\n");
        until Size(u)=s;
        agp:=u;
      else
        gens:=GeneratorsOfGroup(agp);
      fi;
      Info( InfoMatOrb, 1, "found ",Length(gens)," generators");

      DP:=DirectProduct(agp,gp2);
#      SetIsSolvableGroup(DP,IsSolvableGroup(agp)
#       and IsSolvableGroup(ImagesSource(p2iso)));
      p1:=Projection(DP,1);
      p2:=Projection(DP,2);
#      if IsSolvableGroup(DP) then
#       gens:=Pcgs(DP);
#      else
        gens:=GeneratorsOfGroup(DP);
#      fi;
      Unbind(ag);Unbind(agp);

      genimgs:=List(gens,
          i->ImagesRepresentative(Embedding(D,1),
                PreImagesRepresentative(p1iso,ImagesRepresentative(p1,i)))
            *ImagesRepresentative(Embedding(D,2),
                PreImagesRepresentative(p2iso,ImagesRepresentative(p2,i))) );

    fi;
    triso:=GroupHomomorphismByImagesNC(DP,D,gens,genimgs);
    SetIsBijective(triso,true);
    return rec(pairgens:=genimgs,
               permgens:=gens,
               isomorphism:=triso,
               permgroup:=DP);
  else
    return false;
  fi;
end);

InstallGlobalFunction(EXReducePermutationActionPairs,function(r)
local hom, sel, u, gens, i;
  if IsPcgs(r.permgens) then
    hom:=true; # dummy, nothing to do here
  elif IsSolvableGroup(r.permgroup) then
    hom:=IsomorphismPcGroup(r.permgroup);
    r.permgroup:=Image(hom,r.permgroup);
    r.permgens:=List(r.permgens,i->Image(hom,i));
    if IsBound(r.isomorphism) then
      r.isomorphism:=RestrictedInverseGeneralMapping(hom)*r.isomorphism;
    fi;
  else
    hom:=SmallerDegreePermutationRepresentation(r.permgroup:cheap);
    if NrMovedPoints(Image(hom))<NrMovedPoints(r.permgroup) then
      r.permgroup:=Image(hom,r.permgroup);
      r.permgens:=List(r.permgens,i->Image(hom,i));
      if IsBound(r.isomorphism) then
        r.isomorphism:=RestrictedInverseGeneralMapping(hom)*r.isomorphism;
      fi;
    fi;

    # try to reduce nr. of generators
    sel:=[];
    u:=TrivialSubgroup(r.permgroup);
    gens:=r.permgens;
    for i in Reversed([1..Length(gens)]) do
      if not gens[i] in u then
        u:=ClosureSubgroupNC(u,gens[i]);
        Add(sel,i);
      fi;
    od;
    for i in Reversed(sel) do
      if Size(r.permgroup)=Size(Difference(sel,[i])) then
        RemoveSet(sel,i);
      fi;
    od;
    if Length(sel)<Length(gens) then
      #Print("Reduce nrgens from ",Length(gens)," to ",Length(sel),"\n");
      r.permgens:=r.permgens{sel};
      r.pairgens:=r.pairgens{sel};
    fi;

  fi;

end);

############################################################################
##
#F CompatiblePairs( [A,] G, M )
#F CompatiblePairs( [A,] G, M, D )  ... D <= Aut(G) x GL
#F CompatiblePairs( [A,] G, M, D, flag ) ... D <= Aut(G) x GL normalises K
##
InstallGlobalFunction( CompatiblePairs, function( arg )
local G, M, Mgrp, oper, A, B, D, translate, gens, genimgs, triso, K, K1,
  K2, f, tmp, Ggens, pcgs, l, idx, u, tup,Dos,elmlist,preimlist,pows,
  baspt,newimgs,i,j,basicact,neu,K1nontriv,epi,hf,pool,modulehom,test,
  larg;

    # catch arguments
    A:=fail;
    larg:=ShallowCopy(arg);
    if Length(larg)>2 and IsGroupOfAutomorphismsFiniteGroup(arg[1]) and
      Source(One(arg[1]))=arg[2] then
      #automorphism group given
      A:=larg[1];
      larg:=larg{[2..Length(larg)]};
    else
      A:=fail;
    fi;
    G := larg[1];
    M := larg[2];
    Mgrp := GroupByGenerators( M.generators );
    Ggens:=Pcgs(G);
    oper:=fail;
    if IsPcgs(Ggens) and Length(Ggens)=Length(M.generators) then
      oper := GroupHomomorphismByImagesNC( G, Mgrp, Ggens, M.generators );
    elif Length(larg)=2 then
      # search through automorphism group for projection image and reps,
      # then add module automorphisms
      gens:=GeneratorsOfGroup(G);
      if A=fail then
        A:=AutomorphismGroup(G);
      fi;
      triso:=IsomorphismPermGroup(A);
      pool:=[];
      modulehom:=GroupHomomorphismByImages(G,Group(M.generators),
        gens,M.generators);
      test:=function(perm)
      local aut,imgs,mat;
        aut:=PreImagesRepresentative(triso,perm);
        imgs:=List(gens,x->ImagesRepresentative(aut,x));
        imgs:=List(imgs,x->ImagesRepresentative(modulehom,x));
        mat:=MTX.IsomorphismModules(M,GModuleByMats(imgs,M.field));
        if mat<>fail then
          Add(pool,DirectProductElement([aut,mat]));
          return true;
        fi;
        return false;
      end;
      K:=SubgroupProperty(Image(triso),test);

      # remove redundant generators
      B:=[1..Length(GeneratorsOfGroup(K))];
      for i in [1..Length(GeneratorsOfGroup(K))] do
        if Size(K)
          =Size(SubgroupNC(K,GeneratorsOfGroup(K){Difference(B,[i])})) then
          B:=Difference(B,[i]);
        fi;
      od;
      K:=Group(GeneratorsOfGroup(K){B});
      pool:=pool{B};

      B:=MTX.ModuleAutomorphisms(M);
      if Size(B)>1 then
        for i in Set(GeneratorsOfGroup(B)) do
          Add(pool,DirectProductElement([One(A),i]));
        od;
      fi;
      if Length(pool)=0 then
        A:=GroupWithGenerators([DirectProductElement([One(A),One(B)])]);
        SetSize(A,1);
      else
        A:=GroupWithGenerators(pool);
        SetSize(A,Size(K)*Size(B));
      fi;
      return A;
    fi;

    if oper=fail then
      Ggens:=GeneratorsOfGroup(G);
      oper := GroupHomomorphismByImagesNC( G, Mgrp, Ggens, M.generators );
    fi;

    # automorphism groups of G and M
    if Length( larg ) = 2 then
        Info( InfoCompPairs, 1, "    CompP: compute aut group");
        A := AutomorphismGroup( G );
        B := GL( M.dimension, Characteristic( M.field ) );
        D := DirectProduct( A, B );
    else
        D := larg[3];
        A := DirectProductInfo(D).groups[1];
    fi;

    # the trivial case
    if IsBound( M.isCentral ) and M.isCentral then
        return D;
    fi;

    # do we translate D in a permutation group?
    translate:=EXPermutationActionPairs(D);
    if translate<>false then

      D:=translate.permgroup;
      gens:=translate.permgens;
      genimgs:=translate.pairgens;
      triso:=translate.isomorphism;
      translate:=true;
    else
      gens:=GeneratorsOfGroup(D);
      genimgs:=gens;
    fi;

    Dos:=Size(D);

    # compute stabilizer of K in A
    if Length( larg ) <= 3 or not larg[4] then

      # get kernel of oper
      K := KernelOfMultiplicativeGeneralMapping( oper );
      if Size(K)>1 then

        # get its stabilizer
        if IsPcGroup(K) then
          K1:=CanonicalPcgsWrtFamilyPcgs(Centre(K));
          K1nontriv:=Length(K1)>0;
          K2:=CanonicalPcgsWrtFamilyPcgs(K);
          f := function( pt, a )
                 return CanonicalPcgsWrtFamilyPcgs(Group(List(pt,i->Image( a[1], i ))));
               end;
        else
          K1:=Centre(K);
          K1nontriv:=Size(K1)>1;
          K2:=K;
          f := function( pt, a ) return Image( a[1], pt ); end;
        fi;

        if K1nontriv and K1<>K2 then
          tmp := Stabilizer( D, K1,gens,genimgs, f );

          if Size(tmp)<Size(D) then
            Info( InfoMatOrb, 1, "    CompP: found orbit of centre of length ",
                  Size(D)/Size( tmp ));
            D := tmp;
            if translate<>false then
              if HasIsSolvableGroup(D) and IsSolvableGroup(D) then
                gens:=Pcgs(D);
              else
                gens:=GeneratorsOfGroup(D);
              fi;
              genimgs:=List(gens,i->ImageElm(triso,i));
              translate:=rec(pairgens:=genimgs,
                             permgens:=gens,
                             isomorphism:=triso,
                             permgroup:=D);
              EXReducePermutationActionPairs(translate);
              gens:=translate.permgens;
              genimgs:=translate.pairgens;
              triso:=translate.isomorphism;
              D:=translate.permgroup;
            else
              gens:=GeneratorsOfGroup(D);
              genimgs:=gens;
            fi;
          fi;
          tmp:=false; # clear memory

        fi;

        tmp := Stabilizer( D, K2,gens,genimgs, f );

        if Size(tmp)<Size(D) then
          Info( InfoMatOrb, 1, "    CompP: found orbit of length ",
                Size(D)/Size(tmp));
          D := tmp;
          if translate<>false then
            if HasIsSolvableGroup(D) and IsSolvableGroup(D) then
              gens:=Pcgs(D);
            else
              gens:=GeneratorsOfGroup(D);
            fi;
            genimgs:=List(gens,i->ImageElm(triso,i));
            translate:=rec(pairgens:=genimgs,
                            permgens:=gens,
                            isomorphism:=triso,
                            permgroup:=D);
            EXReducePermutationActionPairs(translate);
            gens:=translate.permgens;
            genimgs:=translate.pairgens;
            triso:=translate.isomorphism;
            D:=translate.permgroup;
          else
            gens:=GeneratorsOfGroup(D);
            genimgs:=gens;
          fi;
        fi;
        tmp:=false; # clear memory

      fi;
    fi;

    # compute stabilizer of M.generators in D

    basicact:=function( tup, elm )
    local gens;
      #gens := List( tup[1], x -> PreImagesRepresentative( elm[1], x ) );
      #gens := List( gens, x -> MappedPcElement( x, tup[1], tup[2] ) );
      gens := List( Ggens, x -> PreImagesRepresentative( elm[1], x ) );
      gens := List( gens, x -> MappedPcElement( x, Ggens, tup ) );
      gens := List( gens, x -> x ^ elm[2] );
      return gens;
      #return DirectProductElement( [tup[1], gens] );
    end;

    if not IsPcgs(Ggens) then
      elmlist:=fail;
      epi:=EpimorphismFromFreeGroup(G);
      Assert(1,MappingGeneratorsImages(epi)[2]=Ggens);
      f:=function( tup, elm )
          local gens;
            #gens := List( tup[1], x -> PreImagesRepresentative( elm[1], x ) );
            #gens := List( gens, x -> MappedPcElement( x, tup[1], tup[2] ) );
            gens := List( Ggens, x -> PreImagesRepresentative( elm[1], x ) );
            gens := List( gens, x -> MappedWord( PreImagesRepresentative(epi,x),
              GeneratorsOfGroup(Source(epi)), tup ) );
            gens := List( gens, x -> x ^ elm[2] );
            return gens;
            #return DirectProductElement( [tup[1], gens] );
          end;

      elif Size(G)>20000 then
        # if G is too large we cannot write out elements
        elmlist:=fail;
        f:=basicact;
      else

      elmlist:=[];

      tmp:=List(genimgs,x->x[1]);
      preimlist:=List(tmp,x->[x,List(Ggens,y->PreImagesRepresentative(x,y))]);

      f:=function( tup, elm )
      local gens,p;
        p:=PositionProperty(preimlist,x->IsIdenticalObj(x[1],elm[1]));
        if p=fail then
          gens := List( Ggens, x -> PreImagesRepresentative( elm[1], x ) );
        else
          gens:=preimlist[p][2];
        fi;
        gens:=List(gens,x->TracedPointPcElement(x,Ggens,elmlist{tup},baspt));
        gens:=List(gens,x->x^elm[2]);

        return gens;

        # tup:=ShallowCopy(tup); # get memory
        # avoid duplicate matrices
        # for i in [1..Length(gens)] do
        #   p:=PositionSorted(elmlist,gens[i]);
        #   if p<>fail and p<=Length(elmlist) and elmlist[p]=gens[i] then
        #     tup[i]:=p;
        #   else
        #     AddSet(elmlist,gens[i]);
        #     p:=PositionSorted(elmlist,gens[i]);
        #     tup[i]:=p;
        #   fi;
        # od;
        # return tup;

      end;

    fi;

    if IsPcgs(Ggens) then
      # build tails of the pcgs that are closed under automorphisms
      pcgs:=Pcgs(G);
      l:=Length(Pcgs(G))+1;
      repeat
        Unbind(tmp);
        repeat
          l:=l-1;
          idx:=[l..Length(pcgs)];
          u:=SubgroupNC(G,pcgs{idx});
        until ForAll(GeneratorsOfGroup(u),
          i->ForAll(GeneratorsOfGroup(A),j->Image(j,i) in u));

        Ggens:=InducedPcgsByPcSequence(pcgs,pcgs{idx});
        tup:=M.generators{idx};

        if elmlist<>fail then
          tmp:=List(genimgs,x->x[1]);
          preimlist:=List(tmp,x->[x,List(Ggens,y->PreImagesRepresentative(x,y))]);

          # ensure we also account for action
          u:=Group(tup);
          elmlist:=AsSSortedList(u);
          tmp:=SmallGeneratingSet(u);
          i:=1;
          while elmlist<>fail and i<=Length(tmp) do
            j:=1;
            while j<=Length(genimgs) do
              neu:=tmp[i]^genimgs[j][2];
              if elmlist<>fail and not neu in elmlist then
                u:=ClosureGroup(u,neu);
                if Size(u)>50000 then
                  # catch cases of too many elements.
                  elmlist:=fail;
                  f:=basicact;
                  j:=Length(genimgs)+1;
                else
                  elmlist:=AsSSortedList(u);
                  if Length(SmallGeneratingSet(u))<Length(tmp) then
                    tmp:=SmallGeneratingSet(u);
                    i:=0;
                    j:=Length(genimgs)+1; # force loop reset
                  else
                    tmp:=Concatenation(tmp,[neu]);
                  fi;
                fi;
              fi;
              j:=j+1;
            od;
            i:=i+1;
          od;

          if elmlist<>fail then
            baspt:=Position(elmlist,One(u));
            # describe how second part acts on matrices by conjugation
            newimgs:=List(genimgs,
              x->DirectProductElement([x[1],Permutation(x[2],elmlist,OnPoints)]));
            Assert(1,ForAll(newimgs,x->x[2]<>fail));

            tup:=List(tup,x->Position(elmlist,x));
            elmlist:=List(elmlist,x->Permutation(x,elmlist,OnRight));

            pows:=NextPrimeInt(Length(elmlist)-20); # we are likely sparse, so
            # not being perfect is not likely to do a hash conflict
            pows:=List([0..Length(tup)],x->pows^x);

            tmp:=[D, rec(hashfun:= lst->lst*pows),tup, gens,newimgs, f ];
            #  use `op' to get in the fake domain with the hashfun
            tmp := StabilizerOp( D, rec(hashfun:= lst->lst*pows),tup,
              gens,newimgs, f );
          else
            tmp := Stabilizer( D, tup,gens,genimgs, f );
          fi;
        else
          tmp := Stabilizer( D, tup,gens,genimgs, f );
        fi;

        Info( InfoMatOrb, 1, "    CompP: ",l,"-tail found orbit of length ",
              Size(D)/Size(tmp));
        if Size(tmp)<Size(D) then
          D:=tmp;
          if IsPcgs(gens) then
            gens:=InducedPcgs(gens,tmp);
          else
            gens:=SmallGeneratingSet(tmp);
          fi;
          genimgs:=List(gens,i->ImageElm(triso,i));
          if translate<>false then
            translate:=rec(pairgens:=genimgs,
                            permgens:=gens,
                            isomorphism:=triso,
                            permgroup:=D);
            EXReducePermutationActionPairs(translate);
            gens:=translate.permgens;
            genimgs:=translate.pairgens;
            triso:=translate.isomorphism;
            D:=translate.permgroup;
          fi;
        fi;
      until l=1;
    else
      #D:=Stabilizer(D,M.generators,gens,genimgs,f);
      hf:=SparseIntKeyVecListAndMatrix(false,Concatenation(M.generators));
      D:=StabilizerOp(D,rec(hashfun:=tup->hf(Concatenation(tup))),M.generators,gens,genimgs,f);
    fi;

    if translate<>false then
      l:=Size(D);
      if Length(gens)>3 then
        # reduce generator number

        u:=SmallGeneratingSet(D);
        if IsSubset(gens,u) then
          Info( InfoMatOrb, 3, "Reduce generators subset");
          idx:=List(u,x->Position(gens,x));
          gens:=gens{idx};
          genimgs:=genimgs{idx};
        else
          Info( InfoMatOrb, 3, "Reduce generators new words");
          gens:=u;
          genimgs:=List(gens,i->ImageElm(triso,i));
        fi;
      fi;
      tmp:=SubgroupNC(Range(triso),genimgs);
      SetIsGroupOfAutomorphismsFiniteGroup(tmp,true);
      SetSize(tmp,l);
      # cache the faithful permutation representation in case we need it
      # later
      tmp!.permrep:=rec(pairgens:=genimgs,
                      permgens:=gens,
                      permgroup:=D);
      D:=tmp;
    fi;
    Info( InfoMatOrb, 1, "Total index: ",Dos/Size(D));
    return D;
end );

#############################################################################
##
#F MatrixOperationOfCPGroup( cc, gens )
##
BindGlobal( "MatrixOperationOfCPGroup", function( cc, gens  )
    local mats, base, pcgs, ords, imgs, n, d, fpgens, fprels, H, pcgsH,
    l, g, imgl, k, i, j, rel, tail, m, tails, prei, h,field;


    mats := List( gens, x -> [] );
    base := Basis( Image( cc.cohom ) );
    prei := List( base, x -> PreImagesRepresentative( cc.cohom, x ) );

    pcgs := Pcgs( cc.group );
    ords := RelativeOrders( pcgs );
    imgs := List( gens, x -> List( pcgs, y -> y^Inverse( x[1] ) ) );

    n := Length( pcgs );
    d := cc.module.dimension;
    field:=cc.module.field;

    fpgens := GeneratorsOfGroup( cc.presentation.group );
    fprels := cc.presentation.relators;

    # loop over base elements and compute images under operation
    for h in [1..Length(base)] do
        H := ExtensionSQ( cc.collector, cc.group, cc.module, prei[h] );
        pcgsH := Pcgs( H );

        # loop over generators
        for l in [1..Length(gens)] do
            g := gens[l];
            imgl := List( imgs[l], x -> MappedPcElement( x, pcgs, pcgsH ) );

            if imgl <> pcgs then

                # compute tails of relators in H
                k := 0;
                tails := [];
                for i in [1..Length(pcgs)] do
                    for j in [1..i] do

                        # compute tail of relator
                        k := k + 1;
                        rel := fprels[k];
                        tail := MappedWord( rel, fpgens, imgl );

                        # conjugating element
                        if not IsBound( cc.module.isCentral ) or
                           not cc.module.isCentral then
                            if i = j then
                                m := imgl[i]^ords[i];
                            else
                                m := imgl[i]^imgl[j];
                            fi;
                            tail := tail^m;
                        fi;
                        tail := ExponentsOfPcElement(pcgsH,tail,[n+1..n+d]);
                        tail := tail * g[2];
                        # convert tail to compressed format ...
                        if IsHPCGAP then
                          if Size(field)<=256 then
                            tail := CopyToVectorRepNC(tail,Size(field));
                          fi;
                        else
                          ConvertToVectorRepNC(tail,field);
                        fi;
                        # ... and append tail to tails; we have to
                        # treat the case that tails is still empty separately,
                        # because right now, GAP does not support empty
                        # compressed vectors; hence tails is an empty plist,
                        # and Append will leave it at that.
                        if Length(tails) = 0 then
                          tails := tail;
                        else
                          Append( tails, tail );
                        fi;
                    od;
                od;
            else
              Error("not yet done");
            fi;
            tails := Image( cc.cohom, tails );
            Add( mats[l], tails );
        od;
    od;
    return List(mats,i->ImmutableMatrix(field,i));
end );

#############################################################################
##
#M ExtensionRepresentatives( G, M, C )
##
InstallMethod( ExtensionRepresentatives,
    "generic method for pc groups",
    true,
    [ CanEasilyComputePcgs, IsRecord, IsGroup ],
    0,
function( G, M, C )
    local cc, ext, mats, Mgrp, orbs, c;

    cc := TwoCohomology( G, M );

    # catch the trivial case
    if Dimension(Image(cc.cohom)) = 0 then
        return [ExtensionSQ( cc.collector, G, M, 0 )];
    elif Dimension( Image(cc.cohom)) = 1 then
        c := Basis(Image(cc.cohom))[1];
        c := PreImagesRepresentative(cc.cohom, c);
        return [ExtensionSQ( cc.collector, G, M, 0 ),
                ExtensionSQ( cc.collector, G, M, c )];
    fi;

    mats := MatrixOperationOfCPGroup( cc, GeneratorsOfGroup( C ) );

    # compute orbit of mats on H^2( G, M )
    Mgrp := GroupByGenerators( mats );
    orbs := OrbitsDomain( Mgrp, Image(cc.cohom), OnRight );
    orbs := List( orbs, x -> PreImagesRepresentative( cc.cohom, x[1] ) );
    ext  := List( orbs, x -> ExtensionSQ( cc.collector, G, M, x ) );
    return ext;
end);

#############################################################################
##
#F MyIntCoefficients( p, d, w )
##
BindGlobal( "MyIntCoefficients", function( p, d, w )
    local v, int, i;
    v   := IntVecFFE( w );
    int := 0;
    for i in [1..d] do
        int := int * p + v[i];
    od;
    return int;
end );

#############################################################################
##
#F MatOrbs( mats, dim, field )
##
BindGlobal( "MatOrbs", function( mats, dim, field )
    local p, q, r, l, seen, reps, rest, i, v, orb, j, w, im, h, mat, rep;

    # set up
    p := Characteristic( field );
    q := p^dim;
    r := p^dim - 1;
    l := List( [1..dim], x -> p );

    # set up large boolean list
    seen := [];
    seen[q] := false;
    for i in [1..q-1] do seen[i] := false; od;
    IsBlist( seen );

    reps := [];
    rest := r;
    for i in [1..r] do
        if not seen[i] then
            seen[i] := true;
            v    := CoefficientsMultiadic( l, i );
            orb  := [v];
            rest := rest - 1;
            j    := 1;
            rep  := v;
            Add( reps, rep );
            while j <= Length( orb ) do
                w := orb[j];
                for mat in mats do
                    im := w * mat;
                    h  := MyIntCoefficients( p, dim, im );
                    if not seen[h] then
                        seen[h] := true;
                        rest    := rest - 1;
                        Add( orb, im );
                    fi;
                od;
                if rest = 0 then j := Length( orb ); fi;
                j := j + 1;
            od;
            Info( InfoExtReps, 3, "found orbit of length: ", Length(orb),
                                  " remaining points: ",rest);
        fi;
    od;
    return reps * One( field );
end );

#############################################################################
##
#F NonSplitExtensions( G, M [, reduce] )
##
BindGlobal( "NonSplitExtensions", function( arg )
    local G, M, C, cc, cohom, mats, CP, all, red, c;

    # catch arguments
    G := arg[1];
    M := arg[2];

    # compute H^2(G, M)
    cc := TwoCohomology( G, M );
    C  := cc.collector;

    Info( InfoExtReps, 1, "   dim(M) = ",M.dimension,
                                " char(M) = ", Characteristic(M.field),
                                " dim(H2) = ", Dimension(Image(cc.cohom)));

    # catch the trivial cases
    if Dimension( Image( cc.cohom ) ) = 0 then
        all := [];
        red := true;

    elif Dimension( Image(cc.cohom ) ) = 1 then
        c := PreImagesRepresentative(cc.cohom, Basis(Image(cc.cohom))[1]);
        all := [ExtensionSQ( C, G, M, c)];
        red := true;

    # if reduction is suppressed
    elif IsBound( arg[3] ) and not arg[3] then
        all := NormedRowVectors( Image(cc.cohom) );
        all := List( all, x -> ExtensionSQ(cohom.collector, G, M,
                               PreImagesRepresentative(cc.cohom,x )));
        red := false;

    # sometimes we do not want to reduce
    elif not IsBound( arg[3] )
        and Size(Image(cc.cohom)) < 10
        and not (HasIsFrattiniFree( G ) and IsFrattiniFree( G ))
        and not HasAutomorphismGroup( G )
    then
        all := NormedRowVectors( Image(cc.cohom) );
        all := List( all, x -> ExtensionSQ(cc.collector, G, M,
                               PreImagesRepresentative(cc.cohom, x )));
        red := false;

    # then we want to reduce
    else

        Info( InfoExtReps, 2, "   Ext: compute compatible pairs");
        CP := CompatiblePairs( G, M );

        Info( InfoExtReps, 2, "   Ext: compute linear action");
        mats := MatrixOperationOfCPGroup( cc, GeneratorsOfGroup( CP ) );

        Info( InfoExtReps, 2, "   Ext: compute orbits ");
        all := MatOrbs( mats, Length(mats[1]) , M.field );
        red := true;
        Info( InfoExtReps, 2, "   Ext: found ",Length(all)," orbits ");

        # create extensions and add info
        all := List( all, x -> ExtensionSQ(cc.collector, G, M,
                               PreImagesRepresentative(cc.cohom, x )));
    fi;

    if red then
        Info( InfoExtReps, 1, "    found ",Length(all),
                               " extensions - reduced");
    else
        Info( InfoExtReps, 1, "    found ",Length(all)," extensions ");
    fi;

    return rec( groups := all, reduced := red );
end );

#############################################################################
##
#F  SplitExtension( G, M )
#F  SplitExtension( G, aut, N )
##
InstallMethod( SplitExtension,
    "generic method for pc groups",
    true,
    [ CanEasilyComputePcgs, IsObject ],
    0,
function( G, M )
    return Extension( G, M, 0 );
end );

InstallOtherMethod( SplitExtension,
    "generic method for pc groups",
    true,
    [ CanEasilyComputePcgs, IsObject, CanEasilyComputePcgs ],
    0,
function( G, aut, N )
    local pcgsG, fpg, n, gensG, pcgsN, fpn, d, gensN, F, gensF, relators,
          rel, new, g, e, t, l, i, j, k, H, m, relsN, relsG;

    pcgsG := Pcgs( G );
    fpg   := Range( IsomorphismFpGroupByPcgs( pcgsG, "g" ) );
    n     := Length( pcgsG );
    gensG := GeneratorsOfGroup( FreeGroupOfFpGroup( fpg ) );
    relsG := RelatorsOfFpGroup( fpg );

    pcgsN := Pcgs( N );
    fpn   := Range( IsomorphismFpGroupByPcgs( pcgsN, "n" ) );
    d     := Length( pcgsN );
    gensN := GeneratorsOfGroup( FreeGroupOfFpGroup( fpn ) );
    relsN := RelatorsOfFpGroup( fpn );

    F := FreeGroup(IsSyllableWordsFamily, n + d );
    gensF := GeneratorsOfGroup( F );
    relators := [];

    # relators of G
    for rel in relsG do
        new := MappedWord( rel, gensG, gensF{[1..n]} );
        Add( relators, new );
    od;

    # operation of G on N
    for i in [1..n] do
        for j in [1..d] do

            # left hand side
            l := Comm( gensF[n+j], gensF[i] );

            # right hand side
            g := Image( aut, pcgsG[i] );
            m := Image( g, pcgsN[j] );
            e := ExponentsOfPcElement( pcgsN, (pcgsN[j]^-1 * m)^-1 );
            t := One( F );
            for k in [1..d] do
                t := t * gensF[n+k]^e[k];
            od;

            # add new relator
            Add( relators, l * t );
        od;
    od;

    # relators of N
    for rel in relsN do
        new := MappedWord( rel, gensN, gensF{[n+1..n+d]} );
        Add( relators, new );
    od;

    H := PcGroupFpGroup( F / relators );
    SetModuleOfExtension( H, Subgroup(H, Pcgs(H){[n+1..n+d]} ) );
    return H;
end);
