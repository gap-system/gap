#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick and Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#M RegularModule( <G>, <F> ) . . . . . . . . . . .right regular F-module of G
##
InstallGlobalFunction( RegularModuleByGens, function( G, gens, F )
    local mats, elms, d, zero, i, mat, j, o;
    mats := [];
    elms := AsList( G );
    d    := Length(elms);
    zero := NullMat( d, d, F );
    for i in [1..Length( gens )] do
        mat := List( zero, ShallowCopy );
        for j in [1..d] do
            o := Position( elms, elms[j]*gens[i] );
            mat[j][o] := One( F );
        od;
        mats[i] := mat;
    od;
    return GModuleByMats( mats, F );
end );

InstallMethod( RegularModule,
    "generic method for groups",
    true,
    [ IsGroup, IsField ],
    0,
function( G, F )
    return [GeneratorsOfGroup(G),
            RegularModuleByGens( G, GeneratorsOfGroup( G ), F )];
end);

#############################################################################
##
#M IrreducibleModules( <G>, <F>, <dim> ) . . . constituents of regular module
##
InstallMethod(IrreducibleModules,"generic method for groups and finite field",
    true, [ IsGroup, IsField and IsFinite, IsInt ], 0,
function( G, F, dim )
local modu, modus,gens,v,subs,sub,ser,i,j,a,si,dims,cf,mats,hom;

  if dim=1 then
    # linear representations come from G/G'
    gens:=GeneratorsOfGroup(G);
    a:=DerivedSubgroup(G);
    if Size(a)=Size(G) then
      return [gens,[TrivialModule(Length(gens),F)]];
    elif IsAbelian(G) then
      if IsPrimeField(F) then
        if CanEasilyComputePcgs(G) then
          # call `IrreducibleModules` again;
          # we assume that now another method is applicable
          return IrreducibleModules(G, F, 1);
        else
          # delegate to a pc group,
          # for which another method is available
          a:= IsomorphismPcGroup(G);
        fi;
      else
        a:= IsomorphismPermGroup(G);
      fi;
    else
      # delegate to a proper factor group
      a:= MaximalAbelianQuotient(G);
    fi;
    si:=List(gens,x->ImagesRepresentative(a,x));
    sub:= Group(si);
    SetIsAbelian(sub, true);
    sub:= IrreducibleModules(sub,F,0);
    if sub[1]=si then
      return [gens, Filtered( sub[2], x -> x.dimension = 1 )];
    else
      modu:=[];
      for i in sub[2] do
        if i.dimension = 1 then
          v:=GroupHomomorphismByImages(Image(a),Group(i.generators),sub[1],i.generators);
          Add(modu,GModuleByMats(List(si,x->ImagesRepresentative(v,x)),F));
        fi;
      od;
      return [gens,modu];
    fi;

  fi;

  gens:=GeneratorsOfGroup(G);

  # O_p(G) acts trivially on every irreducible module in characteristic p,
  # so all of them are constituents of the regular module of G/O_p(G)
  si:=PCore(G,Characteristic(F));
  if Size(si)=Size(G) then
    return [gens,[TrivialModule(Length(gens),F)]];
  elif Size(si)>1 then
    hom:=NaturalHomomorphismByNormalSubgroup(G,si);
    modu:=RegularModuleByGens(Image(hom),
            List(gens,x->ImagesRepresentative(hom,x)),F);
  else
    modu:=RegularModule(G,F);
    gens:=modu[1];
    modu:=modu[2];
  fi;

  mats:=modu.generators;
  a:=Length(mats[1]);
  Info(InfoMeatAxe,1,"Work in factor dimension ",a);
  subs:=[];
  # It is quite likely that a vector [1,-1] spans a submodule
  # want that n(n+1)>2> dim/1000
  j:=QuoInt(a,1000);
  for i in [1..First([1..a],n->n*(n+1)/2>j)] do
    v:=ShallowCopy(Zero(modu.generators[1][1]));
    v[1]:=One(F);v[Random([2..a])]:=-One(F);
    sub:=MTX.SpinnedBasis(v,mats,modu.field);
    sub:=ImmutableMatrix(modu.field,TriangulizedMat(sub));
    if not sub in subs then
      Add(subs,sub);
    fi;
  od;

  Info(InfoMeatAxe,1,"submodules:",List(subs,Length));

  if Length(subs)>0 then
    # close under sums/intersections to form series
    ser:=[[],subs[1],One(mats[1])];
    for i in [2..Length(subs)] do
      a:=subs[i];
      j:=2;
      while j<Length(ser) and a<>fail do
        si:=List(SumIntersectionMat(ser[j],a),
          x->ImmutableMatrix(modu.field,TriangulizedMat(x)));
        if Length(si[2])>Length(ser[j-1]) and Length(si[2])<Length(ser[j]) then
          ser:=Concatenation(ser{[1..j-1]},[si[2]],ser{[j..Length(ser)]});
          j:=j+1;
        fi;
        if si[1]=ser[j] or si[1]=ser[j+1] then
          a:=fail; # in this or next step, no further refinement
        else
          a:=si[1];
        fi;
        j:=j+1;
      od;
    od;

    dims:=List(ser,Length);
    Info(InfoMeatAxe,1,"series:",dims);

    # find a basis reflecting the series
    si:=[];
    for i in [2..Length(ser)] do
      Add(si,BaseSteinitzVectors(ser[i],ser[i-1]).factorspace);
    od;

    # base change
    si:=ImmutableMatrix(modu.field,Concatenation(si))^-1;
    mats:=List(mats,x->x^si);
    modus:=[];
    for i in [2..Length(dims)] do
      si:=[dims[i-1]+1..dims[i]];
      modu:=GModuleByMats(List(mats,x->x{si}{si}),modu.field);
      cf:=List(MTX.CollectedFactors(modu),x->x[1]);
      if dim>0 then cf:=Filtered(cf,x->MTX.Dimension(x)<=dim);fi;
      for j in cf do
        if ForAll(modus,
          x->x.dimension<>j.dimension or MTX.Isomorphism(x,j)=fail) then
            Add(modus,j);
        fi;
      od;
    od;

  else
    modus:=List(MTX.CollectedFactors(modu),x->x[1]);
  fi;
  SortBy(modus,x->x.dimension);
  if dim>0 then modus:=Filtered(modus,x->MTX.Dimension(x)<=dim);fi;

  return [gens,modus];
end);


InstallMethod(IrreducibleModules,
  "permutation group, finite field, Burnside-Brauer",
    true, [ IsPermGroup, IsField and IsFinite, IsInt ], 2,
function(G,field,dim)
local n,mats,mo,moduln,i,j,k,t,cnt,p,hom,words;
  if dim=1 then TryNextMethod();fi; # special abelian case

  p:=Characteristic(field);
  # Is there a pcore? If so take the quotient
  k:=PCore(G,p);
  if Size(k)>1 then
    n:=NaturalHomomorphismByNormalSubgroup(G,k);
    t:=List(GeneratorsOfGroup(G),x->ImagesRepresentative(n,x));
    i:=IrreducibleModules(Group(t),field,dim);
    if i[1]=t then return [GeneratorsOfGroup(G),i[2]];fi;

    # the modules are given w.r.t. other generators of the factor;
    # write t as words in these once, for all modules
    hom:=EpimorphismFromFreeGroup(Group(i[1]));
    words:=List(t,x->PreImagesRepresentative(hom,x));
    moduln:=[];
    for j in i[2] do
      Add(moduln,GModuleByMats(List(words,x->MappedWord(x,
        GeneratorsOfGroup(Source(hom)),j.generators)),field));
    od;
    SortBy(moduln,x->x.dimension);
    return [GeneratorsOfGroup(G),moduln];
  fi;

  n:=LargestMovedPoint(G);
  if n = 0 then
    # trivial group
    return [ GeneratorsOfGroup( G ), [ TrivialGModule( G, field ) ] ];
  fi;

  # Count those absolutely irreducible representations
  # that are not constituents of the 'F'-irreducibles we have already found.
  cnt:= Number( ConjugacyClasses( G ),
                C -> Order( Representative( C ) ) mod p <> 0 );
  Info(InfoMeatAxe,1,"Expect ",cnt," absolute irreps");

  mats:=List(GeneratorsOfGroup(G),x->PermutationMat(x,n,field));
  n:=Length(mats);
  mo:=GModuleByMats(mats,field);
  moduln:=List(MTX.CollectedFactors(mo),x->x[1]);
  for k in moduln do
    # The number of pairwise nonequivalent absolutely irreducible
    # constituents of 'k'
    # is equal to the degree of the field extension 'E > F' where 'F' is
    # the field over which 'k' is defined,
    # and 'E' is the smallest field that contains 'F' and over which 'k'
    # splits into absolutely irreducibles.
    # (This degree is what 'MTX.DegreeFieldExt' returns.)
    # Note that the character \chi of each absolutely irreducible constituent
    # 'M' of 'k' satisfies 'F(\chi) = E' because \chi has values in 'E' and
    # its values cannot be contained in a smaller field that contains 'F'.
    # By \cite[(9.23)]{Isa76}, 'dim(k) = [F(\chi):F] dim(M)',
    # and by \cite[(9.21)]{Isa76}, all absolutely irreducible constituents
    # of 'k' are pairwise nonequivalent.
    cnt:= cnt - MTX.DegreeFieldExt(k);
  od;
  i:=1;
  while i<=Length(moduln) and cnt>0 do
    j:=1;
    while j<=i and cnt>0 do
      t:=GModuleByMats(List([1..n],x->KroneckerProduct(moduln[i].generators[x],
        moduln[j].generators[x])),field);
      if i=j and t.dimension>100 then
        # try to split in the obvious way
        k:=ShallowCopy(Zero(t.generators[1][1]));
        # the vector [1,0,...,0,-1] lies in antisymmetric tensors
        k[1]:=One(t.field); k[Length(k)]:=-One(t.field);
        k:=MTX.SpinnedBasis(k,t.generators,t.field);
        if Length(k)<t.dimension then
          MTX.SetSubbasis(t,k);
          MTX.SetIsIrreducible(t,false);
        else
          Info(InfoWarning,1,
            "Given vector not in submodule. See https://xkcd.com/2200/");
        fi;
      fi;
      t:=List(MTX.CollectedFactors(t),x->x[1]);
      Info(InfoMeatAxe,1,i," ",j," yields  ",List(t,x->x.dimension));
      for k in t do
        if ForAll(moduln,x-> not MTX.IsEquivalent(k,x)) then
          Add(moduln,k);
          # see the comment above
          cnt:= cnt - MTX.DegreeFieldExt(k);
          if cnt = 0 then
            break;
          fi;
        fi;
        Info(InfoMeatAxe,1,"left are ",cnt," irreps");
      od;
      j:=j+1;
    od;
    i:=i+1;
  od;
  if dim>0 then moduln:=Filtered(moduln,x->MTX.Dimension(x)<=dim);fi;
  SortBy(moduln,MTX.Dimension);
  return [GeneratorsOfGroup(G),moduln];
end);

InstallOtherMethod(IrreducibleModules,"Supply no dimension limit",
    true, [ IsGroup, IsField and IsFinite ], 0,
function(G,F)
  return IrreducibleModules(G,F,0);
end);

#############################################################################
##
#M AbsolutelyIrreducibleModules( <G>, <F>, <dim> ) . . . . .  constituents of
##                                                             regular module
##
InstallMethod( AbsolutelyIrreducibleModules,
    "generic method for groups and finite field",
    true,
    [ IsGroup, IsField and IsFinite, IsInt ],
    0,
function( G, F, dim )
    local modu, modus,gens;
    modu := RegularModule( G, F );
    gens:=modu[1];
    modu:=modu[2];
    modus := List( MTX.CollectedFactors( modu ), x -> x[1] );
    if dim > 0 then
        modus := Filtered( modus, x -> MTX.Dimension(x) <= dim and MTX.IsAbsolutelyIrreducible (x));
    fi;
    return [gens,modus];
end);
