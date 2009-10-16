DeclareGlobalFunction( "NormalTree" );


AddScalarstoKernel := function(ri,rifac,Z)
# Adds the scalars to the kernel
 local l,z,s,y,n,i;

 Info(InfoRecognition,1,"Forcing scalars in image to be in the  kernel.");
 l := gensN(ri);
 if IsTrivial(Z) then return true; fi;
 z := GeneratorsOfGroup(Z)[1];
 if not IsDirectProduct(group(rifac)) then
   s := SLPforElement(rifac,z);
   y := ResultOfStraightLineProgram(s,
                 ri!.genswithmem{[ri!.nrgensH+1..Length(ri!.genswithmem)]});
   Add(l,y);
   return true;
 fi;
       
 if IsDirectProduct(group(rifac)) then
   n := NumberOfDPComponents(group(rifac));
   for i in [1..n] do
     s := SLPforElement(rifac,ImageElm(MyEmbedding(group(rifac),i),z));
     y := ResultOfStraightLineProgram(s,
                 ri!.genswithmem{[ri!.nrgensH+1..Length(ri!.genswithmem)]});
     Add(l,y);
   od;
   return true;
 fi;
end;  
 

#DealWithOpG := function(ri)
## Construct the remaining part of the chief series sitting in Op(G)

# G := overgroup(ri);
# F := FieldOfMatrixGroup(G);
# M := GModuleByMats(GeneratorsOfGroup(G),F);
# B := MTX.BasesCompositionSeries(M);
# dims := List(B,x->Size(x));
# cmat := ReducibleCOB(M,F,B);
# Cgens := List(GeneratorsOfGroup(G),g->g^cmat);
# Blockgens := List(Cgens,x->List([1..(Length(dims)-1)],i->x{[(dims[i]+1)..dims[i+1]]}{[(dims[i]+1)..dims[i+1]]}));
# Blockgensinverses := List(Cgens,x->List([1..(Length(dims)-1)],i->(x{[(dims[i]+1)..dims[i+1]]}{[(dims[i]+1)..dims[i+1]]})^-1));
# Fprime := PrimeField(F);
# p := Size(Fprime);
# Fbasis := Basis(F);
# e := DegreeOverPrimeField(F);

# lri := []; rri := [];
# lri[1] := rec();
# Objectify(RecognitionInfoType,lri[1]);;
  
# Setgroup(lri[1],group(ri));

# overgp := ShallowCopy(overgroup(ri));
# Setovergroup(lri[1],overgp);
 
# count := 1;
# for i in [1..(Length(dims)-1)] do
#   for j in [1..(Length(dims)-i)] do
#   i1 := j; j1 := i + j;
#   Ugens := GeneratorsOfGroup(group(lri[count]));
#   Vq := FullRowSpace(F,(dims[i1+1]-dims[i1])*(dims[j1+1]-dims[j1]));
#   Vp := FullRowSpace(Fprime,(dims[i1+1]-dims[i1])*(dims[j1+1]-dims[j1])*e);
#   GtoVp := function(g)
#     local c,el;
#     c := g^cmat;
#     el := c{[(dims[j1]+1)..dims[j1+1]]}{[(dims[i1]+1)..dims[i1+1]]};
#     return BlownUpVector(Fbasis,Concatenation(el));
#   end;
#   Vptomat := function(v)
#     local k1,k2,l,im,mat,c;
#     im := [];
#     for k1 in [1..Dimension(Vq)] do
#       l := List([1..e],k2->Fbasis[k2]*v[(k1-1)*e+k2]);
#       Add(im,Sum(l));
#     od;
#     mat := NullMat(dims[i1+1]-dims[i1],dims[j1+1]-dims[j1],F);
#     c := 1;
#     for k1 in [1..Length(mat)] do
#       for k2 in [1..Length(mat[1])] do
#         mat[k1][k2] := im[c];
#         c := c + 1;
#       od;
#     od;
#     return mat;
#   end;
#   Vsubims := List(Ugens,x->GtoVp(x));   
#   Vsub := SubspaceNC(Vp,Vsubims);
#   if Dimension(Vsub) gt 0 then
# Construct a basis for Vsub
#     B := [];
#     Bpreims := [];
#     Bmats := [];
#     for k in [1..Length(Vsubims)] do
#       if not Vsubims[k] in SubspaceNC(Vp,B) then
#         Add(B,Vsubims[k]);
#         Add(Bpreims,Ugens[k]);
#         Add(Bmats,VptoMat(Vsubims[k]));
#       fi;
#       if Length(B) = Dimension(Vsub) then break; fi;
#     od;
# Spinning up the module
#     repeat
#       ExtraElts := [];
#       for k1 in [1..Length(B)] do
#         for k2 in [1..Length(GeneratorsOfGroup(G))] do
#           mat := Blockgensinverses[k2][j1]*Bmats[k1]*Blockgens[k2][i1];
#           im := BlownUpVector(Fbasis,Concatenation(mat)); 
#           if not im in Vsub then
#             Add(ExtraElts,Bpreims[k1]^GeneratorsOfGroup(G)[k2]);
#             Add(B,im);
#             Add(Bmats,mat);
#             Add(Bpreims,Bpreims[k1]^GeneratorsOfGroup(G)[k2]);
#             Add(Vsubims,im);
#             Vsub := SubspaceNC(Vp,Vsubims);
#           fi; 
#         od;
#       od;
#       Ugens := Concatenation(Ugens,ExtraElts);
#     until Length(ExtraElts)=0;

#     VV := VectorSpace(F,B,"basis");
#     b := Basis(B,VV);
#     VPc := ElementaryAbelianGroup(p^Length(b));
#     rri[count] := rec();
#     Objectify(RecognitionInfoType,rri[count]);;
#     Setgroup(rri[count],VPc);
# Solve the rewriting problem with these gens
#     P := Pcgs(VPc);
#     Triv := GroupWithMemory(GroupWithGenerators(List(AsList(P),x->())));
#     VPctoTriv := GroupHomomorphismByImages(VPc,Triv,AsList(P),GeneratorsOfGroup(Triv)); 
#     mems := List(AsList(P),x->ImageElm(VPctoTriv,x));
#     Setslptonice(rri[count],SLPOfElms(mems));   
#     Setcalcnicegens(rri[count], CalcNiceGensGeneric);
#     Setslpforelement(rri[count],
#   function(rri[count],g)
#     return SLPOfElm(ImageElm(VPctoTriv,g));
#   end);  
#     Setpregensfac(lri[count],Bpreims);
#     Sethomom(lri[count],GroupHomomorphismByFunction(group(lri[count]),VPc,function(g)
#  local v;
#  v := GtoVp(g);
#  return PcElementByExponents(Pcgs(VPc),List(v,x->IntFFE(x)));
#  end));
# Setup the kernel
          









	


InstallGlobalFunction( NormalTree,
  function(arg)
    # Contructs a normal tree
    # Call via NormalTree(G,nsm,depth)
    
    # Assume all the generators have no memory!
    local H,N,depth,done,i,knowledge,l,ll,methgensN,methoddb,
          proj1,proj2,ri,rifac,riker,s,x,y,z,succ,counter,nsm,name,
	  I,OverI;

    # Look after arguments:
    H := arg[1];
    nsm := arg[2];
    depth := arg[3];
    if Length(arg) = 4 then
        knowledge := arg[4];
    else
        knowledge := rec();
    fi;

    Info(InfoRecognition,3,"Recognising: ",H);

    if Length(GeneratorsOfGroup(H)) = 0 then
        H := Group([One(H)]);
    fi;

    # Set up the record and the group object:
    ri := ShallowCopy(knowledge);
    Objectify( RecognitionInfoType, ri );;
    ri!.depth := depth;
    ri!.nrgensH := Length(GeneratorsOfGroup(H));
    Setovergroup(ri,nsm!.Group);

    Setgroup(ri,H);
    Setcalcnicegens(ri,CalcNiceGensGeneric);
    Setslpforelement(ri,SLPforElementGeneric);
    SetgensN(ri,[]);       # this will grow over time
    SetfindgensNmeth(ri,rec(method := FindKernelRandom, args := [20]));
    Setimmediateverification(ri,false);
    Setforkernel(ri,rec(hints := []));   
          # this is eventually handed down to the kernel
    Setforfactor(ri,rec(hints := []));   
          # this is eventually handed down to the factor


    # Use the homomorphism defined by nsm!.Maps[depth+1];
    if IsBound(nsm!.Maps[depth+1]) then
      Sethomom(ri,nsm!.Maps[depth+1]);
      name := nsm!.Names[depth+1]; 
      Setfhmethsel(ri,"Hom from NSM"); 
      OverI := nsm!.MapImages[depth+1];
    else
# We are now in Op(G)
#      map1 := IsomorphismPcPGroup(group(ri));
#      map2 := IsomorphismPcGroup(Image(map1));
#  Should have some good spinning up property and a better way of handling this!       
      Sethomom(ri,IsomorphismPcGroup(group(ri)));
      OverI := Image(homom(ri));
      name := "";
    fi;     
      

    # We know we are in the non-leaf case:
    # In that case we know that ri now homom and image of homom is a leaf
    
    Info(InfoRecognition,1,"Going to the factor (depth=",depth,")");

    I := SubgroupNC(OverI,List(GeneratorsOfGroup(H), x->ImageElm(homom(ri),x)));

    rifac := RecogniseLeaf(ri,I,name);;

     Setfactor(ri,rifac);
     Setparent(rifac,ri);

     Info(InfoRecognition,1,"Back from factor (depth=",depth,").");

     if not(IsReady(rifac)) then
          # the recognition of the factor failed, also give up here:
          return ri;
     fi;

        # Now we want to have preimages of the new generators in the factor:
      if not IsBound(ri!.pregensfac) then
        Info(InfoRecognition,1,"Calculating preimages of nice generators.");
        Setpregensfac( ri, CalcNiceGens(rifac,GeneratorsOfGroup(H)));
      fi;
        Setcalcnicegens(ri,CalcNiceGensHomNode);

        ri!.genswithmem := GeneratorsWithMemory(
            Concatenation(GeneratorsOfGroup(H),pregensfac(ri)));
        ri!.groupmem := Group(ri!.genswithmem{[1..ri!.nrgensH]});

        # Now create the kernel generators with the stored method:
        Info(InfoRecognition,2,"Creating kernel elements.");
        methgensN := findgensNmeth(ri);
        succ := CallFuncList(methgensN.method,
                             Concatenation([ri],methgensN.args));
        
# If the map is modulo scalars force the scalars to be added to the kernel
    if IsBound(nsm!.Scalars[depth+1]) and nsm!.Scalars[depth+1]<>0 then
      succ := AddScalarstoKernel(ri,rifac,nsm!.Scalars[depth+1]);
    fi;
   
    # Do a little bit of preparation for the generators of N:
    l := gensN(ri);
    if not(IsBound(ri!.leavegensNuntouched)) then
        Sort(l,SortFunctionWithMemory);   # this favours "shorter" memories!
        # remove duplicates:
        ll := [];
        for i in [1..Length(l)] do
            if not(IsOne(l[i])) and (i = 1 or l[i] <> l[i-1]) then
                Add(ll,l[i]);
            fi;
        od;
        SetgensN(ri,ll);
    fi;
    if Length(gensN(ri)) = 0 then
        # We found out that N is the trivial group!
        # In this case we do nothing, kernel is fail indicating this.
        Info(InfoRecognition,1,"Found trivial kernel (depth=",depth,").");
        Setkernel(ri,fail);
        # We have to learn from the factor, what our nice generators are:
        Setnicegens(ri,pregensfac(ri));
        SetFilterObj(ri,IsReady);
        return ri;
    fi;

    Info(InfoRecognition,1,"Going to the kernel (depth=",depth,").");
        # Now we go on as usual:
        SetgensNslp(ri,SLPOfElms(gensN(ri)));
        # This is now in terms of the generators of H plus the preimages
        # of the nice generators behind the homomorphism!
        N := Group(StripMemory(gensN(ri)));
        
        riker := NormalTree( N, nsm, depth+1 );;
        Setkernel(ri,riker);
        Setparent(riker,ri);
        Info(InfoRecognition,1,"Back from kernel (depth=",depth,").");

        done := true;

    if IsReady(riker) then    # we are only ready when the kernel is
        # Now make the two projection slps:
        Setnicegens(ri,Concatenation(pregensfac(ri),nicegens(riker)));
        #ll := List([1..Length(nicegens(rifac))],i->[i,1]);
        #ri!.proj1 := StraightLineProgramNC([ll],Length(nicegens(ri)));
        #ll := List([1..Length(nicegens(riker))],
        #           i->[i+Length(nicegens(rifac)),1]);
        #ri!.proj2 := StraightLineProgramNC([ll],Length(nicegens(ri)));
        SetFilterObj(ri,IsReady);
    fi;
    return ri;
  end);
