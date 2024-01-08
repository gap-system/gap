#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Michael Smith, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains meataxe type routines to compute module homomorphisms
##  for modules that are not necessarily irreducible. They are mainly a
##  conversion of the module routines in the GAP3 package `autag' by the
##  first author.
##

InstallGlobalFunction(TestModulesFitTogether,function(m1,m2);
  if m1.field<>m2.field then
    Error("different fields");
  fi;
  if Length(m1.generators)<>Length(m2.generators) then
    Error("generators are different lengths");
  fi;
end);

# basis for homomorphism space, efficient only for small dimensions
BindGlobal("SmalldimHomomorphismsModules",function(m1,m2)
local f, d1, d2, e, z, g1, g2, r, b, n, a, gp, i, j, k;
  f:=m1.field;
  d1:=m1.dimension;
  d2:=m2.dimension;
  e:=[];
  z:=ListWithIdenticalEntries(d1*d2,Zero(f));
  z:=ImmutableVector(f,z);
  for gp in [1..Length(m1.generators)] do
    g1:=m1.generators[gp];
    g2:=m2.generators[gp];
    for i in [1..d1] do
      for j in [1..d2] do
        # calculate equation for i-th row, j-th column
        r:=ShallowCopy(z);
        # the entry in g*hom is the i-th row of g with the variables in the
        # j-th column
        for k in [1..d1] do
          b:=(k-1)*d2+j;
          r[b]:=r[b]+g1[i][k];
        od;
        # the entry in hom*g is the variables in the i-th row of hom with the
        # j-th column of g
        for k in [1..d2] do
          b:=(i-1)*d2+k;
          r[b]:=r[b]-g2[k][j];
        od;
        Add(e,r);
      od;
    od;
  od;
  n:=NullspaceMat(TransposedMat(e));
  b:=[];
  for i in n do
    # convert back to d1 x d2 matrix
    a:=[];
    for j in [1..d1] do
      Add(a,i{[(j-1)*d2+1..(j-1)*d2+d2]});
    od;
    a:=ImmutableMatrix(f,a);
    Add(b,a);
  od;
  return b;
end);


# the following code is essentially due to Michael Smith

# These routines are designed to accumulate a system of linear equations
#
#    M_1 X = V_1,  M_2 X = V_2 ...  M_t X = V_t
#
# Where each M_i is an m_i*n matrix, X is the unknown length n vector, and
# each V is an length m_i vector.  The equations can be added as each batch
# is calculated. Here is some pseudo-code to demonstrate:
#
#   eqns := newEqns (n, field);
#   i := 1;
#   repeat
#     <calculate M_i and V_i>
#     addEqns(M_i, V_i)
#     increment i;
#   until  i > t  or  eqns.failed;
#   if not eqns.failed then
#     S := solveEqns(eqns);
#   fi;
#
# As demonstrated by the example, an early notification of failure is
# available by checking ".failed".  All new equations are sifted with respect
# to the current set, and only added if they are independent of the current
# set. If a new equation reduces to the zero row and a nonzero vector
# entry, then there is no solution and this is immediately returned by
# setting eqns.failed to true.  The function solveEqns has an already
# triangulised system of equations, so it simply reduces above the pivots
# and returns the solution vector.


BindGlobal("SMTX_AddEqns",function ( eqns, newmat, newvec)
local n, weights, mat, vec, ReduceRow, t,
      newweight, newrow, newrhs, i, l, k;

# Add a bunch of equations to the system of equations in <eqns>.  Each
# row of <newmat> is the left-hand side of a new equation, and the
# corresponding row of <newvec> the right-hand side. Each equation in
# filtered against the current echelonised system stored in <eqns> and
# then added if it is independent of the system.  As soon as a
# left-hand side reduces to 0 with a non-zero right-hand side, the flag
# <eqns.failed> is set.

  Info(InfoMtxHom,6,"addEqns: entering" );

  n := eqns.dim;
  weights := eqns.weights;
  mat := eqns.mat;
  vec := eqns.vec;

  # reduce the (lhs,rhs) against the semi-echelonised current matrix,
  # and return either: (1) the reduced rhs if the lhs reduces to zero,
  # or (2) a list containing the new echelon weight, the new row and
  # the new rhs for the system, and the row number that this
  # equation should placed.
  ReduceRow := function (lhs, rhs)
  local lead, i, z;
    lead := PositionNonZero(lhs);
    Assert(0, n = Length(lhs));
    if lead > n then
      return rhs;
    fi;
    for i in [1..Length(weights)] do
      if weights[i] = lead then
        z := lhs[lead];
        lhs := lhs - z * mat[i]; rhs := rhs - z * vec[i];
        lead := PositionNonZero(lhs, lead);
        if lead > n then
          return rhs;
        fi;
      elif weights[i] > lead then
        return [lead, lhs, rhs, i];
      fi;
    od;
    return [lead, lhs, rhs, Length(weights)+1];
  end;

  for k in [1..Length(newmat)] do
    t := ReduceRow(newmat[k], newvec[k]);

    if IsList(t) then
      # new equation
      newweight := t[1];
      newrow := t[2];
      newrhs := t[3];
      i := t[4]; # position for new row

      # normalise so that leading entry is 1
      newrhs := newrhs / newrow[newweight];
      newrow := newrow / newrow[newweight]; # NB: in this order

      if i = Length(mat)+1 then
        # add new equation to end of list
        Add(mat, newrow);
        Add(vec, newrhs);
        Add(weights, newweight);
      else
        l := Length(mat);
        # move down other rows to make space for this new one...
        mat{[i+1..l+1]} := mat{[i..l]};
        vec{[i+1..l+1]} := vec{[i..l]};
        # and then slot it in
        mat[i] := newrow;
        vec[i] := newrhs;
        weights{[i+1..l+1]} := weights{[i..l]};
        weights[i] := newweight;
      fi;

    else
      # no new equation, check whether inconsistent due to
      # nonzero rhs reduction

      if not IsZero(t) then
        Info(InfoMtxHom,6,"addEqns: FAIL!" );
        eqns.failed := true;
        return eqns; # return immediately
      fi;
    fi;
  od;
end);

BindGlobal("SMTX_NewEqns",function (arg)
local X, n, F, V, eqns;

  if Length(arg) <2 then
    Error("NewEqns(dim, field) or NewEqns(X, V)");
  fi;

  if IsInt(arg[1]) then
    X := false;
    n := arg[1];
    F := arg[2];
  else
    X := arg[1];
    V := arg[2];
    n := Length(X[1]);
    F := Field(X[1][1]); # Note: prime field only
  fi;

  eqns := rec();
  eqns.dim := n;              # number of variables
  eqns.field := F;            # field over which the equation hold
  eqns.mat := [];             # left-hand sides of system
  eqns.weights := [];         # echelon weights for lhs matrix
  eqns.vec := [];             # right-hand sides of system
  eqns.failed := false;         # flag to indicate inconsistent system
  eqns.index := [];           # index for row ordering

  if IsMatrix(X) then
    SMTX_AddEqns(eqns, X, V);
  fi;

  return eqns;
end);

BindGlobal("SMTX_KillAbovePivotsEqns",function (eqns)
# Eliminate entries above pivots. Note that the pivot entries are
# all 1 courtesy of SMTX_AddEqns.

local m, n, zero, i, c, j, factor;

  Info(InfoMtxHom,6,"killAbovePivotsEqns: entering" );
  m := Length(eqns.mat);
  n := eqns.dim;
  if m > 0 then
    zero := Zero(eqns.field);
    for i in [1..m] do
      c := eqns.weights[i];
      for j in [1..i-1] do
        if eqns.mat[j][c] <> zero then
          Info(InfoMtxHom,6,"solveEqns: kill mat[",j,",",c,"]");
          factor := eqns.mat[j][c];
          eqns.mat[j] := eqns.mat[j] - factor*eqns.mat[i];
          eqns.vec[j] := eqns.vec[j] - factor*eqns.vec[i];
        fi;
      od;
    od;
  fi;
  Info(InfoMtxHom,6,"killAbovePivotsEqns: leaving" );
end);

BindGlobal("SMTX_NullspaceEqns",function(e)

# Take the matrix stored in equation record <e> and compute a basis
# for its nullspace, ie  x  such that  mat * x = 0.  Note that the
# vector is on the other side of the matrix from GAP's NullspaceMat.
# This means we get to skip the Transposing that occurs at the top
# of that function (a bonus!).
#
# This function is a modified version NullspaceMat in matrix.g

local mat, n, one, zerovec, i, k, nullspace, row;

  SMTX_KillAbovePivotsEqns(e);
  mat := e.mat;

  n := e.dim;
  one  := One(e.field);

  # insert zero rows to bring the leading term of each row on the diagonal
  if mat = [] then
    if n=0 then return [];fi;
    mat := ZeroMatrix(e.field, n, n);
  else
    zerovec := MakeImmutable(ZeroVector(n, mat));
    i := 1;
    while i <= NrRows(mat) do
      if i < n and IsZero(mat[i,i]) then
        Add(mat, zerovec, i);
      fi;
      i := i+1;
    od;
    for i  in [ NrRows(mat)+1 .. n ]  do
      Add(mat, zerovec);
    od;
    ConvertToMatrixRep(mat);
  fi;

  # The following comment from NullspaceMat:
  # 'mat' now  looks  like  [ [1,2,0,2], [0,0,0,0], [0,0,1,3], [0,0,0,0] ],
  # and the solutions can be read in those columns with a 0 on the diagonal
  # by replacing this 0 by a -1, in  this  example  [2,-1,0,0], [2,0,3,-1].
  nullspace := [];
  for k in [1..n] do
    if IsZero(mat[k,k])  then
      row := ZeroVector(n, mat);
      for i  in [1..k-1]  do row[i] := -mat[i,k];  od;
      row[k] := one;
      Add( nullspace, row );
    fi;
  od;

  return nullspace;
end);


BindGlobal("EchResidueCoeffs",function (base, ech, v,mode)
local n, coeffs, x, zero, z, i;
#
# Take a semi-ech basis <base>, with ech weights <ech>, and a vector
# <v> in the subspace spanned by <base>. Returns:
# if mode>2:
# a record containing the
# residue after removing projection of <v> onto subspace spanned by
# <base>, as well as the coefficients of the linear combination of
# <base> elements used to obtain the projection. Also return the
# projection.
# if mode =1 returns only the coefficients
# if mode=2 returns only the residue

# Note that the pivots of <base> must be set to 1.

  n:=Length(base);

  if n = 0 then
    coeffs:=[];
    x:=v;
  else
    x:=v;
    zero:=x[1]*0;
    coeffs:=ListWithIdenticalEntries(n, zero);
    for i in [1..n] do
      z:=x[ech[i]];
      if z <> zero then
        x:=x - z * base[i];
        coeffs[i]:=z;
      fi;
    od;
  fi;

  if mode=1 then
    return coeffs;
  elif mode=2 then
    return x;
  else
    return rec(coeffs:=coeffs,
              residue:=x,
              projection:=v - x
              );
  fi;
end);

BindGlobal("SpinSpaceVector",function (V, U, ech, v,zero)
local gens, pos, settled, oldlen, i, j;

# Take <U> a semi-ech basis for a submodule of <V>, with ech-weights
# <ech>, and a vector <v> in <V>. Return a semi-ech basis for the
# submodule generated by <U> and <v>.

  U:=ShallowCopy(U);
  ech:=ShallowCopy(ech);
  gens:=V.generators;

  v:=EchResidueCoeffs(U, ech, v,2);
  pos:=PositionNonZero(v);
  if pos > Length(v) then
    return U;
  fi;
  Add(U, v/v[pos]); Add(ech, pos);

  settled:=Maximum(Length(U),1); # <U> is a submodule
  repeat
    oldlen:=Length(U);
    for i in [settled+1..Length(U)] do
      for j in [1..Length(gens)] do
        v:=EchResidueCoeffs(U, ech, (U[i] * gens[j]),2);
        pos:=PositionNonZero(v);
        if pos <= Length(v) then
          Add(U, v/v[pos]); Add(ech, pos);
        fi;
      od;
    od;
    settled:=oldlen;
  until oldlen = Length(U);
  return U;
end);

BindGlobal("SpinHomFindVector",function (r)
local V, nv, W, nw, U, echu, F, matsV, matsW, k, g1, g2, max_stack_len, _t,
      newstack, v0, extradim, N, count, look_lim, done, grpalg, i, M, pos, A,
      j,zero;

# <r> contains information about modules <V> and <W>, and a submodule
# <U> of <V> with semi-ech information <echu>. The routine selects
# an element of <V> lying outside of <U> that will be used to spin
# up to a new submodule U'.
#
# It returns a list [<v0>, <M>] where <v0> is the element of <V>
# and <M> is a basis for a submodule of <W> which <v0> must map into
# under any hom.

  V:=r.V;    nv:=V.dimension;
  W:=r.W;    nw:=W.dimension;
  U:=r.U;    echu:=r.echu;
  F:=V.field;
  zero:=Zero(F);

  if not IsBound(r.mats) then
    matsV:=V.generators;
    matsW:=W.generators;
    k:=Length(matsV);
    r.mats:=List([1..k], i -> [matsV[i], matsW[i]]);

    # do preprocessing to make random matrices list in parallel

    for i in [1..10] do
      g1:=Random(1, k);
      g2:=g1;
      while g2 = g1 and Length(r.mats)>1 do
        g2:=Random(1, k);
      od;
      Add(r.mats,[r.mats[g1][1]*r.mats[g2][1],
                  r.mats[g1][2]*r.mats[g2][2]]);
      k:=k + 1;
    od;

    r.zero:=[ ImmutableMatrix(F,NullMat(nv,nv,F)),
              ImmutableMatrix(F,NullMat(nw,nw,F)) ];

    # we build a stack of good grpalg elements to use for choosing
    # elements <v0> --- an element <A> in <stack> is of the form:
    #   A[1] = v0
    #   A[2] = grpalg element whose nullspace contains v0
    #   A[3] = Dim(<U,v0>^G)-Dim(U) i.e. increase in dim by adding
    #          <v0> to <U>
    r.stack:=[];

  else
    k:=Length(r.mats);
  fi;

  max_stack_len:=10;

  # adjust the elements of the stack to account for the larger
  # submodule <U> we now have
  _t:=Runtime();
  newstack:=[];
  for A in r.stack do
    v0:=A[1];
    extradim:=Length(SpinSpaceVector(V, U, echu, v0,zero))
                - Length(U);
    if extradim > 0 then
      Add(newstack, [v0, A[2], extradim]);
    fi;
  od;
  r.stack:=newstack;
  Info(InfoMtxHom,2,"stack reduced to length ", Length(r.stack), " (",
          Runtime()-_t, ")");

  # <N> contains the nullspace in <V> of a group algebra element ---
  # initialise it to the empty list for the following repeat loop
  N:=[];

  count:=0;
  look_lim:=5;  # give up after this many random grpalg elements

  _t:=Runtime();

  if Length(r.stack) > 0 then
    # if we have something left, don't bother generating any new
    # grpalg elements (?)
    count:=look_lim + 1;
  fi;

  done:=false;
  while count < look_lim and Length(r.stack) < max_stack_len and not done do

    # we look for a while and take the best element found

    # We are looking for an element <v0> of a nullspace that lies
    # outside of <U>

    repeat
      # Take a work record <r> containing the information about the two
      # modules <V> and <W>, and return a random group algebra element
      # record containing its action on each of the modules.

      # first take two elements of the list and multiply them
      # together
      g1:=Random(1, k);
      repeat
        g2:=Random(1, k);
      until g2 <> g1 or Length(r.mats)=1;
      Add(r.mats,[r.mats[g1][1]*r.mats[g2][1],
                  r.mats[g1][2]*r.mats[g2][2]]);
      k:=k + 1;

      # Now take a random linear sum of the existing generators as new
      # generator.  Record the sum in coefflist

      grpalg:=ShallowCopy(r.zero);

      for g1 in [1..k] do
        g2:=Random(F);
        if not IsZero(g2) then
          grpalg[1]:=grpalg[1] + g2*r.mats[g1][1];
          grpalg[2]:=grpalg[2] + g2*r.mats[g1][2];
        fi;
      od;
      N:=TriangulizedNullspaceMat(grpalg[1]);
      count:=count + 1;
    until Length(N) > 0 or count >= look_lim;

    if Length(N) > 0 then

      # now find best element of <N> for adding to <stack>
      extradim:=List(N, y ->
                        Length(SpinSpaceVector(V, U, echu, y,zero))
                        - Length(U));
      i:=1;
      for j in [2..Length(extradim)] do
        if extradim[j] > extradim[i] then
          i:=j;
        fi;
      od;
      if extradim[i] > 0 then
        # exit early if we have found an element that gets use all
        # of <V> after spinning
        done:=extradim[i] = nv - Length(U);
        if done then
          r.stack:=[[N[i], grpalg, extradim[i]]];
        else
          Add(r.stack, [N[i], grpalg, extradim[i]]);
        fi;
      fi;
    fi;

  od;
  Info(InfoMtxHom,2,"stack loop done, stack now length ", Length(r.stack), " (",
          Runtime()-_t, ")");

  if Length(r.stack) > 0 then
    #
    # find best element in r.stack and use it
    i:=1;
    for j in [2..Length(r.stack)] do
      if r.stack[j][3] > r.stack[i][3] then
        i:=j;
      fi;
    od;
    v0:=r.stack[i][1];
    M:=TriangulizedNullspaceMat(r.stack[i][2][2]);

  else

    # we haven't found a good grpalg element, so just choose
    # something outside of <U> and use it

    Info(InfoMtxHom,1,"too many random grpalg elements...");
    M:=IdentityMat(nw,F);
    pos:=Difference([1..nv], echu)[1];
    v0:=ListWithIdenticalEntries(nv,zero);
    v0[pos]:=One(F);
    v0:=ImmutableVector(F,v0);
  fi;
  return [v0, M];

end);

# compute a semi-echelonised basis for a matrix algebra
# If a linearly dependent set of elements is supplied, this
# routine will trim it down to a basis.
BindGlobal("SMTX_EcheloniseMats",function (gens, F)
local n, m, zero, ech, k, i, j, found, l;

  if Length(gens) = 0 then
    return [ [], [] ];
  fi;
  # copy the list to avoid destroying the original list
  gens:=List(gens,i->List(i,ShallowCopy));

  n:=Length(gens[1]);
  m:=Length(gens[1][1]);
  zero:=Zero(F);

  ech:=[];
  k:=1;

  while k <= Length(gens) do
    i:=1; j:=1;
    found:=false;
    while not found and i <= n do
      if (gens[k][i][j] <> zero) then
        found:=true;
      else
        j:=j + 1;
        if (j > m) then
          j:=1; i:=i + 1;
        fi;
      fi;
    od;

    if found then

      # Now basis element k will have echelonisation index [i,j]
      Add(ech, [i,j]);

      # First normalise the [i,j] position to 1
      gens[k]:=gens[k] / gens[k][i][j];

      # Now zero position [i,j] in all further generators
      for l in [k+1..Length(gens)] do
        if (gens[l][i][j] <> zero) then
          gens[l]:=gens[l] - gens[k] * gens[l][i][j];
        fi;
      od;
      k:=k + 1;
    else
      # no non-zero element found, delete from list
      Remove(gens, k);
    fi;
  od;
  return [List(gens,i->ImmutableMatrix(F,i)), ech];
end);

# The SpinHom routine in this file was written during August 1996. The
# basic idea comes from a discussion I had with Charles Leedham-Green early
# in 1995. He gave me a rough sketch of the algorithm that he and John
# Cannon developed for Magma. Some details were missing, and this is my
# attempt at filling in some of them.
#
# Many improvements were made on my earlier version, in large part due to a
# discussion I had with Alice Niemeyer in early 1996. She relayed to me
# some comments of Klaus Lux on my earlier version. This is a combination
# of the suggestions of Klaus and Alice and my own ideas.
#
# Note: This provides an enormous speed-up on the default GAP routine,
# and on my own naive intertwining routine, especially when the module is
# large enough and/or it is irreducible. However, this routine is nowhere
# near as good as the Magma algorithm, and I do not know how to improve it.
#
# The code is heavily commented, and I appreciate suggestions on how to
# improve it (particularly bits of code).
BindGlobal("SpinHom",function (V, W)
local nv, nw, F, zero, zeroW, gV, gW, k, U, echu, r, homs, s, work, ans, v0,
      M, x, pos, z, echm, t, v, echv, a, u, e, start, oldlen, ag, m, uu, ret,
      c, s1, X, mat, uuc, uic, newhoms, hom, Uhom, imv0, imv0c, image, i, j, l;

# Compute Hom(V,W) for G-modules <V> and <W>. The algorithm starts with
# the trivial submodule <U> of <V> for which Hom(U,V) is trivial.  It
# then computes Hom(U',W) for U' a submodule generated by <U> and a
# single element <v0> in <V>. This U' becomes the next <U> as the process
# is iterated, ending when <U'> = <V>. The element <v0> is chosen in a
# nullspace of a group algebra element in order to restrict it possible
# images in <W>.

  nv:=V.dimension;
  nw:=W.dimension;

  F:=V.field;
  if F<>W.field then
    Error("different fields");
  fi;
  zero:=Zero(F);

  zeroW:=ListWithIdenticalEntries(nw,zero);
  zeroW:=ImmutableVector(F,zeroW);

  # group generating sets acting on each module
  gV:=V.generators;
  gW:=W.generators;

  # <k> is the number of generators of the acting group
  k:=Length(gV);
  if k<>Length(gW) then
    Error("generator lengths");
  fi;

  # <U> is the semi-ech basis for the currently known submodule, of
  # dimension <r>
  U:=[];
  echu:=[];
  r:=0;

  # <homs> contains a basis for Hom(U,W), of dimension <s>
  homs:=[];
  s:=0;

  # define a record which stores information about the modules <V>, <W>
  # and <U> for passing into a routine that selects a new vector <v0>
  # for spinning up to a larger submodule U'.
  work:=rec(V:=V, W:=W, U:=U, echu:=echu);

  repeat

    # we loop until <U> is the whole of <V>

    ans:=SpinHomFindVector(work);
    v0:=ans[1];
    M:=ans[2];

    # find residue of <v0> modulo current submodule <U>
    x:=EchResidueCoeffs(U, echu, v0,2);

    # normalise <x> (ie get a 1 in leading position)
    pos:=PositionNonZero(x);
    z:=x[pos];
    x:=x / z;
    v0:=v0 / z;

    # we know that <v0> has to map into the subspace <M> of <W>.
    echm:=List(M, PositionNonZero);
    t:=Length(M);

    # now we start building extension of semi-echelonised basis for
    # the submodule U' generated by <U> and <v0>
    #
    # new elements of semi-ech basis will be stored in <v>, with
    # echelon weights stored in <echv>

    v:=[ x ];
    echv:=[ pos ];

    # we need to keep track of how each new element of the semi-ech
    # basis was obtained from <v0> --- new basis element <v[i]> will
    # satisfy:
    #
    #     v[i]  =  v0*a[i] + u[i]
    #
    # where <a[i]> is an element of the group algebra FG, and <u[i]> is
    # the element of <U> that was subtracted during semi-ech reduction

    a:=[ M ];
    u:=[ x - v0 ];

    # we will accumulate the homogeneous linear system in <e>
    #
    # the first <s> variables are the coefficients of basis elements of
    # Hom(U,W), which describes how a hom of U' acts on submodule <U>
    #
    # the other <t> variables are the coefficients of basis elements of
    # <M>, which describes the image of <v0> under a hom
    #
    e:=SMTX_NewEqns(s + t, F);

    # we will close the submodule by spinning <v0> --- the variable
    # <start> will trim off the elements of <v> that we have already
    # used
    start:=1;

    repeat

      # take an element <v[i]> of <v> and a group generator <g[j]>
      # and check whether <v[i]^g[j]> is a new basis element.
      #
      # if it is, add it to the basis, with its definition.
      #
      # if it isn't, we get an equation which an element of Hom(U',W)
      # must satisfy

      oldlen:=Length(v);

      for i in [start..oldlen] do     ### loop on vectors in <v>
        for j in [1..k] do          ### loop on generators of G

          if Length(a[i])=0 then
            #T: special treatment 0-dimensional
            ag:=[];
          else
            ag:=a[i] * gW[j];
          fi;

          # create new element <x>, with its definition as the
          # difference between <v0^m> and <uu> in <U>.
          x:=v[i] * gV[j];
          m:=ag;
          uu:=u[i] * gV[j];

          ret:=EchResidueCoeffs(U, echu, x,3);
          x:=ret.residue;
          uu:=uu - ret.projection;

          # reduce modulo the new semi-ech basis elements in <v>,
          # storing the coefficients in <c>
          #
          c:=ListWithIdenticalEntries(Length(v),zero);
          for l in [1..Length(v)] do
            z:=x[echv[l]];
            if z <> zero then
              x:=x - z * v[l];
              if Length(m) > 0 then
                  m:=m - z * a[l];
              fi;
              c[l]:=c[l] + z;
              uu:=uu - z * u[l];
            fi;
          od;
      c:=ImmutableVector(F,c);

          # Note: at this point, <x> has been reduced modulo the
          # semi-ech basis <U> union <v>, and that
          #
          #     x = v0 * a[i] + uu

          pos:=PositionNonZero(x);
          if pos <= Length(x) then

            # new semi-ech basis element <x>

            z:=x[pos];
            Add(v, x/z);
            Add(echv, pos);
            Add(a, m/z);
            Add(u, uu/z);

          else

            # we get some equations !

            s1:=Sum([1..Length(v)], y -> c[y] * v[y]);
            uu:=v[i] * gV[j] - s1;

            X:=NullMat(t, nw, F);
            for l in [1..Length(v)] do
              if c[l] <> zero then
                if Length(X) > 0 then
                  X:=X + c[l] * a[l];
                fi;
                uu:=uu + c[l] * u[l];
              fi;
            od;

            if Length(X) > 0 then
              X:=X - ag;
            fi;

            mat:=[];
            uuc:=EchResidueCoeffs(U, echu, uu,1);
            uic:=EchResidueCoeffs(U, echu, u[i],1);
            for l in [1..s] do
              Add(mat, uuc * homs[l] - uic * homs[l] * gW[j]);
            od;
            Append(mat, X);
            SMTX_AddEqns(e, TransposedMat(mat), zeroW);
          fi;
        od;
      od;

      start:=oldlen+1;

      # exit when no new elements were added --- i.e. the subspace
      # is closed under action of G and is therefore a submodule

    until oldlen = Length(v);

    # we have the system of equations, so find its solution space

    ans:=SMTX_NullspaceEqns(e);

    # Now build the homomorphisms

    newhoms:=[];
    for i in [1..Length(ans)] do

      # Each row of ans is of the form:
      #
      #     [ b_1, b_2, ..., b_s, c_1, c_2, ..., c_t ]
      #
      # where the action of this hom on <U> is as \Sum{b_l homs[l]}
      # and the hom sends <v0> to Sum{c_l M[l]}

      hom:=[];
      if r > 0 then
        Uhom:=NullMat(r, nw, F);
        for l in [1..s] do
          if ans[i][l] <> zero then
            Uhom:=Uhom + ans[i][l] * homs[l];
          fi;
        od;
        for l in [1..r] do
          Add(hom, Uhom[l]);
        od;
      fi;

      imv0:=zeroW * zero;
      for l in [1..t] do
        if ans[i][s+l] <> zero then
          imv0:=imv0 + ans[i][s+l] * M[l];
        fi;
      od;
      imv0c:=EchResidueCoeffs(M, echm, imv0,1);
      for l in [1..Length(v)] do
        if Length(imv0c)=0 then image:=[];
        else image:=imv0c * a[l];fi;
        if r > 0 then
          image:=image + EchResidueCoeffs(U, echu, u[l],1) * Uhom;
        fi;
        Add(hom, image);
      od;
      hom:=ImmutableMatrix(F,hom);
      Assert(1,hom<>0*hom);
      Add(newhoms, hom);
    od;

    # now update <U> to be the now larger submodule

    Append(U,v);
    Append(echu, echv);
    homs:=newhoms;
    r:=Length(U);
    s:=Length(homs);

    Info(InfoMtxHom,1,"U is now dimension ", r, " and dim(Hom(U,W)) = ", s);

  until r = nv; # i.e. <U> = <V>

  if Length(homs)=0 then
    return homs;
  fi;

  # We must change basis on <V> from <U> to the usual one before returning

  U:=ImmutableMatrix(F,U);
  return U^-1 * homs;

end);


# module isomorphism and decomposition routines
#
# These are functions for computing with modules, including:
#
#   (1) computing a direct sum decomposition of a module into
#   indecomposable summands.
#
#   (2) deciding module isomorphism using the decomposition.
#
# The algorithm for deciding indecomposability is based on the algorithm
# described by G. Schneider in the Journal of Symbolic Computation,
# Volume 9, Numbers 5 & 6, 1990


# Take a Fitting element and use it to split M into a direct sum
# of submodules. Return the submodules.
# r is the rank of a (which might be known before
BindGlobal("FittingSplitModule",function (a,r,F)
local n, ro;

  # do we have a fitting matrix?
  # a matrix is a fitting matrix if it is singular but not nilpotent.
  # case
  n:=Length(a);
  if r=n or r=0 then
    # not singular or zero.
    return fail;
  fi;
  # now square repeatedly until the rank stays the same and >0
  repeat
    ro:=r;
    a:=a^2;
    r:=RankMat(a);
  until ro=r or r=0;
  if r=0 then
    return fail;
  fi;
  # otherwise a is a power of a fitting matrix, the space will split in
  # Kern(a) \oplus Image(a)

  Info(InfoMeatAxe,2,"Decomposition ",r,":",n-r," found");

  return [ImmutableMatrix(F,BaseMat(a)),NullspaceMat(a)];
end);

# Take a module and break it into two pieces if possible.
# The function searches for a decomposition of the module M while
# attempting to prove indecomposability at the same time.  Of course,
# only one of these will succeed.
BindGlobal("ProperModuleDecomp",function (M)
local proveIndecomposability, addnilpotent, n, F, zero, basis, enddim,
      echelon, nildim, p, maxorder, maxa, nilbase, nilech, cnt, remain,
      coeffs, a, rk, order, fit, pos, newa, lastdim, i;

  # Check whether we have found the indecomposability proof. That is,
  # see whether our regular element generates a subalgebra which
  # complements the current nilpotent ideal (the approximation to
  # radical)
  proveIndecomposability:=function ()
  local maxaord;
  # NB: <maxa> is not local

    if enddim - nildim = LogInt(maxorder + 1,p) then
      # Yes, found the residue field root and proved indecomposability!
      maxaord:=Order(maxa);
      while maxaord > maxorder do
        maxa:=maxa^p;
        maxaord:=maxaord / p;
      od;
      SMTX.SetEndAlgResidue(M, [maxa, maxaord]);
      Info(InfoMtxHom,3,"proved ",Length(nilbase));
      SMTX.SetBasisEndomorphismsRadical(M, nilbase);
      return true;
    fi;
    return false;
  end;

  # take a new nilpotent element and sift against current nilpotent
  # ideal basis. If it does not lie in the space spanned so far,
  # add it to nilbasis
  addnilpotent:=function (a)
  local i, r, c, k, done, l;
  # NB: <remain> and <nildim> and <cnt> are not local

    for i in [1..nildim] do
      r:=echelon[nilech[i]][1]; c:=echelon[nilech[i]][2];
      if a[r][c] <> zero then
        a:=a - a[r][c] * nilbase[i] / nilbase[i][r][c];
      fi;
    od;

    # find which echelon index to remove due to this new element
    k:=1; done:=false;
    while not done and k <= Length(remain) do
      l:=remain[k];
      r:=echelon[l][1]; c:=echelon[l][2];
      if a[r][c] <> zero then
        done:=true;
      else
        k:=k + 1;
      fi;
    od;

    if k > Length(remain) then
      # in nilpotent ideal already, return
      return false;
    fi;

    # We now know this nilpotent element is a new one
    Add(nilbase, a);

    # the k-th basis element was used to make the new element a. So
    # remove it from future random element calculations
    #
    Add(nilech, remain[k]);
    remain:=Difference(remain, [remain[k]]);
    nildim:=nildim + 1;
    cnt:=1;
    return true;
  end;

  if not M.IsOverFiniteField then
    return Error ("Argument of ProperModuleDecomp is not over a finite field.");
  fi;
  n:=M.dimension;
  F:=M.field;

  zero:=Zero(F);
  Info(InfoMtxHom,2,"ProperModuleDecomp for module of dimension ", n);

  if n = 1 then
    # A 1-dimensional module is always indecomposable
    Info(InfoMtxHom,3,"1dimensional");
    SMTX.SetEndAlgResidue(M, [[[ PrimitiveElement(F) ]], Size(F) - 1]);
    SMTX.SetBasisEndomorphismsRadical(M, []);
    return fail;
  fi;

  basis:=SMTX.BasisModuleEndomorphisms(M);
  if Length(basis) = 1 then
    # if endomorphism algebra has dimension 1 then indecomposable
    #SMTX.SetEndAlgResidueFlag(M, F.root * GModOps.EndAlgBasisFlag(M)[1], F.size - 1);
    SMTX.SetEndAlgResidue(M, [PrimitiveElement(F)*basis[1], Size(F) - 1]);
    Info(InfoMtxHom,3,"basislength 1");
    SMTX.SetBasisEndomorphismsRadical(M, []);
    return fail;
  fi;

  enddim:=Length(basis);            # dim of endo algebra
  echelon:=SMTX_EcheloniseMats(basis,F)[2]; # echelon indices for endalg basis
  nildim:=0;                        # dim of current approx to radical
  p:=Size(F);
  maxorder:=1;                      # order of largest order regular elmt
                                    #   found so far
  maxa:=IdentityMat(n,F);           # the regular elmt with order maxorder
  nilbase:=[];                      # basis for approx to radical
  nilech:=[];

  cnt:=1;

  # We will "quotient" out the nilpotent subspace as we go. The elements
  # of remain tell us which (echelonised) basis elements of the
  # endomorphism algebra we will take use in our random linear
  # combination.
  #
  remain:=[1..enddim];

  repeat
    # we will loop until too many passes without an improvement in knowledge
    repeat
      # randomly sample endomorphism algebra
      repeat
        coeffs:=List([1..enddim], x -> Random(F));
      until ForAny(remain,x->not IsZero(coeffs[x]));

      a:=LinearCombination(basis,coeffs);

      rk:=RankMat(a);
      if rk=n then
        # a regular element, check to see whether its order is
        # larger than previously known, and if so whether it
        # generates the residue field modulo current nilpotent ideal
        order:=Order(a);

        while (order mod p = 0) do
            order:=order / p;
        od;
        if order > maxorder then
          maxorder:=order;
          maxa:=a;
          if proveIndecomposability() then
            return fail;
          fi;
          cnt:=1;
        else
          cnt:=cnt + 1;
        fi;
      else
        fit:=FittingSplitModule(a,rk,F);
        if fit<>fail then
          return fit;
        elif addnilpotent(a) then
          # new nilpotent element, added to nilbasis. Now close nilbasis to
          # basis for an ideal.

          # keep a pointer to the first new element added to nilbase
          pos:=nildim; # a was just added

          # first add powers of a
          newa:=a^2;
          repeat
            lastdim:=nildim;
            addnilpotent(newa);
            newa:=newa * a;
          until lastdim = nildim or IsZero(newa);

          # now close nilbase to make ideal basis
          repeat
            for i in [1..enddim] do
              a:=nilbase[pos] * basis[i];
              fit:=FittingSplitModule(a,RankMat(a),F);
              if fit <> fail then
                return fit;
              fi;
              addnilpotent(a);
            od;
            pos:=pos + 1;
          until pos = nildim + 1;
        fi;
      fi;

      if proveIndecomposability() then
        return fail;
      fi;
    until (cnt >= 20000);
    Error("Unable to ascertain module decomposition within time limits.\n",
          "Call `return;' to try again.");
    cnt:=0;
  until false;
end);


BindGlobal("SMTX_Indecomposition",function(m)
local n, F, stack, i, d, d2, md, b, endo, sel, e1, e2;
  if not IsBound(m.indecomposition) then
    n:=m.dimension;
    F:=m.field;
    stack:=[[IdentityMat(n,F),m]];
    i:=1;
    while i<=Length(stack) do
      d:=ProperModuleDecomp(stack[i][2]);
      if d<>fail then
        if Length(stack[i][1])<n then
          d2:=List(d,j->j*stack[i][1]);
        else
          d2:=d;
        fi;
        md:=List(d2,i->SMTX.InducedActionSubmodule(m,i));
        Assert(1,ForAll(md,i->i<>fail));
        # Translate endomorphism rings
        b:=Concatenation(d[1],d[2]); # local new basis
        # basechange
        endo:=List(stack[i][2].basisModuleEndomorphisms,
                   i->b*i/b);
        sel:=[1..Length(d[1])];
        e1:=List(endo,i->i{sel}{sel});
        e1:=SMTX_EcheloniseMats(e1,F)[1];
        Assert(1,ForAll(md[1].generators,i->ForAll(e1,j->i*j=j*i)));
        md[1].basisModuleEndomorphisms:=e1;
        sel:=[Length(d[1])+1..stack[i][2].dimension];
        e2:=List(endo,i->i{sel}{sel});
        e2:=SMTX_EcheloniseMats(e2,F)[1];
        Assert(1,ForAll(md[2].generators,i->ForAll(e2,j->i*j=j*i)));
        md[2].basisModuleEndomorphisms:=e2;
        stack[i]:=[d2[1],md[1]];
        Add(stack,[d2[2],md[2]]);
      else
        SMTX.SetIsIndecomposable(stack[i][2],true);
        i:=i+1;
      fi;
    od;
    m.indecomposition:=stack;
  fi;
  return m.indecomposition;
end);

SMTX.Indecomposition:=SMTX_Indecomposition;


# Check isomorphism of indecomposable modules.
#
# If they are isomorphic then the homomorphism space between them is a
# disguised copy of the endomorphism algebra. This is a local algebra,
# and hence all singular elements are nilpotent. Certainly it cannot
# have a basis consisting entirely of nilpotent elements (a theorem of
# Wedderburn), so at least one basis element for Hom(M1,M2) must be an
# isomorphism if they are isomorphic.
BindGlobal("IsomIndecModules",function (M1, M2)
local base, i,n;

  if not (SMTX.IsIndecomposable(M1) and SMTX.IsIndecomposable(M2)) then
    Error("IsomIndecModules: requires indecomposable modules");
  fi;

  n:=M1.dimension;
  # module dimensions certainly must match
  if n<>M2.dimension or

    # their endomorphism algebras must have same dimension
     Length(SMTX.BasisModuleEndomorphisms(M1)) <>
     Length(SMTX.BasisModuleEndomorphisms(M2)) or

    (SMTX.BasisEndomorphismsRadical(M1)<>fail  and
     SMTX.BasisEndomorphismsRadical(M2)<>fail  and
     Length(SMTX.BasisEndomorphismsRadical(M1))<>
     Length(SMTX.BasisEndomorphismsRadical(M2)) ) then
    return fail;
  fi;
  # the easy options have run out

  # Last case, both modules are idecomposable but not necessarily irreducible.
  # In this case, compute Hom and look for isom in the basis.

  base:=SMTX.BasisModuleHomomorphisms(M1, M2);

  for i in base do
    if RankMat(i) = n then
      return i;
    fi;
  od;

  return fail;

end);

BindGlobal("SMTX_HomogeneousComponents",function(m)
local d, h, found, i, m1, idx, imgs, hom, j;
  d:=SMTX.Indecomposition(m);
  h:=[];
  found:=[];
  i:=1;
  while Length(found)<Length(d) do
    if not i in found then
      m1:=d[i][2];
      idx:=[i];
      AddSet(found,i);
      imgs:=[];
      for j in [i+1..Length(d)] do
        if not j in found and m1.dimension=d[j][2].dimension then
          hom:=IsomIndecModules(d[j][2],m1);
          if hom<>fail then
            Add(idx,j);
            AddSet(found,j);
            Add(imgs,rec(component:=d[j],isomorphism:=hom^-1));
          fi;
        fi;
      od;
      Add(h,rec(component:=d[i],images:=imgs,indices:=idx));
    fi;
    i:=i+1;
  od;
  return h;
end);

SMTX.HomogeneousComponents:=SMTX_HomogeneousComponents;


# Test for isomorphism of modules. Will return one of:
#
# (1) the isomorphism as an F-matrix between M1 and M2
# (2) fail if the two modules are definitely not isomorphic
#
# Note that the isomorphism X is such that conjugating each generator
# acting on M1 by X gives the corresponding action on M2. Therefore
# X^-1 is a matrix whose rows correspond to a new basis of M1 that
# duplicates the action of M2 on M1.
#
# If necessary, uses the decomposition into indecomposable summands.  A
# homogeneous component is a direct sum of multiple copies of a single
# indecomposable summand. The homogeneous components must match between
# each module, with their multiplicities.
BindGlobal("SMTX_IsomorphismModules",function (M1, M2)
local n, hc1, hc2, nc, b1, b2, map, remain, j, found, hom, i, k;

  TestModulesFitTogether(M1,M2);
  n:=M1.dimension;

  if n <> M2.dimension then
    # Modules have different dimensions
    return fail;
  elif (SMTX.BasisEndomorphismsRadical(M1)<>fail  and
    SMTX.BasisEndomorphismsRadical(M2)<>fail  and
    Length(SMTX.BasisEndomorphismsRadical(M1))<>
    Length(SMTX.BasisEndomorphismsRadical(M2)) ) then
    # different endomorphism algebra dimensions
    return fail;
  fi;

  hc1:=SMTX.HomogeneousComponents(M1);
  hc2:=SMTX.HomogeneousComponents(M2);

  nc:=Length(hc1);
  if nc <> Length(hc2) then
    return fail;
  fi;

  # build bases that must be mapped to each other iteratively
  b1:=[];
  b2:=[];
  map:=[];

  remain:=[1..nc];
  for i in [1..nc] do
    j:=1;found:=false;
    while j<=nc and not found do
      if j in remain and Length(hc1[i].indices)=Length(hc2[j].indices) then
        # test: i isomorphic j?
        hom:=IsomIndecModules(hc1[i].component[2],hc2[j].component[2]);
        if hom<>fail then
          # the homogeneous components are isomorphic
          found:=true;
          Append(b1,hc1[i].component[1]);
          Append(b2,hc2[j].component[1]);
          Add(map,hom);
          for k in [1..Length(hc1[i].images)] do
            Append(b1,hc1[i].images[k].component[1]);
            Append(b2,hc2[j].images[k].component[1]);
            Add(map,hc1[i].images[k].isomorphism^-1*hom*
                    hc2[j].images[k].isomorphism);
          od;
        fi;
      fi;
      j:=j+1;
    od;
    if found=false then
      # one homogeneous component has no image -- the modules cannot be
      # isomorphic
      return fail;
    fi;
  od;
  b1:=ImmutableMatrix(M1.field,b1);
  b2:=ImmutableMatrix(M1.field,b2);
  return b1^-1*ImmutableMatrix(M1.field,DirectSumMat(map))*b2;
end);

SMTX.IsomorphismModules:=SMTX_IsomorphismModules;

# Note: matalg is a basis for a nilpotent matrix algebra whose elements
# are all in lower diagonal form (zeros on the main diagonal).
#
# Echelonisation indices are chosen as the earliest non-zero entries
# running down diagonals below the main diagonal:
#   [2,1], [3,2], [4,3], ..., [3,1], [4,2], ..., [n-1,1], [n, 2], [n,1]
BindGlobal("SMTX_EcheloniseNilpotentMatAlg",function (matalg, F)
local zero, n, flags, base, ech, k, diff, i, j, found, l;

  zero:=Zero(F);
  n := Length(matalg[1][1]);
  flags := NullMat(n,n);

  base := matalg;
  ech := [];
  k := 1;

  while k <= Length(base) do
    diff := 1;
    i := 2; j := i - diff;
    found := false;
    while not found and diff < n do
      if (base[k][i][j] <> zero) and
        (flags[i][j] = 0) then
        found := true;
      else
        i := i + 1;
        j := i - diff;
        if (i > n) then
          diff := diff + 1;
          i := diff + 1;
          j := i - diff;
        fi;
      fi;
    od;

    if found then

      # Now basis element k will have echelonisation index [i,j]
      Add(ech, [i,j]);

      # First normalise the [i,j] position to 1
      base[k] := base[k] / base[k][i][j];

      # Now zero position [i,j] in all other basis elements
      for l in [1..Length(base)] do
        if (l <> k) and (base[l][i][j] <> zero) then
          base[l] := base[l] - base[k] * base[l][i][j];
        fi;
      od;
      k := k + 1;

    else
      # no non-zero element found, delete from list
      base := base{ Concatenation([1..k-1], [k+1..Length(base)])};
    fi;
  od;
  return [base, ech];
end);

# compute a change of basis that exhibits the matrix algebra
# defined by the basis 'matalg' in triangular form.
BindGlobal("SMTX_NilpotentBasis",function (matalg)
local decompose, field, Y, mats, newbase;

  decompose := function ( m, b )
  local n, subs, vs, vsi,rep, newm,j,ran;

    if Length(m) = 0 then
      # all action is now zero, so append current full basis and
      # finish up
      Append(Y, b);
    else

      n := Length(m[1][1]);

      # find the intersection of the nullspaces
      subs:=NullspaceMat(m[1]);
      for j in [2..Length(m)] do
        subs:=SumIntersectionMat(subs,NullspaceMat(m[j]))[2];
      od;


      # Use matrix group routine to compute action of nilpotent
      # matrices on the quotient vectorspace
      vs := BaseSteinitzVectors(IdentityMat(n,field),subs);
      vs:=Concatenation(vs.subspace,vs.factorspace);
      vs:=ImmutableMatrix(field,vs);
      vsi:=vs^-1;
      ran:=[Length(subs)+1..n];
      rep:=List(m,i->vs*i*vsi);
      rep:=List(rep,i->i{ran}{ran});

      # Take a copy of the non-zero matrices acting on the quotient space
      #
      newm := Filtered(rep,x->not IsZero(x));

      Append(Y, subs * b);
      decompose( newm, vs{ran} * b );

    fi;
  end;

  # return empty list if empty matrix list
  if Length(matalg) = 0 then return []; fi;

  field := DefaultField(matalg[1][1]);

  Y   := [];

  decompose( matalg, IdentityMat(Length(matalg[1][1]), field));
  #
  # Y is the change of basis matrix

  if Length(matalg) > 0 then
      mats := Y * matalg / Y;
  fi;
  #
  # mats is now a list of matrices in lower triangular form

  # echelonise them along lower diagonals
  #
  newbase := SMTX_EcheloniseNilpotentMatAlg(mats, field)[1];

  return [newbase, Y];

end);


# module automorphism group
BindGlobal("SMTX_ModuleAutomorphisms",function(m)
  local f, h, hb, hbi, bas, auts, autorder, dim, nb, nbi, r, q, w, Fqr, gl, a, subm, nilbase, homs, i, j, g, k;
  f:=m.field;
  h:=MTX.HomogeneousComponents(m);
  # construct basis for each homogeneous component
  hb:=[];
  for i in h do
    # basis of component
    bas:=ShallowCopy(i.component[1]);
    for j in i.images do
      #Append(bas,LeftQuotient(j.isomorphism,j.component[1]));
      Append(bas,j.isomorphism*j.component[1]);
    od;
    #bas:=MTX.NormedBasisAndBaseChange(bas)[1];
    Add(hb,bas);
  od;

  # each homogeneous component separately
  auts:=[];
  autorder:=1;
  for i in [1..Length(h)] do
    # basis of component
    bas:=hb[i];
    dim:=h[i].component[2].dimension;
    nb:=Concatenation(bas,Concatenation(hb{Difference([1..Length(h)],[i])}));
    nb:=ImmutableMatrix(f,nb);
    nbi:=nb^-1;

    # start by building those automorphisms that fix the homogeneous
    # components - ie, do not involve maps from M_i to M_j unless
    # M_i is the same isomorphism type as M_j
    r:=Length(h[i].indices);
    # first the subgroup GL(multiplicity, residue field)
    q:=SMTX.EndAlgResidue(h[i].component[2]);
    w:=q[1];
    q:=q[2]+1;
    Fqr:=PrimitiveElement(GF(q));
    gl:=GL(r,q);
    autorder:=autorder*Size(gl);
    Info(InfoMtxHom,3,"increase by gl",Size(gl)," ",autorder);
    for g in GeneratorsOfGroup(gl) do
      a:=IdentityMat(m.dimension,f);
      for j in [1..r] do
        for k in [1..r] do
          if IsZero(g[j][k]) then
            subm:=w*0;
          else
            subm:=w^LogFFE(g[j][k],Fqr);
          fi;
          a{[(j-1)*dim+1..j*dim]}{[(k-1)*dim+1..k*dim]}:=subm;
        od;
      od;
      a:=nbi*a*nb;
      Assert(1,ForAll(m.generators,i->i*a=a*i));
      Add(auts,a);
    od;

    # now the subgroup { I + Y | Y in S } where S generates the radical
    # of the endomorphism algebra as a circle group
    nilbase:=SMTX.BasisEndomorphismsRadical(h[i].component[2]);
    if Length(nilbase)>0 then
      nilbase:=SMTX_NilpotentBasis(nilbase);
      nilbase:=nilbase[2]^-1*nilbase[1]*nilbase[2];
    fi;
    a:=(Size(f)^Length(nilbase))^(r^2);
    autorder := autorder * a;
    Info(InfoMtxHom,3,"increase by radical",a," ",autorder);

    for j in nilbase do;
      a:=IdentityMat(m.dimension,f);
      subm:=IdentityMat(dim,f)+j;
      a{[1..dim]}{[1..dim]}:=subm;
      a:=nbi*a*nb;
      Assert(1,ForAll(m.generators,i->i*a=a*i));
      Add(auts,a);
    od;

    # Now the automorphisms that act trivially when restricted to
    # each homogeneous component, but which include action between
    # homogeneous components via elements of Hom(M_i, M_j)
    for j in [1..Length(h)] do
      if i <> j then
        homs:=SMTX.BasisModuleHomomorphisms(h[i].component[2],
                                            h[j].component[2]);
        if Length(homs) > 0 then
          hbi:=0;
          for k in [1..j-1] do
            hbi:=hbi+Length(hb[k]);
          od;
          if i>j then
            hbi:=hbi+Length(hb[i]);
          fi;
          hbi:=hbi+[1..h[j].component[2].dimension];

          a:=(Size(f)^Length(homs))^(r*Length(h[j].indices));
          autorder:=autorder*a;
          Info(InfoMtxHom,3,"increase by mixing ",j,":",a," ",autorder);
          for k in homs do
            a:=IdentityMat(m.dimension,f);
            a{[1..dim]}{hbi}:=k;
            a:=nbi*a*nb;
            Assert(1,ForAll(m.generators,i->i*a=a*i));
            Add(auts,a);
          od;
        fi;
      fi;
    od;
  od;

  if Length(auts)=0 then
    return Group(auts,IdentityMat(m.dimension,f));
  else
    a:=Group(auts);
    Assert(1,Size(a)=autorder);
    SetSize(a,autorder);
    return a;
  fi;

end);

SMTX.ModuleAutomorphisms:=SMTX_ModuleAutomorphisms;

SMTX.SetIsIndecomposable:=function(m,b)
  m.isIndecomposable:=b;
end;

SMTX.HasIsIndecomposable:=function(m)
  return IsBound(m.isIndecomposable);
end;

SMTX.IsIndecomposable:=function(m)
  if not SMTX.HasIsIndecomposable(m) then
    m.isIndecomposable:=Length(SMTX.Indecomposition(m))=1;
  fi;
  return m.isIndecomposable;
end;


SMTX.BasisModuleHomomorphisms:=function(m1,m2)
local b;
  TestModulesFitTogether(m1,m2);
  if m1.dimension>5 then
    b:= SpinHom(m1,m2);
    Assert(1,Length(b)=Length(SmalldimHomomorphismsModules(m1,m2)));
  else
    b:= SmalldimHomomorphismsModules(m1,m2);
  fi;
  Assert(1,ForAll([1..Length(m1.generators)],
           i->ForAll(b,j->m1.generators[i]*j=j*m2.generators[i])));
  return b;
end;

SMTX.BasisModuleEndomorphisms:=function(m)
  if not IsBound(m.basisModuleEndomorphisms) then
    m.basisModuleEndomorphisms:=Immutable(SMTX.BasisModuleHomomorphisms(m,m));
  fi;
  return m.basisModuleEndomorphisms;
end;

SMTX.SetBasisEndomorphismsRadical:=SMTX.Setter("basisEndoRad");
SMTX.BasisEndomorphismsRadical:=SMTX.Getter("basisEndoRad");

SMTX.SetEndAlgResidue:=SMTX.Setter("endAlgResidue");
SMTX.EndAlgResidue:=SMTX.Getter("endAlgResidue");

if IsHPCGAP then
    MakeReadOnlyObj(SMTX);
fi;
