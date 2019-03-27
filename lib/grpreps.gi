#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This files's authors include Bettina Eick and Alexander Hulpke.
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
    mats := List( gens, x -> false );
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
    a:=AsList(G);
    cf:=Set(List(GeneratorsOfGroup(si),x->Position(a,x)));

    for i in cf do
      v:=ShallowCopy(Zero(modu.generators[1][1]));
      v[Position(a,One(si))]:=One(F);v[i]:=-One(F);
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
local n,mats,mo,moduln,i,j,k,t;
  if dim=1 then TryNextMethod();fi; # special abelian case
  n:=LargestMovedPoint(G);
  mats:=List(GeneratorsOfGroup(G),x->PermutationMat(x,n,field));
  n:=Length(mats);
  mo:=GModuleByMats(mats,field);
  moduln:=List(MTX.CollectedFactors(mo),x->x[1]);
  i:=1;
  while i<=Length(moduln) do
    j:=1;
    while j<=i do
      t:=GModuleByMats(List([1..n],x->KroneckerProduct(moduln[i].generators[x],
        moduln[j].generators[x])),field);
      t:=List(MTX.CollectedFactors(t),x->x[1]);
      Info(InfoMeatAxe,i," ",j," ",List(t,x->x.dimension));
      for k in t do
        MTX.IsIrreducible(k);
        if ForAll(moduln,x->MTX.Isomorphism(k,x)=fail) then 
          Add(moduln,k);
        fi;
      od;
      j:=j+1;
    od;
    i:=i+1;
  od;
  SortBy(moduln,x->x.dimension);
  if dim>0 then moduln:=Filtered(moduln,x->MTX.Dimension(x)<=dim);fi;
  return [GeneratorsOfGroup(G),moduln];
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


