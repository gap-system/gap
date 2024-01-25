#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file contains declarations for the subgroup lattice functions for
##  pc groups.
##

#############################################################################
##
#F  InvariantElementaryAbelianSeries( <G>, <morph>, [ <N> ] )
##           find <morph> invariant EAS of G (through N)
##
InstallGlobalFunction(InvariantElementaryAbelianSeries,function(arg)
local G,morph,N,s,p,e,i,j,k,ise,fine,cor;
  G:=arg[1];
  morph:=arg[2];
  fine:=false;
  if Length(arg)>2 then
    N:=arg[3];
    e:=[G,N];
    if Length(arg)>3 then
      fine:=arg[4];
    fi;
    if fine then
      e:=ElementaryAbelianSeries(e);
    else
      e:=ElementaryAbelianSeriesLargeSteps(e);
    fi;
  else
    N:=TrivialSubgroup(G);
    e:=DerivedSeriesOfGroup(G);
    e:=ElementaryAbelianSeriesLargeSteps(e);
  fi;
  s:=[G];
  i:=2;
  while i<=Length(e) do
    # intersect all images of normal subgroup to obtain invariant one
    # as G is invariant, we dont have to deal with special cases
    ise:=[e[i]];
    cor:=e[i];
    for j in ise do
      for k in morph do
        p:=Image(k,j);
        if not IsSubset(p,cor) then
          Add(ise,p);
          cor:=Intersection(cor,p);
        fi;
      od;
    od;
    Assert(1,HasElementaryAbelianFactorGroup(s[Length(s)],cor));
    ise:=cor;
    Add(s,ise);
    p:=Position(e,ise);
    if p<>fail then
      i:=p+1;
    elif fine then
      e:=ElementaryAbelianSeries([G,ise,TrivialSubgroup(G)]);
      i:=Position(e,ise)+1;
    else
      e:=ElementaryAbelianSeriesLargeSteps([G,ise,TrivialSubgroup(G)]);
      i:=Position(e,ise)+1;
    fi;
    Assert(1,ise in e);
  od;
  return s;
end);

#############################################################################
##
#F  InducedAutomorphism(<epi>,<aut>)
##
InstallGlobalFunction(InducedAutomorphism,function(epi,aut)
local f;
  f:=Range(epi);
  if HasIsConjugatorAutomorphism( aut ) and IsConjugatorAutomorphism( aut )
     and ConjugatorOfConjugatorIsomorphism( aut ) in Source( epi ) then
    aut:= ConjugatorAutomorphismNC( f,
              Image( epi, ConjugatorOfConjugatorIsomorphism( aut ) ) );
  else
    aut:= GroupHomomorphismByImagesNC(f,f,GeneratorsOfGroup(f),
                                   List(GeneratorsOfGroup(f),
               i->Image(epi,Image(aut,PreImagesRepresentative(epi,i)))));
    SetIsInjective(aut,true);
    SetIsSurjective(aut,true);
  fi;
  return aut;
end);

#############################################################################
##
#F  InvariantSubgroupsElementaryAbelianGroup(<G>,<homs>[,<dims])  submodules
#F    find all subgroups of el. ab. <G>, which are invariant under all <homs>
#F    which have dimension in dims
##
InstallGlobalFunction(InvariantSubgroupsElementaryAbelianGroup,function(arg)
local g,op,a,pcgs,ma,mat,d,f,i,j,new,newmat,id,p,dodim,compldim,compl,dims,nm;
  g:=arg[1];
  op:=arg[2];
  if not IsElementaryAbelian(g) then
    Error("<g> must be a vector space");
  fi;
  if IsTrivial(g) then
    return [g];
  fi;
  pcgs:=Pcgs(g);
  d:=Length(pcgs);
  p:=RelativeOrderOfPcElement(pcgs,pcgs[1]);
  f:=GF(p);
  if Length(arg)=2 then
    dims:=[0..d];
  else
    dims:=arg[3];
  fi;

  if Length(dims)=0 then
    return [];
  fi;

  if Length(op)=0 then

    # trivial operation: enumerate subspaces
    # check which dimensions we'll need
    ma:=QuoInt(d,2);
    dodim:=[];
    compldim:=[];
    for i in dims do
      if i<=ma then
        AddSet(dodim,i);
      else
        AddSet(dodim,d-i);
        AddSet(compldim,d-i);
      fi;
    od;
    if d<3 then compldim:=[]; fi;
    dodim:=Maximum(dodim);

    # enumerate spaces
    id:= Immutable( IdentityMat(d, One(f)) );
    ma:=[[],[ShallowCopy(id[1])]];
    ConvertToMatrixRep(ma[2],f);
    # the complements to ma
    if d>1 then
      compl:=[ShallowCopy(id)];
    else
      compl:=[];
    fi;
    if d>2 then
      nm:=TriangulizedNullspaceMat(TransposedMat(id{[1]}));
      ConvertToMatrixRep(nm,f);
      Add(compl,nm);
    fi;
    for i in [2..d] do
      new:=[];
      for mat in ma do
        # subspaces of equal dimension
        for j in [0..p^Length(mat)-1] do
          if j=0 then
            # special case for subspace of higher dimension
            if Length(mat)<dodim then
              newmat:=Concatenation(mat,[id[i]]);
              ConvertToMatrixRep(newmat,f);
            else
              newmat:=false;
            fi;
          else
            # possible extension number d
            a:=CoefficientsQadic(j,p)*One(f);
            newmat:=List(mat,ShallowCopy);
            for j in [1..Length(a)] do
                newmat[j][i]:=a[j];
            od;
            ConvertToMatrixRep(newmat,f);
          fi;
          if newmat<>false then
            # we will need the space for the next level
            Add(new,newmat);

            # note complements if necc.
            if Length(newmat) in compldim then
              nm:=NullspaceMat(TransposedMat(newmat));
              ConvertToMatrixRep(nm,f);
              Add(compl,nm);
              #Add(compl,List(NullspaceMat(TransposedMat(newmat*One(f))),
              #               i->List(i,IntFFE)));
            fi;
          fi;
        od;
      od;
      ma:=Concatenation(ma,new);
    od;

    ma:=Concatenation(ma,compl);

    # take only those of right dim
    ma:=Filtered(ma,i->Length(i) in dims);

    # convert to grps (noting also the triv. one)
    new:=ma;
    for i in [1..Length(new)] do
      #a:=SubgroupNC(Parent(g),List(i,j->Product([1..d],k->pcgs[k]^j[k])));
      ma:=new[i];
      a:=SubgroupNC(Parent(g),List(ma,
                          j->PcElementByExponentsNC(pcgs,List(j,IntFFE))));
#      a:=MySubgroupNC(Parent(g),List(i,j->PcElementByExponentsNC(pcgs,j)),
#                      IsFinite and IsSubsetLocallyFiniteGroup and
#                      IsSupersolvableGroup and IsNilpotentGroup and
#                      IsCommutative and IsElementaryAbelian);

      SetSize(a,p^Length(ma));
      if Size(a)=Size(g) then a:=g;fi;
      new[i]:=a;
    od;
    ma:=new;

  else

    # compute representation
    ma:=[];
    for i in op do
      mat:=[];
      for j in pcgs do
        Add(mat,ExponentsOfPcElement(pcgs,Image(i,j))*One(f));
      od;
      mat:=ImmutableMatrix(f,mat);
      Add(ma,mat);
    od;

    ma:=GModuleByMats(ma,f);
    mat:=MTX.BasesSubmodules(ma);

    ma:=[];
    for i in mat do
      Add(ma,SubgroupNC(Parent(g),
                      List(i,j->PcElementByExponentsNC(pcgs,j))));
                      #List(i,j->Product([1..d],k->pcgs[k]^IntFFE(j[k])))));
    od;
  fi;
  SortBy(ma,x->-Size(x));
  return ma;
end);

#############################################################################
##
#F  ActionSubspacesElementaryAbelianGroup(<P>,<G>[,<dims>])
##
##  compute the permutation action of <P> on the subspaces of the
##  elementary abelian subgroup <G> of <P>. Returns
##  a list [<subspaces>,<action>], where <subspaces> is a list of all the
##  subspaces (as groups) and <action> a homomorphism from <P> in a
##  permutation group, which is equal to the action homomrophism for the
##  action of <P> on <subspaces>. If <dims> is given, only subspaces of
##  dimension <dims> are considered.  Instead of <G> also a (modulo) pcgs
##  may be given, in this case <subspaces> are pre-images of the subspaces.
##
InstallGlobalFunction(ActionSubspacesElementaryAbelianGroup,function(arg)
local P,g,op,act,a,pcgs,ma,mat,d,f,i,j,new,newmat,id,p,dodim,compldim,compl,
      dims,Pgens,Pcgens,Pu,perms,one,par,ker,kersz,pcelm,pccache,asz;

  P:=arg[1];
  if IsModuloPcgs(arg[2]) then
    pcgs:=arg[2];
    g:=Group(NumeratorOfModuloPcgs(pcgs));
    if not IsSubset(Parent(P),g) then # for matrix groups we need a parent here.
      par:=ClosureGroup(Parent(P),g);
    else
      par:=P;
    fi;
    Pu:=AsSubgroup(par,g);
    ker:=SubgroupNC(par,DenominatorOfModuloPcgs(pcgs));
    kersz:=Size(ker);
  else
    kersz:=1;
    g:=arg[2];
    par:=Parent(g);
    Pu:=Centralizer(P,g);
    if not IsElementaryAbelian(g) then
      Error("<g> must be a vector space");
    fi;
    if IsTrivial(g) then
      return [g];
    fi;

    pcgs:=Pcgs(g);
  fi;

  d:=Length(pcgs);
  p:=RelativeOrderOfPcElement(pcgs,pcgs[1]);
  f:=GF(p);
  one:=One(f);
  if Length(arg)=2 then
    dims:=[0..d];
  else
    dims:=arg[3];
  fi;

  if Length(dims)=0 then
    return [];
  fi;

  # find representatives generating the acting factor
  Pgens:=[];
  Pcgens:=GeneratorsOfGroup(Pu);
  while Size(Pu)<Size(P) do
    repeat
      i:=Random(P);
    until not i in Pu;
    Add(Pgens,i);
    Pu:=ClosureGroup(Pu,i);
  od;
  if Length(Pgens)>2 and Length(Pgens)>Length(SmallGeneratingSet(P)) then
    Pgens:=SmallGeneratingSet(P);
  fi;

  # compute representation
  op:=[];
  for i in Pgens do
    mat:=[];
    for j in pcgs do
      Add(mat,ExponentsConjugateLayer(pcgs,j,i)*One(f));
    od;
    mat:=ImmutableMatrix(f,mat);
    Add(op,mat);
  od;

  # and action on canonical bases
  #act:=function(bas,m)
  #  bas:=bas*m;
  #  bas:=List(bas,ShallowCopy);
  #  TriangulizeMat(bas);
  #  bas:=List(bas,IntVecFFE);
  #  return bas;
  #end;
  if p=2 then
    act:=OnSubspacesByCanonicalBasisGF2;
  else
    act:=OnSubspacesByCanonicalBasis;
  fi;

  # enumerate subspaces
  # check which dimensions we'll need
  ma:=QuoInt(d,2);
  dodim:=[];
  compldim:=[];
  for i in dims do
    if i<=ma then
      AddSet(dodim,i);
    else
      AddSet(dodim,d-i);
      AddSet(compldim,d-i);
    fi;
  od;
  if d<3 then compldim:=[]; fi;
  dodim:=Maximum(dodim);

  # enumerate spaces
  id:= Immutable( IdentityMat(d, one) );
  ma:=[[],[id[1]]];
  # the complements to ma
  if d>1 then
    compl:=[ShallowCopy(id)];
  else
    compl:=[];
  fi;
  if d>2 then
    Add(compl,List(TriangulizedNullspaceMat(TransposedMat(id{[1]})),
                   ShallowCopy));
  fi;
  for i in [2..d] do
    new:=[];
    for mat in ma do
      # subspaces of equal dimension
      for j in [0..p^Length(mat)-1] do
        if j=0 then
          # special case for subspace of higher dimension
          if Length(mat)<dodim then
            newmat:=Concatenation(mat,[id[i]]);
          else
            newmat:=false;
          fi;
        else
          # possible extension number d
          a:=CoefficientsQadic(j,p)*one;
          newmat:=List(mat,ShallowCopy);
          for j in [1..Length(a)] do
              newmat[j][i]:=a[j];
          od;
        fi;
        if newmat<>false then
          # we will need the space for the next level
          Add(new,Immutable(newmat));

          # note complements if necc.
          if Length(newmat) in compldim then
            a:=List(TriangulizedNullspaceMat(MutableTransposedMat(newmat)),
                    ShallowCopy);
            Add(compl,Immutable(a));
          fi;
        fi;
      od;
    od;

    ma:=Concatenation(ma,new);
  od;

  ma:=Concatenation(ma,compl);

  # take only those of right dim
  ma:=Filtered(ma,i->Length(i) in dims);

  perms:=List(Pgens,i->());
  new:=[];
  for i in dims do
    mat:=Immutable(Set(Filtered(ma,j->Length(j)=i)));
    # compute action on mat
    if i>0 and i<d then
      for j in [1..Length(Pgens)] do
        #a:=Permutation(op[j],mat,act);
        a:=List([1..Length(mat)],k->PositionSorted(mat,act(mat[k],op[j])));
        a:=PermList(a);
        perms[j]:=perms[j]*a^MappingPermListList([1..Length(mat)],
                                [Length(new)+1..Length(new)+Length(mat)]);
      od;
    fi;
    Append(new,mat);
  od;
  ma:=new;

  # convert to grps
  pccache:=[]; # avoid recerating different copies of same element
  pcelm:=function(vec)
  local e,p;
    e:=Immutable([vec]);
    p:=PositionSorted(pccache,e);
    if IsBound(pccache[p]) and pccache[p][1]=vec then
      return pccache[p][2];
    else
      e:=Immutable([vec,PcElementByExponentsNC(pcgs,vec)]);
      AddSet(pccache,e);
      return e[2];
    fi;
  end;

  new:=[];
  for i in ma do
    #a:=SubgroupNC(Parent(g),List(i,j->Product([1..d],k->pcgs[k]^j[k])));
    asz:=kersz*p^Length(i);
    if kersz=1 then
      a:=SubgroupNC(par,List(i,pcelm));
    else
      #a:=ClosureSubgroup(ker,List(i,pcelm):knownClosureSize:=asz);
      a:=SubgroupNC(par,Concatenation(GeneratorsOfGroup(ker),
        List(i,pcelm)));
    fi;
    SetSize(a,asz);
    Add(new,a);
  od;

  ma:= GroupByGenerators( perms, () );
  #Assert(1,Group(perms)=Action(P,new));

  op:=GroupHomomorphismByImagesNC(P,ma,Concatenation(Pcgens,Pgens),
    Concatenation(List(Pcgens,i->()),perms));
#  Assert(1,Size(P)=Size(KernelOfMultiplicativeGeneralMapping(op))
#                   *Size(Image(op)));
  return [new,op];

end);

# test whether the c-conjugate of g is h-invariant, internal
BindGlobal( "HasInvariantConjugateSubgroup", function(g,c,h)
  # This should be done better!
  g:=ConjugateSubgroup(g,c);
  return ForAll(h,i->Image(i,g)=g);
end );

#############################################################################
##
#F  SubgroupsSolvableGroup(<G>[,<opt>]) . classreps of subgrps of <G>,
##                                           <homs>-inv. with options.
##    Options are:
##                  actions:  list of automorphisms: search for invariants
##                  funcnorm: N_G(actions) (speeds up calculation)
##                  normal:   just search for normal subgroups
##                  consider: function(A,N,B,M) indicator function, whether
##                            complements of this type would be needed
##                  retnorm:  return normalizers
##
InstallGlobalFunction(SubgroupsSolvableGroup,function(arg)
local g,        # group
      isom,     # isomorphism onto AgSeries group
      func,     # automorphisms to be invariant under
      funcs,    # <func>
      funcnorm, # N_G(funcs)
      efunc,    # induced automs on factor
      efnorm,   # funcnorm^epi
      e,        # EAS
      len,      # Length(e)
      start,    # last index with EA factor
      i,j,k,l,
      m,kp,     # loop
      kgens,    # generators of k
      kconh,    # complemnt conjugacy storage
      opt,      # options record
      normal,   # flag for 'normal' option
      consider, # optional 'consider' function
      retnorm,  # option: return all normalizers
      f,        # g/e[i]
      home,     # HomePcgs(f)
      epi,      # g -> f
      lastepi,  # epi of last step
      n,        # e[i-1]^epi
      fa,       # f/n = g/e[i-1]
      hom,      # f -> fa
      B,        # subgroups of n
      ophom,    # perm action of f on B (or false if not computed)
      a,        # preimg. of group over n
      no,       # N_f(a)
#      aop,     # a^ophom
#      nohom,   # ophom\rest no
      oppcgs,   # acting pcgs
      oppcgsimg,# images under ophom
      ex,       # external set/orbits
      bs,       # b\in B normal under a, reps
      bsp,      # bs index
      bsnorms,  # respective normalizers
      b,        # in bs
      bpos,     # position in bs
      hom2,     # N_f(b) -> N_f(b)/b
      nag,      # AgGroup(n^hom2)
      fghom,    # assoc. epi
      t,s,      # dnk-transversals
      z,        # Cocycles
      coboundbas,# Basis(OneCobounds)
      field,    # GF(Exponent(n))
      com,      # complements
      comnorms, # normalizers supergroups
      isTrueComnorm, # is comnorms the true normalizer or a supergroup
      comproj,  # projection onto complement
      kgn,
      kgim,     # stored decompositions, translated to matrix language
      kgnr,     # assoc index
      ncom,     # dito, tested
      idmat,    # 1-matrix
      mat,      # matrix action
      mats,     # list of mats
      conj,     # matrix action
      chom,     # homom onto <conj>
      shom,     # by s induced autom
      shoms,    # list of these
      smats,    # dito, matrices
      conjnr,   # assoc. index
      glsyl,
      glsyr,    # left and right side of eqn system
      found,    # indicator for success
      grps,     # list of subgroups
      ngrps,    # dito, new level
      gj,       # grps[j]
      grpsnorms,# normalizers of grps
      ngrpsnorms,# dito, new level
      bgids,    # generators of b many 1's (used for copro)
      opr,      # operation on complements
      xo;       # xternal orbits

  g:=arg[1];
  if Length(arg)>1 and IsRecord(arg[Length(arg)]) then
    opt:=arg[Length(arg)];
  else
    opt:=rec();
  fi;

  # parse options
  retnorm:=IsBound(opt.retnorm) and opt.retnorm;

  # handle trivial case
  if IsTrivial(g) then
    if retnorm then
       return [[g],[g]];
    else
       return [g];
    fi;
  fi;

  normal:=IsBound(opt.normal) and opt.normal=true;
  if IsBound(opt.consider) then
    consider:=opt.consider;
  else
    consider:=false;
  fi;

  isom:=fail;

  # get automorphisms and compute their normalizer, if applicable
  if IsBound(opt.actions) then
    func:=opt.actions;
    hom2:= Filtered( func,     HasIsConjugatorAutomorphism
                           and IsInnerAutomorphism );
    hom2:= List( hom2, ConjugatorOfConjugatorIsomorphism );

    if IsBound(opt.funcnorm) then
      # get the func. normalizer
      funcnorm:=opt.funcnorm;
      b:=g;
    else
      funcs:= GroupByGenerators( Filtered( func,
                  i -> not ( HasIsConjugatorAutomorphism( i ) and
                             IsInnerAutomorphism( i ) ) ),
                   IdentityMapping(g));
      IsGroupOfAutomorphismsFiniteGroup(funcs); # set filter
      if IsTrivial( funcs ) then
        b:=ClosureGroup(Parent(g),List(func,ConjugatorOfConjugatorIsomorphism));
        func:=hom2;
      else
        if IsSolvableGroup(funcs) then
          a:=IsomorphismPcGroup(funcs);
        else
          a:=IsomorphismPermGroup(funcs);
        fi;
        hom:=InverseGeneralMapping(a);
        IsTotal(hom); IsSingleValued(hom); # to be sure (should be set anyway)
        b:=SemidirectProduct(Image(a),hom,g);
        hom:=Embedding(b,1);
        funcs:=List(GeneratorsOfGroup(funcs),i->Image(hom,Image(a,i)));
        isom:=Embedding(b,2);
        hom2:=List(hom2,i->Image(isom,i));
        func:=Concatenation(funcs,hom2);
        g:=Image(isom,g);
      fi;

      # get the normalizer of <func>
      funcnorm:=Normalizer(g,SubgroupNC(b,func));
      func:=List(func,i->ConjugatorAutomorphism(b,i));
    fi;

    Assert(1,IsSubgroup(g,funcnorm));

    # compute <func> characteristic series
    e:=InvariantElementaryAbelianSeries(g,func);
  else
    func:=[];
    funcnorm:=g;
    e:=ElementaryAbelianSeriesLargeSteps(g);
  fi;

  if IsBound(opt.series) then
    e:=opt.series;
  else
    f:=DerivedSeriesOfGroup(g);
    if Length(e)>Length(f) and
      ForAll([1..Length(f)-1],i->IsElementaryAbelian(f[i]/f[i+1])) then
      Info(InfoPcSubgroup,1,"  Preferring Derived Series");
      e:=f;
    fi;
  fi;

#  # check, if the series is compatible with the AgSeries and if g is a
#  # parent group. If not, enforce this
#  if not(IsParent(g) and ForAll(e,IsElementAgSeries)) then
#    Info(InfoPcSubgroup,1,"  computing better series");
#    isom:=IsomorphismAgGroup(e);
#    g:=Image(isom,g);
#    e:=List(e,i->Image(isom,i));
#    funcnorm:=Image(isom,funcnorm);
#
#    #func:=List(func,i->isom^-1*i*isom);
#    hom:=[];
#    for i in func do
#      hom2:=GroupHomomorphismByImagesNC(g,g,g.generators,List(g.generators,
#                 j->Image(isom,Image(i,PreImagesRepresentative(isom,j)))));
#      hom2.isMapping:=true;
#      Add(hom,hom2);
#    od;
#    func:=hom;
#  else
#    isom:=false;
#  fi;

  len:=Length(e);

  if IsBound(opt.groups) then
    start:=0;
    while start+1<=Length(e) and ForAll(opt.groups,i->IsSubgroup(e[start+1],i)) do
      start:=start+1;
    od;
    Info(InfoPcSubgroup,1,"starting index ",start);
    epi:=NaturalHomomorphismByNormalSubgroup(g,e[start]);
    lastepi:=epi;
    f:=Image(epi,g);
    grps:=List(opt.groups,i->Image(epi,i));
    if not IsBound(opt.grpsnorms) then
      opt:=ShallowCopy(opt);
      opt.grpsnorms:=List(opt.groups,i->Normalizer(e[1],i));
    fi;
    grpsnorms:=List(opt.grpsnorms,i->Image(epi,i));
  else
    # search the largest elementary abelian quotient
    start:=2;
    while start<len and IsElementaryAbelian(g/e[start+1]) do
      start:=start+1;
    od;

    # compute all subgroups there
    if start<len then
      # form only factor groups if necessary
      epi:=NaturalHomomorphismByNormalSubgroup(g,e[start]);
      LockNaturalHomomorphismsPool(g,e[start]);
      f:=Image(epi,g);
    else
      f:=g;
      epi:=IdentityMapping(f);
    fi;
    lastepi:=epi;
    efunc:=List(func,i->InducedAutomorphism(epi,i));
    grps:=InvariantSubgroupsElementaryAbelianGroup(f,efunc);
    Assert(1,ForAll(grps,i->ForAll(efunc,j->Image(j,i)=i)));
    grpsnorms:=List(grps,i->f);
    Info(InfoPcSubgroup,5,List(grps,Size),List(grpsnorms,Size));

  fi;

  for i in [start+1..len] do
    Info(InfoPcSubgroup,1," step ",i,": ",Index(e[i-1],e[i]),", ",
                    Length(grps)," groups");
    # compute modulo e[i]
    if i<len then
      # form only factor groups if necessary
      epi:=NaturalHomomorphismByNormalSubgroup(g,e[i]);
      f:=Image(epi,g);
    else
      f:=g;
      epi:=IdentityMapping(g);
    fi;
    home:=HomePcgs(f); # we want to compute wrt. this pcgs
    n:=Image(epi,e[i-1]);

    # the induced factor automs
    efunc:=List(func,i->InducedAutomorphism(epi,i));
    # filter the non-trivial ones
    efunc:=Filtered(efunc,i->ForAny(GeneratorsOfGroup(f),j->Image(i,j)<>j));

    if Length(efunc)>0 then
      efnorm:=Image(epi,funcnorm);
    fi;

    if Length(efunc)=0 then
      ophom:=ActionSubspacesElementaryAbelianGroup(f,n);
      B:=ophom[1];
      Info(InfoPcSubgroup,2,"  ",Length(B)," normal subgroups");
      ophom:=ophom[2];

      ngrps:=[];
      ngrpsnorms:=[];
      oppcgs:=Pcgs(Source(ophom));
      oppcgsimg:=List(oppcgs,i->Image(ophom,i));
      ex:=[1..Length(B)];
      IsSSortedList(ex);
      ex:=ExternalSet(Source(ophom),ex,oppcgs,oppcgsimg,OnPoints);
      ex:=ExternalOrbitsStabilizers(ex);

      for j in ex do
        Add(ngrps,B[Representative(j)]);
        Add(ngrpsnorms,StabilizerOfExternalSet(j));
#       Assert(1,Normalizer(f,B[j[1]])=ngrpsnorms[Length(ngrps)]);
      od;

    else
      B:=InvariantSubgroupsElementaryAbelianGroup(n,efunc);
      ophom:=false;
      Info(InfoPcSubgroup,2,"  ",Length(B)," normal subgroups");

      # note the groups in B
      ngrps:=SubgroupsOrbitsAndNormalizers(f,B,false);
      ngrpsnorms:=List(ngrps,i->i.normalizer);
      ngrps:=List(ngrps,i->i.representative);
    fi;

    # Get epi to the old factor group
    # as hom:=NaturalHomomorphism(f,fa); does not work, we have to play tricks
    hom:=lastepi;
    lastepi:=epi;
    fa:=Image(hom,g);

    hom:= GroupHomomorphismByImagesNC(f,fa,GeneratorsOfGroup(f),
           List(GeneratorsOfGroup(f),i->
             Image(hom,PreImagesRepresentative(epi,i))));
    Assert(2,KernelOfMultiplicativeGeneralMapping(hom)=n);

    # lift the known groups
    for j in [1..Length(grps)] do

      gj:=grps[j];
      if Size(gj)>1 then
        a:=PreImage(hom,gj);
        Assert(1,Size(a)=Size(gj)*Size(n));
        Add(ngrps,a);
        no:=PreImage(hom,grpsnorms[j]);

        Add(ngrpsnorms,no);

        if Length(efunc)>0 then
          # get the double cosets
          t:=List(DoubleCosets(f,no,efnorm),Representative);
          Info(InfoPcSubgroup,2,"  |t|=",Length(t));
          t:=Filtered(t,i->HasInvariantConjugateSubgroup(a,i,efunc));
          Info(InfoPcSubgroup,2,"invar:",Length(t));
        fi;

        # we have to extend with those b in B, that are normal in a
        if ophom<>false then
          #aop:=Image(ophom,a);
          #SetIsSolvableGroup(aop,true);

          if Length(GeneratorsOfGroup(a))>2 then
            bs:=SmallGeneratingSet(a);
          else
            bs:=GeneratorsOfGroup(a);
          fi;
          bs:=List(bs,i->Image(ophom,i));

          bsp:=Filtered([1..Length(B)],i->ForAll(bs,j->i^j=i)
                                         and Size(B[i])<Size(n));
          bs:=B{bsp};
        else
          bsp:=false;
          bs:=Filtered(B,i->IsNormal(a,i) and Size(i)<Size(n));
        fi;

        if Length(efunc)>0 and Length(t)>1 then
          # compute also the invariant ones under the conjugates:
          # equivalently: Take all equivalent ones and take those, whose
          # conjugates lie in a and are normal under a
          for k in Filtered(t,i->not i in no) do
            bs:=Union(bs,Filtered(List(B,i->ConjugateSubgroup(i,k^(-1))),
                  i->IsSubset(a,i) and IsNormal(a,i) and Size(i)<Size(n) ));
          od;
        fi;

        # take only those bs which are valid
        if consider<>false then
          Info(InfoPcSubgroup,2,"  ",Length(bs)," subgroups lead to ");
          if bsp<>false then
            bsp:=Filtered(bsp,j->consider(no,a,n,B[j],e[i])<>false);
            IsSSortedList(bsp);
            bs:=bsp; # to get the 'Info' right
          else
            bs:=Filtered(bs,j->consider(no,a,n,j,e[i])<>false);
          fi;
          Info(InfoPcSubgroup,2,Length(bs)," valid ones");
        fi;

        if ophom<>false then
          #nohom:=List(GeneratorsOfGroup(no),i->Image(ophom,i));
          #aop:=SubgroupNC(Image(ophom),nohom);
          #nohom:=GroupHomomorphismByImagesNC(no,aop,
          #                                   GeneratorsOfGroup(no),nohom);

          if Length(bsp)>0 then
            oppcgs:=Pcgs(no);
            oppcgsimg:=List(oppcgs,i->Image(ophom,i));
            ex:=ExternalSet(no,bsp,oppcgs,oppcgsimg,OnPoints);
            ex:=ExternalOrbitsStabilizers(ex);

            bs:=[];
            bsnorms:=[];
            for bpos in ex do
              Add(bs,B[Representative(bpos)]);
              Add(bsnorms,StabilizerOfExternalSet(bpos));
#            Assert(1,Normalizer(no,B[bpos[1]])=bsnorms[Length(bsnorms)]);
            od;
          fi;

        else
          # fuse under the action of no and compute the local normalizers
          bs:=SubgroupsOrbitsAndNormalizers(no,bs,true);
          bsnorms:=List(bs,i->i.normalizer);
          bs:=List(bs,i->i.representative);
        fi;

Assert(1,ForAll(bs,i->ForAll(efunc,j->Image(j,i)=i)));

        # now run through the b in bs
        for bpos in [1..Length(bs)] do
          b:=bs[bpos];
          Assert(2,IsNormal(a,b));
          # test, whether we'll have to consider this case

# this test has basically be done before the orbit calculation already
#         if consider<>false and consider(a,n,b,e[i])=false then
#           Info(InfoPcSubgroup,2,"  Ignoring case");
#           s:=[];

          # test, whether b is invariant
          if Length(efunc)>0 then
            # extend to dcs of bnormalizer
            s:=RightTransversal(no,bsnorms[bpos]);
            nag:=Length(s);
            s:=Concatenation(List(s,i->List(t,j->i*j)));
            z:=Length(s);
            #NOCH: Fusion
            # test, which ones are usable at all
            s:=Filtered(s,i->HasInvariantConjugateSubgroup(b,i,efunc));
            Info(InfoPcSubgroup,2,"  |s|=",nag,"-(m)>",z,"-(i)>",Length(s));
          else
            s:=[()];
          fi;

          if Length(s)>0 then
            nag:=InducedPcgs(home,n);
            nag:=nag mod InducedPcgs(nag,b);
#           if Index(Parent(a),a.normalizer)>1 then
#             Info(InfoPcSubgroup,2,"  normalizer index ",
#                             Index(Parent(a),a.normalizer));
#           fi;

            z:=rec(group:=a,
                generators:=InducedPcgs(home,a) mod NumeratorOfModuloPcgs(nag),
                modulePcgs:=nag);
            OCOneCocycles(z,true);
            if IsBound(z.complement) and
              # normal complements exist, iff the coboundaries are trivial
              (normal=false or Dimension(z.oneCoboundaries)=0)
              then
              # now fetch the complements

              z.factorGens:=z.generators;
              coboundbas:=Basis(z.oneCoboundaries);
              com:=BaseSteinitzVectors(BasisVectors(Basis(z.oneCocycles)),
                                       BasisVectors(coboundbas));
              field:=LeftActingDomain(z.oneCocycles);
              if Size(field)^Length(com.factorspace)>100000 then
                Info(InfoWarning,1, "Many (",
                  Size(field)^Length(com.factorspace),") complements!");
              fi;
              com:=Enumerator(VectorSpace(field,com.factorspace,
                                               Zero(z.oneCocycles)));
              Info(InfoPcSubgroup,3,"  ",Length(com),
                   " local complement classes");

              # compute fusion
              kconh:=List([1..Length(com)],i->[i]);
              if i<len or retnorm then
                # we need to compute normalizers
                comnorms:=[];
              else
                comnorms:=fail;
              fi;

              if Length(com)>1 and Size(a)<Size(bsnorms[bpos]) then

                opr:=function(cyc,elm)
                      local l,i;
                        l:=z.cocycleToList(cyc);
                        for i in [1..Length(l)] do
                          l[i]:=(z.complementGens[i]*l[i])^elm;
                        od;
                        l:=CorrespondingGeneratorsByModuloPcgs(z.origgens,l);
                        for i in [1..Length(l)] do
                          l[i]:=LeftQuotient(z.complementGens[i],l[i]);
                        od;
                        l:=z.listToCocycle(l);
                        return SiftedVector(coboundbas,l);
                      end;

                xo:=ExternalOrbitsStabilizers(
                     ExternalSet(bsnorms[bpos],com,opr));

                for k in xo do
                  l:=List(k,i->Position(com,i));
                  if comnorms<>fail then
                    comnorms[l[1]]:=StabilizerOfExternalSet(k);
                    isTrueComnorm:=false;
                  fi;
                  l:=Set(l);
                  for kp in l do
                    kconh[kp]:=l;
                  od;
                od;

              elif comnorms<>fail then
                if Size(a)=Size(bsnorms[bpos]) then
                  comnorms:=List(com,i->z.cocycleToComplement(i));
                  isTrueComnorm:=true;
                  comnorms:=List(comnorms,
                              i->ClosureSubgroup(CentralizerModulo(n,b,i),i));
                else
                  isTrueComnorm:=false;
                  comnorms:=List(com,i->bsnorms[bpos]);
                fi;
              fi;


              if Length(efunc)>0 then
                ncom:=[];

                #search for invariant ones

                # force exponents corresponding to vector space

                # get matrices for the inner automorphisms
#                conj:=[];
#                for k in GeneratorsOfGroup(a) do
#                  mat:=[];
#                  for l in nag do
#                    Add(mat,One(field)*ExponentsOfPcElement(nag,l^k));
#                  od;
#                  Add(conj,mat);
#                od;
                conj:=LinearOperationLayer(a,GeneratorsOfGroup(a),nag);

                idmat:=conj[1]^0;
                mat:= GroupByGenerators( conj, idmat );
                chom:= GroupHomomorphismByImagesNC(a,mat,
                        GeneratorsOfGroup(a),conj);

                smats:=[];
                shoms:=[];

                fghom:=Concatenation(z.factorGens,GeneratorsOfGroup(n));
                bgids:=List(GeneratorsOfGroup(n),i->One(b));

                # now run through the complements
                for kp in [1..Length(com)] do

                  if kconh[kp]=fail then
                    Info(InfoPcSubgroup,3,"already conjugate");
                  else

                    l:=z.cocycleToComplement(com[kp]);
                    # the projection on the complement
                    k:=ClosureSubgroup(b,l);
                    if Length(s)=1 and IsOne(s[1]) then
                      # special case -- no conjugates
                      if ForAll(efunc,x->ForAll(GeneratorsOfGroup(l),
                           y->ImagesRepresentative(x,y) in k)) then
                        l:=rec(representative:=k);
                        if comnorms<>fail then
                          if IsBound(comnorms[kp]) then
                            l.normalizer:=comnorms[kp];
                          else
                            l.normalizer:=Normalizer(bsnorms[bpos],
                                    ClosureSubgroup(b,k));
                          fi;
                        fi;
                        Add(ncom,l);

                        # tag all conjugates
                        for l in kconh[kp] do
                          kconh[l]:=fail;
                        od;
                      fi;

                    else
                      # generic case

                      comproj:= GroupHomomorphismByImagesNC(a,a,fghom,
                                Concatenation(GeneratorsOfGroup(l),bgids));

                      # now run through the conjugating elements
                      conjnr:=1;
                      found:=false;
                      while conjnr<=Length(s) and found=false do
                        if not IsBound(smats[conjnr]) then
                          # compute the matrix action for the induced, jugated
                          # morphisms
                          m:=s[conjnr];
                          smats[conjnr]:=[];
                          shoms[conjnr]:=[];
                          for l in efunc do
                            # the induced, jugated morphism
                            shom:= GroupHomomorphismByImagesNC(a,a,
                                    GeneratorsOfGroup(a),
                                    List(GeneratorsOfGroup(a),
                                    i->Image(l,i^m)^Inverse(m)));

                            mat:=List(nag,
                                  i->One(field)*ExponentsOfPcElement(nag,
                                  Image(shom,i)));
                            Add(smats[conjnr],mat);
                            Add(shoms[conjnr],shom);
                          od;
                        fi;

                        mats:=smats[conjnr];
                        # now test whether the complement k can be conjugated to
                        # be invariant under the morphisms to mats
                        glsyl:=List(nag,i->[]);
                        glsyr:=[];
                        for l in [1..Length(efunc)] do
                          kgens:=GeneratorsOfGroup(k);
                          for kgnr in [1..Length(kgens)] do

                            kgn:=Image(shoms[conjnr][l],kgens[kgnr]);
                            kgim:=Image(comproj,kgn);
                            Assert(2,kgim^-1*kgn in n);
                            # nt part
                            kgn:=kgim^-1*kgn;

                            # translate into matrix terms
                            kgim:=Image(chom,kgim);
                            kgn:=One(field)*ExponentsOfPcElement(nag,kgn);

                            # the matrix action
                            mat:=idmat+(mats[l]-idmat)*kgim-mats[l];

                            # store action and vector
                            for m in [1..Length(glsyl)] do
                              glsyl[m]:=Concatenation(glsyl[m],mat[m]);
                            od;
                            glsyr:=Concatenation(glsyr,kgn);

                          od;
                        od;

                        # a possible conjugating element is a solution of the
                        # large LGS
                        l:= SolutionMat(glsyl,glsyr);
                        if l <> fail then
                          m:=Product([1..Length(l)],
                                    i->nag[i]^IntFFE(l[i]));
                          # note that we found one!
                          found:=[s[conjnr],m];
                        fi;

                        conjnr:=conjnr+1;
                      od;

                      # there is an invariant complement?
                      if found<>false then
                        found:=found[2]*found[1];
                        l:=ConjugateSubgroup(ClosureSubgroup(b,k),found);
                        Assert(1,ForAll(efunc,i->Image(i,l)=l));
                        l:=rec(representative:=l);
                        if comnorms<>fail then
                          if IsBound(comnorms[kp]) then
                            l.normalizer:=ConjugateSubgroup(comnorms[kp],found);
                          else
                            l.normalizer:=ConjugateSubgroup(
                                            Normalizer(bsnorms[bpos],
                                    ClosureSubgroup(b,k)), found);
                          fi;
                        fi;
                        Add(ncom,l);

                        # tag all conjugates
                        for l in kconh[kp] do
                          kconh[l]:=fail;
                        od;

                      fi;

                    fi;

                  fi; # if not already a conjugate

                od;

                # if invariance test needed
              else
                # get representatives of the fused complement classes
                l:=Filtered([1..Length(com)],i->kconh[i][1]=i);

                ncom:=[];
                for kp in l do
                  m:=rec(representative:=
                          ClosureSubgroup(b,z.cocycleToComplement(com[kp])));
                  if comnorms<>fail then
                    m.normalizer:=comnorms[kp];
                  fi;
                  Add(ncom,m);
                od;
              fi;
              com:=ncom;

              # take the preimages
              for k in com do

                Assert(1,ForAll(efunc,i->Image(i,k.representative)
                                         =k.representative));
                Add(ngrps,k.representative);
                if IsBound(k.normalizer) then
                  if isTrueComnorm then
                    Add(ngrpsnorms,k.normalizer);
                  else
                    Add(ngrpsnorms,Normalizer(k.normalizer,k.representative));
                  fi;
                fi;
              od;
            fi;
          fi;
        od;

      fi;
    od;

    grps:=ngrps;
    grpsnorms:=ngrpsnorms;
    Info(InfoPcSubgroup,5,List(grps,Size),List(grpsnorms,Size));
  od;

  if isom<>fail then
    grps:=List(grps,j->PreImage(isom,j));
    if retnorm then
      grpsnorms:=List(grpsnorms,j->PreImage(isom,j));
    fi;
  fi;

  if retnorm then
    return [grps,grpsnorms];
  else
    return grps;
  fi;
end);


#############################################################################
##
#M  CharacteristicSubgroups( <G> )
##
InstallMethod(CharacteristicSubgroups,"solvable, automorphisms",true,
  [IsGroup and IsSolvableGroup],0,
function(G)
local A,s;
  if AbelianRank(G)<5 then
    TryNextMethod();
  fi;
  A:=AutomorphismGroup(G);
  s:=SubgroupsSolvableGroup(G,rec(normal:=true,actions:=GeneratorsOfGroup(A)));
  return Filtered(s,x->IsCharacteristicSubgroup(G,x));
end);

#############################################################################
##
#M  LatticeSubgroups(<G>)  . . . . . . . . . .  lattice of subgroups
##
InstallMethod(LatticeSubgroups,"elementary abelian extension",true,
  [IsGroup and IsFinite and CanComputeFittingFree],
  # want to be better than cyclic extension.
  1,
function(G)
local s,i,c,classes, lattice,map,GI;

  if Size(G)=1 or not IsSolvableGroup(G) then #or not CanEasilyComputePcgs(G) then
    TryNextMethod();
  fi;
  if not IsPcGroup(G) or IsPermGroup(G) then
    map:=IsomorphismPcGroup(G);
    GI:=Image(map,G);
  else
    map:=fail;
    GI:=G;
  fi;
  s:=SubgroupsSolvableGroup(GI,rec(retnorm:=true));
  classes:=[];
  for i in [1..Length(s[1])] do
    if map=fail then
      c:=ConjugacyClassSubgroups(G,s[1][i]);
      SetStabilizerOfExternalSet(c,s[2][i]);
    else
      c:=ConjugacyClassSubgroups(G,PreImage(map,s[1][i]));
      SetStabilizerOfExternalSet(c,PreImage(map,s[2][i]));
    fi;
    Add(classes,c);
  od;
  SortBy(classes, a -> Size(Representative(a)));

  # create the lattice
  lattice:=Objectify(NewType(FamilyObj(classes),IsLatticeSubgroupsRep),
                     rec());
  lattice!.conjugacyClassesSubgroups:=classes;
  lattice!.group     :=G;

  # return the lattice
  return lattice;

end);

# #############################################################################
# ##
# #M  NormalSubgroups(<G>)  . . . . . . . . . .  list of normal subgroups
# ##
# InstallMethod(NormalSubgroups,"elementary abelian extension",true,
#   [CanEasilyComputePcgs],0,
# function(G)
# local n;
#   n:=SubgroupsSolvableGroup(G,rec(
#        actions:=List(GeneratorsOfGroup(G),i->InnerAutomorphism(G,i)),
#        normal:=true));
#
#   # sort the normal subgroups according to their size
#   SortBy(n, Size);
#
#   return n;
# end);

#############################################################################
##
#F  SizeConsiderFunction(<size>)  returns auxiliary function for
##  'SubgroupsSolvableGroup' that allows one to discard all subgroups whose
##  size is not divisible by <size>
##
InstallGlobalFunction(SizeConsiderFunction,function(size)
  return function(c,a,n,b,m)
           return IsInt(Size(a)/Size(n)*Size(b)*Size(m)/size);
         end;
end);

#############################################################################
##
#F  ExactSizeConsiderFunction(<size>)  returns auxiliary function for
##  'SubgroupsSolvableGroup' that allows one to discard all subgroups whose
##  size is not <size>
##
InstallGlobalFunction(ExactSizeConsiderFunction,function(size)
  return function(c,a,n,b,m)
           local result;
           result:=IsInt(Size(a)/Size(n)*Size(b)*Size(m)/size)
              and not (Size(a)/Size(n)*Size(b))>size;
           return result;
         end;
end);

BindGlobal("ElementaryAbelianConsider",
function(c,a,n,b,m)
  return HasElementaryAbelianFactorGroup(a,n) and
    ForAll(GeneratorsOfGroup(a),x->ForAll(GeneratorsOfGroup(b),y->Comm(x,y)
    in m));
end);
