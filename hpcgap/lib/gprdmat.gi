#############################################################################
##
#W  gprdmat.gi                 GAP library                   Alexander Hulpke
##
##
#Y  Copyright (C) 2016 The GAP Group
##

# to ensure this specific method can be called
DeclareGlobalFunction("MatDirectProduct");

InstallGlobalFunction(MatDirectProduct,function(arg)
local l,f,dim,gens,off,g,d,m,a,range,rans,G,compgens,cg;
  l:=arg;
  if Length(l)=1 and IsList(l[1]) and ForAll(l[1],IsGroup) then
    l:=l[1];
  fi;

  # Check the arguments.
  if not ForAll(l,IsGroup) then
    TryNextMethod();
  fi;

  f:=DefaultFieldOfMatrixGroup(l[1]);
  for a in [2..Length(l)] do
    d:=DefaultFieldOfMatrixGroup(l[a]);
    if not IsSubset(f,d) then
      if IsSubset(d,f) then
	f:=d;
      elif PrimeField(d)<>PrimeField(f) then
	TryNextMethod();
      else
	f:=DefaultField(Concatenation(GeneratorsOfField(d),GeneratorsOfField(f)));
      fi;
    fi;
  od;

  dim:=Sum(l,DimensionOfMatrixGroup);
  gens:=[];
  compgens:=[];
  rans:=[];
  off:=0;
  # loop over the groups
  for g in l do
    cg:=[];
    Add(compgens,cg);
    d:=DimensionOfMatrixGroup(g);
    range:=[off+1..off+d];
    for m in GeneratorsOfGroup(g) do
      a:=IdentityMat(dim,f);
      a{range}{range}:=m;
      a:=ImmutableMatrix(f,a);
      Add(gens,a);
      Add(cg,a);
    od;
    Add(rans,range);
    off:=off+d;
  od;
  G:= Group(gens);
  SetDirectProductInfo(G,rec(groups:=ShallowCopy(l),
    dimension:=dim,field:=f,
    compgens:=compgens,
    rans:=rans,
    embeddings:=[],
    projections:=[]));

  return G;
end);

InstallMethod(DirectProductOp,"matrix groups",IsCollsElms,
  [IsList,IsMatrixGroup],0,
function(grps,G)
  return MatDirectProduct(grps);
end);

#############################################################################
##
#M  Size(<D>) . . . . . . . . . . . . . . . . . . . . . . of direct product
##
InstallMethod(Size,"for a matrix group that knows to be a direct product",
    true,[ IsMatrixGroup and HasDirectProductInfo ],0,
    D -> Product(List(DirectProductInfo(D).groups,Size)));

#############################################################################
##
#R  IsEmbeddingDirectProductMatrixGroup(<hom>)  .  embedding of direct factor
##
DeclareRepresentation("IsEmbeddingDirectProductMatrixGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsInjective and
      IsSPGeneralMapping,[ "component" ]);

#############################################################################
##
#M  Embedding(<D>,<i>) . . . . . . . . . . . . . . . . . .  make embedding
##
InstallMethod(Embedding,"matrix direct product",true,
      [ IsMatrixGroup and HasDirectProductInfo,IsPosInt ],0,
function(D,i)
local   emb,info;
  info := DirectProductInfo(D);
  if IsBound(info.embeddings[i]) then return info.embeddings[i]; fi;
  
  emb := Objectify(NewType(GeneralMappingsFamily(FamilyObj(One(D)),
						 FamilyObj(One(D))),
		  IsEmbeddingDirectProductMatrixGroup),
		  rec(component := i,info:=info,range:=info.rans[i]));
  SetRange(emb,D);
  SetSource(emb,info.groups[i]);

  info.embeddings[i] := emb;
  
  return emb;
end);

#############################################################################
##
#M  PrintObj(<emb>) . . . . . . . . . . . . . . . . . . . . print embedding
##
InstallMethod(PrintObj,"for embedding into direct product",true,
    [ IsEmbeddingDirectProductMatrixGroup ],0,
    function(emb)
    Print("Embedding(",Range(emb),",",emb!.component,")");
end);

#############################################################################
##
#M  ImagesRepresentative(<emb>,<g>)  . . . . . . . . . . . .  of embedding
##
InstallMethod(ImagesRepresentative,"matrix direct product embedding",
  FamSourceEqFamElm,[ IsEmbeddingDirectProductMatrixGroup,
		       IsMultiplicativeElementWithInverse ],0,
function(emb,m)
local info,a;
  info:=emb!.info;
  a:=IdentityMat(info.dimension,info.field);
  a{emb!.range}{emb!.range}:=m;
  return ImmutableMatrix(info.field,a);
end);

#############################################################################
##
#M  PreImagesRepresentative(<emb>,<g>) . . . . . . . . . . .  of embedding
##
InstallMethod(PreImagesRepresentative,"matrix direct product embedding",
  FamRangeEqFamElm,
        [ IsEmbeddingDirectProductMatrixGroup,
          IsMultiplicativeElementWithInverse ],
function(emb,g)
local info,a,b;
  info := emb!.info;
  b:=g{emb!.range}{emb!.range};
  a:=IdentityMat(info.dimension,info.field);
  a{emb!.range}{emb!.range}:=b;
  if g=a then
    return b;
  else
    return fail;
  fi;
end);

#############################################################################
##
#R  IsProjectionDirectProductMatrixGroup(<hom>) projection onto direct factor
##
DeclareRepresentation("IsProjectionDirectProductMatrixGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsSurjective and
      IsSPGeneralMapping,[ "component" ]);

#############################################################################
##
#M  Projection(<D>,<i>)  . . . . . . . . . . . . . . . . . make projection
##
InstallMethod(Projection,"matrix direct product",true,
      [ IsMatrixGroup and HasDirectProductInfo,IsPosInt ],0,
function(D,i)
local   prj,info;
  info := DirectProductInfo(D);
  if IsBound(info.projections[i]) then return info.projections[i]; fi;

  prj := Objectify(NewType(GeneralMappingsFamily(FamilyObj(One(D)),
						FamilyObj(One(D))),
		  IsProjectionDirectProductMatrixGroup),
		  rec(component := i,info:=info,range:=info.rans[i]));
  SetSource(prj,D);
  SetRange(prj,info.groups[i]);
  info.projections[i] := prj;
  return prj;
end);

#############################################################################
##
#M  ImagesRepresentative(<prj>,<g>)  . . . . . . . . . . . . of projection
##
InstallMethod(ImagesRepresentative,"matrix direct product projection",
  FamSourceEqFamElm,
        [ IsProjectionDirectProductMatrixGroup,
          IsMultiplicativeElementWithInverse ],0,
function(prj,g)
  return g{prj!.range}{prj!.range};
end);

#############################################################################
##
#M  PreImagesRepresentative(<prj>,<g>) . . . . . . . . . . . of projection
##
InstallMethod(PreImagesRepresentative,"matrix direct product projection",
  FamRangeEqFamElm,
        [ IsProjectionDirectProductMatrixGroup,
          IsMultiplicativeElementWithInverse ],0,
function(prj,m)
local info,a;
  info:=prj!.info;
  a:=IdentityMat(info.dimension,info.field);
  a{prj!.range}{prj!.range}:=m;
  return ImmutableMatrix(info.field,a);
end);

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping(<prj>) . . . . . . . of projection
##
InstallMethod(KernelOfMultiplicativeGeneralMapping,
  "matrix direct product projection",
    true,[ IsProjectionDirectProductMatrixGroup ],0,
    function(prj)
    local   D, gens, i, K,info;
    
    D := Source(prj);
    gens :=Concatenation(prj!.info.compgens{
	      Difference([1..Length(prj!.info.compgens)],[prj!.component])});
    K := SubgroupNC(D,gens);
    SetIsNormalInParent(K,true);
    return K;
end);

#############################################################################
##
#M  PrintObj(<prj>) . . . . . . . . . . . . . . . . . . .  print projection
##
InstallMethod(PrintObj,"for projection from a direct product",
    true,
    [ IsProjectionDirectProductMatrixGroup ],0,
function(prj)
    Print("Projection(",Source(prj),",",prj!.component,")");
end);

# to ensure this specific method can be called
DeclareGlobalFunction("MatWreathProduct");

InstallGlobalFunction(MatWreathProduct,function(A,B)
local f,n,m,Agens,Bgens,emb,i,j,a,g,dim,rans,range;
  f:=DefaultFieldOfMatrixGroup(A);
  n:=DimensionOfMatrixGroup(A);
  m:=LargestMovedPoint(B);
  dim:=n*m;
  emb:=[];
  rans:=[];
  for j in [1..m] do
    Agens:=[];
    range:=[(j-1)*n+1..j*n];
    Add(rans,range);
    for i in GeneratorsOfGroup(A) do
      a:=IdentityMat(n*m,f);
      a{range}{range}:=i;
      Add(Agens,a);
    od;
    emb[j]:=Agens;
  od;
  Agens:=emb[1];

  Bgens:=List(GeneratorsOfGroup(B),
	  x->KroneckerProduct(PermutationMat(x,m,f),One(A)));
  g:=Group(Concatenation(Agens,Bgens));
  if HasSize(A) then
    SetSize(g,Size(A)^m*Size(B));
  fi;
  SetWreathProductInfo(g,rec(groups:=[A,B],
    dimA:=n,
    degI:=m,
    dimension:=dim,field:=f,
    compgens:=emb,
    rans:=rans,
    embeddings:=[]));
  return g;
end);


InstallMethod( WreathProduct,"imprimitive matrix group",
  true, [ IsMatrixGroup, IsPermGroup ], 0, MatWreathProduct);

#############################################################################
##
#M  Size(<D>) . . . . . . . . . . . . . . . . . . . . . . of direct product
##
InstallMethod(Size,"for a matrix group that knows to be a wreath product",
    true,[ IsMatrixGroup and HasWreathProductInfo ],0,
function(W)
local info;
  info:=WreathProductInfo(W);
  return Size(info.groups[1])^info.degI*Size(info.groups[2]);
end);

#############################################################################
##
#R  IsEmbeddingImprimitiveWreathProductMatrixGroup( <hom> )
##
##  special for case of imprimitive wreath product
DeclareRepresentation( "IsEmbeddingImprimitiveWreathProductMatrixGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsInjective and
      IsSPGeneralMapping, [ "component" ] );

#############################################################################
##
#M  Embedding( <W>, <i> ) . . . . . . . . . . . . . . . . . .  make embedding
##
InstallMethod( Embedding,"matrix wreath product", true,
  [ IsMatrixGroup and HasWreathProductInfo, IsPosInt ], 0,
function( W, i )
local   emb, info;
    info := WreathProductInfo( W );
    if IsBound( info.embeddings[i] ) then return info.embeddings[i]; fi;
    
    if i<=info.degI then
      emb := Objectify( NewType(
		GeneralMappingsFamily(FamilyObj(One(W)),FamilyObj(One(W))),
		IsEmbeddingImprimitiveWreathProductMatrixGroup),
	     rec( component := i,range:=info.rans[i],info:=info ) );
      SetSource(emb,info.groups[1]);
    elif i=info.degI+1 then
      emb:=GroupHomomorphismByFunction(info.groups[2],W,
	    x->KroneckerProduct(PermutationMat(x,info.degI,info.field),
	         One(info.groups[1]))  );
      SetIsInjective(emb,true);
    else
      Error("no embedding <i> defined");
    fi;
    SetRange( emb, W );

    info.embeddings[i] := emb;
    
    return emb;
end );


#############################################################################
##
#M  ImagesRepresentative( <emb>, <g> )  . . . . . . . . . . . .  of embedding
##
InstallMethod( ImagesRepresentative,
  "imprim matrix wreath product embedding",FamSourceEqFamElm,
        [ IsEmbeddingImprimitiveWreathProductMatrixGroup,
          IsMultiplicativeElementWithInverse ], 0,
function( emb, m )
local info,a;
  info:=emb!.info;
  a:=IdentityMat(info.dimension,info.field);
  a{emb!.range}{emb!.range}:=m;
  return ImmutableMatrix(info.field,a);
end);
  
#############################################################################
##
#M  PreImagesRepresentative( <emb>, <g> ) . . . . . . . . . . .  of embedding
##
InstallMethod( PreImagesRepresentative,
  "imprim matrix wreath product embedding", FamRangeEqFamElm,
        [ IsEmbeddingImprimitiveWreathProductMatrixGroup,
          IsMultiplicativeElementWithInverse ], 0,
function( emb, g )
local info,a,b;
  info := emb!.info;
  b:=g{emb!.range}{emb!.range};
  a:=IdentityMat(info.dimension,info.field);
  a{emb!.range}{emb!.range}:=b;
  if g=a then
    return b;
  else
    return fail;
  fi;
end);


#############################################################################
##
#M  PrintObj( <emb> ) . . . . . . . . . . . . . . . . . . . . print embedding
##
InstallMethod( PrintObj,
    "for embedding into wreath product",
    true,
    [ IsEmbeddingImprimitiveWreathProductMatrixGroup], 0,
    function( emb )
    Print( "Embedding( ", Range( emb ), ", ", emb!.component, " )" );
end );


#############################################################################
##
#M  Projection( <W> ) . . . . . . . . . . . . . . projection of wreath on top
##
InstallOtherMethod( Projection,"matrix wreath product", true,
  [ IsMatrixGroup and HasWreathProductInfo ],0,
function( W )
local  info,proj,H;
  info := WreathProductInfo( W );
  if IsBound( info.projection ) then return info.projection; fi;

  proj:=Error("TODO");

  info.projection:=proj;
  return proj;
end);

