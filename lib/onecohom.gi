#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for operations for the 1-Cohomology
##


#############################################################################
##
#F  TriangulizedGeneratorsByMatrix(<gens>,<M>,<F>)
##  triangulize and make base
##
InstallGlobalFunction(TriangulizedGeneratorsByMatrix,function (gens,M,F)
local   m, n, i, j, k, a, r,z, z0;

    gens:=ShallowCopy(gens);
    M:=ShallowCopy(M);
    # get the size of the matrix
    m:=Length(M);
    n:=Length(M[1]);

    # run through all columns of the matrix
    z0:=Zero(F);
    i :=0;
    for k in [1 .. n] do
        j:=i+1;
        while j<= m and M[j][k] = z0 do
          j:=j+1;
        od;
        if j<= m  then
            i:=i+1;
            z:=M[j][k]^-1;
            a:=gens[j]; gens[j]:=gens[i]; gens[i]:=a^IntFFE(z);
            r:=M[j];  M[j]:=M[i];  M[i]:=z*r;
            for j in [1 .. m] do
                z:=M[j][k];
                if  i<>j and z<>z0  then
                    gens[j]:=gens[j] / (gens[i]^IntFFE(z));
                    M[j]:=M[j] - z*M[i];
                fi;
            od;

        fi;
    od;

    n:=[[],[]];
    r:=0*M[1];
    for i in [1 .. m] do
        if M[i]<>r  then
            Add(n[1],gens[i]);
            Add(n[2],M[i]);
        fi;
    od;
    return n;

end);


##  For all following functions,the group is given as second argument to
##  allow dispatching after the group type


BindGlobal( "OCAddGeneratorsPcgs", function(ocr,group)
local   gens;

    if not IsBound(ocr.pcgs) then
      ocr.pcgs:=ParentPcgs(NumeratorOfModuloPcgs(ocr.modulePcgs));
    fi;

    Info(InfoCoh,2,"OCAddGenerators2: using standard generators");
    if IsBound(ocr.pPrimeSet)  then
        Info(InfoCoh,3,"OCAddGenerators2: p prime set is given ",
               "for standard generating set");
    fi;
    if IsBound(ocr.smallGeneratingSet)  then
       Info(InfoCoh,3,"OCAddGenerators2: small generating set is given ",
              "for standard generating set");
    fi;

    if not IsBound(ocr.generators) then
      Info(InfoCoh,2,"setting new generators");
      ocr.generators:=InducedPcgs(ocr.pcgs,group)
                          mod NumeratorOfModuloPcgs(ocr.modulePcgs);
    fi;

    Info(InfoCoh,2,"OCAddGenerators2: ",Length(ocr.generators),
      " generators");

    if IsBound(ocr.normalIn)  then
        if not ForAll(ocr.module,i->i in ocr.normalIn)  then
            gens:=InducedPcgs(ocr.pcgs,ocr.normalIn);
        else
            gens:=AsList(InducedPcgs(ocr.pcgs,ocr.normalIn) mod
                       ocr.modulePcgs);
        fi;
        ocr.normalGenerators:=gens;
    fi;

end );

BindGlobal( "OCAddGeneratorsGeneral", function(ocr)
local  hom,fg,fpi,fpg,nt,fam;

  if IsBound(ocr.normalIn)  then
      Error("normalizing subgroup not allowed in general case");
  fi;

  if IsBound(ocr.pPrimeSet)  then
      Error("p prime set given in general case");
  fi;

  if IsBound(ocr.factorpres) then
    # see if factor presentation is known already
    return;
  fi;

  nt:=SubgroupNC(ocr.group,NumeratorOfModuloPcgs(ocr.modulePcgs));
  if IsBound(ocr.factorfphom) and not IsBound(ocr.generators) then
    Info(InfoCoh,1,"using provided presentation");
    hom:=ocr.factorfphom;
    fpg:=FreeGeneratorsOfFpGroup(Range(hom));
    ocr.factorpres:=[fpg,RelatorsOfFpGroup(Range(hom))];
    ocr.generators:=List(GeneratorsOfGroup(Range(hom)),
                          i->PreImagesRepresentative(hom,i));

  else
    if (Index(ocr.group,nt)>Size(nt)^3
          or Index(ocr.group,nt)>500000) and
          (not KnownNaturalHomomorphismsPool(ocr.group,nt) or
          DegreeNaturalHomomorphismsPool(ocr.group,nt)>10000) then
      # computing a factor representation may be too hard
      hom:=false;
    else
      hom:=NaturalHomomorphismByNormalSubgroup(ocr.group,nt);

      fg:=Image(hom,ocr.group);
      ocr.factormap:=hom;
    fi;

    if hom<>false and (IsSolvableGroup(Range(hom))
      or (IsPermGroup(Range(hom)) and Length(MovedPoints(Range(hom)))
                             <Length(MovedPoints(ocr.group))*2)
      or (HasIsomorphismFpGroup(fg) and not IsBound(ocr.generators)))
    then
      Info(InfoCoh,1,"using factor representation");
      if IsBound(ocr.generators) then
        fpi:=IsomorphismFpGroupByGeneratorsNC(fg,List(ocr.generators,
                                                    i->Image(hom,i)),"f");
      else
        fpi:=IsomorphismFpGroup(fg:noshort:=true);
      fi;
      fpg:=FreeGeneratorsOfFpGroup(Range(fpi));
      ocr.factorpres:=[fpg,RelatorsOfFpGroup(Range(fpi)),
                      List(GeneratorsOfGroup(Range(fpi)),
                            i->PreImagesRepresentative(fpi,i))];
      if not IsBound(ocr.generators) then
        ocr.generators:=List(ocr.factorpres[3],i->PreImagesRepresentative(hom,i));
      fi;


    elif IsBound(ocr.generators) then
      Info(InfoCoh,1,"using group representation");
      fpi:=IsomorphismFpGroupByGeneratorsNC(ocr.group,ocr.generators,"f");
#      else # old code
#       fpi:=IsomorphismFpGroup(ocr.group:noshort:=true);
#       ocr.generators:=List(MappingGeneratorsImages(fpi)[2],
#                           i->PreImagesRepresentative(fpi,i));
#      fi;
      fpg:=FreeGeneratorsOfFpGroup(Range(fpi));
      ocr.factorpres:=[fpg,RelatorsOfFpGroup(Range(fpi))];

      # add generating system for ocr.module to obtain a presentation of the
      # factor group

      fpi:= GroupHomomorphismByImagesNC(ocr.group,
                                        FreeGroupOfFpGroup(Range(fpi)),
                                        ocr.generators,fpg);
      ocr.factorpres[2]:=Union(ocr.factorpres[2],
                      List(NumeratorOfModuloPcgs(ocr.modulePcgs),
                            i->ImagesRepresentative(fpi,i:noshort:=true)));
    else
      # build suitable pres for factor
      Info(InfoCoh,1,"using group rep and series for factor");
      fpi:=IsomorphismFpGroupByChiefSeriesFactor(ocr.group,"f",nt);
      fam:=FamilyObj(One(Range(fpi)));
      fpg:=FreeGeneratorsOfFpGroup(Range(fpi));
      ocr.generators:=List(fpg,i->PreImagesRepresentative(fpi,
         ElementOfFpGroup(fam,i)));
      ocr.factorpres:=[fpg,RelatorsOfFpGroup(Range(fpi)),ocr.generators];
    fi;
  fi;

  Info(InfoCoh,1,Length(ocr.generators)," generators,",
                 Length(ocr.factorpres[2])," relators");

end );

#############################################################################
##
#F  OCAddGenerators(<ocr>,<group>)  . . . . . . . . . add generators,local
##
InstallGlobalFunction(OCAddGenerators,function(ocr,G)
  if IsBound(ocr.generatorsAdded) then
    return; # avoid duplicate calls
  fi;
  ocr.generatorsAdded:=true;

  # though using the method selection would be nicer,here the decisions are
  # that involved we actually have to use a dispatcher
  if IsBound(ocr.inPcComplement) # the pc complement routines interface
                                 # directly,giving generators that form an
                                 # pcgs
     or ((IsPcGroup(G) or
       (IsBound(ocr.generators) and IsGeneralPcgs(ocr.generators)))
       and not IsBound(ocr.factorpres)) then
    OCAddGeneratorsPcgs(ocr,G);
  else
    OCAddGeneratorsGeneral(ocr);
  fi;
end);


#############################################################################
##
#F  OCAddMatrices(<ocr>,<G>) . . . . . . . . add operation matrices,local
##
InstallGlobalFunction(OCAddMatrices,function(ocr,G)
local i,base;

    # If<ocr>already has a record component 'matrices',nothing is done.
    if IsBound(ocr.matrices)  then
        return;
    fi;
    Info(InfoCoh,2,"OCAddMatrices: computes linear operations");

    # Construct field and log table.
    base:=ocr.modulePcgs;

    if Length(base)=0 then
        Info(InfoCoh,2,"OCAddMatrices: module is trivial");
        return;
    else
        ocr.char :=RelativeOrderOfPcElement(base,base[1]);
        ocr.field:=GF(ocr.char);
        ocr.one:=One(ocr.field);
        ocr.zero:=Zero(ocr.field);
        # logTable is used by 'NextCentralCO'
        ocr.logTable:=[];
        for i in [1 .. ocr.char - 1] do
            ocr.logTable[LogFFE(i*One(ocr.field),
                                      PrimitiveRoot(ocr.field))+1]:=i;
        od;
    fi;

    # 'moduleMap' is constructed using 'Exponents'.
    ocr.moduleMap:=function(x)
                       x:=ExponentsOfPcElement(ocr.modulePcgs,x)* ocr.one;
                       return ImmutableVector(ocr.field,x);
                     end;
    ocr.matrices:=LinearOperationLayer(ocr.generators,ocr.modulePcgs);
    ocr.identityMatrix:=ImmutableMatrix(ocr.field,
        IdentityMat(Length(ocr.modulePcgs),ocr.field));
#    List(ocr.matrices,IsMatrix);
#    IsMatrix(ocr.identityMatrix);
#T ??

    # Do the same for the operations of 'normalIn' if present.
    if IsBound(ocr.normalIn)  then
        if not IsBound(ocr.normalMatrices)  then
            ocr.normalMatrices:=LinearOperationLayer(ocr.normalGenerators,
                ocr.modulePcgs);
#           List(ocr.normalMatrices,IsMatrix);
        fi;
    fi;

    # Construct the inverse of 'moduleMap'.
    ocr.vectorMap:=function(v)
        local   wrd, i;
        wrd:=One(ocr.modulePcgs[1]);
        for i in [1 .. Length(v)] do
            if v[i]<>ocr.zero  then
                wrd:=wrd*ocr.modulePcgs[i]^IntFFE(v[i]);
            fi;
        od;
        return wrd;
    end;

end);

#############################################################################
##
#F  OCAddToFunctions(<ocr>) . . . . . . . . . . add conversion,local
##
##
InstallGlobalFunction(OCAddToFunctions,function(ocr)
local   base, dim, gens;

    # Get the module generators.
    base:=ocr.modulePcgs;
    dim :=Length(base);

    # If 'smallGeneratingSet' is given,neither 'cocycle' nor 'list' need the
    # entries at the nongenerators.
    if not IsBound(ocr.cocycleToList)  then
        Info(InfoCoh,2,"OCAddToFunctions: adding 'cocycleToList'");
        ocr.cocycleToList:=function(c)
            local   w, i, j, k, L;
            L:=[];
            k:=0;
            for i in [1 .. Length(c) / dim] do
                w:=One(base[1]);
                for j in [1 .. dim] do
                    if c[k+j]<>ocr.zero  then
                        w:=w*base[j]^IntFFE(c[k+j]);
                    fi;
                od;
                Add(L,w);
                k:=k+dim;
            od;
            return L;
        end;
    fi;

    # 'listToCocycle' is almost trivial.
    if not IsBound(ocr.listToCocycle)  then
        Info(InfoCoh,2,"OCAddToFunctions: adding 'listToCocycle'");
        ocr.listToCocycle:=function(L)
            local   c, n;
            c:=[];
            for n in L do
                Append(c,ocr.moduleMap(n));
            od;
            #IsRowVector(c);
            ConvertToVectorRep(c,ocr.field);
            return ImmutableVector(ocr.field,c);
        end;
    fi;

    # If 'complement' is unknown,the following  function does not make sense,
    # so just return.
    if not IsBound(ocr.complement)  then
        Info(InfoCoh,2,"OCAddToFunctions: no complement,returning");
        return;
    fi;

    gens:=ocr.complementGens;

    # If  'smallGeneratingSet'  is  not present,just correct 'complement' by
    # the  list  'cocycleToList'. Otherwise we need to compute the correction
    # with the use of 'bigMatrices' and 'bigVectors'.
    if not IsBound(ocr.cocycleToComplement)  then
        Info(InfoCoh,2,"OCAddToFunctions: adding 'cocycleToComplement'");
        if not IsBound(ocr.smallGeneratingSet)  then
            ocr.cocycleToComplement:=function(c)
                local   L, i;
                L:=ocr.cocycleToList(c);
                for i in [1 .. Length(L)] do
                    L[i]:=gens[i]*L[i];
                od;
                return GroupByGenerators(L,One(base[1]));
            end;
        else

            # Get  the correcting list. The nongenerator correction are given
            # by  m_i + n_1*C_ij+... for i a nongenerator index and j a
            # generator index.  m_i  is  stored in<bigVectors>and C_ij is
            # stored in<bigMatrices>.
            ocr.cocycleToComplement:=function(c)
                local   L, i, n, j;
                L:=[];
                for i in [1 .. Length(c) / dim] do
                    n:=c{[(i-1)*dim+1 .. i*dim]};
                    L[ocr.smallGeneratingSet[i]]:=n;
                od;
                for i in [1 .. Length(gens)] do
                    if not IsBound(L[i])  then
                        n:=ocr.bigVectors[i];
                        for j in ocr.smallGeneratingSet do
                            n:=n+L[j]*ocr.bigMatrices[i][j];
                        od;
                        L[i]:=n;
                    fi;
                od;
                for i in [1 .. Length(L)] do
                    L[i]:=gens[i]*ocr.vectorMap(L[i]);
                od;
                return GroupByGenerators(L,One(base[1]));
            end;
        fi;
    fi;

    # As the IGS might be used especially here,first do not bind
    OCAddToFunctions2(ocr,ocr.generators);

end);

InstallMethod(OCAddToFunctions2,"pc group",true,[IsRecord,IsModuloPcgs],
  2,function(ocr,pcgs)
local  gens;

  gens:=ocr.complementGens;


  if not IsBound(ocr.complementToCocycle)  then

      ocr.origgens:=ocr.generators;
      Info(InfoCoh,2,"OCAddToFunctions: adding 'complementToCocycle'");
      if not IsBound(ocr.smallGeneratingSet)  then
          ocr.complementToCocycle:=function(K)
              local   L, i;
              # get the generators corresponding to the pcgs
              L:=CorrespondingGeneratorsByModuloPcgs(ocr.origgens,
                                                     GeneratorsOfGroup(K));
              for i in [1 .. Length(gens)] do
                  L[i]:=LeftQuotient(gens[i],L[i]);
              od;
              return ocr.listToCocycle(L);
          end;
      else
          Error("not yet implemented");
          ocr.complementToCocycle:=function(K)
              local   L, S, i, j;
              L:=CanonicalPcgs(InducedPcgsByGenerators(ocr.generators,
                               GeneratorsOfGroup(K)));
              S:=[];
              for i in [1 .. Length(ocr.smallGeneratingSet)] do
                  j:=ocr.smallGeneratingSet[i];
                  S[i] :=LeftQuotient(gens[j],L[j]);
              od;
              return ocr.listToCocycle(S);
          end;
      fi;
  fi;

end);

InstallMethod(OCAddToFunctions2,"generic",true,[IsRecord,IsList],0,
function(ocr,gens)
local Ngens;

  gens:=ocr.complementGens;

  if not IsBound(ocr.complementToCocycle)  then
      Info(InfoCoh,2,"OCAddToFunctions: adding 'complementToCocycle'");
      if not IsBound(ocr.smallGeneratingSet)  then
          Ngens:=NumeratorOfModuloPcgs(ocr.modulePcgs);
          ocr.complementToCocycle:=function(K)
          local   L,i,hom;
            # create a homomorphism to decompose into generators
            hom:= GroupHomomorphismByImagesNC(ocr.group,K,
                   Concatenation(GeneratorsOfGroup(K),Ngens),
                   Concatenation(GeneratorsOfGroup(K),List(Ngens,i->One(K))));

            L:=[];
            for i in [1 .. Length(gens)] do
                L[i]:=LeftQuotient(gens[i],
                            ImagesRepresentative(hom,gens[i]));
            od;
            return ocr.listToCocycle(L);
          end;
      else
         Error("this should not happen");
      fi;
  fi;

end);

#############################################################################
##
#F  OCAddCentralizer(<ocr>,<B>)  . . . . . . . add centralizer by base<B>
##
BindGlobal( "OCAddCentralizer", function(ocr,B)
    ocr.centralizer:=GroupByGenerators(List(B,ocr.vectorMap),
                                          One(ocr.group));
end );


#############################################################################
##
#F  OCOneCoboundaries(<ocr>)    . . . . . . . . . . one cobounds main routine
##
InstallGlobalFunction(OCOneCoboundaries,function(ocr)
local   B, S, L, T, i, j;

    # Add the important record components for coboundaries.
    if IsBound(ocr.oneCoboundaries)  then
        return ocr.oneCoboundaries;
    fi;

    Info(InfoCoh,1,"OCOneCoboundaries: coboundaries and centralizer");
    OCAddGenerators(ocr,ocr.group);
    OCAddMatrices(ocr,ocr.generators);

    # Construct (1 - M[1], ...,1 - M[n]).
    if IsBound(ocr.smallGeneratingSet)  then
        S:=ocr.smallGeneratingSet;
    else
        S:=[1 .. Length(ocr.generators)];
    fi;
    L:=[];
    T:=ocr.identityMatrix;
    for i in [1 .. Length(T)] do
        L[i]:=[];
        for j in S do
            Append(L[i],T[i] - ocr.matrices[j][i]);
        od;
    od;
    IsMatrix(L);

    # If there are no equations,return.
    if Length(S) = 0  then
        Info(InfoCoh,1,"OCOneCoboundaries: group is trivial");
        ocr.oneCoboundaries:=FullRowSpace(ocr.field,0);
        ocr.centralizer:=SubgroupNC(ocr.group,ocr.modulePcgs);
        return ocr.oneCoboundaries;
    fi;

    # Find a base for the one coboundaries.
    B:=TriangulizedGeneratorsByMatrix(ocr.modulePcgs ,L,ocr.field);
    ocr.oneCoboundaries:=VectorSpace(ocr.field,B[2],Zero(ocr.field)*L[1]);

    ocr.triangulizedBase:=B[1];
    Info(InfoCoh,1,"OCOneCoboundaries: |B^1| = ",ocr.char,
               "^",Dimension(ocr.oneCoboundaries));
    ocr.heads:=[];
    j:=1;
    i:=1;
    while i<= Length(B[2]) and j<= Length(B[2][1]) do
        if B[2][i][j]<>ocr.zero  then
            ocr.heads[i]:=j;
            i:=i+1;
        fi;
        j:=j+1;
    od;

    # Now get the nullspace, this is the centralizer.
    OCAddCentralizer(ocr,NullspaceMat(L));
    Info(InfoCoh,1,"OCOneCoboundaries: |C| = ",ocr.char,
               "^",Length(GeneratorsOfGroup(ocr.centralizer)));
    OCAddToFunctions(ocr);
    return ocr.oneCoboundaries;

end);


#############################################################################
##
#F  OCConjugatingWord(<ocr>,<c1>,<c2>)  . . . . . . . . . . . . . . local
##
##  Compute a Word n in<ocr.module>such that<c1>^ n =<c2>.
##
InstallGlobalFunction(OCConjugatingWord,function(ocr,c1,c2)
local   B, w, v, j;

    B:=ocr.triangulizedBase;
    w:=One(ocr.modulePcgs[1]);
    v:=c2 - c1;
    for j in [1 .. Length(ocr.heads)] do
        #if IntFFE(v[ocr.heads[j]])<>false  then
        w:=w*B[j]^IntFFE(v[ocr.heads[j]]);
        #fi;
    od;
    return w;

end);


#############################################################################
##
#F  OCAddRelations(<ocr>,<gens>) . . . . . . . . . . .  add relations,local
##
InstallMethod(OCAddRelations,"pc group",true,[IsRecord,IsModuloPcgs],0,
function(ocr,gens )
local   p, w, r, i, j, k,mpcgs;


    # If<ocr>has a  record component 'relators',nothing is done.
    if IsBound(ocr.relators)  then
        return;
    fi;
    Info(InfoCoh,2,"OCAddRelations: computes pc-presentation");

    # Construct the factor pcgs

    mpcgs :=ocr.generators;

    # Start  with the power-relations. If g1^p = g2^3*g4^5*g5,then
    # the  relator  g1 ^ -p * g2 ^ 3 *g4^5*g5 is used,because it
    # contains only one negative exponent.
    ocr.relators:=[];
    for i in [1 .. Length(mpcgs)] do
        p:=RelativeOrders(mpcgs)[i];
        r:=rec(generators:=[i],powers:=[-p] );
        w:=ExponentsOfRelativePower(mpcgs,i);
        for j in [1 .. Length(w)] do
            if w[j]<>0  then
                Add(r.generators,j);
                Add(r.powers,w[j]);
            fi;
        od;
        r.usedGenerators:=Set(r.generators);
        Add(ocr.relators,r);
    od;

    # Now  compute  the  conjugated words. If g1^g2 = g3^5*g4^2,then
    # the  relator (g1^-1)^g2*g3^5*g4^2 is used,as it contains
    # only two negative exponents.
    for i in [1 .. Length(mpcgs) - 1] do
        for j in [i+1 .. Length(mpcgs)] do
            r:=rec(generators:=[i,j,i],powers:=[-1,-1,1]);
            w:=mpcgs[j]^mpcgs[i];
            w:=ExponentsOfPcElement(mpcgs,w);
            for k in [1 .. Length(w)] do
                if w[k]<>0  then
                    Add(r.generators,k);
                    Add(r.powers,w[k]);
                fi;
            od;
            r.usedGenerators:=Set(r.generators);
            Add(ocr.relators,r);
        od;
    od;

end);

InstallMethod(OCAddRelations,"perm group",true,[IsRecord,IsList],0,
function(ocr,gens )
local   r,rel,i,j,w;

  # If<ocr>has a  record component 'relators',nothing is done.
  if IsBound(ocr.relators)  then
      return;
  fi;
  Info(InfoCoh,2,"OCAddRelations: fetch presentation");

  # it is not the right place to get a presentation here,as we may have
  # chosen the wrong generators before. So we just fetch it.

  r:=ocr.factorpres[2];

  # now rewrite the relators into the OC form

  ocr.relators:=[];

  for i in r do
    rel:=rec(generators:=[],powers:=[]);

    w:=ExtRepOfObj(i);
    j:=1;
    while j<Length(w) do
      Add(rel.generators,w[j]);
      Add(rel.powers,w[j+1]);
      j:=j+2;
    od;

    rel.usedGenerators:=Set(rel.generators);
    Add(ocr.relators,rel);
  od;

end);

BindGlobal("OCTestRelations",function(ocr,gens)
local i,j,e,g;
  g:=GroupByGenerators(NumeratorOfModuloPcgs(ocr.modulePcgs));
  for i in ocr.relators do
    e:=One(gens[1]);
    for j in [1..Length(i.generators)] do
      e:=e*gens[i.generators[j]]^i.powers[j];
    od;
    if not e in g then
      Error("relator wrong");
    fi;
  od;
  return true;
end);

#############################################################################
##
#M  NormalRelations(<ocr>,<G>,<gens>)  . .  rels for normal complements,local
##
InstallMethod(OCNormalRelations,"pc group",
  true,[IsRecord,IsPcGroup,IsListOrCollection],0,
function(ocr,G,gens)
local   i,j,k,
        relations,
        r,
        w,mpcgs;

    Info(InfoCoh,2,"computes rels for normal complements");

    Error("this still has to be fixed!");

    mpcgs:=InducedPcgsByGeneratorsNC(ocr.pcgs,
               Concatenation(ocr.generators,ocr.modulePcgs)) mod
               ocr.modulePcgs;
    # Compute  g_i^s_j for all generators s_j in 'normalGenerators' and all
    # i in<generators>.
    relations:=[];
    for i in [1 .. Length(gens)] do
        for j in [1 .. Length(ocr.normalGenerators)] do
            r:=rec(generators:=[],
                      powers    :=[],
                      conjugated:=[i,j]);
            w:=ocr.generators[gens[i]]^ocr.normalGenerators[j];
            w:=ExponentsOfPcElement(mpcgs,w);
            for k in [1 .. Length(w)] do
                if w[k]<>0  then
                    Add(r.generators,k);
                    Add(r.powers,w[k]);
                fi;
            od;
            r.usedGenerators:=Set(r.generators);
            Add(relations,r);
        od;
    od;
    return relations;

end);


#############################################################################
##
#M  OCAddSumMatrices(<ocr>,<gens>)  . . . . . . . . . . . add sums,local
##
InstallMethod(OCAddSumMatrices,"pc group",true,[IsRecord,IsPcgs],0,
function(ocr,pcgs)
local   i, j;

    if not IsBound(ocr.maximalPowers)  then
        Info(InfoCoh,2,"maximal powers = relative orders");
        ocr.maximalPowers:=List(ocr.generators,
          i->RelativeOrderOfPcElement(pcgs,i));
    fi;

    # At  first  add  all  powers, such  that  powerMatrices[ i ][ j] is
    # matrices[ i ] ^j for j = 1 ... p,if p is the maximal power for the
    # i.th generator.
    if not IsBound(ocr.powerMatrices)  then
        Info(InfoCoh,2,"AddSumMatrices: adding power matrices");
        ocr.powerMatrices:=[];
        for i in [1 .. Length(ocr.matrices)] do
            ocr.powerMatrices[i]:=[ocr.matrices[i]];
            for j in [2 .. ocr.maximalPowers[i]] do
                ocr.powerMatrices[i][j] :=
                    ocr.powerMatrices[i][j - 1]*ocr.matrices[i];
            od;
        od;
    fi;

    # Now  all  sums, such  that sumMatrices[i][j] is the sum from k = 0
    # up to j - 1 over matrices[i]^k for j = 1 ... p.
    if not IsBound(ocr.sumMatrices)  then
        Info(InfoCoh,2,"AddSumMatrices: adding sum matrices");
        ocr.sumMatrices:=[];
        for i in [1 .. Length(ocr.matrices)] do
            ocr.sumMatrices[i]:=[ocr.identityMatrix];
            for j in [2 .. ocr.maximalPowers[i]] do
                ocr.sumMatrices[i][j] :=
                    ocr.sumMatrices[i][j-1]+ocr.powerMatrices[i][j-1];
            od;
        od;
    fi;

end);


InstallMethod(OCAddSumMatrices,"perm group",true,[IsRecord,IsList],0,
function(ocr,gens)
local   i,j;

    if not IsBound(ocr.maximalPowers)  then
        Info(InfoCoh,2,"AddSumMatrices: maximal power = 1");
        ocr.maximalPowers:=List(ocr.generators,x->1);
    fi;

    # At  first  add  all  powers, such  that  powerMatrices[ i ][ j] is
    # matrices[ i ] ^j for j = 1 ... p,if p is the maximal power for the
    # i.th generator.
    if not IsBound(ocr.powerMatrices)  then
        Info(InfoCoh,2,"AddSumMatrices: adding power matrices");
        ocr.powerMatrices:=[];
        for i in [1 .. Length(ocr.matrices)] do
            ocr.powerMatrices[i]:=[ocr.matrices[i]];
            for j in [2 .. ocr.maximalPowers[i]] do
                ocr.powerMatrices[i][j] :=
                    ocr.powerMatrices[i][j - 1]*ocr.matrices[i];
            od;
        od;
    fi;

    # Now  all  sums, such  that sumMatrices[i][j] is the sum from k = 0
    # up to j - 1 over matrices[i]^k for j = 1 ... p.
    if not IsBound(ocr.sumMatrices)  then
        Info(InfoCoh,2,"AddSumMatrices: adding sum matrices");
        ocr.sumMatrices:=[];
        for i in [1 .. Length(ocr.matrices)] do
            ocr.sumMatrices[i]:=[ocr.identityMatrix];
            for j in [2 .. ocr.maximalPowers[i]] do
                ocr.sumMatrices[i][j] :=
                    ocr.sumMatrices[i][j-1]+ocr.powerMatrices[i][j-1];
            od;
        od;
    fi;

end);

#############################################################################
##
#F  OCEquationMatrix(<ocr>,<r>,<n>)  . . . . . . . . . . . . . . .  local
##
InstallGlobalFunction(OCEquationMatrix,function(ocr,r,n)
local   mat, i, j, v, vv;

    Info(InfoCoh,3,"OCEquationMatrix: matrix number ",n);
    mat:=ocr.identityMatrix - ocr.identityMatrix;
    if not n in r.usedGenerators  then return mat;  fi;

    #  For j:=generators[i], v:=powers[i], M operations:
    #
    #    if j = n and v>0,then
    #           mat = mat*M[j]^v+sum_{k=0}^{v-1} M[j]^k
    #    if j = n and v<0,then
    #           mat = (mat - sum_{k=0}^{-v-1} M[j]^k)*M[j]^v
    #    if j<>n,then
    #           mat = mat*M[j]^v
    #
    for i in [1 .. Length(r.generators)] do
        j :=r.generators[i];
        vv:=r.powers[i];

        # Repeat,until we used up all powers.
        while vv<>0 do
            if AbsInt(vv)>AbsInt(ocr.maximalPowers[j])  then
                v :=SignInt(vv)*ocr.maximalPowers[j];
                vv:=vv - v;
            else
                v :=vv;
                vv:=0;
            fi;
            if j = n and v>0   then
                mat:=mat*ocr.powerMatrices[j][v]+ocr.sumMatrices[j][v];
            elif j = n and v<0  then
                mat:=  (mat - ocr.sumMatrices[j][-v])
                      *(ocr.powerMatrices[j][-v]^-1);
            elif j<>n and v>0  then
                mat:=mat*ocr.powerMatrices[j][v];
            elif j<>n and v<0  then
                mat:=mat*(ocr.powerMatrices[j][-v]^-1);
            else
                Info(InfoCoh,2,"OCEquationMatrix: zero power");
            fi;
        od;
    od;

    # if<r>  has an entry   'conjugated'  the records  is  no relator for a
    # presentation,but belongs to relation
    #         (g_i n_i)^s_j = r
    # which is used to determinate  normal  complements.  [i,j]  is bound  to
    # 'conjugated'.  If i<><n>,we can  forget about it,but otherwise -s_j
    # must be added.
    if IsBound(r.conjugated) and r.conjugated[1] = n  then
        mat:=mat - ocr.normalMatrices[r.conjugated[2]];
    fi;
    return mat;

end);


#############################################################################
##
#M  OCAddBigMatrices(<ocr>,<generators>)   . . . . . . . . . . . . . local
##
InstallMethod(OCAddBigMatrices,"general",true,[IsRecord,IsList],0,
function(ocr,G)
local   i, j, n, w, small, nonSmall;

    # If no small generating set is known simply return.
    if not IsBound(ocr.smallGeneratingSet)  then
        Info(InfoCoh,2,"AddBigMatrices: no small generating set");
        return;
    fi;
    small:=ocr.smallGeneratingSet;
    nonSmall:=Difference([1 .. Length(ocr.generators)],small);
    if not IsBound(ocr.bigMatrices)  then
        ocr.bigMatrices:=List([1 .. Length(ocr.generators)],x->[]);
        Info(InfoCoh,2,"AddBigMatrices: adding bigMatrices");
        for i in nonSmall do
            for j in small do
                ocr.bigMatrices[i][j]:=OCEquationMatrix(ocr,
                    ocr.generatorsInSmall[i],j);
            od;
        od;
    fi;

    # Compute n_(i) for non small generators i.
    if not IsBound(ocr.bigVectors)  then
        Info(InfoCoh,2,"AddBigMatricesOC: adding bigVectors");
        ocr.bigVectors:=[];
        for i in nonSmall do
            n:=ocr.generators[i]^-1;
            w:=ocr.generatorsInSmall[i];
            for j in [1 .. Length(w.generators)] do
                n:=n*ocr.generators[w.generators[j]]^w.powers[j];
            od;
            ocr.bigVectors[i]:=ocr.moduleMap(n);
        od;
    fi;

end);


#############################################################################
##
#F  OCSmallEquationMatrix(<ocr>,<r>,<n>)  . . . . . . . . . . . . . local
##
InstallGlobalFunction(OCSmallEquationMatrix,function(ocr,r,n)
local   mat, i, j, v, vv;

    Info(InfoCoh,3,"OCSmallEquationMatrix: matrix number ",n);
    mat:=ocr.identityMatrix - ocr.identityMatrix;

    #<n>must a small generator.
    if not n in ocr.smallGeneratingSet  then
      Error("<n> is no small generator");
    fi;

    # Warning: if<n>is not in <r.usedGenerators>we cannot  return,as the
    # nonsmall generators may yield a result.

    # For j:=generators[i], v:=powers[i], M operations:
    #
    # If j is a small generator,everything is as usual.
    #
    #    if j = n and v>0, then
    #          mat = mat*M[j]^v+sum_{k=0}^{v-1} M[j]^k
    #    if j = n and v<0, then
    #          mat = (mat - sum_{k=0}^{-v-1} M[j]^k)*M[j]^v
    #    if j<>n,then
    #          mat = mat*M[j]^v
    #
    # If j is not  a small generator, then j<>n.   But  we need to correct
    #<mat>using the<bigMatrices>:
    #
    #   n_j = n_(j)+...+n_n^C_jn+...
    #
    #   if v>0,then
    #         mat = mat*M[j]^v+C_jn*sum_{k=0}^{v-1} M[j]^k
    #   If v<0,then
    #         mat = (mat - C_jn*sum_{k=0}^{-v-1} M[j]^k)*M[j]^v
    #
    for i in [1 .. Length(r.generators)] do
        j :=r.generators[i];
        vv:=r.powers[i];
        while vv<>0 do
            if AbsInt(vv)>AbsInt(ocr.maximalPowers[j])  then
                v :=SignInt(vv)*ocr.maximalPowers[j];
                vv:=vv - v;
            else
                v :=vv;
                vv:=0;
            fi;
            if j in ocr.smallGeneratingSet  then
                if j = n and v>0   then
                    mat:=mat*ocr.powerMatrices[j][v]
                          +ocr.sumMatrices[j][v];
                elif j = n and v<0  then
                    mat:=(mat - ocr.sumMatrices[j][-v])
                          *(ocr.powerMatrices[j][-v]^-1);
                elif j<>n and v>0  then
                    mat:=mat*ocr.powerMatrices[j][v];
                elif j<>n and v<0  then
                    mat:=mat*(ocr.powerMatrices[j][-v]^-1);
                else
                    Info(InfoCoh,2,"EquationMatrixOC: zero power");
                fi;
            else
                if v>0  then
                    mat:=mat*ocr.powerMatrices[j][v]
                          +ocr.bigMatrices[j][n]*ocr.sumMatrices[j][v];
                elif v<0  then
                    mat:=(mat-ocr.bigMatrices[j][n]*ocr.sumMatrices[j][-v])
                          *(ocr.powerMatrices[j][-v]^-1);
                else
                    Info(InfoCoh,2,"EquationMatrixOC: zero power");
                fi;
            fi;
        od;
    od;

    # If<r>  has an entry  <conjugated> the records  is  no relator for a
    # presentation,but belongs to relation
    #         (g_i n_i)^s_j =<r>
    # which is  used to determinate  normal complements.   [i,j] is  bound to
    # 'conjugated'.  If i<><n>,we can  forget about it,but  otherwise s_j
    # must be added. i is always a small generator.
    if IsBound(r.conjugated) and r.conjugated[1] = n  then
        mat:=mat - ocr.normalMatrices[r.conjugated[2]];
    fi;
    return mat;

end);


#############################################################################
##
#F  OCEquationVector(<ocr>,<r>)  . . . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction(OCEquationVector,function(ocr,r)
local n,i;

  # If <r> has   an entry 'conjugated'   the records is  no relator  for  a
  # presentation,but belongs to relation
  #       (g_i n_i)^s_j =<r>
  # which is  used to determinate  normal  complements.   [i,j] is bound to
  # <conjugated>.
  if IsBound(r.conjugated)  then
    n:=(ocr.generators[r.conjugated[1]]
           ^ocr.normalGenerators[r.conjugated[2]])^-1;
  else
    n:=ocr.identity;
  fi;

  for i in [1 .. Length(r.generators)] do
    n:=n*ocr.generators[r.generators[i]]^r.powers[i];
  od;

  Assert(1,n in GroupByGenerators(NumeratorOfModuloPcgs(ocr.modulePcgs)));

  return ShallowCopy(ocr.moduleMap(n));

end);


#############################################################################
##
#F  OCSmallEquationVector(<ocr>,<r>)    . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction(OCSmallEquationVector,function(ocr,r)
local   n, a, i, nonSmall, v, vv, j;

    # if<r>has  an entry 'conjugated'  the  records  is no relator   for  a
    # presentation,but belongs to relation
    #     (g_i n_i)^s_j =<r>
    # which is used to determinate normal complements.  [i,j] is bound  to
    # 'conjugated'. i is always a small generator.
    if IsBound(r.conjugated)  then
        n:=(ocr.generators[r.conjugated[1]]
              ^ocr.normalGenerators[r.conjugated[2]])^-1;
    else
        n:=ocr.identity;
    fi;

    # At first the vector of the relator itself.
    for i in [1 .. Length(r.generators)] do
        n:=n*ocr.generators[r.generators[i]]^r.powers[i];
    od;
    n:=ocr.moduleMap(n);

    # Each  non  small generators in<r>gives an additional vector. It
    # must be shifted through the relator.
    nonSmall:=Difference([1 .. Length(ocr.generators)],
                            ocr.smallGeneratingSet);
    a:=n - n;
    for i in [1 .. Length(r.generators)] do
        j :=r.generators[i];
        vv:=r.powers[i];
        while vv<>0 do
            if AbsInt(vv)>AbsInt(ocr.maximalPowers[j])  then
                v :=SignInt(vv)*ocr.maximalPowers[j];
                vv:=vv - v;
            else
                v :=vv;
                vv:=0;
            fi;

            if j in nonSmall  then
                if v>0  then
                    a:=a*ocr.powerMatrices[j][v]+ocr.bigVectors[j]
                        *ocr.sumMatrices[j][v];
                elif v<0  then
                    a:=(a - ocr.bigVectors[j]
                        *ocr.sumMatrices[j][-v])
                        *(ocr.powerMatrices[j][-v]^-1);
                else
                    Info(InfoCoh,2,"OCSmallEquationVector: zero power");
                fi;
            else
                if v>0  then
                    a:=a*ocr.powerMatrices[j][v];
                elif v<0  then
                    a:=a*(ocr.powerMatrices[j][-v]^-1);
                else
                    Info(InfoCoh,2,"OCSmallEquationVector: zero power");
                fi;
            fi;
        od;
    od;

    return ShallowCopy(n+a);

end);


#############################################################################
##
#F  OCAddComplement(<ocr>,<K>) . . . . . . . . . . . . . . . . . . . local
##
InstallMethod(OCAddComplement,"pc group",true,
  [IsRecord,IsPcGroup,IsListOrCollection],0,
function(ocr,G,K)
    ocr.complementGens:=K;
    Assert(1,ForAll([1..Length(ocr.complementGens)],i->
             ExponentsOfPcElement(ocr.generators,ocr.complementGens[i])
             =ExponentsOfPcElement(ocr.generators,ocr.generators[i])));

    K:=InducedPcgsByGeneratorsNC(NumeratorOfModuloPcgs(ocr.generators),K);
    ocr.complement:=SubgroupNC(ocr.group,K);
end);

InstallMethod(OCAddComplement,"generic",true,
  [IsRecord,IsGroup,IsListOrCollection],0,
function(ocr,G,K)
    ocr.complement:=SubgroupNC(ocr.group,K);
    ocr.complementGens:=K;
end);


#############################################################################
##
#F  OCOneCocycles(<ocr>,<onlySplit>) . . . . . . one cocycles main routine
##
##  If<onlySplit>,'OCOneCocycles' returns 'false' as soon  as  possibly  if
##  the extension does not split.
##
InstallGlobalFunction(OCOneCocycles,function(ocr,onlySplit)
local   cobounds,cocycles,    # base of one coboundaries and cocycles
        dim,                # dimension of module
        gens,               # generator numbers
        len,                # number of generators
        K,                  # list of complement generators
        L0,                 # null vector
        S, R,               # linear system and right hand side
        rels,               # relations
        RS, RR,             # rel linear system and right hand side
        isSplit,            # is split extension
        N,                  # correct
        row,                # one row
        tmp,i,g,j,k,n;

    # If we know our cocycles return them.
    if IsBound(ocr.oneCocycles)  then
        return ocr.oneCocycles;
    fi;

    # Assume it does split. This may change later.
    isSplit:=true;

    ocr.identity:=One(ocr.modulePcgs[1]);
    Info(InfoCoh,1,"OCOneCocycles: computes cocycles and cobounds");

    # We  need the generators of the factorgroup with relations,all matrices
    # and  the  cobounds.  If  the 'smallGeneratingSet' is given,get the big
    # matrices and vectors.
    cobounds:=BasisVectors(Basis(OCOneCoboundaries(ocr)));

    # If  we  are only want normal complements,the group of cobounds must be
    # trivial,  otherwise  there  are  no  normal  ones  as  the  conjugated
    # complements correspond with the cobounds.
    if IsBound(ocr.normalIn) and cobounds<>[]  then
        Info(InfoCoh,1,"OneCocyclesCO: no normal complements");
        return false;
    fi;

    # Initialize the relations and sum/big matrices.
    OCAddRelations(ocr,ocr.generators);
    Assert(1,OCTestRelations(ocr,ocr.generators)=true);

    OCAddSumMatrices(ocr,ocr.generators);
    if IsBound(ocr.smallGeneratingSet)  then
        OCAddBigMatrices(ocr,ocr.generators);
    fi;

    # Now initialize  a  matrix  with  will  hold the triangulized system of
    # linear  equations.  If  'smallGeneratingSet'  is  given  use  this, if
    # 'pPrimeSet' is given do not use those.
    dim:=Length(ocr.modulePcgs);
    if IsBound(ocr.smallGeneratingSet)  then
        gens:=ocr.smallGeneratingSet;
        len :=Length(ocr.smallGeneratingSet);
        K   :=ShallowCopy(ocr.generators);
    elif IsBound(ocr.pPrimeSet)  then
        Info(InfoCoh,2,"OCOneCocycles: computing coprime complement");
        gens:=Difference([1 .. Length(ocr.generators)],ocr.pPrimeSet);
        gens:=Set(gens);
        len :=Length(ocr.generators) - Length(ocr.pPrimeSet);
        K   :=OCCoprimeComplement(ocr,ocr.generators);
        ocr.generators:=ShallowCopy(K);
    else
        len :=Length(ocr.generators);
        gens:=[1 .. len];
        K   :=ShallowCopy(ocr.generators);
    fi;
    Info(InfoCoh,2,"OCOneCocycles: ",len," generators");

    # Initialize system.
    tmp:=ocr.moduleMap(ocr.identity);
    L0 :=Concatenation(List([1 .. len],x->tmp));
    L0:=ImmutableVector(ocr.field,L0);
    S:=List([1 .. len*dim],x->L0);
    #R:=List([1 .. len*dim],x->Zero(ocr.field));
    R:=ListWithIdenticalEntries(len*dim,Zero(ocr.field));

    # Get  the  linear  system  for one relation and append it to the already
    # triangulized system.
    Info(InfoCoh,2,"OCOneCocycles: constructing linear equations: ");

    # Get all relations.
    if IsBound(ocr.normalIn)  then
        rels:=Concatenation(ocr.relators,
                               OCNormalRelations(ocr,ocr.group,gens));
    else
        rels:=ocr.relators;
    fi;

    for i in [1 .. Length(rels)] do
        Info(InfoCoh,2,"  relation ",i," (",Length(rels),")");
        RS:=[];
        if IsBound(ocr.smallGeneratingSet)  then
            for g in gens do
                Append(RS,OCSmallEquationMatrix(ocr,rels[i],g));
            od;
            RR:=OCSmallEquationVector(ocr,rels[i]);
            MultVector(RR,-One(ocr.field));

        else
            for g in gens do
                Append(RS,OCEquationMatrix(ocr,rels[i],g));
            od;
            RR:=OCEquationVector(ocr,rels[i]);
            MultVector(RR,-One(ocr.field));

        fi;

        # The is a system for x M = v so transpose.
        RS:=MutableTransposedMat(RS);

        # Now append this to the triangulized system.
        for j in [1 .. Length(RS)] do
            k:=1;
            while RS[j]<>L0 do
                while RS[j][k] = ocr.zero do
                    k:=k+1;
                od;
                if S[k][k]<>ocr.zero  then
                    RR[j]:=RR[j] - RS[j][k]*R[k];
                    RS[j]:=RS[j] - RS[j][k]*S[k];
                else
                    R[k]:=RS[j][k]^-1*RR[j];
                    S[k]:=RS[j][k]^-1*RS[j];
                    RS[j]:=L0;
                    RR[j]:=0*RR[j];
                fi;
            od;
            if RR[j] <>ocr.zero  then
                Info(InfoCoh,1,"OCOneCocycles: no split extension");
                isSplit:=false;
                if onlySplit  then
                    return isSplit;
                fi;
            fi;
        od;
        IsMatrix(RS);
    od;

    # Now remove all  entries above the  diagonal.  Let's see  if a  solution
    # exist.  As system <S> is triangulized all we have to do,is to check if
    # right side <R> is null,where the diagonal is null.
    Info(InfoCoh,2,"OCOneCocycles: computing nullspace and solution");
    for i in [1 .. Length(S)] do
        if S[i][i]<>ocr.zero  then
            for k in [1 .. i-1] do
                if S[k][i]<>ocr.zero  then
                    R[k]:=R[k] - S[k][i]*R[i];
                    S[k]:=S[k] - S[k][i]*S[i];
                fi;
            od;
        else
            if R[i]<>ocr.zero  then
                Info(InfoCoh,1,"OCOneCocycles: no split extension");
                isSplit:=false;
                if onlySplit  then
                    return isSplit;
                fi;
            fi;
        fi;
    od;

    # As <system>is triangulized,the right side is now the solution. So if
    # 'smallGeneratingSet'   is  not  given, we  only  need  to  modify  the
    #<complement> generators, which  are  not in 'pPrimeSet'. Otherwise we
    # must  blow  up  the  cocycle to cover all generators not only the small
    # ones.
    if isSplit  then
        if not IsBound(ocr.smallGeneratingSet)  then
            N:=ocr.cocycleToList(R);
            for i in [1 .. Length(N)] do
                K[gens[i]]:=K[gens[i]]*N[i];
            od;
        else
            N:=[];
            for i in [1 .. Length(R) / dim] do
                n:= R{ [(i-1)*dim+1 .. i*dim] };
                N[ocr.smallGeneratingSet[i]]:=n;
            od;
            for i in [1 .. Length(K)] do
                if not IsBound(N[i])  then
                    n:=ocr.bigVectors[i];
                    for j in ocr.smallGeneratingSet do
                        n:=n+N[j]*ocr.bigMatrices[i][j];
                    od;
                else
                    n:=N[i];
                fi;
                K[i]:=K[i]*ocr.vectorMap(n);
            od;
        fi;
        OCAddComplement(ocr,ocr.group,K);
        OCAddToFunctions(ocr);
    fi;

    # System<S>is triangulized, get the nullspace.
    cocycles:=[];
    for i in [1 .. Length(S[1])] do
        if  S[i][i] = ocr.zero  then
            row:=ShallowCopy(L0);
            for k in [1 .. i-1] do
                row[k]:=S[k][i];
            od;
            row[i]:=- One(ocr.field);
            Add(cocycles,row);
        fi;
    od;
    IsMatrix(cocycles);

    # If  'pPrimeSet'  is  given, we  need  to  add  zeros to cocycle at the
    # positions  of  the pPrimeGenerators. Then the cobounds must be added in
    # order to get all cocycles.
    if IsBound(ocr.pPrimeSet)  then
        tmp:=ocr.moduleMap(ocr.identity);
        for j in [1 .. Length(cocycles)] do
            k:=0;
            row:=[];
            for i in [1 .. Length(ocr.generators)] do
                if not i in ocr.pPrimeSet  then
                    n:=cocycles[j]{ [k*dim+1 .. (k+1)*dim] };
                    Append(row,n);
                    k:=k+1;
                else
                    Append(row,tmp);
                fi;
            od;
            #IsRowVector(row);
            cocycles[j]:=ImmutableVector(ocr.field,row);
        od;
        Append(cocycles,cobounds);
        if cocycles<>[]  then
            cocycles:=BaseMat(cocycles);
        fi;
    else
        if cocycles<>[]  then
            TriangulizeMat(cocycles);
        fi;
    fi;
    ocr.oneCocycles:=VectorSpace(ocr.field,cocycles,
                              Zero(ocr.oneCoboundaries));
    Info(InfoCoh,1,"OCOneCocycles: order of cocycles ",ocr.char,
               "^",Dimension(ocr.oneCocycles));
    return ocr.oneCocycles;

end);


#############################################################################
##
#M  OneCoboundaries(<G>,<M>)    . . . . . . . . . . one cobounds of<G>/<M>
##
InstallGlobalFunction(OneCoboundaries,function(G,M)
local ocr;


  if not IsList(M) then
    if not IsElementaryAbelian(M) then
      Error("<M> must be elementary abelian");
    fi;
    M:=InducedPcgsWrtHomePcgs(M);
  fi;

  ocr:=rec(modulePcgs:=M);
  if IsGroup(G) then
    ocr.group:=G;
  else
    ocr.group:= GroupByGenerators(G);
    ocr.generators:=G;
  fi;

  OCOneCoboundaries(ocr);

  return rec(
      oneCoboundaries:=ocr.oneCoboundaries,
      generators     :=ocr.generators,
      cocycleToList  :=ocr.cocycleToList,
      listToCocycle  :=ocr.listToCocycle);

end);


#############################################################################
##
#F  OneCocycles(<G>,<M>) . . . . . . . . . . . . one cocycles of<G>/<M>
##
InstallGlobalFunction(OneCocycles,function(G,M)
local   ocr,erg;

  if not IsList(M) then
    if not IsElementaryAbelian(M) then
      Error("<M> must be elementary abelian");
    fi;
    M:=InducedPcgsWrtHomePcgs(M);
  fi;

  ocr:=rec(modulePcgs:=M);
  if IsGroup(G) then
    ocr.group:=G;
  else
    ocr.group:= GroupByGenerators(G);
    ocr.generators:=G;
  fi;

  OCOneCocycles(ocr,false);

  if IsBound(ocr.complement)  then
      erg:=rec(
          oneCoboundaries    :=ocr.oneCoboundaries,
          oneCocycles        :=ocr.oneCocycles,
          generators         :=ocr.generators,
          isSplitExtension   :=true,
          complement         :=ocr.complement,
          complementGens     :=ocr.complementGens,
          cocycleToList      :=ocr.cocycleToList,
          listToCocycle      :=ocr.listToCocycle,
          cocycleToComplement:=ocr.cocycleToComplement,
          factorGens         :=ocr.generators);
      if IsBound(ocr.complementToCocycle) then
        erg.complementToCocycle:=ocr.complementToCocycle;
      fi;
      return erg;
  else
      return rec(
          oneCoboundaries    :=ocr.oneCoboundaries,
          oneCocycles        :=ocr.oneCocycles,
          generators         :=ocr.generators,
          cocycleToList      :=ocr.cocycleToList,
          listToCocycle      :=ocr.listToCocycle,
          isSplitExtension   :=false);
  fi;

end);


#############################################################################
##
#F  ComplementClassesRepresentativesEA(<G>,<N>) . complement classes to el.ab. N by 1-Cohom.
##
InstallGlobalFunction(ComplementClassesRepresentativesEA,function(g,n)
local oc,l;
  if Size(g)=Size(n) then
    return TrivialSubgroup(g);
  fi;
  oc:=OneCocycles(g,n);
  if not oc.isSplitExtension  then
    return [];
  else
    if Dimension(oc.oneCocycles)=Dimension(oc.oneCoboundaries) then
      return [oc.complement];
    else
      l:=BaseSteinitzVectors(BasisVectors(Basis(oc.oneCocycles)),
                             BasisVectors(Basis(oc.oneCoboundaries)));
      l:=List(VectorSpace(LeftActingDomain(oc.oneCocycles),l.factorspace,
                          Zero(oc.oneCocycles)),
              i->oc.cocycleToComplement(i));
      return l;
    fi;
  fi;
end);
