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
#M IrreducibleModules( <G>, <F>, <dim> ). . . .constituents of regular module
##
InstallMethod(IrreducibleModules,"generic method for groups and finite field",
    true, [ IsGroup, IsField and IsFinite, IsInt ], 0,
function( G, F, dim )
local modu, modus,gens,v,subs,sub,ser,i,j,a,si,dims,cf,mats,clos,bas,rad;

  if dim=1 then
    # linear representations come from G/G'
    gens:=GeneratorsOfGroup(G);
    a:=DerivedSubgroup(G);
    if Size(a)=Size(G) then
      return [gens,[TrivialModule(Length(gens),F)]];
    else
      a:=MaximalAbelianQuotient(G);
      si:=List(gens,x->ImagesRepresentative(a,x));
      sub:=IrreducibleModules(Group(si),F,1);
      if sub[1]=si then
        return [gens,sub[2]];
      else
        modu:=[];
        for i in sub[2] do
          v:=GroupHomomorphismByImages(Image(a),Group(i.generators),sub[1],i.generators);
          Add(modu,GModuleByMats(List(si,x->ImagesRepresentative(v,x)),F));
        od;
        return [gens,modu];
      fi;
    fi;

  fi;

  modu := RegularModule( G, F );
  gens:=modu[1];
  modu:=modu[2];

  # The augmentation ideal of a P-normal subgroup lies in the radical
  if Characteristic(F)=0 then
    si:=TrivialSubgroup(G);
  else
    si:=PCore(G,Characteristic(F));
  fi;

  mats:=modu.generators;
  bas:=One(modu.generators[1]);
  rad:=0;

  if Size(si)>1 then

    # get augmentation ideal of subgroup, at least approximate from
    # generators
    a:=Enumerator(G);
    cf:=Set(GeneratorsOfGroup(si),x->Position(a,x));

    for i in cf do
      v:=ShallowCopy(Zero(modu.generators[1][1]));
      Assert(0, Position(a,One(si)) = 1);
      v[1]:=One(F);v[i]:=-One(F);
      v:=SolutionMat(bas,v){[rad+1..Length(bas)]};
      if not IsZero(v) then
        sub:=MTX.SpinnedBasis(v,mats,modu.field);

        # extend to full basis
        clos:=BaseSteinitzVectors(One(mats[1]),sub).factorspace;
        j:=ImmutableMatrix(modu.field,Concatenation(sub,clos))^-1;
        # cut out factor bit
        mats:=List(mats,x->x^j);
        j:=[Length(sub)+1..Length(mats[1])];
        mats:=List(mats,x->ImmutableMatrix(modu.field,x{j}{j}));

        # translate in old basis
        j:=bas{[rad+1..Length(bas)]};
        sub:=List(sub,x->x*j);
        clos:=List(clos,x->x*j);

        bas:=Concatenation(bas{[1..rad]},sub,clos);
        rad:=rad+Length(sub);

      fi;
    od;
  fi;

  a:=Length(mats[1]);
  Info(InfoMeatAxe,1,"Work in factor dimension ",a);
  subs:=[];
  # It is quite likely that a vector [1,-1] spans a submodule
  # want that n(n+1)>2> dim/1000
  j:=QuoInt(a,1000);
  for i in [1..First([1..a],n->n*(n+1)/2>j)] do
    v:=ShallowCopy(Zero(modu.generators[1][1]));
    v[1]:=One(F);v[Random([2..a])]:=-One(F);
    v:=SolutionMat(bas,v){[rad+1..Length(bas)]};
    if not IsZero(v) then
      sub:=MTX.SpinnedBasis(v,mats,modu.field);
      sub:=ImmutableMatrix(modu.field,TriangulizedMat(sub));
      if not sub in subs then
        Add(subs,sub);
      fi;
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
local n,mats,mo,moduln,i,j,k,t,cnt,p,ext,emo;
  if dim=1 then TryNextMethod();fi; # special abelian case

  p:=Characteristic(field);
  # Is there a pcore? If so take the quotient
  k:=PCore(G,p);
  if Size(k)>1 then
    n:=NaturalHomomorphismByNormalSubgroup(G,k);
    t:=List(GeneratorsOfGroup(G),x->ImagesRepresentative(n,x));
    i:=IrreducibleModules(Group(t),field,dim);
    if i[1]=t then return [GeneratorsOfGroup(G),i[2]];fi;
  fi;


  # how many should we expect
  t:=List(ConjugacyClasses(G),Representative);
  t:=Filtered(t,x->Order(x) mod p<>0);
  cnt:=Length(t);
  Info(InfoMeatAxe,1,"Expect ",cnt," absolute irreps");

  n:=LargestMovedPoint(G);
  if n<=1 then
    # trivial group
    return [GeneratorsOfGroup(G),
            [GModuleByMats(List(GeneratorsOfGroup(G),x->IdentityMat(1,field)),
              field)]];
  fi;
  mats:=List(GeneratorsOfGroup(G),x->PermutationMat(x,n,field));
  n:=Length(mats);
  mo:=GModuleByMats(mats,field);
  moduln:=List(MTX.CollectedFactors(mo),x->x[1]);
  for k in moduln do
    if MTX.IsAbsolutelyIrreducible(k) then
      cnt:=cnt-1;
    else
      ext:=GF(p^(LogInt(Size(field),p)*MTX.DegreeSplittingField(k)));
      emo:=GModuleByMats(k.generators,ext);
      emo:=MTX.CollectedFactors(emo);
      cnt:=cnt-Length(emo);
    fi;
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
        MTX.IsIrreducible(k);
        if ForAll(moduln,x->MTX.Isomorphism(k,x)=fail) then
          Add(moduln,k);
          if MTX.IsAbsolutelyIrreducible(k) then
            cnt:=cnt-1;
          else
            ext:=GF(p^(LogInt(Size(field),p)*MTX.DegreeSplittingField(k)));
            emo:=GModuleByMats(k.generators,ext);
            emo:=MTX.CollectedFactors(emo);
            cnt:=cnt-Length(emo);
          fi;
        fi;
        Info(InfoMeatAxe,1,"left are ",cnt," irreps");
      od;
      j:=j+1;
    od;
    i:=i+1;
  od;
  SortBy(moduln,x->x.dimension);
  if dim>0 then moduln:=Filtered(moduln,x->MTX.Dimension(x)<=dim);fi;
  return [GeneratorsOfGroup(G),moduln];
end);

InstallOtherMethod(IrreducibleModules,"Supply no dimension limit",
    true, [ IsGroup, IsField and IsFinite ], 0,
function(G,F)
  return IrreducibleModules(G,F,0);
end);

#############################################################################
##
#M AbsolutelyIrreducibleModules( <G>, <F>, <dim> ). . . .constituents of regular module
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
