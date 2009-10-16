#############################################################################
##
##  matrix.gi          recog package                      Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  A collection of find homomorphism methods for matrix groups.
##
##  $Id: matrix.gi,v 1.48 2006/10/11 03:30:27 gap Exp $
##
#############################################################################

SLPforElementFuncsMatrix.TrivialMatrixGroup :=
   function(ri,g)
     return StraightLineProgramNC( [ [1,0] ], 1 );
   end;

FindHomMethodsMatrix.TrivialMatrixGroup := function(ri, G)
  local g,gens;
  gens := GeneratorsOfGroup(G);
  for g in gens do
      if not(IsOne(g)) then
          return false;
      fi;
  od;
  SetSize(G,1);
  SetSize(ri,1);
  Setslpforelement(ri,SLPforElementFuncsMatrix.TrivialMatrixGroup);
  Setslptonice( ri, 
                StraightLineProgramNC([[[1,0]]],Length(GeneratorsOfGroup(G))));
  SetFilterObj(ri,IsLeaf);
  return true;
end;

RECOG.HomToScalars := function(data,el)
  return ExtractSubMatrix(el,data.poss,data.poss);
end;

FindHomMethodsMatrix.DiagonalMatrices := function(ri, G)
  local H,d,f,gens,hom,i,isscalars,j,newgens,upperleft;

  d := DimensionOfMatrixGroup(G);
  if d = 1 then
      Info(InfoRecog,1,"Found dimension 1, going to Scalars method");
      return FindHomMethodsMatrix.Scalar(ri,G);
  fi;

  gens := GeneratorsOfGroup(G);
  if not(ForAll(gens,IsDiagonalMat)) then
      return false;
  fi;

  # FIXME: FieldOfMatrixGroup
  f := FieldOfMatrixGroup(G);
  isscalars := true;
  i := 1;
  while isscalars and i <= Length(gens) do
      j := 2;
      upperleft := gens[i][1][1];
      while isscalars and j <= d do
          if upperleft <> gens[i][j][j] then
              isscalars := false;
          fi;
          j := j + 1;
      od;
      i := i + 1;
  od;

  if not(isscalars) then 
      # We quickly know that we want to make a balanced tree:
      ri!.blocks := List([1..d],i->[i]);
      # Note that we cannot tell the upper levels that they should better
      # have made some more generators for the kernel!

      return FindHomMethodsMatrix.BlockScalar(ri,G);
  fi;

  # Scalar matrices, so go to dimension 1:
  newgens := List(gens,x->ExtractSubMatrix(x,[1],[1]));
  H := Group(newgens);
  hom := GroupHomByFuncWithData(G,H,RECOG.HomToScalars,rec(poss := [1]));
  Sethomom(ri,hom);
  findgensNmeth(ri).method := FindKernelDoNothing;

  # Hint to the factor:
  Add(forfactor(ri).hints,rec( method := FindHomMethodsMatrix.Scalar,
                               rank := 2000, stamp := "Scalar" ),1);

  return true;
end;

#RECOG.DetWrapper := function(m)
#  local n;
#  n := ExtractSubMatrix(m,[1],[1]);
#  n[1][1] := DeterminantMat(m);
#  return n;
#end;

#FindHomMethodsMatrix.Determinant := function(ri, G)
#  local H,d,dets,gens,hom;
#  d := DimensionOfMatrixGroup(G);
#  if d = 1 then
#      Info(InfoRecog,1,"Found dimension 1, going to Scalar method");
#      return FindHomMethodsMatrix.Scalar(ri,G);
#  fi;
#
#  # check for a hint from above:
#  if IsBound(ri!.containedinsl) and ri!.containedinsl = true then
#      return false;  # will not succeed
#  fi;
#
#  gens := GeneratorsOfGroup(G);
#  dets := List(gens,RECOG.DetWrapper);
#  if ForAll(dets,IsOne) then
#      ri!.containedinsl := true;
#      return false;  # will not succeed
#  fi;
#  
#  H := GroupWithGenerators(dets);
#  hom := GroupHomomorphismByFunction(G,H,RECOG.DetWrapper);
#
#  Sethomom(ri,hom);
#
#  # Hint to the kernel:
#  forkernel(ri).containedinsl := true;
#  return true;
#end;

SLPforElementFuncsMatrix.DiscreteLog := function(ri,x)
  local log;
  log := LogFFE(x[1][1],ri!.generator);
  return StraightLineProgramNC([[1,log]],1);
end;

FindHomMethodsMatrix.Scalar := function(ri, G)
  local f,gcd,generator,gens,i,l,o,pows,q,rep,slp,subset,z;
  if DimensionOfMatrixGroup(G) > 1 then
      return NotApplicable;
  fi;

  # FIXME: FieldOfMatrixGroup
  f := FieldOfMatrixGroup(G);
  o := One(f);
  gens := List(GeneratorsOfGroup(G),x->x[1][1]);
  subset := Filtered([1..Length(gens)],i->not(IsOne(gens[i])));
  if subset = [] then
      return FindHomMethodsMatrix.TrivialMatrixGroup(ri,G);
  fi;
  gens := gens{subset};
  q := Size(f);
  z := PrimitiveRoot(f);
  pows := [LogFFE(gens[1],z)];     # zero cannot occur!
  Add(pows,q-1);
  gcd := Gcd(Integers,pows);
  i := 2;
  while i <= Length(gens) and gcd > 1 do
      pows[i] := LogFFE(gens[i],z);
      Add(pows,q-1);
      gcd := Gcd(Integers,pows);
      i := i + 1;
  od;
  rep := GcdRepresentation(Integers,pows);
  l := [];
  for i in [1..Length(pows)-1] do
      if rep[i] <> 0 then
          Add(l,subset[i]);
          Add(l,rep[i]);
      fi;
  od;
  slp := StraightLineProgramNC([[l]],Length(GeneratorsOfGroup(G)));
  Setslptonice(ri,slp);   # this sets the nice generators
  Setslpforelement(ri,SLPforElementFuncsMatrix.DiscreteLog);
  ri!.generator := ResultOfStraightLineProgram(slp,
                                      GeneratorsOfGroup(G))[1][1][1];
  SetFilterObj(ri,IsLeaf);
  return true;
end;

RECOG.HomToDiagonalBlock := function(data,el)
  return ExtractSubMatrix(el,data.poss,data.poss);
end;

FindHomMethodsMatrix.BlockScalar := function(ri,G)
  # We assume that ri!.blocks is a list of ranges where the non-trivial
  # scalar blocks are. Note that their length does not have to sum up to 
  # the dimension, because some blocks at the end might already be trivial.
  local H,data,hom,middle,newgens,nrblocks,topblock;
  nrblocks := Length(ri!.blocks);  # this is always >= 1
  if nrblocks <= 2 then   # the factor is only one block
      # go directly to scalars in that case:
      data := rec(poss := [ri!.blocks[nrblocks][1]]);
      newgens := List(GeneratorsOfGroup(G),x->RECOG.HomToDiagonalBlock(data,x));
      H := GroupWithGenerators(newgens);
      hom := GroupHomByFuncWithData(G,H,RECOG.HomToDiagonalBlock,data);
      Sethomom(ri,hom);
      Add(forfactor(ri).hints,
          rec( method := FindHomMethodsMatrix.Scalar, rank := 2000,
               stamp := "Scalar" ),1);

      if nrblocks = 1 then     # no kernel:
          findgensNmeth(ri).method := FindKernelDoNothing;
      else   # exactly two blocks:
          forkernel(ri).blocks := ri!.blocks{[1]};
          # We have to go to BlockScalar with 1 block because the one block 
          # is only a part of the whole matrix:
          Add(forkernel(ri).hints,
              rec( method := FindHomMethodsMatrix.BlockScalar, rank := 2000,
                   stamp := "BlockScalar" ),1);
          Setimmediateverification(ri,true);
      fi;
      return true;
  fi;

  # We hack away at least two blocks and leave at least one:
  middle := QuoInt(nrblocks,2)+1;   # the first one taken
  topblock := ri!.blocks[nrblocks];
  data := rec(poss := [ri!.blocks[middle][1]..topblock[Length(topblock)]]);
  newgens := List(GeneratorsOfGroup(G),x->RECOG.HomToDiagonalBlock(data,x));
  H := GroupWithGenerators(newgens);
  hom := GroupHomByFuncWithData(G,H,RECOG.HomToDiagonalBlock,data);
  Sethomom(ri,hom);

  # the factor are the last few blocks:
  forfactor(ri).blocks := List(ri!.blocks{[middle..nrblocks]},
                               x->x - (ri!.blocks[middle][1]-1));
  Add(forfactor(ri).hints,
      rec( method := FindHomMethodsMatrix.BlockScalar, rank := 2000,
           stamp := "BlockScalar" ),1);

  # the kernel is the first few blocks (can be only one!):
  findgensNmeth(ri).args[1] := 20 + middle - 1;
  forkernel(ri).blocks := ri!.blocks{[1..middle-1]};
  Add(forkernel(ri).hints,
      rec( method := FindHomMethodsMatrix.BlockScalar, rank := 2000,
           stamp := "BlockScalar" ),1);
  Setimmediateverification(ri,true);
  return true;
end;

# A helper function for base changes:

ExtendToBasisOfFullRowspace := function(m,f)
  # FIXME:
  # This function has to be improved with respect to performance:
  local i,o,v,z;
  if not(IsMutable(m)) then
      m := MutableCopyMat(m);
  fi;
  v := ZeroMutable(m[1]);
  if RankMat(m) < Length(m) then
      Error("No basis!");
      return;
  fi;
  i := 1;
  o := One(f);
  z := Zero(f);
  while Length(m) < Length(m[1]) do
      v[i] := o;
      Add(m,ShallowCopy(v));
      v[i] := z;
      if RankMat(m) < Length(m) then
          Unbind(m[Length(m)]);
      #else
      #    Print("len=",Length(m),"    \r");
      fi;
      i := i + 1;
  od;
  #Print("\n");
  return m;
end;

RECOG.HomDoBaseChange := function(data,el)
  return data.t*el*data.ti;
end;

RECOG.CleanRow := function( basis, vec, extend, dec)
  local c,firstnz,i,j,lc,len,lev,mo,newpiv,pivs;
  # INPUT
  # basis: record with fields
  #        pivots   : integer list of pivot columns of basis matrix
  #        vectors : matrix of basis vectors in semi echelon form
  # vec  : vector of same length as basis vectors
  # extend : boolean value indicating whether the basis will we extended
  #          note that for the greased case also the basis vectors before
  #          the new one may be changed
  # OUTPUT
  # returns decomposition of vec in the basis, if possible.
  # otherwise returns 'fail' and adds cleaned vec to basis and updates
  # pivots
  # NOTES
  # destructive in both arguments

  # Clear dec vector if given:
  if dec <> fail then
    MultRowVector(dec,Zero(dec[1]));
  fi;
  
  # First a little shortcut:
  firstnz := PositionNonZero(vec);
  if firstnz > Length(vec) then
      return true;
  fi;

  len := Length(basis.vectors);
  i := 1;

  for j in [i..len] do
    if basis.pivots[j] >= firstnz then
      c := vec[ basis.pivots[ j ] ];
      if not IsZero( c ) then
        if dec <> fail then
          dec[ j ] := c;
        fi;
        AddRowVector( vec, basis.vectors[ j ], -c );
      fi;
    fi;
  od;

  newpiv := PositionNonZero( vec );
  if newpiv = Length( vec ) + 1 then
    return true;
  else
    if extend then
      c := vec[newpiv]^-1;
      MultRowVector( vec, vec[ newpiv ]^-1 );
      if dec <> fail then
        dec[len+1] := c;
      fi;
      Add( basis.vectors, vec );
      Add( basis.pivots, newpiv );
    fi;
    return false;
  fi;
end;

RECOG.FindAdjustedBasis := function(l)
  # l must be a list of matrices coming from MTX.BasesCompositionSeries.
  local blocks,i,pos,seb,v;
  blocks := [];
  seb := rec( vectors := [], pivots := [] );
  pos := 1;
  for i in [2..Length(l)] do
      for v in l[i] do
          RECOG.CleanRow(seb,ShallowCopy(v),true,fail);
      od;
      Add(blocks,[pos..Length(seb.vectors)]);
      pos := Length(seb.vectors)+1;
  od;
  ConvertToMatrixRep(seb.vectors);
  return rec(base := seb.vectors, baseinv := seb.vectors^-1, blocks := blocks);
end;

FindHomMethodsMatrix.ReducibleIso := function(ri,G)
  # First we use the MeatAxe to find an invariant subspace:
  local H,bc,compseries,f,hom,isirred,m,newgens;

  if IsBound(ri!.isabsolutelyirred) and ri!.isabsolutelyirred then
      # this information is coming from above
      return false;
  fi;

  # FIXME:
  f := FieldOfMatrixGroup(G);
  m := GModuleByMats(GeneratorsOfGroup(G),f);
  isirred := MTX.IsIrreducible(m);
  
  # Save the MeatAxe module for later use:
  ri!.meataxemodule := m;
  # Report enduring failure if irreducible:
  if isirred then return false; fi;
  
  # Now compute a composition series:
  compseries := MTX.BasesCompositionSeries(m);
  bc := RECOG.FindAdjustedBasis(compseries);

  Info(InfoRecog,1,"Found composition series with block sizes ",
       List(bc.blocks,Length)," (dim=",DimensionOfMatrixGroup(G),")");

  # Do the base change:
  newgens := List(GeneratorsOfGroup(G),x->bc.base*x*bc.baseinv);
  H := GroupWithGenerators(newgens);
  hom := GroupHomByFuncWithData(G,H,RECOG.HomDoBaseChange,
                                rec(t := bc.base,ti := bc.baseinv));

  # Now report back:
  Sethomom(ri,hom);
  findgensNmeth(ri).method := FindKernelDoNothing;

  # Inform authorities that the factor can be recognised easily:
  forfactor(ri).blocks := bc.blocks;
  Add(forfactor(ri).hints,
      rec(method := FindHomMethodsMatrix.BlockLowerTriangular,
          rank := 2000,stamp := "BlockLowerTriangular"));

  return true;
end;

RECOG.HomOntoBlockDiagonal := function(data,el)
  local dim,i,m;
  dim := Length(el);
  m := ZeroMutable(el);
  for i in [1..Length(data.blocks)] do
      CopySubMatrix(el,m,data.blocks[i],data.blocks[i],
                         data.blocks[i],data.blocks[i]);
  od;
  return m;
end;

FindHomMethodsMatrix.BlockLowerTriangular := function(ri,G)
  # This is only used coming from a hint, we know what to do:
  # A base change was done to get block lower triangular shape.
  # We first do the diagonal blocks, then the lower p-part:
  local H,data,hom,newgens;
  data := rec( blocks := ri!.blocks );
  newgens := List(GeneratorsOfGroup(G),
                  x->RECOG.HomOntoBlockDiagonal(data,x));
  H := GroupWithGenerators(newgens);
  hom := GroupHomByFuncWithData(G,H,RECOG.HomOntoBlockDiagonal,data);
  Sethomom(ri,hom);

  # Now give hints downward:
  forfactor(ri).blocks := ri!.blocks;
  Add(forfactor(ri).hints, 
      rec( method := FindHomMethodsMatrix.BlockDiagonal,
           rank := 2000, stamp := "BlockDiagonal" ) );
  findgensNmeth(ri).method := FindKernelLowerLeftPGroup;
  findgensNmeth(ri).args := [];
  Add(forkernel(ri).hints,rec(method := FindHomMethodsMatrix.LowerLeftPGroup,
                              rank := 2000,stamp := "LowerLeftPGroup"));
  forkernel(ri).blocks := ri!.blocks;
  return true;
end;

FindHomMethodsMatrix.BlockDiagonal := function(ri,G)
  # This is only called by a hint, so we know what we have to do:
  # We do all the blocks projectively and thus are left with scalar blocks.
  # In the projective case we still do the same, the BlocksModScalars
  # will automatically take care of the projectiveness!
  local hom;
  hom := IdentityMapping(G);
  Sethomom(ri,hom);
  # Now give hints downward:
  forfactor(ri).blocks := ri!.blocks;
  Add(forfactor(ri).hints, 
      rec( method := FindHomMethodsProjective.BlocksModScalars,
           rank := 2000, stamp := "BlocksModScalars" ) );
  # We go to projective, although it would not matter here, because we
  # gave a working hint anyway:
  Setmethodsforfactor(ri,FindHomDbProjective);

  # the kernel:
  findgensNmeth(ri).args[1] := Length(ri!.blocks)+20;
  # In the projective case we have to do a trick: We use an isomorphism
  # to a matrix group by multiplying things such that the last block
  # becomes an identity matrix:
  if ri!.projective then
      Add(forkernel(ri).hints,
          rec(method := FindHomMethodsProjective.BlockScalarProj,
              rank := 2000,stamp := "BlockScalarProj"));
  else
      Add(forkernel(ri).hints,rec(method := FindHomMethodsMatrix.BlockScalar,
                                  rank := 2000,stamp := "BlockScalar"));
  fi;
  forkernel(ri).blocks := ri!.blocks;
  return true;
end;

#RECOG.HomInducedOnFactor := function(data,el)
#  local dim,m;
#  dim := Length(el);
#  m := ExtractSubMatrix(el,[data.subdim+1..dim],[data.subdim+1..dim]);
#  # FIXME: no longer necessary when vectors/matrices are in place:
#  ConvertToMatrixRep(m);
#  return m;
#end;
#
#FindHomMethodsMatrix.InducedOnFactor := function(ri,G)
#  local H,dim,gens,hom,newgens,gen,data;
#  # Are we applicable?
#  if not(IsBound(ri!.subdim)) then
#      return NotApplicable;
#  fi;
#
#  # Project onto factor:
#  gens := GeneratorsOfGroup(G);
#  dim := DimensionOfMatrixGroup(G);
#  data := rec(subdim := ri!.subdim);
#  newgens := List(gens, x->RECOG.HomInducedOnFactor(data,x));
#  H := GroupWithGenerators(newgens);
#  hom := GroupHomByFuncWithData(G,H,RECOG.HomInducedOnFactor,data); 
#
#  # Now report back:
#  Sethomom(ri,hom);
#
#  # Inform authorities that the kernel can be recognised easily:
#  forkernel(ri).subdim := ri!.subdim;
#  Add(forkernel(ri).hints,rec(method := FindHomMethodsMatrix.InducedOnSubspace,
#                              rank := 2000,stamp := "InducedOnSubspace"),1);
#
#  return true;
#end;
#
RECOG.ExtractLowStuff := function(m,layer,blocks,lens,canbas)
  local block,i,j,k,l,pos,v,what,where;
  v := ZeroVector(lens[layer],m[1]);
  pos := 0;
  i := layer+1;
  l := Length(blocks);
  # Extract the blocks with block coordinates (i,1)..(l,l-i+1):
  for j in [1..l-i+1] do
      block := [j+i-1,j];
      what := blocks[block[2]];
      for k in blocks[block[1]] do
          where := [pos+1..pos+Length(what)];
          CopySubVector(m[k],v,what,where);
          pos := pos + Length(what);
      od;
  od;
  if canbas <> fail then
      return BlownUpVector(canbas,v);
  else
      return v;
  fi;
end;

RECOG.ComputeExtractionLayerLengths := function(blocks)
  local block,i,j,l,len,lens;
  lens := [];
  l := Length(blocks);
  for i in [2..Length(blocks)] do
      len := 0;
      for j in [1..l-i+1] do
          block := [j+i-1,j];
          len := len + Length(blocks[block[1]]) * Length(blocks[block[2]]);
      od;
      Add(lens,len);
  od;
  return lens;
end;

InstallGlobalFunction( FindKernelLowerLeftPGroup,
  function(ri)
    local b,curlay,done,el,f,i,l,lens,lvec,nothingnew,pivots,pos,ready,
          rifac,s,v,x,y;
    f := FieldOfMatrixGroup(group(ri));
    if not(IsPrimeField(f)) then
        b := CanonicalBasis(f);  # a basis over the prime field
    else
        b := fail;
    fi;
    l := [];       # here we collect generators of N
    lvec := [];    # the linear part of the layer cleaned out by the gens
    pivots := [];  # pairs of numbers indicating the layer and pivot columns
                   # this will stay strictly increasing (lexicographically)
    lens := RECOG.ComputeExtractionLayerLengths(ri!.blocks);
    if b <> fail then
        lens := lens * Length(b);
    fi;

    nothingnew := 0;   # we count until we produced 10 new generators
                       # giving no new dimension
    rifac := factor(ri);
    while nothingnew < 10 do
        x := PseudoRandom( ri!.groupmem );
        s := SLPforElement(rifac,ImageElm( homom(ri), x!.el ));
        y := ResultOfStraightLineProgram(s,
                 ri!.genswithmem{[ri!.nrgensH+1..Length(ri!.genswithmem)]});
        x := x^-1 * y;   # this is in the kernel

        # In the projective case we can now have matrices with an arbitrary
        # nonzero scalar on the diagonal, we get rid of it by norming.
        # Then we can go on as in the matrix group case...
        if ri!.projective and not(IsOne(x[1][1])) then
            x := (x[1][1]^-1) * x;
        fi;

        # Now clean out this vector and remember what we did:
        curlay := 1;
        v := RECOG.ExtractLowStuff(x,curlay,ri!.blocks,lens,b);
        pos := PositionNonZero(v);
        i := 1;
        done := 0*[1..Length(lvec)];   # this refers to the current gens
        ready := false;
        while not(ready) do
            # Find out where there is something left:
            while pos > Length(v) and not(ready) do
                curlay := curlay + 1;
                if curlay <= Length(lens) then
                    v := RECOG.ExtractLowStuff(x,curlay,ri!.blocks,lens,b);
                    pos := PositionNonZero(v);
                else
                    ready := true;   # x is now equal to the identity!
                fi;
            od;
            # Either there is something left in this layer or we are done
            if ready then break; fi;

            # Clean out this layer:
            while i <= Length(l) and pivots[i][1] <= curlay do
                if pivots[i][1] = curlay then
                    # we might have jumped over a layer
                    done := -v[pivots[i][2]];
                    if not(IsZero(done)) then
                        AddRowVector(v,lvec[i],done);
                        x := x * l[i]^IntFFE(done);
                    fi;
                fi;
                i := i + 1;
            od;
            pos := PositionNonZero(v);
            if pos <= Length(v) then  # something left here!
                ready := true;
            fi;
        od;
        # Now we have cleaned out x until one of the following happened:
        #   x is the identity (<=> curlay > Length(lens))
        #   x has been cleaned up to some layer and is not yet zero
        #     in that layer (<=> pos <= Length(v))
        #     then a power of x will be a new generator in that layer and 
        #     has to be added in position i in the list of generators
        if curlay <= Length(lens) then   # a new generator
            # Now find a new pivot:
            el := v[pos]^-1;
            MultRowVector(v,el);
            x := x ^ IntFFE(el);
            Add(l,x,i);
            Add(lvec,v,i);
            Add(pivots,[curlay,pos],i);
            nothingnew := 0;
        else
            nothingnew := nothingnew + 1;
        fi;
    od;
    # Now make sure those things get handed down to the kernel:
    forkernel(ri).gensNvectors := lvec;
    forkernel(ri).gensNpivots := pivots;
    forkernel(ri).blocks := ri!.blocks;
    forkernel(ri).lens := lens;
    forkernel(ri).canonicalbasis := b;
    # this is stored on the upper level:
    SetgensN(ri,l);
    ri!.leavegensNuntouched := true;
    return true;
  end );

SLPforElementFuncsMatrix.LowerLeftPGroup := function(ri,g)
  # First project and calculate the vector:
  local done,h,i,l,layer,pow;
  # Take care of the projective case:
  if ri!.projective and not(IsOne(g[1][1])) then
      g := (g[1][1]^-1) * g;
  fi;
  l := [];
  i := 1;
  for layer in [1..Length(ri!.lens)] do
      h := RECOG.ExtractLowStuff(g,layer,ri!.blocks,ri!.lens,
                                 ri!.canonicalbasis);
      while i <= Length(ri!.gensNvectors) and ri!.gensNpivots[i][1] = layer do
          done := h[ri!.gensNpivots[i][2]];
          if not(IsZero(done)) then
              AddRowVector(h,ri!.gensNvectors[i],-done);
              pow := IntFFE(done);
              g := nicegens(ri)[i]^(-pow) * g;
              Add(l,i);
              Add(l,IntFFE(done));
          fi;
          i := i + 1;
      od;
      if not(IsZero(h)) then return fail; fi;
  od;
  if Length(l) = 0 then
      return StraightLineProgramNC([[1,0]],Length(ri!.gensNvectors));
  else
      return StraightLineProgramNC([l],Length(ri!.gensNvectors));
  fi;
end;

FindHomMethodsMatrix.LowerLeftPGroup := function(ri,G)
  local f,p;
  # Do we really have our favorite situation?
  if not(IsBound(ri!.blocks) and IsBound(ri!.lens) and 
         IsBound(ri!.canonicalbasis) and IsBound(ri!.gensNvectors) and 
         IsBound(ri!.gensNpivots)) then
      return NotApplicable;
  fi; 
  # We are done, because we can do linear algebra:
  f := FieldOfMatrixGroup(G);
  p := Characteristic(f);
  SetFilterObj(ri,IsLeaf);
  Setslpforelement(ri,SLPforElementFuncsMatrix.LowerLeftPGroup);
  SetSize(ri,p^Length(ri!.gensNvectors));
  return true;
end;
 
FindHomMethodsMatrix.GoProjective := function(ri,G)
  local hom,q;
  hom := IdentityMapping(G);
  Sethomom(ri,hom);
  # Now give hints downward:
  Setmethodsforfactor(ri,FindHomDbProjective);

  # the kernel:
  q := Size(FieldOfMatrixGroup(G));
  findgensNmeth(ri).args[1] := Length(Factors(q-1))+20;
  return true;
end;
  
#FindHomMethodsMatrix.SmallVectorSpace := function(ri,G)
#  local d,f,hom,l,method,o,q,r,v,w;
#  d := DimensionOfMatrixGroup(G);
#  # FIXME: FieldOfMatrixGroup
#  f := FieldOfMatrixGroup(G);
#  q := Size(f);
#  if q^d > 10000 then
#      return false;
#  fi;
#
#  # Now we will for sure find a rather short orbit:
#  # FIXME: adjust to new vector/matrix interface:
#  v := FullRowSpace(f,d);
#  repeat
#      w := Random(v);
#  until not(IsZero(w));
#  o := Orbit(G,w,OnRight);
#  hom := ActionHomomorphism(G,o,OnRight);
#
#  Info(InfoRecog,1,"Found orbit of length ",Length(o),".");
#  if Length(o) >= d then
#      l := Minimum(Length(o),3*d);
#      r := RankMat(o{[1..l]});
#      if r = d then
#          # We proved that it is an isomorphism:
#          findgensNmeth(ri).method := FindKernelDoNothing;
#          Info(InfoRecog,1,"Spans rowspace ==> found isomorphism.");
#      else 
#          Info(InfoRecog,2,"Rank of o{[1..3*d]} is ",r,".");
#      fi;
#  fi;
#
#  Sethomom(ri,hom);
#  Setmethodsforfactor(ri,FindHomDbPerm);
#  return true;
#end;
#  
#FindHomMethodsMatrix.IsomorphismPermGroup := function(ri,G)
#  Sethomom(ri,IsomorphismPermGroup(G));
#  findgensNmeth(ri).method := FindKernelDoNothing;
#  Setmethodsforfactor(ri,FindHomDbPerm);
#  return true;
#end;

# Looking at element orders:

SporadicsElementOrders :=
[ [ 1,2,3,5,6,7,10,11,15,19 ],[ 1,2,3,4,5,6,8,11 ],
  [ 1,2,3,4,5,6,8,10,11 ], [ 1,2,3,4,5,6,8,9,10,12,15,17,19 ],
  [ 1,2,3,4,5,6,7,8,11,14,15,23 ],[ 1,2,3,4,5,6,7,8,11 ],
  [ 1,2,3,4,5,6,7,8,10,12,15 ], [ 1,2,3,4,5,6,7,8,10,12,14,15,17,21,28 ],
  [ 1,2,3,4,5,6,7,8,10,12,13,14,15,16,20,24,26,29 ],
  [ 1,2,3,4,5,6,7,8,10,11,12,15,20 ], [ 1,2,3,4,5,6,7,8,10,11,12,14,15,21,23 ],
  [ 1,2,3,4,5,6,7,8,10,11,12,14,15,16,20,21,22,23,24,28,
      29,30,31,33,35,37,40,42,43,44,66 ],
  [ 1,2,3,4,5,6,7,8,10,11,12,14,15,16,19,20,28,31 ],
  [ 1,2,3,4,5,6,7,8,9,10,12,13,14,15,18,19,20,21,24,27, 28,30,31,36,39 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,14,15,30 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,14,15,19,20,21,22,25,30, 35,40 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,14,15,18,20,21,22,24,25,
      28,30,31,33,37,40,42,67 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,14,15,18,20,21,22,23,24,30 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,18,20,23,24,28,30 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,18,20,21,24 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,20,21,22,24,30 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,20,21,22,
      23,24,26,28,30,33,35,36,39,40,42,60 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20,21,
      22,23,24,26,27,28,30,35,36,39,42,60 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20,21,
      22,23,24,26,27,28,29,30,33,35,36,39,42,45,60 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
      21,22,23,24,25,26,27,28,30,31,32,33,34,35,36,38,39,40,
      42,44,46,47,48,52,55,56,60,66,70 ],
  [ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,
      21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,38,39,
      40,41,42,44,45,46,47,48,50,51,52,54,55,56,57,59,60,62,
      66,68,69,70,71,78,84,87,88,92,93,94,95,104,105,110,119 ] ];
SporadicsProbabilities :=
[ [ 1/175560,1/120,1/30,1/15,1/6,1/7,1/5,1/11,2/15,3/19 ],
  [ 1/7920,1/48,1/18,1/8,1/5,1/6,1/4,2/11 ],
  [ 1/95040,3/320,5/108,1/16,1/10,1/4,1/4,1/10,2/11 ],
  [ 1/50232960,1/1920,49/9720,1/96,1/15,1/24,1/8,1/9,1/5,1/12,2/15,
      2/17,2/19 ],
  [ 1/10200960,1/2688,1/180,1/32,1/15,1/12,1/7,1/8,2/11,1/7,2/15,
      2/23 ],[ 1/443520,1/384,1/36,3/32,1/5,1/12,2/7,1/8,2/11 ],
  [ 1/604800,3/640,31/1080,1/96,7/150,1/8,1/7,1/8,3/10,1/12,2/15 ],
  [ 1/4030387200,17/322560,2/945,1/84,1/300,1/18,95/4116,1/16,1/20,
      1/6,5/28,1/15,2/17,4/21,1/14 ],
  [ 1/145926144000,283/22364160,1/2160,17/5120,13/3000,1/48,1/28,
      11/192,3/40,1/8,1/52,3/28,1/15,1/8,3/20,1/12,3/52,2/29 ],
  [ 1/44352000,11/23040,1/360,19/960,17/375,5/72,1/7,3/16,1/10,2/11,
      1/12,1/15,1/10 ],
  [ 1/244823040,19/107520,11/3780,1/48,1/60,1/12,1/21,1/16,1/20,
      1/11,1/6,1/7,2/15,2/21,2/23 ],
  [ 1/86775571046077562880,13/21799895040,1/2661120,53/1576960,1/6720,
      2311/2661120,1/420,31/7680,13/960,133/31944,1/32,5/84,1/30,
      1/32,1/80,1/21,13/264,1/23,1/24,1/14,1/29,1/30,3/31,1/33,
      2/35,3/37,1/20,1/21,3/43,1/44,1/33 ],
  [ 1/460815505920,1/161280,1/3240,79/20160,1/180,1/72,29/1372,1/16,
      1/20,1/11,1/36,1/28,2/45,1/4,3/19,1/10,1/14,2/31 ],
  [ 1/90745943887872000,1/92897280,13603/1719506880,257/1935360,1/3000,
      67/25920,1/1176,5/384,5/648,1/120,25/432,1/39,1/56,1/15,5/72,
      1/19,1/20,1/21,1/6,1/9,1/28,1/15,2/31,1/12,2/39 ],
  [ 1/898128000,1/40320,31/29160,1/96,31/750,11/360,1/7,1/8,2/27,
      1/30,2/11,1/12,1/7,1/15,1/15 ],
  [ 1/273030912000000,131/473088000,59/1632960,23/46080,16913/31500000,
      1/192,1/420,9/320,1/27,431/12000,1/22,17/144,1/28,13/180,2/19,
      3/20,1/21,1/22,2/25,1/12,2/35,1/20 ],
  [ 1/51765179004000000,1/39916800,15401/2694384000,1/20160,601/2250000,
      1291/362880,1/168,1/80,1/54,73/3600,1/33,5/288,1/168,28/1125,
      1/18,1/40,1/21,1/11,1/8,1/25,1/28,1/45,5/31,2/33,2/37,1/20,
      1/21,3/67 ],
  [ 1/495766656000,179/31933440,631/2449440,1/1440,1/250,373/12960,
      1/42,1/24,1/54,1/15,1/11,1/18,1/14,1/10,1/18,1/10,1/21,1/11,
      2/23,1/12,1/30 ],
  [ 1/42305421312000,523/743178240,1/116640,139/120960,1/500,79/12960,
      1/56,5/192,1/54,1/20,1/11,2/27,5/56,1/10,1/16,1/18,1/10,
      2/23,1/12,1/28,1/10 ],
  [ 1/448345497600,151/23224320,661/1959552,103/23040,7/1800,187/10368,
      1/84,5/96,1/27,3/40,1/11,31/288,2/13,1/28,1/9,1/9,1/20,2/21,
      1/24 ],
  [ 1/64561751654400,4297/7357464576,11419/176359680,181/276480,1/600,
      9121/933120,1/42,17/384,5/108,1/24,1/11,79/864,2/13,1/14,1/30,
      1/16,7/108,1/20,1/21,1/11,1/24,1/30 ],
  [ 1/4157776806543360000,39239/12752938598400,7802083/4035109478400,
      1061/11612160,1433/15120000,198391/69672960,2/2205,79/23040,1/216,
      109/9600,1/66,10949/207360,1/156,1/42,277/5400,1/32,1/24,
      37/480,17/252,1/22,2/23,25/288,1/52,1/14,13/120,1/33,1/35,
      1/36,2/39,1/40,1/84,1/60 ],
  [ 1/4089470473293004800,407161/129123503308800,161281/148565394432,
      239/5806080,1/25200,1036823/705438720,1/840,1/128,127/17496,
      11/1200,1/44,529/12960,1/39,5/168,1/72,1/16,1/17,13/216,1/30,
      1/42,3/44,2/23,1/16,1/13,1/27,1/28,7/120,1/35,1/18,2/39,
      1/42,1/60 ],
  [ 1/1255205709190661721292800,6439/1032988026470400,144613199/
        4412392214630400,25/6967296,1/907200,159797/564350976,67/123480,
      11/4608,1189/1049760,7/4800,1/132,4741/311040,1/234,5/168,
      103/16200,1/32,1/17,11/288,1/48,17/252,1/44,2/23,7/72,1/26,
      1/27,1/28,2/29,1/24,2/33,1/35,1/24,4/117,5/84,2/45,1/60 ],
  [ 1/4154781481226426191177580544000000,
      34727139371/281639525236291462496256000,160187/10459003768012800,
      56445211/3060705263616000,1873/11088000000,7216687/1418939596800,
      1/564480,18983/123863040,5/34992,667/2688000,1/1320,12629/3732480,
      1/312,871/564480,31/3600,1/96,1/68,7/432,1/38,323/12000,1/252,
      5/264,1/23,19/432,1/25,3/104,1/27,5/224,67/1200,2/31,1/32,
      1/66,3/68,1/70,5/108,1/38,1/39,1/20,1/36,1/44,1/23,2/47,
      1/48,1/52,1/55,1/56,1/30,1/66,1/70 ],
  [ 1/808017424794512875886459904961710757005754368000000000,
      952987291/132953007399245638117682577408000000,
      1309301528411/299423045898886400305790976000,
      228177889/1608412858851262464000,361177/34128864000000000,
      352968797/83672030144102400,16369/1382422809600,80467/177124147200,
      7/18895680,1270627/532224000000,1/1045440,20669/313528320,
      31/949104,9/250880,8611/40824000,1/3072,1/2856,91/139968,1/1140,
      2323/1152000,907/370440,3/3520,1/276,167/13824,1/250,1/208,
      1/162,3/392,1/87,529/43200,1/93,1/64,5/1188,1/136,31/2100,
      1/48,1/76,25/702,49/1600,1/41,1/56,1/176,1/135,3/92,1/47,
      1/96,1/50,1/51,3/104,1/54,1/110,5/112,1/57,2/59,41/720,1/31,
      1/44,1/68,2/69,3/140,2/71,1/26,1/28,2/87,1/44,1/46,2/93,
      1/47,2/95,1/52,1/105,1/110,2/119 ] ];
SporadicsNames :=
[ "J1","M11","M12","J3","M23","M22","J2","He","Ru","HS","M24",
  "J4","ON","Th","McL","HN","Ly","Co3","Co2","Suz","Fi22","Co1",
  "Fi23","F3+","B","M" ];
SporadicsSizes :=
[ 175560, 7920, 95040, 50232960, 10200960, 443520, 604800, 4030387200, 
  145926144000, 44352000, 244823040, 86775571046077562880, 460815505920, 
  90745943887872000, 898128000, 273030912000000, 51765179004000000, 
  495766656000, 42305421312000, 448345497600, 64561751654400, 
  4157776806543360000, 4089470473293004800, 1255205709190661721292800, 
  4154781481226426191177580544000000, 
  808017424794512875886459904961710757005754368000000000 ];
SporadicsKillers :=
[ ,,,,,,,,,,,,,,,,,,,,[[18..22]],[[26..32],[25..32]],
  [[28..32],[27..32]],[[27..35],[29..35],[27,29,34]], # the latter is for Fi23
  [[31..49],[40,41,42,43,44,45,46,48,49]],   # the latter is against Fi23
  [[32..73],[61..73]] ];
SporadicsWorkers := [];
SporadicsWorkers[2] := SporadicsWorkerGenSift;   # M11
SporadicsWorkers[3] := SporadicsWorkerGenSift;   # M12
SporadicsWorkers[6] := SporadicsWorkerGenSift;   # M22
SporadicsWorkers[7] := SporadicsWorkerGenSift;   # J2
SporadicsWorkers[10] := SporadicsWorkerGenSift;  # HS
SporadicsWorkers[17] := SporadicsWorkerGenSift;  # Ly
SporadicsWorkers[18] := SporadicsWorkerGenSift;  # Co3
SporadicsWorkers[19] := SporadicsWorkerGenSift;  # Co2
LastRecognisedSporadic := fail;

FindHomMethodsMatrix.LookAtOrders := function(ri,G)
  local i,j,jj,k,killers,l,limit,o,ordersseen,pp,raus,res,x;
  l := [1..26];
  pp := 0*[1..26];
  ordersseen := [];
  for i in [1..120] do
      x := PseudoRandom(G);
      o := Order(x);
      AddSet(ordersseen,o);
      Info(InfoRecog,2,"Found order: ",String(o,3)," (element #",i,")");
      l := Filtered(l,i->o in SporadicsElementOrders[i]);
      if l = [] then
          LastRecognisedSporadic := fail;
          return false;
      fi;
      # Throw out improbable ones:
      j := 1;
      while j <= Length(l) do
          if Length(l) = 1 then
              limit := 1/1000;
          else
              limit := 1/400;
          fi;
          jj := l[j];
          raus := false;
          for k in [1..Length(SporadicsElementOrders[jj])] do
              if not(SporadicsElementOrders[jj][k] in ordersseen) and
                 (1-SporadicsProbabilities[jj][k])^i < limit then
                  Info(InfoRecog,2,"Have thrown out ",SporadicsNames[jj],
                       " (did not see order ",
                       SporadicsElementOrders[jj][k],")");
                  raus := true;
                  break;
              fi;
          od;
          if not(raus) and IsBound(SporadicsKillers[jj]) then
            for killers in SporadicsKillers[jj] do
              if Intersection(ordersseen,SporadicsElementOrders[jj]{killers})=[]
                 and (1-Sum(SporadicsProbabilities[jj]{killers}))^i < 10^-5 then
                  raus := true;
                  break;
                  Info(InfoRecog,2,"Have thrown out ",SporadicsNames[jj],
                       " (did not see orders in ",
                       SporadicsElementOrders[jj]{killers},")");
              fi;
            od;
          fi;
          if raus then
              Remove(l,j);
          else
              j := j + 1;
          fi;
      od;
      if l = [] then
          LastRecognisedSporadic := fail;
          return false;
      fi;
      if Length(l) = 1 and i > 80 then
          Info(InfoRecog,1,"I guess that this is the sporadic simple ",
               "group ",SporadicsNames[l[1]],".");
          res := LookupHintForSimple(ri,G,SporadicsNames[l[1]]);
          if res = true then return res; fi;
          if IsBound(SporadicsWorkers[l[1]]) then
              Info(InfoRecog,1,"Calling its installed worker...");
              return SporadicsWorkers[l[1]](SporadicsNames[l[1]],
                                            SporadicsSizes[l[1]],ri,G);
          fi;
          Info(InfoRecog,1,"However, I cannot verify this.");
          LastRecognisedSporadic := SporadicsNames[l[1]];
          return false;
      fi;
      if Length(l) < 6 then
          Info(InfoRecog,2,"Possible sporadics left: ",
               SporadicsNames{l});
      else
          Info(InfoRecog,2,"Possible sporadics left: ",Length(l));
      fi;
  od;
  Info(InfoRecog,1,"Giving up, still possible Sporadics: ",
       SporadicsNames{l});
  LastRecognisedSporadic := fail;
  return false;
end;

AddMethod( FindHomDbMatrix, FindHomMethodsMatrix.TrivialMatrixGroup,
  1200, "TrivialMatrixGroup",
        "check whether all generators are equal to the identity matrix" );
AddMethod( FindHomDbMatrix, FindHomMethodsMatrix.DiagonalMatrices,
  1100, "DiagonalMatrices",
        "check whether all generators are multiples of the identity" );
AddMethod( FindHomDbMatrix, FindHomMethodsMatrix.ReducibleIso,
  1000, "ReducibleIso",
        "use the MeatAxe to find invariant subspaces" );
AddMethod( FindHomDbMatrix, FindHomMethodsMatrix.GoProjective,
   900, "GoProjective",
        "divide out scalars and recognise projectively" );

###AddMethod( FindHomDbMatrix, FindHomMethodsMatrix.SmallVectorSpace,
###           700, "SmallVectorSpace",
###           "for small vector spaces directly compute an orbit" );
###AddMethod( FindHomDbMatrix, FindHomMethodsMatrix.LookAtOrders,
###           600, "LookAtOrders",
###           "generate a few random elements, calculate LCM of orders" );

