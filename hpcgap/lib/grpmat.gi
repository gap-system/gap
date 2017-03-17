#############################################################################
##
#W  grpmat.gi                   GAP Library                      Frank Celler
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the methods for matrix groups.
##


#############################################################################
##
#M  KnowsHowToDecompose( <mat-grp> )
##
InstallMethod( KnowsHowToDecompose, "matrix groups",
        [ IsMatrixGroup, IsList ], ReturnFalse );


#############################################################################
##
#M  DefaultFieldOfMatrixGroup( <mat-grp> )
##
InstallMethod(DefaultFieldOfMatrixGroup,"for a matrix group",[IsMatrixGroup],
function( grp )
local gens,R;
  gens:= GeneratorsOfGroup( grp );
  if IsEmpty( gens ) then
    return Field( One( grp )[1][1] );
  else
    R:=DefaultScalarDomainOfMatrixList(gens);
    if not IsField(R) then
      R:=FieldOfMatrixList(gens);
    fi;
  fi;
  return R;
end );

InstallMethod( DefaultFieldOfMatrixGroup,
    "for matrix group over the cyclotomics",
    [ IsCyclotomicMatrixGroup ],
    grp -> Cyclotomics );

InstallMethod( DefaultFieldOfMatrixGroup,
    "for a matrix group over an s.c. algebra",
    [ IsMatrixGroup and IsSCAlgebraObjCollCollColl ],
    grp -> ElementsFamily( ElementsFamily( ElementsFamily(
               FamilyObj( grp ) ) ) )!.fullSCAlgebra );

# InstallOtherMethod( DefaultFieldOfMatrixGroup,
#         "from source of nice monomorphism",
#         [ IsMatrixGroup and HasNiceMonomorphism ],
#     grp -> DefaultFieldOfMatrixGroup( Source( NiceMonomorphism( grp ) ) ) );
#T this was illegal,
#T since it assumes that the source is a different object than the
#T original group; if this fails then we run into an infinite recursion!


#############################################################################
##
#M  FieldOfMatrixGroup( <mat-grp> )
##
InstallMethod( FieldOfMatrixGroup,
  "for a matrix group",
    [ IsMatrixGroup ],
    function( grp )
    local gens;

    gens:= GeneratorsOfGroup( grp );
    if IsEmpty( gens ) then
      return Field( One( grp )[1][1] );
    else
      return FieldOfMatrixList(gens);
    fi;
end );


#############################################################################
##
#M  DimensionOfMatrixGroup( <mat-grp> )
##
InstallMethod( DimensionOfMatrixGroup, "from generators",
    [ IsMatrixGroup and HasGeneratorsOfGroup ],
    function( grp )
    if not IsEmpty( GeneratorsOfGroup( grp ) )  then
        return Length( GeneratorsOfGroup( grp )[ 1 ] );
    else
        TryNextMethod();
    fi;
end );

InstallMethod( DimensionOfMatrixGroup, "from one",
    [ IsMatrixGroup and HasOne ], 1,
    grp -> Length( One( grp ) ) );

# InstallOtherMethod( DimensionOfMatrixGroup,
#         "from source of nice monomorphism",
#         [ IsMatrixGroup and HasNiceMonomorphism ],
#     grp -> DimensionOfMatrixGroup( Source( NiceMonomorphism( grp ) ) ) );
#T this was illegal,
#T since it assumes that the source is a different object than the
#T original group; if this fails then we run into an infinite recursion!

#T why not delegate to `Representative' instead of installing
#T different methods?

#############################################################################
##
#M  One( <mat-grp> )
##
InstallOtherMethod( One,
    "for matrix group, call `IdentityMat'",
    [ IsMatrixGroup ],
    grp -> ImmutableMatrix(DefaultFieldOfMatrixGroup(grp),
             IdentityMat( DimensionOfMatrixGroup( grp ),
	     DefaultFieldOfMatrixGroup( grp ) ) ));

#############################################################################
##
#M  TransposedMatrixGroup( <G> ) . . . . . . . . .transpose of a matrix group
##
InstallMethod( TransposedMatrixGroup,
    [ IsMatrixGroup ],
function( G )
    local T;
    T := GroupByGenerators( List( GeneratorsOfGroup( G ), TransposedMat ),
                            One( G ) );
#T avoid calling `One'!
    UseIsomorphismRelation( G, T );
    SetTransposedMatrixGroup( T, G );
    return T;
end );


#############################################################################
##
#F  NaturalActedSpace( [<G>,]<acts>,<veclist> )
##
InstallGlobalFunction(NaturalActedSpace,function(arg)
local f,i,j,veclist,acts;
  veclist:=arg[Length(arg)];
  acts:=arg[Length(arg)-1];
  if Length(arg)=3 and IsGroup(arg[1]) and acts=GeneratorsOfGroup(arg[1]) then
    f:=DefaultFieldOfMatrixGroup(arg[1]);
  else
    f:=FieldOfMatrixList(acts);
  fi;
  for i in veclist do
    for j in i do
      if not j in f then
        f:=ClosureField(f,j);
      fi;
    od;
  od;
  return f^Length(veclist[1]);
end);

InstallGlobalFunction(BasisVectorsForMatrixAction,function(G)
local F, gens, evals, espaces, is, ise, gen, i, j,module,list,ind,vecs,mins;

  F := DefaultFieldOfMatrixGroup(G);
  # `Cyclotomics', the default field for rational matrix groups causes
  # problems with a subsequent factorization
  if IsIdenticalObj(F,Cyclotomics) then
    # cyclotomics really is too large here
    F:=FieldOfMatrixGroup(G);
  fi;

  list:=[];
  if false and ValueOption("nosubmodules")=fail and IsFinite(F) then
    module:=GModuleByMats(GeneratorsOfGroup(G),F);
    if not MTX.IsIrreducible(module) then
      mins:=Filtered(MTX.BasesCompositionSeries(module),x->Length(x)>0);
      if Length(mins)<=5 then
	mins:=MTX.BasesMinimalSubmodules(module);
      else
	if Length(mins)>7 then
	  mins:=mins{Set(List([1..7],x->Random([1..Length(mins)])))};
	fi;
      fi;

      # now get potential basis vectors from submodules
      for i in mins do
	ind:=MTX.InducedActionSubmodule(module,i);
	vecs:=BasisVectorsForMatrixAction(Group(ind.generators):nosubmodules);
	Append(list,vecs*i);
      od;

    fi;
  fi;

  # use Murray/OBrien method

  gens := ShallowCopy( GeneratorsOfGroup( G ) ); # Need copy for mutability
  while Length( gens ) < 10 do
      Add( gens, PseudoRandom( G ) );
  od;

  evals := [];  espaces := [];
  for gen in gens do
      evals := Concatenation( evals, GeneralisedEigenvalues(F,gen) );
      espaces := Concatenation( espaces, GeneralisedEigenspaces(F,gen) );
  od;

  is:=[];
  # the `AddSet' wil automatically put small spaces first
  for i in [1..Length(espaces)] do
    for j in [i+1..Length(espaces)] do
      ise:=Intersection(espaces[i],espaces[j]);
      if Dimension(ise)>0 and not ise in is then
	Add(is,ise);
      fi;
    od;
  od;
  Append(list,Concatenation(List(is,i->BasisVectors(Basis(i)))));
  return list;
end);

#############################################################################
##
#F  DoSparseLinearActionOnFaithfulSubset( <G>,<act>,<sort> )
##
##  computes a linear action of the matrix group <G> on the span of the
##  standard basis. The action <act> must be `OnRight', or
##  `OnLines'. The calculation of further orbits stops, once a basis for the
##  underlying space has been reached, often giving a smaller degree
##  permutation representation.
##  The boolean <sort> indicates, whether the domain will be sorted.
BindGlobal("DoSparseLinearActionOnFaithfulSubset",
function(G,act,sort)
local field, dict, acts, start, j, zerov, zero, dim, base, partbas, heads, 
      orb, delay, permimg, maxlim, starti, ll, ltwa, img, v, en, p, kill,
      i, lo, imgs, xset, hom, R;

  field:=DefaultFieldOfMatrixGroup(G);
  #dict := NewDictionary( One(G)[1], true , field ^ Length( One( G ) ) );
  acts:=GeneratorsOfGroup(G);

  if Length(acts)=0 then
    start:=One(G);
  elif act=OnRight then
    start:=Concatenation(BasisVectorsForMatrixAction(G),One(G));
  elif act=OnLines then
    j:=One(G);
    start:=Concatenation(List(BasisVectorsForMatrixAction(G),
	    x->OnLines(x,j)),j);
  else
    Error("illegal action");
  fi;

  zerov:=Zero(start[1]);
  zero:=zerov[1];
  dim:=Length(zerov);

  base:=[]; # elements of start which are a base in the permgrp sense
  partbas:=[]; # la basis of space spanned so far
  heads:=[];
  orb:=[];
  delay:=[]; # Vectors we delay later, because they are potentially very
             # expensive.
  permimg:=List(acts,i->[]);
  maxlim:=200000;

  starti:=1;
  while Length(partbas)<dim or 
    (act=OnLines and not OnLines(Sum(base),One(G)) in orb) do
    Info(InfoGroup,2,"dim=",Length(partbas)," ",
         "|orb|=",Length(orb));
    if Length(partbas)=dim and act=OnLines then
      Info(InfoGroup,2,"add sum for projective action");
      img:=OnLines(Sum(base),One(G));
    else
      if starti>Length(start) then
	Sort(delay);
	for i in delay do
	  Add(start,i[2]);
	od;
	maxlim:=maxlim*100;
	Info(InfoGroup,2,
	    "original pool exhausted, use delayed.  maxlim=",maxlim);
	delay:=[];
      fi;

      ll:=Length(orb);
      ltwa:=Maximum(maxlim,(ll+1)*20);
      img:=start[starti];
      v:=ShallowCopy(img);
      for j in [ 1 .. Length( heads ) ] do
	en:=v[heads[j]];
	if en <> zero then
	  AddRowVector( v, partbas[j], - en );
	fi;
      od;
    fi;

    if not IsZero(v) then
      dict := NewDictionary( v, true , field ^ Length( One( G ) ) );
      # force `img' over field
      if (Size(field)=2 and not IsGF2VectorRep(img)) or
	 (Size(field)>2 and Size(field)<=256 and not (Is8BitVectorRep(img)
	 and Q_VEC8BIT(img)=Size(field))) then
	img:=ShallowCopy(img);
	ConvertToVectorRep(img,Size(field));
      fi;
      Add(orb,img);
      p:=Length(orb);
      AddDictionary(dict,img,Length(orb));
      kill:=false;

      # orbit algorithm with image keeper
      while p<=Length(orb) do
	i:=1;
	while i<=Length(acts) do
	  img := act(orb[p],acts[i]);
	  v:=LookupDictionary(dict,img);
	  if v=fail then
	    if Length(orb)>ltwa then
	      Info(InfoGroup,2,"Very long orbit, delay");
	      Add(delay,[Length(orb)-ll,orb[ll+1]]);
	      kill:=true;
	      for p in [ll+1..Length(orb)] do
	        Unbind(orb[p]);
		for i in [1..Length(acts)] do
		  Unbind(permimg[i][p]);
		od;
	      od;
	      i:=Length(acts)+1;
	      p:=Length(orb)+1;
	    else
	      Add(orb,img);
	      AddDictionary(dict,img,Length(orb));
	      permimg[i][p]:=Length(orb);
	    fi;
	  else
	    permimg[i][p]:=v;
	  fi;
	  i:=i+1;
	od;
	p:=p+1;
      od;
    fi;
    starti:=starti+1;

    if not kill then
      # break criterion: do we actually *want* more points?
      i:=ll+1;
      lo:=Length(orb);
      while i<=lo do
	v:=ShallowCopy(orb[i]);
	for j in [ 1 .. Length( heads ) ] do
	  en:=v[heads[j]];
	  if en <> zero then
	    AddRowVector( v, partbas[j], - en );
	  fi;
	od;
	if v<>zerov then
	  Add(base,orb[i]);
	  Add(partbas,ShallowCopy(orb[i]));
	  TriangulizeMat(partbas);
	  heads:=List(partbas,PositionNonZero);
	  if Length(partbas)>=dim then
	    # full dimension reached
	    i:=lo;
	  fi;
	fi;
	i:=i+1;
      od;
    fi;

  od;

  # Das Dictionary hat seine Schuldigkeit getan
  Unbind(dict);
  Info(InfoGroup,1,"found degree=",Length(orb));

  # any asymptotic argument is pointless here: In practice sorting is much
  # quicker than image computation.
  if sort then
    imgs:=Sortex(orb); # permutation we must apply to the points to be sorted.
    # was: permimg:=List(permimg,i->OnTuples(Permuted(i,imgs),imgs));
    # run in loop to save memory
    for i in [1..Length(permimg)] do
      permimg[i]:=Permuted(permimg[i],imgs);
      permimg[i]:=OnTuples(permimg[i],imgs);
    od;
  fi;

#check routine
#  Print("check!\n");
#  for p in [1..Length(orb)] do
#    for i in [1..Length(acts)] do
#      img:=act(orb[p],acts[i]);
#      v:=LookupDictionary(dict,img);
#      if v<>permimg[i][p] then
#        Error("wrong!");
#      fi;
#    od;
#  od;
#  Error("hier");

  for i in [1..Length(permimg)] do
    permimg[i]:=PermList(permimg[i]);
  od;

  if fail in permimg then
    Error("not permutations");
  fi;
  xset:=ExternalSet( G, orb, acts, acts, act);

  # when acting projectively the sum of the base vectors must be part of the
  # base -- that will guarantee that we can distinguish diagonal from scalar
  # matrices.
  if act=OnLines then
    if Length(base)<=dim then
      Add(base,OnLines(Sum(base),One(G)));
    fi;
  fi;

  # We know that the points corresponding to `start' give a base of the
  # vector space. We can use
  # this to get images quickly, using a stabilizer chain in the permutation
  # group
  SetBaseOfGroup( xset, base );
  xset!.basePermImage:=List(base,b->PositionCanonical(orb,b));

  hom := ActionHomomorphism( xset,"surjective" );
  if act <> OnLines then
    SetIsInjective(hom, true); # we know by construction that it is injective.
  fi;
  
  R:=Group(permimg,()); # `permimg' arose from `PermList'
  SetBaseOfGroup(R,xset!.basePermImage);

  if HasSize(G) and act=OnRight then
    SetSize(R,Size(G)); # faithful action
  fi;

  SetRange(hom,R);
  SetImagesSource(hom,R);
  SetMappingGeneratorsImages(hom,[acts,permimg]);
#  p:=RUN_IN_GGMBI; # no niceomorphism translation here
#  RUN_IN_GGMBI:=true;
#  SetAsGroupGeneralMappingByImages ( hom, GroupHomomorphismByImagesNC
#            ( G, R, acts, permimg ) );
#
#  SetFilterObj( hom, IsActionHomomorphismByBase );
#  RUN_IN_GGMBI:=p;
  base:=ImmutableMatrix(field,base);
  SetLinearActionBasis(hom,base);

  return hom;
end);

#############################################################################
##
#M  IsomorphismPermGroup( <mat-grp> )
##

BindGlobal( "NicomorphismOfGeneralMatrixGroup", function( grp,canon,sort )
local   nice,img,module,b;
  b:=SeedFaithfulAction(grp);
  if canon=false and b<>fail then
    Info(InfoGroup,1,"using predefined action seed");
    # the user (or code) gave a seed for a faithful action
    nice:=MultiActionsHomomorphism(grp,b.points,b.ops);
  # don't be too clever if it is a matrix over a non-field domain
  elif not IsField(DefaultFieldOfMatrixGroup(grp)) then
    Info(InfoGroup,1,"over nonfield");
    #nice:=ActionHomomorphism( grp,AsSSortedList(grp),OnRight,"surjective");
    if canon then
      nice:=SortedSparseActionHomomorphism( grp, One( grp ) );
      SetIsCanonicalNiceMonomorphism(nice,true);
    else
      nice:=SparseActionHomomorphism( grp, One( grp ) );
      nice:=nice*SmallerDegreePermutationRepresentation(Image(nice));
    fi;
  elif IsFinite(grp) and ( (HasIsNaturalGL(grp) and IsNaturalGL(grp)) or
             (HasIsNaturalSL(grp) and IsNaturalSL(grp)) ) then
    # for full GL/SL we get never better than the full vector space as domain
    Info(InfoGroup,1,"is GL/SL");
    return NicomorphismFFMatGroupOnFullSpace(grp);
  elif canon then
    Info(InfoGroup,1,"canonical niceo");
    nice:=SortedSparseActionHomomorphism( grp, One( grp ) );
    SetIsCanonicalNiceMonomorphism(nice,true);
  else
    Info(InfoGroup,1,"act to find base");
    nice:=DoSparseLinearActionOnFaithfulSubset( grp, OnRight, sort);
    SetIsSurjective( nice, true );

    img:=Image(nice);
    if not IsFinite(DefaultFieldOfMatrixGroup(grp)) or
    Length(GeneratorsOfGroup(grp))=0 then
      module:=fail;
    else
      module:=GModuleByMats(GeneratorsOfGroup(grp),DefaultFieldOfMatrixGroup(grp));
    fi;
    #improve,
    # try hard, unless absirr and orbit lengths at least 1/q^2 of domain --
    #then we expect improvements to be of little help
    if module<>fail and not (NrMovedPoints(img)>=
      Size(DefaultFieldOfMatrixGroup(grp))^(Length(One(grp))-2)
      and MTX.IsAbsolutelyIrreducible(module)) then
	nice:=nice*SmallerDegreePermutationRepresentation(img);
    else
      nice:=nice*SmallerDegreePermutationRepresentation(img:cheap:=true);
    fi;
  fi;
  SetIsInjective( nice, true );

  return nice;
end );

InstallMethod( IsomorphismPermGroup,"matrix group", true,
  [ IsMatrixGroup ], 10,
function(G)
local map;
  if HasNiceMonomorphism(G) and IsPermGroup(Range(NiceMonomorphism(G))) then
    map:=NiceMonomorphism(G);
    if IsIdenticalObj(Source(map),G) then
      return map;
    fi;
    return GeneralRestrictedMapping(map,G,Image(map,G));
  else
    if not HasIsFinite(G) then
      Info(InfoWarning,1,
           "IsomorphismPermGroup: The group is not known to be finite");
    fi;
    map:=NicomorphismOfGeneralMatrixGroup(G,false,false);
    SetNiceMonomorphism(G,map);
    return map;
  fi;
end);

#############################################################################
##
#M  NiceMonomorphism( <mat-grp> )
##
InstallMethod( NiceMonomorphism,"use NicomorphismOfGeneralMatrixGroup",
  [ IsMatrixGroup and IsFinite ],
  G->NicomorphismOfGeneralMatrixGroup(G,false,false));

#############################################################################
##
#M  CanonicalNiceMonomorphism( <mat-grp> )
##
InstallMethod( CanonicalNiceMonomorphism, [ IsMatrixGroup and IsFinite ],
  G->NicomorphismOfGeneralMatrixGroup(G,true,true));

#############################################################################
##
#F  ProjectiveActionHomomorphismMatrixGroup(<G>)
##
InstallGlobalFunction(ProjectiveActionHomomorphismMatrixGroup,
  G->DoSparseLinearActionOnFaithfulSubset(G,OnLines,true));

#############################################################################
##
#M  GeneratorsSmallest(<finite matrix group>)
##
##  This algorithm takes <bas>:=the points corresponding to the standard basis
##  and then computes a minimal generating system for the permutation group
##  wrt. this base <bas>. As lexicographical comparison of matrices is
##  compatible with comparison of base images wrt. the standard base this
##  also is the smallest (irredundant) generating set of the matrix group!
InstallMethod(GeneratorsSmallest,"matrix group via niceo",
  [IsMatrixGroup and IsFinite],
function(G)
local gens,s,dom,mon,no;
  mon:=CanonicalNiceMonomorphism(G);
  no:=Image(mon,G);
  dom:=UnderlyingExternalSet(mon);
  s:=StabChainOp(no,rec(base:=List(BaseOfGroup(dom),
				      i->Position(HomeEnumerator(dom),i))));
  # call the recursive function to do the work
  gens:= SCMinSmaGens( no, s, [], One( no ), true ).gens;
  SetMinimalStabChain(G,s);
  return List(gens,i->PreImagesRepresentative(mon,i));
end);

#############################################################################
##
#M  MinimalStabChain(<finite matrix group>)
##
##  used for cosets where we probably won't need the smallest generators
InstallOtherMethod(MinimalStabChain,"matrix group via niceo",
  [IsMatrixGroup and IsFinite],
function(G)
local s,dom,mon,no;
  mon:=CanonicalNiceMonomorphism(G);
  no:=Image(mon,G);
  dom:=UnderlyingExternalSet(mon);
  s:=StabChainOp(no,rec(base:=List(BaseOfGroup(dom),
				      i->Position(HomeEnumerator(dom),i))));
  # call the recursive function to do the work
  SCMinSmaGens( no, s, [], One( no ), false );
  return s;
end);

#############################################################################
##
#M  LargestElementGroup(<finite matrix group>)
##
InstallOtherMethod(LargestElementGroup,"matrix group via niceo",
  [IsMatrixGroup and IsFinite],
function(G)
local s,dom,mon, img;
  mon:=CanonicalNiceMonomorphism(G);
  dom:=UnderlyingExternalSet(mon);
  img:= Image( mon, G );
  s:=StabChainOp( img, rec(base:=List(BaseOfGroup(dom),
				      i->Position(HomeEnumerator(dom),i))));
  # call the recursive function to do the work
  s:= LargestElementStabChain( s, One( img ) );
  return PreImagesRepresentative(mon,s);
end);

#############################################################################
##
#M  CanonicalRightCosetElement(<finite matrix group>,<rep>)
##
InstallMethod(CanonicalRightCosetElement,"finite matric group",IsCollsElms,
  [IsMatrixGroup and IsFinite,IsMatrix],
function(U,e)
local mon,dom,S,o,oimgs,p,i,g;
  mon:=CanonicalNiceMonomorphism(U);
  dom:=UnderlyingExternalSet(mon);
  S:=StabChainOp(Image(mon,U),rec(base:=List(BaseOfGroup(dom),
				      i->Position(HomeEnumerator(dom),i))));
  dom:=HomeEnumerator(dom);

  while not IsEmpty(S.generators) do
    o:=dom{S.orbit}; # the relevant vectors
    oimgs:=List(o,i->i*e); #their images

    # find the smallest image
    p:=1;
    for i in [2..Length(oimgs)] do
      if oimgs[i]<oimgs[p] then
        p:=i;
      fi;
    od;

    # the point corresponding to the preimage
    p:=S.orbit[p];

    # now find an element that maps S.orbit[1] to p;
    g:=S.identity;
    while S.orbit[1]^g<>p do
      g:=LeftQuotient(S.transversal[p/g],g);
    od;

    # change by corresponding matrix element
    e:=PreImagesRepresentative(mon,g)*e;

    S:=S.stabilizer;
  od;

  return e;
end);

#############################################################################
##
#M  ViewObj( <matgrp> )
##
InstallMethod( ViewObj,
    "for a matrix group with stored generators",
    [ IsMatrixGroup and HasGeneratorsOfGroup ],
function(G)
local gens;
  gens:=GeneratorsOfGroup(G);
  if Length(gens)>0 and Length(gens)*
                        Length(gens[1])^2 / GAPInfo.ViewLength > 8 then
    Print("<matrix group");
    if HasSize(G) then
      Print(" of size ",Size(G));
    fi;
    Print(" with ",Length(GeneratorsOfGroup(G)),
          " generators>");
  else
    Print("Group(");
    ViewObj(GeneratorsOfGroup(G));
    Print(")");
  fi;
end);

#############################################################################
##
#M  ViewObj( <matgrp> )
##
InstallMethod( ViewObj,"for a matrix group",
    [ IsMatrixGroup ],
function(G)
local d;
  d:=DimensionOfMatrixGroup(G);
  Print("<group of ",d,"x",d," matrices");
  if HasSize(G) then
    Print(" of size ",Size(G));
  fi;
  if HasFieldOfMatrixGroup(G) then
    Print(" over ",FieldOfMatrixGroup(G),">");
  elif HasDefaultFieldOfMatrixGroup(G) then
    Print(" over ",DefaultFieldOfMatrixGroup(G),">");
  else
    Print(" in characteristic ",Characteristic(One(G)),">");
  fi;
end);

#############################################################################
##
#M  PrintObj( <matgrp> )
##
InstallMethod( PrintObj,"for a matrix group",
    [ IsMatrixGroup ],
function(G)
local l;
  l:=GeneratorsOfGroup(G);
  if Length(l)=0 then
    Print("Group([],",One(G),")");
  else
    Print("Group(",l,")");
  fi;
end);

#############################################################################
##
#M  IsGeneralLinearGroup(<G>)
##
InstallMethod(IsGeneralLinearGroup,"try natural",[IsMatrixGroup],
function(G)
  if HasIsNaturalGL(G) and IsNaturalGL(G) then
    return true;
  else
    TryNextMethod();
  fi;
end);

#############################################################################
##
#M  IsSubgroupSL
##
InstallMethod(IsSubgroupSL,"determinant test for generators",
  [IsMatrixGroup and HasGeneratorsOfGroup],
    G -> ForAll(GeneratorsOfGroup(G),i->IsOne(DeterminantMat(i))) );

#############################################################################
##
#M  <mat> in <G>  . . . . . . . . . . . . . . . . . . . .  is form invariant?
##
InstallMethod( \in, "respecting bilinear form", IsElmsColls,
    [ IsMatrix, IsFullSubgroupGLorSLRespectingBilinearForm ],
    NICE_FLAGS,  # this method is better than the one using a nice monom.
function( mat, G )
    local inv;
    if not IsSubset( FieldOfMatrixGroup( G ), FieldOfMatrixList( [ mat ] ) )
       or ( IsSubgroupSL( G ) and not IsOne( DeterminantMat( mat ) ) ) then
      return false;
    fi;
    inv:= InvariantBilinearForm(G).matrix;
    return mat * inv * TransposedMat( mat ) = inv;
end );

InstallMethod( \in, "respecting sesquilinear form", IsElmsColls,
    [ IsMatrix, IsFullSubgroupGLorSLRespectingSesquilinearForm ],
    NICE_FLAGS,  # this method is better than the one using a nice monom.
function( mat, G )
    local pow, inv;
    if not IsSubset( FieldOfMatrixGroup( G ), FieldOfMatrixList( [ mat ] ) )
       or ( IsSubgroupSL( G ) and not IsOne( DeterminantMat( mat ) ) ) then
      return false;
    fi;
    pow:= RootInt( Size( FieldOfMatrixGroup( G ) ) );
    inv:= InvariantSesquilinearForm(G).matrix;
    return mat * inv * List( TransposedMat( mat ),
                             row -> List( row, x -> x^pow ) )
           = inv;
end );


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <matlist> )
##
##  Check that all entries are matrices of the same dimension, and that they
##  are all invertible.
##
InstallMethod( IsGeneratorsOfMagmaWithInverses,
    "for a list of matrices",
    [ IsRingElementCollCollColl ],
    function( matlist )
    local dims;
    if ForAll( matlist, IsMatrix ) then
      dims:= DimensionsMat( matlist[1] );
      return dims[1] = dims[2] and
             ForAll( matlist, mat -> DimensionsMat( mat ) = dims ) and
             ForAll( matlist, mat -> Inverse( mat ) <> fail );
    fi;
    return false;
    end );


#############################################################################
##
#M  GroupWithGenerators( <mats> )
#M  GroupWithGenerators( <mats>, <id> )
##
InstallMethod( GroupWithGenerators,
    "list of matrices",
    [ IsFFECollCollColl ],
#T ???
    function( gens )
    local G,fam,typ,f;

    fam:=FamilyObj(gens);
    if IsFinite(gens) then
      if not IsBound(fam!.defaultFinitelyGeneratedGroupType) then
	fam!.defaultFinitelyGeneratedGroupType:=
	  NewType(fam,IsGroup and IsAttributeStoringRep
		      and HasGeneratorsOfMagmaWithInverses
		      and IsFinitelyGeneratedGroup);
      fi;
      typ:=fam!.defaultFinitelyGeneratedGroupType;
    else
      TryNextMethod();
    fi;
    f:=DefaultScalarDomainOfMatrixList(gens);
    gens:=List(Immutable(gens),i->ImmutableMatrix(f,i));

    G:=rec();
    ObjectifyWithAttributes(G,typ,GeneratorsOfMagmaWithInverses,AsList(gens));

    if IsField(f) then SetDefaultFieldOfMatrixGroup(G,f);fi;

    return G;
    end );

InstallMethod( GroupWithGenerators,
  "list of matrices with identity", IsCollsElms,
  [ IsFFECollCollColl,IsMultiplicativeElementWithInverse and IsFFECollColl],
function( gens, id )
local G,fam,typ,f;

    fam:=FamilyObj(gens);
    if IsFinite(gens) then
      if not IsBound(fam!.defaultFinitelyGeneratedGroupWithOneType) then
	fam!.defaultFinitelyGeneratedGroupWithOneType:=
	  NewType(fam,IsGroup and IsAttributeStoringRep
		      and HasGeneratorsOfMagmaWithInverses
		      and IsFinitelyGeneratedGroup and HasOne);
      fi;
      typ:=fam!.defaultFinitelyGeneratedGroupWithOneType;
    else
      TryNextMethod();
    fi;
    f:=DefaultScalarDomainOfMatrixList(gens);
    gens:=List(Immutable(gens),i->ImmutableMatrix(f,i));
    id:=ImmutableMatrix(f,id);

    G:=rec();
    ObjectifyWithAttributes(G,typ,GeneratorsOfMagmaWithInverses,AsList(gens),
                            One,id);

    if IsField(f) then SetDefaultFieldOfMatrixGroup(G,f);fi;

    return G;
end );


#############################################################################
##
#M  IsConjugatorIsomorphism( <hom> )
##
InstallMethod( IsConjugatorIsomorphism,
    "for a matrix group general mapping",
    [ IsGroupGeneralMapping ], 1,
    # There is no filter to test whether source and range of a homomorphism
    # are matrix groups.
    # So we have to test explicitly and make this method
    # higher ranking than the default one in `ghom.gi'.
    function( hom )

    local s, r, dim, Fs, Fr, F, genss, rep;

    s:= Source( hom );
    if not IsMatrixGroup( s ) then
      TryNextMethod();
    elif not ( IsGroupHomomorphism( hom ) and IsBijective( hom ) ) then
      return false;
    elif IsEndoGeneralMapping( hom ) and IsInnerAutomorphism( hom ) then
      return true;
    fi;
    r:= Range( hom );

    # Check whether dimensions and fields of matrix entries are compatible.
    dim:= DimensionOfMatrixGroup( s );
    if dim <> DimensionOfMatrixGroup( r ) then
      return false;
    fi;
    Fs:= DefaultFieldOfMatrixGroup( s );
    Fr:= DefaultFieldOfMatrixGroup( r );
    if FamilyObj( Fs ) <> FamilyObj( Fr ) then
      return false;
    fi;
    if not ( IsField( Fs ) and IsField( Fr ) ) then
      TryNextMethod();
    fi;
    F:= ClosureField( Fs, Fr );
    if not IsFinite( F ) then
      TryNextMethod();
    fi;

    # Compute a conjugator in the full linear group.
    genss:= GeneratorsOfGroup( s );
    rep:= RepresentativeAction( GL( dim, Size( F ) ), genss, List( genss,
                    i -> ImagesRepresentative( hom, i ) ), OnTuples );

    # Return the result.
    if rep <> fail then
      Assert( 1, ForAll( genss, i -> Image( hom, i ) = i^rep ) );
      SetConjugatorOfConjugatorIsomorphism( hom, rep );
      return true;
    else
      return false;
    fi;
    end );


#############################################################################
##
#F  AffineActionByMatrixGroup( <M> )
##
InstallGlobalFunction( AffineActionByMatrixGroup, function(M)
local   gens,V,  G, A;

  # build the vector space
  V := DefaultFieldOfMatrixGroup( M ) ^ DimensionOfMatrixGroup( M );

  # the linear part
  G := Action( M, V );

  # the translation part
  gens:=List( Basis( V ), b -> Permutation( b, V, \+ ) );

  # construct the affine group
  A := GroupByGenerators(Concatenation(gens,GeneratorsOfGroup( G )));
  SetSize( A, Size( M ) * Size( V ) );

  if HasName( M )  then
      SetName( A, Concatenation( String( Size( DefaultFieldOfMatrixGroup( M ) ) ),
	      "^", String( DimensionOfMatrixGroup( M ) ), ":",
	      Name( M ) ) );
  fi;
  # the !.matrixGroup component is not documented!
  A!.matrixGroup := M;
#T what the hell shall this misuse be good for?
  return A;

end );


#############################################################################
##
##  n. Code needed for ``blow up isomorphisms'' of matrix groups
##


#############################################################################
##
#F  IsBlowUpIsomorphism
##
##  We define this filter for additive as well as for multiplicative
##  general mappings,
##  so the ``respectings'' of the mappings must be set explicitly.
##
DeclareFilter( "IsBlowUpIsomorphism", IsSPGeneralMapping and IsBijective );


#############################################################################
##
#M  ImagesRepresentative( <iso>, <mat> ) . . . . .  for a blow up isomorphism
##
InstallMethod( ImagesRepresentative,
    "for a blow up isomorphism, and a matrix in the source",
    FamSourceEqFamElm,
    [ IsBlowUpIsomorphism, IsMatrix ],
    function( iso, mat )
    return BlownUpMat( Basis( iso ), mat );
    end );


#############################################################################
##
#M  PreImagesRepresentative( <iso>, <mat> )  . . .  for a blow up isomorphism
##
InstallMethod( PreImagesRepresentative,
    "for a blow up isomorphism, and a matrix in the range",
    FamRangeEqFamElm,
    [ IsBlowUpIsomorphism, IsMatrix ],
    function( iso, mat )

    local B,
          d,
          n,
          Binv,
          preim,
          i,
          row,
          j,
          submat,
          elm,
          k;

    B:= Basis( iso );
    d:= Length( B );
    n:= Length( mat ) / d;

    if not IsInt( n ) then
      return fail;
    fi;

    Binv:= List( B, Inverse );
    preim:= [];

    for i in [ 1 .. n ] do
      row:= [];
      for j in [ 1 .. n ] do

        # Compute the entry in the `i'-th row in the `j'-th column.
        submat:= mat{ [ 1 .. d ] + (i-1)*d }{ [ 1 .. d ] + (j-1)*d };
        elm:= Binv[1] * LinearCombination( B, submat[1] );

        # Check that the matrix is in the image of the isomorphism.
        for k in [ 2 .. d ] do
          if B[k] * elm <> LinearCombination( B, submat[k] ) then
            return fail;
          fi;
        od;

        row[j]:= elm;

      od;
      preim[i]:= row;
    od;

    return preim;
    end );


#############################################################################
##
#F  BlowUpIsomorphism( <matgrp>, <B> )
##
InstallGlobalFunction( "BlowUpIsomorphism", function( matgrp, B )

    local gens,
          preimgs,
          imgs,
          range,
          iso;

    gens:= GeneratorsOfGroup( matgrp );
    if IsEmpty( gens ) then
      preimgs:= [ One( matgrp ) ];
      imgs:= [ IdentityMat( Length( preimgs[1] ) * Length( B ),
                   LeftActingDomain( UnderlyingLeftModule( B ) ) ) ];
      range:= GroupByGenerators( [], imgs[1] );
    else
      preimgs:= gens;
      imgs:= List( gens, mat -> BlownUpMat( B, mat ) );
      range:= GroupByGenerators( imgs );
    fi;

    iso:= rec();
    ObjectifyWithAttributes( iso,
        NewType( GeneralMappingsFamily( FamilyObj( preimgs[1] ),
                                        FamilyObj( imgs[1] ) ),
                     IsBlowUpIsomorphism
                 and IsGroupGeneralMapping
                 and IsAttributeStoringRep ),
        Source, matgrp,
        Range, range,
        Basis, B );

    return iso;
    end );


#############################################################################
##
##  stuff concerning invariant forms of matrix groups
#T add code for computing invariant forms,
#T and transforming matrices for normalizing the forms
#T (which is useful, e.g., for embedding the groups from AtlasRep into
#T the unitary, symplectic, or orthogonal groups in question)
##


#############################################################################
##
#M  InvariantBilinearForm( <matgrp> )
##  
InstallMethod( InvariantBilinearForm,
    "for a matrix group with known `InvariantQuadraticForm'",
    [ IsMatrixGroup and HasInvariantQuadraticForm ],
    function( matgrp )
    local Q;

    Q:= InvariantQuadraticForm( matgrp ).matrix;
    return rec( matrix:= ( Q + TransposedMat( Q ) ) );
    end );


#############################################################################
##
#E

