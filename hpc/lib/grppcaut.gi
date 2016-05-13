#############################################################################
##
#W  grppcaut.gi                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##

#############################################################################
##
#F CheckAuto( auto )
##
CheckAuto := function( auto )
    local new,mapi;
    mapi:=MappingGeneratorsImages(auto);
    new := GroupGeneralMappingByImagesNC( Source(auto), Range(auto),
           mapi[1], mapi[2] );
    if Source( auto ) <> Range( auto ) then 
        Print("source and range differ \n");
        return false;
    fi;
    if not IsGroupHomomorphism( new ) then
        Print("no group hom \n");
        return false;
    fi;
    if not IsBijective( new ) then
        Print("no bijection \n");
        return false;
    fi;
    return true;
end;


#############################################################################
##
#F InducedActionFactor( mats, fac, low )
# this function is used only in a package.
##
InducedActionFactor := function( mats, fac, low )
    local sml, upp, d, i, b, t;
    sml := List( mats, x -> [] );
    upp := Concatenation( fac, low );
    d   := Length( fac );
    for i in [1..Length(mats)] do
        for b in fac do
            t := SolutionMat( upp, b*mats[i] ){[1..d]};
            Add( sml[i], t );
        od;
    od;
    return sml; 
end;

VectorStabilizerByFactors:=function(group,gens,mats,shadows,vec)
  local PrunedBasis, f, lim, mo, dim, bas, newbas, dims, q, bp, ind, affine, acts, nv, stb, idx, idxh, incstb, incperm, notinc, free, freegens, stabp, stabm, dict, orb, tp, tm, p, img, sch, incpermstop, sz, sel, nbas, offset, i;

  PrunedBasis:=function(p)
  local b,q,i;
    # prune too small factors
    b:=[p[1]];
    q:=0;
    for i in [2..Length(p)] do
      if i=Length(p) or Length(p[i+1])-q>lim then
	Add(b,p[i]);
	q:=Length(p[i]);
      fi;
    od;
    return b;
  end;

  f:=DefaultScalarDomainOfMatrixList(mats);
  lim:=LogInt(1000,Size(f));
  lim:=2;
  mo:=GModuleByMats(mats,f);
  dim:=mo.dimension;
  bas:=PrunedBasis(MTX.BasesCompositionSeries(mo));

  # form new basis of space
  newbas:=ShallowCopy(bas[2]);
  dims:=[0,Length(newbas)];
  for i in [3..Length(bas)] do
    q:=BaseSteinitzVectors(bas[i],newbas);
    Append(newbas,q.factorspace);
    Add(dims,Length(newbas));
  od;

  #base change newbas is matrix new -> old
  q:=newbas^-1;
  mats:=List(mats,i->newbas*i*q);
  #bas:=List(bas{[2..Length(bas)]},i->i*q);
  #bas:=Concatenation([[]],bas);
  vec:=vec*q;

  bp:=Length(dims)-1;
  while bp>=1 do
    ind:=[dims[bp]+1..dims[bp+1]];
    q:=[dims[bp+1]+1..dim];
    if bp+1=Length(dims) then
      affine:=false;
      ind:=[dims[bp]+1..dim];
    else
      affine:=List(mats,i->vec{q}*(i{q}{ind}));
    fi;
    Info(InfoMatOrb,2,"Acting dimension ",ind);
    acts:=List(mats,x->ImmutableMatrix(f,x{ind}{ind}));
    nv:=vec{ind};
    
    if (affine=false and ForAny([1..Length(acts)],i->nv*acts[i]<>nv))
    or (affine<>false and ForAny([1..Length(acts)],i->nv*acts[i]+affine[i]<>nv))
      then
      # orbit/stabilizer algorithm. We need to carry (pre)images through
      #os:=OrbitStabilizer(group,nv,hocos,ind[2].generators,OnRight);
      stb:=TrivialSubgroup(group);
      idx:=Size(group);idxh:=idx/Factors(idx)[1];
      incstb:=true;
      incperm:=true;
      notinc:=0;
      free:=FreeGroup(Length(gens));
      freegens:=GeneratorsOfGroup(free);
      stabp:=[];
      stabm:=[];
      dict:=NewDictionary(nv,true,f^Length(nv));
      orb:=[nv];
      AddDictionary(dict,nv,1);
      tp:=[One(group)];
      tm:=[One(free)];
      p:=1;
      while incstb and p<=Length(orb) do
	for i in [1..Length(gens)] do
	  if affine=false then
	    img:=orb[p]*acts[i];
	  else
	    img:=orb[p]*acts[i]+affine[i];
	  fi;
	  q:=LookupDictionary(dict,img);
	  if q=fail then
	    Add(orb,img);
	    if incstb and idxh<Length(orb) then
	      Info(InfoMatOrb,3,"stopped at orbit length ",
		Length(orb),"/",idx);
	      incstb:=false;
	    else
	      AddDictionary(dict,img,Length(orb));
	      if incperm then
		Add(tp,tp[p]*gens[i]);
	      fi;
	      Add(tm,tm[p]*freegens[i]);
	    fi;
	  elif incstb then
	    if IsBound(tp[p]) and IsBound(tp[q]) then
	      sch:=tp[p]*gens[i]/tp[q];
	    elif Random([1..200])=1 then
	      if IsBound(tp[p]) then
		sch:=tp[p];
	      else
		sch:=MappedWord(tm[p],freegens,gens);
	      fi;
	      sch:=sch*gens[i];
	      if IsBound(tp[q]) then
		sch:=sch/tp[q];
	      else
		sch:=sch/MappedWord(tm[q],freegens,gens);
	      fi;
	    else
	      sch:=false;
	    fi;
	    if sch<>false and not sch in stb then
#Print("new schreiergen",Length(orb),"\n");
	      stb:=ClosureSubgroupNC(stb,sch);
	      idx:=Size(group)/Size(stb);idxh:=idx/Factors(idx)[1];
	      if idxh<Length(orb) then
		Info(InfoMatOrb,3,"stopped at orbit length ",
		  Length(orb),"/",idx);
		incstb:=false;
	      fi;
	      Add(stabp,sch);
	      sch:=tm[p]*freegens[i]/tm[q];
	      Add(stabm,sch);
	      notinc:=0;
	    elif incperm then
	      notinc:=notinc+1;
	      if 20*notinc>idxh and notinc>10000 then 
		Info(InfoMatOrb,3, Length(orb),
		" -- not incrementing perms again:",Size(group)/Size(stb));
		incperm:=false;
		incpermstop:=p;
	      fi;
#Print("old schreiergen",Length(orb),"\n");
	    fi;
	  fi;
	od;
	p:=p+1;
      od;
      #sz:=Maximum(Difference(DivisorsInt(sz),[sz]));
      if Length(orb)<=idxh then
	Info(InfoWarning,1,"too small stabilizer");
	p:=incpermstop;
	sz:=Size(group)/Length(orb);
	while Size(stb)<sz do
	  for i in [1..Length(gens)] do
	    if affine=false then
	      img:=orb[p]*acts[i];
	    else
	      img:=orb[p]*acts[i]+affine[i];
	    fi;
	    q:=LookupDictionary(dict,img);
	    if q=fail then
	      Error("error in orbit alg");
	    else
	      if IsBound(tp[p]) then
		sch:=tp[p];
	      else
		sch:=MappedWord(tm[p],freegens,gens);
	      fi;
	      sch:=sch*gens[i];
	      if IsBound(tp[q]) then
		sch:=sch/tp[q];
	      else
		sch:=sch/MappedWord(tm[q],freegens,gens);
	      fi;
	      if not sch in stb then
		stb:=ClosureSubgroupNC(stb,sch);
		Add(stabp,sch);
		sch:=tm[p]*freegens[i]/tm[q];
		Add(stabm,sch);
	      fi;
	    fi;
	  od;
	  p:=p+1;
	od;
      fi;
      sz:=Size(stb);
      sel:=[];
      stb:=TrivialSubgroup(group);
      for i in Reversed([1..Length(stabp)]) do
	if not stabp[i] in stb then
	  Add(sel,i);
	  stb:=ClosureSubgroupNC(stb,stabp[i]);
	fi;
      od;
      stabp:=stabp{sel};
      stabm:=stabm{sel};
      sz:=Size(group)/Size(stb);
      Info(InfoMatOrb,2,"Orbit length ",Length(orb),
           " stabilizer index ",sz,", ",Length(sel)," generators");
      Unbind(orb); Unbind(dict);Unbind(tp);Unbind(tm);
      group:=stb;
      gens:=stabp;
      mats:=List(stabm,i->MappedWord(i,freegens,mats));
      shadows:=List(stabm,i->MappedWord(i,freegens,shadows));
      if AssertionLevel()>0 then
	    ind:=[dims[bp]+1..dim];
	    acts:=List(mats,x->ImmutableMatrix(f,x{ind}{ind}));
	    nv:=vec{ind};
	    Assert(1,ForAll(acts,i->nv*i=nv));
      fi;

      # should we try to refine the next step?
      if Length(mats)>0 and sz>1 and bp>1 and ForAny([2..bp],q->dims[q]-dims[q-1]>lim) then
	mo:=GModuleByMats(mats,f);
	ind:=[1..dims[bp]];
	acts:=List(mats,x->ImmutableMatrix(f,x{ind}{ind}));
	mo:=GModuleByMats(acts,f);
	#if not MTX.IsIrreducible(mo) then
	nbas:=PrunedBasis(MTX.BasesCompositionSeries(mo));
	offset:=Length(nbas)-bp;
        if offset>0 then
	  #nbas:=nbas{[2..Length(nbas)]};
	  q:=IdentityMat(dim,f){ind};
	  nbas:=List(nbas,i->List(i,j->j*q));
	  Info(InfoMatOrb,2,"Reduction ",List(nbas,Length));
	  newbas:=[];
	  for i in nbas do
	    q:=BaseSteinitzVectors(i,newbas);
	    Append(newbas,q.factorspace);
	  od;
	  Append(newbas,IdentityMat(dim,f){[dims[bp]+1..dim]});
	  newbas:=ImmutableMatrix(f,newbas);

	  dims:=Concatenation(List(nbas{[1..Length(nbas)]},Length),
		 dims{[bp+1..Length(dims)]});

	  #Error("further reduction!");
	  #base change newbas is matrix new -> old
	  q:=newbas^-1;
	  mats:=List(mats,i->newbas*i*q);
	  vec:=vec*q;
	  bp:=bp+offset;

	fi;
	if AssertionLevel()>0 then
	  ind:=[dims[bp]+1..dim];
	  acts:=List(mats,x->ImmutableMatrix(f,x{ind}{ind}));
	  nv:=vec{ind};
	  Assert(1,ForAll(acts,i->nv*i=nv));
	fi;

      fi;
    fi;
    bp:=bp-1;
  od;
  Assert(1,ForAll(mats,i->vec*i=vec));
  return rec(stabilizer:=group,
             gens:=gens,
	     mats:=mats,
	     shadows:=shadows);
end;

#############################################################################
##
#F StabilizerByMatrixOperation( C, v, cohom )
##
StabilizerByMatrixOperation := function( C, v, cohom )
local translate, gens, oper, fac, ind, vec, tmp;

    # the trivial case 
    if Size( C ) = 1 then return C; fi;

    # can we get a permrep?
    if IsBound(C!.permrep) then
      translate:=C!.permrep;
    else
      translate:=EXPermutationActionPairs(C);
    fi;

    # choose gens 
    if translate<>false then
      Unbind(translate.isomorphism);
      EXReducePermutationActionPairs(translate);
      gens:=translate.pairgens;
    elif HasPcgs( C ) then 
      gens := Pcgs( C );
    else 
      gens := GeneratorsOfGroup( C ); 
    fi;

    # compute matrix operation
    oper := MatrixOperationOfCPGroup( cohom, gens );

    if translate<>false then
      tmp:=VectorStabilizerByFactors(translate.permgroup,translate.permgens,
	                             oper,translate.pairgens,v);
      translate:=rec(permgroup:=tmp.stabilizer,
		     permgens:=tmp.gens,
		     pairgens:=tmp.shadows);
      C:=GroupByGenerators(translate.pairgens,One(C));
      SetSize(C,Size(tmp.stabilizer));
    else
      tmp := OrbitStabilizer( C, v, gens, oper, OnRight );
      Info( InfoMatOrb, 1, " MO: found orbit of length ",Length(tmp.orbit) );
      SetSize( tmp.stabilizer, Size( C ) / Length( tmp.orbit ) );
      C   := tmp.stabilizer;
    fi;

    if translate<>false then
      C!.permrep:=translate;
    fi;
    return C;
end;

#############################################################################
##
#F TransferPcgsInfo( A, pcsA, rels )
##
TransferPcgsInfo := function( A, pcsA, rels )
    local pcgsA;
    pcgsA := PcgsByPcSequenceNC( ElementsFamily( FamilyObj( A ) ), pcsA );
    SetRelativeOrders( pcgsA, rels );
    SetOneOfPcgs( pcgsA, One(A) );
    SetPcgs( A, pcgsA );
    SetFilterObj( A, CanEasilyComputePcgs );
end;

#############################################################################
##
#F BlockStabilizer( G, bl )
##
BlockStabilizer := function( G, bl )
    local sub, sortbl, f, len, pos, L, new;

    # the trivial blocksys is useless
    if ForAll( bl, x -> Length(x) = 1 ) then return G; fi;
    if Length( bl ) = 1 then return G; fi;
    sub := Filtered( bl, x -> Length(x) > 1 );
    len := Set( List( sub, x -> Length(x) ) );
    pos := List( len, x -> Filtered(sub, y -> Length(y) = x ) );
    L   := ShallowCopy( G );
    Sort( pos, function( x, y ) return Length(x) < Length( y ); end);

    sortbl := function( sys )
        local i;
        for i in [1..Length(sys)] do
            Sort( sys[i] );
        od;
        Sort( sys, function( x, y ) return x[1] < y[1]; end);
    end;
    sortbl( sub );

    f := function( pt, perm )
        local new;
        new := List( pt, x -> List( x, y -> y^perm) );
        sortbl( new );
        return new;
    end;

    # now loop
    for new in pos do
        if Length( new ) = 1 then
            L := Stabilizer( L, new[1], OnSets );
        else
            L := Stabilizer( L, new, f );
        fi;
    od;
        
    return L;
end;

#############################################################################
##
#F InducedActionAutGroup( epi, weights, s, n, A )
##
InducedActionAutGroup := function( epi, weights, s, n, A )
    local M, H, F, pcgsM, indices, pcsN, N, d, gensN, G, free, words,
          comp, aut, imgs, mat, w, m, exp, tup, gensG, field, D, gensA;

    M := KernelOfMultiplicativeGeneralMapping( epi );
    H := Source( epi );
    F := Image( epi );
    pcgsM := Pcgs( M );
    field := GF( weights[s][3] );

    # construct p-subgroup of H 
    indices := Filtered( [1..s-1], x -> weights[x][1] = weights[s][1] 
                                   and  weights[x][3] = weights[s][3] );
    pcsN  := Pcgs( H ){indices};
    N     := SubgroupNC( H, pcsN );
    d     := Length( indices );
    gensN := pcsN{[1..d]};

    # construct words for pcgsM in gensN
    G     := FreeGroup( d );
    gensG := GeneratorsOfGroup( G );
    free  := GroupHomomorphismByImagesNC( G, N, gensG, gensN );
    words := List( pcgsM, x -> PreImagesRepresentative( free, x ) );

    # compute images of words
    comp := [];
    if CanEasilyComputePcgs( A ) then
        gensA := Pcgs( A );
    else
        gensA := GeneratorsOfGroup( A );
    fi;
    for aut in gensA do
        imgs := List( gensN, x -> Image( aut, Image( epi, x ) ) );
        imgs := List( imgs, x -> PreImagesRepresentative( epi, x ) );
        mat := [];
        for w in words do
            m := MappedWord( w, gensG, imgs );
            exp := ExponentsOfPcElement( pcgsM, m ) * One( field );
            Add( mat, exp );
        od;
        tup := DirectProductElement( [aut, mat] );
        Add( comp, tup );
    od; 

    # add size and check solubility
    D := GroupByGenerators( comp, DirectProductElement( [ One( A ),
             Immutable( IdentityMat(Length(pcgsM), field) )]));
    SetSize( D, Size( A ) );
    if CanEasilyComputePcgs( A ) then
        TransferPcgsInfo( D, comp, RelativeOrders( gensA ) );
    fi;
   
    return D;
end;

#############################################################################
##
#F Fingerprint( G, U )
##
if not IsBound( MyFingerprint ) then MyFingerprint := false; fi;

FingerprintSmall := function( G, U )
    return [IdGroup( U ), Size( CommutatorSubgroup(G,U) )];
end;

FingerprintMedium := function( G, U )
    local w, cl, id;

    # some general stuff
    w := LGWeights( SpecialPcgs( U ) );
    id := [w, Size( CommutatorSubgroup( G, U ) )];

    # about conjugacy classes
    cl := OrbitsDomain( U, AsList( U ), OnPoints );
    cl := List( cl, x -> [Length(x), Order( x[1] ) ] );
    Sort( cl );
    Add( id, cl );

    return id;
end;

FingerprintLarge := function( G, U )
    return [Size(U), Size( DerivedSubgroup( U ) ),
            Size( CommutatorSubgroup( G, U ) )];
end;

Fingerprint := function ( G, U )
    if not IsBool( MyFingerprint ) then
        return MyFingerprint( G, U );
    fi;
    if ID_AVAILABLE( Size( U ) ) <> fail then 
        return FingerprintSmall( G, U );
    elif Size( U ) <= 1000 then
        return FingerprintMedium( G, U );
    else
        return FingerprintLarge( G, U );
    fi;
end;

#############################################################################
##
#F NormalizingReducedGL( spec, s, n, M )
##
NormalizingReducedGL := function( spec, s, n, M )
    local G, p, d, field, B, U, hom, pcgs, pcs, rels, w,
          S, L,
          f, P, norm,
          pcgsN, pcgsM, pcgsF, 
          orb, part,
          par, done, i, elm, elms, pcgsH, H, tup, pos, 
          perms, V;

    G      := GroupOfPcgs( spec );
    d      := M.dimension;
    field  := M.field;
    p      := Characteristic( field );
    B      := GL( d, p );
    U      := SubgroupNC( B, M.generators );

    # the trivial case 
    if d = 1 then 
        hom := IsomorphismPermGroup( B );
        pcgs := Pcgs( Image( hom ) );
        pcs := List( pcgs, x -> PreImagesRepresentative( hom, x ) );
        TransferPcgsInfo( B, pcs, RelativeOrders( pcgs ) );
        return B;
    fi;

    # first find out, whether there are characteristic subspaces
    # -> compute socle series and chain stabilising mat group
    S := B;

    # in case that we cannot compute a perm rep of pgl
    if p^d > 10000 then
        return S;
    fi;

    # otherwise use a perm rep of pgl and find a small admissible subgroup
    norm := NormedRowVectors( field^d );
    f := function( pt, op ) return NormedRowVector( pt * op ); end;
    hom := ActionHomomorphism( S, norm, f );
    P := Image( hom );
    L := ShallowCopy(P);

    # compute corresponding subgroups to mins
    pcgsN := InducedPcgsByPcSequenceNC( spec, spec{[s..Length(spec)]} );
    pcgsM := InducedPcgsByPcSequenceNC( spec, spec{[n..Length(spec)]} );
    pcgsF := pcgsN mod pcgsM;

    # use fingerprints
    done := [];
    part := [];
    for i in [1..Length(norm)] do
        elm := PcElementByExponentsNC( pcgsF, norm[i] );
        elms := Concatenation( [elm], pcgsM );
        pcgsH := InducedPcgsByPcSequenceNC( spec, elms );
        H := SubgroupByPcgs( G, pcgsH );
        tup := Fingerprint( G, H );
        pos := Position( done, tup );
        if IsBool( pos ) then
            Add( part, [i] );
            Add( done, tup );
        else
            Add( part[pos], i );
        fi;
    od;
    Sort( part, function( x, y ) return Length(x) < Length(y); end );

    # compute partition stabilizer
    if Length(part) > 1 then
        for par in part do 
            if Length( part ) = 1 then
                L := Stabilizer( L, par[1], OnPoints );
            else
                L := Stabilizer( L, par, OnSets );
            fi;
        od;
    fi;
    Info( InfoOverGr, 1, "found partition ",part );

    # use operation of G on norm
    orb := OrbitsDomain( U, norm, f );
    part := List( orb, x -> List( x, y -> Position( norm, y ) ) );

    # was: L := BlockStabilizer( L, part );
    part:=List(part,Set);
    L:=PartitionStabilizerPermGroup(L,part);
    Info( InfoOverGr, 1, "found blocksystem ",part );

    # compute normalizer of module
    perms := List( M.generators, x -> Image( hom, x ) );
    V := SubgroupNC( P, perms );
    L := Normalizer( L, V );
    Info( InfoOverGr, 1, "computed normalizer of size ", Size(L));

    # go back to mat group
    B := List( GeneratorsOfGroup(L), x -> PreImagesRepresentative(hom,x) );
    w := PrimitiveRoot(field)* Immutable( IdentityMat( d, field ) );
    B := SubgroupNC( S, Concatenation( B, [w] ) );

    if IsSolvableGroup( L ) then
        pcgs := List( Pcgs(L), x -> PreImagesRepresentative( hom, x ) );
        Add( pcgs, w );
        rels := ShallowCopy( RelativeOrders( Pcgs(L) ) );
        Add( rels, p-1 );
        TransferPcgsInfo( B, pcgs, rels );
    fi;

    SetSize( B, Size( L )*(p-1) );
    return B;
end;

#############################################################################
##
#F CocycleSQ( epi, field )
##
CocycleSQ := function( epi, field )
    local H, F, N, pcsH, pcsN, pcgsH, o, n, d, z, c, i, j, h, exp, p, k;

    # set up
    H     := Source( epi );
    F     := Image( epi );
    N     := KernelOfMultiplicativeGeneralMapping( epi );
    pcsH  := List( Pcgs( F ), x -> PreImagesRepresentative( epi, x ) );
    pcsN  := Pcgs( N );
    pcgsH := PcgsByPcSequence( ElementsFamily( FamilyObj( H ) ), 
                               Concatenation( pcsH, pcsN ) );
    o     := RelativeOrders( pcgsH );
    n     := Length( pcsH );
    d     := Length( pcsN );
    z     := One( field );
    
    # initialize cocycle
    c := List( [1..d*(n^2 + n)/2], x -> Zero( field ) );

    # add relators
    for i in [1..n] do
        for j in [1..i] do
            if i = j then
                h := pcgsH[i]^o[i];
            else
                h := pcgsH[i]^pcgsH[j];
            fi; 
            exp := ExponentsOfPcElement( pcgsH, h ){[n+1..n+d]} * z;
            p   := (i^2 - i)/2 + j - 1;
            for k in [1..d] do
                c[p*d+k] := exp[k];
            od;
        od;
    od;

    # check
    if c = 0 * c then return 0; fi;
    return c;
end;
             
#############################################################################
##
#F InduciblePairs( C, epi, M )
##
InduciblePairs := function( C, epi, M )
    local F, cc, c, stab, b;

    if HasSize( C ) and Size( C ) = 1 then return C; fi;

    # get groups
    F := Image( epi );

    # get cohomology
    cc := TwoCohomology( F, M );
    Info( InfoAutGrp, 2, "computed cohomology with dim ",
          Dimension(Image(cc.cohom)));
    # get cocycle
    c := CocycleSQ( epi, M.field );
    b := Image( cc.cohom, c );

    # compute stabilizer of b
    stab := StabilizerByMatrixOperation( C, b, cc );
    return stab;
end;
   
MatricesOfRelator := function( rel, gens, inv, mats, field, d )
    local n, m, L, s, i, mat;

    # compute left hand side
    n := Length( mats );
    m := Length( rel );
    L := ListWithIdenticalEntries( n, Immutable( NullMat( d, d, field ) ) );
    while m > 0 do
        s := Subword( rel, 1, 1 );
        i := Position( gens, s );
        if not IsBool( i ) and m > 1 then
            mat := MappedWord(Subword( rel, 2, m ), gens, mats);
            L[i] := L[i] + mat;
        elif not IsBool( i ) then
            L[i] := L[i] + IdentityMat( d, field );
        else
            i := Position( inv, s );
            mat := MappedWord( rel, gens, mats );
            L[i] := L[i] - mat;
        fi;
        if m > 1 then rel := Subword( rel, 2, m ); fi;
        m   := m - 1;
    od;
    return L;
end;

VectorOfRelator := function( rel, gens, imgsF, pcsH, pcsN, nu, field )
    local w, s, r;

    # compute right hand side
    w := MappedWord( rel, gens, imgsF )^-1;
    s := MappedWord( rel, gens, pcsH );
    r := ExponentsOfPcElement( pcsN, w * Image( nu, s ) ) * One(field);
    return r;
end;

#############################################################################
##
#F LiftInduciblePair( epi, ind, M, weight )
##
LiftInduciblePair := function( epi, ind, M, weight )
    local H, F, N, pcgsF, pcsH, pcsN, pcgsH, n, d, imgsF, imgsN, nu, P, 
          gensP, invP, relsP, l, E, v, k, rel, u, vec, L, r, i,
          elm, auto, imgsH, j, h, opmats;

    # set up
    H := Source( epi );
    F := Image( epi );
    N := KernelOfMultiplicativeGeneralMapping( epi );


    pcgsF := Pcgs( F );
    pcsH  := List( pcgsF, x -> PreImagesRepresentative( epi, x ) );
    pcsN  := Pcgs( N );
    pcgsH := PcgsByPcSequence( ElementsFamily( FamilyObj( H ) ),
                               Concatenation( pcsH, pcsN ) );
    n     := Length( pcsH ); 
    d     := Length( pcsN );

    # use automorphism of F
    imgsF := List( pcgsF, x -> Image( ind[1], x ) );
    opmats := List( imgsF, x -> MappedPcElement( x, pcgsF, M.generators ) );
    imgsF := List( imgsF, x -> PreImagesRepresentative( epi, x ) );

    # use automorphism of N
    imgsN := List( pcsN, x -> ExponentsOfPcElement( pcsN, x ) );
    imgsN := List( imgsN, x -> x * ind[2] );
    imgsN := List( imgsN, x -> PcElementByExponentsNC( pcsN, x ) ); 

    # in the split case this is all to do
    if weight[2] = 1 then
        imgsH := Concatenation( imgsF, imgsN );
        auto  := GroupHomomorphismByImagesNC( H, H, AsList(pcgsH), imgsH );
    
        SetIsBijective( auto, true );
        SetKernelOfMultiplicativeGeneralMapping( auto, TrivialSubgroup( H ) );

        return auto;
    fi;

    # add correction
    nu := GroupHomomorphismByImagesNC( N, N, AsList( pcsN ), imgsN );
    P := Range( IsomorphismFpGroupByPcgs( pcgsF, "g" ) );
    gensP := GeneratorsOfGroup( FreeGroupOfFpGroup( P ) );
    invP  := List( gensP, x -> x^-1 );
    relsP := RelatorsOfFpGroup( P );
    l := Length( relsP );

    E := List( [1..n*d], x -> List( [1..l*d], y -> true ) );
    v := [];
    for k in [1..l] do
        rel := relsP[k];
        L   := MatricesOfRelator( rel, gensP, invP, opmats, M.field, d );
        r   := VectorOfRelator( rel, gensP, imgsF, pcsH, pcsN, nu, M.field );
  
        # add to big system
        Append( v, r );
        for i in [1..n] do
            for j in [1..d] do
                for h in [1..d] do
                    E[d*(i-1)+j][d*(k-1)+h] := L[i][j][h];
                od;
            od;
        od;
    od;

    # solve system
    u := SolutionMat( E, v );
    if u = fail then Error("no lifting found"); fi;

    # correct images 
    for i in [1..n] do
        vec := u{[d*(i-1)+1..d*i]};
        elm := PcElementByExponentsNC( pcsN, vec );
        imgsF[i] := imgsF[i] * elm;
    od;

    # set up automorphisms
    imgsH := Concatenation( imgsF, imgsN );
    auto  := GroupHomomorphismByImagesNC( H, H, AsList( pcgsH ), imgsH );
    
    SetIsBijective( auto, true );
    SetKernelOfMultiplicativeGeneralMapping( auto, TrivialSubgroup( H ) );

    return auto;
end;

#############################################################################
##
#F AutomorphismGroupElAbGroup( G, B )
##
AutomorphismGroupElAbGroup := function( G, B )
    local pcgs, p, d, mats, autos, mat, imgs, auto, A;

    # create matrices
    pcgs := Pcgs( G );
    p := RelativeOrders( pcgs )[1];
    d := Length( pcgs );

    if CanEasilyComputePcgs( B ) then
        mats := Pcgs( B );
    else
        mats := GeneratorsOfGroup( B );
    fi;

    autos := [];
    for mat in mats do
        imgs := List( pcgs, x -> PcElementByExponentsNC( pcgs, 
                            ExponentsOfPcElement( pcgs, x ) * mat ) ); 
        auto := GroupHomomorphismByImagesNC( G, G, AsList( pcgs ), imgs );
 
        SetIsBijective( auto, true );
        SetKernelOfMultiplicativeGeneralMapping( auto, TrivialSubgroup( G ) );
        Add( autos, auto );
    od;

    A := GroupByGenerators( autos, IdentityMapping( G ) );
    SetSize( A, Size( B ) );
    if IsPcgs( mats ) then
        TransferPcgsInfo( A, autos, RelativeOrders( mats ) );
    fi;
    
    return A;
end;

#############################################################################
##
#F AutomorphismGroupSolvableGroup( G )
##
InstallGlobalFunction(AutomorphismGroupSolvableGroup,function( G )
    local spec, weights, first, m, pcgsU, F, pcgsF, A, i, s, n, p, H, 
          pcgsH, pcgsN, N, epi, mats, M, autos, ocr, elms, e, list, imgs,
          auto, tmp, hom, gens, P, C, B, D, pcsA, rels, iso, xset,
          gensA, new,as;

    # get LG series
    spec    := SpecialPcgs(G);
    weights := LGWeights( spec );
    first   := LGFirst( spec );
    m       := Length( spec );

    # set up with GL
    Info( InfoAutGrp, 2, "set up computation for grp with weights ",
                          weights);
    pcgsU := InducedPcgsByPcSequenceNC( spec, spec{[first[2]..m]} );
    pcgsF := spec mod pcgsU;
    F     := PcGroupWithPcgs( pcgsF );
    M     := rec( field := GF( weights[1][3] ),
                  dimension := first[2]-1,
                  generators := [] );
    B     := NormalizingReducedGL( spec, 1, first[2], M );
    A     := AutomorphismGroupElAbGroup( F, B );
    SetIsGroupOfAutomorphismsFiniteGroup(A,true);

    # run down series
    for i in [2..Length(first)-1] do

        # get factor
        s := first[i];
        n := first[i+1];
        p := weights[s][3];
        Info( InfoAutGrp, 2, "start ",i,"th layer, weight ",weights[s],
                             "^", n-s, ", aut.grp. size ",Size(A));

        # set up
        pcgsU := InducedPcgsByPcSequenceNC( spec, spec{[n..m]} );
        H     := PcGroupWithPcgs( spec mod pcgsU );
        pcgsH := Pcgs( H );
        ocr   := rec( group := H, generators := pcgsH );
        # we will modify the generators later!

        pcgsN := InducedPcgsByPcSequenceNC( pcgsH, pcgsH{[s..n-1]} );
        ocr.modulePcgs := pcgsN;
	ocr.generators:=ocr.generators mod NumeratorOfModuloPcgs(pcgsN);

        N     := SubgroupByPcgs( H, pcgsN ); 
        epi := GroupHomomorphismByImagesNC( H, F, AsList( pcgsH ), 
               Concatenation( Pcgs(F), List( [s..n-1], x -> One(F) ) ) );
        SetKernelOfMultiplicativeGeneralMapping( epi, N );

        # get module
        mats := LinearOperationLayer( H, pcgsH{[1..s-1]}, pcgsN );
        M    := GModuleByMats( mats, GF( p ) );
                  
        # compatible / inducible pairs
        if weights[s][2] = 1 then
            Info( InfoAutGrp, 2,"compute reduced gl ");
            B := NormalizingReducedGL( spec, s, n, M );

	    # A and B will not be used later, so it is no problem to 
	    # replace them by other groups with fewer generators
            B:=SubgroupNC(B,SmallGeneratingSet(B));
	    if HasPcgs(A) 
	     and Length(Pcgs(A))<Length(GeneratorsOfGroup(A)) then
	      as:=Size(A);
	      A:=Group(Pcgs(A),One(A));
	      SetSize(A,as);
	      SetIsGroupOfAutomorphismsFiniteGroup(A,true);
	    fi;

            D := DirectProduct( A, B ); 

            Info( InfoAutGrp, 2,"compute compatible pairs in group of size ",
                                  Size(A), " x ",Size(B),", ",
				  Length(GeneratorsOfGroup(D))," generators");
            C := CompatiblePairs( F, M, D );
        else
            Info( InfoAutGrp, 2,"compute reduced gl ");
            B := NormalizingReducedGL( spec, s, n, M );

	    # A and B will not be used later, so it is no problem to 
            B:=SubgroupNC(B,SmallGeneratingSet(B));
	    if HasPcgs(A) 
	     and Length(Pcgs(A))<Length(GeneratorsOfGroup(A)) then
	      as:=Size(A);
	      A:=Group(Pcgs(A),One(A));
	      SetIsGroupOfAutomorphismsFiniteGroup(A,true);
	      SetSize(A,as);
	    fi;

            D := DirectProduct( A, B ); 
            if weights[s][1] > 1 then
                Info( InfoAutGrp, 2,
                      "compute compatible pairs in group of size ",
                       Size(A), " x ",Size(B),", ",
		       Length(GeneratorsOfGroup(D))," generators");
                D := CompatiblePairs( F, M, D );
            fi;
            Info( InfoAutGrp,2, "compute inducible pairs in a group of size ",
                  Size( D ));
            C := InduciblePairs( D, epi, M );
        fi;
	Unbind(A);Unbind(B);Unbind(D);

        # lift
        Info( InfoAutGrp, 2, "lift back ");
        if Size( C ) = 1 then
            gens := [];
        elif CanEasilyComputePcgs( C ) then
            gens := Pcgs( C );
        else
            gens  := GeneratorsOfGroup( C );
        fi;
        autos := List( gens, x -> LiftInduciblePair( epi, x, M, weights[s] ) );
        
        # add H^1
        Info( InfoAutGrp, 2, "add derivations ");

        elms := BasisVectors( Basis( OCOneCocycles( ocr, false ) ) );
        for e in elms do
            list := ocr.cocycleToList( e );
            imgs := List( [1..s-1], x -> pcgsH[x] * list[x] );
            Append( imgs, pcgsH{[s..n-1]} );
            auto := GroupHomomorphismByImagesNC( H, H,
                        AsList( pcgsH ), imgs );
           
            SetIsBijective( auto, true );
            SetKernelOfMultiplicativeGeneralMapping(auto, TrivialSubgroup(H));

            Add( autos, auto );
        od;
        Info( InfoAutGrp, 2, Length(autos)," generating automorphisms");

        # set up for iteration
        F := ShallowCopy( H );
        A := GroupByGenerators( autos );
	SetIsGroupOfAutomorphismsFiniteGroup(A,true);
        SetSize( A, Size( C ) * p^Length(elms) );
        if Size(C) = 1 then
            rels := List( [1..Length(elms)], x-> p );
            TransferPcgsInfo( A, autos, rels );
        elif CanEasilyComputePcgs( C ) then
            rels := Concatenation( RelativeOrders(gens), 
                                   List( [1..Length(elms)], x-> p ) );
            TransferPcgsInfo( A, autos, rels );
        fi;
	Unbind(C);
	Unbind(gens);

        # if possible reduce the number of generators of A
        if Size( F ) <= 1000 and not CanEasilyComputePcgs( A ) then
            Info( InfoAutGrp, 2, "nice the gen set of A ");
            xset := ExternalSet( A, AsList( F ) );
            hom  := ActionHomomorphism( xset, "surjective");
            P    := Image( hom );
            if IsSolvableGroup( P ) then
                pcsA := List( Pcgs(P), x -> PreImagesRepresentative( hom, x ));
                TransferPcgsInfo( A, pcsA, RelativeOrders( Pcgs(P) ) );
            else
                imgs := SmallGeneratingSet( P );
                gens := List( imgs, x -> PreImagesRepresentative( hom, x ) );
                tmp  := Size( A );
                A := GroupByGenerators( gens, One( A ) );
                SetSize( A, tmp );
            fi;
        fi;
    od; 

    # the last step
    gensA := GeneratorsOfGroup( A );
    # try to reduce the generator set
    if HasPcgs(A) and Length(Pcgs(A))<Length(gensA) then
      gensA:=Pcgs(A);
    fi;

    iso   := GroupHomomorphismByImagesNC( F, G, Pcgs(F), spec );
    autos := [];
    for auto in gensA do
        imgs := List( Pcgs(F), x -> Image( iso, Image( auto, x ) ) );
        new  := GroupHomomorphismByImagesNC( G, G, spec, imgs );
        SetIsBijective( new, true );
        SetKernelOfMultiplicativeGeneralMapping(new, TrivialSubgroup(F));
        Add( autos, new );
    od;
    B := GroupByGenerators( autos );
    SetSize( B, Size(A) );
    return B;
end);

#############################################################################
##
#F AutomorphismGroupFrattFreeGroup( G )
##
InstallGlobalFunction(AutomorphismGroupFrattFreeGroup,function( G )
    local F, K, gensF, gensK, gensG, A, 
          iso, P, gensU, k, aut, U, hom, N, gensN,
          full, n, imgs, i, m, a, l, new, size, 
          pr, p, S, pcgsS, T, ocr, elms, e, list, B;

    # create fitting subgroup
    if HasSocle( G ) and HasSocleComplement( G ) then
        F := Socle( G );
        K := SocleComplement( G );
    else
        F := FittingSubgroup( G );
        K := ComplementClassesRepresentatives( G, F )[1];
    fi;
    gensF := Pcgs( F );
    gensK := Pcgs( K );
    gensG := Concatenation( gensK, gensF );

    # create automorhisms
    Info( InfoAutGrp, 2, "get aut grp of socle ");
    A := AutomorphismGroupAbelianGroup( F );

    # go over to perm rep
    Info( InfoAutGrp, 2, "compute perm rep ");
    iso := IsomorphismPermGroup( A );
    P   := Image( iso );

    # compute subgroup
    Info( InfoAutGrp, 2, "compute subgroup ");
    gensU := [];
    for k in gensK do
        imgs := List( gensF, y -> y ^ k );
        aut := GroupHomomorphismByImagesNC( F, F, gensF, imgs ); 
        # CheckAuto( aut );
        Add( gensU, Image( iso, aut ) );
    od;
    U := SubgroupNC( P, gensU );
    hom := GroupHomomorphismByImagesNC( K, U, gensK, gensU );


    # get normalizer
    Info( InfoAutGrp, 2, "compute normalizer ");
    N := Normalizer( P, U );
    gensN := GeneratorsOfGroup( N );

    # create automorphisms of G
    Info( InfoAutGrp, 2, "compute preimages ");
    full  := [];
    for n in gensN do
        imgs := [];
        for i in [1..Length(gensK)] do
            m := gensU[i]^n;
            a := PreImagesRepresentative( hom, m );
            Add( imgs, a );
        od;
        l := PreImagesRepresentative( iso, n );
        Append( imgs, List( gensF, x -> Image( l, x ) ) );
        new := GroupHomomorphismByImagesNC( G, G, gensG, imgs );
        SetIsBijective( new, true );
        SetKernelOfMultiplicativeGeneralMapping(new, TrivialSubgroup(G));
        Add( full, new );
    od;
    size := Size(N);

    # add derivations
    Info( InfoAutGrp, 2, "add derivations ");
    pr  := Set( FactorsInt( Size( F ) ) );
    for p in pr do

        # create subgroup
        S := SylowSubgroup( F, p );
        pcgsS := InducedPcgs( gensF, S );
        T := SubgroupNC( G, Concatenation( gensK, pcgsS ) );
        ocr := rec( group := T,
                    generators := gensK,
                    modulePcgs := pcgsS );

        # compute 1-cocycles
        elms := BasisVectors( Basis( OCOneCocycles( ocr, false ) ) );
        for e in elms do
            list := ocr.cocycleToList( e );
            imgs := List( [1..Length(gensK)], x -> gensK[x] * list[x] );
            Append( imgs, gensF );
            new := GroupHomomorphismByImagesNC( G, G, gensG, imgs );
            SetIsBijective( new, true );
            SetKernelOfMultiplicativeGeneralMapping(new, TrivialSubgroup(G));
            Add( full, new );
        od;
        size := size * ocr.char^Length(elms);
    od;

    # create automorphism group
    B := GroupByGenerators( full, IdentityMapping( G ) );
    SetSize( B, size );

    return B;
end);

# The following computes the automorphism group of
# a nilpotent group which is NOT a p-group. It computes
# the automorphism groups of each Sylow subgroup of G
# and then glues these together.
# For p-groups, either the standard GAP functionality, or
# that from the autpgrp package is used.
InstallGlobalFunction(AutomorphismGroupNilpotentGroup,function(G)
	local S, autS, gens, imgs, i, j, x, off, gensAutG, pcgsSi, autG;
	if IsAbelian(G) then
		return AutomorphismGroupAbelianGroup(G);
	fi;

	if not IsNilpotentGroup(G) or not IsFinite(G) then
		return fail;
	fi;

	if IsPGroup(G) then
		return fail;	# p-groups should be handled elsewhere
	fi;

	# Compute the Sylow subgroups of G; G is the direct product of
	# these, and Aut(G) is the direct product of the automorphism
	# groups of the Sylow subgroups.
	S := SylowSystem(G);

	# Compute the automorphism group of each of the p-groups
	autS := List(S, AutomorphismGroup);

	# Compute automorphism group for G from this
	gens := Concatenation(List(S, P->Pcgs(P)));
	off := 0;
	gensAutG := [];
	for i in [1..Length(S)] do
		# Convert the automorphisms of S[i] into automorphisms of G.
		pcgsSi := Pcgs(S[i]);
		for x in GeneratorsOfGroup(autS[i]) do
			imgs := ShallowCopy( gens );
			for j in [1..Length(pcgsSi)] do
				imgs[off + j] := Image(x, pcgsSi[j]);
			od;
			Add(gensAutG, GroupHomomorphismByImages(G, G, gens, imgs));
		od;
		off := off + Length(pcgsSi);
	od;

	# Now construct autG as "inner" direct product of all the autS
	autG := Group( gensAutG, IdentityMapping(G) );
	SetIsAutomorphismGroup(autG, true);
	SetIsGroupOfAutomorphismsFiniteGroup(autG, true);
	SetIsFinite(autG,true);

	return autG;
end );

