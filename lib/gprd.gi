#############################################################################
##
#W  gprd.gi                     GAP library                      Bettina Eick
##                                                             Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.gprd_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  DirectProduct( <arg> )
##
InstallGlobalFunction( DirectProduct, function( arg )
local d;
  if Length( arg ) = 0 then
    Error( "<arg> must be nonempty" );
  elif Length( arg ) = 1 and IsList( arg[1] ) then
    if IsEmpty( arg[1] ) then
      Error( "<arg>[1] must be nonempty" );
    else
      d:=DirectProductOp( arg[1], arg[1][1] );
    fi;
  else
    d:=DirectProductOp( arg, arg[1] );
  fi;
  if ForAll(arg,HasSize) then
    SetSize(d,Product(List(arg,Size)));
  fi;
  return d;
end );


#############################################################################
##
#M  DirectProductOp( <list>, <G> )
##
InstallMethod( DirectProductOp,
    "for a list (of groups), and a group",
    true,
    [ IsList, IsGroup ], 0,
    function( list, gp )

    local ids, tup, first, i, G, gens, g, new, D;

    # Check the arguments.
    if IsEmpty( list ) then
      Error( "<list> must be nonempty" );
    elif ForAny( list, G -> not IsGroup( G ) ) then
      TryNextMethod();
    fi;

    ids := List( list, One );
    tup := [];
    first := [1];
    for i in [1..Length( list )] do
        G    := list[i];
        gens := GeneratorsOfGroup( G );
        for g in gens do
            new := ShallowCopy( ids );
            new[i] := g;
            new := Tuple( new );
            Add( tup, new );
        od;
        Add( first, Length( tup )+1 );
    od;

    D := GroupByGenerators( tup, Tuple( ids ) );

    SetDirectProductInfo( D, rec( groups := list,
                                  first  := first,
                                  embeddings := [],
                                  projections := [] ) );

    return D;
    end );        


#############################################################################
##
#M  \in( <tuple>, <G> )
##
InstallMethod( \in,"generic direct product", IsElmsColls,
    [ IsTuple, IsGroup and HasDirectProductInfo ], 0,
function( g, G )
    local n, info;
    n := Length( g );
    info := DirectProductInfo( G );
    return ForAll( [1..n], x -> g[x] in info.groups[x] );
end );


#############################################################################
##
#A Embedding
##
InstallMethod( Embedding, "group direct product and integer", true, 
         [ IsGroup and HasDirectProductInfo, IsPosInt ], 
         0,
    function( D, i )
    local info, G, imgs, hom, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then 
        return info.embeddings[i];
    fi;

    info.onelist:=List(info.groups,One);
    # compute embedding
    G := info.groups[i];
    gens := GeneratorsOfGroup( G );
    imgs := GeneratorsOfGroup( D ){[info.first[i] .. info.first[i+1]-1]};
    if Length(imgs)>0 and IsTuple(imgs[1]) then
      # the direct product is represented by tuples. The easiest way to
      # compute the embedding is to construct tuples
      hom:=GroupHomomorphismByFunction(G,D,function(elm)
	       local l;
	       l:=ShallowCopy(info.onelist);
	       l[i]:=elm;
	       return Tuple(l);
             end);
    else
      hom  := GroupHomomorphismByImagesNC( G, D, gens, imgs );
    fi;
    SetIsInjective( hom, true );

    # store information
    info.embeddings[i] := hom;
    return hom;
end );

#############################################################################
##
#A Projection
##
InstallMethod( Projection, "group direct product and integer", true, 
         [ IsGroup and HasDirectProductInfo, IsPosInt ], 
         0,
    function( D, i )
    local info, G, imgs, hom, N, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.projections[i] ) then 
        return info.projections[i];
    fi;

    # compute projection
    G    := info.groups[i];
    gens := GeneratorsOfGroup( D );
    imgs := Concatenation( 
               List( [1..info.first[i]-1], x -> One( G ) ),
               GeneratorsOfGroup( G ),
               List( [info.first[i+1]..Length(gens)], x -> One(G)));
    if Length(gens)>0 and IsTuple(gens[1]) then
      # the direct product is represented by tuples. The easiest way to
      # compute the projection is to take elements apart
      hom:=GroupHomomorphismByFunction( D, G, elm -> elm[i] );
    else
      hom := GroupHomomorphismByImagesNC( D, G, gens, imgs );
    fi;
    N := SubgroupNC( D, gens{Concatenation( [1..info.first[i]-1], 
                           [info.first[i+1]..Length(gens)])});
    SetIsSurjective( hom, true );
    SetKernelOfMultiplicativeGeneralMapping( hom, N );

    # store information
    info.projections[i] := hom;
    return hom;
end );

#############################################################################
##
#M  Size( <D> )
##
InstallMethod( Size, "group direct product",true, 
  [IsGroup and HasDirectProductInfo], 0,
function( D )
    return Product( List( DirectProductInfo( D ).groups, x -> Size(x) ) );
end );

#############################################################################
##
#M  IsSolvableGroup( <D> )
##
InstallMethod( IsSolvableGroup, "for direct products", true, 
               [IsGroup and HasDirectProductInfo], 0,
function( D )
    return ForAll( DirectProductInfo( D ).groups, IsSolvableGroup );
end );

#############################################################################
##
#M  Pcgs( <D> )
##
InstallMethod( Pcgs, "for direct products", true, 
               [IsGroup and CanEasilyComputePcgs and HasDirectProductInfo], 
	       Maximum(
		RankFilter(IsPcGroup),
		RankFilter(IsPermGroup and IsSolvableGroup)
	        ),# this is better than these two common alternatives
function( D )
    local info, pcs, i, pcgs, rels, one, new, g;
    if not IsTuple( One( D ) ) then TryNextMethod(); fi;
    info := DirectProductInfo( D );
    pcs := [];
    rels := [];
    one := List( info.groups, x -> One(x) );
    for i in [1..Length(info.groups)] do
        pcgs := Pcgs( info.groups[i] );
        for g in pcgs do
            new := ShallowCopy( one );
            new[i] := g;
            Add( pcs, Tuple( new ) );
        od;
        Append( rels, RelativeOrders( pcgs ) );
    od;
    pcs := PcgsByPcSequenceNC( ElementsFamily(FamilyObj( D ) ), pcs );
    SetRelativeOrders( pcs, rels );
    SetOneOfPcgs( pcs, One(D) );
    return pcs;
end );

#
# subdirect product stuff
#

InstallGlobalFunction(SubdirectProduct,function(G,H,ghom,hhom)
local iso;
  if Image(ghom,G)<>Image(hhom,H) then
    # are they isomorphic?
    iso:=IsomorphismGroups(Image(ghom,G),Image(hhom,H));
    if iso=fail then
      Error("the image groups are nonisomorphic");
    else
      Info(InfoWarning,1,
        "The image groups are inequal. Computed an isomorphism between them.");
      ghom:=ghom*iso;
    fi;
  fi;

  # the ...Op is installed for `IsGroupHomomorphism'. So we have to enforce
  # the filter to be set.
  if not IsGroupHomomorphism(ghom) or not IsGroupHomomorphism(hhom) then
    Error("mappings are not homomorphisms");
  fi;
  return SubdirectProductOp(G,H,ghom,hhom);
end);

#############################################################################
##
#M  SubdirectProduct( <G1>, <G2>, <phi1>, <phi2> )
##
InstallMethod( SubdirectProductOp,"groups", true,
  [ IsGroup, IsGroup, IsGroupHomomorphism, IsGroupHomomorphism ], 0,
function( G, H, gh, hh )
local gc,hc,S,info;
  # try to enforce a common representation
  if not (IsFinite(G) and IsFinite(H)) then
    TryNextMethod();
  fi;
  if IsSolvableGroup(G) and IsSolvableGroup(H) and
    not (IsPcGroup(G) and IsPcGroup(H)) then
    # enforce pc groups
    gc:=IsomorphismPcGroup(G);
    hc:=IsomorphismPcGroup(H);
  elif not (IsPermGroup(G) and IsPermGroup(H)) then
    # enforce perm groups
    gc:=IsomorphismPermGroup(G);
    hc:=IsomorphismPermGroup(H);
  else
    TryNextMethod();
  fi;
  gh:=InverseGeneralMapping(gc)*gh;
  hh:=InverseGeneralMapping(hc)*hh;
  S:=SubdirectProductOp(Image(gc,G),Image(hc,H),gh,hh);
  info:=rec(groups:=[G,H],
	    homomorphisms:=[gh,hh],
	    projections:=[Projection(S,1)*InverseGeneralMapping(gc),
			  Projection(S,2)*InverseGeneralMapping(hc)]);
  S:=Group(GeneratorsOfGroup(S));
  SetSubdirectProductInfo(S,info);
  return S;
end);

#############################################################################
##
#M  Projection( <S>, <i> )  . . . . . . . . . . . . . . . . . make projection
##
InstallMethod( Projection,"pc subdirect product", true,
      [ IsGroup and HasSubdirectProductInfo, IsPosInt ], 0,
function( S, i )
local   prj, info;
  if not i in [1,2] then
    Error("only 2 embeddings");
  fi;
  info := SubdirectProductInfo( S );
  if not IsBound(info.projections[i]) then
    TryNextMethod();
  fi;
  return info.projections[i];
end);

#############################################################################
##
#M  Size( <S> ) . . . . . . . . . . . . . . . . . . . .  of subdirect product
##
InstallMethod( Size,"subdirect product", true,
  [ IsGroup and HasSubdirectProductInfo ], 0,
    function( S )
    local info;
    info := SubdirectProductInfo( S );
    return Size( info.groups[ 1 ] ) * Size( info.groups[ 2 ] )
           / Size( ImagesSource( info.homomorphisms[ 1 ] ) );
end );



#
# functions for finding all SDP's
#

#############################################################################
##
#F InnerSubdirectProducts2( D, U, V ) . . . . . . . . . .up to conjugacy in D
##
InstallGlobalFunction(InnerSubdirectProducts2,function( D, U, V )
    local normsU, normsV, div, fac, Syl, NormU, orb, NormV, pairs, i, j,
          homU, homV, iso, subdir, gensU, gensV, N, UN, M, VM, Aut, gamma,
          P, NormUN, autU, n, alpha, NormVM, autV, reps, rep, gens, r, g, h,
          S, pair, imgs;
    
    # compute necessary normal subgroups in U and V
    if IsAbelian( U ) and IsAbelian( V ) then
        normsU := List( ConjugacyClassesSubgroups( U ), Representative );
        normsV := List( ConjugacyClassesSubgroups( V ), Representative );
    elif IsAbelian( U ) then
        normsU := List( ConjugacyClassesSubgroups( U ), Representative );
        normsV := NormalSubgroupsAbove( V, DerivedSubgroup(V),[]);
    elif IsAbelian( V ) then
        normsU := NormalSubgroupsAbove( U, DerivedSubgroup(U),[]);
        normsV := List( ConjugacyClassesSubgroups( V ), Representative );
    else
        div  := Set( FactorsInt( Gcd( Size( U ), Size( V ) ) ) );

        # in U
        fac  := Set( FactorsInt( Size( U ) ) );
        fac  := Filtered( fac, x -> not x in div );
        Syl  := List( fac, x -> GeneratorsOfGroup( SylowSubgroup( U, x ) ) );
        Syl  := Concatenation( Syl );
        Syl  := NormalClosure( U, Subgroup( U, Syl ) );
        normsU := NormalSubgroupsAbove( U, Syl, [] );
            
        # in V
        fac  := Set( FactorsInt( Size( V ) ) );
        fac  := Filtered( fac, x -> not x in div );
        Syl  := List( fac, x -> GeneratorsOfGroup( SylowSubgroup( V, x ) ) );
        Syl  := Concatenation( Syl );
        Syl  := NormalClosure( V, Subgroup( V, Syl ) );
        normsV := NormalSubgroupsAbove( V, Syl, [] );
    fi;

    # compute orbits on normal subgroups in U
    NormU  := Normalizer( D, U );
    orb    := OrbitsDomain( NormU, normsU, OnPoints );
    normsU := List( orb, x -> x[1] );

    # compute orbits on normal subgroups in V
    NormV  := Normalizer( D, V );
    orb    := OrbitsDomain( NormV, normsV, OnPoints );
    normsV := List( orb, x -> x[1] );

    # find isomorphic pairs of factors
    pairs := [];
    for i in [1..Length(normsU)] do
        for j in [1..Length(normsV)] do
            if Index( U, normsU[i] ) = Index( V, normsV[j] ) then
                homU := NaturalHomomorphismByNormalSubgroup( U, normsU[i] );
                homV := NaturalHomomorphismByNormalSubgroup( V, normsV[j] );
                iso := IsomorphismGroups( Image( homU ), Image( homV ) );
                if not IsBool( iso ) then
                    Add( pairs, [ homU, homV, iso] );
                fi;
            fi;
        od;
    od;

    # loop over pairs
    subdir := [];
    gensU  := GeneratorsOfGroup( U );
    gensV  := GeneratorsOfGroup( V );
    for pair in pairs do

        N := KernelOfMultiplicativeGeneralMapping( pair[1] ); 
        UN := Image( pair[1] );
        M := KernelOfMultiplicativeGeneralMapping( pair[2] ); 
        VM := Image( pair[2] );
        iso := pair[3];

        # calculate Aut( U / N )
        Aut := AutomorphismGroup( UN );
        gamma := IsomorphismPermGroup( Aut );
        P := Image( gamma );

        # calculate induced autos in G
        NormUN := Normalizer( NormU, N );
        autU   := [];
        for n in GeneratorsOfGroup( NormUN ) do
            gens := List( gensU, x -> Image( pair[1], x ) );
            imgs := List( gensU, x -> Image( pair[1], x^n ) );
            if gens <> imgs then
                alpha := GroupHomomorphismByImagesNC( UN, UN, gens, imgs );
                SetFilterObj( alpha, IsMultiplicativeElementWithInverse );
                Add( autU, Image( gamma, alpha ) );
            fi;
        od;
        autU := SubgroupNC( P, autU );

        # calculate induced autos in H
        NormVM := Normalizer( NormV, M );
        autV   := [];
        for n in GeneratorsOfGroup( NormVM ) do
            gens := List( gensV, x -> Image( pair[2], x ) );
            imgs := List( gensV, x -> Image( pair[2], x^n ) );
            if gens <> imgs then
                alpha := GroupHomomorphismByImagesNC( VM, VM, gens, imgs );
                alpha := iso * alpha * InverseGeneralMapping( iso );
                SetFilterObj( alpha, IsMultiplicativeElementWithInverse );
                Add( autV, Image( gamma, alpha ) );
            fi;
        od;
        autV := SubgroupNC( P, autV );

        # and obtain double coset reps
        reps := List( DoubleCosets( P, autU, autV ), Representative );
        reps := List( reps, x -> PreImagesRepresentative( gamma, x ) );

        # loop over automorphisms
        for rep in reps do

            # compute corresponding group
            gens := Concatenation( GeneratorsOfGroup( N ), 
                                   GeneratorsOfGroup( M ) );
            for r in GeneratorsOfGroup( UN ) do
                g := PreImagesRepresentative( pair[1], r );
                h := Image( iso, Image( rep, r ) );
                h := PreImagesRepresentative( pair[2], h );
                Add( gens, g * h );
            od;
            S := SubgroupNC( D, gens );
            SetSize( S, Size( N ) * Size( M ) * Size( UN ) );
            Add( subdir, S );
        od;
    od;

    # return
    return subdir;
end);

#############################################################################
##
#F InnerSubdirectProducts( D, list ) . . . . . . .iterated subdirect products
##
InstallGlobalFunction(InnerSubdirectProducts,function( P, list )
    local subdir, i, U, tmp, S, new;
    subdir := [list[1]];
    for i in [2..Length(list)] do
        U := list[i];
        tmp := [];
        for S in subdir do
            new := InnerSubdirectProducts2( P, S, U );
            Append( tmp, new );
        od;
        subdir := tmp;
    od;
    return subdir;
end);

#############################################################################
##
#F SubdirectProducts( S, T ) . . . . . . . . . . . up to conjugacy in parents
##
InstallGlobalFunction(SubdirectProducts,function( S, T )
    local G, H, D, emb1, emb2, U, V, subdir, info, i;

    # go over to direct product
    G := Parent( S );
    H := Parent( T );
    D := DirectProduct( G, H );

    # create embeddings
    emb1  := Embedding( D, 1 );
    emb2  := Embedding( D, 2 );

    # compute subdirect products
    U := Image( emb1, S );
    V := Image( emb2, T );

    subdir := InnerSubdirectProducts2( D, U, V );

    # create info
    info := rec( groups := [S, T],
                 projections := [Projection( D, 1 ), Projection( D, 2 )] );
        
    for i in [1..Length( subdir )] do
        SetSubdirectProductInfo( subdir[i], info );
    od;
         
    return subdir;
end);

#
# wreath products: generic code
#

InstallOtherMethod( WreathProduct,"generic groups", true,
 [ IsGroup, IsGroup ], 0,
function(G,H)
local iso;
  iso:=IsomorphismPermGroup(H);
  return WreathProduct(G,H,iso);
end);

#############################################################################
##
#M  WreathProduct(<G>,<H>,<alpha>)
##
InstallOtherMethod( WreathProduct,"generic groups with permhom", true,
 [ IsGroup, IsGroup, IsSPGeneralMapping ], 0,
function(G,H,alpha)
local I,n,fam,typ,gens,hgens,id,i,e,info,W;
  I:=Image(alpha,H);
  n:=LargestMovedPoint(I);
  fam:=NewFamily("WreathProductElemFamily",IsWreathProductElement);
  typ:=NewType(fam,IsWreathProductElementDefaultRep);
  fam!.defaultType:=typ;
  info:=rec(groups:=[G,H],
	    family:=fam,
            I:=I,
	    degI:=n,
	    alpha:=alpha,
	    embeddings:=[]);
  fam!.info:=info;
  if CanEasilyCompareElements(One(G)) then
    SetCanEasilyCompareElements(fam,true);
  fi;
  if CanEasilySortElements(One(G)) then
    SetCanEasilySortElements(fam,true);
  fi;

  gens:=[];
  id:=ListWithIdenticalEntries(n,One(G));
  Add(id,One(I));
  info.identvec:=ShallowCopy(id);
  for i in GeneratorsOfGroup(G) do
    e:=ShallowCopy(id);
    e[1]:=i;
    Add(gens,Objectify(typ,e));
  od;
  info.basegens:=ShallowCopy(gens);
  hgens:=[];
  for i in GeneratorsOfGroup(H) do
    e:=ShallowCopy(id);
    e[n+1]:=Image(alpha,i);
    Add(hgens,Objectify(typ,e));
  od;
  Append(gens,hgens);
  info.hgens:=hgens;
  SetOne(fam,Objectify(typ,id));
  W:=Group(gens,One(fam));
  SetWreathProductInfo(W,info);
  SetIsWholeFamily(W,true);
  if HasSize(G) then
    if IsFinite(G) then
      SetSize(W,Size(G)^n*Size(I));
    else
      SetSize(W,infinity);
    fi;
  fi;
  if HasIsFinite(G) then
    SetIsFinite(W,IsFinite(G));
  fi;
  return W;

end);

#############################################################################
##
#M  PrintObj(<x>)
##
InstallMethod(PrintObj,"wreath elements",true,[IsWreathProductElement],0,
function(x)
local i,info;
  info:=FamilyObj(x)!.info;
  Print("WreathProductElement(");
  for i in [1..info!.degI] do
    Print(x![i],",");
  od;
  Print(x![info!.degI+1],")");
end);

#############################################################################
##
#M  OneOp(<x>)
##
InstallMethod(OneOp,"wreath elements",true,[IsWreathProductElement],0,
  x->One(FamilyObj(x)));

#############################################################################
##
#M  InverseOp(<x>)
##
InstallMethod(InverseOp,"wreath elements",true,
  [IsWreathProductElement],0,
function(x)
local l,p,i,j,info,fam;
  fam:=FamilyObj(x);
  info:=fam!.info;
  l:=[];
  p:=x![info!.degI+1]^-1;
  for i in [1..info!.degI] do
    l[i]:=x![i^p]^-1;
  od;
  l[info!.degI+1]:=p;
  return Objectify(fam!.defaultType,l);
end);

#############################################################################
##
#M  \*(<x>,<y>)
##
InstallMethod(\*,"wreath elements",IsIdenticalObj,
  [IsWreathProductElement,IsWreathProductElement],0,
function(x,y)
local l,p,i,j,info,fam;
  fam:=FamilyObj(x);
  info:=fam!.info;
  l:=[];
  p:=x![info!.degI+1];
  for i in [1..info!.degI] do
    j:=i^p;
    l[i]:=x![i]*y![j];
  od;
  i:=info!.degI+1;
  l[i]:=p*y![i];
  return Objectify(fam!.defaultType,l);
end);

#############################################################################
##
#M  \=(<x>,<y>)
##
InstallMethod(\=,"wreath elements",IsIdenticalObj,
  [IsWreathProductElement,IsWreathProductElement],0,
function(x,y)
local i,info;
  info:=FamilyObj(x)!.info;
  for i in [1..info!.degI+1] do
    if x![i]<>y![i] then
      return false;
    fi;
  od;
  return true;
end);

#############################################################################
##
#M  \<(<x>,<y>)
##
InstallMethod(\<,"wreath elements",IsIdenticalObj,
  [IsWreathProductElement,IsWreathProductElement],0,
function(x,y)
local i,info;
  info:=FamilyObj(x)!.info;
  for i in [1..info!.degI+1] do
    if x![i]>y![i] then
      return false;
    elif x![i]<y![i] then
      return true;
    fi;
  od;
  return false;
end);

#############################################################################
##
#M  Embedding( <W>, <i> )
##
InstallMethod( Embedding,"generic wreath product", true,
  [ IsGroup and HasWreathProductInfo and IsWreathProductElementCollection,
    IsPosInt ], 0,
function(G,n)
local info,map,U,mapfun,P;
  info:=WreathProductInfo(G);
  if n<1 or n-1>info.degI then
    Error("wrong index");
  else
    if not IsBound(info.embeddings[n]) then
      mapfun:=function(elm)
	      local a;
		a:=ShallowCopy(info.identvec);
		if n>info.degI then
		  elm:=Image(info.alpha,elm);
		fi;
		a[n]:=elm;
		return Objectify(info.family!.defaultType,a);
	      end;
      if n<=info.degI then
	P:=info.groups[1];
        U:=SubgroupNC(G,List(GeneratorsOfGroup(P),mapfun));
      else
	P:=info.groups[2];
        U:=SubgroupNC(G,info.hgens);
      fi;
      map:=GroupHomomorphismByFunction(P,U,mapfun,
	function(elm)
	  elm:=elm![n];
	  if n>info.degI then
	    elm:=PreImagesRepresentative(info.alpha,elm);
	  fi;
	  return elm;
	end);
      info.embeddings[n]:=map;
    fi;
    return info.embeddings[n];
  fi;
end);
   
#############################################################################
##
#M  Projection( <W> )
##
InstallOtherMethod( Projection,"generic wreath product", true,
  [ IsGroup and HasWreathProductInfo and IsWreathProductElementCollection],0,
function(G)
local info,map,np;
  info:=WreathProductInfo(G);
  if not IsBound(info.projection) then
    np:=info.degI+1;

    map:=GroupHomomorphismByFunction(G,info.groups[2],
      function(elm)
	return PreImagesRepresentative(info.alpha,elm![np]);
      end,
      false, # not bijective
      function(elm)
	    local a;
	      a:=ShallowCopy(info.identvec);
	      elm:=Image(info.alpha,elm);
	      a[np]:=elm;
	      return Objectify(info.family!.defaultType,a);
	    end);
    info.projection:=map;
  fi;
  return info.projection;
end);
  
#############################################################################
##
#M  \in(<G>,<elm>
##
InstallMethod( \in,"generic wreath product", IsCollsElms,
  [ IsGroup and HasWreathProductInfo and IsWreathProductElementCollection
    and IsWholeFamily, IsWreathProductElement ], 0,
function(G,e)
  return true;
end);

#
# semidirect product
#

##############################################################################
##
#M  SemidirectProduct
##
InstallOtherMethod( SemidirectProduct, "automorphisms group with group", true,
  [ IsGroup, IsObject ], 0,
function( G, N )
  return SemidirectProduct(G,IdentityMapping(G),N);
end);

InstallMethod( SemidirectProduct,"different representations",true, 
    [ IsGroup, IsGroupHomomorphism, IsGroup ], 0,
function( G, aut, N )
local giso,niso,P,gens,a,Go,No,i;
  Go:=G;
  No:=N;
  if IsSolvableGroup(N) and IsSolvableGroup(G) then
    giso:=IsomorphismPcGroup(G);
    niso:=IsomorphismPcGroup(N);
  else
    giso:=IsomorphismPermGroup(G);
    niso:=IsomorphismPermGroup(N);
  fi;
  G:=Image(giso,G);
  N:=Image(niso,N);
  gens:=[];
  for i in GeneratorsOfGroup(G) do
    i:=Image(aut,PreImagesRepresentative(giso,i));
    i:=InducedAutomorphism(niso,i);
    Add(gens,i);
  od;
  a:=Group(gens,IdentityMapping(N));
  if IsFinite(N) then
    SetIsGroupOfAutomorphismsFiniteGroup(a,true);
  else
    SetIsGroupOfAutomorphisms(a,true);
  fi;
  a:=GroupHomomorphismByImagesNC(G,a,GeneratorsOfGroup(G),gens);
  P:=SemidirectProduct(G,a,N);
  # trick the embeddings and projections (dirty tricks)
  i:=rec(groups:=[Go,No],
         embeddings:=[giso*Embedding(P,1),niso*Embedding(P,2)],
	 projections:=Projection(P)*InverseGeneralMapping(giso));
  P:=Group(GeneratorsOfGroup(P));
  SetSemidirectProductInfo(P,i);
  return P;
end );

#############################################################################
##
#A Embedding/Projection
##
InstallMethod( Embedding,"of semidirect product and integer",true, 
    [ IsGroup and HasSemidirectProductInfo, IsPosInt ], 0,
function( P, i )
local info, G, imgs, hom;

  info := SemidirectProductInfo( P );
  if IsBound( info.embeddings[i] ) then 
    return info.embeddings[i];
  else
    TryNextMethod();
  fi;
end);

InstallOtherMethod( Projection,"of semidirect product", true, 
    [ IsGroup and HasSemidirectProductInfo ], 0,
function( P )
local info;
  info := SemidirectProductInfo( P );
  if not IsBool( info.projections ) then
    return info.projections;
  else
    TryNextMethod();
  fi;
end);

##############################################################################
##
#M  SemidirectProduct: with vector space
##
InstallOtherMethod( SemidirectProduct, "group with vector space: affine", true,
  [ IsGroup, IsGroupHomomorphism, IsFullRowModule and IsVectorSpace ], 0,
function( G, map, V )
local pm,F,d,b,s,t,pos,i,j,img,m,P,info,Go,bnt;
  # construction assumes faithful action. AH
  if Size(KernelOfMultiplicativeGeneralMapping(map))<>1 then
    TryNextMethod();
  fi;
  G:=Image(map,G);
  F:=LeftActingDomain(V);
  d:=DimensionOfVectors(V);
  # if G is a permgroup, take permutation matrices
  Go:=G;
  if IsPermGroup(G) then
    m:=List(GeneratorsOfGroup(G),i->PermutationMat(i,d,F));
    s:=Group(m);
    pm:=GroupHomomorphismByImagesNC(G,s,GeneratorsOfGroup(G),m);
    map:=map*pm;
    G:=s;
  fi;

  if not IsMatrixGroup(G) or d<>DimensionOfMatrixGroup(G) or not
    IsSubset(F,FieldOfMatrixGroup(G)) then
    Error("the matrices do not fit with the field");
  fi;
  b:=BasisVectors(Basis(V));
  # spin up a basis
  s:=[];
  pos:=1;
  t:=[];
  while Length(s)<Length(b) do
    # skip basis vectors that give nothing new
    while Length(s)>0 and RankMat(s)=RankMat(Concatenation(s,[b[pos]])) do
      pos:=pos+1;
    od;
    Add(s,b[pos]);
    Add(t,b[pos]); # those vectors need own affine matrices
    # spin the new vector
    i:=Length(s);
    while i<=Length(s) and Length(s)<Length(b) do
      for j in GeneratorsOfGroup(G) do
        img:=s[i]*j;
	if RankMat(s)<RankMat(Concatenation(s,[img])) then
	  # new dimension
	  Add(s,img);
	fi;
      od;
      i:=i+1;
    od;
  od;

  # do we need to take extra vectors to extend the field?
  if FieldOfMatrixGroup(G)<>F then
    b:=BasisVectors(Basis(Field(FieldOfMatrixGroup(G),GeneratorsOfField(F))));
    s:=[];
    for i in t do
      for j in b do
        Add(s,i*j);
      od;
    od;
    t:=s;
  fi;
  
  m:=[];
  # build affine matrices from group generators
  for i in GeneratorsOfGroup(G) do
    b:=MutableIdentityMat(d+1,F);
    b{[1..d]}{[1..d]}:=i;
    Add(m,ImmutableMatrix(F,b));
  od;
  # and from basis vectors
  bnt:=[];
  for i in t do
    b:=MutableIdentityMat(d+1,F);
    b[d+1]{[1..d]}:=i;
    b:=ImmutableMatrix(F,b);
    Add(m,b);
    Add(bnt,b);
  od;

  P:=Group(m,One(m[1]));
  SetSize(P,Size(G)*Size(V));
  info:=rec(group:=Go,
	    vectorspace:=V,
	    normalsub:=bnt,
	    lenlist:=[0,Length(GeneratorsOfGroup(G))],
            embeddings:=[],
	    field:=F,
	    dimension:=d,
	    projections:=true);
  SetSemidirectProductInfo( P, info );
    
  return P;
end);

##############################################################################
##
#M  Embedding
##
InstallMethod( Embedding, "vectorspace semidirect products",
    true, [ IsGroup and HasSemidirectProductInfo, IsPosInt ], 0,
function( S, i )
    local  info, G, genG, imgs, hom,j,m,n,d;

    info := SemidirectProductInfo( S );
    if not IsBound(info.vectorspace) then
      # its not a vectorspace product
      TryNextMethod();
    fi;

    if IsBound( info.embeddings[i] ) then
      return info.embeddings[i];
    fi;
    if i=1 then
      G := info.group;
      genG := GeneratorsOfGroup( G );
      imgs := GeneratorsOfGroup( S ){[info.lenlist[i]+1 .. info.lenlist[i+1]]};
      hom := GroupHomomorphismByImages( G, S, genG, imgs );
    elif i=2 then
      d:=info.dimension;

      # image of vectorspace
      n:=[];
      for j in BasisVectors(Basis(info.vectorspace)) do
	m:=MutableIdentityMat(d+1,info.field);
	m[d+1]{[1..d]}:=j;
	Add(n,ImmutableMatrix(info.field,m));
      od;
      n:=SubgroupNC(S,n);
      hom:=MappingByFunction(info.vectorspace,n,function(v)
        local m;
	m:=MutableIdentityMat(d+1,info.field);
	m[d+1]{[1..d]}:=v;
        return ImmutableMatrix(info.field,m);
      end,
      function(a)
        if not a in n then
	  Error("not in image");
	fi;
	return a[d+1]{[1..d]};
      end);
      SetImagesSource(hom,n);
    else
      Error("wrong index");
    fi;

    SetIsInjective( hom, true );
    info.embeddings[i] := hom;
    return hom;
end );


#############################################################################
##
#E

