#############################################################################
##
#W  grpmat.gi                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for matrix groups.
##
Revision.grpmat_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  KnowsHowToDecompose( <mat-grp> )
##
InstallMethod( KnowsHowToDecompose, "matrix groups", true,
        [ IsMatrixGroup, IsList ], 0, ReturnFalse );


#############################################################################
##
#M  DefaultFieldOfMatrixGroup( <mat-grp> )
##
InstallMethod( DefaultFieldOfMatrixGroup,
    "using 'FieldOfMatrixGroup'",
    true,
    [ IsMatrixGroup ],
    0,
    FieldOfMatrixGroup );

InstallMethod( DefaultFieldOfMatrixGroup,
    "for matrix group over the cyclotomics",
    true,
    [ IsMatrixGroup and IsCyclotomicCollCollColl ], 0,
    grp -> Cyclotomics );

InstallOtherMethod( DefaultFieldOfMatrixGroup,
        "from source of nice monomorphism", true,
        [ IsMatrixGroup and HasNiceMonomorphism ], 0,
    grp -> DefaultFieldOfMatrixGroup( Source( NiceMonomorphism( grp ) ) ) );


#############################################################################
##
#M  FieldOfMatrixGroup( <mat-grp> )
##
InstallMethod( FieldOfMatrixGroup,
    "for a matrix group",
    true,
    [ IsMatrixGroup ],
    0,
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
InstallMethod( DimensionOfMatrixGroup, "from generators", true,
    [ IsMatrixGroup and HasGeneratorsOfGroup ], 0,
    function( grp )
    if not IsEmpty( GeneratorsOfGroup( grp ) )  then
        return Length( GeneratorsOfGroup( grp )[ 1 ] );
    else
        TryNextMethod();
    fi;
end );

InstallMethod( DimensionOfMatrixGroup, "from one", true,
    [ IsMatrixGroup and HasOne ], 1,
    grp -> Length( One( grp ) ) );

InstallOtherMethod( DimensionOfMatrixGroup,
        "from source of nice monomorphism", true,
        [ IsMatrixGroup and HasNiceMonomorphism ], 0,
    grp -> DimensionOfMatrixGroup( Source( NiceMonomorphism( grp ) ) ) );


#############################################################################
##
#M  One( <mat-grp> )
##
InstallOtherMethod( One,
    "for matrix group, call `IdentityMat'",
    true, [ IsMatrixGroup ], 0,
    grp -> IdentityMat( DimensionOfMatrixGroup( grp ),
                        DefaultFieldOfMatrixGroup( grp ) ) );

#############################################################################
##
#M  TransposedMatrixGroup( <G> ) . . . . . . . . .transpose of a matrix group
##
InstallMethod( TransposedMatrixGroup, 
    true, [ IsMatrixGroup ], 0,
function( G )
    local T;
    T := Group( List( GeneratorsOfGroup( G ), TransposedMat ), One( G ) );
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

#############################################################################
##
#F  DoSparseLinearActionOnFaithfulSubset( <G>,<act>,<sort> )
##
##  computes a linear action of the matrix group <G> on the span of the
##  standard basis. The action <act> must be `OnRight', `OnPoints' or
##  `OnLines'. The calculation of further orbits stops, once a basis for the
##  onderlying space has been reached, often giving a smaller degree
##  permutation representation.
##  The boolean <sort> indicates, whether the domain will be sorted.
BindGlobal("DoSparseLinearActionOnFaithfulSubset",
function(G,act,sort)
local orb,p,i,j,img,imgs,hom,permimg,imgn,starti,partbas,ll,heads,
      v,zero,zerov,en,lo,dim,field,start,acts,base,R,dict,xset;

  field:=FieldOfMatrixGroup(G);
  dict := NewDictionary( One(G)[1], true , field ^ Length( One( G ) ) );
  acts:=GeneratorsOfGroup(G);

  if Length(acts)=0 then
    start:=One(G);
  else
    start:=acts[1];
  fi;

  zerov:=Zero(start[1]);
  zero:=zerov[1];
  dim:=Length(zerov);

  base:=[]; # elements of start which are a base in the permgrp sense
  partbas:=[]; # la basis of space spanned so far
  heads:=[];
  orb:=[];
  permimg:=List(acts,i->[]);
  p:=1;

  starti:=1;
  while starti<=Length(start) and Length(partbas)<dim do

    ll:=Length(orb);
    img:=start[starti];
    v:=ShallowCopy(img);
    for j in [ 1 .. Length( heads ) ] do
      en:=v[heads[j]];
      if en <> zero then
	AddRowVector( v, partbas[j], - en );
      fi;
    od;

    if not IsZero(v) then
      Add(orb,img);
      AddDictionary(dict,img,Length(orb));

      # orbit algorithm with image keeper
      while p<=Length(orb) do
	for i in [1..Length(acts)] do
	  img := act(orb[p],acts[i]);
	  v:=LookupDictionary(dict,img);
	  if v=fail then
	    Add(orb,img);
	    AddDictionary(dict,img,Length(orb));
	    permimg[i][p]:=Length(orb);
	  else
	    permimg[i][p]:=v;
	  fi;
	od;
	p:=p+1;
      od;
    fi;
    starti:=starti+1;

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
  od;

  # Das Dictionary hat seine Schuldigkeit getan
  Unbind(dict);

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
  
  for i in [1..Length(permimg)] do
    permimg[i]:=PermList(permimg[i]);
  od;

  if fail in permimg then
    Error("not permutations");
  fi;
  xset:=ExternalSet( G, orb, acts, acts, act);

  # We know that the points corresponding to `start' give a base of the
  # vector space. We can use
  # this to get images quickly, using a stabilizer chain in the permutation
  # group
  SetBaseOfGroup( xset, base );

  hom := ActionHomomorphism( xset,"surjective" );
  SetIsInjective(hom,true); # we know by construction that its injective.
  R:=Group(permimg,());

  if HasSize(G) then
    SetSize(R,Size(G)); # faithful action
  fi;

  SetRange(hom,R);
  SetImagesSource(hom,R);
  p:=RUN_IN_GGMBI; # no niceomorphism translation here
  RUN_IN_GGMBI:=true;
  SetAsGroupGeneralMappingByImages( hom, GroupHomomorphismByImagesNC
            ( G, R, acts, permimg ) );

  SetFilterObj( hom, IsActionHomomorphismByBase );
  RUN_IN_GGMBI:=p;
  SetLinearActionBasis(hom,base);

  return hom;
end);

#############################################################################
##
#M  IsomorphismPermGroup( <mat-grp> )
##
BindGlobal( "NicomorphismOfGeneralMatrixGroup", function( grp,canon,sort )
  local   nice;
  # avoid a recursion due to the translation of homomorphisms for nice
  # groups
  if canon then
    nice:=SortedSparseActionHomomorphism( grp, One( grp ) );
  else
    nice:=DoSparseLinearActionOnFaithfulSubset( grp, OnRight, sort);
  fi;
  SetIsInjective( nice, true ); # surjectivity is ensured by `SortedSparse...'

  if canon then
    SetIsCanonicalNiceMonomorphism(nice,true);
  fi;
  return nice;
end );

InstallMethod( IsomorphismPermGroup, true, [ IsMatrixGroup and IsFinite ], 0,
function(G)
  if HasNiceMonomorphism(G) and IsPermGroup(Range(NiceMonomorphism(G))) then
    return NiceMonomorphism(G);
  else
    return NicomorphismOfGeneralMatrixGroup(G,false,false);
  fi;
end);

#############################################################################
##
#M  NiceMonomorphism( <mat-grp> )
##
InstallMethod( NiceMonomorphism, true, [ IsMatrixGroup and IsFinite ], 0,
  G->NicomorphismOfGeneralMatrixGroup(G,false,true));

#############################################################################
##
#M  CanonicalNiceMonomorphism( <mat-grp> )
##
InstallMethod( CanonicalNiceMonomorphism,true,[ IsMatrixGroup and IsFinite ],0,
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
InstallMethod(GeneratorsSmallest,"matrix group via niceo",true,
  [IsMatrixGroup and IsFinite],0,
function(G)
local gens,s,dom,mon,no;
  mon:=CanonicalNiceMonomorphism(G);
  no:=Image(mon,G);
  dom:=UnderlyingExternalSet(mon);
  s:=StabChainOp(no,rec(base:=List(BaseOfGroup(dom),
				      i->Position(HomeEnumerator(dom),i))));
  # call the recursive function to do the work
  gens:=SCMinSmaGens(no,s,[],(),true).gens;
  SetMinimalStabChain(G,s);
  return List(gens,i->PreImagesRepresentative(mon,i));
end);

#############################################################################
##
#M  MinimalStabChain(<finite matrix group>)
##
##  used for cosets where we probably won't need the smallest generators
InstallOtherMethod(MinimalStabChain,"matrix group via niceo",true,
  [IsMatrixGroup and IsFinite],0,
function(G)
local s,dom,mon,no;
  mon:=CanonicalNiceMonomorphism(G);
  no:=Image(mon,G);
  dom:=UnderlyingExternalSet(mon);
  s:=StabChainOp(no,rec(base:=List(BaseOfGroup(dom),
				      i->Position(HomeEnumerator(dom),i))));
  # call the recursive function to do the work
  SCMinSmaGens(no,s,[],(),false);
  return s;
end);

#############################################################################
##
#M  LargestElementGroup(<finite matrix group>)
##
InstallOtherMethod(LargestElementGroup,"matrix group via niceo",true,
  [IsMatrixGroup and IsFinite],0,
function(G)
local s,dom,mon;
  mon:=CanonicalNiceMonomorphism(G);
  dom:=UnderlyingExternalSet(mon);
  s:=StabChainOp(Image(mon,G),rec(base:=List(BaseOfGroup(dom),
				      i->Position(HomeEnumerator(dom),i))));
  # call the recursive function to do the work
  s:=LargestElementStabChain(s,());
  return PreImagesRepresentative(mon,s);
end);

#############################################################################
##
#M  CanonicalRightCosetElement(<finite matrix group>,<rep>)
##
InstallMethod(CanonicalRightCosetElement,"finite matric group",IsCollsElms,
  [IsMatrixGroup and IsFinite,IsMatrix],0,
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
  if Length(gens)>0 and Length(gens)*Length(gens[1])^2/VIEWLEN>8 then
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
InstallMethod(IsGeneralLinearGroup,"try natural",true,[IsMatrixGroup],0,
function(G)
  if IsNaturalGL(G) then 
    return true;
  else
    TryNextMethod();
  fi;
end);

#############################################################################
##
#M  IsSubgroupSL
##
InstallMethod(IsSubgroupSL,"determinant test for generators",true,
  [IsMatrixGroup and HasGeneratorsOfGroup],0,
function(G)
  return ForAll(GeneratorsOfGroup(G),i->IsOne(DeterminantMat(i)));
end);

#############################################################################
##
#M  <mat> in <G>  . . . . . . . . . . . . . . . . . . . .  is form invariant?
##
InstallMethod( \in, "respecting bilinear form", IsElmsColls,
        [ IsMatrix, IsFullSubgroupGLorSLRespectingBilinearForm ], 0,
function( mat, G )
  if IsSubgroupSL(G) and not IsOne(DeterminantMat(mat)) then return false;fi;
  return mat * InvariantBilinearForm(G).matrix * TransposedMat( mat ) =
	       InvariantBilinearForm(G).matrix;
end );

InstallMethod( \in, "respecting sesquilinear form", IsElmsColls,
        [ IsMatrix, IsFullSubgroupGLorSLRespectingSesquilinearForm ], 0,
function( mat, G )
local   f;
  if IsSubgroupSL(G) and not IsOne(DeterminantMat(mat)) then return false;fi;
  f := FrobeniusAutomorphism( FieldOfMatrixGroup( G ) );
  return mat * InvariantSesquilinearForm(G).matrix * List( TransposedMat( mat ),
		  row -> OnTuples(row,f)) = InvariantSesquilinearForm(G).matrix;
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
    true,
    [ IsRingElementCollCollColl ], 0,
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
    true, [ IsFFECollCollColl ] , 0,
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
    f:=FieldOfMatrixList(gens);
    gens:=List(Immutable(gens),i->ImmutableMatrix(f,i));

    G:=rec();
    ObjectifyWithAttributes(G,typ,GeneratorsOfMagmaWithInverses,AsList(gens));

    return G;
    end );

InstallMethod( GroupWithGenerators,
  "list of matrices with identity", IsCollsElms, 
  [ IsFFECollCollColl,IsMultiplicativeElementWithInverse and IsFFECollColl],0,
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
    f:=FieldOfMatrixList(gens);
    gens:=List(Immutable(gens),i->ImmutableMatrix(f,i));
    id:=ImmutableMatrix(f,id);

    G:=rec();
    ObjectifyWithAttributes(G,typ,GeneratorsOfMagmaWithInverses,AsList(gens),
                            One,id);

    return G;
end );


#############################################################################
##
#M  IsConjugatorIsomorphism( <hom> )
##
InstallMethod( IsConjugatorIsomorphism,
    "for a matrix group general mapping",
    true,
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
    Fs:= FieldOfMatrixGroup( s );
    Fr:= FieldOfMatrixGroup( r );
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
  V := FieldOfMatrixGroup( M ) ^ DimensionOfMatrixGroup( M );
  
  # the linear part
  G := Action( M, V );
  
  # the translation part
  gens:=List( Basis( V ), b -> Permutation( b, V, \+ ) );

  # construct the affine group
  A := GroupByGenerators(Concatenation(gens,GeneratorsOfGroup( G )));
  SetSize( A, Size( M ) * Size( V ) );

  if HasName( M )  then
      SetName( A, Concatenation( String( Size( FieldOfMatrixGroup( M ) ) ),
	      "^", String( DimensionOfMatrixGroup( M ) ), ":",
	      Name( M ) ) );
  fi;
  # the !.matrixGroup component is not documented!
  A!.matrixGroup := M; 
  return A;

end );


#############################################################################
##
#E

