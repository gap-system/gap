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
##  This file contains the implementation of the Dixon-Schneider algorithm
##


#############################################################################
##
#V  USECTPGROUP . . . . . . . . . . indicates,whether CharTablePGroup should
##                                  always be called
USECTPGROUP := false;


#############################################################################
##
#V  DXLARGEGROUPORDER
##
##  If a group is small,we may use enumerations of the elements to speed up
##  the computations. The criterion is the size, compared to the global
##  variable DXLARGEGROUPORDER.
##
if not IsBound(DXLARGEGROUPORDER) then
  DXLARGEGROUPORDER:=10000;
fi;

InstallGlobalFunction( IsDxLargeGroup, G -> Size(G) > DXLARGEGROUPORDER );


#############################################################################
##
#F  ClassComparison(<c>,<d>)  . . . . . . . . . . . . compare classes c and d
##
##  comparison is based first on the size of the class and afterwards on the
##  order of the representatives. Thus the 1-Class is in the first position,
##  as required. Since sorting is primary by the class sizes,smaller
##  classes are in earlier positions,making the active columns those to
##  smaller classes,reducing the work for calculating class matrices!
##  Additionally galois conjugated classes are together,thus increasing the
##  chance,that with one columns of them active to be several acitive,
##  reducing computation time !
##
InstallGlobalFunction( ClassComparison, function(c,d)
  if Size(c)=Size(d) then
    return Order(Representative(c))<Order(Representative(d));
  else
    return Size(c)<Size(d);
  fi;
end );


#############################################################################
##
#M  DixonRecord(<G>) . . . . . . . . . .  generic
##
InstallMethod(DixonRecord,"generic",true,[IsGroup],0,
function(G)
local D,C,cl,pl;
  D:=rec(
          group:=G,# workgroup
          deg:=Size(G),
          size:=Size(G),
          # when do we consider a class as large, so we might do something
          # special?
          classlimit:=10^6,
          calculatedMats:=[],
          yetmats:=[],
          modulars:=[]
        );

  # Do not leave the computation of power maps to 'CharacterTable',
  # since here we are in a better situation (use inverse map,use
  # class identification,use the fact that all power maps for primes
  # up to the maximal element order are computed).
  C:=CharacterTable(G);

  # Store the conjugacy classes compatibly with other information
  # about the character table.
  D.classes:= ConjugacyClasses( C );
  cl:=ShallowCopy(D.classes);
  D.classreps:=List(cl,Representative);
  D.centfachom:=[];
  D.klanz:=Length(cl);
  D.classrange:=[1..D.klanz];
  Info(InfoCharacterTable,1,D.klanz," classes");

  # compute the permutation we apply to the classes
  pl:=[1..D.klanz];
  SortParallel(cl,pl,ClassComparison);
  D.perm:=PermList(pl);
  D.permlist:=pl;
  D.invpermlist:=ListPerm(D.perm^-1,Length(D.permlist));
  D.currentInverseClassNo:=0;

  D.characterTable:=C;
  D.classiz:=SizesConjugacyClasses(C);
  D.centralizers:=SizesCentralizers(C);
  D.orders:=OrdersClassRepresentatives(C);

  IsAbelian(G); # force computation
  DxPreparation(G,D);

  return D;
end);

#############################################################################
##
#F  DxCalcAllPowerMaps(<D>) . . . . . . . calculate power maps for char.table
##
BindGlobal( "DxCalcAllPowerMaps", function(D)
local p,primes,i,cl,spr,j,allpowermaps,pm,ex;

  # compute the inverse classes
  p:=[1];
  for i in [2..D.klanz] do
    p[i]:=D.ClassElement(D,D.classreps[i]^-1);
  od;
  SetInverseClasses(D.characterTable,p);
  D.inversemap:=p;

  allpowermaps:=ComputedPowerMaps(D.characterTable);
  allpowermaps[1]:= Immutable( D.classrange );
  D.powermap:=allpowermaps;

  # get all primes smaller than the largest element order
  primes:=[];
  p:=2;
  pm:=Maximum(D.orders);
  while p<=pm do
    Add(primes,p);
    p:=NextPrimeInt(p);
  od;

  for p in primes do
    allpowermaps[p]:=List(D.classrange,i->ShallowCopy(D.classrange));
    allpowermaps[p][1]:=1;
    #allpowermaps[p]:=InitPowerMap(D.characterTable,p);
  od;

  for p in primes do
#T ConsiderSmallerPowermaps?
# eventuell,bei kleinen Gruppen kostet das aber zu viel. Hier ist es
# vermutlich sinnvoller erst von Hand anzufangen.
    spr:=Filtered(primes,i->i<p);
    pm:=allpowermaps[p];

    # First try to compute cheap images.
    for i in D.classrange do
      if IsList(pm[i]) and Length(pm[i])=1 then
        pm[i]:=pm[i][1];
      fi;

      if not IsInt(pm[i]) then
        cl:=i;
        ex:=p mod D.orders[i];
if ex=0 then
  pm[i]:=1;
else
        if ex>D.orders[i]/2 then
          # can we get it cheaper via the inverse
          ex:=AbsInt(D.orders[i]-ex);
          cl:=D.inversemap[i];
        fi;
        if ex<p or (ex=p and IsInt(pm[cl])) then
          # compose the ex-th power
          j:=Factors(ex);
          while Length(j)>0 do
            cl:=allpowermaps[j[1]][cl];
            j:=j{[2..Length(j)]};
          od;
          pm[i]:=cl;
        fi;
fi;
      fi;
    od;

    # Do the hard computations.
    for i in Reversed(D.classrange) do
      if not IsInt(pm[i]) then
          pm[i]:=D.ClassElement(D,D.classreps[i]^(p mod D.orders[i]));
#T TestConsistencyMaps (local improvement!) after each calculation?
        # note following powers: (x^a)^b=(x^b)^a
        for j in spr do
          cl:=allpowermaps[j][i];
          if not IsInt(pm[cl]) then
            pm[cl]:=allpowermaps[j][pm[i]];
          fi;
        od;
      fi;
    od;

    MakeImmutable( pm );
  od;
end );

#############################################################################
##
#F  DxCalcPrimeClasses(<D>)
##
##  Compute primary classes of the group $G$,that is,every class of $G$
##  is the power of one of these classes.
##  'DxCalcPrimeClasses(<D>)' returns a list,each entry being a list whose
##  $i$-th entry is the $i$-th power of a primary class.
##
##  It is assumed that the power maps for all primes up to the maximal
##  representative order of $G$ are known.
##
BindGlobal( "DxCalcPrimeClasses", function(D)
local primeClasses,
      classes,
      i,
      j,
      class,
      p;

  primeClasses:=[];
  classes:=[1..D.klanz];
  for i in Reversed(classes) do
    primeClasses[i]:=[];
    if IsBound(classes[i]) then
      class:=i;
      j:=1;
      while 1<class do
        if class<>i then
          Unbind(classes[class]);
        fi;
        primeClasses[i][j]:=class;
        j:=j+1;
        class:=i;
        for p in Factors(j) do
          class:=D.powermap[p][class];
        od;
      od;
    fi;
  od;
  D.primeClasses:=[];
  for i in classes do
    Add(D.primeClasses,primeClasses[i]);
  od;
  D.primeClasses[1]:=[1];

end );

#############################################################################
##
#F  DxIsInSpace(v,space)
##
BindGlobal( "DxIsInSpace", function(v,r)
  return SolutionMat(Matrix(BaseDomain(r.base[1]),r.base),v)<>fail;
end );

#############################################################################
##
#F  DxNiceBasis(D,space) . . . . . . . . . . . . . nice basis of space record
##
BindGlobal( "DxNiceBasis", function(d,r)
local b;
  if not IsBound(r.niceBasis) then
    b:=Matrix(BaseDomain(r.base[1]),List(r.base,i->i{d.permlist})); # copied and permuted according to order
    TriangulizeMat(b);
    b:=List(b,i->i{d.invpermlist}); # permuted back
    r.niceBasis:=Immutable(b);
  fi;
  Assert(1,Length(r.niceBasis)=Length(r.base));
  return r.niceBasis;
end );

#############################################################################
##
#F  DxActiveCols(D,<space|base>)  . . . . . . active columns of space or base
##
BindGlobal( "DxActiveCols", function(D,raum)
local base,activeCols,j,n,l;
  activeCols:=[];
  if IsRecord(raum) then
    n:=Zero(D.field);
    if IsBound(raum.activeCols) then
      return raum.activeCols;
    fi;
    base:=DxNiceBasis(D,raum);
  else
    n:=Zero(D.field);
    base:=DxNiceBasis(D,rec(base:=raum));
  fi;
  l:=1;
  # find columns in order as given in pl as active
  for j in [1..Length(base)] do
    while base[j][D.permlist[l]]=n do
      l:=l+1;
    od;
    Add(activeCols,D.permlist[l]);
  od;
  if IsRecord(raum) then
    raum.activeCols:=activeCols;
  fi;
  return activeCols;
end );


#############################################################################
##
#F  DxRegisterModularChar(<D>,<c>)  . . . . .  note newly found irreducible
#F                                                     character modulo prime
##
BindGlobal( "DxRegisterModularChar", function(D,c)
local d,p;
  # it may happen,that an irreducible character will be registered twice:
  # 2-dim space,1 Orbit,combinatoric split. Avoid this!
  if IsPlistRep(c) then c:=Vector(c); fi;
  if not(c in D.modulars) then
    Add(D.modulars,c);
    d:=Int(c[1]);
    D.deg:=D.deg-d^2;
    D.num:=D.num-1;
    p:=1;
    while p<=Length(D.degreePool) do
      if D.degreePool[p][1]=d then
        D.degreePool[p][2]:=D.degreePool[p][2]-1;
        # filter still possible character degrees:
        p:=1;
        d:=1;
        # determinate smallest possible degree (nonlinear)
        while p<=Length(D.degreePool) and d=1 do
          if D.degreePool[p][2]>1 then
            d:=D.degreePool[p][1];
          fi;
          p:=p+1;
        od;
        # degreeBound
        d:=RootInt(D.deg-(D.num-1)*d);
        D.degreePool:=Filtered(D.degreePool,i->i[2]>0 and i[1]<=d);
        p:=Length(D.degreePool)+1;
      fi;
      p:=p+1;
    od;
  fi;
end );

#############################################################################
##
#F  DxIncludeIrreducibles(<D>,<new>,[<newmod>]) . . . . handle (newly?) found
#F                                                               irreducibles
##
##  This routine will do all handling,whenever characters have been found
##  by other means,than the Dixon/Schneider algorithm. First the routine
##  checks,which characters are not new (this allows one to include huge bulks
##  of irreducibles got by tensoring). Then the characters are closed under
##  images of the CharacterMorphisms. Afterwards the character spaces are
##  stripped of the new characters,the characters are included as
##  irreducibles and possible degrees etc. are corrected. If the modular
##  images of the irreducibles are known, they may be given in newmod.
##
InstallGlobalFunction( DxIncludeIrreducibles, function(arg)
local i,pcomp,m,r,D,neue,tm,news,opt;

  D:=arg[1];
  opt:=ValueOption("noproject");
  # force computation of all images under $\cal T$. We will need this
  # (among others),to be sure,that we can keep the stabilizers
  neue:=arg[2];
  if Length(neue) = 0 then return; fi;

  if IsBound(D.characterMorphisms) then
    tm:=D.characterMorphisms;
    news:=Union(List(neue,i->Orbit(tm,i,D.asCharacterMorphism)));
    if Length(news)>Length(neue) then
      Info(InfoCharacterTable,1,"new Characters by character morphisms found");
    fi;
    neue:=news;
  fi;
  neue:=Difference(neue,D.irreducibles);
  D.irreducibles:=Concatenation(D.irreducibles,neue);
  if Length(arg)=3 then
    m:=Difference(arg[3],D.modulars);
    if IsBound(D.characterMorphisms) then
      m:=Union(List(m,i->Orbit(tm,i,D.asCharacterMorphism)));
    fi;
  else
    m:=List(neue,i->List(i,D.modularMap));
  fi;
  for i in m do
    DxRegisterModularChar(D,i);
  od;

  if opt<>true then
    pcomp:=NullspaceMat(D.projectionMat*TransposedMatImmutable(Matrix(D.field,D.modulars)));
    if Length(pcomp)>0 then
      for i in [1..Length(D.raeume)] do
        r:=D.raeume[i];
        if r.dim = Length(r.base[1]) then
          # trivial case: Intersection with full space in the beginning
          r:=rec(base:=pcomp);
        else
          r:=rec(base:=SumIntersectionMat(pcomp,
            Matrix(BaseDomain(r.base[1]),r.base))[2]);
        fi;
        r.dim:=Length(r.base);
        # note stabilizer
        if IsBound(D.raeume[i].stabilizer) then
          r.stabilizer:=D.raeume[i].stabilizer;
        fi;
        if r.dim>0 then
          DxActiveCols(D,r);
        fi;
        D.raeume[i]:=r;
      od;
    fi;
  fi;
  D.raeume:=Filtered(D.raeume,i->i.dim>0);
end );


#############################################################################
##
#F  DxLinearCharacters(<D>) . . . .   calculate characters of G of degree 1
##
##  These characters are computed as characters of G/G'. This can be done
##  easily by using the fact,that an abelian group is direct product of
##  cyclic groups. Thus we get the characters as "direct products" of the
##  characters of cyclic groups,which can be easily computed. They are
##  lifted afterwards back to G.
##
BindGlobal( "DxLinearCharacters", function(D)
local H,T,c,a,e,f,i,j,k,l,m,p,ch,el,ur,s,hom,gens,onc,G;
  G:=D.group;
  onc:=List([1..D.klanz],i->1);
  D.trivialCharacter:=onc;
  H:=DerivedSubgroup(G);
  hom:=NaturalHomomorphismByNormalSubgroup(G,H);
  H:=Image(hom,G);
  e:=ShallowCopy(AsList(H));
  s:=Length(e); # Size(H)
  if s=1 then # perfekter Fall
    D.tensorMorphisms:=rec(a:=[],
                           c:=[],
                           els:=[[[],onc]]);
    return [onc];
  else
    a:=Reversed(AbelianInvariants(H));
    gens:=[];
    T:=Subgroup(H,gens);
    for i in a do
      # was: m:=First(e,el->Order(el)=i);
      m:=First(e,
          el->Order(el)=i and ForAll([2..Order(el)-1],i->el^i in e));
      T:=ClosureGroup(T,m);
      e:=Difference(e,AsList(T));
      Add(gens,m);
    od;
    e:=AsList(H);
    f:=List(e,i->[]);
    for i in [1..D.klanz] do # create classimages
      Add(f[Position(e,Image(hom,D.classreps[i]))],i);
   od;

    m:=Length(a);
    c:=List([1..m],i->[]);
    i:=m;
    # run through all Elements of H by trying every combination of the
    # generators
    p:=List([1..m],i->0);
    while i>0 do
      el:=One(H); # Element berechnen
      for j in [1..m] do
        el:=el*gens[j]^p[j];
      od;
      ur:=f[Position(e,el)];
      for j in [1..m] do # all character values for this element
        ch:=E(a[j])^p[j];
        for l in ur do
          c[j][l]:=ch;
        od;
      od;
      while (i>0) and (p[i]=a[i]-1) do
        p[i]:=0;
        i:=i-1;
      od;
      if i>0 then
        p[i]:=p[i]+1;
        i:=m;
      fi;
    od;

    ch:=[];
    i:=m;
    p:=List([1..m],i->0);
    while i>0 do
      # construct tensor product systematically
      el:=ShallowCopy(onc);
      for j in [1..m] do
        for k in [1..D.klanz] do
          el[k]:=el[k]*c[j][k]^p[j];
        od;
      od;
      Add(ch,[ShallowCopy(p),el]);
      while (i>0) and (p[i]=a[i]-1) do
        p[i]:=0;
        i:=i-1;
      od;
      if i>0 then
        p[i]:=p[i]+1;
        i:=m;
      fi;
    od;
    D.tensorMorphisms:=rec(a:=a,
                           c:=c,
                           els:=ch);

    ch:=List(ch,i->i[2]);
    return ch;
  fi;
end );


#############################################################################
##
#F  DxLiftCharacter(<D>,<modChi>) . recalculate character in characteristic 0
##
BindGlobal( "DxLiftCharacter", function(D,modular)
local modularchi,chi,zeta,degree,sum,M,l,s,n,j,polynom,chipolynom,
      family,prime;
  prime:=D.prime;
  modularchi:=List(modular,Int);
  degree:=modularchi[1];
  chi:=[degree];
  for family in D.primeClasses do
    # we need to compute the polynomial only for prime classes. Powers are
    # obtained by simply inserting powers in this polynomial
    j:=family[1];
    l:=Order(D.classreps[j]);
    zeta:=E(l);
    polynom:=[degree,modularchi[j]];
    for n in [2..l-1] do
      s:=family[n];
      polynom[n+1]:=modularchi[s];
    od;
    chipolynom:=[];
    s:=0;
    sum:=degree;
    while sum>0 do
      M:=DxModularValuePol(polynom,
                         PowerModInt(D.z,-s*Exponent(D.group)/l,prime),
                         #PowerModInt(D.z,-s*D.irrexp/l,prime),
                         prime)/l mod prime;
      Add(chipolynom,M);
      sum:=sum-M;
      s:=s+1;
    od;
    for n in [1..l-1] do
      s:=family[n];
      if not IsBound(chi[s]) then
        chi[s]:=ValuePol(chipolynom,zeta^n);
      fi;
    od;
  od;
  return chi;
end );


#############################################################################
##
#F  SplitCharacters(<D>,<list>)   split characters according to the spaces
#F   this function can be applied to ordinary characters. It splits them
#F   according to the character spaces yet known. This can be used
#F   interactively to utilize partially computed spaces
##
InstallGlobalFunction( SplitCharacters, function(D,l)
local ml,nu,ret,r,p,v,alo,ofs,orb,i,j,inv,b;
  b:=Filtered(l,i->(i[1]>1) and (i[1]<D.prime/2));
  l:=Difference(l,b);
  ml:=List(b,i->List(i,D.modularMap));
  nu:=List(D.classrange,i->Zero(D.field));
  ret:=[];
  b:=ShallowCopy(D.modulars);
  alo:=Length(b);
  ofs:=[];
  for r in D.raeume do
    # recreate all images
    orb:=Orbit(D.characterMorphisms,r,
      function(raum,el)
      local img;
        img:=D.asCharacterMorphism(raum.base[1],el);
        img:=First(D.raeume,
          function(i)
          local c;
            c:=Concatenation(List(i.base,ShallowCopy),[ShallowCopy(img)]);
            return RankMat(c)=Length(i.base);
          end);
        if img=fail then
          img:=rec(base:=List(raum.base,i->D.asCharacterMorphism(i,el)),
                   dim:=raum.dim);
        fi;
        return img;
      end);
    for i in orb do
      if not IsMutable(i) then
        i:=ShallowCopy(i);
      fi;
      b:=Concatenation(b,DxNiceBasis(D,i));
      Add(ofs,[alo+1..Length(b)]);
      alo:=Length(b);
    od;
  od;
  inv:=Matrix(BaseDomain(b[1]),b)^(-1);
  for i in ml do
    v:=i*inv;
    for r in [1..Length(D.raeume)] do
      p:=ShallowCopy(nu);
      for j in ofs[r] do
        p[j]:=v[j];
      od;
      p:=p*b;
      if not IsZero(p) then
        AddSet(ret,DxLiftCharacter(D,p));
      fi;
    od;
  od;
  return Union(ret,l);
end );


#############################################################################
##
#F  DxEigenbase(<mat>) . . . . . components of Eigenvects resp. base
##
BindGlobal( "DxEigenbase", function(M)
  local dim,i,eigenvalues,base,minpol,bases;

  minpol:=MinimalPolynomial(BaseDomain(M),M);

  Assert(2,IsDuplicateFree(RootsOfUPol(minpol)));
  eigenvalues:=Set(RootsOfUPol(minpol));
  dim:=0;
  bases:=[];
  for i in eigenvalues do
    base:=NullspaceMat(M-i*M^0);
    if base=[] then
      Error("This can`t happen: Wrong Eigenvalue ???");
    else
      dim:=dim+Length(base);
      Add(bases,base);
    fi;
  od;
  if dim<>Length(M) then
    Error("Failed to calculate eigenspaces.");
  fi;

  Assert(3, ForAll([1..Length(bases)],j->bases[j]*M = bases[j]*eigenvalues[j]));
  return rec(base:=bases,
             values:=eigenvalues);
end );


#############################################################################
##
#F  SplitStep(<D>,<bestMat>)  . . . . . .  calculate matrix bestMat as far as
#F                                                    needed and split spaces
##
InstallGlobalFunction(SplitStep,function(D,bestMat)
  local raeume,base,M,bestMatCol,bestMatSplit,i,j,k,N,row,col,Row,o,dim,
        newRaeume,raum,ra,f,activeCols,eigenbase,eigen,v,vo,partial;

  if not bestMat in D.matrices then
    Error("matrix <bestMat> not indicated for splitting");
  fi;

  k:=D.klanz;

  f:=D.field;
  o:=D.one;
  raeume:=D.raeume;

  if ForAny(raeume,i->i.dim>1) then
    bestMatCol:=D.requiredCols[bestMat];
    bestMatSplit:=D.splitBases[bestMat];
    M:= ZeroMatrix(Integers,k,k);

    Info(InfoCharacterTable,1,"Matrix ",bestMat,",Representative of Order ",
       Order(D.classreps[bestMat]),
       ",Centralizer: ",D.centralizers[bestMat]);
    Info(InfoCharacterTable,2,"Splitting Nr.s",bestMatSplit,
      "of dimensions ",List(D.raeume{bestMatSplit},x->x.dim));

    partial:=false;
    if D.classiz[bestMat]>D.classlimit then
      Info(InfoWarning,1,"computing class matrix for class of size >",
        D.classlimit);
      if Length(bestMatSplit)>1 then
        i:=List(bestMatSplit,x->D.raeume[x].dim);
        i:=bestMatSplit[Position(i,Minimum(i))];
        bestMatSplit:=[i];
        bestMatCol:=Set(D.raeume[i].activeCols);
        if not IsBound(D.calculatedMats[bestMat]) then
          D.calculatedMats[bestMat]:=
            List([1..k],x->ListWithIdenticalEntries(k,0));
        fi;
        # need and known
        col:=Union(bestMatCol,Filtered([1..k],num->ForAny([1..k],
          x->not IsZero(D.calculatedMats[bestMat][x][num]))));
        # do we get other spaces for free ?
        i:=Filtered(D.splitBases[bestMat],
          x->IsSubset(col,D.raeume[x].activeCols));
        if i<>bestMatSplit then
          bestMatSplit:=Union(i,bestMatSplit);
          bestMatCol:=Union(List(bestMatSplit,x->D.raeume[x].activeCols));
        fi;

        Info(InfoCharacterTable,1,"Partial:",bestMatSplit);
        partial:=true;
      fi;
    fi;

    if not partial then
      Add(D.yetmats,bestMat);
      SubtractSet(D.matrices,[bestMat]);
    fi;
    Info(InfoCharacterTable,2,"Columns: ",bestMatCol);

    for col in bestMatCol do
      if IsBound(D.calculatedMats[bestMat]) and
        ForAny([1..k],x->not IsZero(D.calculatedMats[bestMat][x][col])) then
        Info(InfoCharacterTable,2,"Re-using cached column ",col);
        for i in [1..k] do
          M[i][col]:=D.calculatedMats[bestMat][i][col];
        od;
      else
        D.ClassMatrixColumn(D,M,bestMat,col);
        if partial then
          for i in [1..k] do
            D.calculatedMats[bestMat][i][col]:=M[i][col];
          od;
        fi;
      fi;
    od;

    M:=Matrix(D.field,Unpack(M)*o);

    # note,that we will have calculated yet one!
    D.maycent:=true;

    newRaeume:=[];
    for i in bestMatSplit do
      raum:=raeume[i];
      base:=DxNiceBasis(D,raum);
      dim:=raum.dim;
      # cut out the 'active part' for computation of an eigenbase
      activeCols:=DxActiveCols(D,raum);
      N:= ZeroMatrix(f,dim,dim);
      for row in [1..dim] do
        #Row:=base[row]*M;
        Row:=CompatibleVector(M);
        for col in [1..Length(Row)] do
          Row[col]:=base[row,col];
        od;
        Row:=Row*M;
        for col in [1..dim] do
          N[row,col]:=Row[activeCols[col]];
        od;
      od;
      eigen:=DxEigenbase(N);
      # Base umrechnen
      base:=Matrix(BaseDomain(base[1]),base);
      eigenbase:=List(eigen.base,i->List(i,j->j*base));

      Assert(1,Length(eigenbase)>1);

      ra:=List(eigenbase,i->rec(base:=i,dim:=Length(i)));

      # throw away Galois-images
      for i in [1..Length(ra)] do
        if IsBound(ra[i]) then
          vo:=Orbit(raum.stabilizer,ra[i].base[1],
                   D.asCharacterMorphism);
          for v in vo do
            for j in [i+1..Length(ra)] do
              if IsBound(ra[j])

                # ahulpke, 11-jan-00: If we map into a larger space, the
                # extra dimension of the larger space might somehow get
                # lost. Therefore we can't be that tricky as the following
                # argument supposes.
                  # In characteristic p the split may be
                  # not as well,as in characteristic 0. In this
                  # case,we may find a smaller image in another space.
                  # As character morphisms are a group we will also
                  # have the inverse image of the complement, we can
                  # throw away the space without doing harm!
                  # the only ugly disadvantage is,that we will have to
                  # do some more inclusion tests.

                and ra[i].dim=ra[j].dim
                and DxIsInSpace(v,ra[j]) then
                  Unbind(ra[j]);
              fi;
            od;
          od;
        fi;
      od;

      for i in ra do
        # force computation of base
        i.dim:=Length(i.base);
        DxNiceBasis(D,i);
        if IsBound(raum.stabilizer) then
          i.approxStab:=raum.stabilizer;
        fi;
        Add(newRaeume,i);
      od;

    od;
    # add the ones that did not split
    for i in [1..Length(raeume)] do
      if not i in bestMatSplit then
        Add(newRaeume,raeume[i]);
      fi;
    od;
    raeume:=newRaeume;
  fi;

  for i in [1..Length(raeume)] do
    if raeume[i].dim>1 then
      DxActiveCols(D,raeume[i]);
    fi;
  od;

  Info(InfoCharacterTable,1,"Dimensions: ",Collected(List(raeume,i->i.dim)));
  D.raeume:=raeume;
  return true;
end);


#############################################################################
##
#F  CharacterMorphismOrbits(<D>,<space>) . . stabilizer and invariantspace
##
BindGlobal( "CharacterMorphismOrbits", function(D,space)
  local a,b,s,o,gen,b1;
  if not IsBound(space.stabilizer) then
    if IsBound(space.approxStab) then
      a:=space.approxStab;
    else
      a:=D.characterMorphisms;
    fi;
    space.stabilizer:=Stabilizer(a,VectorSpace(D.field,space.base),
                                 D.asCharacterMorphism);
  fi;
  if not IsBound(space.invariantbase) then
    o:=D.one;
    s:=space.stabilizer;
    b:=DxNiceBasis(D,space);
    a:=DxActiveCols(D,space);
    # calculate invariant space as intersection of E.S to E.V. 1
    for gen in GeneratorsOfGroup(s) do
      if Length(b)>0 then
        b1:=NullspaceMat(List(b,i->D.asCharacterMorphism(i,gen){a})
                -IdentityMat(Length(b),o));
        if Length(b1)=0 then
          b:=[];
        else
          b:=b1*b;
        fi;
      fi;
#T cheaper!
      b:=rec(base:=b,dim:=Length(b));
      a:=DxActiveCols(D,b);
      b:=DxNiceBasis(D,b);
    od;
    space.invariantbase:=b;
  fi;
  return rec(invariantbase:=space.invariantbase,
             number:=Length(space.invariantbase),
             stabilizer:=space.stabilizer);
end );



#############################################################################
##
#F  DxModProduct(<D>,<vector1>,<vector2>) . . . product of two characters mod p
##
BindGlobal( "DxModProduct", function(D,v1,v2)
  local prod,i;
  prod:=0*D.one;
  for i in [1..D.klanz] do
    prod:=prod+ (D.classiz[i] mod D.prime)*v1[i]
                *v2[D.inversemap[i]];
  od;
  prod:=prod/(D.size mod D.prime);
  return prod;
end );


#############################################################################
##
#F  DxFrobSchurInd(<D>,<char>) . . . . . . modular Frobenius-Schur indicator
##
BindGlobal( "DxFrobSchurInd", function(D,char)
  local FSInd,classes,l,ll,L,family;
  FSInd:=char[1];
  classes:=[2..D.klanz];
  for family in D.primeClasses do
    L:=Length(family)+1;
    for l in [1..L-1] do
      if family[l] in classes then
        ll:=2*l mod L;
        if ll=0 then
          FSInd:=FSInd+(D.classiz[family[l]] mod D.prime)
                       *char[1];
        else
          FSInd:=FSInd+(D.classiz[family[l]] mod D.prime)
                       *char[family[ll]];
       fi;
        SubtractSet(classes,[family[l]]);
      fi;
    od;
  od;
  return FSInd/(D.size mod D.prime);
end );


#############################################################################
##
#F  SplitTwoSpace(<D>,<raum>) . . . split two-dim space by combinatoric means
##
##  If the room is 2-dimensional, this is meant to be the standard split.
##  Otherwise,the two-dim invariant space of raum is to be split
##
BindGlobal( "SplitTwoSpace", function(D,raum)
  local v1,v2,v1v1,v1v2,v2v1,v2v2,degrees,d1,d2,deg2,prime,o,f,d,degrees2,
        lift,root,p,q,n,char,char1,char2,a1,a2,i,NotFailed,k,l,m,test,ol,
        di,rp,mdeg2,mult,str;

  mult:=Index(D.characterMorphisms,CharacterMorphismOrbits(D,raum).stabilizer);
  f:=raum.dim=2; # space or invariant space split indicator flag
  prime:=D.prime;
  rp:=Int(prime/2);
  o:=D.one;
  if f then
    v1:=DxNiceBasis(D,raum);
    v2:=v1[2];
    v1:=v1[1];
    ol:=[1];
  else
    Info(InfoCharacterTable,1,"Attempt:",raum.dim);
    v1:=raum.invariantbase[1];
    v2:=raum.invariantbase[2];
    ol:=Filtered(DivisorsInt(Size(raum.stabilizer)),i->i<raum.dim/2+1);
  fi;
  v1v1:=DxModProduct(D,v1,v1);
  v1v2:=DxModProduct(D,v1,v2);
  v2v1:=DxModProduct(D,v2,v1);
  v2v2:=DxModProduct(D,v2,v2);
  char:=[];
  char2:=[];
  NotFailed:=not IsZero(v2v2);
  di:=1;
  while di<=Length(ol) and NotFailed do
    d:=ol[di];
    degrees:=DxDegreeCandidates(D,d*mult);
    if f then
      degrees2:=degrees;
    else
      degrees2:=DxDegreeCandidates(D,(raum.dim-d)*mult);
    fi;
    mdeg2:=List(degrees2,i->i mod prime);
    i:=1;
    while i<=Length(degrees) and NotFailed do
      lift:=true;
      d1:=degrees[i];
      if d1*d>rp then
        lift:=false;
      fi;
      p:=(v2v1+v1v2)/v2v2;
      q:=(v1v1-o/(d*(d1^2) mod D.prime))/v2v2;

      for root in SquareRoots(D.field,(p/2)^2-q) do
        a1:=(-p/2+root);
        n:=v1v2+a1*v2v2;
        if (n=0*o) then
          # proceeding would force a division by zero
          NotFailed:=false;
        else
          a2:=-(v1v1+a1*v2v1)/n;
          n:=v1v1+a2*(v1v2+v2v1)+a2^2*v2v2;
          if n<>0*o then
            deg2:=List(SquareRoots(D.field,o/(raum.dim-d)/n),Int);
            for d2 in deg2 do
              if d2 in mdeg2 then
                if not d2 in degrees2 or d2*(raum.dim-d)>rp then
                  # degree is too big for lifting
                  lift:=false;
                fi;
                char1:=[d*d1*(v1+a1*v2),(raum.dim-d)*d2*(v1+a2*v2)];

                if Length(char)>0 and
                  (char[1].base[1]=char1[2]) and
                  (char[2].base[1]=char1[1]) then
                    test:=false;
                else
                  test:=true;
                fi;
                l:=1;
                while (l<3) and test do
                  if f then
                    n:=1;
                  elif l=1 then
                    n:=d;
                  else
                    n:=raum.dim-d;
                  fi;
                  if not DxFrobSchurInd(D,char1[l]) in o*[-n..n]
                    then test:=false;
                  fi;
                  m:=DxLiftCharacter(D,char1[l]);
                  char2[l]:=m;
                  if test and lift then
                    for k in [2..Length(m)] do
                      if IsInt(m[k]) and AbsInt(m[k])>m[1] then
                        test:=false;
                      fi;
                    od;
                    if test and not IsInt(Sum(m)) then
                      test:=false;
                    fi;
                  fi;
                  l:=l+1;
                od;

                if test then
                  if Length(char)>0 then
                    NotFailed:=false;
                  else
                    char:=[rec(base:=[char1[1]],
                               char:=[char2[1]],
                               d:=d),
                           rec(base:=[char1[2]],
                               char:=[char2[2]],
                               d:=raum.dim-d)];
                  fi;
                fi;
              fi;
            od;
          fi;
        fi;
      od;
      i:=i+1;
    od;
    di:=di+1;
  od;
  if f then
    str:="Two-dim";
  else
    str:="Two orbit";
  fi;
  if NotFailed then
    Info(InfoCharacterTable,2,str," space split");
    return char;
  else
    Info(InfoCharacterTable,2,str," split failed");
    raum.twofail:=true;
    return [];
  fi;
end );


#############################################################################
##
#F  CombinatoricSplit(<D>)  . . . . . . . . .  split two-dimensional spaces
##
BindGlobal( "CombinatoricSplit", function(D)
local i,newRaeume,raum,neuer,j,ch,irrs,mods,incirrs,incmods,nb,rt,neuc;
  newRaeume:=[];
  incirrs:=[];
  incmods:=[];
  for i in [1..Length(D.raeume)] do
    raum:=D.raeume[i];
    if raum.dim=2 and not IsBound(raum.twofail) then
      neuer:=SplitTwoSpace(D,raum);
    else
      neuer:=[];
      if raum.dim=2 then
        # next attempt might work due to fewer degrees
        Unbind(raum.twofail);
      fi;
    fi;
    if Length(neuer)=2 then
      rt:=Difference(RightTransversal(D.characterMorphisms,
           CharacterMorphismOrbits(D,raum).stabilizer),
           [One(D.characterMorphisms)]);
      mods:=[];
      irrs:=[];
      for j in [1,2] do
        Info(InfoCharacterTable,2,"lifting character no.",
                        Length(D.irreducibles)+Length(incirrs));
        if IsBound(neuer[j].char) then
          ch:=neuer[j].char[1];
        else
          ch:=DxLiftCharacter(D,neuer[j].base[1]);
        fi;
        if not ch in D.irreducibles then
          Add(mods,neuer[j].base[1]);
          Add(incmods,neuer[j].base[1]);
          Add(irrs,ch);
          Add(incirrs,ch);
        fi;
      od;
      for j in rt do
        Info(InfoCharacterTable,1,"TwoDimSpace image");
        nb:=D.asCharacterMorphism(raum.base[1],j);
        neuc:=List(irrs,i->D.asCharacterMorphism(i,j));
        if not ForAny([i+1..Length(D.raeume)],i->DxIsInSpace(nb,D.raeume[i])) then
          incirrs:=Union(incirrs,neuc);
          incmods:=Union(incmods,List(mods,i->D.asCharacterMorphism(i,j)));
        else
          Error("#W  strange spaces due to inclusion of irreducibles!\n");
          Add(D.irreducibles,neuc[1]);
          Add(D.irreducibles,neuc[2]);
        fi;
      od;
    else
      Add(newRaeume,raum);
    fi;
  od;
  D.raeume:=newRaeume;
  if Length(incirrs)>0 then
    DxIncludeIrreducibles(D,incirrs,incmods:noproject);
  fi;
end );

#############################################################################
##
#F  OrbitSplit(<D>) . . . . . . . . . . . . . . try to split two-orbit-spaces
##
InstallGlobalFunction( OrbitSplit, function(D)
local i,s,ni,nm;
  ni:=[];
  nm:=[];
  for i in D.raeume do
    if i.dim=3 and not IsBound(i.twofail) and
       CharacterMorphismOrbits(D,i).number=2 then
      s:=SplitTwoSpace(D,i);
      if Length(s)=2 and s[1].d=1 then
        # character extracted
        Add(ni,s[1].char[1]);
        Add(nm,s[1].base[1]);
      fi;
    fi;
  od;
  if ni<>[] then
    DxIncludeIrreducibles(D,ni,nm);
  fi;
  CombinatoricSplit(D);
end );


#############################################################################
##
#F  DxModularValuePol(<f>,<x>,<p>)  . evaluate polynomial at a point,mod p
##
##  'DxModularValuePol' returns the value of the polynomial<f>at<x>,
##  regarding the result modulo p.<x>must be an integer number.
##
##  'DxModularValuePol' uses Horners rule to evaluate the polynom.
##
InstallGlobalFunction( DxModularValuePol, function (f,x,p)
local  value,i;
  value := 0;
  i := Length(f);
  while i>0  do
    value := (value * x + f[i]) mod p;
    i := i-1;
  od;
  return value;
end );


#############################################################################
##
#F  ModularCharacterDegree(<D>,<chi>) . . . . . . . . .  degree of normalized
#F                                                         character modulo p
##
BindGlobal( "ModularCharacterDegree", function(D,chi)
  local j,j1,d,sum,prime;
  prime:=D.prime;
  sum:=0*D.one;
  for j in [1..D.klanz] do
    j1:=D.inversemap[j];
    sum:=sum+chi[j]*chi[j1]*(D.classiz[j] mod prime);
  od;
  d:=RootMod(D.size/Int(sum) mod prime,prime);
  # take correct (smaller) root
  if 2*d>prime then
    d:=prime-d;
  fi;
  return d;
end );


#############################################################################
##
#F  DxDegreeCandidates(<D>,[<anz>]) . Potential degrees for anz characters of
#F     same degree,if num characters of total degree deg are yet to be found
##
InstallGlobalFunction( DxDegreeCandidates, function(arg)
  local D,anz,degrees,i,r;
  D:=arg[1];
  if Length(arg)>1 then
    anz:=arg[2];
    degrees:=[];
    if Length(D.degreePool)=0 then
      return [];
    fi;
    r:=RootInt(Int((D.deg-(D.num-anz)*D.degreePool[1][1]^2)/anz));
    i:=1;
    while i<=Length(D.degreePool) and D.degreePool[i][1]<=r do
      if D.degreePool[i][2]>anz then
        Add(degrees,D.degreePool[i][1]);
      fi;
      i:=i+1;
    od;
    return degrees;
  else
    return List(D.degreePool,i->i[1]);
  fi;
end );


#############################################################################
##
#F  DxSplitDegree(<D>,<space>,<r>)  estimate number of parts when splitting
##                space with matrix number r,according to charactermorphisms
##
InstallGlobalFunction( DxSplitDegree, function(D,space,r)
  local a,s,o,fix,k,l,i,j,gorb,v,w,
        base;
  # is perfect split guaranteed ?
  if IsBound(space.split) then
    return space.split;
  fi;
  o:=D.one;
  a:=CharacterMorphismOrbits(D,space);
  if a.number=space.dim then
    return 2; #worst possible split
  fi;
  if a.number=1 and IsPrime(space.dim) then
    # spaces of prime dimension with one orbit must split perfectly
    space.split:=space.dim;
    return space.dim;
  fi;
  # both cases,but MultiOrbit is not as effective
  s:=a.stabilizer;
  gorb:=D.galoisOrbits[r];
  fix:=Length(gorb)=1;
  if not fix then
    # Galois group acts trivial ? (seen if constant values on
    # rational class)
    i:=1;
    fix:=true;
    base:=DxNiceBasis(D,space);
    while fix and i<=Length(base) do
      v:=base[i];
      w:=v[r];
      for j in gorb do
        if v[j]<>w then
          fix:=false;
        fi;
      od;
      i:=i+1;
    od;
  fi;
  if fix then
    #l:=List(s.generators,i->i.tens[r]);
    l:=List(GeneratorsOfGroup(s),i->D.asCharacterMorphism(1,i).tens[r]);
    v:=[o];
    for i in v do
      for j in l do
        w:=i*j;
        if not w in v then
          Add(v,w);
        fi;
      od;
    od;
    return Length(v); #Length(Set(AsList(s),i->i.tens[r]));
  else
    # nonfix
    # v is an element from the space with non-galois-fix parts.
    l:=Maximum(List(TransposedMat(List(Orbit(s,v,D.asCharacterMorphism),
               i->i{D.galoisOrbits[r]})),i->Length(Set(i))));
    if a.number=1 then
# One orbit: number of resultant spaces must be a divisor of the dimension
      k:=DivisorsInt(space.dim);
      while l<space.dim and not l in k do
        l:=l+1;
      od;
    fi;
    return l;
  fi;
end );


#############################################################################
##
#F  DxGaloisOrbits(<D>,<f>) .  orbits of Stab_Gal(f) when acting on the classes
##
InstallGlobalFunction(DxGaloisOrbits,function(D,f)
local i,k,l,u,ga,galOp,p;
  k:=D.klanz;
  if not IsBound(D.galOp[f]) then
    galOp:=D.galOp;
    if f in MovedPoints(D.galMorphisms) then
      ga:=Stabilizer(D.galMorphisms,f);
    else
      ga:=D.galMorphisms;
    fi;
    p:=true;
    i:=1;
    while p and i<=Length(galOp) do
      if IsBound(galOp[i]) and
         galOp[i].group=ga then
          galOp[f]:=galOp[i];
          p:=false;
      else
        i:=i+1;
      fi;
    od;
    if p then
      galOp[f]:=rec(group:=ga);
      l:=List([1..k],i->Set(Orbit(ga,i)));
      galOp[f].orbits:=l;
      u:=List(Filtered(Collected(
        List(Set(l,i->i[1]),j->D.rids[j])),n->n[2]=1),t->t[1]);
      galOp[f].uniqueIdentifications:=u;
      galOp[f].identifees:=Filtered([1..k],i->D.rids[i] in u);
    fi;
  fi;
  return D.galOp[f];
end);

#############################################################################
##
#F  BestSplittingMatrix(<D>) . number of the matrix,that will yield the best
#F                                                                      split
##
##  This routine calculates also all required columns etc. and stores the
##  result in D
##
InstallGlobalFunction( BestSplittingMatrix, function(D)
local n,i,val,b,requiredCols,splitBases,wert,nu,r,rs,rc,bn,bw,split,
      orb,os,lim,ksl,dmats,imp;

  nu:=Zero(D.field);
  requiredCols:=List([1..D.klanz],x->[]);
  splitBases:=List([1..D.klanz],x->[]);
  wert:=[];
  os:=ForAll(D.raeume,i->i.dim<20); #only small spaces left?

  if Length(D.raeume)=0 then
    Error("nothing left to split!");
  fi;

  lim:=ValueOption("maxclasslen");
  if lim=fail then
    lim:=infinity;
  fi;

  ksl:=1;
  # try matrics by class sizes
  dmats:=[1..Length(D.classiz)];
  SortParallel(ShallowCopy(D.classiz),dmats);
  dmats:=Filtered(dmats,x->x in D.matrices);

  repeat
    for n in dmats do
      requiredCols[n]:=[];
      splitBases[n]:=[];
      wert[n]:=0;
      imp:=false;

      # only take classes small enough
      if D.classiz[n]<=lim and
      # dont start with central classes in small groups!
      (D.classiz[n]>ksl or IsBound(D.maycent)) then
        for i in [1..Length(D.raeume)] do
          r:=D.raeume[i];
          if IsBound(r.splits) then
            rs:=r.splits;
          else
            rs:=[];
            r.splits:=rs;
          fi;

          if r.dim>1 then

            if IsBound(rs[n]) then
              split:=rs[n].split;
              val:=rs[n].val;
            else
              b:=DxNiceBasis(D,r);
              split:=ForAny(b{[2..r.dim]},i->i[n]<>nu);
              imp:=imp or split;
              if split then
                if r.dim<4 then
                  # very small spaces will split nearly perfect
                  val:=8;
                else
                  bn:=DxSplitDegree(D,r,n);
                  if os then
                    if IsPerfectGroup(D.group) then
                      # G is perfect,no linear characters
                      # we can't predict much about the splitting
                      val:=Maximum(1,9-r.dim/bn);
                    else
                      val:=bn*Maximum(1,9-r.dim/bn);
                    fi;
                  else
                    val:=bn;
                  fi;
                fi;
                # note the images,which split as well
                val:=val*Index(D.characterMorphisms,
                              CharacterMorphismOrbits(D,r).stabilizer);
              else
                val:=0;
              fi;
              rs[n]:=rec(split:=split,val:=val);
            fi;
            if split then
              wert[n]:=wert[n]+val;
              Add(splitBases[n],i);
              requiredCols[n]:=Union(requiredCols[n],
                                      D.raeume[i].activeCols);
            fi;
          fi;
        od;
        if Length(splitBases[n])>0 then
          # can we use Galois-Conjugation
          orb:=DxGaloisOrbits(D,n);
          rc:=[];
          for i in requiredCols[n] do
            rc:=Union(rc,[orb.orbits[i][1]]);
          od;

          wert[n]:=wert[n]*D.centralizers[n] # *G/|K|
                  /(Length(rc)); # We count -mistakening - also the first
            # column,that is available for free. Its "costs" are meant to
            # compensate for the splitting process.
        fi;
      fi;
      # is there one that does all already? If so don't bother testing the
      # rest, as we go by cost
      if imp and Length(D.raeume)<=20
        and ForAll(D.raeume,x->IsBound(x.splits)) then

        rc:=Intersection(List(D.raeume,x->Filtered([1..Length(x.splits)],
          y->IsBound(x.splits[y]) and x.splits[y].split=true)));
        if Length(rc)>0 then
          for bw in rc do
            if not IsBound(wert[bw]) or wert[bw]=0 then
              wert[bw]:=Sum(D.raeume,x->x.splits[bw].val);
            fi;
            splitBases[bw]:=Union(splitBases[bw],[1..Length(D.raeume)]);
            for bn in D.raeume do
              requiredCols[bw]:=Union(requiredCols[bw],
                                      bn.activeCols);
            od;
          od;
          break;
        fi;
      fi;
    od;

    for r in D.raeume do
      if IsBound(r.splits) and Number(r.splits,x->x.split=true)=1 then
        # is room split by only ONE matrix?(then we need this sooner or later)
        n:=1;
        while not IsBound(r.splits[n]) or r.splits[n].split=false do
          n:=n+1;
        od;
        wert[n]:=wert[n]*10; #arbitrary increase of value
      fi;
    od;

    bn:=fail;
    bw:=0;
    # run through them in pl sequence
    for n in Filtered(D.permlist,i->i in D.matrices) do
      Info(InfoCharacterTable,3,n,":",Int(wert[n]));
      if IsBound(wert[n]) and wert[n]>bw then
        bn:=n;
        bw:=wert[n];
      fi;
    od;

    ksl:=ksl-1;
  until bn<>fail or ksl<0;

  if bn<>fail then
    D.requiredCols:=requiredCols;
    D.splitBases:=splitBases;
  fi;

  return bn;
end );


#############################################################################
##
#F  AsCharacterMorphismFunction(<pcgs>,<gals>,<tensormorphisms>)  operation
#F                               function for operation of charactermorphisms
##
BindGlobal( "AsCharacterMorphismFunction", function(pcgs,gals,tme)
  local i,j,k,x,g,c,lg,gens;
  lg:=Length(gals);
  return function(p,e)
    x:=ExponentsOfPcElement(pcgs,e);
    g:=();
    for i in [1..lg] do
      g:=g*gals[i]^x[i];
    od;
    x:=x{[lg+1..Length(x)]};
    i:=1;
    while tme[i][1]<>x do
      i:=i+1;
    od;
    x:=tme[i][3];
    if IsInt(p) then # integer works only as indicator: return galois and
                     # tensor part
      return rec(gal:=g,
                 tens:=x);
    elif IsList(p) and not IsList(p[1]) then
      if not IsFFE(p[1]) then
        # operation on characteristic 0 characters;
        x:=tme[i][2];
      fi;
      c:=[];
      for i in [1..Length(p)] do
        c[i]:=p[i/g]*x[i];
      od;
      return c;
    elif IsVectorSpace(p) then # Space
      gens:=BasisVectors(Basis(p));
      c:=List(gens,i ->[]);
      for i in [1..Length(gens[1])] do
        j:=i/g;
        for k in [1..Length(gens)] do
          c[k][i]:=gens[k][j] * x[i];
        od;
      od;
      return VectorSpace(LeftActingDomain(p),gens);
    else
      Error("action not defined");
    fi;
  end;
end );

#############################################################################
##
#F  CharacterMorphismGroup(<D>) . . . . create group of character morphisms
##
##  The group is stored in .characterMorphisms. It is an AgGroup,
##  according to the decomposition K=tens:gal as semidirect product. The
##  group acts as linear mappings that permute characters via the operation
##  .asCharacterMorphism.
##
BindGlobal( "CharacterMorphismGroup", function(D)
local tm,tme,piso,gpcgs,gals,ord,l,l2,f,fgens,rws,pow,pos,i,j,k,gen,
      cof,comm;
  tm:=D.tensorMorphisms;
  tme:=tm.els;

  piso:=IsomorphismPcGroup(D.galMorphisms);
  k:=Image(piso,D.galMorphisms);
  # Temporary workaround, 7/30/07, AH. It seems that permuting classes does
  # not easily transfer to mod p.
  k:=Image(piso,TrivialSubgroup(D.galMorphisms));
  gpcgs:=Pcgs(k);
  gals:=List(gpcgs,i->PreImagesRepresentative(piso,i));
  ord:=List(gpcgs,i->RelativeOrderOfPcElement(gpcgs,i));
  l:=Length(gpcgs);

  # add tensor relative orders
  tm.ro:=[];
  tm.re:=[];
  for i in tm.a do
    f:=Factors(i);

    Add(tm.ro,f[1]);
    Add(tm.re,Length(f));
  od;
  l2:=Length(ord)-l;

  f:=FreeGroup(IsSyllableWordsFamily,Length(ord));
  fgens:=GeneratorsOfGroup(f);
  rws:=SingleCollector(f,ord);

  # translate the gal-Relations:
  for i in [1..l] do
      SetPower( rws, i, ObjByExponents( rws,
              Concatenation(
                      ExponentsOfPcElement( gpcgs, gpcgs[i]^ord[i] ),
                      [1..l2] * 0 ) ) );
      for j in [i+1..l] do
          SetConjugate( rws, j, i, ObjByExponents( rws,
                  Concatenation(
                          ExponentsOfPcElement( gpcgs, gpcgs[j]^gpcgs[i] ),
                          [1..l2] * 0 ) ) );
      od;
  od;

  # correct the first and add last tme entries
  for i in tme do
    for j in [1..Length(i[1])] do
      cof:=CoefficientsQadic(i[1][j],tm.ro[j]);
      while Length(cof)<tm.re[j] do
        Add(cof,0);
      od;
      i[1][j]:=cof;
    od;
    i[1]:=Concatenation(i[1]);
    Add(i,List(i[2],D.modularMap));
  od;

  pow:=1;
  pos:=0;
  for i in [l+1..Length(ord)] do
    # get generator
    if pow=1 then
      # new position, new generator
      pos:=pos+1;
      gen:=tm.c[pos];
      pow:=tm.a[pos];
    else
      # power generator of last step
      gen:=List(gen,j->j^ord[i-1]);
    fi;

    # add the necessary tensor power relations
    if pow>ord[i] then
      SetPower(rws,i,fgens[i+1]);
    fi;

    pow:=pow/ord[i];

    # add commutator relations between galois and tensor
    for j in [1..l] do
      # compute commutator Comm(tens[i],gal[j])
      #comm:=Permuted(gen,gals[j]);
      #for k in [1..Length(comm)] do
      #  comm[k]:=gen[k]^-1*comm[k];
      #od;
      comm:=[];
      for k in [1..Length(comm)] do
        comm[k]:=gen[k]^-1*gen[k/gals[j]];
      od;

      # find decomposition
      k:=PositionProperty(tme,i->i[2]=comm);
      cof:=tme[k][1];
      comm:=One(f);
      for k in [1..Length(cof)] do
        comm:=comm*fgens[l+k]^cof[k];
      od;
      SetCommutator(rws,i,j,comm);
    od;
  od;
  tm:=GroupByRwsNC(rws);

  D.characterMorphisms:=tm;
  D.asCharacterMorphism:=AsCharacterMorphismFunction(HomePcgs(tm),
                           gals,tme);
  D.tensorMorphisms:=tme;
  return tm;
end );


#############################################################################
##
#F  ClassElementLargeGroup(D,<el>[,<possible>]) ident. class of el in D.group
##
##  First,the (hopefully) cheap identification is used,to filter the
##  possible classes. If still not unique,a hard conjugacy test is applied
##
BindGlobal( "ClassElementLargeGroup", function(arg)
local D,el,possible,i,id;
  D:=arg[1];
  el:=arg[2];
  id:=D.identification(D,el);
  possible:=Filtered([1..D.klanz],i->D.ids[i]=id);
  if Length(arg)>2 then
    possible:=Intersection(possible,arg[3]);
  fi;
  i:=1;
  while i<Length(possible) do
    if el in D.classes[possible[i]] then
      return possible[i];
    else
      i:=i+1;
    fi;
  od;
  return possible[i];
end );


#############################################################################
##
#F  ClassElementSmallGroup(<D>,<el>[,<poss>]) identify class of el in D.group
##
##  Since we have stored the complete classmap,this is done by simply
##  looking the class number up in this list.
##
BindGlobal( "ClassElementSmallGroup", function(arg)
local D;
  D:=arg[1];
  return D.classMap[Position(D.enum,arg[2])];
end );


#############################################################################
##
#F  DoubleCentralizerOrbit(<D>,<c1>,<c2>)
##
##  Let g_i be the representative of Class i.
##  Compute orbits of C(g_2) on (g_1^(-1))^G. Since we want to evaluate
##  x^(-1)*z for x\in Cl(g_1),and we only need the class of the result,we
##  may conjugate with z-centralizing elements and still obtain the same
##  results! The orbits are calculated either by simple orbit algorithms or
##  whenever they might become bigger using double cosets of the
##  centralizers.
##
InstallGlobalFunction(DoubleCentralizerOrbit,function(D,c1,c2)
local often,trans,e,neu,i,inv,cent,l,s,s1,x,dom;
  inv:=D.inversemap[c1];
  s1:=D.classiz[c1];
  # criteria for using simple orbit part: only for small groups,note that
  # computing ascending chains can be very expensive.
  if s1<500 or
     (not (HasStabilizerOfExternalSet(D.classes[inv])
           and Tester(ComputedAscendingChains)(Centralizer(D.classes[inv])))
        and s1<1000)

  then
    if D.currentInverseClassNo<>c1 then
      D.currentInverseClassNo:=c1;
      # compute (x^(-1))^G
      D.currentInverseClass:=Orbit(D.group,D.classreps[inv]);
    fi;
    trans:=[];
    cent:=Centralizer(D.classes[c2]);
    for e in D.currentInverseClass do
      neu:=true;
      i:=1;
      while neu and (i<=Length(trans)) do
        if e in trans[i] then neu:=false;
        fi;
        i:=i+1;
      od;
      if neu then
        Add(trans,Orbit(cent,e));
      fi;
    od;
    often:=List(trans,Length);
    return [List(trans,i->i[1]),often];
  else
    #Info(InfoCharacterTable,3,"using DoubleCosets;");
    cent:=Centralizer(D.classes[inv]);
    if IndexNC(D.group,cent)<=10^5 then
      dom:=fail;
      if not IsBound(D.centfachom[inv]) then
        #e:=ActionHomomorphism(D.group,RightTransversal(D.group,cent),OnRight,
        #  "surjective");
        #TODO: both in one
        e:=SubgroupNC(D.group,SmallGeneratingSet(D.group));
        SetSize(e,Size(D.group));
        dom:=Orbit(e,Representative(D.classes[inv]));
        e:=ActionHomomorphism(e,dom,"surjective");
        s:=Image(e);
        StabChainOptions(s).limit:=Size(D.group);
        # do not use action later on

        # rebuild from scratch to not carry through the orbit in
        # centfachom
        #e:=AsGroupGeneralMappingByImages(e);
        s:=MappingGeneratorsImages(e);
        e:=GroupHomomorphismByImagesNC(Source(e),Image(e),s[1],s[2]);
        SetIsSurjective(e,true);
        D.centfachom[inv]:=e;
        D.lastOrbit:=[e,dom];
      else
        e:=D.centfachom[inv];
        if IsBound(D.lastOrbit) and IsIdenticalObj(D.lastOrbit[1],e) then
          dom:=D.lastOrbit[2];
        fi;
      fi;
      s:=Orbits(Image(e,Centralizer(D.classes[c2])),[1..IndexNC(D.group,cent)]);
      if dom=fail then
        x:=D.classreps[inv];

        l:=List(s,i->[x^PreImagesRepresentative(e,
          RepresentativeAction(Image(e),1,i[1])),Size(cent)*Length(i)]);
      else
        l:=List(s,i->[dom[i[1]],Size(cent)*Length(i)]);
      fi;
    else
      l:=DoubleCosetRepsAndSizes(D.group,cent,Centralizer(D.classes[c2]));
      x:=D.classreps[inv];
      l:=List(l,i->[x^i[1],i[2]]);
    fi;
    s1:=Size(cent);
    e:=[];
    s:=[];
    for i in l do
      Add(e,i[1]);
      Add(s,i[2]/s1);
    od;
    return [e,s];
  fi;
end);


#############################################################################
##
#F  StandardClassMatrixColumn(<D>,<mat>,<r>,<t>)  . calculate the t-th column
#F       of the r-th class matrix and store it in the appropriate column of M
##
BindGlobal( "StandardClassMatrixColumn", function(D,M,r,t)
  local c,gt,s,z,i,T,w,e,j,p,orb;
  if t=1 then
    M[D.inversemap[r],t]:=D.classiz[r];
  else
    orb:=DxGaloisOrbits(D,r);
    z:=D.classreps[t];
    c:=orb.orbits[t][1];
    if c<>t then
      p:=RepresentativeAction(Stabilizer(orb.group,r),c,t);
      if p<>fail then
        # was the first column of the galois class active?
        if ForAny([1..NrRows(M)],i->M[i,c]>0) then
          for i in D.classrange do
            M[i^p,t]:=M[i,c];
          od;
          Info(InfoCharacterTable,2,"Computing column ",t,
            " : by GaloisImage");
          return;
        fi;
      fi;
    fi;

    T:=DoubleCentralizerOrbit(D,r,t);
    Info(InfoCharacterTable,2,"Computing column ",t," :",
      Length(T[1])," instead of ",D.classiz[r]);

    if IsDxLargeGroup(D.group) then
      # if r and t are unique,the conjugation test can be weak (i.e. up to
      # galois automorphisms)
      w:=Length(orb.orbits[t])=1 and Length(orb.orbits[r])=1;
      for i in [1..Length(T[1])] do
        e:=T[1][i]*z;
        Unbind(T[1][i]);
        if w then
          c:=D.rationalidentification(D,e);
          if c in orb.uniqueIdentifications then
            s:=orb.orbits[
              First([1..D.klanz],j->D.rids[j]=c)][1];
          else
            s:=D.ClassElement(D,e);
          fi;
        else # only strong test possible
          s:=D.ClassElement(D,e);
        fi;
        M[s,t]:=M[s,t]+T[2][i];
      od;
      if w then # weak discrimination possible ?
        gt:=Set(Filtered(orb.orbits,i->Length(i)>1));
        for i in gt do
          if i[1] in orb.identifees then
            # were these classes detected weakly ?
            e:=M[i[1],t];
            if e>0 then
              Info(InfoCharacterTable,3,"GaloisIdentification ",i,": ",e);
            fi;
            for j in i do
              M[j,t]:=e/Length(i);
            od;
          fi;
        od;
      fi;
    else # Small Group
      for i in [1..Length(T[1])] do
        s:=D.ClassElement(D,T[1][i] * z);
        Unbind(T[1][i]);
        M[s,t]:=M[s,t]+T[2][i];
      od;
    fi;
  fi;
end );


#############################################################################
##
#F  IdentificationGenericGroup(<D>,<el>) . .  class invariants for el in G
##
BindGlobal( "IdentificationGenericGroup", function(D,el)
  return Order(el);
end );


#############################################################################
##
#F  DxAbelianPreparation(<G>) . . specific initialisation for abelian groups
##
InstallMethod(DxPreparation,"abelian",true,[IsGroup and IsAbelian,IsRecord],0,
function(G,D)
  local i;
  D.identification:=function(a,b) return b; end;
  D.rationalidentification:=D.identification;
  D.ClassMatrixColumn:=StandardClassMatrixColumn;

  D.ids:=[];
  for i in D.classrange do
    D.ids[i]:=D.identification(D,D.classreps[i]);
  od;
  D.rids:=D.ids;

  D.ClassElement:=ClassElementLargeGroup;

  return D;

end);

#############################################################################
##
#M  DxPreparation(<G>,<D>)
##
InstallMethod(DxPreparation,"generic",true,[IsGroup,IsRecord],0,
function(G,D)
local i,j,enum,cl;
  D.identification:=IdentificationGenericGroup;
  D.rationalidentification:=IdentificationGenericGroup;
  D.ClassMatrixColumn:=StandardClassMatrixColumn;

  cl:=D.classes;
  D.ids:=[];
  for i in D.classrange do
    D.ids[i]:=D.identification(D,D.classreps[i]);
  od;
  D.rids:=D.ids;

  if IsDxLargeGroup(G) then
    D.ClassElement:=ClassElementLargeGroup;
  else
    D.ClassElement:=ClassElementSmallGroup;
    enum:=Enumerator(G);
    D.enum:=enum;
    D.classMap:=List([1..Size(G)],i->D.klanz);
    for j in [1..D.klanz-1] do
      for i in Orbit(G,Representative(cl[j])) do
        D.classMap[Position(D.enum,i)]:=j;
      od;
    od;
  fi;

  return D;

end);


#############################################################################
##
##  CharacterDegreePool(G)  . . possible character degrees,using thm. of Ito
##
BindGlobal( "CharacterDegreePool", function(G)
  local k,r,s;
  r:=RootInt(Size(G));
  #if Size(G)>10^6 and not IsSolvableGroup(G) then
  #  s:=Filtered(NormalSubgroups(G),IsAbelian);
  #  s:=Lcm(List(s,i->Index(G,i)));
  #else
  s:=Size(G);
  #fi;
  k:=Length(ConjugacyClasses(G));
  return List(Filtered(DivisorsInt(s),i->i<=r),i->[i,k]);
end );

#############################################################################
##
##  ClassNumbersElements(<G>,<l>) . .  class numbers in G for elements in l
##
BindGlobal( "ClassNumbersElements", function(G,l)
local D;
  D:=DixonRecord(G);
  return List(l,i->D.ClassElement(D,i));
end );

#############################################################################
##
#F  DxGeneratePrimeCyclotomic(<e>,<r>) . . . . . . . . .  ring homomorphisms
##
##  $\Q(\varepsilon_e)\to\F_p$. r is e-th root in F_p.
##
BindGlobal( "DxGeneratePrimeCyclotomic", function(e,r) # exponent,Primitive Root
  return function(a)
  local l,n,w,s,i,o;
    l:=COEFFS_CYC(a);
    n:=Length(l);
    o:=r^0;
    w:=0*o;
    s:=r^(e/n); # calculate corresponding power of modular root of unity
   for i in [1..n] do
      if i=1 then
        w:=w+l[i]*o;
      else
        w:=w+s^(i-1)*l[i];
      fi;
    od;
    return w;
  end;
end );

#############################################################################
##
#F  DixonInit(<G>) . . . . . . . . . . initialize Dixon-Schneider algorithm
##
##
InstallGlobalFunction( DixonInit, function(arg)
local G,     # group
      D,     # Dixon record,result
      k,z,exp,prime,M,m,f,r,ga,i,fk;

  G:=arg[1];

  # Force computation of the size of the group.
  Size(G);

  D:=DixonRecord(G);
  k:=D.klanz;

  DxCalcAllPowerMaps(D);
  DxCalcPrimeClasses(D);

  # estimate the irrationality of the table
  exp:=Exponent(G);
  z:=RootInt(Size(G));
  prime:=12*exp+1;

  fk:=ValueOption("prime");
  if not IsPosInt(fk) or fk<5*k then
    fk:=5*k;
  fi;

  while prime<Maximum(100,fk) do
    prime:=prime+exp;
  od;

  # try to calculate approximate degrees
  D.degreePool:=CharacterDegreePool(G);
  z:=2*Maximum(List(D.degreePool,i->i[1]));

  # throw away (unneeded) linear degrees!
  D.degreePool:=Filtered(D.degreePool,i->i[1]>1 and i[1]<=z/2);

  while prime<z do
    prime:=prime+exp;
  od;
  while not IsPrimeInt(prime) do
    prime:=prime+exp;
  od;

  f:=GF(prime);
  Info(InfoCharacterTable,1,"choosing prime ",prime);

  z:=PowerModInt(PrimitiveRootMod(prime),(prime-1)/exp,prime);
  D.modularMap:=DxGeneratePrimeCyclotomic(exp,z* One(f));

  D.num:=D.klanz;
  D.prime:=prime;
  D.field:=f;
  D.one:=One(f);
  D.z:=z;
  r:=rec(base:=List(IdentityMat(k,D.one),Vector),dim:=k);
  D.raeume:=[r];

  # Galois group operating on the columns
  ga:= GroupByGenerators( Set( Flat( GeneratorsPrimeResidues(
                      Exponent(G)).generators),
    i->PermList(List([1..k],j->PowerMap(D.characterTable,i,j)))),());

  D.galMorphisms:=ga;
  D.galoisOrbits:=List([1..k],i->Set(Orbit(ga,i)));
  D.matrices:=Difference(Set(D.galoisOrbits,i->i[1]),[1]);
  D.galOp:=[];
  D.irreducibles:=[];

  fk:=D.one/(Size(G) mod prime);
  M:= ZeroMatrix(D.field,k,k);
  for i in [1..k] do
    M[i,i]:=(D.classiz[i] mod prime)*D.one*fk;
  od;
  D.projectionMat:=M;

  #if (USECTPGROUP or Size(G)<2000 or k*10>=Size(G))
  #   and IsBound(G.isAgGroup) and G.isAgGroup
  #    then # Anfangscharaktere ausrechnen
#
#    m:=CharTablePGroup(G,"meckere nicht").irreducibles;
#    if Length(m)<k then
#
#      C.irreducibles:=[];
#      IncludeIrreducibles(D,m);
#
#    else
#
#      # The irreducibles are complete.
#      C.irreducibles:=m;
#      D.raeume:=[];
#
#    fi;
#  else
    DxIncludeIrreducibles(D,DxLinearCharacters(D));
#  fi;

  if Length(D.raeume)>0 then
    # indicate Stabilizer of the whole orbit,simultaneously compute
    # CharacterMorphisms.
    D.raeume[1].stabilizer:=CharacterMorphismGroup(D);
    m:=First(D.classes,i->Size(i)>1);
    if m<>fail and Size(m)>8 then
      D.maycent:=true;
    fi;
  fi;

  return D;
end );

InstallGlobalFunction(DxOnedimCleanout,function(D)
local i,j,r,ch,kill,gens,ra;
  kill:=false;
  for i in [1..Length(D.raeume)] do
    r:=D.raeume[i];
    if r.dim=1 then
      Info(InfoCharacterTable,2,"lifting character no.",
                      Length(D.irreducibles)+1);
      if IsBound(r.char) then
        ch:=r.char[1];
      else
        gens:=r.base[1];
        gens:=gens/gens[1];
        gens:=gens * ModularCharacterDegree(D,gens);
        for j in Orbit(D.characterMorphisms,
                          gens,D.asCharacterMorphism) do
          DxRegisterModularChar(D,j);
        od;
        ch:=DxLiftCharacter(D,gens);
      fi;
      for j in Orbit(D.characterMorphisms,ch,D.asCharacterMorphism) do
        Add(D.irreducibles,j);
      od;
      Unbind(D.raeume[i]);
      kill:=true;
    fi;
  od;
  if kill then
    # Throw away lifted spaces
    ra:=[];
    for i in D.raeume do
      Add(ra,i);
    od;
    D.raeume:=ra;
  fi;
end);

#############################################################################
##
#F  DixonSplit(<D>) . .  calculate matrix,split spaces and obtain characters
##
InstallGlobalFunction( DixonSplit, function(arg)
local D,bsm;

  D:=arg[1];
  if Length(arg)>1 then
    bsm:=arg[2];
  else
    bsm:=BestSplittingMatrix(D);
  fi;
  if bsm<>fail then
    SplitStep(D,bsm);
  fi;

  DxOnedimCleanout(D);

  CombinatoricSplit(D);
  return bsm;
end );


#############################################################################
##
#F  DixontinI(<D>)  . . . . . . . . . . . . . . . .  reverse initialisation
##
##  Return everything modified by the Dixon-Algorithm to its former status.
##  the old group is returned,character table is sorted according to its
##  classes
##
InstallGlobalFunction( DixontinI, function(D)
local C,u,irr;

  if IsBound(D.shorttests) then
    Info(InfoCharacterTable,2,D.shorttests," shortened conjugation tests");
  fi;
  Info(InfoCharacterTable,1,"Total:",Length(D.yetmats)," matrices,",
                 D.yetmats);
  C:=D.characterTable;

  irr:=List(D.irreducibles,i->Character(C,i));

  # Sort the characters by degrees.
  irr:=SortedCharacters(C,irr);

  SetInfoText(C,"origin: Dixon's Algorithm");

  # Throw away not any longer used components of the Dixon record.
  for u in Difference(RecNames(D),
    ["ClassElement","centmulCandidates","centmulMults","characterTable",
    "classMap","facs","fingerprintCandidates",
    "group","identification","ids","iscentral","klanz","name","operations",
    "replist","shorttests","uniques",
    "lastOrbit","centfachom"])
    do
    Unbind(D.(u));
  od;

  return irr;
end );


#############################################################################
##
#M  IrrDixonSchneider( <G>[, <options>] ) . . . . irr. chars. of finite group
##
##  Compute the irreducible characters of <G>,
##  using the Dixon/Schneider method.
##
InstallMethod( IrrDixonSchneider,
    "Dixon/Schneider",
    true,
    [ IsGroup ], 0,
    G -> IrrDixonSchneider( G, rec() ) );

InstallMethod( IrrDixonSchneider,
    "Dixon/Schneider",
    true,
    [ IsGroup, IsRecord ], 0,
    function( G, opt )

local k,C,D,dsp;

  D:=DixonInit(G,opt);
  k:=D.klanz;
  C:=D.characterTable;

  # iterierte Schleife

  dsp:=true;
  while k>Length(D.irreducibles) and dsp<>fail do

    dsp:=DixonSplit(D);
    OrbitSplit(D);

  od;

  C:=DixontinI(D);
  Assert(1,Length(C)=D.klanz);
  # SetIrr(OrdinaryCharacterTable(G),C);
  # (if `IrrDixonSchneider' is called explicitly,
  # we want to ignore the attribute)
  return C;

end );


#############################################################################
##
#M  Irr( <G>, 0 )  call Dixon-Schneider-algorithm
##
InstallMethod( Irr,
    "Dixon/Schneider",
    [ IsGroup, IsZeroCyc ],
    function( G, zero )
    local irr;
    irr:= IrrDixonSchneider( G );
    SetIrr( OrdinaryCharacterTable( G ), irr );
    return irr;
    end );


#############################################################################
##
#M  Irr( <G> ) . . via niceomorphism
##
##  We have to be careful about the ordering of conjugacy classes in the
##  character tables of <G> and of its nice object.
##
InstallMethod( Irr,
    "via niceomorphism",
    [ IsGroup and IsHandledByNiceMonomorphism, IsZeroCyc ],
    function( G, zero )
    local tbl, ccl, nice, cclnice, monom, imgs, bijection, i, j, irr;

    # Compute the conjugacy classes of the two tables.
    tbl:= CharacterTable( G );
    ccl:= ConjugacyClasses( tbl );
    nice:= CharacterTable( NiceObject( G ) );
    cclnice:= ShallowCopy( ConjugacyClasses( nice ) );

    # Compute the identification of classes.
    monom:= NiceMonomorphism( G );
    imgs:= List( ccl,
                 c -> ImagesRepresentative( monom, Representative( c ) ) );
    bijection:= [];
    for i in [ 1 .. Length( ccl ) ] do
      for j in [ 1 .. Length( cclnice ) ] do
        if IsBound( cclnice[j] ) and imgs[i] in cclnice[j] then
          bijection[i]:= j;
          Unbind( cclnice[j] );
          break;
        fi;
      od;
    od;
    Assert( 1, IsCollection( bijection ) and IsEmpty( cclnice ) );

    # Compute the values of the irreducibles of the nice object.
    irr:= List( Irr( nice ), ValuesOfClassFunction );

    # Permute the character values.
    irr:= List( irr, x -> x{ bijection } );

    # Construct and return the irreducibles.
    for i in irr do
      MakeImmutable( i );
    od;
    irr:= List( irr, x -> Character( tbl, x ) );
    SetIrr( tbl, irr );
    return irr;
end );


# The following code implements a naive version of
# Dixon, John D.
# Constructing representations of finite groups.
# Groups and computation (New Brunswick, NJ, 1991), 105--112,
# DIMACS Ser. Discrete Math. Theoret. Comput. Sci., 11,
# Amer. Math. Soc., Providence, RI, 1993.


BindGlobal("CholeskyDecomp",function(A)
local n,i,j,aii,Li,L;
  n:=Length(A);
  L:=One(A);
  for i in [1..n] do
    aii:=A[i][i];
    if IsInt(aii) then
      aii:=ER(aii);
    elif IsRat(aii) then
      aii:=ER(NumeratorRat(aii))/ER(DenominatorRat(aii));
    else
      return fail;
    fi;
    Li:=IdentityMat(n);
    Li[i][i]:=aii;
    for j in [i+1..n] do
      Li[j][i]:=1/aii*A[j][i];
    od;
    L:=L*Li;
    A:=Li^-1*A*TransposedMat(GaloisCyc(Li,-1))^-1;
  od;
  return L;
end);

BindGlobal("DixonRepGHchi",function(G,H,chi)
local tblG, cg, d, tblH, res, pos, theta, hl, sp, ch, alpha, AF, bw, cnt,
      sum, A, x, ra, l, rt, rti, rtl, r, alonin, wert, bx, mats, hom,
      i,balonin;

  tblG:=UnderlyingCharacterTable(chi);
  if UnderlyingGroup(tblG)<>G then
    Error("inconsistent groups");
  fi;
  cg:=ConjugacyClasses(tblG);
  d:=chi[1];

  tblH:=CharacterTable(H);
  Irr(tblH);
  FusionConjugacyClasses(tblH,tblG);
  res:=Restricted(chi,tblH);
  pos:=1;
  theta:=fail;
  hl:=Filtered(Irr(tblH),i->i[1]=1);
  while theta=fail and pos<=Length(hl) do
    sp:=ScalarProduct(res,hl[pos]);
    if sp=1 then
      theta:=hl[pos];
    elif not IsInt(sp) then
      Error("wrong restriction!");
    else
      pos:=pos+1;
    fi;
  od;
  if theta=fail then
    return fail; # did not work
  fi;

  Info(InfoCharacterTable,2,"DixonRepGHchi ",Size(G),",",Size(H),":\n",chi);

  Info(InfoCharacterTable,3,"theta= ",theta);

  ch:=ConjugacyClasses(tblH);

  alpha:=function(t)
  local ti,s,hi,z,elm,pos;
    ti:=t^-1;
    s:=0;
    for hi in [1..Length(ch)] do
      for z in ch[hi] do
        elm:=LeftQuotient(z,ti);
        pos:=1;
        while pos<=Length(cg) and not elm in cg[pos] do
          pos:=pos+1;
        od;
        s:=s+theta[hi]*chi[pos];
      od;
    od;
    return s;
  end;

  AF:=function(elm)
  local elmi,mat,i,j;
    elmi:=elm^-1;
    mat:=[];
    for i in [1..d] do
      mat[i]:=[];
      for j in [1..d] do
        mat[i][j]:=alpha(x[j]*elmi/x[i]);
      od;
    od;
    return mat;
  end;

  bw:=infinity;
  cnt:=0;
  sum:=0;
  repeat
    A:=[];
    x:=[];
    ra:=0;
    l:=0;
    rt:=RightTransversal(G,H);
    rti:=1;
    rtl:=BlistList([1..Length(rt)],[]);
    while ra<d do
      if SizeBlist(rtl)=Length(rt) then
        Error("could not find suitable elements?");
      fi;
      repeat
        rti:=Random(1, Length(rt));
      until rtl[rti]=false;
      rtl[rti]:=true;
      r:=rt[rti];
      i:=Random(H);
      r:=i*r;
      rti:=rti+1;
      for i in [1..l] do
        A[i][l+1]:=alpha(r/x[i]);
      od;
      l:=l+1;
      x[l]:=r;
      A[l]:=[];
      for i in [1..l] do
        A[l][i]:=alpha(x[i]/r);
      od;
      if RankMat(A)>ra then
        ra:=ra+1;
      else
        Unbind(A[l]);Unbind(x[l]);
        l:=l-1; #overwrite last
      fi;
    od;
    Unbind(rt);

    alonin:=AF(One(G))^-1;
    wert:=Lcm(List(Flat(alonin),DenominatorCyc));
    cnt:=cnt+1;
    sum:=sum+wert;
    Info(InfoCharacterTable,2,"denominator lcm=",wert,
         " average=",Int(sum/cnt));
    if wert<bw then
      bx:=x;
      bw:=wert;
      balonin:=alonin;
    fi;
  until bw<Size(G) or cnt>30
        # bw*1000<average
        or bw*1000*cnt<sum;
  x:=bx;

  mats:=List(GeneratorsOfGroup(G),i->AF(i)*balonin);

  if ValueOption("unitary")=true then
    r:=CholeskyDecomp(alonin^-1);
    if r=fail then
      Error("cannot guarantee unitary");
    else
      mats:=List(mats,x->x^r);
    fi;
  fi;

  hom:=GroupHomomorphismByImagesNC(G,Group(mats),
    GeneratorsOfGroup(G),mats);

  SetIsSurjective(hom,true);
  return hom;
end);

BindGlobal("DixonRepChi",function(G,chi)
local i,H,r;
  # find a suitable H
  # try first cyclic
  for i in ConjugacyClasses(G) do
    if Order(Representative(i))>1 then
      H:=Subgroup(G,[Representative(i)]);
      r:=DixonRepGHchi(G,H,chi);
      if r<>fail then
        return r;
      fi;
    fi;
  od;
  # now all subgroups
  Info(InfoWarning,1,"need to compute subgroup lattice");
  for i in ConjugacyClassesSubgroups(G) do
    if Size(Representative(i))>1 then
      H:=Subgroup(G,GeneratorsOfGroup(Representative(i)));
      UseIsomorphismRelation(Representative(i),H);
      r:=DixonRepGHchi(G,H,chi);
      if r<>fail then
        return r;
      fi;
    fi;
  od;
  return fail;
end);

InstallGlobalFunction(IrreducibleRepresentationsDixon,function(arg)
local G,chi,reps,r,i,gensp;
  G:=arg[1];
  if Length(arg)=1 then
    chi:=Irr(G);
  elif IsClassFunction(arg[2]) and IsCharacter(arg[2]) then
    chi:=[arg[2]];
  elif IsList(arg[2]) and ForAll(arg[2],IsCharacter) then
    chi:=arg[2];
  else
    Error("second argument must be ordinary character or character list");
  fi;

  # Special case of trivial group
  if Size(G)=1 then
    r:=Group([[1]]);
    r:=GroupHomomorphismByImagesNC(G,r,[One(G)],[One(r)]);
    return List(chi,x->r);
  fi;

  gensp:=fail;
  reps:=[];
  for i in chi do
    Info(InfoCharacterTable,1,"Character ",i);
    if i[1]=1 then
      # linear
      if gensp=fail then
        gensp:=List(GeneratorsOfGroup(G),
          i->PositionProperty(ConjugacyClasses(G),j->i in j));
      fi;
      r:=List(i{gensp},i->[[i]]);
      r:=GroupHomomorphismByImagesNC(G,Group(r),GeneratorsOfGroup(G),r);
    else
      r:=DixonRepChi(G,i);
      if r=fail then
        Info(InfoWarning,1,"Dixon's method does not work for ",chi);
      fi;
    fi;
    Add(reps,r);
  od;
  if Length(reps)=1 and Length(arg)>1 and (not IsList(arg[2][1]))
    and IsCharacter(arg[2]) then
    return r;
  fi;
  return reps;
end);

#############################################################################
##
#M  IrreducibleRepresentations( <G> )
##
##
InstallMethod( IrreducibleRepresentations, "Dixon's method",
    true, [ IsGroup and IsFinite], 0,IrreducibleRepresentationsDixon);

InstallGlobalFunction(RepresentationsPermutationIrreducibleCharacters,
function(G,chars,reps)
local imgs, cl, d, cands, j, t, i;
  if Length(chars)<>Length(reps) or
    Length(chars)<>Length(ConjugacyClasses(G)) then
    Error("inconsistency");
  fi;
  imgs:=[];
  cl:=ConjugacyClasses(G);
  for i in reps do
    d:=Length(One(Range(i)));
    cands:=Filtered([1..Length(chars)],i->chars[i][1]=d);
    j:=2;
    while Length(cands)>1 do
      if Length(Set(chars{cands}[j]))>1 then
        # characters differ on this class
        t:=TraceMat(Image(i,Representative(cl[j])));
        cands:=Filtered(cands,i->chars[i][j]=t);
      fi;
      j:=j+1;
    od;
    if Length(cands)=0 then
      Error("No character for particular representation found");
    fi;
    Add(imgs,cands[1]);
  od;
  return PermList(imgs);
end);


# the following function is in this file only for dependency reasons.
#############################################################################
##
#F  NthRootsInGroup( <G>, <e>, <n> )
##
##  Takes the <n>th root of element <e> in <G>. This function returns a
##  list of elements <a> of <G> such that $a^n=e$.
##
InstallGlobalFunction(NthRootsInGroup,function(G,elm,n)
local c,cl,k,p,cand,x,rep,conj,i,rc,roots,cen;
  # based on an idea by Mathieu Dutour. AH
  c:=CharacterTable(G);
  cl:=ConjugacyClasses(c);
  k:=Length(cl);
  p:=PowerMap(c,n);

  cand:=Filtered([1..k],i->Order(Representative(cl[i]))=Order(elm));
  x:=First(cand,i->elm in cl[i]);
  #root classes
  rc:=Filtered([1..k],i->p[i]=x);
  if Length(rc)=0 then return rc;fi;

  roots:=[];
  cen:=Centralizer(G,elm);
  # now for each root class map rep^n to our element
  for i in rc do
    rep:=Representative(cl[i]);
    conj:=RepresentativeAction(G,rep^n,elm);
    # the roots in this class form one orbit under the centralizer of elm
    Append(roots,Orbit(cen,rep^conj));
  od;
  return roots;
end);
