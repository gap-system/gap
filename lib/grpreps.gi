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

# Helper function for the 'IrreducibleModules' method below:
# (Thus we assume that 'G' is a permutation group.)
# The number of irreducible representations of the group 'G' over the finite
# field 'F' is equal to the number of 'p'-regular 'F'-conjugacy classes
# of 'G', where 'p' is the characteristic of 'F'.
# Two 'p'-regular elements 'g', 'h' of 'G' lie in the same 'F'-conjugacy class
# of 'G' if and only if 'g' is 'G'-conjugate to 'h^q' where 'q' is some power
# of 'Size( F )'.
# In other words, the 'F'-conjugacy classes are unions of orbits under the
# action of the Frobenius automorphism with fixed field 'F'.
BindGlobal( "NumberOfFConjugacyClasses", function( G, F )
  local p, q, reps, invs, C, g, n, res, start, i, e, cand, l, done, j, img, k;

  p:= Characteristic( F );
  q:= Size( F );
  reps:= [];
  invs:= [];
  for C in ConjugacyClasses( G ) do
    g:= Representative( C );
    if Order( g ) mod p <> 0 then
      Add( reps, g );
      Add( invs, [ CycleStructurePerm( g ), Size( C ) ] );
    fi;
  od;
  SortParallel( invs, reps );
  n:= Length( reps );
  res:= 0;
  start:= 1;
  while start <= n do
    i:= start + 1;
    while i <= n and invs[i] = invs[ start ] do
      i:= i+1;
    od;
    if i = start + 1 then
      # fixed point
      res:= res + 1;
    else
      # distribute to orbits
      e:= q mod Order( reps[ start ] );
      cand:= reps{ [ start .. i-1 ] };
      l:= Length( cand );
      done:= ListWithIdenticalEntries( l, false );
      for j in [ 1 .. l ] do
        if not done[j] then
          # compute the orbit of 'cand[j]'
          res:= res + 1;
          img:= cand[j]^e;
          while not IsConjugate( G, img, cand[j] ) do
            for k in [ j+1 .. l ] do
              if not done[k] and IsConjugate( G, img, cand[k] ) then
                done[k]:= true;
                img:= cand[k]^e;
                break;
              fi;
            od;
          od;
        fi;
      od;
    fi;
    start:= i;
  od;

  return res;
end );

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

  # Count those irreducible representations we have not yet found.
  cnt:= NumberOfFConjugacyClasses( G, field );
  Info(InfoMeatAxe,1,"Expect ",cnt," irreps");

  mats:=List(GeneratorsOfGroup(G),x->PermutationMat(x,n,field));
  n:=Length(mats);
  mo:=GModuleByMats(mats,field);
  moduln:=List(MTX.CollectedFactors(mo),x->x[1]);
  for k in moduln do
    cnt:= cnt - 1;
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
          cnt:= cnt - 1;
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
