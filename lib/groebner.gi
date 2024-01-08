#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke, David Joyner.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementations for monomial orderings and Groebner
##  bases.

# convenience function to catch cases
BindGlobal("GBasisFixOrderingArgument",function(a)
  if IsFunction(a) then
    a:=a();
  fi;
  return a;
end);

BindGlobal("MakeMonomialOrdering",function(name,ercomp)
local obj;
  obj:=Objectify(NewType(MonomialOrderingsFamily,IsMonomialOrderingDefaultRep),
                 rec());
  SetName(obj,name);
  SetMonomialExtrepComparisonFun(obj,ercomp);
  return obj;
end);

BindGlobal("InstallMonomialOrdering",function(ord,ordfun,idxord,
  # for external interfaces. We use the names as in Singular
  # this might change in future versions
  type
  )
  InstallGlobalFunction(ord,function(arg)
  local idx,nam,ordname,neword,ov;
    if Length(arg)=1 and IsList(arg[1]) then
      idx:=arg[1];
    else
      idx:=arg;
    fi;
    nam:=String(idx);
    if Length(idx)>0 and not IsInt(idx[1]) then
      idx:=List(idx,IndeterminateNumberOfUnivariateRationalFunction);
    fi;
    if Length(idx)>0 then
      ov:=Set(idx);
    else
      ov:=true;
    fi;
    if IsSSortedList(idx) then
      idx:=[];
    fi;
    if IsString(ord) then
      ordname:=ord;
    else
      ordname:=NameFunction(ord);
    fi;
    if Length(idx)>0 then
      # get an indexed ordering

      nam:=Concatenation(ordname,"(",nam,")");
      neword:=MakeMonomialOrdering(nam,
        function(a,b)
          # for each variable give its index position.
          return idxord(a,b,List([1..Maximum(idx)],i->Position(idx,i)));
        end);
      neword!.idxarrangement:=Immutable(idx);
      neword!.type:=Immutable(type);
      SetOccuringVariableIndices(neword,ov);
      return neword;
    else
      nam:=Concatenation(ordname,"()");
      neword:=MakeMonomialOrdering(nam,ordfun);
      neword!.idxarrangement:=Immutable(idx);
      neword!.type:=Immutable(type);
      SetOccuringVariableIndices(neword,ov);
      return neword;
    fi;
  end);
end);

InstallMethod(MonomialComparisonFunction,"default: use extrep",true,
  [IsMonomialOrderingDefaultRep],0,
function(ord)
local fun;
  fun:=MonomialExtrepComparisonFun(ord);
  return function(a,b)
  local e, f, le, lf,fam;
    fam:=FamilyObj(a);
    e:=ExtRepPolynomialRatFun(a);
    f:=ExtRepPolynomialRatFun(b);
    repeat
      if Length(e)=0 and Length(f)>0 then return true;
      elif Length(f)=0 then return false;
      fi;
      if Length(e)=2 then
        le:=1;
      else
        le:=LeadingMonomialPosExtRep(fam,e,fun);
      fi;
      if Length(f)=2 then
        lf:=1;
      else
        lf:=LeadingMonomialPosExtRep(fam,f,fun);
      fi;
      if fun(e[le],f[lf]) then
        return true;
      elif e[le]<>f[lf] then
        return false;
      fi;
      e:=e{Concatenation([1..le-1],[le+2..Length(e)])};
      f:=f{Concatenation([1..lf-1],[lf+2..Length(f)])};
    until false;
  end;
end);

#############################################################################
##
#F  MonomialLexOrdering()
#F  MonomialLexOrdering(<vari>)
##
##  This function creates a lexicographic ordering for monomials. If <vari>
##  is given and is a list of variables or variable indices, this is used as
##  the underlying order of variables.
InstallMonomialOrdering(MonomialLexOrdering,
  #ordinary case
  function(a,b)
  local l,m,i;
    l:=Length(a);
    m:=Length(b);
    i:=1;
    while i<l and i<m do
    # in this ordering x_1>x_2
      if a[i]>b[i] then
        return true;
      elif a[i]<b[i] then
        return false;
      elif a[i+1]<b[i+1] then
        return true;
      elif a[i+1]>b[i+1] then
        return false;
      fi;
      i:=i+2;
    od;
    if i<m then
      return true;
    fi;
    # bigger or equal
    return false;
  end,
  # indexed case
  function(a,b,idx)
  local l, m, min, i, am, ap, ai, has, bi,ret;
    l:=Length(a);
    m:=Length(b);

    # as variables are not necessarily stored in the right order, we'll have
    # to run through by variables one by one, The biggest index variables
    # first
    min:=0;

    repeat
      # get the smallest position (i.e. largest) remaining variable in a
      i:=1;
      am:=infinity;
      ap:=0;
      while i<l do
        ai:=idx[a[i]];
        if ai>min and ai<am then
          # smaller pos (i.e. larger) variable found
          am:=ai;
          ap:=i;
        fi;
        i:=i+2;
      od;
      if am=infinity then
        # no variable left in a. Test what is left in b
        i:=1;
        has:=false;
        while i<m do
          bi:=idx[b[i]];
          if bi>min then
            # b has variables left. So a is smaller
            return true;
          fi;
          i:=i+2;
        od;
        # b also not. thus a must be equal to b
        return false;
      fi;

      # now search for am in b
      i:=1;
      has:=false;
      while i<m do
        bi:=idx[b[i]];
        if bi>min then
          if bi<am then
            # b has a larger (smaller pos) variable left. Thus b is bigger.
            return true;
          elif bi=am then
            # the same variable occurs.
            has:=true;
            if a[ap+1]>b[i+1] then

              # a exponent is bigger
              ret:=false; # unless a smaller (larger pos) variable found
            elif a[ap+1]<b[i+1] then
              # b exponent is bigger
              ret:=true; # unless a smaller (larger pos) variable found
            else
              # same exponents -- cannot decide on this variable
              ret:=fail;
            fi;
          fi;
        fi;
        i:=i+2;
      od;
      if not has then
        # b has no variable as large as am. thus a is bigger
        return false;
      elif ret<>fail then
        # b has no larger variable than am  buty has am. Use the comparison
        return ret;
      fi;
      min:=am; # will increase until no variable in a left
    until false;
  end,
  MakeImmutable("lp"));

#############################################################################
##
#F  MonomialGrlexOrdering()
#F  MonomialGrlexOrdering(<vari>)
##
##  This function creates a degree/lexicographic ordering for monomials. If
##  <vari> is given and is a list of variables or variable indices, this is
##  used as the underlying order of variables.
InstallMonomialOrdering(MonomialGrlexOrdering,
  function(a,b)
  local s,t,i,l,m;
    s:=0;
    l:=Length(a);
    m:=Length(b);
    for i in [2,4..l] do
      s:=s+a[i];
    od;
    t:=0;
    for i in [2,4..m] do
      t:=t+b[i];
    od;
    if s<t then
      return true;
    elif s>t then
      return false;
    fi;

    # Lex
    i:=1;
    while i<l and i<m do
    # in this ordering x_1>x_2
      if a[i]>b[i] then
        return true;
      elif a[i]<b[i] then
        return false;
      elif a[i+1]<b[i+1] then
        return true;
      elif a[i+1]>b[i+1] then
        return false;
      fi;
      i:=i+2;
    od;
    if i<m then
      return true;
    fi;
    # bigger or equal
    return false;
  end,

  # indexed case
  function(a,b,idx)
  local s, l, m, t, min, i, am, ap, ai, has, bi, ret;
    s:=0;
    l:=Length(a);
    m:=Length(b);
    for i in [2,4..l] do
      s:=s+a[i];
    od;
    t:=0;
    for i in [2,4..m] do
      t:=t+b[i];
    od;
    if s<t then
      return true;
    elif s>t then
      return false;
    fi;

    # Lex


    # as variables are not necessarily stored in the right order, we'll have
    # to run through by variables one by one, The biggest index variables
    # first
    min:=0;

    repeat
      # get the smallest position (i.e. largest) remaining variable in a
      i:=1;
      am:=infinity;
      ap:=0;
      while i<l do
        ai:=idx[a[i]];
        if ai>min and ai<am then
          # smaller pos (i.e. larger) variable found
          am:=ai;
          ap:=i;
        fi;
        i:=i+2;
      od;
      if am=infinity then
        # no variable left in a. Test what is left in b
        i:=1;
        has:=false;
        while i<m do
          bi:=idx[b[i]];
          if bi>min then
            # b has variables left. So a is smaller
            return true;
          fi;
          i:=i+2;
        od;
        # b also not. thus a must be equal to b
        return false;
      fi;

      # now search for am in b
      i:=1;
      has:=false;
      while i<m do
        bi:=idx[b[i]];
        if bi>min then
          if bi<am then
            # b has a larger (smaller pos) variable left. Thus b is bigger.
            return true;
          elif bi=am then
            # the same variable occurs.
            has:=true;
            if a[ap+1]>b[i+1] then

              # a exponent is bigger
              ret:=false; # unless a smaller (larger pos) variable found
            elif a[ap+1]<b[i+1] then
              # b exponent is bigger
              ret:=true; # unless a smaller (larger pos) variable found
            else
              # same exponents -- cannot decide on this variable
              ret:=fail;
            fi;
          fi;
        fi;
        i:=i+2;
      od;
      if not has then
        # b has no variable as large as am. thus a is bigger
        return false;
      elif ret<>fail then
        # b has no larger variable than am  buty has am. Use the comparison
        return ret;
      fi;
      min:=am; # will increase until no variable in a left
    until false;
  end,
  MakeImmutable("Dp"));

#############################################################################
##
#F  MonomialGrevlexOrdering()
#F  MonomialGrevlexOrdering(<vari>)
##
##  This function creates a degree/reverse lexicographic ordering for
##  monomials. If <vari> is given and is a list of variables or variable
##  indices, this is used as the underlying order of variables.
InstallMonomialOrdering(MonomialGrevlexOrdering,
  #ordinary
  function(a,b)
  local s,t,i,j,l,m;
    s:=0;
    l:=Length(a);
    m:=Length(b);
    for i in [2,4..l] do
      s:=s+a[i];
    od;
    t:=0;
    for i in [2,4..m] do
      t:=t+b[i];
    od;
    if s<t then
      return true;
    elif s>t then
      return false;
    fi;
    # Revlex
    i:=l-1;
    j:=m-1;
    while i>0 and j>0 do
    # in this ordering x_1>x_2
      if a[i]>b[j] then
        # case x/0 -- a not bigger
        return true;
      elif a[i]<b[j] then
        # case 0/x  a bigger
        return false;
      elif a[i+1]<b[j+1] then
        # a-b is negative
        return false;
      elif a[i+1]>b[j+1] then
        # a-b is positive
        return true;
      fi;
      i:=i-2;
      j:=j-2;
    od;
    if i>0 then
      #a-part left
      return true;
    fi;
    # bigger or equal
    return false;
  end,
  # indexed case
  function(a,b,idx)
    Error("indexed grevlex not yet implemented");
  end,
  MakeImmutable("dp"));

#############################################################################
##
#F  EliminationOrdering(<elim>)
#F  EliminationOrdering(<elim>,<rest>)
##
##  This function creates an elimination ordering for eliminating the
##  variables in <elim>. Two monomials are compared first by the exponent
##  vectors for the variables listed in <elim> (a lexicographic comparison
##  with respect to the ordering indicated in <elim>).
##  If these submonomial are equal, the submonomials given by the other
##  variables are compared by a graded lexicographic ordering (with respect
##  to the variable order given in <rest>, if called with two parameters).
##
##  Both <elim> and <rest> may be a list of variables of a list of variable
##  indices.
InstallGlobalFunction(EliminationOrdering,function(arg)
local elimvar, nam, ord1, othvar, ord2,ov,neword;
  elimvar:=arg[1];
  nam:=ShallowCopy(String(elimvar));
  if not IsInt(elimvar[1]) then
    elimvar:=List(elimvar,IndeterminateNumberOfUnivariateRationalFunction);
  fi;
  ov:=Set(elimvar);
  ord1:=MonomialExtrepComparisonFun(MonomialLexOrdering(elimvar));
  if Length(arg)>1 then
    othvar:=arg[2];
    Add(nam,',');
    nam:=Concatenation(nam,String(othvar));
    if not IsInt(othvar[1]) then
      othvar:=List(othvar,IndeterminateNumberOfUnivariateRationalFunction);
    fi;
    ov:=Union(ov,othvar);
    ord2:=MonomialExtrepComparisonFun(MonomialGrlexOrdering(othvar));
  else
    ov:=true;
    ord2:=MonomialExtrepComparisonFun(MonomialGrlexOrdering());
  fi;

  neword:=MakeMonomialOrdering(
    Concatenation("EliminationOrdering(",nam,")"),
    function(a,b)
    local la, lb, asel, bsel, ah, bh, i;
      la:=Length(a);
      lb:=Length(b);
      asel:=[];
      for i in [1,3..la-1] do
        if a[i] in elimvar then
          Add(asel,i);
          Add(asel,i+1);
        fi;
      od;
      bsel:=[];
      for i in [1,3..lb-1] do
        if b[i] in elimvar then
          Add(bsel,i);
          Add(bsel,i+1);
        fi;
      od;
      ah:=a{asel};
      bh:=b{bsel};
      if ah=bh then
        ah:=a{Difference([1..la],asel)};
        bh:=b{Difference([1..lb],bsel)};
        return ord2(ah,bh);
      else
        return ord1(ah,bh);
      fi;
    end);
  SetOccuringVariableIndices(neword,ov);
  return neword;
end);

InstallMethod(MonomialExtrepComparisonFun,
  "functions are themselves -- for compatibility",true,[IsFunction],0,f->f);

InstallOtherMethod(OccuringVariableIndices,"polynomial",true,
  [IsPolynomial],0,
function(p)
local ov, l, i, j;
  p:=ExtRepPolynomialRatFun(p);
  ov:=[];
  for i in [1,3..Length(p)-1] do
    l:=p[i];
    for j in [1,3..Length(l)-1] do
      AddSet(ov,l[j]);
    od;
  od;
  return ov;
end);

InstallMethod(LeadingTermOfPolynomial,"with ordering",true,
  [IsPolynomialFunction,IsMonomialOrdering],0,
function(p,order)
local e,fam,a;
  order:=MonomialExtrepComparisonFun(order);
  e:=ExtRepPolynomialRatFun(p);
  fam:=FamilyObj(p);
  a:=LeadingMonomialPosExtRep(fam,e,order);
  return PolynomialByExtRepNC(fam,e{[a,a+1]});
end);

InstallOtherMethod(LeadingMonomialOfPolynomial,"with ordering",true,
  [IsPolynomialFunction,IsMonomialOrdering],0,
function(p,order)
local e,fam,a;
  if not IsPolynomial(p) then
    TryNextMethod();
  fi;
  order:=MonomialExtrepComparisonFun(order);
  e:=ExtRepPolynomialRatFun(p);
  fam:=FamilyObj(p);
  a:=LeadingMonomialPosExtRep(fam,e,order);
  return PolynomialByExtRepNC(fam,[e[a],One(CoefficientsFamily(fam))]);
end);

InstallOtherMethod(LeadingCoefficientOfPolynomial,"with ordering",true,
  [IsPolynomialFunction,IsMonomialOrdering],0,
function(p,order)
local e,fam,a;
  if not IsPolynomial(p) then
    TryNextMethod();
  fi;
  order:=MonomialExtrepComparisonFun(order);
  e:=ExtRepPolynomialRatFun(p);
  fam:=FamilyObj(p);
  a:=LeadingMonomialPosExtRep(fam,e,order);
  return e[a+1];
end);

# compute S-polynomial and return `0' if the leading monomials are coprime
BindGlobal("SPolynomial",function(p,q,order)
local a,b,c,d,e,f,i,j,ae,be,di,fam;
  order:=MonomialExtrepComparisonFun(order);
  e:=ExtRepPolynomialRatFun(p);
  f:=ExtRepPolynomialRatFun(q);
  fam:=FamilyObj(p);
  a:=LeadingMonomialPosExtRep(fam,e,order);
  b:=LeadingMonomialPosExtRep(fam,f,order);
  ae:=e[a];
  be:=f[b];

  # compute the cofactors
  i:=1;
  j:=1;
  c:=[];
  d:=[];
  while i<Length(ae) and j<Length(be) do
    if ae[i]<be[j] then
      # a has variable not in b
      Append(d,ae{[i,i+1]});
      i:=i+2;
    elif ae[i]>be[j] then
      # b has variable not in a
      Append(c,be{[j,j+1]});
      j:=j+2;
    else
      # variable in both: One larger?
      di:=be[j+1]-ae[i+1];
      if di>0 then
        Append(c,[ae[i],di]);
      elif di<0 then
        Append(d,[be[j],-di]);
      fi;
      i:=i+2;
      j:=j+2;
    fi;
  od;

  # trailing entries
  if i<Length(ae) then
    Append(d,ae{[i..Length(ae)]});
  elif j<Length(be) then
    Append(c,be{[j..Length(be)]});
  fi;
  return PolynomialByExtRepNC(fam,[c,f[b+1]])*p
         -PolynomialByExtRepNC(fam,[d,e[a+1]])*q;
end);

#############################################################################
##
#F  PolynomialReduction(poly,plist,order)     reduces poly with the ideal
##                                 generated by plist, according to order
##  The routine returns a list [remainder,[quotients]]
##
InstallGlobalFunction( PolynomialReduction, function(poly,plist,order)
local fam,quot,elist,lmp,lmo,lmc,x,y,z,mon,mon2,qmon,noreduce,
      ep,pos,di,rem,qmex;
  if IsMonomialOrdering(order) then
    order:=MonomialExtrepComparisonFun(order);
  fi;
  fam:=FamilyObj(poly);
  quot:=List(plist,i->Zero(poly));
  elist:=List(plist,ExtRepPolynomialRatFun);
  lmp:=List(elist,i->LeadingMonomialPosExtRep(fam,i,order));
  lmo:=List([1..Length(lmp)],i->elist[i][lmp[i]]);
  lmc:=List([1..Length(lmp)],i->elist[i][lmp[i]+1]);

  ep:=ExtRepPolynomialRatFun(poly);
  rem:=Zero(poly);
  while Length(ep)>0 do
    # now try whether we can reduce at x

    noreduce:=true;
    x:=LeadingMonomialPosExtRep(fam,ep,order);
    mon:=ep[x];
    y:=1;
    while y<=Length(plist) and noreduce do
      mon2:=lmo[y];
      #check whether the monomial at position x is a multiple of the
      #y-th leading monomial
      z:=1;
      pos:=1;
      qmon:=[]; # potential quotient
      noreduce:=false;
      while noreduce=false and z<=Length(mon2) and pos<=Length(mon) do
        if mon[pos]>mon2[z] then
          noreduce:=true; # indet in mon2 does not occur in mon -> does not
                          # divide
        elif mon[pos]<mon2[z] then
          Append(qmon,mon{[pos,pos+1]}); # indet only in mon
          pos:=pos+2;
        else
          # the indets are the same
          di:=mon[pos+1]-mon2[z+1];
          if di>0 then
            #divides and there is remainder
            Append(qmon,[mon[pos],di]);
          elif di<0 then
            noreduce:=true; # exponent to small
          fi;
          pos:=pos+2;
          z:=z+2;
        fi;
      od;

      # if there is a tail in mon2 left, cannot divide
      if z<=Length(mon2) then
        noreduce:=true;
      fi;
      y:=y+1;
    od;
    if noreduce then
      mon:=PolynomialByExtRepNC(fam,[ep[x],ep[x+1]]);
      rem:=rem+mon;
  #Print("noreduce:",PolynomialByExtRepNC(fam,ep)," ",mon," ",rem,"\n");
      ep:=ep{Difference([1..Length(ep)],[x,x+1])};
  #Print(ep,"\n");
    else
      y:=y-1; # re-correct incremented numbers

      # is there a tail in mon? if yes we need to append it
      if pos<Length(mon) then
        Append(qmon,mon{[pos..Length(mon)]});
      fi;

      # reduce!
      qmex:=[qmon,-ep[x+1]/lmc[y]];

      qmon:=PolynomialByExtRepNC(fam,[qmon,ep[x+1]/lmc[y]]); #quotient monomial
      quot[y]:=quot[y]+qmon;

      qmex:=ZippedProduct(qmex,elist[y],
             fam!.zeroCoefficient,fam!.zippedProduct);
      qmex:=ZippedSum(ep,qmex,fam!.zeroCoefficient,fam!.zippedSum);

      #poly:=PolynomialByExtRep(fam,ep);
      #poly:=poly-qmon*plist[y]; # reduce
      #ep:=ExtRepPolynomialRatFun(poly);
      #if ep<>qmex then Error("RED!"); fi;
      ep:=qmex;

    fi;
  od;
  return [rem,quot];
end);




#############################################################################
##
#F  PolynomialReducedRemainder(poly,plist,order)
##
InstallGlobalFunction(PolynomialReducedRemainder,function(poly,plist,order)
local fam, elist, lmp, lmo, lmc, ep, rem, noreduce, x, mon, y, mon2,
  z, pos, qmon, di,qmex;
  if IsMonomialOrdering(order) then
    order:=MonomialExtrepComparisonFun(order);
  fi;
  fam:=FamilyObj(poly);
  elist:=List(plist,ExtRepPolynomialRatFun);
  lmp:=List(elist,i->LeadingMonomialPosExtRep(fam,i,order));
  lmo:=List([1..Length(lmp)],i->elist[i][lmp[i]]);
  lmc:=List([1..Length(lmp)],i->elist[i][lmp[i]+1]);

  ep:=ExtRepPolynomialRatFun(poly);
  rem:=Zero(poly);
  while Length(ep)>0 do
    # now try whether we can reduce at x

    noreduce:=true;
    x:=LeadingMonomialPosExtRep(fam,ep,order);
    mon:=ep[x];
    y:=1;
    while y<=Length(plist) and noreduce do
      mon2:=lmo[y];
      #check whether the monomial at position x is a multiple of the
      #y-th leading monomial
      z:=1;
      pos:=1;
      qmon:=[]; # potential quotient
      noreduce:=false;
      while noreduce=false and z<=Length(mon2) and pos<=Length(mon) do
        if mon[pos]>mon2[z] then
          noreduce:=true; # indet in mon2 does not occur in mon -> does not
                          # divide
        elif mon[pos]<mon2[z] then
          Append(qmon,mon{[pos,pos+1]}); # indet only in mon
          pos:=pos+2;
        else
          # the indets are the same
          di:=mon[pos+1]-mon2[z+1];
          if di>0 then
            #divides and there is remainder
            Append(qmon,[mon[pos],di]);
          elif di<0 then
            noreduce:=true; # exponent to small
          fi;
          pos:=pos+2;
          z:=z+2;
        fi;
      od;

      # if there is a tail in mon2 left, cannot divide
      if z<=Length(mon2) then
        noreduce:=true;
      fi;
      y:=y+1;
    od;
    if noreduce then
      mon:=PolynomialByExtRepNC(fam,[ep[x],ep[x+1]]);
      rem:=rem+mon;
      ep:=ep{Difference([1..Length(ep)],[x,x+1])};
    else
      y:=y-1; # re-correct incremented numbers

      # is there a tail in mon? if yes we need to append it
      if pos<Length(mon) then
        Append(qmon,mon{[pos..Length(mon)]});
      fi;

      # reduce!
      qmex:=[qmon,-ep[x+1]/lmc[y]];
      qmex:=ZippedProduct(qmex,elist[y],
             fam!.zeroCoefficient,fam!.zippedProduct);
      qmex:=ZippedSum(ep,qmex,fam!.zeroCoefficient,fam!.zippedSum);

      #qmon:=PolynomialByExtRepNC(fam,[qmon,ep[x+1]/lmc[y]]); #quotient monomial
      #poly:=PolynomialByExtRep(fam,ep);
      #poly:=poly-qmon*plist[y]; # reduce
      #ep:=ExtRepPolynomialRatFun(poly);
      #if ep<>qmex then Error("RED0!"); fi;
      ep:=qmex;
    fi;
  od;
  return rem;
end);

#############################################################################
##
#F  PolynomialDivisionAlgorithm(poly,plist,order)
##
InstallGlobalFunction(PolynomialDivisionAlgorithm,function(poly,plist,order)
local fam,quot,elist,lmp,lmo,lmc,x,y,z,mon,mon2,qmon,noreduce,
      ep,pos,di,rem;
  if IsMonomialOrdering(order) then
    order:=MonomialExtrepComparisonFun(order);
  fi;
  fam:=FamilyObj(poly);
  quot:=List(plist,i->Zero(poly));
  elist:=List(plist,ExtRepPolynomialRatFun);
  lmp:=List(elist,i->LeadingMonomialPosExtRep(fam,i,order));
  lmo:=List([1..Length(lmp)],i->elist[i][lmp[i]]);
  lmc:=List([1..Length(lmp)],i->elist[i][lmp[i]+1]);

  rem:=Zero(poly);
  ep:=ExtRepPolynomialRatFun(poly);
  while Length(ep)>0 do
    # now try whether we can reduce the leading monomial
    x:=LeadingMonomialPosExtRep(fam,ep,order);
    mon:=ep[x];
    y:=1;
    noreduce:=true;
    while y<=Length(plist) and noreduce do
      mon2:=lmo[y];
      #check whether the monomial at position x (leading mon of poly)
      #is a multiple of the y-th leading monomial
      z:=1;
      pos:=1;
      qmon:=[]; # potential quotient
      noreduce:=false;
      while noreduce=false and z<=Length(mon2) and pos<=Length(mon) do
        if mon[pos]>mon2[z] then
          noreduce:=true; # indet in mon2 does not occur in mon -> does not
                          # divide
        elif mon[pos]<mon2[z] then
          Append(qmon,mon{[pos,pos+1]}); # indet only in mon
          pos:=pos+2;
        else
          # the indets are the same
          di:=mon[pos+1]-mon2[z+1];
          if di>0 then
            #divides and there is remainder
            Append(qmon,[mon[pos],di]);
          elif di<0 then
            noreduce:=true; # exponent to small
          fi;
          pos:=pos+2;
          z:=z+2;
        fi;
      od;

      # if there is a tail in mon2 left, cannot divide
      if z<=Length(mon2) then
        noreduce:=true;
      fi;
      y:=y+1;
    od;

    if noreduce=false then
      y:=y-1; # re-correct incremented numbers

      # is there a tail in mon? if yes we need to append it
      if pos<Length(mon) then
        Append(qmon,mon{[pos..Length(mon)]});
      fi;

      # reduce!
      qmon:=PolynomialByExtRepNC(fam,[qmon,ep[x+1]/lmc[y]]); #quotient monomial

      quot[y]:=quot[y]+qmon;
      poly:=poly-qmon*plist[y]; # reduce
    else
      # remove leading monomial
      qmon:=PolynomialByExtRepNC(fam,[mon,ep[x+1]]);
      rem:=rem+qmon;
      poly:=poly-qmon;
    fi;
    ep:=ExtRepPolynomialRatFun(poly);
  od;
  return [rem,quot];
end);

BindGlobal("SyzygyCriterion",function(baslte,i,j,t,B)
local li, lj, lcm, a, b, k;
  lcm:=false;
  for k in [1..t] do
    if k<>i and k<>j and
      (not Set([i,k]) in B) and (not Set([j,k]) in B) then

        if lcm=false then
          li:=baslte[i];
          lj:=baslte[j];
          lcm:=[];
          a:=1;
          b:=1;
          while a<Length(li) and b<Length(lj) do
            if li[a]<lj[b] then
              # li variable is smaller
              Add(lcm,li[a]);
              Add(lcm,li[a+1]);
              a:=a+2;
            elif li[a]>lj[b] then
              # lj-variable is smaller
              Add(lcm,lj[b]);
              Add(lcm,lj[b+1]);
              b:=b+2;
            else
              # same variable
              Add(lcm,li[a]);
              Add(lcm,Maximum(li[a+1],lj[b+1]));
              a:=a+2;
              b:=b+2;
            fi;
          od;
          # add remaining tails. Only one of these loops is run
          while a<Length(li) do
            Add(lcm,li[a]);
            Add(lcm,li[a+1]);
            a:=a+2;
          od;
          while b<Length(lj) do
            Add(lcm,lj[b]);
            Add(lcm,lj[b+1]);
            b:=b+2;
          od;
        fi;

        # does baslte[k] divide?
        li:=baslte[k];
        a:=1;
        b:=1;
        while a<Length(li) and b<Length(lcm) do
          # lcm has extra variables?
          while b<Length(lcm) and li[a]>lcm[b] do
            b:=b+2;
          od;
          # test whether variable OK and variable power not bigger
          if b<Length(lcm) then
            if li[a]=lcm[b] and li[a+1]<=lcm[b+1] then
              a:=a+2;
              b:=b+2;
            else
              # either a has an extra (smaller) variable or a bigger
              # exponent. In both cases division fails which we indicate by
              # only b running out
              b:=Length(lcm)+1;
            fi;
          fi;
        od;
        # if b has variables left or a and b both ran out, we're fine
        if b<Length(lcm) or (b>Length(lcm) and a>Length(li)) then
          return true;
        fi;
    fi;
  od;
  return false;
end);

BindGlobal("GAPGBASIS",MakeImmutable(rec(
  name:="naive GAP version of Buchberger's algorithm",
  GroebnerBasis:=function(elms,order)
  local orderext, bas, baslte, fam, t, B, i, j, s;
    orderext:=MonomialExtrepComparisonFun(order);
    bas:=Filtered(elms,x->not IsZero(x));
    baslte:=List(bas,ExtRepPolynomialRatFun);
    fam:=FamilyObj(bas[1]);
    baslte:=List(baslte,i->i[LeadingMonomialPosExtRep(fam,i,orderext)]);
    t:=Length(bas);
    B:=Concatenation(List([1..t],i->List([1..i-1],j->[j,i])));
    while Length(B)>0 do
      j:=B[1][1];
      i:=B[1][2];
      # remove first entry of B
      Remove(B, 1);

      if Length(Intersection(baslte[i]{[1,3..Length(baslte[i])-1]},
                            baslte[j]{[1,3..Length(baslte[j])-1]}))=0 then
        Info(InfoGroebner,2,"Pair (",i,",",j,") avoided by product criterion");
      elif SyzygyCriterion(baslte,i,j,t,B) then
        Info(InfoGroebner,2,"Pair (",i,",",j,") avoided by chain criterion");
      else
        s:=SPolynomial(bas[i],bas[j],order);
        if InfoLevel(InfoGroebner)<3 then
          Info(InfoGroebner,2,"Spol(",i,",",j,")");
        else
          Info(InfoGroebner,3,"Spol(",i,",",j,")=",s);
        fi;
        s:=PolynomialReducedRemainder(s,bas,orderext);
        if not IsZero(s) then
          Info(InfoGroebner,3,"reduces to ",s);
          Add(bas,s);
          s:=ExtRepPolynomialRatFun(s);
          Add(baslte,s[LeadingMonomialPosExtRep(fam,s,orderext)]);
          t:=t+1;
          # add new pairs
          for i in [1..t-1] do
            Add(B,[i,t]);
          od;
          Info(InfoGroebner,1,"|bas|=",t,", ",Length(B)," pairs left");
        fi;
      fi;
    od;
    return bas;
  end)
  ));

#############################################################################
##
#V  GBASIS
##
##  This variable is assigned to a record which determines which
##  implementation is used to compute Groebner bases. By default it is
##  assigned to `GAPGBASIS', a naive implementation of Buchberger's
##  algorithm, which is only provided for educational purposes. For serious
##  work a better implementation should be used.
GBASIS:=GAPGBASIS;

InstallGlobalFunction(GroebnerBasisNC,
function(elms,order)
  return GBASIS.GroebnerBasis(elms,order);
end);

InstallMethod(GroebnerBasis,"polynomials",true,
  [IsHomogeneousList and IsRationalFunctionCollection,IsMonomialOrdering],0,
function(elms,order)
local ov,i,d;
  # do some tests
  if not ForAll(elms,IsPolynomial) then
    Error("<elms> must be a list of polynomials");
  fi;
  ov:=OccuringVariableIndices(order);
  if ov<>true then
    for i in elms do
      d:=Difference(OccuringVariableIndices(i),ov);
      if Length(d)>0 then
        Error("Ordering is undefined for variables ",
          List(d,j->Indeterminate(DefaultRing([FamilyObj(i)!.zeroCoefficient]),j)));
      fi;
    od;
  fi;
  return GroebnerBasisNC(elms,order);
end);

InstallOtherMethod(GroebnerBasis,"fix function",true,
  [IsObject,IsFunction],0,
function(obj,f)
  if f=MonomialLexOrdering or f=MonomialGrlexOrdering or
    f=MonomialGrevlexOrdering then
    return GroebnerBasis(obj,f());
  fi;
  TryNextMethod();
end);

InstallMethod(StoredGroebnerBasis,"ideal",true,
  [IsPolynomialRingIdeal],0,function(I)
local ord;
  ord:=MonomialGrlexOrdering();
  return [ReducedGroebnerBasis(GeneratorsOfTwoSidedIdeal(I),ord),ord];
end);

InstallMethod(GroebnerBasis,"ideal",true,
  [IsPolynomialRingIdeal,IsMonomialOrdering],0,
function(I,order)
local bas;
  if HasStoredGroebnerBasis(I) then
    bas:=StoredGroebnerBasis(I);
    if IsIdenticalObj(bas[2],order) then return bas[1];fi;
  fi;
  # do some tests
  bas:=ReducedGroebnerBasis(GeneratorsOfIdeal(I),order);
  if not HasStoredGroebnerBasis(I) then
    SetStoredGroebnerBasis(I,[bas,order]);
  fi;
  return bas;
end);

InstallMethod(GroebnerBasis,"ideal with stored GB",true,
  [IsPolynomialRingIdeal and HasStoredGroebnerBasis,IsMonomialOrdering],0,
function(I,order)
  # do some tests
  if not IsIdenticalObj(StoredGroebnerBasis(I)[2],order) then
    TryNextMethod();
  fi;
  return StoredGroebnerBasis(I)[1];
end);

InstallMethod(ReducedGroebnerBasis,"polynomials",true,
  [IsHomogeneousList and IsRationalFunctionCollection,IsMonomialOrdering],0,
function(elms,order)
local orderext, bas, i, l, nomod, pol;
  orderext:=MonomialExtrepComparisonFun(order);
  # do some tests
  bas:=ShallowCopy(GBASIS.GroebnerBasis(elms,order));
  i:=1;
  l:=Length(bas);
  repeat
    nomod:=true;
    while i<=l do
      pol:=PolynomialReducedRemainder(bas[i],
             bas{Difference([1..l],[i])},orderext);
      if pol<>bas[i] then nomod:=false;fi;
      if IsZero(pol) then
        bas[i]:=bas[l];
        Unbind(bas[l]);
        l:=l-1;
      else
        bas[i]:=pol;
        i:=i+1;
      fi;
    od;
  until nomod;
  for i in [1..Length(bas)] do
     bas[i]:=bas[i]/LeadingCoefficientOfPolynomial(bas[i],order);
  od;
  Sort(bas,MonomialComparisonFunction(order));
  return bas;
end);

InstallMethod(ReducedGroebnerBasis,"ideal",true,
  [IsPolynomialRingIdeal,IsMonomialOrdering],0,
function(I,order)
local bas;
  # do some tests
  if HasStoredGroebnerBasis(I)
    and IsIdenticalObj(StoredGroebnerBasis(I)[2],order) then
    bas:=StoredGroebnerBasis(I)[1];
  else
    bas:=GeneratorsOfIdeal(I);
  fi;
  # reduce
  bas:=ReducedGroebnerBasis(bas,order);
  if not HasStoredGroebnerBasis(I) then
    SetStoredGroebnerBasis(I,[bas,order]);
  fi;
  return bas;
end);

InstallOtherMethod(ReducedGroebnerBasis,"fix function",true,
  [IsObject,IsFunction],0,
function(obj,f)
  if f=MonomialLexOrdering or f=MonomialGrlexOrdering or
    f=MonomialGrevlexOrdering then
    return ReducedGroebnerBasis(obj,f());
  fi;
  TryNextMethod();
end);

InstallMethod(\in,"polynomial ideal",true,
  [IsPolynomial,IsPolynomialRingIdeal],0,function(p,I)
local g;
  g:=StoredGroebnerBasis(I);
  p:=PolynomialReducedRemainder(p,g[1],MonomialExtrepComparisonFun(g[2]));
  return IsZero(p);
end);

# We only provide a single GcdOp method (taking three arguments) for the
# general case, and no specialized two argument version, which we usually
# provide to avoid costly construction of the polynomial ring object, simply
# because in this case the cost of Gcd computation dwarfs the cost for
# creating the polynomial ring.
InstallOtherMethod(GcdOp,"multivariate Gcd based on Groebner bases",
  IsCollsElmsElms,[IsPolynomialRing,IsPolynomial,IsPolynomial],0,
# Input: f, g are multivariate polys in R=F[x1,...,xn]
# Output: a gcd of f,g in R
function(R,f,g)
local basis_elt,t,F,vars,vars2,GB,coeff_t;
  F:=CoefficientsRing(R);
  vars:=IndeterminatesOfPolynomialRing(R);
  t:=Indeterminate(F,vars);
  vars2:=Concatenation([t],vars);
  GB:=ReducedGroebnerBasis([t*f,(1-t)*g],MonomialLexOrdering(vars2));
  for basis_elt in GB do
    coeff_t:=PolynomialCoefficientsOfPolynomial(basis_elt,t);
    if Length(coeff_t)=1 then
      return StandardAssociate(f*g/coeff_t[1]);
    fi;
  od;
  return One(F);
end);

InstallOtherMethod(LcmOp,"multivariate Lcm based on Groebner bases",
  IsCollsElmsElms,[IsPolynomialRing,IsPolynomial,IsPolynomial],0,
function(R,f,g)
  return f*g/GcdOp(R,f,g);
end);

BindGlobal("NaiveBuchberger",function(elms,order)
local orderext, bas, baslte, fam, t, B, i, j, s;
  orderext:=MonomialExtrepComparisonFun(order);
  bas:=ShallowCopy(elms);
  baslte:=List(bas,ExtRepPolynomialRatFun);
  fam:=FamilyObj(bas[1]);
  baslte:=List(baslte,i->i[LeadingMonomialPosExtRep(fam,i,orderext)]);
  t:=Length(bas);
  B:=Concatenation(List([1..t],i->List([1..i-1],j->[j,i])));
  while Length(B)>0 do
    i:=B[1]; # take one
    j:=i[1];
    i:=i[2];
      s:=SPolynomial(bas[i],bas[j],order);
      if InfoLevel(InfoGroebner)<3 then
        Info(InfoGroebner,2,"Spol(",i,",",j,")");
      else
        Info(InfoGroebner,3,"Spol(",i,",",j,")=",s);
      fi;
      s:=PolynomialReducedRemainder(s,bas,orderext);
      if not IsZero(s) then
        Info(InfoGroebner,3,"reduces to ",s);
        Add(bas,s);
        s:=ExtRepPolynomialRatFun(s);
        Add(baslte,s[LeadingMonomialPosExtRep(fam,s,orderext)]);
        t:=t+1;
        # add new pairs
        for i in [1..t] do
          Add(B,[i,t]);
        od;
        Info(InfoGroebner,1,"|bas|=",t,", ",Length(B)," pairs left");
      fi;
    # remove first entry of B
    Remove(B,1);
  od;
  return bas;
end);

# setup for quotient rings of polynomial rings

#############################################################################
##
#M  NaturalHomomorphismByIdeal(<R>,<I>)
##
InstallMethod( NaturalHomomorphismByIdeal,"polynomial rings",IsIdenticalObj,
    [ IsPolynomialRing,IsRing],
function(R,I)
local ord,b,ind,num,c,corners,i,j,a,rem,bound,mon,n,monb,dim,sc,k,l,char,hom;
  if not IsIdeal(R,I) then
    Error("I is not an ideal!");
  fi;
  if not IsField(LeftActingDomain(R)) then
    TryNextMethod();
  fi;
  char:=Characteristic(LeftActingDomain(R));
  ord:=MonomialGrlexOrdering();
  b:=GroebnerBasis(I,ord);

  # special case: unit in ideal -- quotient is trivial
  if ForAny(b,IsUnit) then
    a:=Subring(R,[Zero(R)]);
    hom:=MappingByFunction(R,a,x->Zero(a));
    SetImagesSource(hom,a);
    return hom;
  fi;


  # determine all monomials bounded
  ind:=IndeterminatesOfPolynomialRing(R);
  n:=Length(ind);
  num:=List(ind,IndeterminateNumberOfUnivariateRationalFunction);
  c:=List(b,x->ExtRepNumeratorRatFun(LeadingMonomialOfPolynomial(x,ord))[1]);
  corners:=[];
  bound:=List(ind,x->infinity);
  for i in c do
    a:=List(ind,x->0);
    for j in [1,3..Length(i)-1] do
      a[Position(num,i[j])]:=i[j+1];
    od;
    # single variable bound
    if Number(a,x->x<>0)=1 then
      bound[PositionNonZero(a)]:=Sum(a);
    else
      Add(corners,a); # extra corner
    fi;
  od;
  if not ForAll(bound,IsInt) then
    Info(InfoWarning,1,"quotient ring has infinite dimension");
    TryNextMethod();
  fi;

  #run through bounded simplex
  a:=List(ind,x->0);
  mon:=[a];
  i:=Length(a);
  repeat
    a[i]:=a[i]+1;
    while i>0 and a[i]>=bound[i] do
      a[i]:=0;
      i:=i-1;
      if i>0 then
        a[i]:=a[i]+1;
      fi;
    od;

    if i>0 then
      if ForAny(corners,x->ForAll([1..n],j->x[j]<=a[j])) then
        # set last coordinate to become 0 again
        a[n]:=bound[n];
        i:=n;
      else
        Add(mon,ShallowCopy(a));
        i:=Length(a);
      fi;
    fi;
  until i=0;

  # basis of the quotient as vector space
  mon:=List(mon,x->Product([1..n],y->ind[y]^x[y]));
  monb:=Basis(VectorSpace(LeftActingDomain(R),mon));

  # now form the quotient
  dim:=Length(mon);
  sc:=EmptySCTable(dim,0);
  for i in [1..dim] do
    for j in [1..dim] do
      rem:=PolynomialReducedRemainder(mon[i]*mon[j],b,ord);
      a:=rem;
      if not IsZero(a) then
        a:=Coefficients(monb,a);
        if char>0 then
          a:=List(a,Int);
        fi;
        l:=[];
        for k in [1..dim] do
          if not IsZero(a[k]) then
            Add(l,a[k]);
            Add(l,k);
          fi;
        od;
        SetEntrySCTable(sc,i,j,l);
      fi;
    od;
  od;
  l:=List(mon,x->Concatenation("(",
        Filtered(String(x),y->y<>'^' and y<>'*'),")"));
  a:=PositionProperty(mon,IsOne);
  if a<>fail then
    l[a]:="(1)";
  fi;

  a:=AlgebraByStructureConstants(LeftActingDomain(R),sc,l);
  if Length(l)<50 then
    j:=Concatenation("<ring ",String(LeftActingDomain(R)));
    for i in l do
      Append(j,",");
      Append(j,i);
    od;
    Append(j,">");
    SetName(a,j);
  fi;
  #k:=Concatenation([One(R)],IndeterminatesOfPolynomialRing(R));
  k:=IndeterminatesOfPolynomialRing(R);
  l:=[];
  for i in k do
    j:=Position(mon,i);
    if j<>fail then
      Add(l,GeneratorsOfLeftOperatorRing(a)[j]);
    else
      rem:=PolynomialReducedRemainder(i,b,ord);
      rem:=Coefficients(monb,rem);
      Add(l,GeneratorsOfLeftOperatorRing(a)*rem);
    fi;
  od;

  hom:=AlgebraWithOneHomomorphismByImagesNC(R,a,k,l);
  SetIsSurjective(hom,true);
  SetKernelOfAdditiveGeneralMapping(hom,I);

  j:=AlgebraWithOneGeneralMappingByImages(a,R,l,k);
  SetInverseGeneralMapping(hom,j);

  return hom;
  #x*y^3-x^2,x^3*y^2-y

end);


# BindGlobal("CANGB",function(elms,order)
#local orderext, bas, i, l, nomod, pol;
#  orderext:=MonomialExtrepComparisonFun(order);
#  # do some tests
#  bas:=ShallowCopy(elms);
#  i:=1;
#  l:=Length(bas);
#  repeat
#    nomod:=true;
#    while i<=l do
#      pol:=PolynomialReducedRemainder(bas[i],
#             bas{Difference([1..Length(bas)],[i])},orderext);
#      if pol<>bas[i] then nomod:=false;fi;
#      if IsZero(pol) then
#        bas[i]:=bas[l];
#        Unbind(bas[l]);
#        l:=l-1;
#      else
#        bas[i]:=pol;
#        i:=i+1;
#      fi;
#    od;
#  until nomod;
#  for i in [1..Length(bas)] do
#     bas[i]:=bas[i]/LeadingCoefficientOfPolynomial(bas[i],order);
#  od;
#  Sort(bas,MonomialComparisonFunction(order));
#  return bas;
#end);
#
#DoTest:=function(l,ord)
#local a,b,t1,t2;
#  t1:=Runtime();
#  a:=NaiveBuchberger(l,ord);
#  t1:=Runtime()-t1;
#  t2:=Runtime();
#  b:=GroebnerBasis(l,ord);
#  t2:=Runtime()-t2;
#  a:=CANGB(a,ord);
#  b:=CANGB(b,ord);
#  return [t1,t2,a=b];
#end;
