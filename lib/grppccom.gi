#############################################################################
##
#W  grppccom.gi                  GAP Library                     Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for complements in pc groups
##
Revision.grppccom_gi :=
    "@(#)$Id$";

HomomorphismsSeries := function(G,h)
local r,img,i,gens,img2;
  r:=ShallowCopy(h);
  img:=Image(h[Length(h)],G);
  for i in [Length(h)-1,Length(h)-2..1] do
    gens:=GeneratorsOfGroup(img);
    img2:=Image(h[i],G);
    r[i]:=GroupHomomorphismByImages(img,img2,gens,List(gens,j->
           Image(h[i],PreImagesRepresentative(h[i+1],j))));
    SetKernelOfMultiplicativeGeneralMapping(r[i],
       Image(h[i+1],KernelOfMultiplicativeGeneralMapping(h[i])));
    img:=img2;
  od;
  return r;
end;

#############################################################################
##
#F  COAffineBlocks( <S>, <mats> ) . . . . . . . . . . . . . . . . . . . local
##
##  Divide the vectorspace  into blocks using  the  affine operations of  <S>
##  described by <mats>.  Return representative  for  these blocks and  their
##  normalizers in <S>.
##
COAffineBlocks := function( S, mats )
  local   dim, p, nul, one, C, L, blt, B, O, Q, i, j, v, w, n, z, root;

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
  dim := Length(mats[1]) - 1;
  one := One(mats[1][1][1]);
  nul := 0 * one;
  root:=Z(Characteristic(one));
  p := Characteristic( mats[1][1][1] );
  C := List( [1..dim], x -> p );
  Q := List( [0..dim-1], x -> p ^x );
  L := [];
  for i  in [1..p-1]  do
    L[LogFFE( one * i,root ) + 1] := i;
  od;

  # Make a boolean list of length <p> ^ <dim>.
  blt := BlistList( [1..p ^ dim], [] );
  Info(InfoComplement,2,"COAffineBlocks: ", p^dim, " elements in H^1" );
  i := 1; # was: Position( blt, false );
  B := [];

  # Run through this boolean list.
  while i <> fail  do
    v := CoefficientsQadic(i-1,p);
    while Length(v)<dim do
      Add(v,0);
    od;
    v:=v*one;
    w := ShallowCopy( v );
    Add( v, one );
    O := OrbitStabilizer( S,v, Pcgs(S),mats);
    for v  in O.orbit  do
        n := 1;
        for j  in [1..dim]  do
            z := v[j];
            if z <> nul  then
                n := n + Q[j] * L[LogFFE( z,root ) + 1];
            fi;
        od;
        blt[n] := true;
    od;
    Info(InfoComplement,2,"COAffineBlocks: |block| = ", Length(O.orbit));
    Add( B, rec( vector := w, stabilizer := O.stabilizer ) );
    i := Position( blt, false );
  od;
  Info(InfoComplement,2,"COAffineBlocks: ", Length( B ), " blocks found" );
  return B;

end;


#############################################################################
##
#F  CONextCentralizer( <ocr>, <S>, <H> )  . . . . . . . . . . . . . . . local
##
##  Correct the blockstabilizer and return the stabilizer of <H> in <S>
##
CONextCentralizer := function( ocr, S, H )
  local   gens,  pnt,  i;

  # Get the generators of <S> and correct them.
  Info(InfoComplement,2,"CONextCentralizer: correcting blockstabilizer" );
  gens := ShallowCopy( InducedPcgsWrtHomePcgs( S ) );
  pnt  := ocr.complementToCocycle( H );
  for i  in [1..Length( gens )]  do
    gens[i] := gens[i] *
      OCConjugatingWord( ocr,
                       ocr.complementToCocycle( H ^ gens[i] ),
                 pnt );
  od;
  Info(InfoComplement,2,"CONextCentralizer: blockstabilizer corrected" );
  return ClosureGroup( ocr.centralizer, gens );

end;


#############################################################################
##
#F  CONextCocycles( <cor>, <ocr>, <S> )    . . . . . . . . . . . . . . . . local
##
##  Get the next conjugacy classes of  complements  under  operation  of  <S>
##  using affine operation on the onecohomologygroup of <K>  and  <N>,  where
##  <ocr> := rec( group := <K>, module := <N> ).
##
##  <ocr>  is a  record  as  described  in 'OCOneCocycles'.  The classes  are
##  returned as list of records rec( complement, centralizer ).
##
CONextCocycles := function( cor, ocr, S )
  local   K, N, Z, SN, B, L, LL, tau, phi, mats, i;

  # Try to split <K> over <M>, if it does not split return.
  Info(InfoComplement,2,"CONextCocycles: computing cocycles" );
  K := ocr.group;
  N := ocr.module;
  Z := OCOneCocycles( ocr, true );
  if IsBool( Z )  then
      if IsBound( ocr.normalIn )  then
        Info(InfoComplement,2,"CONextCocycles: no normal complements" );
      else
        Info(InfoComplement,2,"CONextCocycles: no split extension" );
    fi;
    return [];
  fi;

  ocr.generators := GeneratorsOfGroup(ocr.complement);

  # If there is only one complement this is normal.
  if Dimension( Z ) = 0  then
      Info(InfoComplement,2,"CONextCocycles: group of cocycles is trivial" );
      K := ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
        return [];
      else
       return [rec( complement := K, centralizer := S )];
      fi;
  fi;

  # If  the  one  cohomology  group  is trivial, there is only one class of
  # complements.  Correct  the  blockstabilizer and return. If we only want
  # normal complements, this case cannot happen, as cobounds are trivial.
  SN := Subgroup( S, Filtered(GeneratorsOfGroup(S),i-> not i in N));
  if Dimension(ocr.oneCoboundaries)=Dimension(ocr.oneCocycles)  then
      Info(InfoComplement,2,"CONextCocycles: H^1 is trivial" );
      K := ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
        return [];
      fi;
      S := CONextCentralizer( ocr, SN, ocr.complement );
    return [rec( complement := K, centralizer := S )];
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
      LL := [];
      if IsBound(cor.condition)  then
	for i  in L  do
	  K := ocr.cocycleToComplement(i);
	  if cor.condition(cor, K)  then  
	    Add(LL, rec(complement := K, centralizer := S));
	  fi;
	od;
      else
	for i  in L  do
	  K := ocr.cocycleToComplement(i);
	  Add(LL, rec(complement := K, centralizer := S));
	od;
      fi;
      return LL;
    else
      Info(InfoComplement,2,"CONextCocycles: S meets N, using H^1");
      LL := [];
      if IsBound(cor.condition)  then
	for i  in L  do
	  K := ocr.cocycleToComplement(i);
	  if cor.condition(cor, K)  then
	    S := ocr.centralizer;
	    Add(LL, rec(complement := K, centralizer := S));
	  fi;
	od;
      else
	for i  in L  do
	  K := ocr.cocycleToComplement(i);
	  S := ocr.centralizer;
	  Add(LL, rec(complement := K, centralizer := S));
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
  # Get  the  matrices describing the affine operations. The linear  part
  # of the  operation  is just conjugation of the entries of cocycle. The
  # translation are  commuators  with the  generators.  So check if <ocr>
  # has a small generating set. Use only these to form the commutators.

  # Translation: (.. h ..) -> (.. [h,c] ..)
  if IsBound( ocr.smallGeneratingSet )  then

    tau := function( c )
    local   l,  i,  j,  z,  v;
      l := [];
      for i  in ocr.smallGeneratingSet  do
	Add( l, Comm( ocr.generators[i], c ) );
      od;
      l := ocr.listToCocycle( l );
      v := ShallowCopy( B.factorzero );
      for i  in [1..Length(l)]  do
	if IntFFE(l[i]) <> 0  then
	  z := l[i];
	  j := B.heads[i];
	  if j > 0  then
	    l := l - z * B.factorspace[j];
	    v[j] := z;
	  else
	    l := l - z * B.subspace[-j];
	  fi;
	fi;
      od;
      IsRowVector( v );
      return v;
    end;

  else

    tau := function( c )
    local   l,  i,  j,  z,  v;
      l := [];
      for i  in ocr.generators  do
	Add( l, Comm( i, c ) );
      od;
      l := ocr.listToCocycle( l );
      v := ShallowCopy( B.factorzero );
      for i  in [1..Length(l)]  do
	if IntFFE(l[i]) <> 0  then
	  z := l[i];
	  j := B.heads[i];
	  if j > 0  then
	    l := l - z * B.factorspace[j];
	    v[j] := z;
	  else
	    l := l - z * B.subspace[-j];
	  fi;
	fi;
      od;
      IsRowVector( v );
      return v;
    end;
  fi;

  # Linear Operation: (.. hm ..) -> (.. (hm)^c ..)
  phi := function( z, c )
  local   l,  i,  j,  v;
    l := ocr.listToCocycle( List( ocr.cocycleToList( z ), x -> x ^ c ) );
    v := ShallowCopy( B.factorzero );
    for i  in [1..Length( l )]  do
      if IntFFE(l[i]) <> 0  then
        z := l[i];
        j := B.heads[i];
        if j > 0  then
          l := l - z * B.factorspace[j];
          v[j] := z;
        else
          l := l - z * B.subspace[-j];
        fi;
      fi;
    od;
    IsRowVector( v );
    return v;
  end;

  # Construct the affine operations and blocks under them.
  mats := AffineOperation( Pcgs(SN),B.factorspace, phi, tau );
  L  := COAffineBlocks( SN, mats );
  Info(InfoComplement,2,"CONextCocycles:", Length( L ), " complements found" );

  # choose a representative from each block and correct the blockstab
  LL := [];
  for i  in L  do
    K := ocr.cocycleToComplement(i.vector*B.factorspace);
      if not IsBound(cor.condition) or cor.condition(cor, K)  then
      if Z = []  then
        S := ClosureGroup( ocr.centralizer, i.stabilizer );
      else
        S := CONextCentralizer(ocr, i.stabilizer, K);
      fi;
      Add(LL, rec(complement := K, centralizer := S));
      fi;
  od;
  return LL;

end;


#############################################################################
##
#F  CONextCentral( <cor>, <ocr>, <S> )     . . . . . . . . . . . . . . . . local
##
##  Get the conjugacy classes of complements in case <ocr.module> is central.
##
CONextCentral := function( cor, ocr, S )
  local   z,K,N,zett,SN,B,L,tau,gens,imgs,A,T,heads,dim,s,v,j,i,root;

  # Try to split <ocr.group>
  K := ocr.group;
  N := ocr.module;

  # If  <K>  is no split extension of <N> return the trivial list, as there
  # are  no  complements.  We  compute  the cocycles only if the extenstion
  # splits.
  zett := OCOneCocycles( ocr, true );
  if IsBool( zett )  then
      if IsBound( ocr.normalIn )  then
        Info(InfoComplement,2,"CONextCentral: no normal complements" );
      else
        Info(InfoComplement,2,"CONextCentral: no split extension" );
    fi;
    return [];
  fi;

  ocr.generators := GeneratorsOfGroup(ocr.complement);

  # if there is only one complement it must be normal
  if Dimension(zett) = 0  then
      Info(InfoComplement,2,"CONextCentral: Z^1 is trivial");
      K := ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
        return [];
      else
      return [rec(complement := K, centralizer := S)];
      fi;
  fi;

  # If  the  one  cohomology  group  is trivial, there is only one class of
  # complements.  Correct  the  blockstabilizer and return. If we only want
  # normal complements, this cannot happen, as the cobounds are trivial.
  SN := Subgroup( S, Filtered(GeneratorsOfGroup(S),i-> not i in N));
  if Dimension(ocr.oneCoboundaries)=Dimension(ocr.oneCocycles)  then
      Info(InfoComplement,2,"CONextCocycles: H^1 is trivial" );
      K := ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
        return [];
      else
        S := CONextCentralizer( ocr, SN, ocr.complement );
      return [rec(complement := K, centralizer := S)];
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
        S := ocr.centralizer;
    fi;
      L:=VectorSpace(ocr.field,B.factorspace, B.factorzero);
      T := [];
      for i  in L  do
        K := ocr.cocycleToComplement(i);
        if not IsBound(cor.condition) or cor.condition(cor, K)  then
            Add(T, rec(complement := K,  centralizer := S));
      fi;
      od;
      Info(InfoComplement,2,"CONextCocycles: ",Length(T)," complements found" );
      return T;
  fi;

  # The  conjugacy  classes  of  complements  are cosets of the cocycles of
  # 0^S. If 'smallGeneratingSet' is given, do not use this gens.

  # Translation: (.. h ..) -> (.. [h,c] ..)
  if IsBound( ocr.smallGeneratingSet )  then
      tau := function( c )
        local   l;
        l := [];
        for i  in ocr.smallGeneratingSet  do
            Add( l, Comm( ocr.generators[i], c ) );
        od;
        return ocr.listToCocycle( l );
    end;
  else
      tau := function( c )
        local   l;
        l := [];
        for i  in ocr.generators  do
            Add( l, Comm( i, c ) );
        od;
        return ocr.listToCocycle( l );
    end;
  fi;
  gens := InducedPcgsWrtHomePcgs( SN );
  imgs := List( gens, tau );

  # Now get a base for the subspace 0^S. For those zero  images which are
  # not part of a base a generators of the stabilizer can be generated.
  #   B   holds the base,
  #   A   holds the correcting elements for the base vectors,
  #   T   holds the stabilizer generators.
  dim := Length( imgs[1] );
  A := [];
  B := [];
  T := [];
  heads := [1..dim] * 0;

  root:=Z(ocr.char);
  # Get the base starting with the last one and go up.
  for i  in Reversed( [1..Length(imgs)] )  do
    s := gens[i];
    v := imgs[i];
    j := 1;
    while j <= dim and IntFFE(v[j]) = 0  do
        j := j + 1;
      od;
    while j <= dim and heads[j] <> 0  do
        z := v[j] / B[heads[j]][j];
        if z <> 0*z  then
        s := s / A[heads[j]] ^ ocr.logTable[LogFFE(z,root)+1];
        fi;
      v := v - v[j] / B[heads[j]][j] * B[heads[j]];
      while j <= dim and IntFFE(v[j]) = 0  do
            j := j + 1;
        od;
    od;
    if j > dim  then
      Add( T, s );
    else
      Add( B, v );
      Add( A, s );
      heads[j] := Length( B );
    fi;
  od;

  # So  <T>  now  holds a reversed list of generators for a stabilizer. <B>
  # is  a  base for 0^<S> and <cocycles>/0^<S> are the conjugacy classes of
  # complements.
  S := ClosureGroup(N,T);
  if B = []  then
    B := zett;
  else
    B:=BaseSteinitzVectors(BasisVectors(Basis(zett)),B);
    B:=VectorSpace(ocr.field,B.factorspace, B.factorzero);
  fi;
  L := [];
  for i  in B  do
      K := ocr.cocycleToComplement(i);
      if not IsBound(cor.condition) or cor.condition(cor, K)  then
        Add(L, rec(complement := K, centralizer := S));
      fi;
  od;
  Info(InfoComplement,2,"CONextCentral: ", Length(L), " complements found");
  return L;

end;


#############################################################################
##
#F  CONextComplements( <cor>, <S>, <K>, <M> ) . . . . . . . . . . . . . local
##  S: fuser, K: Complements in, M: Complements to
##
CONextComplements := function( cor, S, K, M )
local   L,  p,  C,  ocr;

  if not IsSubgroup(K,M) then
    Error("huh?");
  fi;

  if IsTrivial(M)  then
    if IsBound(cor.condition) and not cor.condition(cor, K)  then
      return [];
    else
    return [rec( complement := K, centralizer := S )];
    fi;
  #AH
  elif false and IsEmpty(Intersection( Factors(Size(M)), Factors(Index(K,M))))  then

    # If <K> and <M> are coprime, <K> splits.
    Info(InfoComplement,2,"CONextComplements: coprime case, <K> splits" );
    ocr := rec( group := K, module:=M, modulePcgs := Pcgs(M),
                inPcComplement := true);

    if IsBound( cor.generators )  then
      ocr.generators := cor.generators;
    fi;
    if IsBound( cor.smallGeneratingSet )  then
      ocr.smallGeneratingSet := cor.smallGeneratingSet;
      ocr.generatorsInSmall  := cor.generatorsInSmall;
    elif IsBound( cor.primes )  then
      p := Factors(Size( M.generators))[1];
      if p in cor.primes  then
        ocr.pPrimeSet := cor.pPrimeSets[Position( cor.primes, p )];
      fi;
    fi;
    if IsBound( cor.relators )  then
      ocr.relators := cor.relators;
    fi;

    #was: ocr.complement := CoprimeComplement( K, M );
    OCOneCocycles( ocr, true );

    OCOneCoboundaries( ocr );
    if   IsBound( cor.normalComplements )
         and cor.normalComplements
         and Dimension( ocr.oneCoboundaries ) <> 0 then
      return [];
    else
      K := ocr.complement;
      if IsBound(cor.condition) and not cor.condition(cor, K)  then
	return [];
      fi;
      S := Subgroup( S, Filtered(GeneratorsOfGroup(S),i->not i in M));
      S := CONextCentralizer( ocr, S, K );
      return [rec( complement := K, centralizer := S )];
    fi;
  else

    # In the non-coprime case, we must construct cocycles.
    ocr := rec( group := K, module:=M, modulePcgs := Pcgs(M),
                inPcComplement := true);

    if IsBound( cor.generators )  then
      ocr.generators := cor.generators;
    fi;
    if IsBound( cor.normalComplement ) and cor.normalComplements  then
      ocr.normalIn := S;
    fi;

#    if IsBound( cor.normalSubgroup )  then
#      L := cor.normalSubgroup( S, K, M );
#      if IsTrivial(L) = []  then
#	return CONextCocycles(cor, ocr, S);
#      else
#	return CONextNormal(cor, ocr, S, L);
#      fi;
#    else

    if IsBound( cor.smallGeneratingSet )  then
	   ocr.smallGeneratingSet := cor.smallGeneratingSet;
      ocr.generatorsInSmall  := cor.generatorsInSmall;
    elif IsBound( cor.primes )  then
      p := Factors(Size( M.generators))[1];
      if p in cor.primes  then
	ocr.pPrimeSet := cor.pPrimeSets[Position(cor.primes,p)];
      fi;
    fi;
    if IsBound( cor.relators )  then
      ocr.relators := cor.relators;
    fi;
    if  ( cor.useCentral and IsCentral( Parent(M), M ) )
     or ( cor.useCentralSK and IsCentral(S,M) and IsCentral(K,M) ) then
      return CONextCentral(cor, ocr, S);
    else
      return CONextCocycles(cor, ocr, S);
    fi;

  fi;

end;


#############################################################################
##
#F  COComplements( <cor>, <G>, <N>, <all> ) . . . . . . . . . . . . . . local
##
##  Compute the complements in <G> of the normal subgroup N[1]. N is a list
##  of normal subgroups of G s.t. N[i]/N[i+1] is elementary abelian.
##  If  <all>  is  true, find all (conjugacy classes of) complements.
##  Otherwise   try  to find  just  one complement.
##
COComplements := function( cor, G, E, all )
local r,a,a0,FG,nextStep,C,found,i,time;

  # give some information and start timing
  Info(InfoComplement,2,"Complements: initialize factorgroups" );
  time := Runtime();

  # we only need the series beginning from position <n>
  r := Length(E);

  # Construct the homomorphisms <a>[i] = <G>/<E>[i+1] -> <G>/<E>[i].

  # hope that NHBNS deals with the trivial subgroup sensibly
  a0 := List(E{[1..Length(E)-1]},i->NaturalHomomorphismByNormalSubgroup(G,i));
  a  := HomomorphismsSeries( G, a0 );
  a0 := a0[1];

  # <FG> contains the factorgroups <G>/<E>[1], ..., <G>/<E>[<r>].
  FG := List( a, Range );
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
    cor.useCentral := false;
  fi;
  if not IsBound( cor.useCentralSK )  then
    cor.useCentralSK := false;
  fi;
  if not IsBound( cor.normalComplements )  then
    cor.normalComplements := false;
  fi;
  if IsBound( cor.generators )  then
    cor.generators := List( cor.generators, x -> Image(a0, x) );
  else
    cor.generators := CanonicalPcgs( InducedPcgsWrtHomePcgs(FG[1] ));
  fi;
  Assert(1,cor.generators[1] in FG[1]);

  #if not IsBound( cor.normalSubgroup )  then
  cor.group  := FG[1];
  cor.module := TrivialSubgroup( FG[1] );
  cor.pcgs   := InducedPcgsWrtHomePcgs(G);
  cor.modulePcgs:=InducedPcgsWrtHomePcgs(E[1]);
  # avoid clashes of generators
  cor.gens:=cor.generators;cor.generators:=cor.pcgs mod cor.modulePcgs;
  OCAddRelations(cor,cor.generators);
  cor.generators:=cor.gens;
  #fi;

  # The  following  function will be called recursively in order to descend
  # the tree and reach a complement.  <nr> is the current level.
  # it lifts the complement K over the nr-th step and fuses under the action
  # of (the full preimage of) S
  nextStep := function( S, K, nr )
  local   M,  NC,  X;

    # give information about the level reached
    Info(InfoComplement,1,"Complements: reached level ", nr, " of ", r);

    # if this is the last level we have a complement, add it to <C>
    if nr = r  then
      Add( C, rec( complement := K, centralizer := S ) );
        Info(InfoComplement,2,"Complements: next class found, ",
             "total ", Length(C), " complement(s), ",
                 "time=", Runtime() - time);
      found := true;

      # otherwise try to split <K> over <M> = <FE>[<nr>+1]
    else
      S := PreImage( a[nr], S );
      M := KernelOfMultiplicativeGeneralMapping(a[nr]);
      cor.module := M;

      # we cannot take the 'PreImage' as this changes the gens
      cor.generators := List( GeneratorsOfGroup(K), x ->
			PreImagesRepresentative(a[nr],x) );
      K := ClosureGroup( M, cor.generators );

      # now 'CONextComplements' will try to find the complements
      NC := CONextComplements( cor, S, K, M );

      # try to step down as fast as possible
      for X  in NC  do
	nextStep( X.centralizer, X.complement, nr+1 );
	if found and not all  then
	  return;
	fi;
      od;
    fi;
  end;

  # in <C> we will collect the complements at the last step
  C := [];

  # ok, start 'nextStep'  with trivial module
  Info(InfoComplement,1,"  starting search, time=",Runtime()-time);
  found := false;
  nextStep( TrivialSubgroup( FG[1] ),
            Subgroup( FG[1], cor.generators ), 1 );

  # some timings
  Info(InfoComplement,1,"Complements: ",Length(C)," complement(s) found, ",
           "time=", Runtime()-time );

  # add the normalizer
  Info(InfoComplement,2,"Complements: adding normalizers" );
  for i  in [1..Length(C)]  do
    C[i].normalizer := ClosureGroup( C[i].centralizer,
			C[i].complement );
  od;
  return C;

end;


#############################################################################
##
#M  COComplementsMain( <G>, <N>, <all>, <fun> )  . . . . . . . . . . . . . local
##
##  Prepare arguments for 'ComplementCO'.
##
COComplementsMain:= function( G, N, all, fun )
local   H, E,  cor,  a,  i,  fun2,pcgs;

  pcgs:=HomePcgs(G);
  # Get the elementary abelian series through <N>.
  E := ElementaryAbelianSeries( N );
  if Length(Pcgs(G))<Length(pcgs) # G is not the top group
     # nt not in series
     or ForAny(E,i->not i=Subgroup(G,Filtered(pcgs,j->j in i)))
     then
    # create a better pcgs
    pcgs:=InducedPcgsWrtHomePcgs(G) mod InducedPcgsWrtHomePcgs(N);
    for i in [2..Length(E)] do
      pcgs:=Concatenation(pcgs,
         InducedPcgsWrtHomePcgs(E[i-1]) mod InducedPcgsWrtHomePcgs(E[i]));
    od;
    pcgs:=PcgsByPcSequenceCons(IsPcgsDefaultRep,
      IsPcgs and IsPrimeOrdersPcgs,FamilyObj(One(G)),pcgs);
    H:=GroupByPcgs(pcgs);
    a:=GroupHomomorphismByImages(G,H,pcgs,GeneratorsOfGroup(H));
    E:=List(E,i->Image(a,i));
    if IsFunction(fun) then
      fun2:=function(x)
	      return fun(PreImage(a,x));
            end;
    else
      fun2:=fun;
    fi;
    return List( COComplementsMain( H, Image(a,N), all, fun2 ), x -> rec(
          complement  := PreImage( a, x.complement ),
            centralizer := PreImage( a, x.centralizer ) ) );
  fi;

  # if <G> and <N> are coprime <G> splits over <N>
  if Intersection( Factors(Size(N)), Factors(Index(G,N))) = []  then
      Info(InfoComplement,2,"Complements: coprime case, <G> splits" );
      cor := rec();

  # otherwise we compute a hall system for <G>/<N>
  else
    #AH
    #Info(InfoComplement,2,"Complements: computing p prime sets" );
    #a   := NaturalHomomorphism( G, G / N );
    #cor := PPrimeSetsOC( Image( a ) );
    #cor.generators := List( cor.generators, x -> 
    #                    PreImagesRepresentative( a, x ) );
    cor:=rec(generators:=AsList(pcgs mod Pcgs(N)));
    cor.useCentralSK := true;
  fi;

  # if a condition was given use it
  if IsFunction(fun)  then cor.condition := fun;  fi;

  # 'COComplements' will do most of the work
  return COComplements( cor, G, E, all );

end;


InstallMethod(ComplementclassesSolvableNC,"pc groups",IsIdentical,
  [IsPcGroup,IsPcGroup],0,
function(G,N)
  return List( COComplementsMain(G, N, true, false), G -> G.complement );
end);


#############################################################################
##
#M  Complementclasses( <G>, <N> ) . . . . . . . . . . . . find all complement
##
InstallMethod(Complementclasses,"solvable normal subgroup",IsIdentical,
  [IsGroup,IsGroup],0,
function( G, N )
  local   C;

  # if <G> and <N> are equal the only complement is trivial
  if G = N  then
      C := [TrivialSubgroup(G)];

  # if <N> is trivial the only complement is <G>
  elif Size(N) = 1 then
      C := [G];

  elif not IsSolvableGroup(N) then
    TryNextMethod();
  else
    # otherwise we have to work
    C:=ComplementclassesSolvableNC(G,N);
  fi;

  # return what we have found
  return C;

end);


#############################################################################
##
#E  grppccom.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

