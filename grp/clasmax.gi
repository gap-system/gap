#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke, Colva Roney-Dougal, Derek Holt.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations for the construction of maximal subgroups
##  of classical groups in small dimensions.
##
##  So far it is very rudimentary

# Maximal subgroups of classical groups
# this should become, in the fulness of time, proper code, based on what has
# been written by Colva Roney-Dougal and Derek Holt. At the moment it is a
# simple lookup of data, precomputed with this code, for small degrees/prime
# powers for certain classes of groups

# clasmax.grp holds 3.5 MB of data; read it on first access, not at startup
AUTO( ReadGrp, "clasmax.grp", "CLASMAXDATA" );

BindGlobal("CompresStrMat",function(m,p)
local s,r,sz,i;
  m:=Concatenation(m);
  sz:=0;
  for i in m do
    sz:=sz*p+i;
  od;
  #Print("sz=",sz,"\n");
  # now sz is a number representing m
  s:="";
  for i in Reversed(CoefficientsQadic(sz,80)) do
    Add(s,CHAR_INT(i+42));
  od;
  return s;
end);

BindGlobal("UncompressStrMat",function(s,p)
local m,r,sz,i;
  sz:=0;
  for i in s do
    sz:=sz*80+INT_CHAR(i)-42;
  od;
  #Print("sz=",sz,"\n");
  # now sz is a number representing m
  m:=CoefficientsQadic(sz,p);
  r:=RootInt(Length(m),2);
  if r^2<Length(m) then
    r:=r+1;
    while Length(m)<r^2 do
      Add(m,0);
    od;
  fi;
  m:=Reversed(m);
  return List([1..r],x->m{[(x-1)*r+1..x*r]});
end);


BindGlobal("ClassicalMaximalsLookup",function(type,d,q)
local a,start,f,l,i,j,b,mats,p;
  a:=First(CLASMAXDATA,x->x[1]=type and x[2]=d and x[3]=q);
  if a=fail then
    # not yet listed
    return fail;
  fi;
  if type="L" then
    p:=SL(d,q);
  elif type="D" then
    p:=SO(1,2*d,q);
    p:=DerivedSubgroup(p);
  elif type="2D" then
    p:=SO(-1,2*d,q);
    p:=DerivedSubgroup(p);
  elif type="B" then
    p:=SO(0,2*d+1,q);
    p:=DerivedSubgroup(p);
  elif type="C" then
    p:=SP(2*d,q);
  else
    Error("not yet done");
  fi;
  start:=4; # maybe later other data inserted
  f:=GF(q);
  l:=[];
  for i in [start..Length(a)] do
    mats:=[];
    for j in a[i] do
      b:=UncompressStrMat(j,q);
      b:=b*One(f);
      Add(mats,ImmutableMatrix(f,b));
    od;
    Add(l,SubgroupNC(p,mats));
  od;
  return l;
end);

BindGlobal("ClassicalMaximals",function(type,d,q)
local l,a,gf,conj,r,gp;

  l:=fail;
  # try to use package
  if IsPackageMarkedForLoading("ClassicalMaximals","")=true
    and ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
    if type="L" and d=2 and q>4 then
      l:=CallFuncList(ValueGlobal("ClassicalMaximalsGeneric"),[type,d,q]);
      r:=RootInt(q,2);
      if (IsPrime(q) and q mod 10 in [1,9]) or
        (r^2=q and IsPrime(r) and r mod 10 in [3,7]) then

        # are the SL(2,5) in class S included ? (Depends on package status)
        if not ForAny(l,x->Size(x)=120 and IsPerfectGroup(x)) then
          # An A5, and its GL-conjugate
          gf:=GF(q);
          a:=Filtered(IrreducibleModules(TransitiveGroup(24,201),gf)[2],
            x->x.dimension=2);
          a:=Group(a[1].generators);
          Assert(1,Size(a)=120);
          Add(l,a);
          conj:=[[PrimitiveRoot(gf),0],[0,1]]*One(gf);
          Add(l,a^conj);
        fi;
      fi;
    fi;
  fi;

  # is the data stored?
  if l=fail then
    l:=ClassicalMaximalsLookup(type,d,q);
  fi;

  return l;
end);
