#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Stefan Kohl, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the functionality for constructing classical groups over
##  residue class rings.
##

#############################################################################
##
#F  SizeOfGLdZmodmZ( <d>, <m> ) . . . . . .  Size of the group GL(<d>,Z/<m>Z)
##
##  Computes the order of the group `GL( <d>, Integers mod <m> )' for
##  positive integers <d> and <m> > 1.
##
InstallGlobalFunction( SizeOfGLdZmodmZ,

  function ( d, m )

    local  size, pow, p, q, k, i;

    if   not (IsPosInt(d) and IsInt(m) and m > 1)
    then Error("GL(",d,",Integers mod ",m,") is not a well-defined group, ",
               "resp. not supported.\n");
    fi;
    size := 1;
    for pow in Collected(Factors(m)) do
      p := pow[1]; k := pow[2]; q := p^k;
      size := size * Product([d*k - d .. d*k - 1], i -> q^d - p^i);
    od;
    return size;
  end );

#############################################################################
##
#M  SpecialLinearGroupCons( IsNaturalSL, <d>, Integers mod <m> )
##
InstallMethod( SpecialLinearGroupCons,
               "natural SL for dimension and residue class ring",
               [ IsMatrixGroup and IsFinite, IsPosInt,
                 IsRing and IsFinite and IsZmodnZObjNonprimeCollection ],

  function ( filter, d, R )

    local  G, gens, g, m, T;

    m := Size(R);
    if R <> Integers mod m or m = 1 then TryNextMethod(); fi;
    if IsPrime(m) then return SpecialLinearGroupCons(IsMatrixGroup,d,m); fi;
    if   d = 1
    then gens := [IdentityMat(d,R)];
    else gens := List(GeneratorsOfGroup(SymmetricGroup(d)),
                      g -> PermutationMat(g,d) * One(R));
         for g in gens do
           if DeterminantMat(g) <> One(R) then g[1] := -g[1]; fi;
         od;
         T := IdentityMat(d,R); T[1][2] := One(R); Add(gens,T);
    fi;
    G := GroupByGenerators(gens);
    SetName(G,Concatenation("SL(",String(d),",Z/",String(m),"Z)"));
    SetIsNaturalSL(G,true);
    SetDimensionOfMatrixGroup(G,d);
    SetIsFinite(G,true);
    SetSize(G,SizeOfGLdZmodmZ(d,m)/Phi(m));
    return G;
  end );

#############################################################################
##
#M  GeneralLinearGroupCons( IsNaturalGL, <d>, Integers mod <m> )
##
InstallMethod( GeneralLinearGroupCons,
               "natural GL for dimension and residue class ring",
               [ IsMatrixGroup and IsFinite, IsPosInt,
                 IsRing and IsFinite and IsZmodnZObjNonprimeCollection ],

  function ( filter, d, R )

    local  G, gens, g, m, T, D;

    m := Size(R);
    if R <> Integers mod m or m = 1 then TryNextMethod(); fi;
    if IsPrime(m) then return GeneralLinearGroupCons(IsMatrixGroup,d,m); fi;
    if   d = 1
    then gens := List(GeneratorsOfGroup(Units(R)), g -> [[g]]);
    else gens := List(GeneratorsOfGroup(SymmetricGroup(d)),
                      g -> PermutationMat(g,d) * One(R));
         T := IdentityMat(d,R); T[1][2] := One(R); Add(gens,T);
         for g in GeneratorsOfGroup(Units(R)) do
           D := IdentityMat(d,R); D[1][1] := g; Add(gens,D);
         od;
    fi;
    G := GroupByGenerators(gens);
    SetName(G,Concatenation("GL(",String(d),",Z/",String(m),"Z)"));
    SetIsNaturalGL(G,true);
    SetDimensionOfMatrixGroup(G,d);
    SetIsFinite(G,true);
    SetSize(G,SizeOfGLdZmodmZ(d,m));
    return G;
  end );

BindGlobal("OrderMatrixIntegerResidue",function(p,a,M)
local f,M2,o,e,MM,i;
  MM:=M;
  f:=GF(p);
  M2:=ImmutableMatrix(f,List(M,x->List(x,y->Int(y)*One(f))));
  o:=Order(M2);
  M:=M^o;
  e:=p;
  i:=1;
  while i<a do
    i:=i+1;
    e:=e*p;
    M2:=M-M^0;
    if ForAny(M2,x->ForAny(x,x->Int(x) mod e<>0)) then
      o:=o*p;
      M:=M^p;
    fi;
  od;

  Assert(1,IsOne(M));
  return o;
end);

BindGlobal("SPRingGeneric",function(n,ring)
local geni,m,slmats,gens,f,rels,i,j,k,l,mat,mat1,mats,id,nh,g;
  nh:=n;
  n:=2*n;
  geni:=List([1..n],x->[]);
  mats:=[];
  slmats:=[];
  id:=IdentityMat(n,ring);
  m:=0;
  for i in [1..nh] do
    #t_{i,n+i}
    mat:=List(id,ShallowCopy);
    mat[i][nh+i]:=One(ring);
    Add(slmats,mat);
    #t_{n+i,i}
    mat:=List(id,ShallowCopy);
    mat[nh+i][i]:=One(ring);
    Add(slmats,mat);
  od;

  for i in [1..nh] do
    for j in [i+1..nh] do
      # t_{i,n+j}
      mat:=List(id,ShallowCopy);
      mat[i][nh+j]:=One(ring);
      mat1:=mat;
      # t_{j,n+i}
      mat:=List(id,ShallowCopy);
      mat[j][nh+i]:=One(ring);
      Add(slmats,mat1*mat);
      # t_{n+i,j}
      mat:=List(id,ShallowCopy);
      mat[nh+i][j]:=One(ring);
      mat1:=mat;
      # t_{n+j,i}
      mat:=List(id,ShallowCopy);
      mat[nh+j][i]:=One(ring);
      Add(slmats,mat1*mat);
    od;
  od;

  g := Group(slmats);
  mat := Concatenation(id{[nh+1..n]},-id{[1..nh]});
  SetInvariantBilinearForm(g,rec(matrix:=mat));
  return g;
end);

InstallGlobalFunction("ConstructFormPreservingGroup",function(arg)
local oper,n,R,o,nrit,
  q,p,field,zero,one,oner,a,f,pp,b,d,fb,btf,eq,r,i,j,e,k,ogens,gens,gensi,
  bp,sol,
  g,prev,proper,fp,ho,evrels,hom,bas,basm,em,ngens,addmat,sub,transpose;

  oper:=arg[1];
  R:=arg[Length(arg)];
  n:=arg[Length(arg)-1];
  q:=Size(R);
  if not IsPrimePowerInt(q) then
    TryNextMethod();
  fi;
  p:=Factors(q)[1];
  if p=2 then
    if oper=SP then
      return SPRingGeneric(n/2,R);
    else
      return fail;
    fi;
  fi;
  field:=GF(p);
  zero:=Zero(field);
  one:=One(field);
  if Length(arg)=3 then
    g:=oper(n,p);
  else
    g:=oper(arg[2],n,p);
  fi;

  # get the form and get the correct -1's
  f:=InvariantBilinearForm(g).matrix;

  transpose:=not ForAll(GeneratorsOfGroup(g),
    x->TransposedMat(x)*f*x=f);
  if transpose then
    Info(InfoGroup,1,"transpose!");
    if HasSize(g) then
      e:=Size(g);
    else
      e:=fail;
    fi;
    g:=Group(List(GeneratorsOfGroup(g),TransposedMat));
    if e<>fail then
      SetSize(g,e);
    fi;
  fi;
  #IsomorphismFpGroup(g); # force hom for next steps
  f:=List(f,r->List(r,Int));
  for i in [1..n] do

    for j in [1..n] do
      if f[i][j]=p-1 then
        f[i][j]:=-1;
      fi;
    od;
  od;

  nrit:=0;
  pp:=p; # previous p
  while pp<q do

    nrit:=nrit+1;
    prev:=g;

    if HasIsomorphismFpGroup(prev) then
      hom:=IsomorphismFpGroup(prev);
      fp:=Range(hom);
      ogens:=List(GeneratorsOfGroup(fp),
              x->List(PreImagesRepresentative(hom,x)));
    else
      fp:=fail;
      ogens:=GeneratorsOfGroup(prev);
    fi;
    ogens:=List(ogens,x->List(x,r->List(r,Int)));
    gens:=[];

    for bp in [1..Length(ogens)+1] do
      if bp<=Length(ogens) then
        b:=ogens[bp];
      else
        b:=One(ogens[1]);
      fi;
      d:=(TransposedMat(b)*f*b-f)*1/pp;
      # solve  D+E^T*F*B+B^T*F*E=0
      fb:=f*b;
      btf:=TransposedMat(b)*f;
      eq:=[];
      r:=[];
      for i in [1..n] do
        for j in [1..n] do
          # eq for entry i,j
          e:=ListWithIdenticalEntries(n^2,zero);
          for k in [1..n] do
            e[(k-1)*n+i]:=e[(k-1)*n+i]+fb[k][j];
            e[(k-1)*n+j]:=e[(k-1)*n+j]+btf[i][k];
          od;
          Add(eq,e);

          #RHS is -d entry
          Add(r,-d[i][j]*one);
        od;
      od;
      eq:=TransposedMat(eq); # columns were corresponding to variables

      if bp<=Length(ogens) then
        # lift generator
        sol:=SolutionMat(eq,r);

        # matrix from it
        sol:=List([1..n],x->sol{[(x-1)*n+1..x*n]});
        sol:=List(sol,x->List(x,Int));
        Add(gens,b+pp*sol);
      else
        # we know all gens

        oner:=One(Integers mod (pp*p));
        gens:=List(gens,x->x*oner);

        g:=Group(gens);

        # d will be zero, so homogeneous

        sol:=NullspaceMat(eq);
        #Info(InfoGroup,1,"extend by dim",Length(sol));

        proper:=p^Length(sol)*Size(prev); # proper order of group

        if ValueOption("avoidkerneltest")<>true then
          # vector space in kernel that is generated
          bas:=[];
          basm:=[];
          sub:=VectorSpace(field,bas,Zero(e));

          addmat:=function(em)
          local c;
            e:=List(em,r->List(r,Int))-b;
            e:=1/pp*e;
            e:=Concatenation(e)*one;
        e:=ImmutableVector(p,e);
            if not e in sub then
              Add(bas,e);
              Add(basm,em);
              sub:=VectorSpace(field,bas);
            fi;
          end;

          if fp<>fail then
            # evaluate relators
            evrels:=RelatorsOfFpGroup(fp);

            i:=1;
            while i<=Length(evrels) and Length(bas)<Length(sol) do
              em:=MappedWord(evrels[i],FreeGeneratorsOfFpGroup(fp),gens);
              addmat(em);
              i:=i+1;
            od;
          else
            evrels:=Source(EpimorphismFromFreeGroup(prev));
            repeat
              j:=PseudoRandom(evrels:radius:=10);
              k:=MappedWord(j,GeneratorsOfGroup(evrels),GeneratorsOfGroup(prev));
              o:=OrderMatrixIntegerResidue(p,nrit,k);
              k:=MappedWord(j,GeneratorsOfGroup(evrels),gens)^o;
            until not IsOne(k);
            addmat(k);

          fi;

          # close under action
          gensi:=List(gens,Inverse);
          i:=1;
          while i<=Length(basm) and Length(bas)<Length(sol) do
            for j in [1..Length(gens)] do
              #em:=basm[i]^j;
              em:=gensi[j]*basm[i]*gens[j];
              addmat(em);
            od;
            i:=i+1;
          od;

          if Length(bas)=Length(sol) then
            Info(InfoGroup,1,"kernel generated ",Length(bas));
          else
            Info(InfoGroup,1,"kernel partially generated ",Length(bas));
            ngens:=ShallowCopy(gens);
            i:=Iterator(sol); # just run through basis as linear
            while Length(bas)<Length(sol) do
              e:=NextIterator(i);
              e:=List(e,Int);
              e:=b+pp*List([1..n],x->e{[(x-1)*n+1..x*n]});
              addmat(e);
              if e=basm[Length(basm)] then
                # was added
                Add(ngens,e);
                g:=Group(ngens);
                Info(InfoGroup,1,"added generator");
              fi;
            od;
          fi;

          if fp <>fail then
            # extend presentation
            bas:=Basis(sub,bas);
            RUN_IN_GGMBI:=true;
            hom:=GroupGeneralMappingByImagesNC(g,fp,gens,GeneratorsOfGroup(fp));
            hom:=LiftFactorFpHom(hom,g,SubgroupNC(g,basm),rec(
                  pcgs:=basm,
                  prime:=p,
                  decomp:=function(em)
                  local e;
                    e:=List(em,r->List(r,Int))-b;
                    e:=1/pp*e;
                    e:=Concatenation(e)*one;
                    return List(Coefficients(bas,e),Int);
                  end
                  ));
            RUN_IN_GGMBI:=false;
            #simplify Image to avoid explosion of generator number
            fp:=Range(hom);
            if true then
              # remove redundant generators
              e:=PresentationFpGroup(fp);
              TzOptions(e).printLevel:=0;
              j:=Filtered(Reversed([1..Length(e!.generators)]),
                x->not MappingGeneratorsImages(hom)[1][x] in ngens);
              j:=e!.generators{j};

              TzInitGeneratorImages(e);
              for i in j do
                TzEliminate(e,i);
              od;
              fp:=FpGroupPresentation(e);
              j:=MappingGeneratorsImages(hom);
              k:=TzPreImagesNewGens(e);
              k:=List(k,x->j[1][Position(OldGeneratorsOfPresentation(e),x)]);

              RUN_IN_GGMBI:=true;
              hom:=GroupHomomorphismByImagesNC(g,fp,
                    k,
                    GeneratorsOfGroup(fp));
              RUN_IN_GGMBI:=false;
            fi;

            SetIsomorphismFpGroup(g,hom);
          fi;
        fi;

        SetSize(g,Size(prev)*Size(field)^Length(sol));
      fi;

    od;

    pp:=pp*p;
  od;

  if transpose then
    e:=Size(g);
    g:=Group(List(GeneratorsOfGroup(g),TransposedMat));
    SetSize(g,e);
  fi;
  SetInvariantBilinearForm(g,rec(matrix:=f*oner));

  return g;
end);

#############################################################################
##
#M  SymplecticGroupCons( <IsMatrixGroup>, <d>, Integers mod <q> )
##
InstallOtherMethod( SymplecticGroupCons,
  "symplectic group for dimension and residue class ring for prime powers",
  [ IsMatrixGroup and IsFinite, IsPosInt,
    IsRing and IsFinite and IsZmodnZObjNonprimeCollection ],
function ( filter, n, R )
local g;
  g:=ConstructFormPreservingGroup(SP,n,R);
  SetName(g,Concatenation("Sp(",String(n),",Z/",String(Size(R)),"Z)"));
  return g;
end);

#############################################################################
##
#M  GeneralOrthogonalGroupCons ( <IsMatrixGroup>, <d>, Integers mod <q> )
##
InstallOtherMethod( GeneralOrthogonalGroupCons,
  "GO for dimension and residue class ring for prime powers",
  [ IsMatrixGroup and IsFinite, IsInt,IsPosInt,
    IsRing and IsFinite and IsZmodnZObjNonprimeCollection ],
function ( filter, sign,n, R )
local g;
  if sign=0 then
    g:=ConstructFormPreservingGroup(GO,n,R);
    SetName(g,Concatenation("GO(",String(n),",Z/",String(Size(R)),"Z)"));
  else
    g:=ConstructFormPreservingGroup(GO,sign,n,R);
    SetName(g,Concatenation("GO(",String(sign),",",String(n),
      ",Z/",String(Size(R)),"Z)"));
  fi;
  return g;
end);

#############################################################################
##
#M  SpecialOrthogonalGroupCons( <IsMatrixGroup>, <d>, Integers mod <q> )
##
InstallOtherMethod( SpecialOrthogonalGroupCons,
  "GO for dimension and residue class ring for prime powers",
  [ IsMatrixGroup and IsFinite, IsInt,IsPosInt,
    IsRing and IsFinite and IsZmodnZObjNonprimeCollection ],
function ( filter, sign,n, R )
local g;
  if sign=0 then
    g:=ConstructFormPreservingGroup(SO,n,R);
    if g=fail then TryNextMethod();fi;
    SetName(g,Concatenation("SO(",String(n),",Z/",String(Size(R)),"Z)"));
  else
    g:=ConstructFormPreservingGroup(SO,sign,n,R);
    if g=fail then TryNextMethod();fi;
    SetName(g,Concatenation("SO(",String(sign),",",String(n),
      ",Z/",String(Size(R)),"Z)"));
  fi;
  return g;
end);
