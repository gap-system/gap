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
##  This file contains functions that compute the conjugacy classes of a
##  finite group by homomorphic images.
##  Literature: A.H: Conjugacy classes in finite permutation groups via
##  homomorphic images, MathComp
##


# get classes from classical group if possible.
BindGlobal("ClassesFromClassical",function(G)
local hom,d,cl;
  if IsPermGroup(G) and (IsNaturalAlternatingGroup(G)  or
    IsNaturalSymmetricGroup(G)) then
    return ConjugacyClasses(G); # there is a method for this
  fi;
  if not IsNonabelianSimpleGroup(PerfectResiduum(G)) then
    return fail;
  fi;
  d:=DataAboutSimpleGroup(PerfectResiduum(G));
  if d.idSimple.series<>"L" then
    return fail;
  fi;
  hom:=EpimorphismFromClassical(G);
  if hom=fail then
    return fail;
  fi;
  # so far matrix classes only implemented for GL/SL
  if not (IsNaturalGL(Source(hom)) or IsNaturalSL(Source(hom))) then
    return fail;
  fi;

  cl:=ClassesProjectiveImage(hom);
  if HasConjugacyClasses(G) then
    cl:=ConjugacyClasses(G); # will have been set
  elif G=Image(hom) then
    cl:=ConjugacyClasses(Image(hom)); # will have been set
  else
    Info(InfoWarning,1,"Weird class storage");
    return fail;
  fi;
  return cl;
end);

#############################################################################
##
#F  ClassRepsPermutedTuples(<g>,<ran>)
##
##  computes representatives of the colourbars with colours selected from
##  <ran>.
BindGlobal("ClassRepsPermutedTuples",function(g,ran)
local anz,erg,pat,pat2,sym,nrcomp,coldist,stab,dc,i,j,k,sum,schieb,lstab,
      stabs,p;
  anz:=NrMovedPoints(g);
  sym:=SymmetricGroup(anz);
  erg:=[];
  stabs:=[];
  for nrcomp in [1..anz] do
    # all sorted colour distributions
    coldist:=Combinations(ran,nrcomp);
    for pat in OrderedPartitions(anz,nrcomp) do
      Info(InfoHomClass,3,"Pattern: ",pat);
      # compute the partition stabilizer
      stab:=[];
      sum:=0;
      for i in pat do
        schieb:=MappingPermListList([1..i],[sum+1..sum+i]);
        sum:=sum+i;
        stab:=Concatenation(stab,
                List(GeneratorsOfGroup(SymmetricGroup(i)),j->j^schieb));
      od;
      stab:=Subgroup(sym,stab);
      dc:=List(DoubleCosetRepsAndSizes(sym,stab,g),i->i[1]);

      # compute expanded pattern
      pat2:=[];
      for i in [1..nrcomp] do
        for j in [1..pat[i]] do
          Add(pat2,i);
        od;
      od;

      for j in dc do
        # the new bar's stabilizer
        lstab:=Intersection(g,ConjugateSubgroup(stab,j));
        p:=Position(stabs,lstab);
        if p=fail then
          Add(stabs,lstab);
        else
          lstab:=stabs[p];
        fi;
        # the new bar
        j:=Permuted(pat2,j);
        for k in coldist do
          Add(erg,[List(j,i->k[i]),lstab]);
        od;
      od;
    od;
  od;
  return erg;
end);

#############################################################################
##
#F  ConjugacyClassesSubwreath(<F>,<M>,<n>,<autT>,<T>,<Lloc>,<comp>,<emb>,<proj>)
##
InstallGlobalFunction(ConjugacyClassesSubwreath,
function(F,M,n,autT,T,Lloc,components,embeddings,projections)
local clT,        # classes T
      lcl,        # Length(clT)
      clTR,       # classes under other group (autT,centralizer)
      fus,        # class fusion
      sci,        # |centralizer_i|
      oci,        # |reps_i|
      i,j,k,l,    # loop
      pfus,       # potential fusion
      op,         # operation of F on components
      ophom,      # F -> op
      clF,        # classes of F
      clop,       # classes of op
      bars,       # colour bars
      barsi,      # partial bars
      lallcolors, # |all colors|
      reps,Mproj,centralizers,centindex,emb,pi,varpi,newreps,newcent,
      newcentindex,centimages,centimgindex,C,p,P,selectcen,select,
      cen,eta,newcentlocal,newcentlocalindex,d,dc,s,t,elm,newcen,shift,
      cengen,b1,ore,
      # as in paper
      colourbar,newcolourbar,possiblecolours,potentialbars,bar,colofclass,
      clin,clout,
      etas,       # list of etas
      opfun,      # operation function
      r,rp,       # op-element complement in F
      cnt,
      brp,bcen,
      centralizers_r, # centralizers of r
      newcent_r,  # new list to build
      centrhom,   # projection \rest{centralizer of r}
      localcent_r,# image
      cr,
      isdirprod,  # is just M a direct product
      genpos,     # generator index
      genpos2,
      gen,        # generator
      stab,       # stabilizer
      stgen,      # local stabilizer generators
      trans,
      repres,
      img,
      limg,
      con,
      pf,
      orb,        # orbit
      orpo,       # orbit position
      minlen,     # minimum orbit length
      remainlen,  #list of remaining lengths
      gcd,        # gcd of remaining orbit lengths
      stabtrue,
      diff,
      possible,
      combl,
      smacla,
      smare,
      ppos,
      maxdiff,
      cystr,
      again,      # run orbit again to get all
      trymap,     # operation to try
      skip,       # skip (if u=ug)
      ug,         # u\cap u^{gen^-1}
      scj,        # size(centralizers[j])
      dsz,        # Divisors(scj);
      pper,
      cbs,cbi,
      faillim,
      failcnt;


  Info(InfoHomClass,1,
       "ConjugacyClassesSubwreath called for almost simple group of size ",
        Size(T));
  faillim:=Maximum(100,Size(F)/Size(M));
  isdirprod:=Size(M)=Size(autT)^n;

  # classes of T
  clT:=ClassesFromClassical(T);
  if clT=fail then
    clT:=ConjugacyClassesByRandomSearch(T);
  fi;

  clT:=List(clT,i->[Representative(i),Centralizer(i)]);
  lcl:=Length(clT);
  Info(InfoHomClass,1,"found ",lcl," classes in almost simple");
  clTR:=List(clT,i->ConjugacyClass(autT,i[1]));

  # possible fusion under autT
  fus:=List([1..lcl],i->[i]);
  for i in [1..lcl] do
    sci:=Size(clT[i][2]);
    # we have taken a permutation representation that  prolongates to autT!
    oci:=CycleStructurePerm(clT[i][1]);

    # we have tested already the smaller-# classes
    pfus:=Filtered([i+1..lcl],j->CycleStructurePerm(clT[j][1])=oci and
      Size(clT[j][2])=sci);
    pfus:=Difference(pfus,fus[i]);
    if Length(pfus)>0 then
      Info(InfoHomClass,3,"possible fusion ",pfus);
      for j in pfus do
        if clT[j][1] in clTR[i] then
          fus[i]:=Union(fus[i],fus[j]);
          # fuse the entries
          for k in fus[i] do
            fus[k]:=fus[i];
          od;
        fi;
      od;
    fi;
  od;
  fus:=Set(fus); # throw out duplicates
  colofclass:=List([1..lcl],i->PositionProperty(fus,j->i in j));
  Info(InfoHomClass,2,"fused to ",Length(fus)," colours");

  # get the allowed colour bars
  ophom:=ActionHomomorphism(F,components,OnSets,"surjective");
  op:=Image(ophom);
  lallcolors:=Length(fus);
  bars:=ClassRepsPermutedTuples(op,[1..lallcolors]);

  Info(InfoHomClass,1,"classes in normal subgroup");
  # inner classes
  reps:=[One(M)];
  centralizers:=[M];
  centindex:=[1];
  colourbar:=[[]];

  Mproj:=[];
  varpi:=[];

  for i in [1..n] do
    Info(InfoHomClass,1,"component ",i);
    barsi:=Set(Immutable(List(bars,j->j[1]{[1..i]})));
    emb:=embeddings[i];
    pi:=projections[i];
    Add(varpi,ActionHomomorphism(M,Union(components{[1..i]}),"surjective"));
    Add(Mproj,Image(varpi[i],M));
    newreps:=[];
    newcent:=[];
    newcentindex:=[];
    centimages:=[];
    centimgindex:=[];
    newcolourbar:=[];

    etas:=[]; # etas for the centralizers

    # fuse centralizers that become the same
    for j in [1..Length(centralizers)] do
      C:=Image(pi,centralizers[j]);
      p:=Position(centimages,C);
      if p=fail then
        Add(centimages,C);
        p:=Length(centimages);
      fi;
      Add(centimgindex,p);

      # #force 'centralizers[j]' to have its base appropriate to the component
      # # (this will speed up preimages)
      # cen:=centralizers[j];
      # d:=Size(cen);
      # cen:=Group(GeneratorsOfGroup(cen),());
      # StabChain(cen,rec(base:=components[i],size:=d));
      # centralizers[j]:=cen;
      # etas[j]:=ActionHomomorphism(cen,components[i],"surjective");

    od;
    Info(InfoHomClass,2,Length(centimages)," centralizer images");

    # consider previous centralizers
    for j in [1..Length(centimages)] do
      # determine all reps belonging to this centralizer
      C:=centimages[j];
      selectcen:=Filtered([1..Length(centimgindex)],k->centimgindex[k]=j);
      Info(InfoHomClass,2,"Number ",j,": ",Length(selectcen),
            " previous centralizers to consider");

      # 7'
      select:=Filtered([1..Length(centindex)],k->centindex[k] in selectcen);
      # Determine the addable colours
      if i=1 then
        possiblecolours:=[1..Length(fus)];
      else
        possiblecolours:=[];
        #for k in select do
        #  bar:=colourbar[k];
        k:=1;
        while k<=Length(select)
          and Length(possiblecolours)<lallcolors do
          bar:=colourbar[select[k]];
          potentialbars:=Filtered(bars,j->j[1]{[1..i-1]}=bar);
          UniteSet(possiblecolours,
                   potentialbars{[1..Length(potentialbars)]}[1][i]);
          k:=k+1;
        od;

      fi;

      for k in Union(fus{possiblecolours}) do
        # double cosets
        if Size(C)=Size(T) then
          dc:=[One(T)];
        else

          Assert(2,IsSubgroup(T,clT[k][2]));
          Assert(2,IsSubgroup(T,C));

          dc:=List(DoubleCosetRepsAndSizes(T,clT[k][2],C),i->i[1]);
        fi;
        for t in selectcen do
          # continue partial rep.

#          #force 'centralizers[j]' to have its base appropriate to the component
#          # (this will speed up preimages)
#          if not (HasStabChainMutable(cen)
#             and i<=Length(centralizers)
#             and BaseStabChain(StabChainMutable(cen))[1] in centralizers[i])
#            then
#            d:=Size(cen);
#            cen:= Group( GeneratorsOfGroup( cen ), One( cen ) );
#            StabChain(cen,rec(base:=components[i],size:=d));
#            #centralizers[t]:=cen;
#          fi;

          cen:=centralizers[t];

          if not IsBound(etas[t]) then
            if Number(etas)>500 then
              for d in
                Filtered([1..Length(etas)],i->IsBound(etas[i])){[1..500]} do
                Unbind(etas[d]);
              od;
            fi;
            etas[t]:=ActionHomomorphism(cen,components[i],"surjective");
          fi;
          eta:=etas[t];

          select:=Filtered([1..Length(centindex)],l->centindex[l]=t);
          Info(InfoHomClass,3,"centralizer nr.",t,", ",
               Length(select)," previous classes");
          newcentlocal:=[];
          newcentlocalindex:=[];

          for d in dc do
            for s in select do
              # test whether colour may be added here
              bar:=Concatenation(colourbar[s],[colofclass[k]]);
              bar:=ShallowCopy(colourbar[s]);
              Add(bar,colofclass[k]);
              MakeImmutable(bar);
              #if ForAny(bars,j->j[1]{[1..i]}=bar) then
              if bar in barsi then
                # new representative
                elm:=reps[s]*Image(emb,clT[k][1]^d);
                if elm in Mproj[i] then
                  # store the new element
                  Add(newreps,elm);
                  Add(newcolourbar,bar);
                  if i<n then # we only need the centralizer for further
                              # components
                    newcen:=ClosureGroup(Lloc,
                              List(GeneratorsOfGroup(clT[k][2]),g->g^d));
                    p:=Position(newcentlocal,newcen);
                    if p=fail then
                      Add(newcentlocal,newcen);
                      p:=Length(newcentlocal);
                    fi;
                    Add(newcentlocalindex,p);
                  else
                    Add(newcentlocalindex,1); # dummy, just for counting
                  fi;
                #else
                #  Info(InfoHomClass,5,"not in");
                fi;

              #else
              #        Info(InfoHomClass,5,bar,"not minimal");
              fi;
              # end the loops from step 9
            od;
          od;
          Info(InfoHomClass,2,Length(newcentlocalindex),
               " new representatives");

          if i<n then # we only need the centralizer for further components

            # Centralizer preimages
            shift:=[];
            for l in [1..Length(newcentlocal)] do
              P:=PreImage(eta,Intersection(Image(eta),newcentlocal[l]));

              p:=Position(newcent,P);
              if p=fail then
                Add(newcent,P);
                p:=Length(newcent);
              fi;
              shift[l]:=p;
            od;

            # move centralizer indices to global
            for l in newcentlocalindex do
              Add(newcentindex,shift[l]);
            od;

          fi;

        # end the loops from step 6,7 and 8
        od;
      od;
    od;

    centralizers:=newcent;
    centindex:=newcentindex;
    reps:=newreps;
    colourbar:=newcolourbar;
    # end the loop of step 2.
  od;

  Info(InfoHomClass,1,Length(reps)," classreps constructed");

  # allow for faster sorting through color bars
  cbs:=ShallowCopy(colourbar);
  cbi:=[1..Length(cbs)];
  SortParallel(cbs,cbi);

  # further fusion among bars
  newreps:=[];
  Info(InfoHomClass,2,"computing centralizers");
  k:=0;
  for bar in bars do
    k:=k+1;
    #Info(InfoHomClass,4,"k-",k);
    CompletionBar(InfoHomClass,3,"Color Bars ",k/Length(bars));
    b1:=Immutable(bar[1]);
    select:=[];
    i:=PositionSorted(cbs,b1);
    if i<>fail and i<=Length(cbs) and cbs[i]=b1 then
      AddSet(select,cbi[i]);
      while i<Length(cbs) and cbs[i+1]=b1 do
        i:=i+1;
        AddSet(select,cbi[i]);
      od;
    fi;
    #Assert(1,select=Filtered([1..Length(reps)],i->colourbar[i]=b1));

    if Length(select)>1 then
      Info(InfoHomClass,2,"test ",Length(select)," classes for fusion");
    fi;
    newcentlocal:=[];
    for i in [1..Length(select)] do
      if not ForAny(newcentlocal,j->reps[select[i]] in j) then
        #AH we could also compute the centralizer
        C:=Centralizer(F,reps[select[i]]);
        Add(newreps,[reps[select[i]],C]);
        if i<Length(select) and Size(bar[2])>1 then
          # there are other reps with the same bar left and the bar
          # stabilizer is bigger than M
          if not IsBound(bar[2]!.colstabprimg) then
            # identical stabilizers have the same link. Therefore store the
            # preimage in them
            bar[2]!.colstabprimg:=PreImage(ophom,bar[2]);
          fi;
          # any fusion would take place in the stabilizer preimage
          # we know that C must fix the bar, so it is the centralizer there.
          r:=ConjugacyClass(bar[2]!.colstabprimg,reps[select[i]],C);
          Add(newcentlocal,r);
        fi;
      fi;
    od;
  od;
  CompletionBar(InfoHomClass,3,"Color Bars ",false);

  Info(InfoHomClass,1,"fused to ",Length(newreps)," inner classes");
  clF:=newreps;
  clin:=ShallowCopy(clF);
  Assert(2,Sum(clin,i->Index(F,i[2]))=Size(M));
  clout:=[];

  # outer classes

  clop:=Filtered(ConjugacyClasses(op),i->Order(Representative(i))>1);

  for k in clop do
    Info(InfoHomClass,1,"lifting class ",Representative(k));

    r:=PreImagesRepresentative(ophom,Representative(k));
    # try to make r of small order
    rp:=r^Order(Representative(k));
    rp:=RepresentativeAction(M,Concatenation(components),
                                  Concatenation(OnTuples(components[1],rp^-1),
                                  Concatenation(components{[2..n]})),OnTuples);
    if rp<>fail then
      r:=r*rp;
    else
      Info(InfoHomClass,2,
           "trying random modification to get large centralizer");
      cnt:=LogInt(Size(autT),2)*10;
      brp:=();
      bcen:=Size(Centralizer(F,r));
      repeat
        rp:=Random(M);
        cengen:=Size(Centralizer(M,r*rp));
        if cengen>bcen then
          bcen:=cengen;
          brp:=rp;
          cnt:=LogInt(Size(autT),2)*10;
        else
          cnt:=cnt-1;
        fi;
      until cnt<0;
      r:=r*brp;
      Info(InfoHomClass,2,"achieved centralizer size ",bcen);
    fi;
    Info(InfoHomClass,2,"representative ",r);
    cr:=Centralizer(M,r);

    # first look at M-action
    reps:=[One(M)];
    centralizers:=[M];
    centralizers_r:=[cr];
    for i in [1..n] do;
      failcnt:=0;
      newreps:=[];
      newcent:=[];
      newcent_r:=[];
      opfun:=function(a,m)
               return Comm(r,m)*a^m;
             end;

      for j in [1..Length(reps)] do
        scj:=Size(centralizers[j]);
        dsz:=0;
        centrhom:=ActionHomomorphism(centralizers_r[j],components[i],
                    "surjective");
        localcent_r:=Image(centrhom);
        Info(InfoHomClass,4,i,":",j);
        Info(InfoHomClass,3,"acting: ",Size(centralizers[j])," minimum ",
              Int(Size(Image(projections[i]))/Size(centralizers[j])),
              " orbits.");
        # compute C(r)-classes
        clTR:=[];
        for l in clT do
          Info(InfoHomClass,4,"DC",Index(T,l[2])," ",Index(T,localcent_r));
          dc:=DoubleCosetRepsAndSizes(T,l[2],localcent_r);
          clTR:=Concatenation(clTR,List(dc,i->l[1]^i[1]));
        od;

        orb:=[];
        for p in [1..Length(clTR)] do

          repres:=PreImagesRepresentative(projections[i],clTR[p]);
          if i=1 or isdirprod
             or reps[j]*RestrictedPermNC(repres,components[i])
                    in Mproj[i] then
            stab:=Centralizer(localcent_r,clTR[p]);
            if Index(localcent_r,stab)<Length(clTR)/10 then
              img:=Orbit(localcent_r,clTR[p]);
              #ensure Representative is in first position
              if img[1]<>clTR[p] then
                genpos:=Position(img,clTR[p]);
                img:=Permuted(img,(1,genpos));
              fi;
            else
              img:=ConjugacyClass(localcent_r,clTR[p],stab);
            fi;
            Add(orb,[repres,PreImage(centrhom,stab),img,localcent_r]);
          fi;
        od;
        clTR:=orb;

        #was:
        #clTR:=List(clTR,i->ConjugacyClass(localcent_r,i));
        #clTR:=List(clTR,j->[PreImagesRepresentative(projections[i],
        #                                            Representative(j)),
        #                 PreImage(centrhom,Centralizer(j)),
        #                 j]);

        # put small classes to the top (to be sure to hit them and make
        # large local stabilizers)
        SortBy(clTR,x->Size(x[3]));

        Info(InfoHomClass,3,Length(clTR)," local classes");

        cystr:=[];
        for p in [1..Length(clTR)] do
          repres:=Immutable(CycleStructurePerm(Representative(clTR[p][3])));
          select:=First(cystr,x->x[1]=repres);
          if select=fail then
            Add(cystr,[repres,[p]]);
          else
            AddSet(select[2],p);
          fi;
        od;

        cengen:=GeneratorsOfGroup(centralizers[j]);
        if Length(cengen)>10 then
          cengen:=SmallGeneratingSet(centralizers[j]);
        fi;
        #cengen:=Filtered(cengen,i->not i in localcent_r);

        while Length(clTR)>0 do

          # orbit algorithm on classes
          stab:=clTR[1][2];
          orb:=[clTR[1]];
          #repres:=RestrictedPermNC(clTR[1][1],components[i]);
          repres:=clTR[1][1];
          trans:=[One(M)];
          select:=[2..Length(clTR)];

          orpo:=1;
          minlen:=Size(orb[1][3]);
          possible:=false;
          stabtrue:=false;
          pf:=infinity;
          maxdiff:=Size(T);
          again:=0;
          trymap:=false;
          ug:=[];
          # test whether we have full orbit and full stabilizer
          while Size(centralizers[j])>(Sum(orb,i->Size(i[3]))*Size(stab)) do
            genpos:=1;
            while genpos<=Length(cengen) and
              Size(centralizers[j])>(Sum(orb,i->Size(i[3]))*Size(stab)) do
              gen:=cengen[genpos];
              skip:=false;
              if trymap<>false then
                orpo:=trymap[1];
                gen:=trymap[2];
                trymap:=false;
              elif again>0 then
                if not IsBound(ug[genpos]) then
                  ug[genpos]:=Intersection(centralizers_r[j],
                                   ConjugateSubgroup(centralizers_r[j],gen^-1));
                fi;
                if again<500 and ForAll(GeneratorsOfGroup(centralizers_r[j]),
                          i->i in ug[genpos])
                 then
                  # the random elements will give us nothing new
                  skip:=true;
                else
                  # get an element not in ug[genpos]
                  repeat
                    img:=Random(centralizers_r[j]);
                  until not img in ug[genpos] or again>=500;
                  gen:=img*gen;
                fi;
              fi;

              if not skip then

                img:=Image(projections[i],opfun(orb[orpo][1],gen));

                smacla:=select;

                if not stabtrue then
                  p:=PositionProperty(orb,i->img in i[3]);
                  ppos:=fail;
                else
                  # we have the stabilizer and thus are only interested in
                  # getting new elements.
                  p:=CycleStructurePerm(img);
                  ppos:=First(First(cystr,x->x[1]=p)[2],
                           i->i in select and
                           Size(clTR[i][3])<=maxdiff and img in clTR[i][3]);
                  if ppos=fail then
                    p:="ignore"; #to avoid the first case
                  else
                    p:=fail; # go to first case
                  fi;
                fi;

                if p=fail then
                  if ppos=fail then
                    p:=First(select,
                           i->Size(clTR[i][3])<=maxdiff and img in clTR[i][3]);
                    if p=fail then
                      return fail;
                    fi;
                  else
                    p:=ppos;
                  fi;

                  RemoveSet(select,p);
                  Add(orb,clTR[p]);

                  if trans[orpo]=false then
                    Add(trans,false);
                  else
                    #change the transversal element to map to the representative
                    con:=trans[orpo]*gen;
                    limg:=opfun(repres,con);
                    con:=con*PreImagesRepresentative(centrhom,
                            RepresentativeAction(localcent_r,
                                                  Image(projections[i],limg),
                                                  Representative(clTR[p][3])));
                    Assert(2,Image(projections[i],opfun(repres,con))
                            =Representative(clTR[p][3]));

                    Add(trans,con);

                    for stgen in GeneratorsOfGroup(clTR[p][2]) do
                      Assert( 2, IsOne( Image( projections[i],
                                    opfun(repres,con*stgen/con)/repres ) ) );
                      stab:=ClosureGroup(stab,con*stgen/con);
                    od;
                  fi;

                  # compute new minimum length

                  if Length(select)>0 then
                    remainlen:=List(clTR{select},i->Size(i[3]));
                    gcd:=Gcd(remainlen);
                    diff:=minlen-Sum(orb,i->Size(i[3]));

                    if diff<0 then
                      # only go through this if the orbit actually grew
                      # larger
                      minlen:=Sum(orb,i->Size(i[3]));
                      repeat
                        if dsz=0 then
                          dsz:=DivisorsInt(scj);
                        fi;
                        while not minlen in dsz do
                          # workaround rare problem -- try again
                          if First(dsz,i->i>=minlen)=fail then
                            return ConjugacyClassesSubwreath(
                              F,M,n,autT,T,Lloc,components,embeddings,projections);
                          fi;
                          # minimum gcd multiple to get at least the
                          # smallest divisor
                          minlen:=minlen+
                                    (QuoInt((First(dsz,i->i>=minlen)-minlen-1),
                                            gcd)+1)*gcd;
                        od;

                        # now try whether we actually can add orbits to make up
                        # that length
                        diff:=minlen-Sum(orb,i->Size(i[3]));
                        Assert(2,diff>=0);
                        # filter those remaining classes small enough to make
                        # up the length
                        smacla:=Filtered(select,i->Size(clTR[i][3])<=diff);
                        remainlen:=List(clTR{smacla},i->Size(i[3]));
                        combl:=1;
                        possible:=false;
                        if diff=0 then
                          possible:=fail;
                        fi;
                        while gcd*combl<=diff
                              and combl<=Length(remainlen) and possible=false do
                          if NrCombinations(remainlen,combl)<100 then
                            possible:=ForAny(Combinations(remainlen,combl),
                                             i->Sum(i)=diff);
                          else
                            possible:=fail;
                          fi;
                          combl:=combl+1;
                        od;
                        if possible=false then
                          minlen:=minlen+gcd;
                        fi;
                      until possible<>false;
                    fi; # if minimal orbit length grew

                    Info(InfoHomClass,5,"Minimum length of this orbit ",
                         minlen," (",diff," missing)");

                  fi;

                  if minlen*Size(stab)=Size(centralizers[j]) then
                    #Assert(1,Length(smacla)>0);
                    maxdiff:=diff;
                    stabtrue:=true;
                  fi;

                elif not stabtrue then
                  # we have an element that stabilizes the conjugacy class.
                  # correct this to an element that fixes the representative.
                  # (As we have taken already the centralizer in
                  # centralizers_r, it is sufficient to correct by
                  # centralizers_r-conjugation.)
                  con:=trans[orpo]*gen;
                  limg:=opfun(repres,con);
                  con:=con*PreImagesRepresentative(centrhom,
                           RepresentativeAction(localcent_r,
                                                 Image(projections[i],limg),
                                                 Representative(orb[p][3])));
                  stab:=ClosureGroup(stab,con/trans[p]);
                  if Size(stab)*2*minlen>Size(centralizers[j]) then
                    Info(InfoHomClass,3,
                         "true stabilizer found (cannot grow)");
                    minlen:=Size(centralizers[j])/Size(stab);
                    maxdiff:=minlen-Sum(orb,i->Size(i[3]));
                    stabtrue:=true;
                  fi;
                fi;

                if stabtrue then

                  smacla:=Filtered(select,i->Size(clTR[i][3])<=maxdiff);

                  if Length(smacla)<pf then
                    pf:=Length(smacla);
                    remainlen:=List(clTR{smacla},i->Size(i[3]));

                    CompletionBar(InfoHomClass,3,"trueorb ",1-maxdiff/minlen);
                    #Info(InfoHomClass,3,
                #        "This is the true orbit length (missing ",
                #        maxdiff,")");

                    if Size(stab)*Sum(orb,i->Size(i[3]))
                        =Size(centralizers[j]) then
                      maxdiff:=0;

                    elif Sum(remainlen)=maxdiff then
                      Info(InfoHomClass,2,
                          "Full possible remainder must fuse");
                      orb:=Concatenation(orb,clTR{smacla});
                      select:=Difference(select,smacla);

                    else
                      # test whether there is only one possibility to get
                      # this length
                      if Length(smacla)<20 and
                       Sum(List([1..Minimum(Length(smacla),
                                    Int(maxdiff/gcd+1))],
                           x-> NrCombinations(smacla,x)))<10000 then
                        # get all reasonable combinations
                        smare:=[1..Length(smacla)]; #range for smacla
                        combl:=Concatenation(List([1..Int(maxdiff/gcd+1)],
                                              i->Combinations(smare,i)));
                        # pick those that have the correct length
                        combl:=Filtered(combl,i->Sum(remainlen{i})=maxdiff);
                        if Length(combl)>1 then
                          Info(InfoHomClass,3,"Addendum not unique (",
                          Length(combl)," possibilities)");
                          if (maxdiff<10 or again>0)
                            and ForAll(combl,i->Length(i)<=5) then
                            # we have tried often enough, now try to pick the
                            # right ones
                            possible:=false;
                            combl:=Union(combl);
                            combl:=smacla{combl};
                            genpos2:=1;
                            smacla:=[];
                            while possible=false and Length(combl)>0 do
                              img:=Image(projections[i],
                                opfun(clTR[combl[1]][1],cengen[genpos2]));
                              p:=PositionProperty(orb,i->img in i[3]);
                              if p<>fail then
                                # it is!
                                Info(InfoHomClass,4,"got one!");

                                # remember the element to try
                                trymap:=[p,(cengen[genpos2]*
                                  PreImagesRepresentative(
                                    RestrictedMapping(projections[i],
                                      centralizers[j]),
                                    RepresentativeAction(
                                    orb[p][4],
                                    img,Representative(orb[p][3]))  ))^-1];

                                Add(smacla,combl[1]);
                                combl:=combl{[2..Length(combl)]};
                                if Sum(clTR{smacla},i->Size(i[3]))=maxdiff then
                                  # bingo!
                                  possible:=true;
                                fi;
                              fi;
                              genpos2:=genpos2+1;
                              if genpos2>Length(cengen) then
                                genpos2:=1;
                                combl:=combl{[2..Length(combl)]};
                              fi;
                            od;
                            if possible=false then
                              Info(InfoHomClass,4,"Even test failed!");
                            else
                              orb:=Concatenation(orb,clTR{smacla});
                              select:=Difference(select,smacla);
                              Info(InfoHomClass,3,"Completed orbit (hard)");
                            fi;
                          fi;
                        elif Length(combl)>0 then
                          combl:=combl[1];
                          orb:=Concatenation(orb,clTR{smacla{combl}});
                          select:=Difference(select,smacla{combl});
                          Info(InfoHomClass,3,"Completed orbit");
                        fi;
                      fi;
                    fi;
                  fi;

                fi;
              else
                Info(InfoHomClass,5,"skip");
              fi; # if not skip

              genpos:=genpos+1;
            od;
            orpo:=orpo+1;
            if orpo>Length(orb) then
              Info(InfoHomClass,3,"Size factor:",EvalF(
              (Sum(orb,i->Size(i[3]))*Size(stab))/Size(centralizers[j])),
              " orbit consists of ",Length(orb)," suborbits, iterating");

              if stabtrue then
                pper:=false;
                # we know stabilizer, just need to find orbit. As these are
                # likely small additions, search in reverse.
                for p in select do
                  for genpos in [1..Length(cengen)] do
                    gen:=Random(centralizers_r[j])*cengen[genpos];
                    img:=Image(projections[i],opfun(clTR[p][1],gen));
                    orpo:=CycleStructurePerm(img);
                    ppos:=First(First(cystr,x->x[1]=orpo)[2],
                           i->not i in select and
                           img in clTR[i][3]);
                    if ppos<>fail and p in select then
                      # so the image is in clTR[ppos] which must be in orb
                      ppos:=Position(orb,clTR[ppos]);
                      Info(InfoHomClass,3,"found new orbit addition ",p);
                      Add(orb,clTR[p]);

#        #change the transversal element to map to the representative
#        con:=trans[ppos]*RepresentativeAction(localcent_r,
#              Representative(orb[ppos][3]),img)/gen;
#        if not Image(projections[i],opfun(repres,con))
#                =Representative(clTR[p][3]) then
#          Error("wrong rep");
#        fi;
#        Add(trans,con);
                      # cannot easily do transversal this way.
                      Add(trans,false);

                      RemoveSet(select,p);
                    elif ppos=fail then
                      pper:=true;
                    fi;
                  od;
                od;

                if pper then
                  # trap some weird setup where it does not terminate
                  failcnt:=failcnt+1;
                  if failcnt>=1000*faillim then
                    #Error("fail4");
                    return fail;
                  fi;
                fi;

              fi;


              orpo:=1;
              again:=again+1;
              if again>1000*faillim then
                return fail;
              fi;
            fi;
          od;
          Info(InfoHomClass,2,"Stabsize = ",Size(stab),
                ", centstabsize = ",Size(orb[1][2]));
          clTR:=clTR{select};
          # fix index positions
          for p in cystr do
            p[2]:=Filtered(List(p[2],x->Position(select,x)),IsInt);
          od;

          Info(InfoHomClass,2,"orbit consists of ",Length(orb)," suborbits,",
               Length(clTR)," classes left.");

          Info(InfoHomClass,3,List(orb,i->Size(i[2])));
          Info(InfoHomClass,4,List(orb,i->Size(i[3])));

          # select the orbit element with the largest local centralizer
          orpo:=1;
          p:=2;
          while p<=Length(orb) do
            if IsBound(trans[p]) and Size(orb[p][2])>Size(orb[orpo][2]) then
              orpo:=p;
            fi;
            p:=p+1;
          od;
          if orpo<>1 then
            Info(InfoHomClass,3,"switching to orbit position ",orpo);
            repres:=opfun(repres,trans[orpo]);
            #repres:=RestrictedPermNC(clTR[1][1],repres);
            stab:=stab^trans[orpo];
          fi;


          Assert(2,ForAll(GeneratorsOfGroup(stab),
                j -> IsOne( Image(projections[i],opfun(repres,j)/repres) )));

          # correct stabilizer to element stabilizer
          Add(newreps,reps[j]*RestrictedPermNC(repres,components[i]));
          Add(newcent,stab);
          Add(newcent_r,orb[orpo][2]);
        od;

      od;
      reps:=newreps;
      centralizers:=newcent;
      centralizers_r:=newcent_r;

      Info(InfoHomClass,2,Length(reps)," representatives");
    od;

    select:=Filtered([1..Length(reps)],i->reps[i] in M);
    reps:=reps{select};
    reps:=List(reps,i->r*i);
    centralizers:=centralizers{select};
    centralizers_r:=centralizers_r{select};
    Info(InfoHomClass,1,Length(reps)," in M");

    # fuse reps if necessary
    cen:=PreImage(ophom,Centralizer(k));
    newreps:=[];
    newcentlocal:=[];
    for i in [1..Length(reps)] do
      bar:=CycleStructurePerm(reps[i]);
      ore:=Order(reps[i]);
      newcentlocal:=Filtered(newreps,
                     i->Order(Representative(i))=ore and
                     i!.elmcyc=bar);
      if not ForAny(newcentlocal,j->reps[i] in j) then
        C:=Centralizer(cen,reps[i]);
        # AH can we use centralizers[i] here ?
        Add(clF,[reps[i],C]);
        Add(clout,[reps[i],C]);
        bar:=ConjugacyClass(cen,reps[i],C);
        bar!.elmcyc:=CycleStructurePerm(reps[i]);
        Add(newreps,bar);
      fi;
    od;
    Info(InfoHomClass,1,"fused to ",Length(newreps)," classes");
  od;

  if Sum(clout,i->Index(F,i[2]))<>Size(F)-Size(M) then return fail;fi;

  Info(InfoHomClass,2,Length(clin)," inner classes, total size =",
        Sum(clin,i->Index(F,i[2])));
  Info(InfoHomClass,2,Length(clout)," outer classes, total size =",
        Sum(clout,i->Index(F,i[2])));
  Info(InfoHomClass,3," Minimal ration for outer classes =",
        EvalF(Minimum(List(clout,i->Index(F,i[2])/(Size(F)-Size(M)))),30));

  Info(InfoHomClass,1,"returning ",Length(clF)," classes");

  Assert(2,Sum(clF,i->Index(F,i[2]))=Size(F));
  return clF;

end);

InstallGlobalFunction(ConjugacyClassesFittingFreeGroup,function(G)
local cs,       # chief series of G
      i,        # index cs
      cl,       # list [classrep,centralizer]
      hom,      # G->G/cs[i]
      M,        # cs[i-1]
      N,        # cs[i]
      subN,     # maximan normal in M over N
      csM,      # orbit of nt in M under G
      n,        # Length(csM)
      T,        # List of T_i
      Q,        # Action(G,T)
      Qhom,     # G->Q and F->Q
      S,        # PreImage(Qhom,Stab_Q(1))
      S1,       # Action of S on T[1]
      deg1,     # deg (s1)
      autos,    # automorphism for action
      arhom,    # autom permrep list
      Thom,     # S->S1
      T1,       # T[1] Thom
      w,        # S1\wrQ
      wbas,     # base of w
      emb,      # embeddings of w
      proj,     # projections of wbas
      components, # components of w
      reps,     # List reps in G for 1->i in Q
      F,        # action of G on M/N
      Fhom,     # G -> F
      FQhom,    # Fhom*Qhom
      genimages,# G.generators Fhom
      img,      # gQhom
      gimg,     # gFhom
      act,      # component permcation to 1
      j,k,      # loop
      clF,      # classes of F
      ncl,      # new classes
      FM,       # normal subgroup in F, Fhom(M)
      FMhom,    # M->FM
      dc,       # double cosets
      jim,      # image of j
      Cim,
      CimCl,
      p,
      l,lj,
      l1,
      elm,
      zentr,
      onlysizes,
      good,bad,
      lastM;

  onlysizes:=ValueOption("onlysizes");
  # we assume the group has no solvable normal subgroup. Thus we get all
  # classes by lifts via nonabelian factors and can disregard all abelian
  # factors.

  # we will give classes always by their representatives in G and
  # centralizers by their full preimages in G.

  cs:= ChiefSeriesThrough( G,[Socle(G)] );

  # First do socle factor
  if Size(Socle(G))=Size(G) then
    cl:=[One(G),G];
    lastM:=G;
  else
    lastM:=Socle(G);
    # compute the classes of the simple nonabelian factor by random search
    hom:=NaturalHomomorphismByNormalSubgroupNC(G,lastM);
    cl:=ConjugacyClasses(Image(hom));
    cl:=List(cl,i->[PreImagesRepresentative(hom,Representative(i)),
                    PreImage(hom,StabilizerOfExternalSet(i))]);
    cs:=Concatenation([G],Filtered(cs,x->IsSubset(lastM,x)));
  fi;

  for i in [2..Length(cs)] do
    # we assume that cl contains classreps/centralizers for G/cs[i-1]
    # we want to lift to G/cs[i]
    M:=cs[i-1];
    N:=cs[i];

    Info(InfoHomClass,1,i,":",Index(M,N),";  ",Size(N));
    if HasAbelianFactorGroup(M,N) then
      Info(InfoHomClass,2,"abelian factor ignored");
    else
      # nonabelian factor. Now it means real work.

      # 1) compute the action for the factor

      # first, we obtain the simple factors T_i/N.
      # we get these as intersections of the conjugates of the subnormal
      # subgroup

      csM:=CompositionSeries(M); # stored attribute
      if not IsSubset(csM[2],N) then
        # the composition series goes the wrong way. Now take closures of
        # its steps with N to get a composition series for M/N, take the
        # first proper factor for subN.
        n:=3;
        subN:=fail;
        while n<=Length(csM) and subN=fail do
          subN:=ClosureGroup(N,csM[n]);
          if Index(M,subN)=1 then
            subN:=fail; # still wrong
          fi;
          n:=n+1;
        od;
      else
        subN:=csM[2];
      fi;

      if IsNormal(G,subN) then

        # only one -> Call standard process

        Fhom:=fail;
        # is this an almost top factor?
        if Index(G,M)<10 then
          Thom:=NaturalHomomorphismByNormalSubgroupNC(G,subN);
          T1:=Image(Thom,M);
          S1:=Image(Thom);
          if Size(Centralizer(S1,T1))=1 then
            deg1:=NrMovedPoints(S1);
            Info(InfoHomClass,2,
              "top factor gives conjugating representation, deg ",deg1);

            Fhom:=Thom;
          fi;
        else
          Thom:=NaturalHomomorphismByNormalSubgroupNC(M,subN);
          T1:=Image(Thom,M);
        fi;

        if Fhom=fail then
          autos:=List(GeneratorsOfGroup(G),
                    i->GroupHomomorphismByImagesNC(T1,T1,GeneratorsOfGroup(T1),
                      List(GeneratorsOfGroup(T1),
                            j->Image(Thom,PreImagesRepresentative(Thom,j)^i))));

          # find (probably another) permutation rep for T1 for which all
          # automorphisms can be represented by permutations
          arhom:=AutomorphismRepresentingGroup(T1,autos);
          S1:=arhom[1];
          deg1:=NrMovedPoints(S1);
          Fhom:=GroupHomomorphismByImagesNC(G,S1,GeneratorsOfGroup(G),arhom[3]);
        fi;


        F:=Image(Fhom,G);

        clF:=ClassesFromClassical(F);
        if clF=fail then
          clF:=ConjugacyClassesByRandomSearch(F);
        fi;

        clF:=List(clF,j->[Representative(j),StabilizerOfExternalSet(j)]);

      else
        csM:=Orbit(G,subN); # all conjugates
        n:=Length(csM);

        if n=1 then
          Error("this cannot happen");
          T:=M;
        fi;

        T:=Intersection(csM{[2..Length(csM)]}); # one T_i
        if Length(GeneratorsOfGroup(T))>5 then
          T:=Group(SmallGeneratingSet(T));
        fi;

        T:=Orbit(G,T); # get all the t's
        # now T[1] is a complement to csM[1] in G/N.

        # now compute the operation of G on M/N
        Qhom:=ActionHomomorphism(G,T,"surjective");
        Q:=Image(Qhom,G);
        S:=PreImage(Qhom,Stabilizer(Q,1));

        # find a permutation rep. for S-action on T[1]
        Thom:=NaturalHomomorphismByNormalSubgroupNC(T[1],N);
        T1:=Image(Thom);
        if not IsSubset([1..NrMovedPoints(T1)],
                         MovedPoints(T1)) then
          Thom:=Thom*ActionHomomorphism(T1,MovedPoints(T1),"surjective");
        fi;
        T1:=Image(Thom,T[1]);
        if IsPermGroup(T1) and
          NrMovedPoints(T1)>SufficientlySmallDegreeSimpleGroupOrder(Size(T1)) then
          Thom:=Thom*SmallerDegreePermutationRepresentation(T1:cheap);
          Info(InfoHomClass,1,"reduced simple degree ",NrMovedPoints(T1),
            " ",NrMovedPoints(Image(Thom)));
          T1:=Image(Thom,T[1]);
        fi;

        autos:=List(GeneratorsOfGroup(S),
                  i->GroupHomomorphismByImagesNC(T1,T1,GeneratorsOfGroup(T1),
                    List(GeneratorsOfGroup(T1),
                          j->Image(Thom,PreImagesRepresentative(Thom,j)^i))));

        # find (probably another) permutation rep for T1 for which all
        # automorphisms can be represented by permutations
        arhom:=AutomorphismRepresentingGroup(T1,autos);
        S1:=arhom[1];
        deg1:=NrMovedPoints(S1);
        Thom:=GroupHomomorphismByImagesNC(S,S1,GeneratorsOfGroup(S),arhom[3]);

        T1:=Image(Thom,T[1]);

        # now embed into wreath
        w:=WreathProduct(S1,Q);
        wbas:=DirectProduct(List([1..n],i->S1));
        emb:=List([1..n+1],i->Embedding(w,i));
        proj:=List([1..n],i->Projection(wbas,i));
        components:=WreathProductInfo(w).components;

        # define isomorphisms between the components
        reps:=List([1..n],i->
                PreImagesRepresentative(Qhom,RepresentativeAction(Q,1,i)));

        genimages:=[];
        for j in GeneratorsOfGroup(G) do
          img:=Image(Qhom,j);
          gimg:=Image(emb[n+1],img);
          for k in [1..n] do
            # look at part of j's action on the k-th factor.
            # we get this by looking at the action of
            #   reps[k] *   j    *   reps[k^img]^-1
            # 1   ->    k  ->  k^img    ->           1
            # on the first component.
            act:=reps[k]*j*(reps[k^img]^-1);
            # this must be multiplied *before* permuting
            gimg:=ImageElm(emb[k],ImageElm(Thom,act))*gimg;
            gimg:=RestrictedPermNC(gimg,MovedPoints(w));
          od;
          Add(genimages,gimg);
        od;

        F:=Subgroup(w,genimages);
        if AssertionLevel()>=2 then
          Fhom:=GroupHomomorphismByImages(G,F,GeneratorsOfGroup(G),genimages);
          Assert(1,fail<>Fhom);
        else
          Fhom:=GroupHomomorphismByImagesNC(G,F,GeneratorsOfGroup(G),genimages);
        fi;

        Info(InfoHomClass,1,"constructed Fhom");

        # 2) compute the classes for F

        if n>1 then
          #if IsPermGroup(F) and NrMovedPoints(F)<18 then
          #  # the old Butler/Theissen approach is still OK
          #  clF:=[];
          #  for j in
          #   Concatenation(List(RationalClasses(F),DecomposedRationalClass)) do
          #    Add(clF,[Representative(j),StabilizerOfExternalSet(j)]);
          #  od;
          #else
            FM:=F;
            for j in components do
              FM:=Stabilizer(FM,j,OnSets);
            od;

            clF:=ConjugacyClassesSubwreath(F,FM,n,S1,
                  Action(FM,components[1]),T1,components,emb,proj);
            if clF=fail then
              #Error("failure");
              # weird error happened -- redo
              j:=Random(SymmetricGroup(MovedPoints(G)));
              FM:=List(GeneratorsOfGroup(G),x->x^j);
              F:=Group(FM);
              SetSize(F,Size(G));
              FM:=GroupHomomorphismByImagesNC(G,F,GeneratorsOfGroup(G),FM);
              clF:=ConjugacyClassesFittingFreeGroup(F);
              clF:=List(clF,x->[PreImagesRepresentative(FM,x[1]),PreImage(FM,x[2])]);
              return clF;
            fi;
          #fi;
        else
          FM:=Image(Fhom,M);
          Info(InfoHomClass,1,
              "classes by random search in almost simple group");

          clF:=ClassesFromClassical(F);
          if clF=fail then
            clF:=ConjugacyClassesByRandomSearch(F);
          fi;

          clF:=List(clF,j->[Representative(j),StabilizerOfExternalSet(j)]);
        fi;
      fi; # true orbit of T.

      Assert(2,Sum(clF,i->Index(F,i[2]))=Size(F));
      Assert(2,ForAll(clF,i->Centralizer(F,i[1])=i[2]));

      # 3) combine to form classes of sdp

      # the length(cl)=1 gets rid of solvable stuff on the top we got ``too
      # early''.
      if IsSubgroup(N,KernelOfMultiplicativeGeneralMapping(Fhom)) then
        Info(InfoHomClass,1,
            "homomorphism is faithful for relevant factor, take preimages");
        if Size(N)=1 and onlysizes=true then
          cl:=List(clF,i->[PreImagesRepresentative(Fhom,i[1]),Size(i[2])]);
        else
          cl:=List(clF,i->[PreImagesRepresentative(Fhom,i[1]),
                            PreImage(Fhom,i[2])]);
        fi;
      else
        Info(InfoHomClass,1,"forming subdirect products");

        FM:=Image(Fhom,lastM);
        FMhom:=RestrictedMapping(Fhom,lastM);
        if Index(F,FM)=1 then
          Info(InfoHomClass,1,"degenerated to direct product");
          ncl:=[];
          for j in cl do
            for k in clF do
              # modify the representative with a kernel elm. to project
              # correctly on the second component
              elm:=j[1]*PreImagesRepresentative(FMhom,
                          LeftQuotient(Image(Fhom,j[1]),k[1]));
              zentr:=Intersection(j[2],PreImage(Fhom,k[2]));
              Assert(3,ForAll(GeneratorsOfGroup(zentr),
                      i->Comm(i,elm) in N));
              Add(ncl,[elm,zentr]);
            od;
          od;

          cl:=ncl;

        else

          # first we add the centralizer closures and sort by them
          # (this allows to reduce the number of double coset calculations)
          ncl:=[];
          for j in cl do
            Cim:=Image(Fhom,j[2]);
            CimCl:=Cim;
            #CimCl:=ClosureGroup(FM,Cim); # should be unnecessary, as we took
            # the full preimage
            p:=PositionProperty(ncl,i->i[1]=CimCl);
            if p=fail then
              Add(ncl,[CimCl,[j]]);
            else
              Add(ncl[p][2],j);
            fi;
          od;

          Qhom:=NaturalHomomorphismByNormalSubgroupNC(F,FM);
          Q:=Image(Qhom);
          FQhom:=Fhom*Qhom;

          # now construct the sdp's
          cl:=[];
          for j in ncl do
            lj:=List(j[2],i->Image(FQhom,i[1]));
            for k in clF do
              # test whether the classes are potential mates
              elm:=Image(Qhom,k[1]);
              if not ForAll(lj,i->RepresentativeAction(Q,i,elm)=fail) then

                #l:=Image(Fhom,j[1]);

                if Index(F,j[1])=1 then
                  dc:=[()];
                else
                  dc:=List(DoubleCosetRepsAndSizes(F,k[2],j[1]),i->i[1]);
                fi;
                good:=0;
                bad:=0;
                for l in j[2] do
                  jim:=Image(FQhom,l[1]);
                  for l1 in dc do
                    elm:=k[1]^l1;
                    if Image(Qhom,elm)=jim then
                      # modify the representative with a kernel elm. to project
                      # correctly on the second component
                      elm:=l[1]*PreImagesRepresentative(FMhom,
                                  LeftQuotient(Image(Fhom,l[1]),elm));
                      zentr:=PreImage(Fhom,k[2]^l1);
                      zentr:=Intersection(zentr,l[2]);

                      Assert(3,ForAll(GeneratorsOfGroup(zentr),
                              i->Comm(i,elm) in N));

                      Info(InfoHomClass,4,"new class, order ",Order(elm),
                          ", size=",Index(G,zentr));
                      Add(cl,[elm,zentr]);
                      good:=good+1;
                    else
                      Info(InfoHomClass,5,"not in");
                      bad:=bad+1;
                    fi;
                  od;
                od;
                Info(InfoHomClass,4,good," good, ",bad," bad of ",Length(dc));
              fi;
            od;
          od;
        fi; # real subdirect product

      fi; # else Fhom not faithful on factor

      # uff. That was hard work. We're finally done with this layer.
      lastM:=N;
    fi; # else nonabelian
    Info(InfoHomClass,1,"so far ",Length(cl)," classes computed");
  od;

  if Length(cs)<3 then
    Info(InfoHomClass,1,"Fitting free factor returns ",Length(cl)," classes");
  fi;
  Assert( 2, Sum( List( cl, pair -> Size(G) / Size( pair[2] ) ) ) = Size(G) );
  return cl;
end);

## Lifting code, using new format and compatible with matrix groups

#############################################################################
##
#F  FFClassesVectorSpaceComplement( <N>, <p>, <gens>, <howmuch> )
##
##  This function creates a record  containing information about a complement
##  in <N> to the span of <gens>.
##
# field, dimension, subgenerators (as vectors),howmuch
BindGlobal("FFClassesVectorSpaceComplement",function(field,r, Q,howmuch )
local   zero,  one,  ran,  n,  nan,  cg,  pos,  i,  j,  v;

    one:=One( field);  zero:=Zero(field);
    ran:=[ 1 .. r ];
    n:=Length( Q );    nan:=[ 1 .. n ];

    cg:=rec( matrix        :=[  ],
               one           :=one,
               baseComplement:=ShallowCopy( ran ),
               commutator    :=0,
               centralizer   :=0,
               dimensionN    :=r,
               dimensionC    :=n );

    if n = 0  or  r = 0  then
        cg.inverse:=NullMapMatrix;
        cg.projection    :=IdentityMat( r, one );
        cg.needed    :=[];
        return cg;
    fi;

    for i  in nan  do
        cg.matrix[ i ]:=Concatenation( Q[ i ], zero * nan );
        cg.matrix[ i ][ r + i ]:=one;
    od;
    TriangulizeMat( cg.matrix );
    pos:=1;
    for v  in cg.matrix  do
        while v[ pos ] = zero  do
            pos:=pos + 1;
        od;
        RemoveSet( cg.baseComplement, pos );
        if pos <= r  then  cg.commutator :=cg.commutator  + 1;
                     else  cg.centralizer:=cg.centralizer + 1;  fi;
    od;

    if howmuch=1 then
      return Immutable(cg);
    fi;

    cg.needed        :=[  ];
    cg.projection    :=IdentityMat( r, one );

    # Find a right pseudo inverse for <Q>.
    Append( Q, cg.projection );
    Q:=MutableTransposedMat( Q );
    TriangulizeMat( Q );
    Q:=TransposedMat( Q );
    i:=1;
    j:=1;
    while i <= r  do
        while j <= n and Q[ j ][ i ] = zero  do
            j:=j + 1;
        od;
        if j <= n and Q[ j ][ i ] <> zero  then
            cg.needed[ i ]:=j;
        else

            # If <Q> does  not  have full rank, terminate when the bottom row
            # is reached.
            i:=r;

        fi;
        i:=i + 1;
    od;

    if IsEmpty( cg.needed )  then
        cg.inverse:=NullMapMatrix;
    else
        cg.inverse:=Q{ n + ran }
                       { [ 1 .. Length( cg.needed ) ] };
        cg.inverse:=ImmutableMatrix(field,cg.inverse,true);
    fi;
    if IsEmpty( cg.baseComplement )  then
        cg.projection:=NullMapMatrix;
    else

        # Find a base change matrix for the projection onto the complement.
        for i  in [ 1 .. cg.commutator ]  do
            cg.projection[ i ][ i ]:=zero;
        od;
        Q:=[  ];
        for i  in [ 1 .. cg.commutator ]  do
            Q[ i ]:=cg.matrix[ i ]{ ran };
        od;
        for i  in [ cg.commutator + 1 .. r ]  do
            Q[ i ]:=ListWithIdenticalEntries( r, zero );
            Q[ i ][ cg.baseComplement[ i-r+Length(cg.baseComplement) ] ]
             :=one;
        od;
        cg.projection:=cg.projection ^ Q;
        cg.projection:=cg.projection{ ran }{ cg.baseComplement };
        cg.projection:=ImmutableMatrix(field,cg.projection,true);

    fi;

    return cg;
end);

#############################################################################
##
#F  VSDecompCentAction( <N>, <h>, <C>, <howmuch> )
##
##  Given a homomorphism C -> N, c |-> [h,c],  this function determines (a) a
##  vector space decomposition N =  [h,C] + K with  projection onto K and (b)
##  the  ``kernel'' S <  C which plays   the role of  C_G(h)  in lemma 3.1 of
##  [Mecky, Neub\"user, Bull. Aust. Math. Soc. 40].
##
BindGlobal("VSDecompCentAction",function( pcgs, h, C, field,howmuch )
local   i,  tmp,  v,x,cg;

  i:=One(field);
  x:=List( C, c -> ExponentsOfPcElement(pcgs,Comm( h, c ) )*i);
#Print(Number(x,IsZero)," from ",Length(x),"\n");

  cg:=FFClassesVectorSpaceComplement(field,Length(pcgs),x,howmuch);
  tmp:=[  ];
  for i  in [ cg.commutator + 1 ..
              cg.commutator + cg.centralizer ]  do
    v:=cg.matrix[ i ];
    tmp[ i - cg.commutator ]:=PcElementByExponentsNC( C,
              v{ [ cg.dimensionN + 1 ..
                  cg.dimensionN + cg.dimensionC ] } );
  od;
  Unbind(cg.matrix);
  cg.cNh:=tmp;
  return cg;
end);

#############################################################################
##
#F  LiftClassesEANonsolvGeneral( <H>,<N>,<NT>,<cl> )
##
BindGlobal("LiftClassesEANonsolvGeneral",
  function(Npcgs, cl, hom, pcisom,solvtriv)
    local  classes,    # classes to be constructed, the result
           correctingelement,
           field,      # field over which <N> is a vector space
           one,
           h,          # preimage `cl.representative' under <hom>
           cg,
           cNh,        # centralizer of <h> in <N>
           gens,   # preimage `Centralizer( cl )' under <hom>
           r,          # dimension of <N>
           ran,        # constant range `[ 1 .. r ]'
           aff,        # <N> as affine space
           imgs,  M,   # generating matrices for affine operation
           orb,        # orbit of affine operation
           rep,# set of classes with canonical representatives
           c,  i, # loop variables
           PPcgs,denomdepths,
           correctionfactor,
           stabfacgens,
           stabfacimg,
           stabrad,
           gpsz,subsz,solvsz,
           b,
           fe,
           radidx,
           comm;# for class correction

  correctingelement:=function(h,rep,fe)
  local comm;
    comm:=Comm( h, fe ) * Comm( rep, fe );
    comm:= ExponentsOfPcElement(Npcgs,comm)*one;
    ConvertToVectorRep(comm,field);
    comm := List(comm * cg.inverse,Int);
    comm:=PcElementByExponentsNC
      ( Npcgs, Npcgs{ cg.needed }, -comm );
    fe:=fe*comm;
    return fe;
  end;

  h := cl[1];

  field := GF( RelativeOrders( Npcgs )[ 1 ] );
  one:=One(field);
  PPcgs:=ParentPcgs(NumeratorOfModuloPcgs(Npcgs));
  denomdepths:=ShallowCopy(DenominatorOfModuloPcgs(Npcgs)!.depthsInParent);
  Add(denomdepths,Length(PPcgs)+1); # one

  # Determine the subspace $[h,N]$ and calculate the centralizer of <h>.
  #cNh := ExtendedPcgs( DenominatorOfModuloPcgs( N!.capH ),
  #               VSDecompCentAction( N, h, N!.capH ) );

  #oldcg:=KernelHcommaC(Npcgs,h,NumeratorOfModuloPcgs(Npcgs),2);

  #cg:=VSDecompCentAction( Npcgs, h, NumeratorOfModuloPcgs(Npcgs),field,2 );
  cg:=VSDecompCentAction( Npcgs, h, Npcgs,field,2 );
#Print("complen =",Length(cg.baseComplement)," of ",cg.dimensionN,"\n");
#if Length(Npcgs)>5 then Error("cb"); fi;

  cNh:=cg.cNh;

  r := Length( cg.baseComplement );
  ran := [ 1 .. r ];

  # Construct matrices for the affine operation on $N/[h,N]$.
  Info(InfoHomClass,4,"space=",Size(field),"^",r);

  gens:=Concatenation(cl[2],Npcgs,cl[3]); # all generators
  gpsz:=cl[5];

  solvsz:=cl[6];

  radidx:=Length(Npcgs)+Length(cl[2]);

  imgs := [  ];
  for c  in gens  do
    M := [  ];
    for i  in [ 1 .. r ]  do
        M[ i ] := Concatenation( ExponentsConjugateLayer( Npcgs,
              Npcgs[ cg.baseComplement[ i ] ] , c )
              * cg.projection, [ Zero( field ) ] );
    od;
    M[ r + 1 ] := Concatenation( ExponentsOfPcElement
                          ( Npcgs, Comm( h, c ) ) * cg.projection,
                          [ One( field ) ] );

    M:=ImmutableMatrix(field,M);
    Add( imgs, M );
  od;


  if Size(field)^r>3*10^8 then Error("too large");fi;
  aff := ExtendedVectors( field ^ r );

  # now compute orbits, being careful to get stabilizers in steps
  #orbreps:=[];
  #stabs:=[];

  orb:=OrbitsRepsAndStabsVectorsMultistage(gens{[1..radidx]},
        imgs{[1..radidx]},pcisom,solvsz,solvtriv,
        gens{[radidx+1..Length(gens)]},
        imgs{[radidx+1..Length(gens)]},cl[4],hom,gpsz,OnRight,aff);

  classes:=[];
  for b in orb do
    rep := PcElementByExponentsNC( Npcgs, Npcgs{ cg.baseComplement },
                    b.rep{ ran } );
    #Assert(3,ForAll(GeneratorsOfGroup(stabsub),i->Comm(i,h*rep) in NT));
    stabrad:=ShallowCopy(b.stabradgens);
#Print("startdep=",List(stabrad,x->DepthOfPcElement(PPcgs,x)),"\n");
#if ForAny(stabrad,x->Order(x)=1) then Error("HUH3"); fi;
    stabfacgens:=b.stabfacgens;
    stabfacimg:=b.stabfacimgs;

    # correct generators. Partially in Pc Image
    if Length(cg.needed)>0 then

      stabrad:=List(stabrad,x->correctingelement(h,rep,x));
      # must make proper pcgs -- correction does not preserve that
      stabrad:=TFMakeInducedPcgsModulo(PPcgs,stabrad,denomdepths);

      # we change by radical elements, so the images in the factor don't
      # change
      stabfacgens:=List(stabfacgens,x->correctingelement(h,rep,x));

    fi;

    correctionfactor:=Characteristic(field)^Length(cg.needed);
    subsz:=b.subsz/correctionfactor;
    c := [h * rep,stabrad,stabfacgens,stabfacimg,subsz,
           b.stabrsubsz/correctionfactor];
    Assert(3,Size(Group(Concatenation(DenominatorOfModuloPcgs(Npcgs),
       stabrad,stabfacgens)))=subsz);

    Add(classes,c);

  od;

  return classes;

end);

#############################################################################
##
#F  LiftClassesEANonsolvCentral( <H>, <N>, <cl> )
##
# the version for pc groups implicitly uses a pc-group orbit-stabilizer
# algorithm. We can't  do this but have to use a more simple-minded
# orbit/stabilizer approach.
BindGlobal("LiftClassesEANonsolvCentral",
  function( Npcgs, cl,hom,pcisom,solvtriv )
local  classes,            # classes to be constructed, the result
        field,             # field over which <Npcgs> is a vector space
        o,
        n,r,               # dimensions
        space,
        com,
        comms,
        mats,
        decomp,
        gens,
        radidx,
        stabrad,stabfacgens,stabfacimg,stabrsubsz,relo,orblock,fe,st,
        orb,rep,reps,repword,repwords,p,stabfac,img,vp,genum,gpsz,
        subsz,solvsz,i,j,
        v,
        h,              # preimage `cl.representative' under <hom>
        w,              # coefficient vectors for projection along $[h,N]$
        c;              # loop variable

  field := GF( RelativeOrders( Npcgs )[ 1 ] );
  h := cl[1];
  #reduce:=ReducedPermdegree(C);
  #if reduce<>fail then
  #  C:=Image(reduce,C);
  #  Info(InfoHomClass,4,"reduced to deg:",NrMovedPoints(C));
  #  h:=Image(reduce,h);
  #  N:=ModuloPcgs(SubgroupNC(C,Image(reduce,NumeratorOfModuloPcgs(N))),
#                 SubgroupNC(C,Image(reduce,DenominatorOfModuloPcgs(N))));
#  fi;

  # centrality still means that conjugation by c is multiplication with
  # [h,c] and that the complement space is generated by commutators [h,c]
  # for a generating set {c|...} of C.

  n:=Length(Npcgs);
  o:=One(field);
  stabrad:=Concatenation(cl[2],Npcgs);
  radidx:=Length(stabrad);
  stabfacgens:=cl[3];
  stabfacimg:=cl[4];
  gpsz:=cl[5];
  subsz:=gpsz;
  solvsz:=cl[6];
  stabfac:=TrivialSubgroup(Image(hom));

  gens:=Concatenation(stabrad,stabfacgens); # all generators
  # commutator space basis

  comms:=List(gens,c->o*ExponentsOfPcElement(Npcgs,Comm(h,c)));
  List(comms,x->ConvertToVectorRep(x,field));
  space:=List(comms,ShallowCopy);
  TriangulizeMat(space);
  space:=Filtered(space,i->i<>Zero(i)); # remove spurious columns

  com:=BaseSteinitzVectors(IdentityMat(n,field),space);

  # decomposition of vectors into the subspace basis
  r:=Length(com.subspace);
  if r>0 then
    # if the subspace is trivial, everything stabilizes

    decomp:=Concatenation(com.subspace,com.factorspace)^-1;
    decomp:=decomp{[1..Length(decomp)]}{[1..r]};
    decomp:=ImmutableMatrix(field,decomp);

    # build matrices for the affine action
    mats:=[];
    for w in comms do
      c:=IdentityMat(r+1,o);
      c[r+1]{[1..r]}:=w*decomp; # translation bit
      c:=ImmutableMatrix(field,c);
      Add(mats,c);
    od;

    #subspace affine enumerator
    v:=ExtendedVectors(field^r);

    # orbit-stabilizer algorithm solv/nonsolv version
    #C := Stabilizer( C, v, v[1],GeneratorsOfGroup(C), mats,OnPoints );

    # assume small domain -- so no bother with bitlist
    orb:= [v[1]];
    reps:=[One(gens[1])];
    repwords:=[[]];
    stabrad:=[];
    stabrsubsz:=Size(solvtriv);

    vp:=1;

    for genum in [radidx,radidx-1..1] do
      relo:=RelativeOrders(pcisom!.sourcePcgs)[
              DepthOfPcElement(pcisom!.sourcePcgs,gens[genum])];
      img:=orb[1]*mats[genum];
      repword:=repwords[vp];
      p:=Position(orb,img);
      if p=fail then
        for j in [1..Length(orb)*(relo-1)] do
          img:=orb[j]*mats[genum];
          Add(orb,img);
          Add(reps,reps[j]*gens[genum]);
          Add(repwords,repword);
        od;
      else
        rep:=gens[genum]/reps[p];
        Add(stabrad,rep);
        stabrsubsz:=stabrsubsz*relo;
      fi;

    od;
    stabrad:=Reversed(stabrad);

    Assert(1,solvsz=stabrsubsz*Length(orb));

    #nosolvable part
    orblock:=Length(orb);
    vp:=1;
    stabfacgens:=[];
    stabfacimg:=[];
    while vp<=Length(orb) do
      for genum in [radidx+1..Length(gens)] do
        img:=orb[vp]*mats[genum];
        rep:=reps[vp]*gens[genum];
        repword:=Concatenation(repwords[vp],[genum-radidx]);
        p:=Position(orb,img);
        if p=fail then
          Add(orb,img);
          Add(reps,rep);
          Add(repwords,repword);
          for j in [1..orblock-1] do
            img:=orb[vp+j]*mats[genum];
    #if img in orb then Error("HUH");fi;
            Add(orb,img);
            Add(reps,reps[vp+j]*gens[genum]);
            # repword stays the same!
            Add(repwords,repword);
          od;
        else
          st:=rep/reps[p];
          if Length(repword)>0 then
            # build the factor group element
            fe:=One(Image(hom));
            for i in repword do
              fe:=fe*cl[4][i];
            od;
            for i in Reversed(repwords[p]) do
              fe:=fe/cl[4][i];
            od;
            if not fe in stabfac then
              # not known -- add to generators
              Add(stabfacgens,st);
              Add(stabfacimg,fe);
              stabfac:=ClosureGroup(stabfac,fe);
            fi;
          fi;
        fi;
      od;
      vp:=vp+orblock;
    od;

    subsz:=stabrsubsz*Size(stabfac);
  else
    stabrsubsz:=solvsz;
  fi;

  if Length(com.factorspace)=0 then
    classes :=[[h,stabrad,stabfacgens,stabfacimg,subsz,stabrsubsz]];
  else
    classes:=[];
    # enumerator of complement
    v:=field^Length(com.factorspace);
    for w in v do
      c := [h * PcElementByExponentsNC( Npcgs,w*com.factorspace),
            stabrad,stabfacgens,stabfacimg,subsz,stabrsubsz];
      #if reduce<>fail then
  #        Add(classes,[PreImagesRepresentative(reduce,c[1]),
  #          PreImage(reduce,c[2])]);
  #      else

  Assert(3,c[6]
    =Size(Group(Concatenation(c[2],DenominatorOfModuloPcgs(Npcgs)))));

      Add(classes,c);
  #      fi;
    od;
  fi;

#  Assert(1,ForAll(classes,i->i[1] in H and IsSubset(H,i[2])));
  return classes;
end);


#############################################################################
##
#F  LiftClassesEATrivRep
##
BindGlobal("LiftClassesEATrivRep",
  function( Npcgs, cl, fants,hom, pcisom,solvtriv)
    local  h,field,one,gens,imgs,M,bas,
           c,i,npcgsact,usent,dim,found,nsgens,nsimgs,mo,
           pcgsimgs,
           sel,pcgs,fasize,nsfgens,fgens,a,norb,fstab,rep,reps,frep,freps,
           orb,p,rsgens,el,img,j,basinv,newo,orbslev,ssd,result,o,subs,orbsub,
           sgens,sfgens,z,minvecs,orpo,norpo,maxorb,
           IteratedMinimizer,OrbitMinimizer,Minimizer,miss;

  npcgsact:=function(c)
    local M,i;
    M := [  ];
    for i  in [ 1 .. dim ]  do
        M[ i ] := ExponentsConjugateLayer( Npcgs,
        Npcgs[ i ] , c )*one;
    od;
    M:=ImmutableMatrix(field,M);
    return M;
  end;

  pcgs:=MappingGeneratorsImages(pcisom)[1];
  field:=GF(RelativeOrders(Npcgs)[1]);
  one:=One(field);
  dim:=Length(Npcgs);

  # action of group
  h := cl[1];
  gens:=Concatenation(cl[2],Npcgs,cl[3]); # all generators
  fgens:=Concatenation(ListWithIdenticalEntries(
            Length(Npcgs)+Length(cl[2]),One(Range(hom))),cl[4]);
  imgs := [  ];
  for c  in gens  do
    Add( imgs, npcgsact(c));
  od;
  sel:=Filtered([1..Length(imgs)],x->Order(imgs[x])>1);

  usent:=0;
  found:=0;
  while usent<Length(fants) do
    usent:=usent+1;
    nsfgens:=NormalIntersection(fants[usent],Group(cl[4]));
    fasize:=Size(nsfgens);
    nsfgens:=SmallGeneratingSet(nsfgens);
    nsgens:=List(nsfgens,x->PreImagesRepresentative(hom,x));
    nsimgs:=List(Concatenation(pcgs,nsgens),npcgsact);
    mo:=GModuleByMats(nsimgs,field);
    if not MTX.IsIrreducible(mo) then
      # split space as direct sum under normal sub -- clifford Theory
      o:=MTX.BasesMinimalSubmodules(mo);
      if Length(o)>50 then
        o:=o{Set([1..50],x->Random(1,Length(o)))};
      fi;

      for i in Filtered([1..Length(o)],
          x->(mo.dimension mod Length(o[x])=0) and Length(o[x])>found) do
        # subspace and images as orbit
        bas:=o[i];
        ssd:=Length(bas);
        if found<ssd and Size(field)^ssd<3*10^7 then
          Info(InfoHomClass,2,"Trying subspace ",ssd," in ",mo.dimension);
          orbsub:=Orbit(Group(imgs{sel}),bas,OnSubspacesByCanonicalBasis);
          if Length(orbsub)*Length(bas)<>Length(bas[1]) then
            subs:=MTX.InducedActionSubmodule(mo,bas);
            subs:=MTX.Homomorphisms(subs,mo);
            orbsub:=Filtered(subs,x->x in orbsub);
          fi;
          if Length(orbsub)*Length(bas)=Length(bas[1]) and
              RankMat(Concatenation(orbsub))=Length(bas[1]) then
            found:=ssd;
            el:=[orbsub,bas,fasize,nsgens,nsimgs,nsfgens,mo];

            subs:=List([1..Length(orbsub)],x->[(x-1)*ssd+1..x*ssd]);
            bas:=ImmutableMatrix(field,Concatenation(orbsub)); # this is the new basis
            basinv:=bas^-1;
              Assert(1,basinv<>fail);
          else
            Info(InfoHomClass,3,"failed ",Length(orbsub));
          fi;
        fi;
      od;
    fi;

  od;

  if found=0 then
    Info(InfoHomClass,3,"basic case");
    #Error("BASIC");
    return fail;
  else
    ssd:=found;
    #el is [orbsub,bas,fasize,nsgens,nsimgs,nsfgens,mo];
    orbsub:=el[1];
    bas:=el[2];
    fasize:=el[3];
    nsgens:=el[4];
    nsimgs:=el[5];
    nsfgens:=el[6];
    mo:=el[7];
    Info(InfoHomClass,2,"Using subspace ",ssd," in ",mo.dimension);

    subs:=List([1..Length(orbsub)],x->[(x-1)*ssd+1..x*ssd]);
    bas:=ImmutableMatrix(field,Concatenation(orbsub)); # this is the new basis
    basinv:=bas^-1;
    Assert(1,basinv<>fail);

  fi;

  imgs:=List(imgs,x->bas*x*basinv); # write wrt new basis

  # now determine N-orbits, stepwise

  solvtriv:=Subgroup(Range(pcisom),
      List(DenominatorOfModuloPcgs(Npcgs),x->ImagesRepresentative(pcisom,x)));

  orb:=[rec(len:=1,rep:=Zero(bas[1]),
        stabfacgens:=nsgens,
        stabfacimgs:=nsfgens,
        # only generators in factor
        stabradgens:=Filtered(pcgs,x->not x in DenominatorOfModuloPcgs(Npcgs)),
        stabrsubsz:=Size(Image(pcisom)),
        subsz:=fasize*Product(RelativeOrders(pcgs))
                   )];

  orbslev:=[];
  maxorb:=1;
  for i in [1..Length(subs)] do
    norb:=[];
    el:=Elements(VectorSpace(field,IdentityMat(Length(bas),field){subs[i]}));
    for o in orb do
      newo:= OrbitsRepsAndStabsVectorsMultistage(
             o.stabradgens,List(o.stabradgens,x->bas*npcgsact(x)*basinv),
             pcisom,o.stabrsubsz,solvtriv,
             o.stabfacgens,List(o.stabfacgens,x->bas*npcgsact(x)*basinv),
             o.stabfacimgs,hom,o.subsz,OnRight,
             el);
      for j in newo do
        if j.len>maxorb then maxorb:=j.len;fi;
        if i>1 then
          j.len:=j.len*o.len;
          j.rep:=Concatenation(o.rep{[1..(i-1)*ssd]},j.rep{[(i-1)*ssd+1..Length(j.rep)]});
          MakeImmutable(j.rep);
        fi;
        Add(norb,j);
      od;
    od;
    Info(InfoHomClass,3,"Level ",i," , ",Length(norb)," orbits");
    orb:=norb;
    Add(orbslev,ShallowCopy(orb));
  od;

  IteratedMinimizer:=function(vec,allcands)
  local i,a,cands,mapper,fmapper,stabfacgens,stabradgens,stabfacimgs,
        range,lcands,lvec;
    cands:=allcands;
    mapper:=One(Source(hom));
    fmapper:=One(Range(hom));
    stabfacgens:=nsgens;
    stabfacimgs:=nsfgens;
    stabradgens:=pcgs;
    for i in [1..Length(subs)] do
      range:=[1..i*ssd];
      lcands:=Filtered(orbslev[i],
        x->ForAny(cands,y->y.rep{range}=x.rep{range}));
      lvec:=Concatenation(vec{range},Zero(vec{[i*ssd+1..Length(vec)]}));
      result:=OrbitMinimumMultistage(stabradgens,
           List(stabradgens,x->bas*npcgsact(x)*basinv),
           stabfacgens,
           List(stabfacgens,x->bas*npcgsact(x)*basinv),
           stabfacimgs,
           OnRight,lvec,maxorb,#Maximum(List(lcands,x->x.len)),
           Set(lcands,x->x.rep));
      a:=First(lcands,x->x.rep{range}=result.min{range});
      mapper:=mapper*result.elm;
      fmapper:=fmapper*result.felm;
      vec:=vec*bas*npcgsact(result.elm)*basinv; # map vector to so far canonical
      # not all classes are feasible
      Assert(1,ForAny(cands,x->x.rep{range}=vec{range}));
      cands:=Filtered(cands,x->x.rep{range}=vec{range});
      stabradgens:=a.stabradgens;
      stabfacgens:=a.stabfacgens;
      stabfacimgs:=a.stabfacimgs;
    od;
    if Length(cands)<>1 then Error("nonunique");fi;
    return rec(elm:=mapper,felm:=fmapper,min:=vec,nclass:=cands[1]);
  end;

  pcgsimgs:=List(pcgs,x->bas*npcgsact(x)*basinv);
  nsimgs:=List(nsgens,x->bas*npcgsact(x)*basinv);


  OrbitMinimizer:=function(vec,allcands)
  local a;

  if false and allcands[1].len>1 then
    Error();
  fi;
    a:=OrbitMinimumMultistage(pcgs,pcgsimgs,
        nsgens,nsimgs,nsfgens,
        OnRight,vec,allcands[1].len,minvecs);
    a.nclass:=First(allcands,x->x.rep=a.min);
    return a;

  end;

  orpo:=NewDictionary(orb[Length(orb)].rep,true,field^Length(orb[1].rep));
  for p in [1..Length(orb)] do
    AddDictionary(orpo,orb[p].rep,p);
  od;

  # now do an orbit algorithm on orb. As the orbit is short no need for
  # two-step.

  newo:=[];
  while Length(orb)>0 do
    # pick new one
    p:=First([1..Length(orb)],x->IsBound(orb[x]));
    norb:=[orb[p]];
    norpo:=[];
    norpo[p]:=1;
    el:=Filtered(orb,x->x.len=orb[p].len);
    minvecs:=Set(el,x->x.rep);
#el:=orbslev[3];
    if orb[p].len>30000 then
      Minimizer:=IteratedMinimizer;
    else
      Minimizer:=OrbitMinimizer;
    fi;

    # as Rad <=N we can assume that the radical part of the stabilizer
    # is known
    rsgens:=ShallowCopy(orb[p].stabradgens);
    a:=Difference([1..Length(gens)],sel);
    sgens:=Concatenation(orb[p].stabfacgens,gens{a});
    sfgens:=Concatenation(orb[p].stabfacimgs,fgens{a});
    fstab:=Group(sfgens);
    reps:=[One(Source(hom))];
    freps:=[One(Range(hom))];
    Unbind(orb[p]);

    # factor missing from stop
    miss:=cl[5]/(norb[1].len*Size(fstab)*norb[1].stabrsubsz);

    i:=1;
    while i<=Length(norb) and miss>1 do
      for j in sel do
        img:=OnRight(norb[i].rep,imgs[j]);
        img:=Minimizer(img,el);

        rep:=reps[i]*gens[j]*img.elm;
        frep:=freps[i]*fgens[j]*img.felm;
        p:=LookupDictionary(orpo,img.min);
        #p:=PositionProperty(norb,x->x.rep=img.min);
        if p=fail then
          return fail;
          Error("unknown minimum");
        elif IsBound(norpo[p]) then
          # old point
          p:=norpo[p];
          if miss>=2 then
            Assert(1,norb[i].rep*imgs[j]*bas*npcgsact(img.elm)*basinv=norb[p].rep);
    #Print("A",i," ",j," ",Length(el),"\n");
            # old point -- stabilize
            a:=frep/freps[p];
            if not a in sfgens then
              Add(sgens,rep/reps[p]);
              Add(sfgens,a);
              miss:=miss*Size(fstab);
              fstab:=ClosureGroup(fstab,a);
              miss:=miss/Size(fstab);
#Print("miss1:",EvalF(miss)," ",i," of ",Length(norb),"\n");

            fi;
          fi;
        else
  #Print("B",i," ",j," ",Length(el),"\n");
          # new point
          #p:=PositionProperty(orb,x->x.rep=img.min);
          Assert(1,norb[i].rep*imgs[j]*bas*npcgsact(img.elm)*basinv=orb[p].rep);
          Add(norb,orb[p]);
          norpo[p]:=Length(norb);
          Add(reps,rep);
          Add(freps,frep);
          miss:=miss*(Length(norb)-1)/Length(norb);
#Print("miss3:",EvalF(miss)," ",i," of ",Length(norb),"\n");
          # add conjugate stabilizer
          #Append(rsgens,List(orb[p].stabradgens,x->rep*x/rep));
          for z in [1..Length(orb[p].stabfacgens)] do
            a:=frep*orb[p].stabfacimgs[z]/frep;
            if not a in fstab then
              Add(sgens,rep*orb[p].stabfacgens[z]/rep);
              Add(sfgens,a);
              miss:=miss*Size(fstab);
              fstab:=ClosureGroup(fstab,a);
              miss:=miss/Size(fstab);
#Print("miss2:",miss,"\n");
            fi;
          od;
          Unbind(orb[p]);
        fi;
      od;
      i:=i+1;
    od;
if miss<>1 then
  # something is dodgy -- fallback to the default algorithm
  return fail;Error("HEH?");fi;
    Info(InfoHomClass,3,"Fused ",Length(norb),"*",norb[1].len," ",
      Number(orb)," left");
    Assert(1,ForAll(rsgens,x->norb[1].rep*bas*npcgsact(x)*basinv=norb[1].rep));
    Assert(1,ForAll(sgens,x->norb[1].rep*bas*npcgsact(x)*basinv=norb[1].rep));
#if ForAny(rsgens,x->Order(x)=1) then Error("HUH5"); fi;

    a:=[h*PcElementByExponents(Npcgs,norb[1].rep*bas),rsgens,sgens,sfgens,
        cl[5]/Length(norb)/norb[1].len, norb[1].stabrsubsz];

#rsgens:=List(rsgens,x->ImageElm(pcisom,x));
#if rsgens<>InducedPcgsByGenerators(FamilyPcgs(Range(pcisom)),rsgens) then
#  Error("nonpcgs!");
#fi;

    Add(newo,a);

  od;
  return newo;
end);

InstallGlobalFunction(ConjugacyClassesViaRadical,function (G)
local r,        #radical
      f,        # G/r
      hom,      # G->f
      pcgs,mpcgs, #(modulo) pcgs
      pcisom,
      gens,
      ser,      # series
      radsize,len,ntrihom,
      mran,nran,
      central,
      fants,
      d,
      solvtriv,
      i,        #loop
      new,      # new classes
      cl,ncl;   # classes

  # it seems to be cleaner (and avoids deferring abelian factors) if we
  # factor out the radical first. (Note: The radical method for perm groups
  # stores the nat hom.!)
  ser:=FittingFreeLiftSetup(G);
  if Length(ser.pcgs)>0 then
    radsize:=Product(RelativeOrders(ser.pcgs));
  else
    radsize:=1;
  fi;
  len:=Length(ser.pcgs);

  if radsize=1 then
    hom:=ser.factorhom;
    if IsPermGroup(Range(hom)) and not IsPermGroup(Source(hom)) then
      f:=Image(hom,G);
      cl:=ConjugacyClassesFittingFreeGroup(f:onlysizes:=false);
      cl:=List(cl,x->[PreImagesRepresentative(hom,x[1]),
        PreImage(hom,x[2])]);
    else
      cl:=ConjugacyClassesFittingFreeGroup(G:onlysizes:=false);
    fi;
    ncl:=[];
    for i in cl do
      r:=ConjugacyClass(G,i[1],i[2]);
      Add(ncl,r);
    od;
    return ncl;
  fi;

  pcgs:=ser.pcgs;
  pcisom:=ser.pcisom;
  fants:=[];

  # store centralizers as rep, centralizer generators in radical,
  # centralizer generators with nontrivial
  # radfactor image, corresponding radfactor images
  # the generators in the radical do not list the generators of the
  # current layer after immediate lifting.

  if radsize=Size(G) then
    # solvable case
    hom:=ser.factorhom;
    d:=MappingGeneratorsImages(hom);
    mran:=Filtered([1..Length(d[2])],x->not IsOne(d[2][x]));
    cl:=[[One(G),[],d[1]{mran},d[2]{mran},Size(G),Size(G)]];
  else
    # nonsolvable
    if radsize>1 then
      hom:=ser.factorhom;
      ntrihom:=true;
      f:=Image(hom);
      # if lift setup is inherited, f might not be trivial-fitting
      if Size(SolvableRadical(f))>1 then
        # this is proper recursion
        cl:=ConjugacyClasses(f:onlysizes:=false);
        cl:=List(cl,x->[Representative(x),Centralizer(x)]);
      else
      # we need centralizers
        cl:=ConjugacyClassesFittingFreeGroup(f:onlysizes:=false);
      fi;
      fants:=Filtered(NormalSubgroups(f),x->Size(x)>1 and Size(x)<Size(f));
    else
      if IsPermGroup(G) then
        hom:=SmallerDegreePermutationRepresentation(G:cheap);
        ntrihom:=not IsOne(hom);;
      else
        hom:=IdentityMapping(G);
        ntrihom:=false;
      fi;
      f:=Image(hom);
      cl:=ConjugacyClassesFittingFreeGroup(f);
    fi;

    if ntrihom then
      ncl:=[];
      for i in cl do
        new:=[PreImagesRepresentative(hom,i[1])];
        if not IsInt(i[2]) then
          Add(new,[]); # no generators in radical yet
          gens:=SmallGeneratingSet(i[2]);
          Add(new,
            List(gens,x->PreImagesRepresentative(hom,x)));
          Add(new,gens);
          #TODO: PreImage groups?
          #Add(new,PreImage(hom,i[2]));
          Add(new,radsize*Size(i[2]));
          Add(new,radsize);
        fi;
        Add(ncl,new);
      od;
      cl:=ncl;

    fi;
  fi;

  Assert(3,ForAll(cl,x->x[6]=Size(Group(Concatenation(x[2],pcgs)))));

  for d in [2..Length(ser.depths)] do
    #M:=ser[i-1];
    #N:=ser[i];
    mran:=[ser.depths[d-1]..len];
    nran:=[ser.depths[d]..len];

    mpcgs:=InducedPcgsByPcSequenceNC(pcgs,pcgs{mran}) mod
           InducedPcgsByPcSequenceNC(pcgs,pcgs{nran});

    central:= ForAll(GeneratorsOfGroup(G),
                i->ForAll(mpcgs,
                  j->DepthOfPcElement(pcgs,Comm(i,j))>=ser.depths[d]));

    # abelian factor, use affine methods
    Info(InfoHomClass,1,"abelian factor ",d,": ",
      Product(RelativeOrders(ser.pcgs){mran}), "->",
      Product(RelativeOrders(ser.pcgs){nran})," central:",central);

    ncl:=[];
    solvtriv:=Subgroup(Range(pcisom),
        List(DenominatorOfModuloPcgs(mpcgs),x->ImagesRepresentative(pcisom,x)));
    for i in cl do
      #Assert(2,ForAll(GeneratorsOfGroup(i[2]),j->Comm(i[1],j) in M));
      if (central or ForAll(Concatenation(i[2],i[3]),
                i->ForAll(mpcgs,
                  j->DepthOfPcElement(pcgs,Comm(i,j))>=ser.depths[d])) ) then
        Info(InfoHomClass,3,"central step");
        new:=LiftClassesEANonsolvCentral(mpcgs,i,hom,pcisom,solvtriv);
      elif Length(fants)>0 and Order(i[1])=1 then
        # special case for trivial representative
        new:=LiftClassesEATrivRep(mpcgs,i,fants,hom,pcisom,solvtriv);
        if new=fail then
          new:=LiftClassesEANonsolvGeneral(mpcgs,i,hom,pcisom,solvtriv);
        fi;
      else
        new:=LiftClassesEANonsolvGeneral(mpcgs,i,hom,pcisom,solvtriv);
      fi;
      #Assert(3,ForAll(new,x->x[6]
      #  =Size(Group(Concatenation(x[2],DenominatorOfModuloPcgs(mpcgs))))));

#if ForAny(new,x->x[2]<>TFMakeInducedPcgsModulo(pcgs,x[2],nran)) then Error("HUH6");fi;
#Print(List(new,x->List(x[2],y->DepthOfPcElement(pcgs,y))),"\n");

      #Assert(1,ForAll(new, i->ForAll(GeneratorsOfGroup(i[2]),j->Comm(j,i[1]) in N)));
      ncl:=Concatenation(ncl,new);
      Info(InfoHomClass,2,Length(new)," new classes (",Length(ncl)," total)");
    od;
    cl:=ncl;
    Info(InfoHomClass,1,"Now: ",Length(cl)," classes (",Length(ncl)," total)");
  od;

  if Order(cl[1][1])>1 then
    # the identity is not in first position
    Info(InfoHomClass,2,"identity not first, sorting");
    SortBy(cl,a->Order(a[1]));
  fi;

  Info(InfoHomClass,1,"forming classes");
  ncl:=[];
  for i in cl do
    if IsInt(i[2]) then
      r:=ConjugacyClass(G,i[1]);
      SetSize(r,Size(G)/i[2]);
    else
      d:=SubgroupByFittingFreeData(G,i[3],i[4],i[2]);
      Assert(2,Size(d)=i[5]);
      Assert(2,Centralizer(G,i[1]:usebacktrack)=d);
      SetSize(d,i[5]);
      r:=ConjugacyClass(G,i[1],d);
      SetSize(r,Size(G)/i[5]);
    fi;
    Add(ncl,r);
  od;

  # as this test is cheap, do it always
  if Sum(ncl,Size)<>Size(G) then
    Error("wrong classes");
  fi;

  cl:=ncl;

  return cl;
end);

#############################################################################
##
#F  LiftConCandCenNonsolvGeneral( <H>,<N>,<NT>,<cl> )
##
BindGlobal("LiftConCandCenNonsolvGeneral",
  function(Npcgs, reps, hom, pcisom,solvtriv)
    local  nreps,      # new reps to be constructed, the result
           correctingelement,
           minvec,
           cano,       # element that will be canonical
           cl,
           field,      # field over which <N> is a vector space
           one,
           h,          # preimage `cl.representative' under <hom>
           cg,
           cNh,        # centralizer of <h> in <N>
           gens,       # preimage `Centralizer( cl )' under <hom>
           r,          # dimension of <N>
           aff,        # <N> as affine space
           imgs,  M,   # generating matrices for affine operation
           orb,        # orbit of affine operation
           rep,# set of classes with canonical representatives
           c,  i, # loop variables
           PPcgs,denomdepths,
           corr,
           correctionfactor,
           censize,cenradsize,
           stabfacgens,
           stabfacimgs,
           stabrad,
           gpsz,subsz,solvsz,
           orblock,
           b,x,
           minimal,mappingelm,
           p,
           fe,
           repwords,radidx,
           sel,
           comm;# for class correction

  correctingelement:=function(h,rep,fe)
  local comm;
    comm:=Comm( h, fe ) * Comm( rep, fe );
    comm:= ExponentsOfPcElement(Npcgs,comm)*one;
    ConvertToVectorRep(comm,field);
    comm := List(comm * cg.inverse,Int);
    comm:=PcElementByExponentsNC
      ( Npcgs, Npcgs{ cg.needed }, -comm );
    fe:=fe*comm;
    return fe;
  end;

  mappingelm:=function(orb,pos)
  local mc,mcf,i;
    mc:=One(Source(hom));
    mcf:=One(Range(hom));
    for i in orb.repwords[pos] do
      mc:=mc*orb.gens[i];
      mcf:=mcf*orb.fgens[i];
    od;
    i:=pos mod orb.orblock;
    if i=0 then i:=orb.orblock;fi;
    mc:=orb.reps[i]*mc;
    return [mc,mcf];
  end;

  # all reps given must have the same canonical representative on the level
  # above. So they also all have the same centralizer and we can use this.
  cl:=reps[1];
  h := cl[3];

  field := GF( RelativeOrders( Npcgs )[ 1 ] );
  one:=One(field);
  PPcgs:=ParentPcgs(NumeratorOfModuloPcgs(Npcgs));
  denomdepths:=ShallowCopy(DenominatorOfModuloPcgs(Npcgs)!.depthsInParent);
  Add(denomdepths,Length(PPcgs)+1); # one

  # Determine the subspace $[h,N]$ and calculate the centralizer of <h>.
  #cNh := ExtendedPcgs( DenominatorOfModuloPcgs( N!.capH ),
  #               VSDecompCentAction( N, h, N!.capH ) );

  #oldcg:=KernelHcommaC(Npcgs,h,NumeratorOfModuloPcgs(Npcgs),2);

  #cg:=VSDecompCentAction( Npcgs, h, NumeratorOfModuloPcgs(Npcgs),field,2 );
  cg:=VSDecompCentAction( Npcgs, h, Npcgs,field,2 );
#Print("complen =",Length(cg.baseComplement)," of ",cg.dimensionN,"\n");
#if Length(Npcgs)>5 then Error("cb"); fi;

  cNh:=cg.cNh;

  r := Length( cg.baseComplement );

  # Construct matrices for the affine operation on $N/[h,N]$.
  Info(InfoHomClass,4,"space=",Size(field),"^",r);
  if Size(field)^r>3*10^8 then Error("too large");fi;
  aff := ExtendedVectors( field ^ r );

  # Format for cl is:
  # 1:Element, 2: Conjugate element, 3: Element that will be canonical
  # in factor, 4:conjugator, 5:cenpcgs,
  # 6:cenfac, 7:cenfacimgs, 8:censize, 9:cenfacsize

  gens:=Concatenation(cl[5],Npcgs,cl[6]); # all generators
  gpsz:=cl[8];

  solvsz:=cl[8]/cl[9];

  radidx:=Length(Npcgs)+Length(cl[5]);

  imgs := [  ];
  for c  in gens  do
    M := [  ];
    for i  in [ 1 .. r ]  do
        M[ i ] := Concatenation( ExponentsConjugateLayer( Npcgs,
              Npcgs[ cg.baseComplement[ i ] ] , c )
              * cg.projection, [ Zero( field ) ] );
    od;
    M[ r + 1 ] := Concatenation( ExponentsOfPcElement
                          ( Npcgs, Comm( h, c ) ) * cg.projection,
                          [ One( field ) ] );

    M:=ImmutableMatrix(field,M);
    Add( imgs, M );
  od;

#if Size(field)^r>10^7 then Error("BIG");fi;

  # now compute orbits, being careful to get stabilizers in steps
  #orbreps:=[];
  #stabs:=[];

  # change reps to list of more general format
  nreps:=[];
  for x in reps do
    p:=rec(list:=x);
    p.vector:=ExponentsOfPcElement(Npcgs,LeftQuotient(h,x[2]))*One(field);
    p.exponents:=ShallowCopy(p.vector);
    ConvertToVectorRep(p.vector,field);
    p.vector:=p.vector*cg.projection;
    Add(p.vector,One(field));
    Add(nreps,p);
  od;
  reps:=nreps;

  nreps:=[];
  sel:=[1..Length(reps)];
  while Length(sel)>0 do
    p:=sel[1]; # the one to do
    RemoveSet(sel,p);
    orb:=OrbitsRepsAndStabsVectorsMultistage(gens{[1..radidx]},
          imgs{[1..radidx]},
          pcisom,solvsz,solvtriv,
          gens{[radidx+1..Length(gens)]},
          imgs{[radidx+1..Length(gens)]},reps[p].list[7],hom,gpsz,OnRight,
          aff:orbitseed:=reps[p].vector);
    orb:=orb[1];
    # find minimal element, mapper, stabilizer of minimal element
    minvec:=Minimum(orb.orbit);
    minimal:=mappingelm(orb,Position(orb.orbit,minvec));

    # get the real minimum, including N-Orbit
    corr:=ExponentsOfPcElement(Npcgs,
                               LeftQuotient(h,reps[p].list[2]^minimal[1]));
    corr:=PcElementByExponentsNC(Npcgs,Npcgs{cg.needed},-corr*cg.inverse);
    minimal[1]:=minimal[1]*corr; # real minimizer

    # element that will be the canonical representative in the factor (tail
    # zeroed out)
    corr:=ExponentsOfPcElement(Npcgs,
           LeftQuotient(h,reps[p].list[2]^minimal[1]));
    cano:=h*PcElementByExponents(Npcgs,corr);

    # this will not be a pcgs, but we induce later anyhow
    stabrad:=List(orb.stabradgens,x->x^minimal[1]);
    stabfacgens:=List(orb.stabfacgens,x->x^minimal[1]);
    stabfacimgs:=List(orb.stabfacimgs,x->x^minimal[2]);

    censize:=orb.subsz;
    cenradsize:=orb.stabrsubsz;

    # correct generators. Partially in Pc Image
    if Length(cg.needed)>0 then

      rep:=LeftQuotient(h,reps[p].list[2]^minimal[1]);

      stabrad:=List(stabrad,x->correctingelement(h,rep,x));
      # must make proper pcgs -- correction does not preserve that
      stabrad:=TFMakeInducedPcgsModulo(PPcgs,stabrad,denomdepths);

      # we change by radical elements, so the images in the factor don't
      # change
      stabfacgens:=List(stabfacgens,x->correctingelement(h,rep,x));

      correctionfactor:=Characteristic(field)^Length(cg.needed);
      censize:=censize/correctionfactor;
      cenradsize:=cenradsize/correctionfactor;
    fi;

    # Format for cl is:
    # 1:Element, 2: Conjugate element, 3: Element that will be canonical
    # in factor, 4:conjugator, 5:cenpcgs,
    # 6:cenfac, 7:cenfacimgs, 8:censize, 9:cenfacsize

    Add(nreps,[reps[p].list[1],
               reps[p].list[2]^minimal[1],
               cano,
               reps[p].list[4]*minimal[1],
               stabrad,stabfacgens,stabfacimgs,
               censize,censize/cenradsize]);

    for cl in sel do
      b:=Position(orb.orbit,reps[cl].vector);
      if b<>fail then
        RemoveSet(sel,cl);
        # now find rep mapping 1 here
        b:=mappingelm(orb,b);
        b:=[LeftQuotient(b[1],minimal[1]),
                              LeftQuotient(b[2],minimal[2])];

        # get the real minimum, including N-Orbit
        corr:=ExponentsOfPcElement(Npcgs,
                                  LeftQuotient(h,reps[cl].list[2]^b[1]));
        corr:=PcElementByExponentsNC(Npcgs,Npcgs{cg.needed},corr*cg.inverse);
        b[1]:=b[1]/corr; # real minimizer

        # Format for cl is:
        # 1:Element, 2: Conjugate element, 3: Element that will be canonical
        # in factor, 4:conjugator, 5:cenpcgs,
        # 6:cenfac, 7:cenfacimgs, 8:censize, 9:cenfacsiz
        Add(nreps,[reps[cl].list[1],
                  reps[cl].list[2]^b[1],
                  cano,
                  reps[cl].list[4]*b[1],
                  stabrad,stabfacgens,stabfacimgs,
                  censize,censize/cenradsize]);

      elif ValueOption("conjugacytest")=true then
        # in conj test this would mean fail
        return fail;
      fi;
    od;
  od;

  return nreps;

end);

# canonical rep/centralizer
BindGlobal("TFCanonicalClassRepresentative",function (G,candidates)
local r,        #radical
      f,        # G/r
      hom,      # G->f
      prereps,  # fixed factor class reps preimages
      pcgs,mpcgs, #(modulo) pcgs
      pcisom,
      ser,      # series
      radsize,len,
      mran,nran,
      central,
      #fants,
      reps,
      nreps,
      fr,
      conj,
      d,
      solvtriv,
      select,sel,pos,
      i,j,      #loop
      new,      # new classes
      classrange,
      cl;   # classes

  # it seems to be cleaner (and avoids deferring abelian factors) if we
  # factor out the radical first. (Note: The radical method for perm groups
  # stores the nat hom.!)
  ser:=FittingFreeLiftSetup(G);
  if Length(ser.pcgs)>0 then
    radsize:=Product(RelativeOrders(ser.pcgs));
  else
    radsize:=1;
  fi;
  len:=Length(ser.pcgs);

  pcgs:=ser.pcgs;
  pcisom:=ser.pcisom;
  #fants:=fail;

  # store centralizers as rep, centralizer generators in radical,
  # centralizer generators with nontrivial
  # radfactor image, corresponding radfactor images
  # the generators in the radical do not list the generators of the
  # current layer after immediate lifting.

  if radsize=Size(G) then
    # solvable case
    hom:=ser.factorhom;
    d:=MappingGeneratorsImages(hom);
    mran:=Filtered([1..Length(d[2])],x->not IsOne(d[2][x]));
    # elm, elmconj, canonical factor, conjugator, cenpcgs,cenfac,cenfacimgs,censize,cenfacsiz
    reps:=List(candidates,x->[x,x,One(G),One(G),[],d[1]{mran},d[2]{mran},Size(G),Size(G)]);
  else
    # nonsolvable
    if radsize>1 then
      hom:=ser.factorhom;
      # we need centralizers
      #fants:=Filtered(NormalSubgroups(f),x->Size(x)>1 and Size(x)<Size(f));
    else
      if IsPermGroup(G) then
        hom:=SmallerDegreePermutationRepresentation(G:cheap);
      elif IsPermGroup(Range(ser.factorhom))
        and not IsPermGroup(Source(ser.factorhom)) then
        hom:=ser.factorhom;
      else
        hom:=IdentityMapping(G);
      fi;
    fi;
    f:=Image(hom,G);
    if not IsBound(f!.someClassReps) then
      f!.someClassReps:=[ConjugacyClass(f,One(f))]; # identity first
    fi;
    if HasConjugacyClasses(f) and
      Length(f!.someClassReps)<Length(ConjugacyClasses(f)) then
      # expand the list of stored factor classes for once.
      cl:=Filtered(ConjugacyClasses(f),x-> not ForAny(f!.someClassReps,
           y->Order(Representative(x))=Order(Representative(y))
           and Representative(y) in x));
      Append(f!.someClassReps,cl);
    fi;
    cl:=f!.someClassReps;

    classrange:=[1..Length(cl)];
    r:=ValueOption("candidatenums");
    if r<>fail and HasConjugacyClasses(G) then
      # candidatenums gives the numbers of some classes in G that should be
      # tried first (as they likely contain the element). Us this to reduce
      # conjugacy test in factor.
      if not IsBound(G!.radicalfactorclassmap) then
        G!.radicalfactorclassmap:=[];
      fi;
      fr:=G!.radicalfactorclassmap;
      for i in Filtered(r,x->not IsBound(fr[x])) do
        # compute images that are not yet known
        d:=ImagesRepresentative(hom,Representative(ConjugacyClasses(G)[i]));
        j:=First([1..Length(cl)],x->IsBound(cl[x]) and d in cl[x]);
        if j<>fail then
          fr[i]:=j;
        fi;
      od;
      r:=Filtered(r,x->IsBound(fr[x]));
      r:=Set(fr{r}); # class numbers in factor
      classrange:=Concatenation(r,
                   Filtered(classrange,x->not x in r));

    fi;

    nreps:=[];
    for i in candidates do
      fr:=ImagesRepresentative(hom,i);
      conj:=fail;
      j:=0;
      while conj=fail and j<Length(classrange) do
        j:=j+1;
        if Order(fr)=Order(Representative(cl[classrange[j]])) then
          conj:=RepresentativeAction(f,fr,Representative(cl[classrange[j]]));
        fi;
      od;

      if conj=fail then
        # not yet found, and classes of f were not known -- store this rep
        # image as canonical one for future use.
        j:=j+1;
        Add(cl,ConjugacyClass(f,fr));
        Add(classrange,Length(cl));
        conj:=One(f);
      else
        j:=classrange[j];
      fi;
      # store fixed preimages of reps to avoid any impact of homomorphism.
      if not IsBound(f!.classpreimgs) then
        f!.classpreimgs:=[];
      fi;
      prereps:=f!.classpreimgs;
      if not IsBound(prereps[j]) then
        prereps[j]:=PreImagesRepresentative(hom,Representative(cl[j]));
      fi;

      r:=PreImagesRepresentative(hom,conj);

      d:=GeneratorsOfGroup(Centralizer(cl[j]));
      # Format for cl is:
      # 1:Element, 2: Conjugate element, 3: Element that will be canonical
      # in factor, 4:conjugator, 5:cenpcgs,
      # 6:cenfac, 7:cenfacimgs, 8:censize, 9:cenfacsize
      Add(nreps,[i,i^r,prereps[j],r,[],
        List(d,x->PreImagesRepresentative(hom,x)),d,
        radsize*Size(Centralizer(cl[j])), Size(Centralizer(cl[j]))]);
    od;
    reps:=nreps;

  fi;

  for d in [2..Length(ser.depths)] do
    #M:=ser[i-1];
    #N:=ser[i];
    mran:=[ser.depths[d-1]..len];
    nran:=[ser.depths[d]..len];

    mpcgs:=InducedPcgsByPcSequenceNC(pcgs,pcgs{mran}) mod
           InducedPcgsByPcSequenceNC(pcgs,pcgs{nran});

    central:= ForAll(GeneratorsOfGroup(G),
                i->ForAll(mpcgs,
                  j->DepthOfPcElement(pcgs,Comm(i,j))>=ser.depths[d]));

    # abelian factor, use affine methods
    Info(InfoHomClass,1,"abelian factor ",d,": ",
      Product(RelativeOrders(ser.pcgs){mran}), "->",
      Product(RelativeOrders(ser.pcgs){nran})," central:",central);

    nreps:=[];
    solvtriv:=Subgroup(Range(pcisom),
        List(DenominatorOfModuloPcgs(mpcgs),x->ImagesRepresentative(pcisom,x)));
    select:=[1..Length(reps)];
    while Length(select)>0 do
      pos:=select[1];
      # same reps, same gens
      sel:=Filtered(select,x->reps[x][3]=reps[pos][3] and
        reps[x][5]=reps[pos][5] and reps[x][6]=reps[pos][6]);

      if ValueOption("conjugacytest")=true and Length(sel)<>2 then
        return fail;
      fi;
      Info(InfoHomClass,2,Length(sel)," in candidate group");
      select:=Difference(select,sel);
      new:=LiftConCandCenNonsolvGeneral(mpcgs,reps{sel},hom,pcisom,
             solvtriv);
      # conj test
      if new=fail then
        return new;
      fi;
      Append(nreps,new);
    od;
    reps:=nreps;
  od;

  # arrange back to same ordering as before.
  nreps:=[];
  for i in candidates do
    Add(nreps,First(reps,x->IsIdenticalObj(x[1],i)));
  od;

  return nreps;
end);

#############################################################################
##
#M  Centralizer( <G>, <e> ) . . . . . . . . . . . . . . using TF method
##
InstallMethod( CentralizerOp, "TF method:elm",IsCollsElms,
  [ IsGroup and IsFinite and HasFittingFreeLiftSetup,
  IsMultiplicativeElementWithInverse ], OVERRIDENICE,
function( G, e )
local ffs,c,ind;
  if IsPcGroup(G)
    or (IsPermGroup(G) and AttemptPermRadicalMethod(G,"CENT")<>true)
    or not e in G then
      TryNextMethod();
  fi;
  ffs:=FittingFreeLiftSetup(G);
  c:=TFCanonicalClassRepresentative(G,[e]:useradical:=false)[1];
  if c=fail then TryNextMethod();fi;
  if Length(ffs.pcgs)>0 then
    ind:=InducedPcgsByGenerators(ffs.pcgs,c[5]);
  else
    ind:=[];
  fi;
  c:=SubgroupByFittingFreeData(G,c[6],c[7],ind)^Inverse(c[4]);
  Assert(2,ForAll(GeneratorsOfGroup(c),x->IsOne(Comm(x,e))));
  return c;
end );

#############################################################################
##
#M  Centralizer( <G>, <e> ) . . . . . . . . . . . . . . using TF method
##
InstallMethod( CentralizerOp, "TF method:subgroup",IsIdenticalObj,
  [ IsGroup and IsFinite and HasFittingFreeLiftSetup,
  IsGroup and IsFinite and HasGeneratorsOfGroup],
  2*OVERRIDENICE,
function( G, S )
local c,e;
  if IsPermGroup(G) or IsPcGroup(G) then TryNextMethod();fi;
  c:=G;
  for e in GeneratorsOfGroup(S) do
    c:=Centralizer(c,e);
  od;
  return c;
end );

#############################################################################
##
#M  RepresentativeAction( <G>, <d>, <e>, <act> ) . . . . . using TF method
##
InstallOtherMethod( RepresentativeActionOp, "TF Method on elements",
  IsCollsElmsElmsX,
  [ IsGroup and IsFinite and HasFittingFreeLiftSetup,
        IsMultiplicativeElementWithInverse,
        IsMultiplicativeElementWithInverse, IsFunction ],
  OVERRIDENICE,
function ( G, d, e, act )
local c;
  if IsPcGroup(G)
    or (IsPermGroup(G) and AttemptPermRadicalMethod(G,"CENT")<>true)
    or not (d in G and e in G) then
      TryNextMethod();
  fi;

  if IsPermGroup(G) and CycleStructurePerm(d)<>CycleStructurePerm(e) then
    return fail;
  fi;

  if act=OnPoints then #and d in G and e in G then
    c:=TFCanonicalClassRepresentative(G,[d,e]:conjugacytest,useradical:=false);
    if c=fail then
      return fail;
    else
      if c[1][2]=c[2][2] then
        return c[1][4]/c[2][4]; # map via canonicals
      else
        return fail; # not conjugate
      fi;
    fi;
  fi;
  TryNextMethod();
end);

#############################################################################
##
#M  ConjugacyClasses( <G> ) . . . . . . . . . . . . . . . . . . of perm group
##
InstallMethod( ConjugacyClasses, "perm group", true,
  [ IsPermGroup and IsFinite],OVERRIDENICE,
function( G )
local cl;
  if IsNaturalSymmetricGroup(G) or IsNaturalAlternatingGroup(G) then
    # there are better methods for Sn/An
    TryNextMethod();
  fi;

  cl:=ConjugacyClassesForSmallGroup(G);
  if cl<>fail then
    return cl;
  elif IsSolvableGroup( G ) and CanEasilyComputePcgs(G) then
    return ConjugacyClassesForSolvableGroup(G);
  elif IsNonabelianSimpleGroup( G ) then
    cl:=ClassesFromClassical(G);
    if cl=fail then
      cl:=ConjugacyClassesByRandomSearch( G );
    fi;
    return cl;
  else
    return ConjugacyClassesViaRadical(G);
  fi;
end );

#############################################################################
##
#M  ConjugacyClasses( <G> ) . . . . . . . . . . . . . . . . . . of perm group
##
InstallMethod( ConjugacyClasses, "TF Method", true,
  [ IsGroup and IsFinite and CanComputeFittingFree],OVERRIDENICE,
function(G)
  if IsPermGroup(G) or IsPcGroup(G) then TryNextMethod();fi;
  return ConjugacyClassesViaRadical(G);
end);


#############################################################################
##
#F  TFClassMatrixColumn(<D>,<mat>,<r>,<t>)  . calculate the t-th column
#F       of the r-th class matrix and store it in the appropriate column of M
##
BindGlobal("TFClassMatrixColumn",function(D,M,r,t)
  local c,gt,s,z,i,T,w,e,j,p,orb,collect,found,id;
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
      collect:=[];
      for i in [1..Length(T[1])] do
        e:=T[1][i]*z;
        Unbind(T[1][i]);
        found:=false;
        if w then
          c:=D.rationalidentification(D,e);
          if c in orb.uniqueIdentifications then
            s:=orb.orbits[
              First([1..D.klanz],j->D.rids[j]=c)][1];
            M[s,t]:=M[s,t]+T[2][i];
            found:=true;
          fi;
        fi;
        if not found then
          id:=D.cheapIdentification(D,e);
          s:=Filtered([1..D.klanz],i->D.chids[i]=id);
          if Length(s)=1 then
            s:=s[1];
            M[s,t]:=M[s,t]+T[2][i];
          else
            # only strong test possible
            Add(collect,[e,First(D.faclaimg,y->y[1]=id)[2],T[2][i]]);
            #s:=D.ClassElement(D,e);
            #M[s,t]:=M[s,t]+T[2][i];
          fi;
        fi;
      od;
      #Print(Length(collect)," collected\n");
      if Length(collect)=1 then
        s:=D.ClassElement(D,collect[1][1]);
        M[s,t]:=M[s,t]+collect[1][3];
      else
        for id in Set(List(collect,x->x[2])) do
          found:=Filtered(collect,x->x[2]=id);
          s:=TFCanonicalClassRepresentative(D.group,
            List(found,x->x[1]):candidatenums:=id);
          s:=List(s,x->x[2]);
          s:=List(s,x->First(id,y->D.canreps[y]=x));
          for i in [1..Length(s)] do
            M[s[i],t]:=M[s[i],t]+found[i][3];
          od;

        od;
      fi;

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
end);
