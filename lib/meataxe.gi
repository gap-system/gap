#############################################################################
##
#W  meataxe.gi                   GAP Library                       Derek Holt
#W                                                                 Sarah Rees
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$ 
##
#Y  Copyright 1994 -- School of Mathematical Sciences, ANU   
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the 'Smash'-MeatAxe modified for GAP4 and using the 
##  standard MeatAxe interface.  It defines the MeatAxe SMTX.
##
Revision.meataxe_gi:=
  "@(#)$Id$";

GModuleByMats:=function(l,f)
local dim,m;
  if ForAny(l,i->Length(i)<>Length(i[1])) or
    Length(Set(List(l,Length)))>1 then
    Error("<l> must be a list of square matrices of the same dimension");
  fi;
  dim:=Length(l[1][1]);

  m:=rec(field:=f,
         dimension:=dim,
	 generators:=l,
	 isMTXModule:=true
	 );

  return m;
end;

InfoMeatAxe:=NewInfoClass("InfoMeatAxe");

SMTX:=rec(name:="The Smash MeatAxe");
MTX:=SMTX;

SMTX.Getter := function(string)
  return function(module)
    if not (IsBound(module.smashMeataxe) and 
            IsBound(module.smashMeataxe.(string))) then
      return fail;
    else
      return module.smashMeataxe.(string);
    fi;
  end;
end;

SMTX.Setter := function(string)
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

SMTX.Dimension:=function(module)
  return module.dimension;
end;

SMTX.Field:=function(module)
  return module.field;
end;

SMTX.Generators:=function(module)
  return module.generators;
end;

SMTX.SetIsIrreducible:=function(module,b)
  module.IsIrreducible:=b;
end;

SMTX.HasIsIrreducible:=function(module)
  return IsBound(module.IsIrreducible);
end;

SMTX.IsAbsolutelyIrreducible:=function(module)
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
SMTX.AlgEl:=SMTX.Getter("algel");
SMTX.SetAlgEl:=SMTX.Setter("algel");
SMTX.AlgElMat:=SMTX.Getter("algelmat");
SMTX.SetAlgElMat:=SMTX.Setter("algelmat");
SMTX.AlgElCharPol:=SMTX.Getter("charpol");
SMTX.SetAlgElCharPol:=SMTX.Setter("charpol");
SMTX.AlgElCharPolFac:=SMTX.Getter("charpolFac");
SMTX.SetAlgElCharPolFac:=SMTX.Setter("charpolFac");
SMTX.AlgElNullspaceVec:=SMTX.Getter("nullspVec");
SMTX.SetAlgElNullspaceVec:=SMTX.Setter("nullspVec");
SMTX.AlgElNullspaceDimension:=SMTX.Getter("ndimFlag");
SMTX.SetAlgElNullspaceDimension:=SMTX.Setter("ndimFlag");

SMTX.CentMat:=SMTX.Getter("centMat");
SMTX.SetCentMat:=SMTX.Setter("centMat");
SMTX.CentMatMinPoly:=SMTX.Getter("centMatMinPoly");
SMTX.SetCentMatMinPoly:=SMTX.Setter("centMatMinPoly");

SMTX.SetDegreeFieldExt:=SMTX.Setter("degreeFieldExt");

FieldOfMatrixList := function(l)
local i,j,k,fg,f;
  # try to find out the field
  if Length(l)=0 or ForAny(l,i->not IsMatrix(i)) then
    Error("<l> must be a list of matrices");
  fi;
  fg:=[l[1][1][1]];
  f:=Field(fg);
  for i in l do
    for j in i do
      for k in j do
        if not j in f then
	  Add(fg,j);
	  f:=Field(fg);
	fi;
      od;
    od;
  od;
  return f;
end;

LinearCombinationVecs := function(v,c)
  return Sum([1..Length(c)],i->c[i]*v[i]);
end;


#############################################################################
##
#F  SMTX.OrthogonalVector( subbasis ) single vector othogonal to a submodule,
##  N.B. subbasis is assumed to consist of normed vectors, 
##  submodule is assumed proper.
##
SMTX.OrthogonalVector := function ( subbasis )
   local zero, one, v, i, j, k, x, dim, len;
   Sort (subbasis);
   subbasis := Reversed (subbasis);
   # Now subbasis is in order so that the vector whose leading coefficient
   # comes furthest to the left comes first.
   len := Length (subbasis);
   dim := Length (subbasis[1]);
   i :=  1;
   v := [];
   one := One(subbasis[1][1]);
   zero := Zero(one);
   for i in [1..dim] do
      v[i] := zero;
   od;
   i := 1;
   while i <= len and subbasis[i][i] = one do
      i :=  i + 1;
   od;
   v[i] := one;
   for j in Reversed ([1..i-1]) do
      x := zero;
      for k in [j + 1..i] do
         x := x + v[k] * subbasis[j][k];
      od;
      v[j] := -x;
   od;

   return v;
end;

#############################################################################
##
#F  SpinnedBasis ( v, matrices, [ngens] ) . . . . 
## 
## SpinnedBasis computes a basis for the submodule defined by the action of the
## matrix group generated by the list matrices on the vector v.
## It is returned as a list of normed vectors.
## If the optional third argument is present, then only the first ngens
## matrices in the list are used.
SMTX.SpinnedBasis := function ( arg  )
   local   v, matrices, ngens, zero,  
           ans, dim, subdim, leadpos, w, i, j, k, l, m;

   if Number (arg) < 2 or Number (arg) > 3 then
      Error ("Usage:  SpinnedBasis ( v, matrices, [ngens] )");
   fi;
   v := arg[1];
   matrices := arg[2];
   if Number (arg) = 3 then
      ngens := arg[3];
      if ngens <= 0 or ngens > Length (matrices) then
         ngens := Length (matrices);
      fi;
   else
      ngens := Length (matrices);
   fi;
   zero := Zero(matrices[1][1][1]);
   ans := [];
   dim := Length (v);
   leadpos := [];

   j := 1;
   while j <= dim and v[j] = zero do j := j + 1; od;
   if j > dim then
      return ans;
   fi;
   subdim := 1;
   leadpos[1] := j;
   w := (v[j]^-1) * v;
   Add ( ans, w );

   i := 1;
   while i <= subdim do
      for l in [1..ngens] do
         m := matrices[l];
         # apply generator m to submodule generator i
         w := ans[i] * m;
         # try to express w in terms of existing submodule generators
         j := 1;
         for  j in [1..subdim] do
            k := w[leadpos[j]];
            if k <> zero then
               w := w - k * ans[j];
            fi;
         od;

         j := 1;
         while j <= dim and w[j] = zero do j := j + 1; od;
         if j <= dim then
            #we have found a new generator of the submodule
            subdim := subdim + 1;
            leadpos[subdim] := j;
            w := (w[j]^-1) * w;
            Add ( ans, w );
            if subdim = dim then
               return ans;
            fi;
         fi;
      od;
      i := i + 1;
   od;

   return ans;
end;

SubGModLeadPos := function(sub,dim,subdim,zero)
local leadpos,cfleadpos,i,j,k;
   ## As in SpinnedBasis, leadpos[i] gives the position of the first nonzero 
   ## entry (which will always be 1) of sub[i].

   leadpos := [];
   cfleadpos := [];
   for i in [1..dim] do cfleadpos[i] := 0; od;
   for i in [1..subdim] do
      j := 1;
      while j <= dim and sub[i][j]=zero do j := j + 1; od;
      leadpos[i] := j; cfleadpos[j] := 1;
      for k in [1..i - 1] do
         if leadpos[k] = j then
            Error ("Subbasis isn't normed.");
         fi;
      od;
   od;
  return [leadpos,cfleadpos];
end;

#############################################################################
##
#F  SMTX.SubQuotActionsModule (matrices,sub,dim,subdim,one,typ) . . .  
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
SMTX.SubQuotActions := function(matrices,sub,dim,subdim,one,typ)
local c,q,i,j,k,w,zero,leadpos,cfleadpos, m, ct, erg,
           g, newg, newgn, smatrices, qmatrices, nmatrices, 
           im, newim, newimn;

   zero:=Zero(one);
   c:=typ>3; # common indicator
   q:=c or (typ mod 4)>1; # quotient indicator

   leadpos:=SubGModLeadPos(sub,dim,subdim,zero);
   cfleadpos:=leadpos[2];
   leadpos:=leadpos[1];

   ## Now add a further dim-subdim vectors to the list sub, to complete a basis.
   if q then
     sub := ShallowCopy (sub);
     k := subdim;
     for i in [1..dim] do
	if cfleadpos[i] = 0 then
	   k := k + 1;
	   w := [];
	   for m in [1..dim] do w[m] := zero; od;
	   w[i] := one;
	   leadpos[k] := i;
	   Add (sub, w);
	fi;
     od;
   fi;

   erg:=rec();

   nmatrices := [];
   if (typ mod 2)>0 then
     ## Now work out action of generators on submodule
     smatrices := [];
     for g in matrices do
	newg := []; newgn := [];
	for i in [1..subdim] do
	   im := sub[i] * g;
	   newim := []; newimn := [];
	   for j in [1..subdim] do
	      k := im[leadpos[j]];
	      newim[j] := k; newimn[j] := k;
	      if k<> zero then
		 im := im - k * sub[j];
	      fi;
	   od;

	   # Check that the vector is now zero - if not, then sub was 
	   # not the basis of a submodule 
	   if im <> im * zero then return fail; fi;
	   Add (newg, newim);

	   if c then
	     for j in [subdim + 1..dim] do newimn[j] := zero; od;
	     Add (newgn, newimn);
	   fi;

	od;
	Add (smatrices, newg);
	Add (nmatrices, newgn);
     od;
     erg.smatrices:=smatrices;
   else
     nmatrices:=List(matrices,i->[]);
   fi;

   if q then
     ## Now work out action of generators on quotient module
     qmatrices := [];
     ct := 0;
     for g in matrices do
	ct := ct + 1;
	newg := []; newgn := nmatrices[ct];
	for i in [subdim + 1..dim] do
	   im := sub[i] * g;
	   newim := []; newimn := [];
	   for j in [1..dim] do
	      k := im[leadpos[j]];
	      if j > subdim then
		 newim[j - subdim] := k;
	      fi;
	      if k <> zero then
		 im := im - k * sub[j];
	      fi;
	      newimn[j] := k;
	   od;
	   Add (newg, newim);   
	   Add (newgn, newimn);
	od;
	Add (qmatrices, newg);
     od;
     erg.qmatrices:=qmatrices;
     erg.nbasis:=sub;
     if c then
       erg.nmatrices:=nmatrices;
     fi;
   fi;

   return erg;
end;


#############################################################################
##
##  SMTX.NormedBasisAndBaseChange(sub)
##
##  returns a list [bas,change] where bas is a normed basis for <sub> and
##  change is the base change from bas to sub (the basis vectors of bas
##  expressed in coefficients for sub)
SMTX.NormedBasisAndBaseChange := function(sub)
local l,m;
  l:=Length(sub);
  m:=MutableIdentityMat(l,One(sub[1][1]));
  sub:=List([1..l],i->Concatenation(List(sub[i],ShallowCopy),m[i]));
  TriangulizeMat(sub);
  m:=Length(sub[1]);
  return [sub{[1..l]}{[1..l]},sub{[1..l]}{[l+1..m]}];
end;

#############################################################################
##
#F  SMTX.InducedActionSubmoduleNB ( module, sub ) . . . . . construct submodule
##
## module is a module record, and sub is a list of generators of a submodule.
## IT IS ASSUMED THAT THE GENERATORS OF SUB ARE NORMED.
## (i.e. each has leading coefficient 1 in a unique place).
## SMTX.InducedActionSubmoduleNB ( module, sub ) computes the submodule of
## module for which sub is the basis.
## If sub does not generate a submodule then fail is returned.
SMTX.InducedActionSubmoduleNB := function ( module, sub )
   local   ans, dim, subdim, smodule,F;

   subdim := Length (sub);
   if subdim = 0 then
      return List(module.generators,i->[[]]);
   fi;
   dim := SMTX.Dimension(module);
   F:=SMTX.Field(module);

   ans:=SMTX.SubQuotActions(SMTX.Generators(module),
                                sub,dim,subdim,One(F),1);

   if ans=fail then
     return fail;
   fi;

   smodule := GModuleByMats (ans.smatrices,F);
   return smodule;
end;

# Dito, but allowing also unnormed modules
SMTX.InducedActionSubmodule := function(module,sub)
local nb,ans,dim,subdim,smodule,F;
  nb:=SMTX.NormedBasisAndBaseChange(sub);
  sub:=nb[1];
  nb:=nb[2];

   subdim := Length (sub);
   if subdim = 0 then
      return List(module.generators,i->[[]]);
   fi;
   dim := SMTX.Dimension(module);
   F:=SMTX.Field(module);

   ans:=SMTX.SubQuotActions(SMTX.Generators(module),
                                sub,dim,subdim,One(F),1);

   if ans=fail then
     return fail;
   fi;

   # conjugate the matrices to correspond to given sub
   smodule := GModuleByMats (List(ans.smatrices,i->i^nb),F);
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
#F  SMTX.InducedActionFactorModule( module, sub [,compl] ) .  . generators of quotient
##
## module is a module record, and sub is a list of generators of a submodule.
## (i.e. each has leading coefficient 1 in a unique place).
## Qmodule is returned, where qmodule
## is the quotient module.
## 
SMTX.InducedActionFactorModule := function (arg)
local module,sub,  ans, dim, subdim, F,qmodule;

   module:=arg[1];
   sub:=arg[2];

   sub:=List(sub,ShallowCopy);
   TriangulizeMat(sub);

   subdim := Length (sub);
   dim := SMTX.Dimension(module);
   if subdim = dim then
      return List(module.generators,i->[[]]);
   fi;

   F:=SMTX.Field(module);

   ans:=SMTX.SubQuotActions(SMTX.Generators(module),
                                sub,dim,subdim,One(F),2);

   if ans=fail then
     return fail;
   fi;

   if Length(arg)=3 then
     # compute basechange
     sub:=Concatenation(sub,arg[3]);
     sub:=sub*Inverse(ans.nbasis);
     ans.qmatrices:=List(ans.qmatrices,i->i^sub);
   fi;

   qmodule := GModuleByMats (ans.qmatrices, F);
   return qmodule;

end;

#############################################################################
##
#F  SMTX.InducedActionFactorModuleWithBasis( module, sub ) 
##
SMTX.InducedActionFactorModuleWithBasis := function (module,sub)
local ans, dim, subdim, F,qmodule;

   sub:=List(sub,ShallowCopy);
   TriangulizeMat(sub);

   subdim := Length (sub);
   dim := SMTX.Dimension(module);
   if subdim = dim then
      return List(module.generators,i->[[]]);
   fi;

   F:=SMTX.Field(module);

   ans:=SMTX.SubQuotActions(SMTX.Generators(module),
                                sub,dim,subdim,One(F),2);

   if ans=fail then
     return fail;
   fi;

   # fetch new basis
   sub:=ans.nbasis{[Length(sub)+1..module.dimension]};

   qmodule := GModuleByMats (ans.qmatrices, F);
   return [qmodule,sub];

end;

#############################################################################
##
#F  SMTX.InducedAction( module, sub, typ ) . . .  
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
SMTX.InducedAction := function ( arg )
local module,sub,typ,ans,dim,subdim,F,one,erg;

   module:=arg[1];
   sub:=arg[2];
   if Length(arg)>2 then
     typ:=arg[3];
   else
     typ:=7;
   fi;
   subdim := Length (sub);
   dim := SMTX.Dimension(module);
   F := SMTX.Field(module); one := One (F);

   erg:=SMTX.SubQuotActions(SMTX.Generators(module),
                                sub,dim,subdim,one,typ);

   if erg=fail then
     return fail;
   fi;

   ans:=[];

   if IsBound(erg.smatrices) then
     Add(ans,GModuleByMats(erg.smatrices, F));
   fi;
   if IsBound(erg.qmatrices) then
     Add(ans,GModuleByMats(erg.qmatrices, F));
   fi;
   if IsBound(erg.nmatrices) then
     Add(ans,GModuleByMats(erg.nmatrices, F));
   fi;
   if IsBound(erg.nbasis) then
     Add(ans,erg.nbasis);
   fi;

   return ans;

end;

SMTX.SMCoRaEl:=function(matrices,ngens,newgenlist,dim,F)
local g1,g2,coefflist,M,pol;
  g1 := Random ([1..ngens]);
  g2 := g1;
  while g2=g1 and ngens>1 do
     g2 := Random ([1..ngens]);
  od;
  ngens := ngens + 1;
  matrices[ngens] := matrices[g1] * matrices[g2];
  Add (newgenlist, [g1, g2]);
  # Take a random linear sum of the existing generators as new generator.
  # Record the sum in coefflist
  coefflist := [];
  M := NullMat (dim, dim, F);
  for g1 in [1..ngens] do
     g2 := Random (F);
     M := M + g2 * matrices[g1];
     Add (coefflist, g2);
  od;
  Info(InfoMeatAxe,2,"Evaluated random element in algebra.");
  pol := CharacteristicPolynomial (F,M);
  return [M,coefflist,pol];
end;

#############################################################################
##
#F  SMTX.IrreduciblityTest( module ) try to reduce a module over a finite
##                                      field
##
## module is a module record
## IsIrreducible ( ) attempts to decide whether module is irreducible.
## When it succeeds it returns true or false.
## We choose at random elements of the group algebra of the group.
## If el is such an element, we define M, p, fac, N, e and v as follows:-
## M is the matrix corresponding to el, p is its characteristic polynomial, 
## fac an irreducible factor of p, N the nullspace of the matrix fac (M), 
## ndim the dimension of N, and v a vector in N.
## If we can find the above such that ndim = deg (fac) then we can test
## conclusively for irreducibility. Then, in the case where irreducibility is
## proved, we store the information as fields for the module, since it may be
## useful later (e.g. to test for absolute irreducibility, equivalence with
## another module).
## These  fields are accessed by the functions
## AlgEl() (el), AlgElMat (M), AlgElCharPol (p), 
## AlgElCharPolFac (fac), AlgElNullspaceDimension (ndim), and
## AlgElNullspaceVec(v).
## 
## If we cannot find such a set with ndim = deg (fac) we may nonetheless prove
## reducibility  by finding a submodule. However we can never prove
## irreducibility without such a set (and hence the algorithm could run
## forever, but hopefully this will never happen!)
## Where reducibility is proved, we set the field .subbasis
## (a basis for the submodule, normed in the sense that the first non-zero
## component of each basis vector is 1, and is in a different position from
## the first non-zero component of every other basis vector).
## The test for irreducibility is based on the meataxe method  (but in the
## meataxe, ndim is always very small, usually 1. The modification here is put
## in to enable the method to work over modules with large centralizing fields).
## We simply spin v. If we do not get  the whole space, we have a submodule, 
## on the other hand, if we do get the whole space, we calculate the 
## nullspace NT of the transpose of fac (M), spin that under the group 
## generated by the transposes of the generating matrices, and thus either 
## find the transpose of a submodule or conclusively prove irreducibility.
##
## This function can also be used to get a random submodule. Therefore it
## is not an end-user function but only called internally
SMTX.IrreducibilityTest := function ( module )
   local matrices, tmatrices, ngens, ans,  M, mat, g1, g2, maxdeg, 
         newgenlist, coefflist, orig_ngens, zero, 
         N, NT, v, subbasis, sq, fac, sfac, pol, orig_pol, q, dim, ndim, i, k, 
         l, trying, deg, facno, bestfacno, F, count, R, rt0 ;

   rt0 := Runtime ();
   Info(InfoMeatAxe,1,"Calling MeatAxe. All times will be in milliseconds");
   if not SMTX.IsMTXModule (module) then 
      return Error ("Argument of IsIrreducible is not a module.");
   fi;

   matrices := ShallowCopy(SMTX.Generators(module));
   dim := SMTX.Dimension(module);
   ngens := Length (matrices);
   orig_ngens := ngens;
   F := SMTX.Field(module);
   zero := Zero (F);
   R := PolynomialRing (F);

   # Now compute random elements M of the group algebra, calculate their
   # characteristic polynomials, factorize, and apply the irreducible factors
   # to M to get matrices with nontrivial nullspaces.
   # tmatrices will be a list of the transposed generators if required.

   tmatrices := [];
   trying := true; 
   #trying will become false when we have an answer
   maxdeg := 1;
   newgenlist := [];
   # Do a small amount of preprocessing to increase the generator set.
   for i in [1..1] do
      g1 := Random ([1..ngens]);
      g2 := g1;
      while g2=g1 and Length (matrices) > 1 do
         g2 := Random ([1..ngens]);
      od;
      ngens := ngens + 1;
      matrices[ngens] := matrices[g1] * matrices[g2];
      Add (newgenlist, [g1, g2]);
   od;
   Info(InfoMeatAxe,1,"Done preprocessing. Time = ",Runtime()-rt0,".");
   count := 0;

   #Main loop starts - choose a random element of group algebra on each pass
   while trying  do
      count := count + 1;
      if count > 50 then
         Error ("Have generated 50 random elements and failed to prove\n",
	        "or disprove irreducibility.");
      fi;
      maxdeg := maxdeg * 2;
      # On this pass, we only consider irreducible factors up to degree maxdeg.
      # Using higher degree factors is very time consuming, so we prefer to try
      # another element.
      # To choose random element, first add on a new generator as a product of
      # two randomly chosen unequal existing generators
      # Record the product in newgenlist.
      Info(InfoMeatAxe,1,"Choosing random element number ",count);

      M:=SMTX.SMCoRaEl(matrices,ngens,newgenlist,dim,F);

      ngens:=Length(matrices);

      coefflist:=M[2];
      pol:=M[3];
      M:=M[1];

      orig_pol := pol;
      Info(InfoMeatAxe,2,"Evaluated characteristic polynomial. Time = ",
           Runtime()-rt0,".");
      #Now we extract the irreducible factors of pol starting with those 
      #of low degree
      deg := 0;
      fac := [];
      #The next loop is through the degrees of irreducible factors
      while DOULP (pol) > 0 and deg < maxdeg and trying do
         repeat
            deg := deg + 1;
            if deg > Int (DOULP (pol) / 2) then
               fac := [pol];
            else
               fac := Factors(R, pol, rec(onlydegs:=[deg]));
	       fac:=Filtered(fac,i->DOULP(i)<=deg);
               Info(InfoMeatAxe,2,Length (fac)," factors of degree ",deg,
	            ", Time = ",Runtime()-rt0,".");
            fi;
         until fac <> [] or deg = maxdeg;

         if fac <> [] then
            if DOULP (fac[1]) = dim then 
               # In this case the char poly is irreducible, so the 
               # module is irreducible.
               ans := true;
               trying := false; 
               bestfacno := 1;
               v := ListWithIdenticalEntries(dim,zero);
               v[1] := One (F);
               ndim := dim;
            fi; 
            # Otherwise, first see if there is a non-repeating factor.
            # If so it will be decisive, so delete the rest of the list
            l := Length (fac);
            facno := 1;
            while facno <= l and trying do
               if facno = l  or  fac[facno] <> fac[facno + 1] then
                  fac := [fac[facno]]; l := 1;
               else
                  while facno < l and fac[facno] = fac[facno + 1] do
                     facno := facno + 1;
                  od;
               fi;
               facno := facno + 1;
            od;
            # Now we can delete repetitions from the list fac
            sfac := Set (fac);

            if DOULP (fac[1]) <> dim then
               # Now go through the factors and attempt to find a submodule
               facno := 1; l := Length (sfac);
               while facno <= l and trying do
                  mat := Value (sfac[facno], M);
                  Info(InfoMeatAxe,2,"Evaluated matrix on factor. Time = ",
		       Runtime()-rt0,".");
                  N := NullspaceMat (mat);
                  v := N[1];
                  ndim := Length (N);
                  Info(InfoMeatAxe,2,"Evaluated nullspace. Dimension = ",
		       ndim,". Time = ",Runtime()-rt0,".");
                  subbasis := SMTX.SpinnedBasis (v, matrices, orig_ngens);
                  Info(InfoMeatAxe,2,"Spun up vector. Dimension = ",
		       Length(subbasis),". Time = ",Runtime()-rt0,".");
                  if Length (subbasis) < dim then
                     # Proper submodule found 
                     trying := false;
                     ans := false;
                     SMTX.SetSubbasis(module, subbasis);
                  elif ndim = deg then
                     trying := false;
                     # if we transpose and find no proper submodule, then the
                     # module is definitely irreducible. 
                     mat := TransposedMat (mat);
                     if Length (tmatrices)=0 then
                        for i in [1..orig_ngens] do
                           Add (tmatrices, TransposedMat (matrices[i]));
                        od;
                     fi;
                     Info(InfoMeatAxe,2,"Transposed matrices. Time = ",
		          Runtime()-rt0,".");
                     NT := NullspaceMat (mat);
                     Info(InfoMeatAxe,2,"Evaluated nullspace. Dimension = ",
		          Length(NT),". Time = ",Runtime()-rt0, ".");
                     subbasis:=SMTX.SpinnedBasis(NT[1],tmatrices,orig_ngens);
		     Info(InfoMeatAxe,2,"Spun up vector. Dimension = ",
		          Length(subbasis),". Time = ",Runtime()-rt0, ".");
                     if Length (subbasis) < dim then
                        # subbasis is a basis for a submodule of the transposed 
                        # module, and the orthogonal complement of this is a 
                        # submodule of the original module. So we find a vector                         # v in that, and then spin it. Of course we won't 
                        # necessarily get the full orthogonal complement 
                        # that way, but we'll certainly get a proper submodule.
                        v := SMTX.OrthogonalVector (subbasis);
                        SMTX.SetSubbasis(module,
			  SMTX.SpinnedBasis(v,matrices,orig_ngens));
                        ans := false;
                     else
                        ans := true;
                        bestfacno := facno;
                     fi;
                  fi;
                  facno := facno + 1;
               od; # going through irreducible factors of fixed degree.
               # If trying is false at this stage, then we don't have 
               #an answer yet, so we have to go onto factors of the next degree.
               # Now divide p by the factors used if necessary
               if trying and deg < maxdeg then
                  for q in fac do
                     pol := Quotient (R, pol, q);
                  od;
               fi; 
            fi;           #DOULP (fac[1]) <> dim
         fi;             #fac <> []
      od; #loop through degrees of irreducible factors

      # if we have not found a submodule and trying is false, then the module
      # must be irreducible.
      if trying = false and ans = true then
         SMTX.SetAlgEl(module, [newgenlist, coefflist]);
         SMTX.SetAlgElMat (module, M);
         SMTX.SetAlgElCharPol (module, orig_pol);
         SMTX.SetAlgElCharPolFac (module, sfac[bestfacno]);
         SMTX.SetAlgElNullspaceVec(module, v);
         SMTX.SetAlgElNullspaceDimension (module, ndim);
      fi;

   od;  #main loop

   # das kommt in die eigentliche Methode!
   #if ans = true then 
   #   SMTX.SetReducibleFlag (module, false);
   #else 
   #   SMTX.SetReducibleFlag (module, true);
   #fi;

   Info(InfoMeatAxe,1,"Total time = ",Runtime()-rt0," microseconds.");
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
#F SMTX.RandomIrreducibleSubGModule ( module ) . . .
## find a basis for a random irreducible
## submodule of module, and return that basis and the submodule, with all
## the irreducibility flags set.
## Returns false if module is irreducible.
SMTX.RandomIrreducibleSubGModule := function ( module )
   local  ranSub, subbasis, submodule, subbasis2, submodule2,
   F, dim, el, M, fac, N, i, matrices, ngens, genpair;

   if not SMTX.IsMTXModule (module) then 
      return Error ("Argument of RandomIrreducibleSubGModule is not a module.");
   elif SMTX.HasIsIrreducible(module) and SMTX.IsIrreducible(module) then
      return false;
   fi;

   # now call an irreducibility test that will compute a new subbasis

#AH Do we really want to keep old flags? What are they good for?
#      copymodule := Copy (module);
#      UndoReducibleFlag (copymodule);
#      # Do this to avoid changing the flags in the original module
#      # We need to undo the reducible falgs before calling IsIrreducible 
#      # so that it actually runs and doesn't merely select the submodule 
#      # already listed as a field of module.

   i:=SMTX.IrreducibilityTest(module);

   if i then
     # we just found out it is irreducible
     SMTX.SetIsIrreducible(module,true);
     return false;
   elif not SMTX.HasIsIrreducible(module) then
     # or store reducibility
     SMTX.SetIsIrreducible(module,false);
   fi;

   subbasis := SMTX.Subbasis (module);
   submodule := SMTX.InducedActionSubmoduleNB (module, subbasis);
   ranSub := SMTX.RandomIrreducibleSubGModule (submodule);
   if ranSub = false then
      # submodule has been proved irreducible in a call to this function, 
      # so the flags have been set.
      return [ subbasis, submodule] ;
   else 
      # ranSub[1] is given in terms of the basis for the submodule, 
      # but we want it in terms of the basis of the original module.
      # So we multiply it by subbasis.
      # Then we need our basis to be normed. 
      # this is done by triangulization
      F := SMTX.Field(module);
      subbasis2 := ranSub[1] * subbasis;
      TriangulizeMat(subbasis2);

      # But now since we've normed the basis subbasis2, 
      # the matrices of the submodule ranSub[2] are given with respect to 
      # the wrong basis.  So we have to recompute the submodule.
      submodule2 := SMTX.InducedActionSubmoduleNB (module, subbasis2);
      # Unfortunately, although it's clear that this submodule is 
      # irreducible, we'll have to reset the flags that IsIrreducible sets. 
      # AH Why can't we keep irreducibility?

      # Some will be the same # as in ranSub[2], but some are affected by 
      # the base change, or at least part of it, since the flags gets 
      # screwed up by the base change.
      # We need to set the following flags:-

      # ReducibleFlag
      # AlgEl(el), AlgElMat (M), AlgElCharPol (p), 
      # AlgElCharPolFac (fac), AlgElNullspaceDimension (ndim), and
      # AlgElNullspaceVec(v).
      # Most of these can simply be copied.
#AHSetReducibleFlag (submodule2, false);

      el:=SMTX.AlgEl(ranSub[2]); 
      SMTX.SetAlgEl(submodule2,el);
      SMTX.SetAlgElCharPol(submodule2,SMTX.AlgElCharPol(ranSub[2]));
      fac:=SMTX.AlgElCharPolFac(ranSub[2]);
      SMTX.SetAlgElCharPolFac(submodule2,fac);
      SMTX.SetAlgElNullspaceDimension(submodule2,
             SMTX.AlgElNullspaceDimension(ranSub[2]));

      # Only the actual algebra element and its nullspace have to be recomputed
      # This code is essentially from IsomorphismGModule 
      dim:=SMTX.Dimension(submodule2);
      matrices:=ShallowCopy(SMTX.Generators(submodule2));
      ngens:=Length (matrices);
      for genpair in el[1] do
         ngens := ngens + 1;
         matrices[ngens] := matrices[genpair[1]] * matrices[genpair[2]];
      od;
      M:=NullMat(dim,dim,Zero(F));
      for i in [1..ngens] do M := M + el[2][i] * matrices[i]; od;
      SMTX.SetAlgElMat(submodule2,M);
      N := NullspaceMat(Value(fac,M));
      SMTX.SetAlgElNullspaceVec(submodule2,N[1]);
      return [subbasis2, submodule2];
   fi;

end;


#############################################################################
##
#F  SMTX.GoodElementGModule ( module ) . .  find good group algebra element
##                                       in an irreducible module
##
## module is a module that is already known to be irreducible.
## GoodElementGModule finds a group algebra element with nullspace of 
## minimal possible dimension. This dimension is 1 if the module is absolutely
## irreducible, and the degree of the relevant field extension otherwise.
## This is needed for testing for equivalence of modules.
SMTX.GoodElementGModule := function ( module )

   local matrices, ngens, el, M, mat,  N, newgenlist, coefflist, orig_ngens, 
         g1, g2, fac, sfac, pol, oldpol,  q, deg, i, k, l, 
         trying, dim, mindim, F, R, count, rt0;

   rt0 := Runtime ();
   if not SMTX.IsMTXModule(module) or not SMTX.IsIrreducible(module) then
     return Error ("Argument is not an irreducible module.");
   fi;
   if not SMTX.HasIsAbsolutelyIrreducible(module) then
      SMTX.IsAbsolutelyIrreducible(module);
   fi;
   if  SMTX.IsAbsolutelyIrreducible(module) then
     mindim:=1;
   else 
     mindim:=SMTX.DegreeFieldExt(module);
   fi;

   if SMTX.AlgElNullspaceDimension (module) = mindim then return; fi;
   # This is the condition that we want. If it holds already, then there is
   # nothing else to do.

   dim := SMTX.Dimension(module);
   matrices:=ShallowCopy(SMTX.Generators(module));
   ngens := Length (matrices);
   orig_ngens := ngens;
   F:=SMTX.Field(module);
   R:=PolynomialRing(F);

   # Now compute random elements el of the group algebra, calculate their
   # characteristic polynomials, factorize, and apply the irreducible factors
   # to el to get matrices with nontrivial nullspaces.

   trying := true; 
   count := 0;
   newgenlist := [];
   while trying do
      count := count + 1;
      if count > 50 then
         Error ("Have generated 50 random elements and failed ",
	        "to find a good one.");
      fi;
      Info(InfoMeatAxe,2,"Choosing random element number ",count,".");

      M:=SMTX.SMCoRaEl(matrices,ngens,newgenlist,dim,F);
      ngens:=Length(matrices);

      coefflist:=M[2];
      pol:=M[3];
      M:=M[1];

      Info(InfoMeatAxe,2,"Evaluated characteristic polynomial. Time = ",
           Runtime()-rt0,".");
      #That is necessary in case p is defined over a smaller field that F.
      oldpol := pol;
      #Now we extract the irreducible factors of pol starting with those 
      #of low degree
      deg := 0;
      fac := [];
      while deg  <= mindim and trying do
         repeat
            deg := deg + 1;
            if deg > mindim then
               fac := [pol];
            else
               fac := Factors(R, pol, rec(onlydegs:=[deg]));
	       fac:=Filtered(fac,i->DOULP(i)<=deg);
               Info(InfoMeatAxe,2,Length(fac)," factors of degree ",deg,
	            ", Time = ",Runtime()-rt0,".");
               sfac := Set (fac);
            fi;
         until fac <> [];
         l := Length (fac);
         if trying and deg <= mindim then
            i := 1;
            while i <= l and trying do
               mat := Value (fac[i], M);
               Info(InfoMeatAxe,2,"Evaluated matrix on factor. Time = ",
	            Runtime()-rt0,".");
               N := NullspaceMat(mat);
               Info(InfoMeatAxe,2,"Evaluated nullspace. Dimension = ",
		    Length(N),". Time = ",Runtime()-rt0,".");
               if Length (N) = mindim then
                  trying := false;
                  SMTX.SetAlgEl(module, [newgenlist, coefflist]);
                  SMTX.SetAlgElMat (module, M);
                  SMTX.SetAlgElCharPol (module, oldpol);
                  SMTX.SetAlgElCharPolFac (module, fac[i]);
                  SMTX.SetAlgElNullspaceVec(module, N[1]);
                  SMTX.SetAlgElNullspaceDimension (module, Length (N));
               fi;
               i := i + 1;
            od;
         fi;

         if trying then
            for q in fac do
               pol := Quotient (R, pol, q);
            od;
         fi; 
      od;
   od;
   Info(InfoMeatAxe,1,"Total time = ",Runtime()-rt0," microseconds.");

end;

#############################################################################
##
#F  EnlargedIrreducibleGModule (module, mat) . .add a generator to a module that
#
# 2bdef!


#############################################################################
##
#F  SMTX.FrobeniusAction (A, v [, basis]) . . action of matrix A on
##                                  . . Frobenius block of vector v
##
## FrobeniusAction (A, v) computes the Frobenius block of the dxd matrix A
## generated by the length - d vector v, and returns it.
## It is based on code of MinPolCoeffsMat.
## The optional third argument is for returning the basis for this block.
##
SMTX.FrobeniusAction := function ( arg )

   local   L, d, p, M, one, zero, R, h, v, w, i, j, nd, ans, 
           A, basis;

   if Number (arg) = 2  then
      A := arg[1];
      v := arg[2];
      basis := 0;
   elif Number (arg) = 3  then
      A := arg[1];
      v := arg[2];
      basis := arg[3];
   else
      return Error ("usage: SMTX.FrobeniusAction ( <A>, <v>, [, <basis>] )");
   fi;
   one :=One(A[1][1]);
   zero := Zero(one);
   d := Length ( A );
   M := ListWithIdenticalEntries(Length(A[1]),zero);
   Add ( M, M[1] );

   # L[i] (length d) will contain a vector with head entry 1 at position i,
   # which is in the current block.
   # R[i] (length d + 1 but (d + 1) - entry always 0) is vector expressing
   # L[i] in terms of the basis of the block.
   L := [];
   R := [];

   # <j> - 1 gives the power of <A> we are looking at
   j := 1;

   # spin vector around and construct polynomial
   repeat

      # compute the head of <v>
      h := 1;
      while v[h] = zero  do
         h := h + 1;
      od;

      # start with appropriate polynomial x^(<j> - 1)
      p := ShallowCopy ( M );
      p[j] := one;

      # divide by known left sides
      w := v;
      while h <= d and IsBound ( L[h] ) do
         p := p - w[h] * R[h];
         w := w - w[h] * L[h];
         while h <= d and w[h] = zero do
            h := h + 1;
         od;
      od;

      # if <v> is not the zero vector try next power
      if h <= d  then
	 #AH replaced Copy by ShallowCopy as only vector is used
         if (basis <> 0) then basis[j] := ShallowCopy (v); fi;
         R[h] := p * w[h]^-1;
         L[h] := w * w[h]^-1;
         j := j + 1;
         v := v * A;
      fi;
   until h > d;

   nd := Length (p);
   while 0 < nd  and p[nd] = zero  do
      nd := nd - 1;
   od;
   nd := nd - 1;
   ans := [];
   for i in [1..nd - 1] do
      ans[i] := [];
      for j in [1..nd] do ans[i][j] := zero; od;
      ans[i][i + 1] := one;
   od;
   ans[nd] := [];
   for j in [1..nd] do
      ans[nd][j] :=  - p[j];
   od;

   return ans;
end;

#############################################################################
##
#F SMTX.CompleteBasis(matrices,basis) . complete a basis under a group action
##
##  CompleteBasis ( matrices, basis ) takes the partial basis 'basis' of the
##  underlying space of the (irreducible) module defined by matrices, and
##  attempts to extend it to a complete basis which is a direct sum of
##  translates of the original subspace under group elements. It returns
##  true or false according to whether it succeeds.
##  It is called by IsAbsolutelyIrreducible ()
## 
SMTX.CompleteBasis := function ( matrices, basis )

   local  L, d, subd, subd0, zero, h, v, w, i, j, bno, gno, vno, newb, ngens;

   subd := Length (basis);
   subd0 := subd;
   d := Length ( basis[1] );
   if d = subd then
      return true;
   fi;
   # L is list of normalized generators of the subspace spanned by basis.
   L := [];
   zero := Zero(basis[1][1]);
   ngens := Length (matrices);

   #First find normalized generators for subspace itself.
   for i in [1..subd] do
      v := basis[i];
      h := 1;
      while v[h] = zero  do
         h := h + 1;
      od;
      w := v;
      while h <= d and IsBound ( L[h] )  do
         w := w - w[h] * L[h];
         while h <= d and w[h] = zero  do
            h := h + 1;
         od;
      od;
      if h <= d then
         L[h] := w * w[h]^-1;
      else 
         return Error ("Initial vectors are not linearly independent.");
      fi;
   od;

   #Now start translating
   bno := 1; gno := 1; vno := 1;
   while subd < d do
      #translate vector vno of block bno by generator gno
      v :=  basis[ (bno - 1) * subd0 + vno] * matrices[gno];
      h := 1;
      while v[h] = zero  do
         h := h + 1;
      od;
      w := v;
      while h <= d and IsBound ( L[h] )  do
         w := w - w[h] * L[h];
         while h <= d and w[h] = zero  do
            h := h + 1;
         od;
      od;
      if (h <= d) then
         #new generator (and block)
         if vno = 1 then
            newb := true;
         elif newb = false then
            return false;
         fi;
         L[h] := w * w[h]^-1;
         subd := subd + 1;
         basis[subd] := v;
      else
         #in existing subspace
         if vno = 1 then
            newb := false;
         elif newb = true then
            return false;
         fi;
      fi;
      vno := vno + 1;
      if vno > subd0 then
         vno := 1;
         gno := gno + 1;
         if gno > ngens then
            gno := 1;
            bno := bno + 1;
         fi;
      fi;
   od;

   return true;
end;

#############################################################################
##
#F AbsoluteIrreducibilityTest( module ) . . decide if an irreducible
##                    module over a  finite field is absolutely irreducible
##
## this function does the work for an absolute irreducibility test but does
## not actually set the flags.
## The function calculates the centralizer of the module.
## The centralizer should be isomorphic to the multiplicative 
## group of the field GF (q^e) for some e, or rather to the group of 
## dim/e x dim/e scalar matrices over GF (q^e), or equivalently, 
## dim x dim matrices composed of identical e x e blocks along the diagonal.
##  e = 1 <=> the module is absolutely irreducible.
## The .fieldExtDeg component is set to e during the function call.
## The function shouldn't be called if the module has not already been
## shown to be irreducible, using IsIrreducible. 
## 
AbsoluteIrreducibilityTest := function ( module )

   local dim, ndim, gcd, div, e, ct, F, q, ok, 
         M, v, M0, v0, C, C0, centmat, one, zero, 
         pow, matrices, newmatrices, looking, 
         basisN, basisB, basisBN, P, Pinv, i, j, k, nblocks; 

   if not SMTX.IsMTXModule(module) or not SMTX.IsIrreducible(module) then
      Error("Argument of IsAbsoluteIrreducible is not an irreducible module");
   fi;

   dim := SMTX.Dimension(module);
   F := SMTX.Field(module);
   q := Size (F);
   matrices := SMTX.Generators(module);

   # M acts irreducibly on N, which is canonically defined with respect to M
   # as the nullspace of fac (M), where fac is a factor of the char poly of M.
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
   gcd := GcdInt (dim, ndim);
   Info(InfoMeatAxe,2,"GCD of module and nullspace dimensions = ", gcd, ".");
   if gcd = 1 then
      SMTX.SetDegreeFieldExt(module,1);
      #SetAbsReducibleFlag (module, false);
      return true;
   fi;
   div := DivisorsInt(gcd);

   # It's easy to find elements  in the centralizer of an element in Frobenius 
   # (=rational canonical) form (centralizing elements are defined by their 
   # action on the first basis element).
   # M0  is the Frobenius form for the action of M on N.
   # basisN is set by the function SMTX.FrobeniusAction to be the 
   # basis v, vM, vM^2, .. for N

   basisN := [];
   Info(InfoMeatAxe,2,
     "Calc. Frobenius action of element from group algebra on nullspace.");
   M0 := SMTX.FrobeniusAction(M,v,basisN);

   zero := Zero (F);
   one:= One (F);
   v0 := ListWithIdenticalEntries(Length(M0[1]),zero);
   v0[1] := one;

   # v0 is just the vector (1, 0, 0....0) of length ndim. It has nothing
   # in particular to do with M0[1], but multiplying a vector that happens to be 
   # around by 0 is a good way to get a zero vector of the right length. 

   # we try all possible divisors of gcd (biggest first) as possibilities for e
   # We're looking for a centralizing element with order dividing q^e - 1, and
   # blocks size e on N. 
   for ct in Reversed ([2..Length (div)]) do
      e := div[ct];
      Info(InfoMeatAxe,2,"Trying dimension ",e," for centralising field.");
      # if ndim = e, M0 will do. 
      if ndim > e then
         C := M0;
         # Take the smallest power of C guaranteed to have order dividing
	 # q^e - 1, and try that.
         pow := (q^ndim - 1)/ (q^e - 1);
         Info(InfoMeatAxe,2,"Looking for a suitable centralising element.");
         repeat
            # The first time through the loop C is M0, otherwise we choose C
	    # at random from the centralizer of M0. Since M0 is in Frobenius
	    # form any centralising element is determined by its top row
	    # (which may be anything but the zero vector).

            if C = [] then
               C[1] := [];
               repeat
                  ok := 0;
                  for i in [1..ndim] do 
                     C[1][i] := Random (F);
		     if C[1][i] <> zero then  ok := 1; fi;
                  od;
               until ok=1;
               for i in [2..ndim] do C[i] := C[i - 1] * M0; od; 
            fi;
            # C0 is the Frobenius form for the action of this power on one
	    # of its blocks, B (all blocks have the same size). basisBN will
	    # be set to be a basis for B, in terms of the elements of basisN.
	    # A matrix product gives us the basis for B in terms of the
	    # original basis for the module.
            basisBN := [];
            C0 := SMTX.FrobeniusAction(C^pow,v0,basisBN);
            C := [];
         until Length (C0) = e;
	 Info(InfoMeatAxe,2,"Found one.");
         basisB := basisBN * basisN;
      else
         C0 := M0;
         basisB := ShallowCopy(basisN);
      fi;
      # Now try to extend basisB to a basis for the whole module, by
      # translating it by the generating matrices.
      P := basisB;
      Info(InfoMeatAxe,2,"Trying to extend basis to whole module.");
      if SMTX.CompleteBasis(matrices,P) then
         # We succeeded in extending the basis (might not have done).
         # So now we have a full basis, which we think of now as a base
 	 # change matrix.
         Info(InfoMeatAxe,2,"Succeeded. Calculating centralising matrix.");
         newmatrices := [];
         Pinv := P^-1;
         for i in [1..Length (matrices)] do
            newmatrices[i] := P * matrices[i] * Pinv;
         od;
         # Make the sum of copies of C0 as centmat
         centmat := MutableNullMat (dim, dim, F);
         nblocks := dim/e;
         for i in [1..nblocks] do
            for j in [1..e] do
               for k in [1..e] do
                  centmat[ (i - 1) * e + j][ (i - 1) * e + k] := C0[j][k];
               od;
            od;
         od;
         Info(InfoMeatAxe,2,"Checking that it centralises the generators.");
         # Check centralizing.
         looking := true;
         i := 1;
         while looking and i <= Length (newmatrices) do
            if newmatrices[i] * centmat <> centmat * newmatrices[i] then
               looking := false;
            fi;
            i := i + 1;
         od;
         if looking then
	    Info(InfoMeatAxe,2,"It did!");
            SMTX.SetDegreeFieldExt(module, e);
            #SetAbsReducibleFlag (module, true);
            SMTX.SetCentMat (module, P^-1 * centmat * P); # get the base right
            # We will also record the minimal polynomial of C0 (and hence of
	    # centmat) in case we need it at some future date.
            SMTX.SetCentMatMinPoly (module, MinimalPolynomial (F,C0));
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
   #SetAbsReducibleFlag (module, false);
   return true;
end;

SMTX.IsAbsolutelyIrreducible:=function(module)
  return AbsoluteIrreducibilityTest(module);
end;

SMTX.DegreeFieldExt:=function(module)
  if not IsBound(module.smashMeataxe.degreeFieldExt) then
    AbsoluteIrreducibilityTest( module );
  fi;
  return module.smashMeataxe.degreeFieldExt;
end;

SMTX.DegreeSplittingField:=function(module)
  return DegreeOverPrimeField(SMTX.Field(module))
         *SMTX.DegreeFieldExt(module);
end;

# #############################################################################
# ##
# #F  FieldGenCentMat ( module ) . . find a centralizing matrix that generates
# ##                                the centralizing field of an irred. module
# ##
# ## FieldGenCentMat ( ) should only be applied to modules that have already
# ## been proved irreducible using IsIrreducible. It then tests for absolute
# ## irreducibility (if not already known) and does nothing if module is
# ## absolutely irreducible. Otherwise, it replaces the centMat component
# ## by a matrix that generates (multiplicatively) the centralizing field
# ## (i.e. its multiplicative order is q^e - 1, where e is the degree of the
# ## centralizing field. This is not yet used, but maybe in future, if we
# ## wish to reduce the group to matrices over the larger field.
# ## It also resets the SmashCentMatMinPoly component.
# FieldGenCentMat := function ( module )
#    local e, F, R, q, qe, minpol, pp, 
#          M, v, M0, v0, C, C0, centmat, newcentmat, genpol, looking, 
#          i, l, okd; 
# 
#    if SMTX.IsMTXModule (module) = false then
#       return Error ("Argument of IsIrreducible is not a module.");
#    elif ReducibleFlag (module) <> false then
#       return Error ("GModule is not known to be irreducible.");
#    elif AbsReducibleFlag (module) = "unknown" then 
#       IsAbsolutelyIrreducible (module);
#    fi;
# 
#    if AbsReducibleFlag (module) = false then
#       return;
#    fi;
# 
#    F := SMTX.Field (module);
#    R := PolynomialRing (F);
#    q := Size (F);
#    e :=SMTX.DegreeFieldExt(module);
#    qe := q^e - 1;
#    minpol := CentMatMinPoly (module);
#    # Factorise q^e - 1 
#    pp := PrimePowersInt (qe);
#    # We seek a generator of the field of order q^e - 1. In other words, a
#    # polynomial genpol of degree e, which has multiplicative order q^e - 1
#    # modulo minpol. We first try the polynomial x, which is the element we
#    # have already. If this does not work, then we try random nonconstant
#    # polynomials until we find one with the right order.
# 
#    genpol := Indeterminate (F);
# 
#    looking := true;
#    while looking do
#       okd := R.operations.OrderKnownDividend (R, genpol, minpol, pp); 
#       if okd[1] * Order (F, okd[2]) = qe then
#          looking := false;
#       fi;
#       if looking then
#          repeat
#             genpol := RandomPol (F, e);
#          until Degree (genpol) > 0;
#          genpol := R.operations.StandardAssociate (R, genpol);
#       fi;
#    od;
#    # Finally recalculate centmat and its minimal polynomial.
#    centmat := CentMat (module);
#    newcentmat := Value (genpol, centmat);
#    SetCentMat (module, newcentmat);
#    SetCentMatMinPoly (module, MinimalPolynomial (newcentmat));
#    # Ugh! That was very inefficient - should work out the min poly using
#    # polynomials, but will sort that out if its ever needed.
#    return;
# end;


###############################################################################
##
#F  SMTX.CollectedFactors ( module ) . . find composition factors of a module
##
## SMTX.CollectedFactors calls IsIrreducible repeatedly to find the
## composition factors of the GModule `module'. It also calls
## IsomorphismGModule to determine which are isomorphic.
## It returns a list [f1, f2, ..fr], where each fi is a list [m, n], 
## where m is an irreducible composition factor of module, and n is the
## number of times it occurs in module.
## 
SMTX.CollectedFactors := function ( module )
   local dim, factors, factorsout, queue, cmod, new, 
         d, i, j, l, q;
   if SMTX.IsMTXModule (module) = false then
      return Error ("Argument is not a module.");
   fi;

   dim := SMTX.Dimension(module);
   factors := [];
   for i in [1..dim] do
      factors[i] := [];
   od;
   #factors[i] will contain a list [f1, f2, ..., fr] of the composition factors
   #of module of dimension i. Each fi will have the form [m, n], where m is
   #the module, and n its multiplicity.

   queue := [module];
   #queue is the list of modules awaiting processing.

   while Length (queue) > 0 do
      l := Length (queue);
      cmod := queue[l];
      Unbind (queue[l]);
      Info(InfoMeatAxe,3,"Length of queue = ", l, ", dim = ", 
                 SMTX.Dimension(cmod), ".");

      if SMTX.IsIrreducible (cmod) then
         Info(InfoMeatAxe,2,"Irreducible: ");
         #module is irreducible. See if it is already on the list.
         d := SMTX.Dimension(cmod);
         new := true;
         l := Length (factors[d]);
         i := 1;
         while new and i <= l do
            if SMTX.IsEquivalent(factors[d][i][1], cmod) then
               new := false;
               factors[d][i][2] := factors[d][i][2] + 1;
            fi;
            i := i + 1;
         od;
         if new then
            Info(InfoMeatAxe,2," new.");
            factors[d][l + 1] := [cmod, 1];
         else 
            Info(InfoMeatAxe,2," old.");
         fi;
      else
         Info(InfoMeatAxe,2,"Reducible.");
         #module is reducible. Add sub- and quotient-modules to queue.
         l := Length (queue);
         q:=SMTX.InducedAction(cmod,
	          SMTX.Subbasis (cmod),3);
         queue[l + 1] := q[1]; queue[l + 2] := q[2];
      fi;
   od;

   #Now repack the sequence for output.
   l := 0;
   factorsout := [];
   for i in [1..dim] do
      for j in [1..Length (factors[i])] do
         l := l + 1;
         factorsout[l] := factors[i][j];
      od;
   od;

   return factorsout;

end;

SMTX.CompositionFactors := function ( module )
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
#F  SMTX.Distinguish ( cf, i )  distinguish a composition factor of a module
##
## cf is assumed to be the output of a call to SMTX.CollectedFactors, 
## and i is the number of one of the cf.
## Distinguish tries to find a group-algebra element for factor[i]
## which gives nullity zero when applied to all other cf.
## Once this is done, it is easy to find submodules containing this
## composition factor.
## 
SMTX.Distinguish := function ( cf, i )
   local el, genpair, ngens, orig_ngens, mat, matsi, mats, M, 
         dimi, dim, F, fac, sfac, p, q, oldp, found, extdeg, j, k, 
         lcf, lf, x, y, wno, deg, trying, N, fact, R;

   lcf := Length (cf);
   ngens := Length (SMTX.Generators (cf[1][1]));
   orig_ngens := ngens;
   F := SMTX.Field (cf[1][1]);
   R := PolynomialRing (F);
   matsi := ShallowCopy(SMTX.Generators (cf[i][1]));
   dimi := SMTX.Dimension (cf[i][1]);

   #First check that the existing nullspace has dim. 1 over centralising field. 
   SMTX.GoodElementGModule (cf[i][1]);

   #First see if the existing element is OK
   #Apply the alg. el. of factor i to every other factor and see if the
   # matrix is nonsingular.
   found := true;
   el := SMTX.AlgEl(cf[i][1]);
   fact := SMTX.AlgElCharPolFac(cf[i][1]);
   for j in [1..lcf] do
      if j <> i and found then
         mats := ShallowCopy(SMTX.Generators (cf[j][1]));
         dim := SMTX.Dimension(cf[j][1]);
         for genpair in el[1] do
            ngens := ngens + 1;
            mats[ngens] := mats[genpair[1]] * mats[genpair[2]];
         od;
         M := NullMat (dim, dim, F);
         for k in [1..ngens] do
            M := M + el[2][k] * mats[k];
         od;
         ngens := orig_ngens;
         mat := Value (fact, M);
         if RankMat (mat) < dim then
            found := false;
            Info(InfoMeatAxe,2,"Current element failed on factor ", j);
         fi;
      fi;
   od;

   if found then
      Info(InfoMeatAxe,2,"Current element worked.");
      return;
   fi;

   #That didn't work, so we have to try new random elements.
   wno := 0;
   el := []; el[1] := [];
   extdeg := SMTX.DegreeFieldExt (cf[i][1]);

   while found = false do
      Info(InfoMeatAxe,2,"Trying new one.");
      wno := wno + 1;
      #Add a new generator if there are less than 8 or if wno mod 10=0.
      if  ngens<8 or wno mod 10 = 0 then
         x := Random ([1..ngens]);
         y := x;
         while y = x and ngens > 1 do y := Random ([1..ngens]); od;
         Add (el[1], [x, y]);
         ngens := ngens + 1;
         matsi[ngens] := matsi[x] * matsi[y];
      fi;
      #Now take the new random element
      el[2] := [];
      for j in [1..ngens] do el[2][j] := Random (F); od;
      #First evaluate on cf[i][1].
      M := NullMat (dimi, dimi, F);
      for k in [1..ngens] do
         M := M + el[2][k] * matsi[k];
      od;
      p := CharacteristicPolynomial (F,M);
      #That is necessary in case p is defined over a smaller field that F.
      oldp := p;
      #extract irreducible factors
      deg := 0;
      fac := [];
      trying := true;
      while deg <= extdeg and trying do
         repeat
            deg := deg + 1;
            if deg > extdeg then
               fac := [p];
            else
               fac := Factors(R, p, rec(onlydegs:=[deg]));
	       fac:=Filtered(fac,i->DOULP(i)<=deg);
               sfac := Set (fac);
            fi;
         until fac <> [];
         lf := Length (fac);
         if trying and deg <= extdeg then
            j := 1;
            while j <= lf and trying do
               mat := Value (fac[j], M);
               N := NullspaceMat (mat);
               if Length (N) = extdeg then
                  trying := false;
                  SMTX.SetAlgEl(cf[i][1], el);
                  SMTX.SetAlgElMat(cf[i][1], M);
                  SMTX.SetAlgElCharPol (cf[i][1], oldp);
                  SMTX.SetAlgElCharPolFac (cf[i][1], fac[j]);
                  SMTX.SetAlgElNullspaceVec(cf[i][1], N[1]);
               fi;
               j := j + 1;
            od;
         fi;

         if trying then
            for q in fac do
               p := Quotient (R, p, q);
            od;
         fi;
      od;

      #Now see if it works against the other factors of cf
      if trying = false then
         Info(InfoMeatAxe,2,"Found one.");
         found := true;
         fact := SMTX.AlgElCharPolFac(cf[i][1]);
         #Apply the alg. el. of factor i to every other factor and 
         #see if the matrix is nonsingular.
         for j in [1..lcf] do
            if j <> i and found then
               mats := ShallowCopy(SMTX.Generators (cf[j][1]));
               dim := SMTX.Dimension(cf[j][1]);
               ngens := orig_ngens;
               for genpair in el[1] do
                  ngens := ngens + 1;
                  mats[ngens] := mats[genpair[1]] * mats[genpair[2]];
               od;
               M := NullMat (dim, dim, F);
               for k in [1..ngens] do
                  M := M + el[2][k] * mats[k];
               od;
               mat := Value (fact, M);
               if RankMat (mat) < dim then
                  found := false;
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
#F  SMTX.MinimalSubGModule ( module, cf, i ) . .  find minimal submodule
##                                     containing a given composition factor.
##
## cf is assumed to be the output of a call to SMTX.CollectedFactors, 
## and i is the number of one of the cf.
## It is assumed that SMTX.Distinguish (cf, i) has already been called.
## A basis of a minimal submodule of module containing the composition factor
## cf[i][1] is calculated and returned - i.e. if cf[i][2] = 1.
##
SMTX.MinimalSubGModule := function ( module, cf, i )
   local el, genpair, ngens, orig_ngens, mat, mats, M, dim, F, 
         j, k, N, fact;

   if SMTX.IsMTXModule (module) = false then
      return Error ("First argument is not a module.");
   fi;

   ngens := Length (SMTX.Generators (module));
   orig_ngens := ngens;
   F := SMTX.Field (module);

   #Apply the alg. el. of factor i to module
   el := SMTX.AlgEl(cf[i][1]);
   mats := ShallowCopy(SMTX.Generators(module));
   dim := SMTX.Dimension(module);
   for genpair in el[1] do
      ngens := ngens + 1;
      mats[ngens] := mats[genpair[1]] * mats[genpair[2]];
   od;
   M := NullMat (dim, dim, F);
   for k in [1..ngens] do
      M := M + el[2][k] * mats[k];
   od;
   #Now throw away extra generators of module
   for k in [orig_ngens + 1..ngens] do
      Unbind (mats[k]);
   od;
   ngens := orig_ngens;
   fact := SMTX.AlgElCharPolFac(cf[i][1]);
   mat := Value (fact, M);
   N := NullspaceMat (mat);
   return (SMTX.SpinnedBasis (N[1], mats, ngens));

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
## for module1 and module2 respectively, Y = BXB^-1
## It is assumed that the same group acts on both modules.
## Otherwise who knows what will happen?
## 
SMTX.IsomorphismComp := function (module1, module2, action)
   local matrices, matrices1, matrices2, F, R, dim, swapmodule, genpair,
         swapped, orig_ngens, i, j, el, p, fac, ngens, M, mat, v1, v2, v, 
         N, basis, basis1, basis2;

   if SMTX.IsMTXModule (module1) = false then 
      Error ("Argument is not a module.");
   elif SMTX.IsMTXModule (module2) = false then 
      Error ("Argument is not a module.");
   elif SMTX.Field (module1) <> SMTX.Field (module2) then 
      Error ("GModules are defined over different fields.");
   fi;

   swapped := false;
   if not SMTX.HasIsIrreducible (module1) then
      if not SMTX.HasIsIrreducible (module2) then
         Error ("Neither module is known to be irreducible.");
      else
         # The second module is known to be irreducible, so swap arguments.
         swapmodule := module2; module2 := module1; module1 := swapmodule;
         swapped := true;
         Info(InfoMeatAxe,2,"Second module is irreducible. Swap them round.");
      fi;
   fi;

   #At this stage, module1 is known to be irreducible
   dim := SMTX.Dimension (module1);
   if dim <> SMTX.Dimension (module2) then
      Info(InfoMeatAxe,2,"GModules have different dimensions.");
      return fail;
   fi;
   F := SMTX.Field (module1);
   R := PolynomialRing (F);

   #First we must check that our nullspace is 1-dimensional over the
   #centralizing field.

   Info(InfoMeatAxe,2,
        "Checking nullspace 1-dimensional over centralising field.");
   SMTX.GoodElementGModule (module1);
   matrices1 := SMTX.Generators (module1);
   matrices2 := ShallowCopy(SMTX.Generators (module2));
   ngens := Length (matrices1);
   orig_ngens := ngens;
   if ngens <> Length (matrices2) then
      Error ("GModules have different numbers of defining matrices.");
   fi;

   # Now we calculate the element in the group algebra of module2 that 
   # corresponds to that in module1. This is done using the AlgEl flag 
   # for module1. We first extend the generating set in the same way as 
   # we did for module1, and then calculate the group alg. element as 
   # a linear sum in the generators.

   Info(InfoMeatAxe,2,"Extending generating set for second module.");
   el := SMTX.AlgEl(module1);
   for genpair in el[1] do
      ngens := ngens + 1;
      matrices2[ngens] := matrices2[genpair[1]] * matrices2[genpair[2]];
   od;
   M := NullMat (dim, dim, F);
   for i in [1..ngens] do
      M := M + el[2][i] * matrices2[i];
   od;
   # Having done that, we no longer want the extra generators of module2, 
   # so we throw them away again.
   for i in [orig_ngens + 1..ngens] do
      Unbind (matrices2[i]);
   od;

   Info(InfoMeatAxe,2,
        "Calculating characteristic polynomial for second module.");
   p := CharacteristicPolynomial (F,M);
   if p <> SMTX.AlgElCharPol (module1) then
      Info(InfoMeatAxe,2,"Characteristic polynomial different.");
      return fail;
   fi;
   fac := SMTX.AlgElCharPolFac (module1);
   mat := Value (fac, M);
   Info(InfoMeatAxe,2,"Calculating nullspace for second module.");
   N := NullspaceMat (mat);
   if Length (N) <> SMTX.AlgElNullspaceDimension(module1) then
      Info(InfoMeatAxe,2,"Null space dimensions different.");
      return fail;
   fi;

   # That concludes the easy tests for nonisomorphism. Now we must proceed
   # to spin up. We first form the direct sum of the generating matrices.
   Info(InfoMeatAxe,2,"Spinning up in direct sum.");
   matrices := SMTX.MatrixSum (matrices1, matrices2);
   v1 := SMTX.AlgElNullspaceVec(module1);
   v2 := N[1];
   v := Concatenation (v1, v2);
   basis := SMTX.SpinnedBasis (v, matrices);
   if Length (basis) = dim then
      if action<>true then
        return true;
      fi;
      basis1 := []; basis2 := [];
      for i in [1..dim] do
         basis1[i] := []; basis2[i] := [];
         for j in [1..dim] do
            basis1[i][j] := basis[i][j];
            basis2[i][j] := basis[i][j + dim];
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

SMTX.Isomorphism := function(module1,module2)
  return SMTX.IsomorphismComp(module1,module2,true);
end;

SMTX.IsEquivalent := function(module1,module2)
  return SMTX.IsomorphismComp(module1,module2,false)<>fail;
end;

#############################################################################
##
#F  SMTX.MatrixSum (matrices1, matrices2) direct sum of two lists of matrices
##
SMTX.MatrixSum := function (matrices1, matrices2) 
   local dim, dim1, dim2, matrices, zero, nmats, i, j, k;
   dim1 := Length (matrices1[1]); dim2 := Length (matrices2[1]);
   dim := dim1 + dim2;
   zero:=0*matrices1[1][1][1];
   matrices := [];
   nmats := Length (matrices1);
   for i in [1..nmats] do
      matrices[i] := MutableNullMat (dim, dim, zero);
      for j in [1..dim1] do for k in [1..dim1] do
         matrices[i][j][k] := matrices1[i][j][k];
      od; od;
      for j in [1..dim2] do for k in [1..dim2] do
         matrices[i][j + dim1][k + dim1] := matrices2[i][j][k];
      od; od;
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
SMTX.Homomorphisms := function (m1, m2)

   local F, ngens, orig_ngens, mats1, mats2, dim1, dim2, m1bas, imbases, 
         el, genpair, fac, mat, N, imlen, subdim, leadpos, vec, imvecs, 
         numrels, rels, leadposrels, newrels, bno, genno, colno, rowno, 
         zero, looking, ans, i, j, k;

   if not SMTX.IsMTXModule (m1) then 
      return Error ("First argument is not a module.");
   elif not SMTX.IsIrreducible(m1) then
      return Error ("First module is not known to be irreducible.");
   fi;

   if not SMTX.IsMTXModule (m2) then 
      return Error ("Second argument is not a module.");
   fi;

   mats1 := SMTX.Generators (m1);
   mats2 := ShallowCopy(SMTX.Generators (m2));
   ngens := Length (mats1);
   if ngens <> Length (mats2) then
      return Error ("GModules have different numbers of generators.");
   fi;

   F := SMTX.Field (m1);
   if F <> SMTX.Field (m2) then
      return Error ("GModules are defined over different fields.");
   fi;
   zero := Zero (F);

   dim1 := SMTX.Dimension (m1); dim2 := SMTX.Dimension (m2);

   m1bas := [];
   m1bas[1] :=  SMTX.AlgElNullspaceVec(m1);

   # In any homomorphism from m1 to m2, the vector in the nullspace of the
   # algebraic element that was used to prove irreducibility  (which is now
   # m1bas[1]) must map onto a vector in the nullspace of the same algebraic
   # element evaluated in m2. We therefore calculate this nullspaces, and
   # store a basis in imbases.

   Info(InfoMeatAxe,2,"Extending generating set for second module.");
   orig_ngens := ngens;
   el := SMTX.AlgEl(m1);
   for genpair in el[1] do
      ngens := ngens + 1;
      mats2[ngens] := mats2[genpair[1]] * mats2[genpair[2]];
   od;
   mat := NullMat (dim2, dim2, F);
   for i in [1..ngens] do
      mat := mat + el[2][i] * mats2[i];
   od;
   # Having done that, we no longer want the extra generators of m2, 
   # so we throw them away again.
   for i in [orig_ngens + 1..ngens] do
      Unbind (mats2[i]);
   od;
   ngens := orig_ngens;

   fac := SMTX.AlgElCharPolFac (m1);
   mat := Value (fac, mat);
   Info(InfoMeatAxe,2,"Calculating nullspace for second module.");
   N := NullspaceMat (mat);
   imlen := Length (N);
   Info(InfoMeatAxe,2,"Dimension = ", imlen, ".");
   if imlen = 0 then
      return [];
   fi;

   imbases := [];
   for i in [1..imlen] do
      imbases[i] := [N[i]];
   od;

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

   subdim := 1; # the dimension of module spanned by m1bas
   numrels := 0;
   rels := [];

   #leadpos[j] will be the position of the first nonzero entry in m1bas[j]
   leadpos := [];
   vec := m1bas[1];
   j := 1;
   while j <= dim1 and vec[j] = zero do j := j + 1; od;
   leadpos[1] := j;
   k := vec[j]^-1;
   m1bas[1] := k * vec;
   for i in [1..imlen] do
      imbases[i][1] := k * imbases[i][1];
   od;

   leadposrels := [];
   #This will play the same role as leadpos but for the relation matrix.
   Info(InfoMeatAxe,2,"Starting spinning.");
   bno := 1;
   while bno <= subdim do
      for genno in [1..ngens] do
         # apply generator no. genno to submodule generator bno
         vec := m1bas[bno] * mats1[genno];
         # and do the same to the images
         imvecs := [];
         for i in [1..imlen] do
            imvecs[i] := imbases[i][bno] * mats2[genno];
         od;
         # try to express w in terms of existing submodule generators
         # make same changes to images
         j := 1;
         for  j in [1..subdim] do
            k := vec[leadpos[j]];
            if k <> zero then
               vec := vec - k * m1bas[j];
               for i in [1..imlen] do
                  imvecs[i] := imvecs[i] - k * imbases[i][j];
               od;
            fi;
         od;

         j := 1;
         while j <= dim1 and vec[j] = zero do j := j + 1; od;
         if j <= dim1 then
            #we have found a new generator of the submodule
            subdim := subdim + 1;
            leadpos[subdim] := j;
            k := vec[j]^-1;
            m1bas[subdim] := k * vec;
            for i in [1..imlen] do
               imbases[i][subdim] := k * imvecs[i];
            od;
         else
            # vec has reduced to zero. We get relations among the imvecs.
            # (these are given by the transpose of imvec)
            # reduce these against any existing relations.
            newrels := TransposedMat (imvecs);
            for i in [1..Length (newrels)] do
               vec := newrels[i];
               for j in [1..numrels] do
                  k := vec[leadposrels[j]];
                  if k <> zero then
                     vec := vec - k * rels[j];
                  fi;
               od;
               j := 1;
               while j <= imlen and vec[j] = zero do j := j + 1; od;
               if j <= imlen then
                  # we have a new relation
                  numrels := numrels + 1;
                  # if we have imlen relations, there can be no homomorphisms
                  # so we might as well give up immediately
                  if numrels = imlen then
                     return [];
                  fi;
                  k := vec[j]^-1;
                  rels[numrels] := k * vec; 
                  leadposrels[numrels] := j;
               fi;
            od;
         fi;
      od;
      bno := bno + 1;
   od;

   # That concludes the spinning. Now we do row operations on the im1bas to
   # make it the identity, and do the same operations to the imvecs.
   # Then the homomorphisms we output will be the basis images.
   Info(InfoMeatAxe,2,"Done. Reducing spun up basis.");

   for colno in [1..dim1] do
      rowno := colno;
      looking := true;
      while rowno <= dim1 and looking do
         if m1bas[rowno][colno] <> zero then
            looking := false;
            if rowno <> colno then
               #swap rows rowno and colno
               vec := m1bas[rowno]; m1bas[rowno] := m1bas[colno]; 
               m1bas[colno] := vec;
               #and of course the same in the images
               for i in [1..imlen] do
                  vec := imbases[i][rowno];
                  imbases[i][rowno] := imbases[i][colno]; 
                  imbases[i][colno] := vec;
               od;
            fi;
            # and then clear remainder of column
            for j in [1..dim1] do
               if j <> colno and m1bas[j][colno] <> zero then
                  k := m1bas[j][colno];
                  m1bas[j] := m1bas[j] - k * m1bas[colno];
                  for i in [1..imlen] do
                     imbases[i][j] := imbases[i][j] - k * imbases[i][colno];
                  od;
               fi;
            od;
         fi;
         rowno := rowno + 1;
      od;
   od;

   #Now we are ready to compute and output the linearly independent 
   #homomorphisms.  The coefficients for the solution are given by 
   #the basis elements of the nullspace of the transpose of rels.

   Info(InfoMeatAxe,2,"Done. Calculating homomorphisms.");
   if rels = [] then
      rels := NullMat (imlen, 1, F);
   else
      rels := TransposedMat (rels);
   fi;
   N := NullspaceMat (rels);
   ans := [];
   for k in [1..Length (N)] do
      vec := N[k];
      mat := NullMat (dim1, dim2, F);
      for i in [1..imlen] do
         mat := mat + vec[i] * imbases[i];
      od;
      ans[k] := mat;
   od;

   return ans;
end;

#############################################################################
##
#F  SMTX.SortHomGModule ( m1, m2, homs)  . . sort output of HomGModule
##                                           according to their images
##
## It is assumed that m1 is a module that has been proved irreducible
## (using IsIrreducible), and m2 is an arbitrary module for the same group, 
## and that homs is the output of a call HomGModule (m1, m2).
## Let e be the degree of the centralising field of m1.
## If e = 1 then SMTX.SortHomGModule does nothing. If e > 1, then it replaces 
## the basis contained in homs by a new basis arranged in the form
## b11, b12, ..., b1e, b21, b22, ...b2e, ..., br1, br2, ...bre,  where each
## block of  e  adjacent basis vectors are all equivalent under the
## centralising field of m1, and so they all have the same image in  m2.
## A complete list of the distinct images can then be obtained with a call
## to DistinctIms (m1, m2, homs).
## 
SMTX.SortHomGModule := function (m1, m2, homs)
   local e, F, ngens, mats1, mats2, dim1, dim2, centmat, fullimbas, oldhoms, 
         hom, homno, dimhoms, newdim, subdim, leadpos, vec, nexthom, 
         i, j, k, zero;

   if SMTX.IsAbsolutelyIrreducible(m1) then return; fi;

   e := SMTX.DegreeFieldExt (m1);
   F := SMTX.Field (m1);
   zero := Zero (F);

   mats1 := SMTX.Generators (m1);  mats2 := SMTX.Generators (m2);
   dim1 := SMTX.Dimension (m1);  dim2 := SMTX.Dimension (m2);
   ngens := Length (mats1);
   centmat := SMTX.CentMat(m1);

   fullimbas := [];
   subdim := 0;
   leadpos := [];

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

   oldhoms := ShallowCopy (homs);
   dimhoms := Length (homs);

   homno := 0; newdim := 0;

   while homno < dimhoms and newdim < dimhoms do
      homno := homno + 1;
      nexthom := oldhoms[homno];
      vec := nexthom[1];

      #Now check whether vec is in existing submodule spanned by fullimbas   
      j := 1;
      for j in [1..subdim] do
         k := vec[leadpos[j]];
         if k <> zero then
            vec := vec - k * fullimbas[j];
         fi;
      od;

      j := 1;
      while j <= dim2 and vec[j] = zero do j := j + 1; od;

      if j <= dim2 then
         #vec is not in the image, so we adjoin this homomorphism to the list;
         #first adjoin vec and all other basis vectors in the image to fullimbas
         subdim := subdim + 1;
         leadpos[subdim] := j;
         k := vec[j]^-1;
         fullimbas[subdim] := k * vec;
         for i in [2..dim1] do
            vec := nexthom[i];
            j := 1;
            for  j in [1..subdim] do
               k := vec[leadpos[j]];
               if k <> zero then
                  vec := vec - k * fullimbas[j];
               fi;
            od;

            j := 1;
            while j <= dim2 and vec[j] = zero do j := j + 1; od;
            subdim := subdim + 1;
            leadpos[subdim] := j;
            k := vec[j]^-1;
            fullimbas[subdim] := k * vec;
         od;

         newdim := newdim + 1;
         homs[newdim] := nexthom;

         #Now add on the other e - 1 homomorphisms equivalent to 
         #newhom by centmat.
         for k in [1..e - 1] do
            nexthom := centmat * nexthom;
            newdim := newdim + 1;
            homs[newdim] := nexthom;
         od;
      fi;
   od;

end;

#############################################################################
##
#F SMTX.MinimalSubGModules (m1, m2, [max]) . . 
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
SMTX.MinimalSubGModules := function (arg)

   local m1, m2, max, e, homs, coeff,  dimhom, edimhom, F, elF, q, 
         submodules, sub, adno, more, count, sr, er, i, j, k ;

   if Number (arg) < 2 or Number (arg) > 3 then
      Error ("Number of arguments to MinimalSubGModules must be 2 or 3.");
   fi;

   m1 := arg[1]; m2 := arg[2];
   if Number (arg) = 2 then max := 0; else max := arg[3]; fi;

   Info(InfoMeatAxe,2,"Calculating homomorphisms from m1 to m2.");
   homs := SMTX.Homomorphisms(m1, m2);
   Info(InfoMeatAxe,2,"Sorting them.");
   SMTX.SortHomGModule (m1, m2, homs);

   F := SMTX.Field (m1);
   e := SMTX.DegreeFieldExt (m1);
   dimhom := Length (homs);
   edimhom := dimhom / e;
   submodules := [];
   count := 0;
   coeff := [];
   elF:=AsList(F);
   q := Length (elF);
   for i in [1..dimhom] do coeff[i] := 1; od;

   #coeff[i] will be an integer in the range [1..q] corresponding to the
   #field element elF[coeff[i]].
   #Each submodule will be calculated as the image of the homomorphism
   #elF[coeff[1]] * homs[1] +...+  elF[coeff[dimhom]] * homs[dimhom]
   #for appropriate field elements elF[coeff[i]]. 
   #We get each distinct submodule
   #exactly once by making the first nonzero elF[coeff[i]] to be 1, 
   #and all other elF[coeff[i]]'s in that block equal to zero.

   Info(InfoMeatAxe,2,"Done. Calculating submodules.");

   for i in Reversed ([1..edimhom]) do
      j := e * (i - 1) + 1;
      coeff[j] := 2;  #giving field element 1.
      for k in [j + 1..dimhom] do coeff[k] := 1; od; # field element 0.
      sr := j + e; er := dimhom;
      #coeff[i] for i in [sr..er] ranges over all field elements.

      more := true;
      adno := er;
      while more do
         count := count + 1;
         if max > 0 and count > max then
            Info(InfoMeatAxe,2,"Number of submodules exceeds ", max,
	         ". Aborting.");
            return submodules;
         fi;

         # Calculate the next submodule
         sub := homs[j];
         for k in [sr..er] do
            sub := sub + elF[coeff[k]] * homs[k];
         od;
	 sub:=List(sub,ShallowCopy);
         TriangulizeMat (sub);
         Add (submodules, sub);

         #Move on to next set of coefficients if any
         while adno >= sr and coeff[adno]=q do
            coeff[adno] := 1;
            adno := adno - 1;
         od;
         if adno < sr then
            more := false;
         else
            coeff[adno] := coeff[adno] + 1;
            adno := er;
         fi;
      od;

   od;

   return submodules;

end;

SMTX.BasesCompositionSeries := function(m)
local q,b,s,ser,queue;
  SMTX.SetSmashRecord(m,0);
  b:=IdentityMat(SMTX.Dimension(m),One(SMTX.Field(m)));
  # denombasis: Basis des Kerns
  m.smashMeataxe.denombasis:=[];
  # csbasis: Basis des Moduls
  m.smashMeataxe.csbasis:=b;
  # fakbasis: Urbilder der Basis, bzgl. derer csbasis angegeben wird
  m.smashMeataxe.fakbasis:=b;

  ser:=[[]];
  queue:=[m];
  while Length(queue)>0 do
    m:=queue[1];
    queue:=queue{[2..Length(queue)]};
    if SMTX.IsIrreducible(m) then
      Info(InfoMeatAxe,3,Length(m.smashMeataxe.csbasis)," ",
                         Length(m.smashMeataxe.denombasis));
      m:=Concatenation(List(m.smashMeataxe.denombasis,ShallowCopy),
                 List(m.smashMeataxe.csbasis,
		      i->LinearCombinationVecs(m.smashMeataxe.fakbasis,i)));
      TriangulizeMat(m);
      m:=Filtered(m,i->i<>Zero(i));
      Add(ser,m);
    else
      b:=SMTX.Subbasis(m);
      s:=SMTX.InducedAction(m,b,3);
      q:=s[2];
      b:=s[3];
      s:=s[1];
      SMTX.SetSmashRecord(s,0);
      SMTX.SetSmashRecord(q,0);
      Info(InfoMeatAxe,1,"chopped ",SMTX.Dimension(s),"\\",
           SMTX.Dimension(q));
      s.smashMeataxe.denombasis:=m.smashMeataxe.denombasis;
      #s.csbasis:=b{[1..s.dim]};
      s.smashMeataxe.csbasis:=IdentityMat(SMTX.Dimension(s),One(SMTX.Field(s)));
      s.smashMeataxe.fakbasis:=
        List(b,i->LinearCombinationVecs(m.smashMeataxe.fakbasis,i));
      q.smashMeataxe.denombasis:=Concatenation(
        List(m.smashMeataxe.denombasis,ShallowCopy),
        List(s.smashMeataxe.fakbasis{[1..s.dimension]},ShallowCopy));
      q.smashMeataxe.csbasis:=IdentityMat(SMTX.Dimension(q),
      					  One(SMTX.Field(q)));
      q.smashMeataxe.fakbasis:=List(b{[SMTX.Dimension(s)+1..Length(b)]},
                       i->LinearCombinationVecs(m.smashMeataxe.fakbasis,i));
      Add(queue,s);
      Add(queue,q);
    fi;
  od;
  Sort(ser,function(a,b) return Length(a)<Length(b);end);
  return ser;
end;

SMTX.BasesSubmodules := function(m)
local cf,u,i,j,f,cl,min,neu,sq,sb,fb,k,nmin;
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
	                  List(k,i->LinearCombinationVecs(fb,i)));
	TriangulizeMat(sq);
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
  Add(u,IdentityMat(SMTX.Dimension(m),SMTX.Field(m)));
  return u;
end;


SMTX.BasesMinimalSubmodules := function(m)
local cf,u,i,j,f,cl,min,neu,sq,sb,fb,k,nmin;
  cf:=SMTX.CollectedFactors(m);
  cf:=List(cf,i->i[1]);
  return Concatenation(List(cf,i->SMTX.MinimalSubGModules(i,m)));
end;

SMTX.DualModule:=function(module)
  return GModuleByMats(List(SMTX.Generators(module),i->TransposedMat(i)^-1),
                       SMTX.Field(module));
end;

SMTX.DualizedBasis:=function(module,sub)
  return NullspaceMat(TransposedMat(sub));
end;

SMTX.BasesMaximalSubmodules := function(m)
local d,u;
  d:=SMTX.DualModule(m);
  u:=SMTX.BasesMinimalSubmodules(d);
  return List(u,i->SMTX.DualizedBasis(d,i));
end;

SMTX.BasesMinimalSupermodules := function(m,sub)
local a,u,i,nb;
  a:=SMTX.InducedAction(m,sub,2);
  u:=SMTX.BasesMinimalSubmodules(a[1]);
  nb:=a[2];
  nb:=nb{[Length(sub)+1..Length(nb)]}; # the new basis part
  nb:=List(u,i->Concatenation(sub,List(i,j->LinearCombinationVecs(nb,j))));
  u:=[];
  for i in nb do
    TriangulizeMat(i);
    Add(u,Filtered(i,j->j<>Zero(j)));
  od;
  return u;
end;

SMTX.BasisRadical := function(module)
local m,i,r;
  m:=SMTX.BasesMaximalSubmodules(module);
  r:=m[1];
  for i in [2..Length(m)] do
    r:=SumIntersectionMat(r,m[i])[2];
  od;
  return r;
end;
