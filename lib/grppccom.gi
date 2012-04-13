#############################################################################
##
#W  grppccom.gi                  GAP Library                     Frank Celler
#W                                                           Alexander Hulpke
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the methods for complements in pc groups
##

BindGlobal("HomomorphismsSeries",function(G,h)
local r,img,i,gens,img2;
  r:=ShallowCopy(h);
  img:=Image(h[Length(h)],G);
  for i in [Length(h)-1,Length(h)-2..1] do
    gens:=GeneratorsOfGroup(img);
    img2:=Image(h[i],G);
    r[i]:=GroupHomomorphismByImagesNC(img,img2,gens,List(gens,j->
           Image(h[i],PreImagesRepresentative(h[i+1],j))));
    SetKernelOfMultiplicativeGeneralMapping(r[i],
       Image(h[i+1],KernelOfMultiplicativeGeneralMapping(h[i])));
    img:=img2;
  od;
  return r;
end);

# test function for relators
BindGlobal("OCTestRelators",function(ocr)
  if not IsBound(ocr.relators) then return true;fi;
  return ForAll(ocr.relators,i->ExponentsOfPcElement(ocr.generators,
     Product(List([1..Length(i.generators)],
             j->ocr.generators[i.generators[j]]^i.powers[j])))
     =List(ocr.generators,i->0));
end);

#############################################################################
##
#F  COAffineBlocks( <S>,<Sgens>,<mats>,<orbs> )
##
##  Divide the vectorspace  into blocks using  the  affine operations of  <S>
##  described by <mats>.  Return representative  for  these blocks and  their
##  normalizers in <S>.
##  if <orbs> is true orbits are kept.
##
InstallGlobalFunction( COAffineBlocks, function( S, Sgens,mats,orbs )
local   dim, p, nul, one, C, L, blt, B, O, Q, i, j, v, w, n, z, root,r;

  # The affine operation of <S> is described via <mats> as
  #
  #    ( lll 0 )
  #    ( lll 0 )
  #    ( ttt 1 )
  #
  # where l  describes  the   linear operation and  t  the  translation the
  # dimension  of   the  vectorspace  is of   dimension  one less  than the
  # matrices <mats>.
  #
  dim:=Length(mats[1]) - 1;
  one:=One(mats[1][1][1]);
  nul:=0 * one;
  root:=Z(Characteristic(one));
  p:=Characteristic( mats[1][1][1] );
  C:=List( [1..dim], x -> p );
  Q:=List( [0..dim-1], x -> p ^x );
  L:=[];
  for i  in [1..p-1]  do
    L[LogFFE( one * i,root ) + 1]:=i;
  od;

  # Make a boolean list of length <p> ^ <dim>.
  blt:=BlistList( [1..p ^ dim], [] );
  Info(InfoComplement,2,"COAffineBlocks: ", p^dim, " elements in H^1" );
  i:=1; # was: Position( blt, false );
  B:=[];

  # Run through this boolean list.
  while i <> fail  do
    v:=CoefficientsQadic(i-1,p);
    while Length(v)<dim do
      Add(v,0);
    od;
    v:=v*one;
    w:=ShallowCopy( v );
    ConvertToVectorRep(w,p);
    v:=Concatenation(v,[one]);
    ConvertToVectorRep(v,p);
    O:=OrbitStabilizer( S,v, Sgens,mats);
    for v  in O.orbit  do
        n:=1;
        for j  in [1..dim]  do
            z:=v[j];
            if z <> nul  then
                n:=n + Q[j] * L[LogFFE( z,root ) + 1];
            fi;
        od;
        blt[n]:=true;
    od;
    Info(InfoComplement,2,"COAffineBlocks: |block| = ", Length(O.orbit));
    r:=rec( vector:=w, stabilizer:=O.stabilizer );
    if orbs=true then r.orbit:=O.orbit;fi;
    Add( B, r);
    i:=Position( blt, false );
  od;
  Info(InfoComplement,2,"COAffineBlocks: ", Length( B ), " blocks found" );
  return B;

end );


#############################################################################
##
#F  CONextCentralizer( <ocr>, <S>, <H> )  . . . . . . . . . . . . . . . local
##
##  Correct the blockstabilizer and return the stabilizer of <H> in <S>
##
InstallGlobalFunction( CONextCentralizer, function( ocr, Spcgs, H )
local   gens,  pnt,  i;

  # Get the generators of <S> and correct them.
  Info(InfoComplement,2,"CONextCentralizer: correcting blockstabilizer" );
  gens:=ShallowCopy( Spcgs );
  pnt :=ocr.complementToCocycle( H );
  for i  in [1..Length( gens )]  do
    gens[i]:=gens[i] *
      OCConjugatingWord( ocr,
                       ocr.complementToCocycle( H ^ gens[i] ),
                 pnt );
  od;
  Info(InfoComplement,2,"CONextCentralizer: blockstabilizer corrected" );
  return ClosureGroup( ocr.centralizer, gens );

end );

#ocr is oc record, acts are elements that act via ^ on group elements, B
#is the result of BaseSteinitzVectors on the 1-cocycles in ocr.
InstallGlobalFunction(COAffineCohomologyAction,function(ocr,relativeGens,acts,B)
local tau, phi, mats;

  # Get  the  matrices describing the affine operations. The linear  part
  # of the  operation  is just conjugation of the entries of cocycle. The
  # translation are  commuators  with the  generators.  So check if <ocr>
  # has a small generating set. Use only these to form the commutators.

  # Translation: (.. h ..) -> (.. [h,c] ..)
  if IsBound( ocr.smallGeneratingSet )  then

    Error("not yet implemented");
    tau:=function( c )
    local   l,  i,  j,  z,  v;
      l:=[];
      for i  in ocr.smallGeneratingSet  do
	Add( l, Comm( ocr.generators[i], c ) );
      od;
      l:=ocr.listToCocycle( l );
      v:=ShallowCopy( B.factorzero );
      for i  in [1..Length(l)]  do
	if l[i] <> ocr.zero  then
	  z:=l[i];
	  j:=B.heads[i];
	  if j > 0  then
	    l:=l - z * B.factorspace[j];
	    v[j]:=z;
	  else
	    l:=l - z * B.subspace[-j];
	  fi;
	fi;
      od;
      IsRowVector( v );
      return v;
    end;

  else

    tau:=function( c )
    local   l,  i,  j,  z,  v;
      l:=[];
      for i  in relativeGens  do
	#Add( l, LeftQuotient(i,i^c));
	Add( l, Comm(i,c));
      od;
      l:=ocr.listToCocycle( l );
      v:=ListWithIdenticalEntries(Length(B.factorspace),ocr.zero);
      for i  in [1..Length(l)]  do
	if l[i] <> ocr.zero  then
	  z:=l[i];
	  j:=B.heads[i];
	  if j > 0  then
	    l:=l - z * B.factorspace[j];
	    v[j]:=z;
	  else
	    l:=l - z * B.subspace[-j];
	  fi;
	fi;
      od;
      IsRowVector( v );
      return v;
    end;
  fi;

  # Linear Operation: (.. hm ..) -> (.. (hm)^c ..)
  phi:=function( z, c )
  local   l,  i,  j,  v;
    l:=ocr.listToCocycle( List( ocr.cocycleToList(z), x -> x ^ c ) );
    v:=ListWithIdenticalEntries(Length(B.factorspace),ocr.zero);
    for i  in [1..Length( l )]  do
      if l[i] <> ocr.zero  then
        z:=l[i];
        j:=B.heads[i];
        if j > 0  then
          l:=l - z * B.factorspace[j];
          v[j]:=z;
        else
          l:=l - z * B.subspace[-j];
        fi;
      fi;
    od;
    IsRowVector( v );
    return v;
  end;

  # Construct the affine operations and blocks under them.
  mats:=AffineAction( acts,B.factorspace, phi, tau );
  Assert(2,ForAll(mats,i->ForAll(i,j->Length(i)=Length(j))));
  return mats;
end);


#############################################################################
##
#F  CONextCocycles( <cor>, <ocr>, <S> )    . . . . . . . . . . . . . . . . local
##
##  Get the next conjugacy classes of  complements  under  operation  of  <S>
##  using affine operation on the onecohomologygroup of <K>  and  <N>,  where
##  <ocr>:=rec( group:=<K>, module:=<N> ).
##
##  <ocr>  is a  record  as  described  in 'OCOneCocycles'.  The classes  are
##  returned as list of records rec( complement, centralizer ).
##
InstallGlobalFunction( CONextCocycles, function( cor, ocr, S )
local K, N, Z, SN, B, L, LL, SNpcgs, mats, i;

  # Try to split <K> over <M>, if it does not split return.
  Info(InfoComplement,2,"CONextCocycles: computing cocycles" );
  K:=ocr.group;
  N:=ocr.module;
  Z:=OCOneCocycles( ocr, true );
  if IsBool( Z )  then
      if IsBound( ocr.normalIn )  then
        Info(InfoComplement,2,"CONextCocycles: no normal complements" );
      else
        Info(InfoComplement,2,"CONextCocycles: no split extension" );
    fi;
    return [];
  fi;

  ocr.generators:=CanonicalPcgs(InducedPcgs(ocr.pcgs,ocr.complement));
  Assert(2,OCTestRelators(ocr));

  # If there is only one complement this is normal.
  if Dimension( Z ) = 0  then
      Info(InfoComplement,2,"CONextCocycles: group of cocycles is trivial" );
      K:=ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
        return [];
      else
       return [rec( complement:=K, centralizer:=S )];
      fi;
  fi;

  # If  the  one  cohomology  group  is trivial, there is only one class of
  # complements.  Correct  the  blockstabilizer and return. If we only want
  # normal complements, this case cannot happen, as cobounds are trivial.
  SN:=SubgroupNC( S, Filtered(GeneratorsOfGroup(S),i-> not i in N));
  if Dimension(ocr.oneCoboundaries)=Dimension(ocr.oneCocycles)  then
      Info(InfoComplement,2,"CONextCocycles: H^1 is trivial" );
      K:=ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
        return [];
      fi;
      S:=CONextCentralizer( ocr,
          InducedPcgs(cor.pcgs,SN),
	  ocr.complement);
    return [rec( complement:=K, centralizer:=S )];
  fi;

  # If <S> = <N>, there are  no new blocks  under the operation  of <S>, so
  # get  all elements of  the one cohomology  group and return. If  we only
  # want normal complements,  there also are no  blocks under the operation
  # of <S>.
  B:=BaseSteinitzVectors(BasisVectors(Basis(ocr.oneCocycles)),
			 BasisVectors(Basis(ocr.oneCoboundaries)));
  if Size(SN) = 1 or IsBound(ocr.normalIn)  then
    L:=VectorSpace(ocr.field,B.factorspace, B.factorzero);
    Info(InfoComplement,2,"CONextCocycles: ",Size(L)," complements found");
    if IsBound(ocr.normalIn)  then
      Info(InfoComplement,2,"CONextCocycles: normal complements, using H^1");
      LL:=[];
      if IsBound(cor.condition)  then
	for i  in L  do
	  K:=ocr.cocycleToComplement(i);
	  if cor.condition(cor, K)  then  
	    Add(LL, rec(complement:=K, centralizer:=S));
	  fi;
	od;
      else
	for i  in L  do
	  K:=ocr.cocycleToComplement(i);
	  Add(LL, rec(complement:=K, centralizer:=S));
	od;
      fi;
      return LL;
    else
      Info(InfoComplement,2,"CONextCocycles: S meets N, using H^1");
      LL:=[];
      if IsBound(cor.condition)  then
	for i  in L  do
	  K:=ocr.cocycleToComplement(i);
	  if cor.condition(cor, K)  then
	    S:=ocr.centralizer;
	    Add(LL, rec(complement:=K, centralizer:=S));
	  fi;
	od;
      else
	for i  in L  do
	  K:=ocr.cocycleToComplement(i);
	  S:=ocr.centralizer;
	  Add(LL, rec(complement:=K, centralizer:=S));
	od;
      fi;
      return LL;
    fi;
  fi;

  # The situation is as follows.
  #
  #  S           As <N>  does act trivial  on  the  onecohomology
  #   \   K        group,  compute first blocks of this group under
  #    \ / \       the operation of  <S>/<N>. But  as <S>/<N>  acts
  #     N   ?      affine,  this can be done using affine operation
  #      \ /       (given as matrices).
  #       1

  SNpcgs:=InducedPcgs(cor.pcgs,SN);
  mats:=COAffineCohomologyAction(ocr,ocr.generators,SNpcgs,B);

  L :=COAffineBlocks( SN, SNpcgs,mats,false );
  Info(InfoComplement,2,"CONextCocycles:", Length( L ), " complements found" );

  # choose a representative from each block and correct the blockstab
  LL:=[];
  for i  in L  do
    K:=ocr.cocycleToComplement(i.vector*B.factorspace);
      if not IsBound(cor.condition) or cor.condition(cor, K)  then
      if Z = []  then
        S:=ClosureGroup( ocr.centralizer, i.stabilizer );
      else
        S:=CONextCentralizer(ocr,
	     InducedPcgs(cor.pcgs,
	                 i.stabilizer), K);
      fi;
      Add(LL, rec(complement:=K, centralizer:=S));
      fi;
  od;
  return LL;

end );


#############################################################################
##
#F  CONextCentral( <cor>, <ocr>, <S> )     . . . . . . . . . . . . . . . . local
##
##  Get the conjugacy classes of complements in case <ocr.module> is central.
##
InstallGlobalFunction( CONextCentral, function( cor, ocr, S )
local   z,K,N,zett,SN,B,L,tau,gens,imgs,A,T,heads,dim,s,v,j,i,root;

  # Try to split <ocr.group>
  K:=ocr.group;
  N:=ocr.module;

  # If  <K>  is no split extension of <N> return the trivial list, as there
  # are  no  complements.  We  compute  the cocycles only if the extenstion
  # splits.
  zett:=OCOneCocycles( ocr, true );
  if IsBool( zett )  then
      if IsBound( ocr.normalIn )  then
        Info(InfoComplement,2,"CONextCentral: no normal complements" );
      else
        Info(InfoComplement,2,"CONextCentral: no split extension" );
    fi;
    return [];
  fi;

  ocr.generators:=CanonicalPcgs(InducedPcgs(ocr.pcgs,ocr.complement));
  Assert(2,OCTestRelators(ocr));

  # if there is only one complement it must be normal
  if Dimension(zett) = 0  then
      Info(InfoComplement,2,"CONextCentral: Z^1 is trivial");
      K:=ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
        return [];
      else
      return [rec(complement:=K, centralizer:=S)];
      fi;
  fi;

  # If  the  one  cohomology  group  is trivial, there is only one class of
  # complements.  Correct  the  blockstabilizer and return. If we only want
  # normal complements, this cannot happen, as the cobounds are trivial.
  SN:=SubgroupNC( S, Filtered(GeneratorsOfGroup(S),i-> not i in N));
  if Dimension(ocr.oneCoboundaries)=Dimension(ocr.oneCocycles)  then
      Info(InfoComplement,2,"CONextCocycles: H^1 is trivial" );
      K:=ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
        return [];
      else
        S:=CONextCentralizer( ocr,
	 InducedPcgs(cor.pcgs,SN),ocr.complement);
      return [rec(complement:=K, centralizer:=S)];
      fi;
  fi;

  # If  <S>  =  <N>, there are no new blocks under the operation of <S>, so
  # get  all elements of the onecohomologygroup and return. If we only want
  # normal  complements,  there  also  are no blocks under the operation of
  # <S>.
  B:=BaseSteinitzVectors(BasisVectors(Basis(ocr.oneCocycles)),
			 BasisVectors(Basis(ocr.oneCoboundaries)));
  if Size(SN)=1 or IsBound( ocr.normalIn )  then
      if IsBound( ocr.normalIn )  then
        Info(InfoComplement,2,"CONextCocycles: normal complements, using H^1");
      else
        Info(InfoComplement,2,"CONextCocycles: S meets N, using H^1" );
        S:=ocr.centralizer;
    fi;
      L:=VectorSpace(ocr.field,B.factorspace, B.factorzero);
      T:=[];
      for i  in L  do
        K:=ocr.cocycleToComplement(i);
        if not IsBound(cor.condition) or cor.condition(cor, K)  then
            Add(T, rec(complement:=K,  centralizer:=S));
      fi;
      od;
      Info(InfoComplement,2,"CONextCocycles: ",Length(T)," complements found" );
      return T;
  fi;

  # The  conjugacy  classes  of  complements  are cosets of the cocycles of
  # 0^S. If 'smallGeneratingSet' is given, do not use this gens.

  # Translation: (.. h ..) -> (.. [h,c] ..)
  if IsBound( ocr.smallGeneratingSet )  then
      tau:=function( c )
        local   l;
        l:=[];
        for i  in ocr.smallGeneratingSet  do
            Add( l, Comm( ocr.generators[i], c ) );
        od;
        return ocr.listToCocycle( l );
    end;
  else
      tau:=function( c )
        local   l;
        l:=[];
        for i  in ocr.generators  do
            Add( l, Comm( i, c ) );
        od;
        return ocr.listToCocycle( l );
    end;
  fi;
  gens:=InducedPcgs(cor.pcgs,SN);
  imgs:=List( gens, tau );

  # Now get a base for the subspace 0^S. For those zero  images which are
  # not part of a base a generators of the stabilizer can be generated.
  #   B   holds the base,
  #   A   holds the correcting elements for the base vectors,
  #   T   holds the stabilizer generators.
  dim:=Length( imgs[1] );
  A:=[];
  B:=[];
  T:=[];
  heads:=ListWithIdenticalEntries(dim,0);

  root:=Z(ocr.char);
  # Get the base starting with the last one and go up.
  for i  in Reversed( [1..Length(imgs)] )  do
    s:=gens[i];
    v:=imgs[i];
    j:=1;
    # was:while j <= dim and IntFFE(v[j]) = 0  do
    while j <= dim and v[j] = ocr.zero  do
      j:=j + 1;
    od;
    while j <= dim and heads[j] <> 0  do
      z:=v[j] / B[heads[j]][j];
      if z <> 0*z  then
	s:=s / A[heads[j]] ^ ocr.logTable[LogFFE(z,root)+1];
      fi;
      v:=v - v[j] / B[heads[j]][j] * B[heads[j]];
      # was: while j <= dim and IntFFE(v[j]) = 0  do
      while j <= dim and v[j] = ocr.zero  do
	j:=j + 1;
      od;
    od;
    if j > dim  then
      Add( T, s );
    else
      Add( B, v );
      Add( A, s );
      heads[j]:=Length( B );
    fi;
  od;

  # So  <T>  now  holds a reversed list of generators for a stabilizer. <B>
  # is  a  base for 0^<S> and <cocycles>/0^<S> are the conjugacy classes of
  # complements.
  S:=ClosureGroup(N,T);
  if B = []  then
    B:=zett;
  else
    B:=BaseSteinitzVectors(BasisVectors(Basis(zett)),B);
    B:=VectorSpace(ocr.field,B.factorspace, B.factorzero);
  fi;
  L:=[];
  for i  in B  do
      K:=ocr.cocycleToComplement(i);
      if not IsBound(cor.condition) or cor.condition(cor, K)  then
        Add(L, rec(complement:=K, centralizer:=S));
      fi;
  od;
  Info(InfoComplement,2,"CONextCentral: ", Length(L), " complements found");
  return L;

end );


#############################################################################
##
#F  CONextComplements( <cor>, <S>, <K>, <M> ) . . . . . . . . . . . . . local
##  S: fuser, K: Complements in, M: Complements to
##
InstallGlobalFunction( CONextComplements, function( cor, S, K, M )
local   p, ocr;

  Assert(1,IsSubgroup(K,M));

  if IsTrivial(M)  then
    if IsBound(cor.condition) and not cor.condition(cor, K)  then
      return [];
    else
    return [rec( complement:=K, centralizer:=S )];
    fi;
  elif IsEmpty(Intersection( Factors(Size(M)), Factors(Index(K,M))))  then

    # If <K> and <M> are coprime, <K> splits.
    Info(InfoComplement,2,"CONextComplements: coprime case, <K> splits" );
    ocr:=rec( group:=K, module:=M,
	modulePcgs:=InducedPcgs(cor.pcgs,M), 
                pcgs:=cor.pcgs, inPcComplement:=true);

    if IsBound( cor.generators )  then
      ocr.generators:=cor.generators;
      Assert(2,OCTestRelators(ocr));
      Assert(1,IsModuloPcgs(ocr.generators));
    fi;
    if IsBound( cor.smallGeneratingSet )  then
      ocr.smallGeneratingSet:=cor.smallGeneratingSet;
      ocr.generatorsInSmall :=cor.generatorsInSmall;
    elif IsBound( cor.primes )  then
      p:=Factors(Size( M.generators))[1];
      if p in cor.primes  then
        ocr.pPrimeSet:=cor.pPrimeSets[Position( cor.primes, p )];
      fi;
    fi;
    if IsBound( cor.relators )  then
      ocr.relators:=cor.relators;
      Assert(2,OCTestRelators(ocr));
    fi;

    #was: ocr.complement:=CoprimeComplement( K, M );
    OCOneCocycles( ocr, true );

    OCOneCoboundaries( ocr );
    if   IsBound( cor.normalComplements )
         and cor.normalComplements
         and Dimension( ocr.oneCoboundaries ) <> 0 then
      return [];
    else
      K:=ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
	return [];
      fi;
      S:=SubgroupNC( S, Filtered(GeneratorsOfGroup(S),i->not i in M));
      S:=CONextCentralizer( ocr,
	InducedPcgs(cor.pcgs,S), K );
      return [rec( complement:=K, centralizer:=S )];
    fi;
  else

    # In the non-coprime case, we must construct cocycles.
    ocr:=rec( group:=K, module:=M,
      modulePcgs:=InducedPcgs(cor.pcgs,M),
                pcgs:=cor.pcgs, inPcComplement:=true);

    if IsBound( cor.generators )  then
      ocr.generators:=cor.generators;
      Assert(2,OCTestRelators(ocr));
      Assert(1,IsModuloPcgs(ocr.generators));
    fi;
    if IsBound( cor.normalComplement ) and cor.normalComplements  then
      ocr.normalIn:=S;
    fi;

#    if IsBound( cor.normalSubgroup )  then
#      L:=cor.normalSubgroup( S, K, M );
#      if IsTrivial(L) = []  then
#	return CONextCocycles(cor, ocr, S);
#      else
#	return CONextNormal(cor, ocr, S, L);
#      fi;
#    else

    if IsBound( cor.smallGeneratingSet )  then
	   ocr.smallGeneratingSet:=cor.smallGeneratingSet;
      ocr.generatorsInSmall :=cor.generatorsInSmall;
    elif IsBound( cor.primes )  then
      p:=Factors(Size( M.generators))[1];
      if p in cor.primes  then
	ocr.pPrimeSet:=cor.pPrimeSets[Position(cor.primes,p)];
      fi;
    fi;
    if IsBound( cor.relators )  then
      ocr.relators:=cor.relators;
      Assert(2,OCTestRelators(ocr));
    fi;
    if  ( cor.useCentral and IsCentral( Parent(M), M ) )
     or ( cor.useCentralSK and IsCentral(S,M) and IsCentral(K,M) ) then
      return CONextCentral(cor, ocr, S);
    else
      return CONextCocycles(cor, ocr, S);
    fi;

  fi;

end );


#############################################################################
##
#F  COComplements( <cor>, <G>, <N>, <all> ) . . . . . . . . . . . . . . local
##
##  Compute the complements in <G> of the normal subgroup N[1]. N is a list
##  of normal subgroups of G s.t. N[i]/N[i+1] is elementary abelian.
##  If  <all>  is  true, find all (conjugacy classes of) complements.
##  Otherwise   try  to find  just  one complement.
##
InstallGlobalFunction( COComplements, function( cor, G, E, all )
local r,a,a0,FG,nextStep,C,found,i,time,hpcgs,ipcgs;

  # give some information and start timing
  Info(InfoComplement,2,"Complements: initialize factorgroups" );
  time:=Runtime();

  # we only need the series beginning from position <n>
  r:=Length(E);

  # Construct the homomorphisms <a>[i] = <G>/<E>[i+1] -> <G>/<E>[i].


  a0:=[];
  for i in [1..Length(E)-1] do
    # to get compatibility we must build the natural homomorphisms
    # ourselves.
    ipcgs:=InducedPcgs(cor.home,E[i]);
    hpcgs:=cor.home mod ipcgs;
    FG:=PcGroupWithPcgs(hpcgs);
    a:=GroupHomomorphismByImagesNC(G,FG,cor.home,
      Concatenation(FamilyPcgs(FG),List(ipcgs,i->One(FG))));
    SetKernelOfMultiplicativeGeneralMapping( a, E[i] );
    Add(a0,a);
  od;

  # hope that NHBNS deals with the trivial subgroup sensibly
#  a0:=List(E{[1..Length(E)-1]},i->NaturalHomomorphismByNormalSubgroup(G,i));

  hpcgs:=List([1..Length(E)-1],
           i->PcgsByPcSequenceNC(FamilyObj(One(Image(a0[i]))),
	      List(cor.home mod InducedPcgs(cor.home,E[i]),
	           j->Image(a0[i],j))));
  Add(hpcgs,cor.home);
  cor.hpcgs:=hpcgs;
  a :=HomomorphismsSeries( G, a0 );
  a0:=a0[1];

  # <FG> contains the factorgroups <G>/<E>[1], ..., <G>/<E>[<r>].
  FG:=List( a, Range );
  Add( FG, G );

  # As all entries in <cor> are optional, initialize them if they are not
  # present in <cor> with the following defaults.
  #
  #   'generators'        : standard generators
  #   'relators'        : pc-relators
  #   'useCentral'        : false
  #   'useCentralSK'      : false
  #   'normalComplements'     : false
  #
  if not IsBound( cor.useCentral )  then
    cor.useCentral:=false;
  fi;
  if not IsBound( cor.useCentralSK )  then
    cor.useCentralSK:=false;
  fi;
  if not IsBound( cor.normalComplements )  then
    cor.normalComplements:=false;
  fi;
  if IsBound( cor.generators )  then
    cor.generators:=
      InducedPcgsByGeneratorsNC(cor.hpcgs[1],
                                List(cor.generators,x->Image(a0,x)));
  else
    cor.generators:=CanonicalPcgs( InducedPcgs(cor.hpcgs[1],FG[1] ));
  fi;
  cor.gele:=Length(cor.generators);
  Assert(1,cor.generators[1] in FG[1]);

  #if not IsBound( cor.normalSubgroup )  then
  cor.group :=FG[1];
  cor.module:=TrivialSubgroup( FG[1] );
  cor.modulePcgs:=InducedPcgs(cor.hpcgs[1],cor.module);
  OCAddRelations(cor,cor.generators);
  #fi;
  Assert(2,OCTestRelators(cor));

  # The  following  function will be called recursively in order to descend
  # the tree and reach a complement.  <nr> is the current level.
  # it lifts the complement K over the nr-th step and fuses under the action
  # of (the full preimage of) S
  nextStep:=function( S, K, nr )
  local   M,  NC,  X;

    # give information about the level reached
    Info(InfoComplement,1,"Complements: reached level ", nr, " of ", r);

    # if this is the last level we have a complement, add it to <C>
    if nr = r  then
      Add( C, rec( complement:=K, centralizer:=S ) );
        Info(InfoComplement,2,"Complements: next class found, ",
             "total ", Length(C), " complement(s), ",
                 "time=", Runtime() - time);
      found:=true;

      # otherwise try to split <K> over <M> = <FE>[<nr>+1]
    else
      S:=PreImage( a[nr], S );
      M:=KernelOfMultiplicativeGeneralMapping(a[nr]);
      cor.module:=M;
      cor.pcgs:=cor.hpcgs[nr+1];
      cor.modulePcgs:=InducedPcgs(cor.pcgs,M);

      # we cannot take the 'PreImage' as this changes the gens

cor.oldK:=K;
cor.oldgens:=cor.generators;

      K:=PreImage(a[nr],K);
      cor.generators:=CanonicalPcgs(InducedPcgs(cor.pcgs,K));
      cor.generators:=cor.generators mod InducedPcgs(cor.pcgs,cor.module);
      Assert(1,Length(cor.generators)=cor.gele);
      Assert(2,OCTestRelators(cor));

      # now 'CONextComplements' will try to find the complements
      NC:=CONextComplements( cor, S, K, M );
Assert(1,cor.pcgs=cor.hpcgs[nr+1]);

      # try to step down as fast as possible
      for X  in NC  do
	Assert(2,OCTestRelators(rec(
	   generators:=CanonicalPcgs(InducedPcgs(cor.hpcgs[nr+1],X.complement)),
	   relators:=cor.relators)));
	nextStep( X.centralizer, X.complement, nr+1 );
	if found and not all  then
	  return;
	fi;
      od;
    fi;
  end;

  # in <C> we will collect the complements at the last step
  C:=[];

  # ok, start 'nextStep'  with trivial module
  Info(InfoComplement,1,"  starting search, time=",Runtime()-time);
  found:=false;
  nextStep( TrivialSubgroup( FG[1] ),
            SubgroupNC( FG[1], cor.generators ), 1 );

  # some timings
  Info(InfoComplement,1,"Complements: ",Length(C)," complement(s) found, ",
           "time=", Runtime()-time );

  # add the normalizer
  Info(InfoComplement,2,"Complements: adding normalizers" );
  for i  in [1..Length(C)]  do
    C[i].normalizer:=ClosureGroup( C[i].centralizer,
			C[i].complement );
  od;
  return C;

end );


#############################################################################
##
#M  COComplementsMain( <G>, <N>, <all>, <fun> )  . . . . . . . . . . . . . local
##
##  Prepare arguments for 'ComplementCO'.
##
InstallGlobalFunction( COComplementsMain, function( G, N, all, fun )
local   H, E,  cor,  a,  i,  fun2,pcgs,home;

  home:=HomePcgs(G);
  pcgs:=home;
  # Get the elementary abelian series through <N>.
  E:=ElementaryAbelianSeriesLargeSteps( [G,N,TrivialSubgroup(G)] );
  E:=Filtered(E,i->IsSubset(N,i));

  # we require that the subgroups of E are subgroups of the Pcgs-Series

  if Length(InducedPcgs(home,G))<Length(home) # G is not the top group
     # nt not in series
     or ForAny(E,i->Size(i)>1 and
       not i=SubgroupNC(G,home{[DepthOfPcElement(home,
                                    InducedPcgs(home,i)[1])..Length(home)]}))
     then

    Info(InfoComplement,2,"Computing better pcgs" );
    # create a better pcgs

    pcgs:=InducedPcgs(home,G) mod InducedPcgs(home,N);
    for i in [2..Length(E)] do
      pcgs:=Concatenation(pcgs,
         InducedPcgs(home,E[i-1]) mod InducedPcgs(home,E[i]));
    od;

    if not IsPcGroup(G) then
      # for non-pc groups arbitrary pcgs may become unfeasibly slow, so
      # convert to a pc group in this case
      pcgs:=PcgsByPcSequenceCons(IsPcgsDefaultRep,
	IsPcgs and IsPrimeOrdersPcgs,FamilyObj(One(G)),pcgs,[]);

      H:=PcGroupWithPcgs(pcgs);
      home:=pcgs; # this is our new home pcgs
      a:=GroupHomomorphismByImagesNC(G,H,pcgs,GeneratorsOfGroup(H));
      E:=List(E,i->Image(a,i));
      if IsFunction(fun) then
	fun2:=function(x)
		return fun(PreImage(a,x));
	      end;
      else
	pcgs:=home;
	fun2:=fun;
      fi;
      Info(InfoComplement,2,"transfer back" );
      return List( COComplementsMain( H, Image(a,N), all, fun2 ), x -> rec(
	    complement :=PreImage( a, x.complement ),
	      centralizer:=PreImage( a, x.centralizer ) ) );
    else
      pcgs:=PcgsByPcSequenceNC(FamilyObj(home[1]),pcgs);
      IsPrimeOrdersPcgs(pcgs); # enforce setting
      H:= GroupByGenerators( pcgs );
      home:=pcgs;
    fi;

  fi;

  # if <G> and <N> are coprime <G> splits over <N>
  if false and Intersection( Factors(Size(N)), Factors(Index(G,N))) = []  then
      Info(InfoComplement,2,"Complements: coprime case, <G> splits" );
      cor:=rec();

  # otherwise we compute a hall system for <G>/<N>
  else
    #AH
    #Info(InfoComplement,2,"Complements: computing p prime sets" );
    #a  :=NaturalHomomorphism( G, G / N );
    #cor:=PPrimeSetsOC( Image( a ) );
    #cor.generators:=List( cor.generators, x -> 
    #                    PreImagesRepresentative( a, x ) );
    cor:=rec(home:=home,generators:=pcgs mod InducedPcgs(pcgs,N));
    cor.useCentralSK:=true;
  fi;

  # if a condition was given use it
  if IsFunction(fun)  then cor.condition:=fun;  fi;

  # 'COComplements' will do most of the work
  return COComplements( cor, G, E, all );

end );


InstallMethod( ComplementClassesRepresentativesSolvableNC, "pc groups", 
  IsIdenticalObj, [CanEasilyComputePcgs,CanEasilyComputePcgs], 0,
function(G,N)
  return List( COComplementsMain(G, N, true, false), G -> G.complement );
end);


#############################################################################
##
#M  ComplementClassesRepresentatives( <G>, <N> ) . . . .  find all complement
##
InstallMethod( ComplementClassesRepresentatives, "solvable normal subgroup",
  IsIdenticalObj, [IsGroup,IsGroup],0,
function( G, N )
  local   C;

  # if <G> and <N> are equal the only complement is trivial
  if G = N  then
      C:=[TrivialSubgroup(G)];

  # if <N> is trivial the only complement is <G>
  elif Size(N) = 1 then
      C:=[G];

  elif not IsSolvableGroup(N) then
    TryNextMethod();
  else
    # otherwise we have to work
    C:=ComplementClassesRepresentativesSolvableNC(G,N);
  fi;

  # return what we have found
  return C;

end);


#############################################################################
##
#M  ComplementcClassesRepresentatives( <G>, <N> )
##
InstallMethod( ComplementClassesRepresentatives,
  "tell that the normal subgroup must be solvable",IsIdenticalObj,
  [IsGroup,IsGroup],-2*RankFilter(IsGroup),
function( G, N )
  if IsSolvableGroup(N) then
    TryNextMethod();
  fi;
  Error("Cannot compute complement classes for nonsolvable normal subgroups");
end);

#############################################################################
##
#E  grppccom.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

