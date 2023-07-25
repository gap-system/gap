#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Derek Holt, Sarah Rees, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the 'Smash'-MeatAxe modified for GAP4 and using the
##  standard MeatAxe interface.  It defines the MeatAxe SMTX.
##

InstallGlobalFunction(GModuleByMats,function(arg)
local l,f,dim,m;
  l:=arg[1];
  if Length(arg)=1 then
    Error("Usage: GModuleByMats(<mats>,[<id>,]<field>)");
  fi;
  f:=arg[Length(arg)];
  if Length(l)>0 and Characteristic(l[1])<>Characteristic(f) then
      Error("matrices and field do not fit together");
  fi;
  l:=List(l,i->ImmutableMatrix(f,i));

  if ForAny(l,i->Length(i)<>Length(i[1])) or
    Length(Set(l,Length))>1 then
    Error("<l> must be a list of square matrices of the same dimension");
  fi;
  m:=rec(field:=f,
         isMTXModule:=true);
  if Length(l)>0 then
    dim:=Length(l[1][1]);
  elif Length(arg)=2 then
    Error("if no generators are given the dimension must be given explicitly");
  else
    dim:=arg[2];
    l:=[ ImmutableMatrix(f, IdentityMat(dim,f) ) ];
    m.smashMeataxe:=rec(isZeroGens:=true);
  fi;
  m.dimension:=dim;
  m.generators:=MakeImmutable(l);
  m.IsOverFiniteField:= Size(f)<>infinity and IsFFECollCollColl(l);
  return m;
end);

# variant of Value: if we evaluate the polynomial `f` at a matrix `x`, then it
# is usually beneficial to first factor `f` and evaluate at the factors
BindGlobal("SMTX_Value",function(f,x,one)
local fa;
  fa:=Factors(f);
  if Length(fa)>1 then
    return Product(List(Collected(fa),y->Value(y[1],x,one)^y[2]),one);
  else
    return Value(f,x,one);
  fi;
end);

#############################################################################
##
#F  TrivialGModule( g, F ) . . . trivial G-module
##
##  g is a finite group, F a field, trivial smash G-module computed.
InstallGlobalFunction(TrivialGModule,function(g, F)
local mats;
  mats:=List(GeneratorsOfGroup(g),i->[[One(F)]]);
  return GModuleByMats(mats,F);
end);

#############################################################################
##
#F  InducedGModule( g, h, m ) . . . calculate an induced G-module
##
## h should be a subgroup of a finite group g, and m a smash
## GModule for h.
## The induced module for g is calculated.
InstallGlobalFunction(InducedGModule,function(g, h, m)
   local  gensh, mats, ghom, gdim, hdim, F, index, gen, genim,
         gensim, r, i, j, k, l, elt, im;

   if IsGroup(g) = false then
      return Error("First argument is not a group.");
   fi;
   if SMTX.IsMTXModule(m) = false then
      return Error("Second argument is not a meataxe module.");
   fi;

   gensh:=GeneratorsOfGroup(h);
   mats:=SMTX.Generators(m);
   if Length(gensh) <> Length(mats) then
      Error("m does not have same number of generators as h = G1");
   fi;

   hdim:=SMTX.Dimension(m);
   F:=SMTX.Field(m);
   if Characteristic(F)=0 then
       ghom:=GroupHomomorphismByImagesNC(h,Group(mats),gensh,mats);
   else
       ghom:=GroupHomomorphismByImages(h,GL(hdim,F),gensh,mats);
   fi;

   # set up transveral
   r:=RightTransversal(g, h);
   index:=Length(r);

   gdim:=index*hdim;

   # Now calculate images of generators.
   gensim:=[];
   for gen in GeneratorsOfGroup(g) do
      genim:=NullMat(gdim, gdim, F);
      for i in [1..index] do
         j:=PositionCanonical(r, r[i]*gen);
         elt:=r[i]*gen/r[j];
         im:=Image(ghom, elt);
         # Now insert hdim x hdim matrix im in the correct place in the genim.
         for k in [1..hdim] do
            for l in [1..hdim] do
               genim[ (i-1)*hdim+k][ (j-1)*hdim+l]:=im[k][l];
            od;
         od;
      od;
      Add(gensim, genim);
   od;

   return GModuleByMats(gensim, F);

end);

#############################################################################
##
#F PermutationGModule( g, F) . permutation module
##
## g is a permutation group, F a field.
## The corresponding permutation module is output.
InstallGlobalFunction(PermutationGModule,function(g, F)
   local gens, deg;
   gens:=GeneratorsOfGroup(g);
   deg:=LargestMovedPoint(gens);
   return GModuleByMats(List(gens,g->PermutationMat(g,deg,F)),F);
end);

###############################################################################
##
#F  TensorProductGModule( m1, m2 )  . . tensor product of two G-modules
##
## TensorProductGModule calculates the tensor product of smash
## modules m1 and m2.
## They are assumed to be modules over the same algebra so, in particular,
## they  should have the same number of generators.
##
InstallGlobalFunction(TensorProductGModule,function( m1, m2)
   local mat1, mat2, F1, F2,  gens, i, l;

   mat1:=SMTX.Generators(m1); mat2:=SMTX.Generators(m2);
   F1:=SMTX.Field(m1); F2:=SMTX.Field(m2);
   if F1 <> F2 then
      Error("GModules are defined over different fields.\n");
   fi;
   l:=Length(mat1);
   if l <> Length(mat2) then
      Error("GModules have different numbers of generators.");
   fi;

   gens:=[];
   for i in [1..l] do
      gens[i]:=KroneckerProduct(mat1[i], mat2[i]);
   od;

   return GModuleByMats(gens, F1);
end);

###############################################################################
##
#F  WedgeGModule( module ) . . . . . wedge product of a G-module
##
## WedgeGModule calculates the wedge product of a G-module.
## That is the action on antisymmetrix tensors.
##
InstallGlobalFunction(WedgeGModule,function( module)
   local mats, mat, newmat, row, F, gens, dim, nmats, i, j, k, m, n, x;

   mats:=SMTX.Generators(module);
   F:=SMTX.Field(module);
   nmats:=Length(mats);
   dim:=SMTX.Dimension(module);

   gens:=[];
   for i in [1..nmats] do
      mat:=mats[i];
      newmat:=[];
      for j in [1..dim] do
         for k in [1..j - 1] do
            row:=[];
            for m in [1..dim] do
               for n in [1..m - 1] do
                  x:=mat[j][m] * mat[k][n] - mat[j][n] * mat[k][m];
                  Add(row, x);
               od;
            od;
            Add(newmat, row);
         od;
      od;
      Add(gens, newmat);
   od;

   return GModuleByMats(gens, F);
end);

SMTX.Setter:=function(string)
  MakeImmutable(string);
  return function(module,obj)
    if not IsBound(module.smashMeataxe) then
      module.smashMeataxe:=rec();
    fi;
    module.smashMeataxe.(string):=obj;
  end;
end;

SMTX.IsMTXModule:=function(module)
  return IsBound(module.isMTXModule) and
         IsBound(module.field) and
         IsBound(module.generators) and
         IsBound(module.dimension);
end;

SMTX.IsZeroGens:=function(module)
  return IsBound(module.smashMeataxe)
     and IsBound(module.smashMeataxe.isZeroGens)
     and module.smashMeataxe.isZeroGens=true;
end;

SMTX.Dimension:=function(module)
  return module.dimension;
end;

SMTX.Field:=function(module)
  return module.field;
end;

SMTX.Generators:=function(module)
  if SMTX.IsZeroGens(module) then
    return [];
  else
    return module.generators;
  fi;
end;

SMTX.SetIsIrreducible:=function(module,b)
  module.IsIrreducible:=b;
end;

SMTX.HasIsIrreducible:=function(module)
  return IsBound(module.IsIrreducible);
end;


SMTX.IsAbsolutelyIrreducible:=function(module)
  if not IsBound(module.IsAbsolutelyIrreducible) then
    if not SMTX.IsIrreducible(module) then
      return false;
    fi;
    module.IsAbsolutelyIrreducible:=SMTX.AbsoluteIrreducibilityTest(module);
  fi;
  return module.IsAbsolutelyIrreducible;
end;

SMTX.SetIsAbsolutelyIrreducible:=function(module,b)
  module.IsAbsolutelyIrreducible:=b;
end;

SMTX.HasIsAbsolutelyIrreducible:=function(module)
  return IsBound(module.IsAbsolutelyIrreducible);
end;

SMTX.SetSmashRecord:=SMTX.Setter("dummy");
SMTX.Subbasis:=SMTX.Getter("subbasis");
SMTX.SetSubbasis:=SMTX.Setter("subbasis");
SMTX.AlgEl:=SMTX.Getter("algebraElement");
SMTX.SetAlgEl:=SMTX.Setter("algebraElement");
SMTX.AlgElMat:=SMTX.Getter("algebraElementMatrix");
SMTX.SetAlgElMat:=SMTX.Setter("algebraElementMatrix");
SMTX.AlgElCharPol:=SMTX.Getter("characteristicPolynomial");
SMTX.SetAlgElCharPol:=SMTX.Setter("characteristicPolynomial");
SMTX.AlgElCharPolFac:=SMTX.Getter("charpolFactors");
SMTX.SetAlgElCharPolFac:=SMTX.Setter("charpolFactors");
SMTX.AlgElNullspaceVec:=SMTX.Getter("nullspaceVector");
SMTX.SetAlgElNullspaceVec:=SMTX.Setter("nullspaceVector");
SMTX.AlgElNullspaceDimension:=SMTX.Getter("ndimFlag");
SMTX.SetAlgElNullspaceDimension:=SMTX.Setter("ndimFlag");

SMTX.CentMat:=SMTX.Getter("centMat");
SMTX.SetCentMat:=SMTX.Setter("centMat");
SMTX.CentMatMinPoly:=SMTX.Getter("centMatMinPoly");
SMTX.SetCentMatMinPoly:=SMTX.Setter("centMatMinPoly");

SMTX.FGCentMat:=SMTX.Getter("fieldGenCentMat");
SMTX.SetFGCentMat:=SMTX.Setter("fieldGenCentMat");
SMTX.FGCentMatMinPoly:=SMTX.Getter("fieldGenCentMatMinPoly");
SMTX.SetFGCentMatMinPoly:=SMTX.Setter("fieldGenCentMatMinPoly");

SMTX.SetDegreeFieldExt:=SMTX.Setter("degreeFieldExt");


#############################################################################
##
#F  SMTX.OrthogonalVector( subbasis ) single vector othogonal to a submodule,
##  N.B. subbasis is assumed to consist of normed vectors,
##  submodule is assumed proper.
##
SMTX.OrthogonalVector:=function( subbasis )
   local zero, one, v, i, j, k, x, dim, len;
   subbasis:=ShallowCopy(subbasis);
   Sort(subbasis);
   subbasis:=Reversed(subbasis);
   # Now subbasis is in order so that the vector whose leading coefficient
   # comes furthest to the left comes first.
   len:=Length(subbasis);
   dim:=Length(subbasis[1]);
   i:= 1;
   v:=[];
   one:=One(subbasis[1][1]);
   zero:=Zero(one);
   for i in [1..dim] do
      v[i]:=zero;
   od;
   i:=1;
   while i <= len and subbasis[i][i] = one do
      i:= i + 1;
   od;
   v[i]:=one;
   for j in Reversed([1..i-1]) do
      x:=zero;
      for k in [j + 1..i] do
         x:=x + v[k] * subbasis[j][k];
      od;
      v[j]:=-x;
   od;

   return v;
end;

BindGlobal( "SubGModLeadPos", function(sub,dim,subdim,zero)
local leadpos,i,j,k;
   ## As in SpinnedBasis, leadpos[i] gives the position of the first nonzero
   ## entry (which will always be 1) of sub[i].

   leadpos:=[];
   for i in [1..subdim] do
      j:=1;
      while j <= dim and sub[i][j]=zero do j:=j + 1; od;
      leadpos[i]:=j;
      for k in [1..i - 1] do
         if leadpos[k] = j then
            Error("Subbasis isn't normed.");
         fi;
      od;
   od;
  return leadpos;
end );

#############################################################################
##
#F  SpinnedBasis( v, matrices, F, [ngens] ) . . . .
##
## The first argument v  can either be a vector over the module on
## which matrices act or a subspace.
##
## SpinnedBasis computes a basis for the submodule defined by the action of the
## matrix group generated by the list matrices on v.
## F is the field over which we act.
## It is returned as a list of normed vectors.
## If the optional third argument is present, then only the first ngens
## matrices in the list are used.
SMTX.SpinnedBasis:=function( arg  )
   local   v, matrices, ngens, zero,ldim,step,
           ans, dim, subdim, leadpos, w, i, j, k, l, m,F;

   if Length(arg) < 3 or Length(arg) > 4 then
      Error("Usage:  SpinnedBasis( v, matrices, F, [ngens] )");
   fi;
   v:=arg[1];
   matrices:=arg[2];
   F:=arg[3];
   if Length(arg) = 4 then
      ngens:=arg[4];
      if ngens <= 0 or ngens > Length(matrices) then
         ngens:=Length(matrices);
      fi;
   else
      ngens:=Length(matrices);
   fi;
   ans:=[];
   zero:=Zero(matrices[1][1][1]);
   if IsList(v) and Length(v)=0 then
     return [];
   elif IsMatrix(v) then
     v:= TriangulizedMat(v);
     ans:=Filtered(v,x->not IsZero(x));
   elif IsList(v) and IsVectorObj(v[1]) then
     v:=TriangulizedMat(Matrix(F,v));
     ans:=Filtered(List(v),x->not IsZero(x));
   else
     # single vector (as vector or list)
     ans:=[v];
   fi;


   #ans:=ShallowCopy(Basis(VectorSpace(F,v)));

   ans:=Filtered(ans,x->not IsZero(x));
   if Length(ans)=0 then return ans; fi;
   ans:=List(ans, v -> ImmutableVector(F,v));
   dim:=Length(ans[1]);
   subdim:=Length(ans);
   ldim:=subdim;
   step:=10;
   leadpos:=SubGModLeadPos(ans,dim,subdim,zero);
   for i in [1..Length(ans)] do
     w:=ans[i];
     j:=w[PositionNonZero(w)];
     if not IsOne(j) then
       ans[i]:=j^-1*ans[i];
     fi;
   od;

   i:=1;
   while i <= subdim do
      for l in [1..ngens] do
         m:=matrices[l];
         # apply generator m to submodule generator i
         w:=ShallowCopy(ans[i] * m);
         # try to express w in terms of existing submodule generators
         j:=1;
         for  j in [1..subdim] do
            k:=w[leadpos[j]];
            if k <> zero then
               #w:=w - k * ans[j];
               AddRowVector(w,ans[j],-k);
            fi;
         od;

         j:=1;
         while j <= dim and w[j] = zero do j:=j + 1; od;
         if j <= dim then
            # we have found a new generator of the submodule
            subdim:=subdim + 1;
            leadpos[subdim]:=j;
            #w:=(w[j]^-1) * w;
            MultVector(w,w[j]^-1);
            Add( ans, w );
            if subdim = dim then
               ans:=ImmutableMatrix(F,ans);
               return ans;
            fi;
            if subdim-ldim>step then
              Info(InfoMeatAxe,4,"subdimension ",subdim);
              ldim:=subdim;
              if ldim>10*step then step:=step*3;fi;
            fi;
         fi;
      od;
      i:=i + 1;
   od;

   Sort(ans);
   ans:=Reversed(ans); # To bring it into semi-echelonised form.
   ans:=ImmutableMatrix(F,ans);
   return ans;
end;

SMTX.SubGModule:=function(module, subspace)
## The submodule of module generated by <subspace>.
  return SMTX.SpinnedBasis(subspace, SMTX.Generators(module),
                                    SMTX.Field(module));
end;

SMTX.SubmoduleGModule:=SMTX.SubGModule;

#############################################################################
##
#F  SMTX.SubQuotActionsModule(matrices,sub,dim,subdim,field,typ) . . .
##  generators of sub- and quotient-module and original module wrt new basis
##
##  IT IS ASSUMED THAT THE GENERATORS OF SUB ARE NORMED.
##
##  this function is used to compute all submodule/quotient stuff, as
##  indicated by  typ: 1=Sub, 2=Quotient, 4=Common
##  The function returns a record with components 'smatrices', 'qmatrices',
##  'nmatrices' and 'nbasis' if applicable.
##
##  See the description for 'SMTX.InducedAction' for
##  description of the matrices
##
SMTX.SubQuotActions:=function(matrices,sub,dim,subdim,F,typ)
local s, c, q, leadpos, zero, zerov, smatrices, newg, im, newim, k, subi,
      qmats, smats, nmats, sr, qr, g, h, erg, i, j;

  s:=(typ mod 2)=1; # subspace indicator
  typ:=QuoInt(typ,2);
  q:=(typ mod 2)=1; # quotient indicator
  c:=typ>1; # common indicator

  zero:=Zero(F);
  leadpos:=SubGModLeadPos(sub,dim,subdim,zero);

  if subdim*2<dim and not (q or c) then
    # the subspace dimension is small and we only want the subspace action:
    # performing a base change is too expensive

    zerov:=ListWithIdenticalEntries(subdim,zero);
    ConvertToVectorRep(zerov,F);

    smatrices:=[];
    for g in matrices do
      newg:=[];
      for i in [1..subdim] do
        im:=ShallowCopy(sub[i] * g);
        newim:=ShallowCopy(zerov);
        for j in [1..subdim] do
          k:=im[leadpos[j]];
          if k<> zero then
            newim[j]:=k;
            AddRowVector(im,sub[j],-k);
          fi;
        od;

        # Check that the vector is now zero - if not, then sub was
        # not the basis of a submodule
        if im <> Zero(im) then return fail; fi;
        Add(newg, newim);
      od;
      Add(smatrices,ImmutableMatrix(F,newg));
    od;
    return rec(smatrices:=smatrices);
  else
    # we want the quotient or all or the subspace dimension is big enough to
    # merit a basechange

    # first extend the basis
    sub:=List(sub);
    Append(sub,List(One(matrices[1])){Difference([1..dim],leadpos)});
    sub:=ImmutableMatrix(F,sub);
    subi:=sub^-1;
    qmats:=[];
    smats:=[];
    nmats:=[];
    sr:=[1..subdim];qr:=[subdim+1..dim];
    for g in matrices do
      g:=sub*g*subi;
      if s then
        h:=ExtractSubMatrix(g,sr,sr);
        h:=ImmutableMatrix(F,h);
        Add(smats,h);
      fi;
      if q then
        h:=ExtractSubMatrix(g,qr,qr);
        h:=ImmutableMatrix(F,h);
        Add(qmats,h);
      fi;
      if c then Add(nmats,g);fi;
    od;
    erg:=rec();
    if s then
      erg.smatrices:=smats;
    fi;
    if q then
      erg.qmatrices:=qmats;
    fi;
    if c then
      erg.nmatrices:=nmats;
    fi;
    if q or c then
      erg.nbasis:=sub;
    fi;
    return erg;
  fi;
end;



#############################################################################
##
##  SMTX.NormedBasisAndBaseChange(sub)
##
##  returns a list [bas,change] where bas is a normed basis for <sub> and
##  change is the base change from bas to sub (the basis vectors of bas
##  expressed in coefficients for sub)
SMTX.NormedBasisAndBaseChange:=function(sub)
local l,m,d;
  l:=Length(sub);
  d:=Length(sub[1]);
  m:= IdentityMat(d,One(sub[1][1]));
  sub:=List([1..l],i->Concatenation(ShallowCopy(sub[i]),m[i]));
  TriangulizeMat(sub);
  m:=d+l;
  return [sub{[1..l]}{[1..d]},sub{[1..l]}{[d+1..m]}];
end;

#############################################################################
##
#F  SMTX.InducedActionSubmoduleNB( module, sub ) . . . . construct submodule
##
## module is a module record, and sub is a list of generators of a submodule.
## IT IS ASSUMED THAT THE GENERATORS OF SUB ARE NORMED.
## (i.e. each has leading coefficient 1 in a unique place).
## SMTX.InducedActionSubmoduleNB( module, sub ) computes the submodule of
## module for which sub is the basis.
## If sub does not generate a submodule then fail is returned.
SMTX.InducedActionSubmoduleNB:=function( module, sub )
   local   ans, dim, subdim, smodule,F;

   subdim:=Length(sub);
   if subdim = 0 then
      return List(module.generators,i->[[]]);
   fi;
   dim:=SMTX.Dimension(module);
   F:=SMTX.Field(module);

   ans:=SMTX.SubQuotActions(module.generators,sub,dim,subdim,F,1);

   if ans=fail then
     return fail;
   fi;

   if SMTX.IsZeroGens(module) then
     smodule:=GModuleByMats([],Length(ans.smatrices[1]),F);
   else
     smodule:=GModuleByMats(ans.smatrices,F);
   fi;
   return smodule;
end;

# Ditto, but allowing also unnormed modules
SMTX.InducedActionSubmodule:=function(module,sub)
local nb,ans,dim,subdim,smodule,F;
  nb:=SMTX.NormedBasisAndBaseChange(sub);
  sub:=nb[1];
  nb:=nb[2];

   subdim:=Length(sub);
   if subdim = 0 then
      return List(module.generators,i->[[]]);
   fi;
   dim:=SMTX.Dimension(module);
   F:=SMTX.Field(module);

   ans:=SMTX.SubQuotActions(module.generators,
                                sub,dim,subdim,F,1);

   if ans=fail then
     return fail;
   fi;

   # conjugate the matrices to correspond to given sub
   if SMTX.IsZeroGens(module) then
     smodule:=GModuleByMats([],Length(ans.smatrices[1]),F);
   else
    smodule:=GModuleByMats(List(ans.smatrices,i->i^nb),F);
   fi;
   return smodule;
end;

SMTX.ProperSubmoduleBasis:=function(module)
  if SMTX.IsIrreducible(module) then
    return fail;
  fi;
  return SMTX.Subbasis(module);
end;


#############################################################################
##
#F  SMTX.InducedActionFactorModule( module, sub [,compl] )
##
## module is a module record, and sub is a list of generators of a submodule.
## (i.e. each has leading coefficient 1 in a unique place).
## Qmodule is returned, where qmodule
## is the quotient module.
##
SMTX.InducedActionFactorModule:=function(arg)
local module,sub,  ans, dim, subdim, F,qmodule;

   module:=arg[1];
   sub:=arg[2];

   sub:=TriangulizedMat(sub);

   subdim:=Length(sub);
   dim:=SMTX.Dimension(module);
   if subdim = dim then
      return List(module.generators,i->[[]]);
   fi;

   F:=SMTX.Field(module);

   ans:=SMTX.SubQuotActions(module.generators,
                                sub,dim,subdim,F,2);

   if ans=fail then
     return fail;
   fi;

   if Length(arg)=3 then
     # compute basechange
     sub:=Concatenation(sub,arg[3]);
     sub:=sub*Inverse(ans.nbasis);
     ans.qmatrices:=List(ans.qmatrices,i->i^sub);
   fi;

   if SMTX.IsZeroGens(module) then
     qmodule:=GModuleByMats([],Length(ans.qmatrices[1]),F);
   else
    qmodule:=GModuleByMats(ans.qmatrices, F);
   fi;
   return qmodule;

end;

#############################################################################
##
#F  SMTX.InducedActionFactorModuleWithBasis( module, sub )
##
# FIXME: this function is never used and documented. Keep it or remove it?
SMTX.InducedActionFactorModuleWithBasis:=function(module,sub)
local ans, dim, subdim, F,qmodule;

   sub:=TriangulizedMat(sub);

   subdim:=Length(sub);
   dim:=SMTX.Dimension(module);
   if subdim = dim then
      return List(module.generators,i->[[]]);
   fi;

   F:=SMTX.Field(module);

   ans:=SMTX.SubQuotActions(module.generators,
                                sub,dim,subdim,F,2);

   if ans=fail then
     return fail;
   fi;

   # fetch new basis
   sub:=ans.nbasis{[Length(sub)+1..module.dimension]};

   if SMTX.IsZeroGens(module) then
     qmodule:=GModuleByMats([],Length(ans.qmatrices[1]),F);
   else
    qmodule:=GModuleByMats(ans.qmatrices, F);
   fi;
   return [qmodule,sub];

end;

#############################################################################
##
#F  SMTX.InducedAction( module, sub, typ )
##  generators of sub- and quotient-module and original module wrt new basis
##  and new basis
##
## module is a module record, and sub is a list of generators of a submodule.
## IT IS ASSUMED THAT THE GENERATORS OF SUB ARE NORMED.
## (i.e. each has leading coefficient 1 in a unique place).
## SMTX.InducedAction computes the submodule and quotient
## and the original module with its matrices written wrt to the basis used
## to compute smodule and qmodule.
## [smodule, qmodule, nmodule] is returned,
## where smodule is the submodule and qmodule the quotient module.
## The matrices of nmodule have the form  A  0  where  A  and  B  are the
##                                        C  B
## corresponding matrices of smodule and qmodule resepctively.
## If sub is not the basis of a submodule then fail is returned.
SMTX.InducedAction:=function( arg )
local module,sub,typ,ans,dim,subdim,F,erg;

   module:=arg[1];
   sub:=arg[2];
   if Length(arg)>2 then
     typ:=arg[3];
   else
     typ:=7;
   fi;
   subdim:=Length(sub);
   dim:=SMTX.Dimension(module);
   F:=SMTX.Field(module);

   erg:=SMTX.SubQuotActions(module.generators,
                                sub,dim,subdim,F,typ);

   if erg=fail then
     return fail;
   fi;

   ans:=[];

   if IsBound(erg.smatrices) then
     if SMTX.IsZeroGens(module) then
       Add(ans,GModuleByMats([],Length(erg.smatrices[1]), F));
     else
       Add(ans,GModuleByMats(erg.smatrices, F));
     fi;
   fi;
   if IsBound(erg.qmatrices) then
     if SMTX.IsZeroGens(module) then
       Add(ans,GModuleByMats([],Length(erg.qmatrices[1]), F));
     else
       Add(ans,GModuleByMats(erg.qmatrices, F));
     fi;
   fi;
   if IsBound(erg.nmatrices) then
     if SMTX.IsZeroGens(module) then
       Add(ans,GModuleByMats([],Length(erg.nmatrices[1]), F));
     else
       Add(ans,GModuleByMats(erg.nmatrices, F));
     fi;
   fi;
   if IsBound(erg.nbasis) then
     Add(ans,erg.nbasis);
   fi;

   return ans;

end;

#############################################################################
##
#F  SMTX.InducedActionSubMatrixNB( mat, sub ) . . . . construct submodule
##
##  as InducedActionSubmoduleNB but for a matrix.
# FIXME: this function is never used and documented. Keep it or remove it?
SMTX.InducedActionSubMatrixNB:=function( mat, sub )
local subdim, dim, F, ans;

   subdim:=Length(sub);
   if subdim = 0 then
      return [];
   fi;
   dim:=Length(mat);
   F:=DefaultFieldOfMatrix(mat);

   ans:=SMTX.SubQuotActions([mat],sub,dim,subdim,F,1);

   if ans=fail then
     return fail;
   else
     return ans.smatrices[1];
   fi;

end;

# Ditto, but allowing also unnormed modules
# FIXME: this function is never used and documented. Keep it or remove it?
SMTX.InducedActionSubMatrix:=function(mat,sub)
local nb, subdim, dim, F, ans;
  nb:=SMTX.NormedBasisAndBaseChange(sub);
  sub:=nb[1];
  nb:=nb[2];

   subdim:=Length(sub);
   if subdim = 0 then
      return [];
   fi;
   dim:=Length(mat);
   F:=DefaultFieldOfMatrix(mat);

   ans:=SMTX.SubQuotActions([mat],sub,dim,subdim,F,1);

   if ans=fail then
     return fail;
   else
    # conjugate the matrices to correspond to given sub
     return ans.smatrices[1]^nb;
   fi;

end;

#############################################################################
##
#F  SMTX.InducedActionFactorMatrix( mat, sub [,compl] )
##
##  as InducedActionFactor, but for a matrix.
##
SMTX.InducedActionFactorMatrix:=function(arg)
local mat, sub, subdim, dim, F, ans;

   mat:=arg[1];
   sub:=arg[2];

   sub:=TriangulizedMat(sub);

   subdim:=Length(sub);
   dim:=Length(mat);
   if subdim = dim then
      return [];
   fi;

   F:=DefaultFieldOfMatrix(mat);

   ans:=SMTX.SubQuotActions([mat],sub,dim,subdim,F,2);

   if ans=fail then
     return fail;
   fi;

   if Length(arg)=3 then
     # compute basechange
     sub:=Concatenation(sub,arg[3]);
     sub:=sub*Inverse(ans.nbasis);
     ans.qmatrices:=List(ans.qmatrices,i->i^sub);
   fi;

   return ans.qmatrices[1];

end;

SMTX.SMCoRaEl:=function(matrices,ngens,newgenlist,dim,F)
local g1,g2,coefflist,M,pol;
  g1:=Random(1, ngens);
  g2:=g1;
  while g2=g1 and ngens>1 do
     g2:=Random(1, ngens);
  od;
  ngens:=ngens + 1;
  matrices[ngens]:=matrices[g1] * matrices[g2];
  Add(newgenlist, [g1, g2]);
  # Take a random linear sum of the existing generators as new generator.
  # Record the sum in coefflist
  coefflist:=[Random(F)];
  M:=coefflist[1]*matrices[1];
  for g1 in [2..ngens] do
     g2:=Random(F);
     if IsOne(g2) then
       M:=M + matrices[g1];
     elif not IsZero(g2) then
       M:=M + g2 * matrices[g1];
     fi;
     Add(coefflist, g2);
  od;
  Info(InfoMeatAxe,3,"Evaluated random element in algebra.");
  pol:=CharacteristicPolynomialMatrixNC(F,M,1);
  return [M,coefflist,pol];
end;

# how many random elements should we try before (temporarily ) giving up?
# This number is set relatively high to minimize the chance of an unlucky
# random run in functions such as composition series computation.
SMTX.RAND_ELM_LIMIT:=5000;

#############################################################################
##
#F  SMTX.IrreduciblityTest( module ) try to reduce a module over a finite
##                                      field
##
## 27/12/2000.
## New version incorporating Ivanyos/Lux method of handling one difficult case
## for proving reducibility.
## (See G.Ivanyos and K. Lux, `Treating the exceptional cases of the meataxe',
##  Experimental Mathematics 9, 2000, 373-381.
##
## module is a module record
## IsIrreducible( ) attempts to decide whether module is irreducible.
## When it succeeds it returns true or false.
## We choose at random elements of the group algebra of the group.
## If el is such an element, we define M, p, fac, N, e and v as follows:-
## M is the matrix corresponding to el, p is its characteristic polynomial,
## fac an irreducible factor of p, N the nullspace of the matrix fac(M),
## ndim the dimension of N, and v a vector in N.
## If we can find the above such that ndim = deg(fac) then we can test
## conclusively for irreducibility. Then, in the case where irreducibility is
## proved, we store the information as fields for the module, since it may be
## useful later (e.g. to test for absolute irreducibility, equivalence with
## another module).
## These  fields are accessed by the functions
## AlgEl()(el), AlgElMat(M), AlgElCharPol(p),
## AlgElCharPolFac(fac), AlgElNullspaceDimension(ndim), and
## AlgElNullspaceVec(v).
##
## If we cannot find such a set with ndim = deg(fac) we may nonetheless prove
## reducibility  by finding a submodule. However we can never prove
## irreducibility without such a set (and hence the algorithm could run
## forever, but hopefully this will never happen!)
## Where reducibility is proved, we set the field .subbasis
## (a basis for the submodule, normed in the sense that the first non-zero
## component of each basis vector is 1, and is in a different position from
## the first non-zero component of every other basis vector).
## The test for irreducibility is based on the meataxe method (but in the
## meataxe, ndim is always very small, usually 1. The modification here is put
## in to enable the method to work over modules with large centralizing fields).
## We simply spin v. If we do not get  the whole space, we have a submodule,
## on the other hand, if we do get the whole space, we calculate the
## nullspace NT of the transpose of fac(M), spin that under the group
## generated by the transposes of the generating matrices, and thus either
## find the transpose of a submodule or conclusively prove irreducibility.
##
## This function can also be used to get a random submodule. Therefore it
## is not an end-user function but only called internally
SMTX.IrreducibilityTest:=function( module )
   local matrices, tmatrices, ngens, ans,  M, mat, g1, g2, maxdeg,
         newgenlist, coefflist, orig_ngens, zero,
         N, NT, v, subbasis, fac, sfac, pol, orig_pol, q, dim, ndim, i,
         l, trying, deg, facno, bestfacno, F, count, R, rt0,idmat,
         pfac1, pfac2, quotRem, pfr, idemp, M2, mat2, mat3;

   rt0:=Runtime();
   #Info(InfoMeatAxe,1,"Calling MeatAxe. All times will be in milliseconds");
   if not SMTX.IsMTXModule(module) then
      Error("Argument of IsIrreducible is not a module.");
   fi;

   if not module.IsOverFiniteField then
      Error("Argument of IsIrreducible is not over a finite field.");
   fi;
   matrices:=ShallowCopy(module.generators);
   dim:=SMTX.Dimension(module);
   ngens:=Length(matrices);
   orig_ngens:=ngens;
   F:=SMTX.Field(module);
   zero:=Zero(F);
   R:=PolynomialRing(F);

   # Now compute random elements M of the group algebra, calculate their
   # characteristic polynomials, factorize, and apply the irreducible factors
   # to M to get matrices with nontrivial nullspaces.
   # tmatrices will be a list of the transposed generators if required.

   tmatrices:=[];
   trying:=true;
   # trying will become false when we have an answer
   maxdeg:=1;
   newgenlist:=[];
   # Do a small amount of preprocessing to increase the generator set.
   for i in [1..1] do
      g1:=Random(1, ngens);
      g2:=g1;
      while g2=g1 and Length(matrices) > 1 do
         g2:=Random(1, ngens);
      od;
      ngens:=ngens + 1;
      matrices[ngens]:=matrices[g1] * matrices[g2];
      Add(newgenlist, [g1, g2]);
   od;
   Info(InfoMeatAxe,4,"Done preprocessing. Time = ",Runtime()-rt0,".");
   count:=0;

   # Main loop starts - choose a random element of group algebra on each pass
   while trying  do
      count:=count + 1;
      if count mod SMTX.RAND_ELM_LIMIT = 0 then
         Error("Have generated ",SMTX.RAND_ELM_LIMIT,
                "random elements and failed to prove\n",
                "or disprove irreducibility. Type return to keep trying.");
      fi;
      maxdeg:=Minimum(maxdeg * 2,dim);
      # On this pass, we only consider irreducible factors up to degree maxdeg.
      # Using higher degree factors is very time consuming, so we prefer to try
      # another element.
      # To choose random element, first add on a new generator as a product of
      # two randomly chosen unequal existing generators
      # Record the product in newgenlist.
      Info(InfoMeatAxe,3,"Choosing random element number ",count);

      M:=SMTX.SMCoRaEl(matrices,ngens,newgenlist,dim,F);

      ngens:=Length(matrices);

      coefflist:=M[2];
      pol:=M[3];
      M:=ImmutableMatrix(F,M[1]);
      idmat:=M^0;

      orig_pol:=pol;
      Info(InfoMeatAxe,3,"Evaluated characteristic polynomial. Time = ",
           Runtime()-rt0,".");
      # Now we extract the irreducible factors of pol starting with those
      # of low degree
      deg:=0;
      fac:=[];
      # The next loop is through the degrees of irreducible factors
      while DegreeOfLaurentPolynomial(pol) > 0 and deg < maxdeg and trying do
         repeat
            deg:=deg + 1;
            if deg > Int(DegreeOfLaurentPolynomial(pol) / 2) then
               fac:=[pol];
            else
               fac:=Factors(R, pol: factoroptions:=rec(onlydegs:=[deg]));
               fac:=Filtered(fac,i->DegreeOfLaurentPolynomial(i)=deg);
               Info(InfoMeatAxe,3,Length(fac)," factors of degree ",deg,
                    ", Time = ",Runtime()-rt0,".");
            fi;
         until fac <> [] or deg = maxdeg;

         if fac <> [] then
            if DegreeOfLaurentPolynomial(fac[1]) = dim then
               # In this case the char poly is irreducible, so the
               # module is irreducible.
               ans:=true;
               trying:=false;
               bestfacno:=1;
               v:=ListWithIdenticalEntries(dim,zero);
               v[1]:=One(F);
               ndim:=dim;
            fi;
            # Otherwise, first see if there is a non-repeating factor.
            # If so it will be decisive, so delete the rest of the list
            l:=Length(fac);
            facno:=1;
            while facno <= l and trying do
               if facno = l  or  fac[facno] <> fac[facno + 1] then
                  fac:=[fac[facno]]; l:=1;
               else
                  while facno < l and fac[facno] = fac[facno + 1] do
                     facno:=facno + 1;
                  od;
               fi;
               facno:=facno + 1;
            od;
            # Now we can delete repetitions from the list fac
            sfac:=Set(fac);

            if DegreeOfLaurentPolynomial(fac[1]) <> dim then
               # Now go through the factors and attempt to find a submodule
               facno:=1; l:=Length(sfac);
               while facno <= l and trying do
                  mat:=SMTX_Value(sfac[facno], M,idmat);
                  Info(InfoMeatAxe,5,"Evaluated matrix on factor. Time = ",
                       Runtime()-rt0,".");
                  N:=NullspaceMat(mat);
                  v:=N[1];
                  ndim:=Length(N);

                  Info(InfoMeatAxe,5,"Evaluated nullspace. Dimension = ",
                       ndim,". Time = ",Runtime()-rt0,".");
                  subbasis:=SMTX.SpinnedBasis(v, matrices, F,orig_ngens);
                  Info(InfoMeatAxe,5,"Spun up vector. Dimension = ",
                       Length(subbasis),". Time = ",Runtime()-rt0,".");
                  if Length(subbasis) < dim then
                     # Proper submodule found
                     trying:=false;
                     ans:=false;
                     SMTX.SetSubbasis(module, subbasis);
                  elif ndim = deg then
                     trying:=false;
                     # if we transpose and find no proper submodule, then the
                     # module is definitely irreducible.
                     mat:=TransposedMat(mat);
                     if Length(tmatrices)=0 then
                        for i in [1..orig_ngens] do
                           Add(tmatrices, TransposedMat(matrices[i]));
                        od;
                     fi;
                     Info(InfoMeatAxe,5,"Transposed matrices. Time = ",
                          Runtime()-rt0,".");
                     NT:=NullspaceMat(mat);
                     Info(InfoMeatAxe,5,"Evaluated nullspace. Dimension = ",
                          Length(NT),". Time = ",Runtime()-rt0, ".");
                     subbasis:=SMTX.SpinnedBasis(NT[1],tmatrices,F,orig_ngens);
                     Info(InfoMeatAxe,5,"Spun up vector. Dimension = ",
                          Length(subbasis),". Time = ",Runtime()-rt0, ".");
                     if Length(subbasis) < dim then
                        # subbasis is a basis for a submodule of the transposed
                        # module, and the orthogonal complement of this is a
                        # submodule of the original module. So we find a vector
                        # v in that, and then spin it. Of course we won't
                        # necessarily get the full orthogonal complement
                        # that way, but we'll certainly get a proper submodule.
                        v:=SMTX.OrthogonalVector(subbasis);
                        SMTX.SetSubbasis(module,
                          SMTX.SpinnedBasis(v,matrices,F,orig_ngens));
                        ans:=false;
                     else
                        ans:=true;
                        bestfacno:=facno;
                     fi;
                  fi;
                  if trying and deg>1 and count>2 then
                     Info(InfoMeatAxe,3,"Trying Ivanyos/Lux Method");
                     # first find the appropriate idempotent
                     pfac1:=sfac[facno];
                     pfac2:=orig_pol;
                     while true do
                       quotRem := QuotRemLaurpols(pfac2, sfac[facno], 3);
                       if quotRem[2] <> Zero(R) then
                         break;
                       fi;
                       pfac2 := quotRem[1];
                       pfac1:=pfac1*sfac[facno];
                     od;
                     pfr:=GcdRepresentation(pfac1, pfac2);
                     idemp:=QuotRemLaurpols(pfr[2]*pfac2, orig_pol, 2);
                     # Now another random element in the group algebra.
                     # and a random vector in the module
                     g2:=Random(F);
                     if IsOne(g2) then
                       M2:=matrices[1];
                     else
                       M2:=g2 * matrices[1];
                     fi;
                     for g1 in [2..ngens] do
                        g2:=Random(F);
                        if IsOne(g2) then
                          M2:=M2 + matrices[g1];
                        elif not IsZero(g2) then
                          M2:=M2 + g2 * matrices[g1];
                        fi;
                     od;
                     Info(InfoMeatAxe,5,
                         "Evaluated second random element in algebra.");
                     v:=Random(FullRowSpace(F,dim));
                     mat2:=SMTX_Value(idemp, M,idmat);
                     mat3:=mat2*M2*mat2;
                     v:=v*(M*mat3 - mat3*M);
                     # This vector might lie in a proper subspace!
                     subbasis:=SMTX.SpinnedBasis(v, matrices, F,orig_ngens);
                     Info(InfoMeatAxe,5,"Spun up vector. Dimension = ",
                       Length(subbasis),". Time = ",Runtime()-rt0,".");
                     if Length(subbasis) < dim and Length(subbasis) <> 0  then
                       # Proper submodule found
                       trying:=false;
                       ans:=false;
                       SMTX.SetSubbasis(module, subbasis);
                    fi;
                  fi;
                  facno:=facno + 1;
               od; # going through irreducible factors of fixed degree.
               # If trying is false at this stage, then we don't have
               # an answer yet, so we have to go onto factors of the next degree.
               # Now divide p by the factors used if necessary
               if trying and deg < maxdeg then
                  for q in fac do
                     pol:=Quotient(R, pol, q);
                  od;
               fi;
            fi;           #DegreeOfLaurentPolynomial(fac[1]) <> dim
         fi;             #fac <> []
      od; # loop through degrees of irreducible factors

      # if we have not found a submodule and trying is false, then the module
      # must be irreducible.
      if trying = false and ans = true then
         SMTX.SetAlgEl(module, [newgenlist, coefflist]);
         SMTX.SetAlgElMat(module, M);
         SMTX.SetAlgElCharPol(module, orig_pol);
         SMTX.SetAlgElCharPolFac(module, sfac[bestfacno]);
         SMTX.SetAlgElNullspaceVec(module, v);
         SMTX.SetAlgElNullspaceDimension(module, ndim);
      fi;

   od;  # main loop

   Info(InfoMeatAxe,4,"Total time = ",Runtime()-rt0," milliseconds.");
   return ans;

end;


SMTX.IsIrreducible:=function(module)
  if not IsBound(module.IsIrreducible) then
    module.IsIrreducible:=SMTX.IrreducibilityTest(module);
  fi;
  return module.IsIrreducible;
end;

#############################################################################
##
#F SMTX.RandomIrreducibleSubGModule( module ) . . .
## find a basis for a random irreducible
## submodule of module, and return that basis and the submodule, with all
## the irreducibility flags set.
## Returns false if module is irreducible.
SMTX.RandomIrreducibleSubGModule:=function( module )
   local  ranSub, subbasis, submodule, subbasis2, submodule2,
   F, el, M, fac, N, i, matrices, ngens, genpair;

   if not SMTX.IsMTXModule(module) then
      return Error("Argument of RandomIrreducibleSubGModule is not a module.");
   elif SMTX.HasIsIrreducible(module) and SMTX.IsIrreducible(module) then
      return false;
   fi;

   # now call an irreducibility test that will compute a new subbasis

   i:=SMTX.IrreducibilityTest(module);

   if i then
     # we just found out it is irreducible
     SMTX.SetIsIrreducible(module,true);
     return false;
   elif not SMTX.HasIsIrreducible(module) then
     # or store reducibility
     SMTX.SetIsIrreducible(module,false);
   fi;

   subbasis:=SMTX.Subbasis(module);
   submodule:=SMTX.InducedActionSubmoduleNB(module, subbasis);
   ranSub:=SMTX.RandomIrreducibleSubGModule(submodule);
   if ranSub = false then
      # submodule has been proved irreducible in a call to this function,
      # so the flags have been set.
      return [ subbasis, submodule];
   else
      # ranSub[1] is given in terms of the basis for the submodule,
      # but we want it in terms of the basis of the original module.
      # So we multiply it by subbasis.
      # Then we need our basis to be normed.
      # this is done by triangulization
      F:=SMTX.Field(module);
      subbasis2:=ranSub[1] * subbasis;
      subbasis2:=TriangulizedMat(subbasis2);

      # But now since we've normed the basis subbasis2,
      # the matrices of the submodule ranSub[2] are given with respect to
      # the wrong basis.  So we have to recompute the submodule.
      submodule2:=SMTX.InducedActionSubmoduleNB(module, subbasis2);
      # Unfortunately, although it's clear that this submodule is
      # irreducible, we'll have to reset the flags that IsIrreducible sets.
      # AH Why can't we keep irreducibility?

      # Some will be the same # as in ranSub[2], but some are affected by
      # the base change, or at least part of it, since the flags gets
      # screwed up by the base change.
      # We need to set the following flags:
      el:=SMTX.AlgEl(ranSub[2]);
      SMTX.SetAlgEl(submodule2,el);
      SMTX.SetAlgElCharPol(submodule2,SMTX.AlgElCharPol(ranSub[2]));
      fac:=SMTX.AlgElCharPolFac(ranSub[2]);
      SMTX.SetAlgElCharPolFac(submodule2,fac);
      SMTX.SetAlgElNullspaceDimension(submodule2,
             SMTX.AlgElNullspaceDimension(ranSub[2]));

      # Only the actual algebra element and its nullspace have to be recomputed
      # This code is essentially from IsomorphismGModule
      matrices:=ShallowCopy(submodule2.generators);
      ngens:=Length(matrices);
      for genpair in el[1] do
         ngens:=ngens + 1;
         matrices[ngens]:=matrices[genpair[1]] * matrices[genpair[2]];
      od;
      M:=ImmutableMatrix(F,Sum([1..ngens], i-> el[2][i] * matrices[i]));
      SMTX.SetAlgElMat(submodule2,M);
      N:=NullspaceMat(SMTX_Value(fac,M,M^0));
      SMTX.SetAlgElNullspaceVec(submodule2,N[1]);
      return [subbasis2, submodule2];
   fi;

end;

#############################################################################
##
#F  SMTX.GoodElementGModule( module ) . .  find good group algebra element
##                                       in an irreducible module
##
## module is a module that is already known to be irreducible.
## GoodElementGModule finds a group algebra element with nullspace of
## minimal possible dimension. This dimension is 1 if the module is absolutely
## irreducible, and the degree of the relevant field extension otherwise.
## This is needed for testing for equivalence of modules.
SMTX.GoodElementGModule:=function( module )
local matrices, ngens, M, mat,  N, newgenlist, coefflist,
      fac, pol, oldpol,  q, deg, i, l,
      trying, dim, mindim, F, R, count, rt0, idmat;

   rt0:=Runtime();
   if not SMTX.IsMTXModule(module) or not SMTX.IsIrreducible(module) then
     ErrorNoReturn("Argument is not an irreducible module.");
   fi;
   if not SMTX.HasIsAbsolutelyIrreducible(module) then
      SMTX.IsAbsolutelyIrreducible(module);
   fi;
   if  SMTX.IsAbsolutelyIrreducible(module) then
     mindim:=1;
   else
     mindim:=SMTX.DegreeFieldExt(module);
   fi;

   if SMTX.AlgElNullspaceDimension(module) = mindim then return; fi;
   # This is the condition that we want. If it holds already, then there is
   # nothing else to do.

   dim:=SMTX.Dimension(module);
   matrices:=ShallowCopy(module.generators);
   ngens:=Length(matrices);
   F:=SMTX.Field(module);
   R:=PolynomialRing(F);

   # Now compute random elements el of the group algebra, calculate their
   # characteristic polynomials, factorize, and apply the irreducible factors
   # to el to get matrices with nontrivial nullspaces.

   trying:=true;
   count:=0;
   newgenlist:=[];
   while trying do
      count:=count + 1;
      if count mod SMTX.RAND_ELM_LIMIT = 0 then
         Error("Have generated ",SMTX.RAND_ELM_LIMIT,
                " random elements and failed ",
                "to find a good one. Type return to keep trying.");
      fi;
      Info(InfoMeatAxe,5,"Choosing random element number ",count,".");

      M:=SMTX.SMCoRaEl(matrices,ngens,newgenlist,dim,F);
      ngens:=Length(matrices);

      coefflist:=M[2];
      pol:=M[3];
      M:=M[1];
      idmat:=M^0;

      Info(InfoMeatAxe,4,"Evaluated characteristic polynomial. Time = ",
           Runtime()-rt0,".");
      # That is necessary in case p is defined over a smaller field that F.
      oldpol:=pol;
      # Now we extract the irreducible factors of pol starting with those
      # of low degree
      deg:=0;
      fac:=[];
      while deg  <= mindim and trying do
         repeat
            deg:=deg + 1;
            if deg > mindim then
               fac:=[pol];
            else
               fac:=Factors(R, pol: factoroptions:=rec(onlydegs:=[deg]));
               fac:=Filtered(fac,i->DegreeOfLaurentPolynomial(i)<=deg);
               Info(InfoMeatAxe,4,Length(fac)," factors of degree ",deg,
                    ", Time = ",Runtime()-rt0,".");
            fi;
         until fac <> [];
         l:=Length(fac);
         if trying and deg <= mindim then
            i:=1;
            while i <= l and trying do
               mat:=SMTX_Value(fac[i], M,idmat);
               Info(InfoMeatAxe,5,"Evaluated matrix on factor. Time = ",
                    Runtime()-rt0,".");
               N:=NullspaceMat(mat);
               Info(InfoMeatAxe,5,"Evaluated nullspace. Dimension = ",
                    Length(N),". Time = ",Runtime()-rt0,".");
               if Length(N) = mindim then
                  trying:=false;
                  SMTX.SetAlgEl(module, [newgenlist, coefflist]);
                  SMTX.SetAlgElMat(module, M);
                  SMTX.SetAlgElCharPol(module, oldpol);
                  SMTX.SetAlgElCharPolFac(module, fac[i]);
                  SMTX.SetAlgElNullspaceVec(module, N[1]);
                  SMTX.SetAlgElNullspaceDimension(module, Length(N));
               fi;
               i:=i + 1;
            od;
         fi;

         if trying then
            for q in fac do
               pol:=Quotient(R, pol, q);
            od;
         fi;
      od;
   od;
   Info(InfoMeatAxe,5,"Total time = ",Runtime()-rt0," milliseconds.");

end;

#############################################################################
##
#F  EnlargedIrreducibleGModule(module, mat) . .add a generator to a module that
#
# 2bdef!


#############################################################################
##
#F  SMTX.FrobeniusAction(A, v [, basis]) . . action of matrix A on
##                                  . . Frobenius block of vector v
##
## FrobeniusAction(A, v) computes the Frobenius block of the dxd matrix A
## generated by the length - d vector v, and returns it.
## It is based on code of MinPolCoeffsMat.
## The optional third argument is for returning the basis for this block.
##
SMTX.FrobeniusAction:=function( arg )
local   L, d, p, M, one, zero, R, h, v, w, i, j, nd, ans,
        A, basis,fld;

   fld:=arg[1];
   A:=arg[2];
   v:=arg[3];
   if Length(arg) = 3  then
      basis:=0;
   elif Length(arg) = 4  then
      basis:=arg[4];
   else
      return Error("usage: SMTX.FrobeniusAction(<F>, <A>, <v>, [, <basis>] )");
   fi;
   one :=One(A[1][1]);
   zero:=Zero(one);
   d:=Length( A );
   M:=ListWithIdenticalEntries(Length(A[1]) + 1,zero);
   M:=ImmutableVector(fld,M);
   v:=ImmutableVector(fld,v);
   A:=ImmutableMatrix(fld,A);

   # L[i] (length d) will contain a vector with head entry 1 at position i,
   # which is in the current block.
   # R[i] (length d + 1 but (d + 1) - entry always 0) is vector expressing
   # L[i] in terms of the basis of the block.
   L:=[];
   R:=[];

   # <j> - 1 gives the power of <A> we are looking at
   j:=1;

   # spin vector around and construct polynomial
   repeat

      # compute the head of <v>
      h:=1;
      while v[h] = zero  do
         h:=h + 1;
      od;

      # start with appropriate polynomial x^(<j> - 1)
      p:=ShallowCopy( M );
      p[j]:=one;

      # divide by known left sides
      w:=v;
      while h <= d and IsBound( L[h] ) do
         p:=p - w[h] * R[h];
         w:=w - w[h] * L[h];
         while h <= d and w[h] = zero do
            h:=h + 1;
         od;
      od;

      # if <v> is not the zero vector try next power
      if h <= d  then
         #AH replaced Copy by ShallowCopy as only vector is used
         if basis <> 0 then basis[j]:=ShallowCopy(v); fi;

         R[h]:=p * w[h]^-1;
         L[h]:=w * w[h]^-1;
         j:=j + 1;
         v:=v * A;
      fi;
   until h > d;

   nd:=Length(p);
   while 0 < nd  and p[nd] = zero  do
      nd:=nd - 1;
   od;
   nd:=nd - 1;
   ans:=[];
   for i in [1..nd - 1] do
      ans[i]:=[];
      for j in [1..nd] do ans[i][j]:=zero; od;
      ans[i][i + 1]:=one;
   od;
   ans[nd]:=[];
   for j in [1..nd] do
      ans[nd][j]:= - p[j];
   od;

   return ans;
end;

#############################################################################
##
#F SMTX.CompleteBasis(matrices,basis) . complete a basis under a group action
##
##  CompleteBasis( matrices, basis ) takes the partial basis 'basis' of the
##  underlying space of the (irreducible) module defined by matrices, and
##  attempts to extend it to a complete basis which is a direct sum of
##  translates of the original subspace under group elements. It returns
##  true or false according to whether it succeeds.
##  It is called by IsAbsolutelyIrreducible()
##
SMTX.CompleteBasis:=function( matrices, basis )
local  L, d, subd, subd0, zero, h, v, w, i, bno, gno, vno, newb, ngens;

   subd:=Length(basis);
   subd0:=subd;
   d:=Length( basis[1] );
   if d = subd then
      return true;
   fi;
   # L is list of normalized generators of the subspace spanned by basis.
   L:=[];
   zero:=Zero(basis[1][1]);
   ngens:=Length(matrices);

   # First find normalized generators for subspace itself.
   for i in [1..subd] do
      v:=basis[i];
      h:=1;
      while v[h] = zero  do
         h:=h + 1;
      od;
      w:=v;
      while h <= d and IsBound( L[h] )  do
         w:=w - w[h] * L[h];
         while h <= d and w[h] = zero  do
            h:=h + 1;
         od;
      od;
      if h <= d then
         L[h]:=w * w[h]^-1;
      else
         return Error("Initial vectors are not linearly independent.");
      fi;
   od;

   # Now start translating
   bno:=1; gno:=1; vno:=1;
   while subd < d do
      # translate vector vno of block bno by generator gno
      v:= basis[ (bno - 1) * subd0 + vno] * matrices[gno];
      h:=1;
      while h<=d and v[h] = zero  do
         h:=h + 1;
      od;
      w:=v;
      while h <= d and IsBound( L[h] )  do
         w:=w - w[h] * L[h];
         while h <= d and w[h] = zero  do
            h:=h + 1;
         od;
      od;
      if h <= d then
         # new generator (and block)
         if vno = 1 then
            newb:=true;
         elif newb = false then
            return false;
         fi;
         L[h]:=w * w[h]^-1;
         subd:=subd + 1;
         basis[subd]:=v;
      else
         # in existing subspace
         if vno = 1 then
            newb:=false;
         elif newb = true then
            return false;
         fi;
      fi;
      vno:=vno + 1;
      if vno > subd0 then
         vno:=1;
         gno:=gno + 1;
         if gno > ngens then
            gno:=1;
            bno:=bno + 1;
         fi;
      fi;
   od;

   return true;
end;

#############################################################################
##
#F SMTX.AbsoluteIrreducibilityTest( module ) . . decide if an irreducible
##                    module over a  finite field is absolutely irreducible
##
## this function does the work for an absolute irreducibility test but does
## not actually set the flags.
## The function calculates the centralizer of the module.
## The centralizer should be isomorphic to the multiplicative
## group of the field GF(q^e) for some e, or rather to the group of
## dim/e x dim/e scalar matrices over GF(q^e), or equivalently,
## dim x dim matrices composed of identical e x e blocks along the diagonal.
##  e = 1 <=> the module is absolutely irreducible.
## The .fieldExtDeg component is set to e during the function call.
## The function shouldn't be called if the module has not already been
## shown to be irreducible, using IsIrreducible.
##
SMTX.AbsoluteIrreducibilityTest:=function( module )
local dim, ndim, gcd, div, e, ct, F, q, ok,
      M, v, M0, v0, C, C0, centmat, one, zero,
      pow, matrices, newmatrices, looking,
      basisN, basisB, basisBN, P, Pinv, i, j, k, nblocks;

   if not SMTX.IsMTXModule(module) then
      Error("Argument of IsAbsoluteIrreducible is not a module");
   fi;

   if not SMTX.IsIrreducible(module) then
      Error("Argument of iIsAbsoluteIrreducible s not an irreducible module");
   fi;

   if not module.IsOverFiniteField then
      return Error("Argument of IsAbsoluteIrreducible is not over a finite field.");
   fi;
   dim:=SMTX.Dimension(module);
   F:=SMTX.Field(module);
   q:=Size(F);
   matrices:=module.generators;

   # M acts irreducibly on N, which is canonically defined with respect to M
   # as the nullspace of fac(M), where fac is a factor of the char poly of M.
   # ndim is the dimension of N, and v is a vector of N. All these come from
   # the irreducibility test for the module.
   # An element of the centralizer must centralize every element, and
   # therefore M, and so must preserve N, since N is canonically defined
   # wrt M. Our plan is therefore first to find an element which centralizes
   # the restriction of M to N, and then extend it to the whole space.

   M:=SMTX.AlgElMat(module);
   ndim:=SMTX.AlgElNullspaceDimension(module);
   v:=SMTX.AlgElNullspaceVec(module);

   # e will have to divide both dim and ndim, and hence their gcd.
   gcd:=GcdInt(dim, ndim);
   Info(InfoMeatAxe,4,"GCD of module and nullspace dimensions = ", gcd, ".");
   if gcd = 1 then
      SMTX.SetDegreeFieldExt(module,1);
      return true;
   fi;
   div:=DivisorsInt(gcd);

   # It's easy to find elements  in the centralizer of an element in Frobenius
   # (=rational canonical) form (centralizing elements are defined by their
   # action on the first basis element).
   # M0  is the Frobenius form for the action of M on N.
   # basisN is set by the function SMTX.FrobeniusAction to be the
   # basis v, vM, vM^2, .. for N

   basisN:=[];
   Info(InfoMeatAxe,4,
     "Calc. Frobenius action of element from group algebra on nullspace.");
   M0:=SMTX.FrobeniusAction(F,M,v,basisN);

   zero:=Zero(F);
   one:= One(F);
   v0:=ListWithIdenticalEntries(Length(M0[1]),zero);
   v0[1]:=one;
   ConvertToVectorRep(v0, F);

   # v0 is just the vector (1, 0, 0....0) of length ndim. It has nothing
   # in particular to do with M0[1], but multiplying a vector that happens to be
   # around by 0 is a good way to get a zero vector of the right length.

   # we try all possible divisors of gcd (biggest first) as possibilities for e
   # We're looking for a centralizing element with order dividing q^e - 1, and
   # blocks size e on N.
   for ct in Reversed([2..Length(div)]) do
      e:=div[ct];
      Info(InfoMeatAxe,4,"Trying dimension ",e," for centralising field.");
      # if ndim = e, M0 will do.
      if ndim > e then
         C:=M0;
         # Take the smallest power of C guaranteed to have order dividing
         # q^e - 1, and try that.
         pow:=(q^ndim - 1) / (q^e - 1);
         Info(InfoMeatAxe,4,"Looking for a suitable centralising element.");
         repeat
            # The first time through the loop C is M0, otherwise we choose C
            # at random from the centralizer of M0. Since M0 is in Frobenius
            # form any centralising element is determined by its top row
            # (which may be anything but the zero vector).

            if Length(C)=0 then
               C[1]:=[];
               repeat
                  ok:=0;
                  for i in [1..ndim] do
                     C[1][i]:=Random(F);
                     if C[1][i] <> zero then  ok:=1; fi;
                  od;
               until ok=1;
               for i in [2..ndim] do C[i]:=C[i - 1] * M0; od;
               C:=ImmutableMatrix(F,C);
            fi;
            # C0 is the Frobenius form for the action of this power on one
            # of its blocks, B (all blocks have the same size). basisBN will
            # be set to be a basis for B, in terms of the elements of basisN.
            # A matrix product gives us the basis for B in terms of the
            # original basis for the module.
            basisBN:=[];
            C0:=SMTX.FrobeniusAction(F,C^pow,v0,basisBN);
            C:=[];
         until Length(C0) = e;
         Info(InfoMeatAxe,5,"Found one.");
         basisB:=List(
           ImmutableMatrix(F,basisBN) *
          ImmutableMatrix(F,basisN));
      else
         C0:=M0;
         basisB:=ShallowCopy(basisN);
      fi;
      C0:=ImmutableMatrix(F,C0);
      # Now try to extend basisB to a basis for the whole module, by
      # translating it by the generating matrices.
      Info(InfoMeatAxe,4,"Trying to extend basis to whole module.");
      if SMTX.CompleteBasis(matrices,basisB) then
         # We succeeded in extending the basis (might not have done).
         # So now we have a full basis, which we think of now as a base
         # change matrix.
         Info(InfoMeatAxe,4,"Succeeded. Calculating centralising matrix.");
         newmatrices:=[];
         P:=ImmutableMatrix(F,basisB);
         Pinv:=P^-1;
         for i in [1..Length(matrices)] do
            newmatrices[i]:=P * matrices[i] * Pinv;
         od;
         # Make the sum of copies of C0 as centmat
         centmat:=NullMat(dim, dim, F);
         nblocks:=dim/e;
         for i in [1..nblocks] do
            for j in [1..e] do
               for k in [1..e] do
                  centmat[ (i - 1) * e + j][ (i - 1) * e + k]:=C0[j][k];
               od;
            od;
         od;
         centmat := ImmutableMatrix(F, centmat);
         Info(InfoMeatAxe,2,"Checking that it centralises the generators.");
         # Check centralizing.
         looking:=true;
         i:=1;
         while looking and i <= Length(newmatrices) do
            if newmatrices[i] * centmat <> centmat * newmatrices[i] then
               looking:=false;
            fi;
            i:=i + 1;
         od;
         if looking then
            Info(InfoMeatAxe,2,"It did!");
            SMTX.SetDegreeFieldExt(module, e);
            SMTX.SetCentMat(module, Pinv * centmat * P); # get the base right
            # We will also record the minimal polynomial of C0 (and hence of
            # centmat) in case we need it at some future date.
            SMTX.SetCentMatMinPoly(module, MinimalPolynomial(F,C0,1));
            return false;
         fi;
         Info(InfoMeatAxe,2,"But it didn't.");
      else
         Info(InfoMeatAxe,2,"Failed!");
      fi;
   od;

   Info(InfoMeatAxe,2,
     "Tried all divisors. Must be absolutely irreducible.");
   SMTX.SetDegreeFieldExt(module, 1);
   return true;
end;

SMTX.DegreeFieldExt:=function(module)
  if not IsBound(module.smashMeataxe.degreeFieldExt) then
    SMTX.AbsoluteIrreducibilityTest( module );
  fi;
  return module.smashMeataxe.degreeFieldExt;
end;

SMTX.DegreeSplittingField:=function(module)
  return DegreeOverPrimeField(SMTX.Field(module))
         *SMTX.DegreeFieldExt(module);
end;

#############################################################################
##
#F  FieldGenCentMat( module ) . . find a centralizing matrix that generates
##                                the centralizing field of an irred. module
##
## FieldGenCentMat( ) should only be applied to modules that have already
## been proved irreducible using IsIrreducible. It then tests for absolute
## irreducibility (if not already known) and does nothing if module is
## absolutely irreducible. Otherwise, it returns a matrix that generates
## (multiplicatively) the centralizing field (i.e. its multiplicative order
## is q^e - 1, where e is the degree of the centralizing field. This is not
## yet used, but maybe in future, if we wish to reduce the group to matrices
## over the larger field.
SMTX.FieldGenCentMat:=function( module )
   local e, F, R, q, qe, minpol, pp,
         centmat, newcentmat, genpol, looking,
         okd;

  if SMTX.FGCentMat(module)=fail then
    if SMTX.IsMTXModule(module) = false then
      Error("Argument of IsIrreducible is not a module.");
    fi;

    if not SMTX.IsIrreducible(module) then
      Error("GModule is not irreducible.");
    fi;

    # enforce absirred knowledge as well.
    #if not SMTX.IsAbsolutelyIrreducible(module) then
    #  Error("GModule is not absolutely irreducible.");
    #fi;

    if SMTX.CentMat(module)=fail then
      Error("No CentMat component!");
    fi;

    F:=SMTX.Field(module);
    R:=PolynomialRing(F);
    q:=Size(F);
    e :=SMTX.DegreeFieldExt(module);
    qe:=q^e - 1;
    minpol:=SMTX.CentMatMinPoly(module);
    # Factorise q^e - 1
    pp:=PrimePowersInt(qe);
    # We seek a generator of the field of order q^e - 1. In other words, a
    # polynomial genpol of degree e, which has multiplicative order q^e - 1
    # modulo minpol. We first try the polynomial x, which is the element we
    # have already. If this does not work, then we try random nonconstant
    # polynomials until we find one with the right order.

    genpol:=Indeterminate(F);

    looking:=true;
    while looking do
      if genpol <> minpol then
      okd:=FFPOrderKnownDividend(R, genpol, minpol, pp);
      if okd[1] * Order(One(F)*okd[2]) = qe then
          looking:=false;
      fi;
      fi;
      if looking then
          repeat
            genpol:=RandomPol(F, e,1);
          until DegreeOfUnivariateLaurentPolynomial(genpol) > 0;
          genpol:=StandardAssociate(R, genpol);
      fi;
    od;
    # Finally recalculate centmat and its minimal polynomial.
    centmat:=SMTX.CentMat(module);
    newcentmat:=SMTX_Value(genpol, centmat,centmat^0);
    SMTX.SetFGCentMat(module, newcentmat);
    SMTX.SetFGCentMatMinPoly(module,MinimalPolynomialMatrixNC(F,newcentmat,1));
    # Ugh! That was very inefficient - should work out the min poly using
    # polynomials, but will sort that out if its ever needed.
  fi;
  return SMTX.FGCentMat(module);
end;

###############################################################################
##
#F  SMTX.CollectedFactors( module ) . . find composition factors of a module
##
## 01/01/01 Try to deal more efficiently with large numbers of repeated
## small factors by using SMTX.Homomorphisms
##
## SMTX.CollectedFactors calls IsIrreducible repeatedly to find the
## composition factors of the GModule `module'. It also calls
## IsomorphismGModule to determine which are isomorphic.
## It returns a list [f1, f2, ..fr], where each fi is a list [m, n],
## where m is an irreducible composition factor of module, and n is the
## number of times it occurs in module.
##
SMTX.CollectedFactors:= function( module )
  local field,dim, factors, factorsout, queue, cmod, new,
      d, i, j, l, lf, q, smod, ds, homs, mat;
   if SMTX.IsMTXModule(module) = false then
      return Error("Argument is not a module.");
   fi;

   dim:=SMTX.Dimension(module);
   field:= SMTX.Field(module);
   factors:=[];
   for i in [1..dim] do
      factors[i]:=[];
   od;
   # factors[i] will contain a list [f1, f2, ..., fr] of the composition factors
   # of module of dimension i. Each fi will have the form [m, n], where m is
   # the module, and n its multiplicity.

   queue:=[module];
   # queue is the list of modules awaiting processing.

   while Length(queue) > 0 do
      cmod:=Remove(queue);
      d:=SMTX.Dimension(cmod);
      Info(InfoMeatAxe,3,"Length of queue = ", Length(queue)+1, ", dim = ", d, ".");

      if SMTX.IsIrreducible(cmod) then
         Info(InfoMeatAxe,2,"Irreducible: ");
         # module is irreducible. See if it is already on the list.
         new:=true;
         lf:=Length(factors[d]);
         i:=1;
         while new and i <= lf do
            if SMTX.IsEquivalent(factors[d][i][1], cmod) then
               new:=false;
               factors[d][i][2]:=factors[d][i][2] + 1;
            fi;
            i:=i + 1;
         od;
         if new then
            Info(InfoMeatAxe,2," new.");
            factors[d][lf + 1]:=[cmod, 1];
         else
            Info(InfoMeatAxe,2," old.");
         fi;
      else
         Info(InfoMeatAxe,2,"Reducible.");
         # module is reducible. Add sub- and quotient-modules to queue.
         q:=SMTX.InducedAction(cmod,
                  SMTX.Subbasis(cmod),3);
         smod:=q[1];
         ds:=SMTX.Dimension(smod);
         if ds < d/10 and SMTX.IsIrreducible(smod) then
           # Small dimensional submodule
           # test for repeated occurrences.
           homs:=SMTX.Homomorphisms( smod, cmod); # must have length >0

           # build the submodule formed by their images
           mat:=Concatenation(homs);
           TriangulizeMat(mat);
           mat:=Filtered(List(mat),i->not IsZero(i));
           mat:=ImmutableMatrix(field,mat);
           if Length(mat)<cmod.dimension then
             # there is still some factor left
             Add(queue, SMTX.InducedActionFactorModule(cmod, mat));
           fi;

           Info(InfoMeatAxe,2,
              "Small irreducible submodule X ",Length(homs),
              " subdim :",Length(mat)/smod.dimension,":");

           # module is irreducible. See if it is already on the list.
           new:=true;
           lf:=Length(factors[ds]);
           i:=1;
           while new and i <= lf do
              if SMTX.IsEquivalent(factors[ds][i][1], smod) then
                 Info(InfoMeatAxe,2," old.");
                 new:=false;
                 factors[ds][i][2]:=factors[ds][i][2] +
                  Length(mat)/smod.dimension;
              fi;
              i:=i + 1;
           od;
           if new then
              Info(InfoMeatAxe,2," new.");
              factors[ds][lf + 1]:=[smod, Length(mat)/smod.dimension];
           fi;

         else
           Add(queue, smod);
           Add(queue, q[2]);
         fi;
      fi;
   od;

   # Now repack the sequence for output.
   l:=0;
   factorsout:=[];
   for i in [1..dim] do
      for j in [1..Length(factors[i])] do
         l:=l + 1;
         factorsout[l]:=factors[i][j];
      od;
   od;

   return factorsout;

end;

SMTX.CompositionFactors:=function( module )
  if SMTX.IsIrreducible(module) then
    return [module];
  else
    module:=SMTX.InducedAction(module,
                  SMTX.Subbasis(module),3);
    return Concatenation(SMTX.CompositionFactors(module[1]),
                         SMTX.CompositionFactors(module[2]));
  fi;
end;

###############################################################################
##
#F  SMTX.Distinguish( cf, i )  distinguish a composition factor of a module
##
## cf is assumed to be the output of a call to SMTX.CollectedFactors,
## and i is the number of one of the cf.
## Distinguish tries to find a group-algebra element for factor[i]
## which gives nullity zero when applied to all other cf.
## Once this is done, it is easy to find submodules containing this
## composition factor.
##
SMTX.Distinguish:=function( cf, i )
   local el, genpair, ngens, orig_ngens, mat, matsi, mats, M, idmat,
         dim, F, fac, p, q, oldp, found, extdeg, j, k,
         lcf, lf, x, y, wno, deg, trying, N, fact, R;

   lcf:=Length(cf);
   ngens:=Length(cf[1][1].generators);
   orig_ngens:=ngens;
   F:=SMTX.Field(cf[1][1]);
   R:=PolynomialRing(F);
   matsi:=ShallowCopy(cf[i][1].generators);
   idmat:=matsi[1]^0;

   # First check that the existing nullspace has dim. 1 over centralising field.
   SMTX.GoodElementGModule(cf[i][1]);

   # First see if the existing element is OK
   # Apply the alg. el. of factor i to every other factor and see if the
   # matrix is nonsingular.
   found:=true;
   el:=SMTX.AlgEl(cf[i][1]);
   fact:=SMTX.AlgElCharPolFac(cf[i][1]);
   for j in [1..lcf] do
      if j <> i and found then
         mats:=ShallowCopy(cf[j][1].generators);
         dim:=SMTX.Dimension(cf[j][1]);
         for genpair in el[1] do
            ngens:=ngens + 1;
            mats[ngens]:=mats[genpair[1]] * mats[genpair[2]];
         od;
         M:=ImmutableMatrix(F,Sum([1..ngens], k -> el[2][k] * mats[k]));
         ngens:=orig_ngens;
         mat:=SMTX_Value(fact, M, M^0);
         if RankMat(mat) < dim then
            found:=false;
            Info(InfoMeatAxe,2,"Current element failed on factor ", j);
         fi;
      fi;
   od;

   if found then
      Info(InfoMeatAxe,2,"Current element worked.");
      return;
   fi;

   # That didn't work, so we have to try new random elements.
   wno:=0;
   el:=[]; el[1]:=[];
   extdeg:=SMTX.DegreeFieldExt(cf[i][1]);

   while found = false do
      Info(InfoMeatAxe,2,"Trying new one.");
      wno:=wno + 1;
      # Add a new generator if there are less than 8 or if wno mod 10=0.
      if  ngens<8 or wno mod 10 = 0 then
         x:=Random(1, ngens);
         y:=x;
         while y = x and ngens > 1 do y:=Random(1, ngens); od;
         Add(el[1], [x, y]);
         ngens:=ngens + 1;
         matsi[ngens]:=matsi[x] * matsi[y];
      fi;
      # Now take the new random element
      el[2]:=[];
      for j in [1..ngens] do el[2][j]:=Random(F); od;
      # First evaluate on cf[i][1].
      M:=ImmutableMatrix(F,Sum([1..ngens], k ->  el[2][k] * matsi[k]));
      p:=CharacteristicPolynomialMatrixNC(F,M,1);
      # That is necessary in case p is defined over a smaller field that F.
      oldp:=p;
      # extract irreducible factors
      deg:=0;
      fac:=[];
      trying:=true;
      while deg <= extdeg and trying do
         repeat
            deg:=deg + 1;
            if deg > extdeg then
               fac:=[p];
            else
               fac:=Factors(R, p: factoroptions:=rec(onlydegs:=[deg]));
               fac:=Filtered(fac,i->DegreeOfLaurentPolynomial(i)<=deg);
            fi;
         until fac <> [];
         lf:=Length(fac);
         if trying and deg <= extdeg then
            j:=1;
            while j <= lf and trying do
               mat:=SMTX_Value(fac[j], M,idmat);
               N:=NullspaceMat(mat);
               if Length(N) = extdeg then
                  trying:=false;
                  SMTX.SetAlgEl(cf[i][1], el);
                  SMTX.SetAlgElMat(cf[i][1], M);
                  SMTX.SetAlgElCharPol(cf[i][1], oldp);
                  SMTX.SetAlgElCharPolFac(cf[i][1], fac[j]);
                  SMTX.SetAlgElNullspaceVec(cf[i][1], N[1]);
               fi;
               j:=j + 1;
            od;
         fi;

         if trying then
            for q in fac do
               p:=Quotient(R, p, q);
            od;
         fi;
      od;

      # Now see if it works against the other factors of cf
      if trying = false then
         Info(InfoMeatAxe,2,"Found one.");
         found:=true;
         fact:=SMTX.AlgElCharPolFac(cf[i][1]);
         # Apply the alg. el. of factor i to every other factor and
         # see if the matrix is nonsingular.
         for j in [1..lcf] do
            if j <> i and found then
               mats:=ShallowCopy(cf[j][1].generators);
               dim:=SMTX.Dimension(cf[j][1]);
               ngens:=orig_ngens;
               for genpair in el[1] do
                  ngens:=ngens + 1;
                  mats[ngens]:=mats[genpair[1]] * mats[genpair[2]];
               od;
               M:=ImmutableMatrix(F,Sum([1..ngens], k -> el[2][k] * mats[k]));
               mat:=SMTX_Value(fact, M, M^0);
               if RankMat(mat) < dim then
                  found:=false;
                  Info(InfoMeatAxe,2,"Failed on factor ", j);
               fi;
            fi;
         od;
      fi;
      if found then
         Info(InfoMeatAxe,2,"It worked!");
      fi;
   od;

end;

###############################################################################
##
#F  SMTX.MinimalSubGModule( module, cf, i ) . .  find minimal submodule
##                                     containing a given composition factor.
##
## cf is assumed to be the output of a call to SMTX.CollectedFactors,
## and i is the number of one of the cf.
## It is assumed that SMTX.Distinguish(cf, i) has already been called.
## A basis of a minimal submodule of module containing the composition factor
## cf[i][1] is calculated and returned - i.e. if cf[i][2] = 1.
##
SMTX.MinimalSubGModule:=function( module, cf, i )
   local el, genpair, ngens, orig_ngens, mat, mats, M, F,
         k, N, fact;

   if SMTX.IsMTXModule(module) = false then
      return Error("First argument is not a module.");
   fi;

   ngens:=Length(module.generators);
   orig_ngens:=ngens;
   F:=SMTX.Field(module);

   # Apply the alg. el. of factor i to module
   el:=SMTX.AlgEl(cf[i][1]);
   mats:=ShallowCopy(module.generators);
   for genpair in el[1] do
      ngens:=ngens + 1;
      mats[ngens]:=mats[genpair[1]] * mats[genpair[2]];
   od;

   M:=ImmutableMatrix(F,Sum([1..ngens], k -> el[2][k] * mats[k]));
   # Now throw away extra generators of module
   for k in [orig_ngens + 1..ngens] do
      Unbind(mats[k]);
   od;
   ngens:=orig_ngens;
   fact:=SMTX.AlgElCharPolFac(cf[i][1]);
   mat:=SMTX_Value(fact, M,M^0);
   N:=NullspaceMat(mat);
   return SMTX.SpinnedBasis(N[1], mats,F, ngens);

end;


#############################################################################
##
#F  SMTX.Isomomorphism(module1, module2) . . . .
##  decide whether two irreducible modules are isomorphic.
##
## If the 2 modules are not isomorphic, this function returns false;
## if they are isomorphic it returns the matrix B, whose rows form the
## basis of module2  which is the image of the standard basis for module1.
## Thus if X and Y are corresponding matrices in the generating sets
## for module1 and module2 respectively, Y = B^-1XB
## It is assumed that the same group acts on both modules.
## Otherwise who knows what will happen?
##
SMTX.IsomorphismComp:=function(module1, module2, action)
   local matrices, matrices1, matrices2, F, dim, swapmodule, genpair,
         swapped, orig_ngens, i, j, el, p, fac, ngens, M, mat, v1, v2, v,
         N, basis, basis1, basis2;

   if SMTX.IsMTXModule(module1) = false then
      Error("Argument is not a module.");
   elif SMTX.IsMTXModule(module2) = false then
      Error("Argument is not a module.");
   elif SMTX.Field(module1) <> SMTX.Field(module2) then
      Error("GModules are defined over different fields.");
   fi;

   swapped:=false;
   if not SMTX.HasIsIrreducible(module1) then
      if not SMTX.HasIsIrreducible(module2) then
         Error("Neither module is known to be irreducible.");
      else
         # The second module is known to be irreducible, so swap arguments.
         swapmodule:=module2; module2:=module1; module1:=swapmodule;
         swapped:=true;
         Info(InfoMeatAxe,2,"Second module is irreducible. Swap them round.");
      fi;
   fi;

   # At this stage, module1 is known to be irreducible
   dim:=SMTX.Dimension(module1);
   if dim <> SMTX.Dimension(module2) then
      Info(InfoMeatAxe,2,"GModules have different dimensions.");
      return fail;
   fi;
   F:=SMTX.Field(module1);

   # First we must check that our nullspace is 1-dimensional over the
   # centralizing field.

   Info(InfoMeatAxe,2,
        "Checking nullspace 1-dimensional over centralising field.");
   SMTX.GoodElementGModule(module1);
   matrices1:=module1.generators;
   matrices2:=ShallowCopy(module2.generators);
   ngens:=Length(matrices1);
   orig_ngens:=ngens;
   if ngens <> Length(matrices2) then
      Error("GModules have different numbers of defining matrices.");
   fi;

   # Now we calculate the element in the group algebra of module2 that
   # corresponds to that in module1. This is done using the AlgEl flag
   # for module1. We first extend the generating set in the same way as
   # we did for module1, and then calculate the group alg. element as
   # a linear sum in the generators.

   Info(InfoMeatAxe,2,"Extending generating set for second module.");
   el:=SMTX.AlgEl(module1);
   for genpair in el[1] do
      ngens:=ngens + 1;
      matrices2[ngens]:=matrices2[genpair[1]] * matrices2[genpair[2]];
   od;
   M:=ImmutableMatrix(F,Sum([1..ngens], i -> el[2][i] * matrices2[i]));
   # Having done that, we no longer want the extra generators of module2,
   # so we throw them away again.
   for i in [orig_ngens + 1..ngens] do
      Unbind(matrices2[i]);
   od;

   Info(InfoMeatAxe,2,
        "Calculating characteristic polynomial for second module.");
   p:=CharacteristicPolynomialMatrixNC(F,M,1);
   if p <> SMTX.AlgElCharPol(module1) then
      Info(InfoMeatAxe,2,"Characteristic polynomial different.");
      return fail;
   fi;
   fac:=SMTX.AlgElCharPolFac(module1);
   mat:=SMTX_Value(fac, M,M^0);
   Info(InfoMeatAxe,2,"Calculating nullspace for second module.");
   N:=NullspaceMat(mat);
   if Length(N) <> SMTX.AlgElNullspaceDimension(module1) then
      Info(InfoMeatAxe,2,"Null space dimensions different.");
      return fail;
   fi;

   # That concludes the easy tests for nonisomorphism. Now we must proceed
   # to spin up. We first form the direct sum of the generating matrices.
   Info(InfoMeatAxe,2,"Spinning up in direct sum.");
   matrices:=SMTX.MatrixSum(matrices1, matrices2);
   v1:=SMTX.AlgElNullspaceVec(module1);
   v2:=N[1];
   if IsVectorObj(v1) then v1:=Unpack(v1);fi;
   if IsVectorObj(v2) then v2:=Unpack(v2);fi;
   v:=Concatenation(v1, v2);
   basis:=SMTX.SpinnedBasis(v, matrices, F);
   if Length(basis) = dim then
      if action<>true then
        return true;
      fi;
      basis1:=[]; basis2:=[];
      for i in [1..dim] do
         basis1[i]:=[]; basis2[i]:=[];
         for j in [1..dim] do
            basis1[i][j]:=basis[i][j];
            basis2[i][j]:=basis[i][j + dim];
         od;
      od;
      if swapped then
         return basis2^-1 * basis1;
      else
         return basis1^-1 * basis2;
      fi;
   else
      return fail;
   fi;
end;

SMTX.IsomorphismIrred:=function(module1,module2)
  return SMTX.IsomorphismComp(module1,module2,true);
end;

SMTX.Isomorphism:=SMTX.IsomorphismIrred;

SMTX.IsEquivalent:=function(module1,module2)
  return SMTX.IsomorphismComp(module1,module2,false)<>fail;
end;

#############################################################################
##
#F  SMTX.MatrixSum(matrices1, matrices2) direct sum of two lists of matrices
##
SMTX.MatrixSum:=function(matrices1, matrices2)
   local matrices, nmats, i;
   matrices:=[];
   nmats:=Length(matrices1);
   for i in [1..nmats] do
      matrices[i]:=DirectSumMat(matrices1[i],matrices2[i]);
   od;

   return  matrices;
end;


#############################################################################
##
#F  SMTX.Homomorphisms( m1, m2) . . . . homomorphisms from an irreducible
##                         . . . GModule to an arbitrary GModule
##
## It is assumed that m1 is a module that has been proved irreducible
##  (using IsIrreducible), and m2 is an arbitrary module for the same group.
## A basis of the space of G-homomorphisms from m1 to m2 is returned.
## Each homomorphism is given as a list of base images.
##
SMTX.Homomorphisms:= function(m1, m2)

   local F, ngens, orig_ngens, mats1, mats2, dim1, dim2, m1bas, imbases,
         el, genpair, fac, mat, N, imlen, subdim, leadpos, vec, imvecs,
         numrels, rels, leadposrels, newrels, bno, genno, colno, rowno,
         zero, looking, ans, i, j, k;

   if not SMTX.IsMTXModule(m1) then
      return Error("First argument is not a module.");
   elif not SMTX.IsIrreducible(m1) then
      return Error("First module is not known to be irreducible.");
   fi;

   if not SMTX.IsMTXModule(m2) then
      return Error("Second argument is not a module.");
   fi;
   mats1:=m1.generators;
   mats2:=ShallowCopy(m2.generators);
   ngens:=Length(mats1);
   if ngens <> Length(mats2) then
      return Error("GModules have different numbers of generators.");
   fi;

   F:=SMTX.Field(m1);
   if F <> SMTX.Field(m2) then
      return Error("GModules are defined over different fields.");
   fi;
   zero:=Zero(F);

   dim1:=SMTX.Dimension(m1); dim2:=SMTX.Dimension(m2);

   if dim1=1 then
     # m1 is 1-dimensional -- eigenspace intersection
     el:=List([1..Length(m1.generators)],x->NullspaceMat(m2.generators[x]-m1.generators[x][1][1]*m2.generators[x]^0));

     imvecs:=el[1];
     for j in [2..Length(el)] do
       imvecs:=SumIntersectionMat(imvecs,el[j])[2];
     od;
     return List(imvecs,x->ImmutableMatrix(m1.field,[x]));
   fi;

   m1bas:=[];
   m1bas[1]:= SMTX.AlgElNullspaceVec(m1);

   # In any homomorphism from m1 to m2, the vector in the nullspace of the
   # algebraic element that was used to prove irreducibility (which is now
   # m1bas[1]) must map onto a vector in the nullspace of the same algebraic
   # element evaluated in m2. We therefore calculate this nullspaces, and
   # store a basis in imbases.

   Info(InfoMeatAxe,2,"Extending generating set for second module.");
   orig_ngens:=ngens;
   el:=SMTX.AlgEl(m1);
   for genpair in el[1] do
      ngens:=ngens + 1;
      mats2[ngens]:=mats2[genpair[1]] * mats2[genpair[2]];
   od;
   mat:=ImmutableMatrix(F,Sum([1..ngens], i -> el[2][i] * mats2[i]));
   # Having done that, we no longer want the extra generators of m2,
   # so we throw them away again.
   for i in [orig_ngens + 1..ngens] do
      Unbind(mats2[i]);
   od;
   ngens:=orig_ngens;

   fac:=SMTX.AlgElCharPolFac(m1);
   mat:=SMTX_Value(fac, mat,mat^0);
   Info(InfoMeatAxe,2,"Calculating nullspace for second module.");
   N:=NullspaceMat(mat);
   imlen:=Length(N);
   Info(InfoMeatAxe,2,"Dimension = ", imlen, ".");
   if imlen = 0 then
      return [];
   fi;

   imbases:=List(N, vec -> [vec]);

   # Now the main algorithm starts. We are going to spin the vectors in m1bas
   # under the action of the module generators, norming as we go. Every
   # operation that we perform on m1bas will also be performed on each of the
   # vectors in  imbas[1], ..., imbas[imlen].
   # When we find a vector that norms to zero in m1bas, then the image of this
   # under a homomorphism must be zero. This leads to a linear relation
   # amongst some vectors in imbas. We store up such relations, echelonizing as
   # we go. At the end, if we have numrels subch independent relations, then
   # there will be imlen - numrels independent homomorphisms from m1 to m2,
   # which we can then calculate.

   subdim:=1; # the dimension of module spanned by m1bas
   numrels:=0;
   rels:=[];

   # leadpos[j] will be the position of the first nonzero entry in m1bas[j]
   leadpos:=[];
   vec:=m1bas[1];
   j:=1;
   while j <= dim1 and vec[j] = zero do j:=j + 1; od;
   leadpos[1]:=j;
   k:=vec[j]^-1;
   m1bas[1]:=k * vec;
   for i in [1..imlen] do
      imbases[i][1]:=k * imbases[i][1];
   od;

   leadposrels:=[];
   # This will play the same role as leadpos but for the relation matrix.
   Info(InfoMeatAxe,2,"Starting spinning.");
   bno:=1;
   while bno <= subdim do
      for genno in [1..ngens] do
         # apply generator no. genno to submodule generator bno
         vec:=m1bas[bno] * mats1[genno];
         # and do the same to the images
         imvecs:=[];
         for i in [1..imlen] do
            imvecs[i]:=imbases[i][bno] * mats2[genno];
         od;
         # try to express w in terms of existing submodule generators
         # make same changes to images
         j:=1;
         for  j in [1..subdim] do
            k:=vec[leadpos[j]];
            if k <> zero then
               vec:=vec - k * m1bas[j];
               for i in [1..imlen] do
                  imvecs[i]:=imvecs[i] - k * imbases[i][j];
               od;
            fi;
         od;

         j:=1;
         while j <= dim1 and vec[j] = zero do j:=j + 1; od;
         if j <= dim1 then
            # we have found a new generator of the submodule
            subdim:=subdim + 1;
            leadpos[subdim]:=j;
            k:=vec[j]^-1;
            m1bas[subdim]:=k * vec;
            for i in [1..imlen] do
               imbases[i][subdim]:=k * imvecs[i];
            od;
         else
            # vec has reduced to zero. We get relations among the imvecs.
            # (these are given by the transpose of imvec)
            # reduce these against any existing relations.
            newrels:=TransposedMat(imvecs);
            for i in [1..Length(newrels)] do
               vec:=newrels[i];
               for j in [1..numrels] do
                  k:=vec[leadposrels[j]];
                  if k <> zero then
                     vec:=vec - k * rels[j];
                  fi;
               od;
               j:=1;
               while j <= imlen and vec[j] = zero do j:=j + 1; od;
               if j <= imlen then
                  # we have a new relation
                  numrels:=numrels + 1;
                  # if we have imlen relations, there can be no homomorphisms
                  # so we might as well give up immediately
                  if numrels = imlen then
                     return [];
                  fi;
                  k:=vec[j]^-1;
                  rels[numrels]:=k * vec;
                  leadposrels[numrels]:=j;
               fi;
            od;
         fi;
      od;
      bno:=bno + 1;
   od;

   # That concludes the spinning. Now we do row operations on the im1bas to
   # make it the identity, and do the same operations to the imvecs.
   # Then the homomorphisms we output will be the basis images.
   Info(InfoMeatAxe,2,"Done. Reducing spun up basis.");

   for colno in [1..dim1] do
      rowno:=colno;
      looking:=true;
      while rowno <= dim1 and looking do
         if m1bas[rowno][colno] <> zero then
            looking:=false;
            if rowno <> colno then
               # swap rows rowno and colno
               vec:=m1bas[rowno]; m1bas[rowno]:=m1bas[colno];
               m1bas[colno]:=vec;
               # and of course the same in the images
               for i in [1..imlen] do
                  vec:=imbases[i][rowno];
                  imbases[i][rowno]:=imbases[i][colno];
                  imbases[i][colno]:=vec;
               od;
            fi;
            # and then clear remainder of column
            for j in [1..dim1] do
               if j <> colno and m1bas[j][colno] <> zero then
                  k:=m1bas[j][colno];
                  m1bas[j]:=m1bas[j] - k * m1bas[colno];
                  for i in [1..imlen] do
                     imbases[i][j]:=imbases[i][j] - k * imbases[i][colno];
                  od;
               fi;
            od;
         fi;
         rowno:=rowno + 1;
      od;
   od;

   # Now we are ready to compute and output the linearly independent
   # homomorphisms.  The coefficients for the solution are given by
   # the basis elements of the nullspace of the transpose of rels.

   Info(InfoMeatAxe,2,"Done. Calculating homomorphisms.");
   if rels = [] then
      rels:=NullMat(imlen, 1, F);
   else
      rels:=TransposedMat(rels);
   fi;
   N:=NullspaceMat(rels);
   ans:=[];
   for vec in N do
      mat:=ImmutableMatrix(F, Sum([1..imlen], i -> vec[i] * imbases[i]));
      Add(ans, mat);
   od;

   return ans;
end;

#############################################################################
##
#F  SMTX.SortHomGModule( m1, m2, homs)  . . sort output of HomGModule
##                                           according to their images
##
## It is assumed that m1 is a module that has been proved irreducible
## (using IsIrreducible), and m2 is an arbitrary module for the same group,
## and that homs is the output of a call HomGModule(m1, m2).
## Let e be the degree of the centralising field of m1.
## If e = 1 then SMTX.SortHomGModule does nothing. If e > 1, then it replaces
## the basis contained in homs by a new basis arranged in the form
## b11, b12, ..., b1e, b21, b22, ...b2e, ..., br1, br2, ...bre,  where each
## block of  e  adjacent basis vectors are all equivalent under the
## centralising field of m1, and so they all have the same image in  m2.
## A complete list of the distinct images can then be obtained with a call
## to DistinctIms(m1, m2, homs).
##
SMTX.SortHomGModule:=function(m1, m2, homs)
local e, F, dim1, dim2, centmat, fullimbas, oldhoms,
      homno, dimhoms, newdim, subdim, leadpos, vec, nexthom,
      i, j, k, zero;

   if SMTX.IsAbsolutelyIrreducible(m1) then return; fi;

   e:=SMTX.DegreeFieldExt(m1);
   F:=SMTX.Field(m1);
   zero:=Zero(F);

   dim1:=SMTX.Dimension(m1);  dim2:=SMTX.Dimension(m2);
   centmat:=SMTX.CentMat(m1);

   fullimbas:=[];
   subdim:=0;
   leadpos:=[];

   # fullimbas will contain an echelonised basis for the submodule of m2
   # generated by all images of the basis vectors of hom that we have found
   # so far; subdim is its length.

   # We go through the existing basis of homs.
   # For each hom in the basis, we first check whether the first vector in
   # the image  of hom is in the space spanned by fullimbas.
   # If so, we reject hom. If not, then hom is adjoined to the new
   # basis of homs, as are the other e-1 linearly independent homomorphisms
   # that are equivalent to hom by a multiplication by centmat. The
   # resulting block of e homomorphisms all have the same image in m2.

   # first make a copy of homs.

   oldhoms:=ShallowCopy(homs);
   dimhoms:=Length(homs);

   homno:=0; newdim:=0;

   while homno < dimhoms and newdim < dimhoms do
      homno:=homno + 1;
      nexthom:=oldhoms[homno];
      vec:=nexthom[1];

      # Now check whether vec is in existing submodule spanned by fullimbas
      j:=1;
      for j in [1..subdim] do
         k:=vec[leadpos[j]];
         if k <> zero then
            vec:=vec - k * fullimbas[j];
         fi;
      od;

      j:=1;
      while j <= dim2 and vec[j] = zero do j:=j + 1; od;

      if j <= dim2 then
         # vec is not in the image, so we adjoin this homomorphism to the list;
         # first adjoin vec and all other basis vectors in the image to fullimbas
         subdim:=subdim + 1;
         leadpos[subdim]:=j;
         k:=vec[j]^-1;
         fullimbas[subdim]:=k * vec;
         for i in [2..dim1] do
            vec:=nexthom[i];
            j:=1;
            for  j in [1..subdim] do
               k:=vec[leadpos[j]];
               if k <> zero then
                  vec:=vec - k * fullimbas[j];
               fi;
            od;

            j:=1;
            while j <= dim2 and vec[j] = zero do j:=j + 1; od;
            subdim:=subdim + 1;
            leadpos[subdim]:=j;
            k:=vec[j]^-1;
            fullimbas[subdim]:=k * vec;
         od;

         newdim:=newdim + 1;
         homs[newdim]:=nexthom;

         # Now add on the other e - 1 homomorphisms equivalent to
         # newhom by centmat.
         for k in [1..e - 1] do
            nexthom:=centmat * nexthom;
            newdim:=newdim + 1;
            homs[newdim]:=nexthom;
         od;
      fi;
   od;

end;

#############################################################################
##
#F  SMTX.Homomorphism(module1,module2,mat) . . . define a module homorphism
##
##  module1 and module2 should be meataxe modules of dimensions m and n
##  over the same algebra, and mat an mXn matrix over the field of
##  the modules that defines a homomorphism module1 -> module2, where
##  the i-th row of mat gives the image in module2 of the i-th basis
##  vector of module1.
##  It is checked whether mat really does define a homomorphism.
##  If, so then the corresponding vector space homomorphism from the underlying
##  row space of module1 to that of module2 is returned. This can be used
##  for computing images, kernel, preimages, etc.

SMTX.Homomorphism:=function(module1, module2, mat)
  local F, gens1, gens2, ng, dim1, dim2, i, j;
  F:=SMTX.Field(module1);
  if F <> SMTX.Field(module2) then
    Error("Modules are over different fields");
  fi;
  gens1:=SMTX.Generators(module1); gens2:=SMTX.Generators(module2);
  dim1:=SMTX.Dimension(module1); dim2:=SMTX.Dimension(module2);
  ng:=Length(gens1);
  if ng <> Length(gens2) then
    Error("Modules are not over the same algebra");
  fi;
  if Length(mat) <> dim1 or Length(mat[1]) <> dim2 then
    Error("matrix has wrong size for a homomorphism");
  fi;
  # Check if it is a homorphism
  mat:=ImmutableMatrix(F,mat);
  for i in [1..ng] do
    for j in [1..dim1] do
      if gens1[i][j] * mat <> mat[j] * gens2[i] then
        Error("matrix does not define a homomorphism");
      fi;
    od;
  od;
  return LeftModuleHomomorphismByImages(FullRowSpace(F,dim1),
                          FullRowSpace(F,dim2),IdentityMat(dim1,F),mat);
end;

#############################################################################
##
#F SMTX.MinimalSubGModules(m1, m2, [max]) . .
## minimal submodules of m2 isomorphic to m1
##
## It is assumed that m1 is a module that has been proved irreducible
##  (using IsIrreducible), and m2 is an arbitrary module for the same group.
## MinimalSubGModules computes and outputs a list of normed bases for all of the
## distinct minimal submodules of m2 that are isomorphic to m1.
## max is an optional maximal number - if the total number of submodules
## exceeds max, then the procedure aborts.
## First HomGModule is called and then SMTX.SortHomGModule to get a basis for
## the homomorphisms from m1 to m2 in the correct order.
## It is then easy to write down the list of distinct images.
##
SMTX.MinimalSubGModules:=function(arg)

   local m1, m2, max, e, homs, coeff,  dimhom, edimhom, F, elF, q,
         submodules, sub, adno, more, count, sr, er, i, j, k;

   if Length(arg) < 2 or Length(arg) > 3 then
      Error("Number of arguments to MinimalSubGModules must be 2 or 3.");
   fi;

   m1:=arg[1]; m2:=arg[2];
   if Length(arg) = 2 then max:=0; else max:=arg[3]; fi;

   Info(InfoMeatAxe,2,"Calculating homomorphisms from m1 to m2.");
   homs:=SMTX.Homomorphisms(m1, m2);
   Info(InfoMeatAxe,2,"Sorting them.");
   SMTX.SortHomGModule(m1, m2, homs);

   F:=SMTX.Field(m1);
   e:=SMTX.DegreeFieldExt(m1);
   dimhom:=Length(homs);
   edimhom:=dimhom / e;
   submodules:=[];
   count:=0;
   elF:=AsList(F);
   q:=Length(elF);
   coeff:=ListWithIdenticalEntries(dimhom,1);

   # coeff[i] will be an integer in the range [1..q] corresponding to the
   # field element elF[coeff[i]].
   # Each submodule will be calculated as the image of the homomorphism
   # elF[coeff[1]] * homs[1] +...+  elF[coeff[dimhom]] * homs[dimhom]
   # for appropriate field elements elF[coeff[i]].
   # We get each distinct submodule
   # exactly once by making the first nonzero elF[coeff[i]] to be 1,
   # and all other elF[coeff[i]]'s in that block equal to zero.

   Info(InfoMeatAxe,2,"Done. Calculating submodules.");

   for i in Reversed([1..edimhom]) do
      j:=e * (i - 1) + 1;
      coeff[j]:=2;  # giving field element 1.
      for k in [j + 1..dimhom] do coeff[k]:=1; od; # field element 0.
      sr:=j + e; er:=dimhom;
      # coeff[i] for i in [sr..er] ranges over all field elements.

      more:=true;
      adno:=er;
      while more do
         count:=count + 1;
         if max > 0 and count > max then
            Info(InfoMeatAxe,2,"Number of submodules exceeds ", max,
                 ". Aborting.");
            return submodules;
         fi;

         # Calculate the next submodule
         sub:=homs[j];
         for k in [sr..er] do
            sub:=sub + elF[coeff[k]] * homs[k];
         od;
         sub:=TriangulizedMat(sub);
         Add(submodules, ImmutableMatrix(F,sub));

         # Move on to next set of coefficients if any
         while adno >= sr and coeff[adno]=q do
            coeff[adno]:=1;
            adno:=adno - 1;
         od;
         if adno < sr then
            more:=false;
         else
            coeff[adno]:=coeff[adno] + 1;
            adno:=er;
         fi;
      od;

   od;

   return submodules;

end;

SMTX.BasesCompositionSeries:=function(arg)
local q,b,s,ser,queue,F,m;
  m:=arg[1];
  SMTX.SetSmashRecord(m,0);
  F:=SMTX.Field(m);
  b:=IdentityMat(SMTX.Dimension(m),F);
  b:=ImmutableMatrix(F,b);
  # denombasis: basis of the kernel
  m.smashMeataxe.denombasis:=[];
  # fakbasis: Urbilder der Basis, bzgl. derer csbasis angegeben wird
  # the first <dimension> vectors of <fakbasis> are the right ones.
  m.smashMeataxe.fakbasis:=b;

  ser:=[[]];
  queue:=[m];
  while Length(queue)>0 do
    m:=Remove(queue);
    if SMTX.IsIrreducible(m) then
      Info(InfoMeatAxe,2,SMTX.Dimension(m)," ",
                         Length(m.smashMeataxe.denombasis));
      m:=Concatenation(
        m.smashMeataxe.denombasis,
        m.smashMeataxe.fakbasis{[1..SMTX.Dimension(m)]});
      m:=ImmutableMatrix(F,m);
      Add(ser,m);
    else
      b:=SMTX.Subbasis(m);
      s:=SMTX.InducedAction(m,b,3);
      q:=s[2];
      b:=s[3];
      s:=s[1];
      SMTX.SetSmashRecord(s,0);
      SMTX.SetSmashRecord(q,0);
      Info(InfoMeatAxe,1,"chopped ",SMTX.Dimension(s),"\\", SMTX.Dimension(q));
      s.smashMeataxe.denombasis:=m.smashMeataxe.denombasis;
      s.smashMeataxe.fakbasis:=b*m.smashMeataxe.fakbasis;

      q.smashMeataxe.denombasis:=Concatenation(
        m.smashMeataxe.denombasis,
        s.smashMeataxe.fakbasis{[1..s.dimension]});
      q.smashMeataxe.fakbasis:=
        s.smashMeataxe.fakbasis{[s.dimension+1..Length(b)]};

      Add(queue,s);
      Add(queue,q);
    fi;
  od;
  SortBy(ser,Length);
  if Length(arg)=1 or arg[2]<>false then
    ser:=List(ser,x->ImmutableMatrix(F,TriangulizedMat(x)));
  fi;
  return ser;
end;

# composition series with small steps
SMTX.BasesCSSmallDimUp:=function(m)
local cf,F,dim,b,den,sub,i,s,q,found,qb;
  cf:=List(SMTX.CollectedFactors(m),x->[x[1],x[2]]); # so we can overwrite
  SortBy(cf,x->x[1].dimension);
  dim:=SMTX.Dimension(m);
  F:=SMTX.Field(m);
  b:=IdentityMat(dim,F);
  b:=ImmutableMatrix(F,b);
  den:=0;
  sub:=[[]];
  q:=m;
  while den<dim do
    i:=1;
    found:=false;
    while i<=Length(cf) and found=false do
      if cf[i][2]>0 then # can we still get this module?
        s:=MTX.Homomorphisms(cf[i][1],q);
        if Length(s)>0 then
          # found one
          cf[i][2]:=cf[i][2]-1;
          found:=true;
          s:=s[1];
          if Length(s)=q.dimension then
            # on top
            Add(sub,TriangulizedMat(b));
            den:=dim;
          else
            s:=TriangulizedMat(s);
            qb:=b{[den+1..Length(b)]}; # basis
            qb:=List(s,x->x*qb);
            qb:=Concatenation(b{[1..den]},qb);
            qb:=TriangulizedMat(qb);
            Add(sub,qb);
            s:=SMTX.InducedAction(q,s,3);
            b:=Concatenation(b{[1..den]},s[3]*b{[den+1..Length(b)]});
            den:=den+Length(qb);
            q:=s[2];
            den:=Length(qb);
          fi;
        fi;
      fi;
      i:=i+1;
    od;
  od;
  return sub;
end;

SMTX.BasesCSSmallDimDown:=function(m)
local d,sub;
  d:=MTX.DualModule(m);
  sub:=SMTX.BasesCSSmallDimUp(d);
  return Concatenation([[]],
    Reversed(List(sub{[2..Length(sub)-1]},x->SMTX.DualizedBasis(m,x))),
    [IdentityMat(m.dimension,m.field)]);

end;

SMTX.BasesSubmodules:=function(m)
local cf,u,i,j,f,cl,min,neu,sq,sb,fb,k,nmin,F;
  F:=SMTX.Field(m);
  cf:=SMTX.CollectedFactors(m);
  cl:=Sum(cf,i->i[2]); # composition length
  cf:=List(cf,i->i[1]);
  u:=[[]];
  if cl>1 then
    min:=Concatenation(List(cf,i->SMTX.MinimalSubGModules(i,m)));
    u:=Concatenation(u,min);
  fi;
  for i in [2..cl-1] do
    neu:=[];
    for j in min do
      f:=List(j,i->List(i,i->i));
      sq:=SMTX.InducedAction(m,j,2);
      Assert(2,j=f);
      f:=sq[1];
      sb:=j;
      fb:=sq[2]{[Length(j)+1..Length(sq[2])]};
      # actually we might want to count frequencies to speed up the process,
      # so far I'm lazy
      nmin:=Concatenation(List(cf,i->SMTX.MinimalSubGModules(i,f)));
      Info(InfoMeatAxe,3,Length(nmin),"minimal submodules");
      for k in nmin do
        sq:=Concatenation(List(sb,ShallowCopy), # don't destroy old basis
                          k*fb);
        TriangulizeMat(sq);
        sq:=ImmutableMatrix(F,sq);
        Assert(2,SMTX.InducedAction(m,sq)<>fail);
        if not sq in neu then
          Info(InfoMeatAxe,2,"submodule dimension ",Length(sq));
          Add(neu,sq);
        fi;
      od;
    od;
    u:=Concatenation(u,neu);
    min:=neu;
  od;
  Add(u,ImmutableMatrix(SMTX.Field(m),
                        IdentityMat(SMTX.Dimension(m),SMTX.Field(m))));
  return u;
end;


SMTX.BasesMinimalSubmodules:=function(m)
local cf;
  cf:=SMTX.CollectedFactors(m);
  cf:=List(cf,i->i[1]);
  return Concatenation(List(cf,i->SMTX.MinimalSubGModules(i,m)));
end;

SMTX.DualModule:=function(module)
  if SMTX.IsZeroGens(module) then
    return GModuleByMats([],module.dimension,SMTX.Field(module));
  else
    return GModuleByMats(List(SMTX.Generators(module),i->TransposedMat(i)^-1),
                        module.dimension,
                        SMTX.Field(module));
  fi;
end;

###############################################################################
##
#F  DualGModule( module ) . . . . . dual of a G-module
##
## DualGModule calculates the dual of a G-module.
## The matrices of the module are inverted and transposed.
##
InstallGlobalFunction(DualGModule,function( module)
   return SMTX.DualModule(module);
end);

SMTX.DualizedBasis:=function(module,sub)
local F,M;
  F:=DefaultFieldOfMatrix(sub);
  M:=TransposedMatMutable(sub);
  M:=TriangulizedNullspaceMatDestructive(M);
  M:=ImmutableMatrix(F,M);
  return M;
end;

SMTX.BasesMaximalSubmodules:=function(m)
local d,u;
  d:=SMTX.DualModule(m);
  u:=SMTX.BasesMinimalSubmodules(d);
  return List(u,i->SMTX.DualizedBasis(d,i));
end;

SMTX.BasesMinimalSupermodules:=function(m,sub)
local a,u,i,nb;
  a:=SMTX.InducedAction(m,sub,2);
  u:=SMTX.BasesMinimalSubmodules(a[1]);
  nb:=a[2];
  nb:=nb{[Length(sub)+1..Length(nb)]}; # the new basis part
  nb:=List(u,i->Concatenation( List( sub, ShallowCopy ),
                               i*nb));
  u:=[];
  for i in nb do
    TriangulizeMat(i);
    Add(u,Filtered(i,j->j<>Zero(j)));
  od;
  return u;
end;

#############################################################################
##
#F SMTX.SpanOfMinimalSubGModules(m1, m2) . .
## span of the minimal submodules of m2 isomorphic to m1
##
## It is assumed that m1 is a module that has been proved irreducible
##  (using IsIrreducible), and m2 is an arbitrary module for the same group.
## SpanOfMinimalSubGModules computes a normed bases for the span of
## the minimal submodules of m2 that are isomorphic to m1,
## First HomGModule is called.
##
SMTX.SpanOfMinimalSubGModules:=function(m1, m2)
   local  homs, e, mat, i;
   Info(InfoMeatAxe,2,"Calculating homomorphisms from m1 to m2.");
   homs:=SMTX.Homomorphisms(m1, m2);
   if homs=[] then
     return [];
   fi;
   Info(InfoMeatAxe,2,"Sorting them.");
   SMTX.SortHomGModule(m1, m2, homs);

   e:=SMTX.DegreeFieldExt(m1);
   # homs are now grouped so that each block of e have the same image.
   # We only want one from each block.
   if e > 1 then
     homs:=homs{Filtered([1..Length(homs)],i->(i mod e) = 1)};
   fi;
   if Length(homs) = 1 then
     return homs[1];
   fi;
   # The span of the images of homs is what we want!
   mat:=Concatenation(homs);
   TriangulizeMat(mat);
   mat:=ImmutableMatrix(m1.field,mat);
   return mat;
end;

SMTX.BasisSocle:=function(module)
local cf, mat, i;
   cf:=SMTX.CollectedFactors(module);
   mat:=Concatenation(List(cf,i->SMTX.SpanOfMinimalSubGModules(i[1],module)));
   if Length(cf) = 1 then
     return ImmutableMatrix(module.field,mat);
   fi;
   TriangulizeMat(mat);
   mat:=ImmutableMatrix(module.field,mat);
   return mat;
end;

SMTX.BasisRadical:=function(module)
local d, bs;
   d:=SMTX.DualModule(module);
   bs:=SMTX.BasisSocle(d);
   return SMTX.DualizedBasis(d,bs);
end;

# the following assignment is for profiling
SMTX.funcs:=[SMTX.OrthogonalVector,SMTX.SpinnedBasis,SMTX.SubQuotActions,
  SMTX.SMCoRaEl,SMTX.IrreducibilityTest,SMTX.RandomIrreducibleSubGModule,
  SMTX.GoodElementGModule,SMTX.FrobeniusAction,SMTX.CompleteBasis,
  SMTX.AbsoluteIrreducibilityTest,SMTX.CollectedFactors,SMTX.Distinguish,
  SMTX.MinimalSubGModule,SMTX.IsomorphismComp,SMTX.MatrixSum,
  SMTX.Homomorphisms,SMTX.SortHomGModule,SMTX.MinimalSubGModules,
  SMTX.BasesCompositionSeries,SMTX.BasesSubmodules,SMTX.BasesMinimalSubmodules,
  SMTX.BasesMaximalSubmodules,SMTX.BasesMinimalSupermodules,SMTX.BasisSocle,
  SMTX.BasisRadical];


# The following functions are for finding a basis of an irreducible module
# that is contained in an orbit of the G-action on vectors, and for
# looking for G-invariant bilinear and quadratic forms of the module.
# The special basis is used for finding invariant quadratic forms when
# the characteristic of the field is 2.

SMTX.SetBasisInOrbit:=function(module,b)
  module.BasisInOrbit:=b;
end;

#############################################################################
##
#F  BasisInOrbit( module ) . . . .
##
## Find a basis of the irrecucible GModule module that is contained in
## an orbit of the action of G.
## The code is similar to that of SpinnedBasis.
SMTX.BasisInOrbit:=function( module  )
   local   v, matrices, ngens, zero,  ans, normedans,
           dim, subdim, leadpos, w, normedw, i, j, k, l, m, F;

   if not SMTX.IsMTXModule(module) or not SMTX.IsIrreducible(module) then
      Error("Argument of BasisInOrbit is not an irreducible module");
   fi;
   if IsBound(module.BasisInOrbit) then return module.BasisInOrbit; fi;

   dim:=SMTX.Dimension(module);
   F:=SMTX.Field(module);
   matrices:=module.generators;
   ngens:=Length(matrices);

   zero:=Zero(F);
   v:=IdentityMat(dim,F)[1];
   ans:=[v];
   normedans:=[v];
   subdim:=1;
   leadpos:=SubGModLeadPos(ans,dim,subdim,zero);

   i:=1;
   while i <= subdim and subdim < dim do
      for l in [1..ngens] do
         m:=matrices[l];
         # apply generator m to submodule generator i
         w:=ans[i] * m;
         normedw:=w;
         # try to express w in terms of existing submodule generators
         j:=1;
         for  j in [1..subdim] do
            k:=normedw[leadpos[j]];
            if k <> zero then
               normedw:=normedw - k * normedans[j];
            fi;
         od;

         j:=1;
         while j <= dim and normedw[j] = zero do
            j:=j + 1;
         od;
         if j <= dim then
            # we have found a new generator of the submodule
            subdim:=subdim + 1;
            leadpos[subdim]:=j;
            normedw:=(normedw[j]^-1) * normedw;
            Add( ans, w );
            Add( normedans, normedw );
            if subdim = dim then
               break;
            fi;
         fi;
      od;
      i:=i + 1;
   od;

   Assert(0, subdim = dim);
   ans:=ImmutableMatrix(F,ans);
   SMTX.SetBasisInOrbit(module,ans);
   return ans;
end;

SMTX.SetInvariantBilinearForm:=function(module,b)
  module.InvariantBilinearForm:=b;
end;

#############################################################################
##
#F  InvariantBilinearForm( module ) . . . .
##
## Look for an invariant bilinear form of the absolutely irreducible
## GModule module. Return fail, or the matrix of the form.
SMTX.InvariantBilinearForm:=function( module  )
   local DM, iso;

   if not SMTX.IsMTXModule(module) or
                            not SMTX.IsAbsolutelyIrreducible(module) then
      Error(
 "Argument of InvariantBilinearForm is not an absolutely irreducible module");
   fi;
   if IsBound(module.InvariantBilinearForm) then
     return module.InvariantBilinearForm;
   fi;
   DM:=SMTX.DualModule(module);
   iso:=MTX.IsomorphismIrred(module,DM);
   if iso = fail then
       SMTX.SetInvariantBilinearForm(module, fail);
       return fail;
   fi;
   iso:=ImmutableMatrix(module.field, iso);
   SMTX.SetInvariantBilinearForm(module, iso);
   return iso;
end;


SMTX.MatrixUnderFieldAuto:=function(matrix, r)
# raise every component of matrix to r-th power
  local mat;
  mat:=List( matrix, x -> List(x, y->y^r) );
  mat:=ImmutableMatrix(GF(r^2), mat);
  return mat;
end;

SMTX.TwistedDualModule:=function(module)
  local q, r, mats;
  q:=Size(module.field);
  r:=RootInt(q,2);
  if r^2 <> q then
    Error("Size of field of module is not a square");
  fi;
  if SMTX.IsZeroGens(module) then
    return GModuleByMats([],module.dimension,SMTX.Field(module));
  else
    mats:=List( SMTX.Generators(module),
          i->SMTX.MatrixUnderFieldAuto(TransposedMat(i)^-1,r) );
    return GModuleByMats( mats, module.dimension, SMTX.Field(module) );
  fi;
end;

SMTX.SetInvariantSesquilinearForm:=function(module,b)
  module.InvariantSesquilinearForm:=b;
end;

#############################################################################
##
#F  InvariantSesquilinearForm( module ) . . . .
##
## Look for an invariant sesquililinear form of the absolutely irreducible
## GModule module. Return fail, or the matrix of the form.
SMTX.InvariantSesquilinearForm:=function( module  )
   local DM, q, r, iso, isot, l;

   if not SMTX.IsMTXModule(module) or
                            not SMTX.IsAbsolutelyIrreducible(module) then
      Error(
 "Argument of InvariantSesquilinearForm is not an absolutely irreducible module"
   );
   fi;

   if IsBound(module.InvariantSesquilinearForm) then
     return module.InvariantSesquilinearForm;
   fi;
   DM:=SMTX.TwistedDualModule(module);
   iso:=MTX.IsomorphismIrred(module,DM);
   if iso = fail then
       SMTX.SetInvariantSesquilinearForm(module, fail);
       return fail;
   fi;
   # Replace iso by a scalar multiple to get iso twisted symmetric
   q:=Size(module.field);
   r:=RootInt(q,2);
   isot:=List( TransposedMat(iso), x -> List(x, y->y^r) );
   isot:=iso * isot^-1;
   if not IsDiagonalMat(isot) then
     Error("Form does not seem to be of the right kind (non-diagonal)!");
   fi;
   l:=LogFFE(isot[1][1],Z(q));
   if l mod (r-1) <> 0 then
     Error("Form does not seem to be of the right kind (not (q-1)st root)!");
   fi;
   iso:=Z(q)^(l/(r-1)) * iso;
   iso:=ImmutableMatrix(GF(q), iso);
   SMTX.SetInvariantSesquilinearForm(module, iso);
   return iso;
end;


SMTX.SetInvariantQuadraticForm:=function(module,b)
  module.InvariantQuadraticForm:=b;
end;

#############################################################################
##
#F  MTX.InvariantQuadraticForm( <module> )
##
##  <#GAPDoc Label="MTX.InvariantQuadraticForm">
##  <ManSection>
##  <Func Name="MTX.InvariantQuadraticForm" Arg='module'/>
##
##  <Description>
##  returns either the matrix of an invariant quadratic form of the
##  absolutely irreducible module <A>module</A>, or <K>fail</K>.
##  <P/>
##  If the characteristic of <A>module</A> is odd then <K>fail</K> is
##  returned if there is no nonzero invariant bilinear form,
##  otherwise a matrix of the bilinear form
##  divided by <M>2</M> is returned;
##  note that this matrix may be antisymmetric and thus describe the zero
##  quadratic form.
##  If the characteristic of <A>module</A> is <M>2</M> then <K>fail</K> is
##  returned if <A>module</A> does not admit a nonzero quadratic form,
##  otherwise a lower triangular matrix describing the form is returned.
##  <P/>
##  An error is signalled if <A>module</A> is not absolutely irreducible.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= SO(-1, 4, 2);;
##  gap> m:= GModuleByMats( GeneratorsOfGroup( g ), GF(2) );;
##  gap> Display( MTX.InvariantQuadraticForm( m ) );
##   . . . .
##   1 . . .
##   . . 1 .
##   . . 1 1
##  gap> g:= SP(4, 2);;
##  gap> m:= GModuleByMats( GeneratorsOfGroup( g ), GF(2) );;
##  gap> MTX.InvariantQuadraticForm( m );
##  fail
##  gap> g:= SP(4, 3);;
##  gap> m:= GModuleByMats( GeneratorsOfGroup( g ), GF(3) );;
##  gap> q:= MTX.InvariantQuadraticForm( m );;
##  gap> q = - TransposedMat( q );  # antisymmetric inv. bilinear form
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
SMTX.InvariantQuadraticForm:=function( module  )
   local iso, bas, cgens, ciso, dim, f, z, x, i, j, qf, g, id, cqf, fix;

   if not SMTX.IsMTXModule(module) or
                            not SMTX.IsAbsolutelyIrreducible(module) then
      Error(
 "Argument of InvariantQuadraticForm is not an absolutely irreducible module");
   fi;
   if IsBound(module.InvariantQuadraticForm) then
     return module.InvariantQuadraticForm;
   fi;
   iso:=SMTX.InvariantBilinearForm(module);
   if iso = fail then return fail; fi;
   if Characteristic(module.field) <> 2 then return iso/2; fi;

   # In characteristic two, we change to a basis in orbit.
   # This makes the search for an invariant quadratic form quicker.
   bas:=SMTX.BasisInOrbit(module);
   cgens:=List(module.generators, x->bas*x*bas^-1 );
   ciso:=List(bas * iso * TransposedMat(bas),ShallowCopy);
   dim:=module.dimension;
   f:=module.field;
   z:=Zero(f);

   # Matrix must be symplectic - perhaps it must be?
   for i in [1..dim] do if ciso[i][i] <> z then
     #Print("Non-symplectic failure!\n");
     return fail;
   fi; od;

   # If there is an invariant quadratic form, then it will be the lower
   # left hand part of ciso plus a scalar.
   for i in [1..dim-1] do for j in [i+1..dim] do ciso[i][j]:=z; od; od;
   id:=IdentityMat(dim, f);
   for x in f do
     qf:=ciso + x*id;
     fix:=true;
     # Form is preserved if and only if diagonal is.
     for g in cgens do
       cqf:=g * qf * TransposedMat(g);
       for j in [1..dim] do if cqf[j][j] <> x then
         fix:=false;
         break;
       fi; od;
       if not fix then break; fi;
     od;
     if fix then
       qf:=bas^-1 * qf * TransposedMat(bas^-1);
       # switch to lower triangular equivalent
       for i in [1..dim-1] do for j in [i+1..dim] do
         qf[j][i]:=qf[i][j] + qf[j][i];
         qf[i][j]:=z;
       od; od;
       qf:=ImmutableMatrix(f,qf);
       SMTX.SetInvariantQuadraticForm(module, qf);
       return qf;
     fi;
   od;
   SMTX.SetInvariantQuadraticForm(module, fail);
   return fail;
end;


#############################################################################
##
#F  MTX.OrthogonalSign( <module> ) . . . .
##
##  <#GAPDoc Label="MTX.OrthogonalSign">
##  <ManSection>
##  <Func Name="MTX.OrthogonalSign" Arg='module'/>
##
##  <Description>
##  Let <A>module</A> be an absolutely irreducible <M>G</M>-module.
##  If <A>module</A> does not fix a nondegenerate quadratic form
##  see <Ref Func="MTX.InvariantQuadraticForm"/>
##  then <K>fail</K> is returned.
##  Otherwise the sign <M>\epsilon \in \{ -1, 0, 1 \}</M> is returned
##  such that <M>G</M> embeds into the general orthogonal group
##  <M>GO^{\epsilon}(d, q)</M> w.r.t. the invariant quadratic form,
##  see <Ref Func="GeneralOrthogonalGroup"/>.
##  That is, <C>0</C> is returned if <A>module</A> has odd dimension,
##  and <C>1</C> or <C>-1</C> is returned if the orthogonal group has
##  plus or minus type, respectively.
##  <P/>
##  An error is signalled if <A>module</A> is not absolutely irreducible.
##  <P/>
##  The <C>SMTX</C> implementation uses an algorithm due to Jon Thackray.
##  <P/>
##  <Example><![CDATA[
##  gap> mats:= GeneratorsOfGroup( GO(1,4,2) );;
##  gap> MTX.OrthogonalSign( GModuleByMats( mats, GF(2) ) );
##  1
##  gap> mats:= GeneratorsOfGroup( GO(-1,4,2) );;
##  gap> MTX.OrthogonalSign( GModuleByMats( mats, GF(2) ) );
##  -1
##  gap> mats:= GeneratorsOfGroup( GO(5,3) );;
##  gap> MTX.OrthogonalSign( GModuleByMats( mats, GF(3) ) );
##  0
##  gap> mats:= GeneratorsOfGroup( SP(4,2) );;
##  gap> MTX.OrthogonalSign( GModuleByMats( mats, GF(2) ) );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
SMTX.SetOrthogonalSign:=function(module,s)
  module.OrthogonalSign:=s;
end;

SMTX.OrthogonalSign:=function(gm)
    local   b,  q,  k,  n,  W,  o,  z,  lo,  lzo,  lines,  l,  w,  p,
            x,  y,  r,  i;
    if IsBound(gm.OrthogonalSign) then
        return gm.OrthogonalSign;
    fi;
    b:=MTX.InvariantBilinearForm(gm);
    q:=MTX.InvariantQuadraticForm(gm);
    if q = fail then
        return fail;
    elif IsOddInt( Characteristic( gm.field ) ) and
         q <> TransposedMat( q ) then
        # There is no *nondegenerate* invariant quadratic form.
        return fail;
    fi;
    n:=Length(b);
    if n mod 2 = 1 then
        return 0;
    fi;
    k:=MTX.Field(gm);
    W:=IdentityMat(n,k);

    #
    # Assemble the points of projective 3-space
    #
    o:=One(k);
    z:=Zero(k);
    lo:=[o];
    lzo:=[z,o];
    lines:=List(AsSSortedList(FullRowSpace(k,2)),x -> Concatenation(lo,x));
    Append(lines,List(AsSSortedList(k), x-> Concatenation(lzo,[x])));
    Add(lines,[z,z,o]);

    #
    # Main loop of Thackray's algorithm, build up a totally isotropic
    # subspace and restrict its perp until the gap between is just 2 dimensional
    #

    while n > 2 do

        #
        # Find an isotropic vector
        #
        for l in lines do
            w:=l*W;
            if w*q*w = z then
                break;
            fi;
        od;
        Assert(1,w*b*w = z);
        p:=PositionNonZero(l);
        #
        # delete it from W (add it to the subspace)
        #
        W{[p..n-1]}:=W{[p+1..n]};
        Unbind(W[n]);
        n:=n-1;
        #
        # find a vector with which it has non-zero inner product
        #
        x:=w*b;
        p:=PositionProperty(W, row -> x*row <> z);
        Assert(1, p <> fail);
        #
        # use it to find the perp of the enlarged subspace
        #
        y:=W[p];
        r:=x*y;
        for i in [p+1..n] do
            AddRowVector(W[i], y, - x*W[i]/r);
            W[i-1]:=W[i];
        od;
        Unbind(W[n]);
        n:=n-1;
        #
        # Now n has gone down by 2 and W is still the "gap" between the
        # subspace and its perp
        #
    od;

    #
    # Now we need to see if the span of W contains an isotropic vector
    #
    if W[2]*q*W[2] = z then
        SMTX.SetOrthogonalSign(gm,1);
        return 1;
    else
        for x in k do
            w:=W[1]+x*W[2];
            if w*q*w = z then
                SMTX.SetOrthogonalSign(gm,1);
                return 1;
            fi;
        od;
        SMTX.SetOrthogonalSign(gm,-1);
        return -1;
    fi;
end;

