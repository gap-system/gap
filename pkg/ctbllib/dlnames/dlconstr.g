#############################################################################
##
#W  dlconstr.g            GAP 4 package `ctbllib'      Michael Cla\3en-Houben
##
#H  @(#)$Id: dlconstr.g,v 1.1 2005/05/17 08:51:03 gap Exp $
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "ctbllib/dlnames/dlconstr_g" ) :=
    "@(#)$Id: dlconstr.g,v 1.1 2005/05/17 08:51:03 gap Exp $";


#############################################################################
##
#V  DeltigConstructionFcts
##
BindGlobal( "DeltigConstructionFcts", rec(
  info:= "functions to find unipotent characters"
)
);

DeltigConstructionFcts.Size:= function(isoc, l, q)
  if isoc = "A" then
    return q^((l+1)*l/2) * Product([2 .. l+1], i -> q^i - 1);
  else 
    return fail;
  fi;
end;

DeltigConstructionFcts.DegreeTypeA:= function(label, q)
  local m, i, list;
  list:= ShallowCopy(label);
  Sort(list);
  for i in [1..Length(list)] do
    list[i]:= list[i] + i - 1;
  od;
  m:=Length(list);
  return ( Product([1 .. Sum(label)], j -> q^j - 1)
           * Product(Combinations([1..m], 2),j -> q^list[j[2]]-q^list[j[1]]) )
       / ( q^Sum([2..m-1], j -> Binomial(j,2))
           *  Product([1..m], j -> Product([1..list[j]], k-> q^k - 1) ) )
  ;       
end;

DeltigConstructionFcts.DegreeType2A:= function(label, q)
  if IsRationalFunction(q) then
    if CycPol(DeltigConstructionFcts.DegreeTypeA(label, -q)).rest[1]<0 then
      return - DeltigConstructionFcts.DegreeTypeA(label, -q);
    else
      return  DeltigConstructionFcts.DegreeTypeA(label, -q);
    fi;
  else
    return AbsInt(DeltigConstructionFcts.DegreeTypeA(label, -q));
  fi;
end;

DeltigConstructionFcts.DegreeTypesBCD2D:= function(label, q)
  return Product([1 .. RankSymbol(label) - 1 ], i -> q^(2*i) - 1 )
  * Product([1 .. Length(label[1])], 
    i -> Product([1 .. i-1], j -> q^(label[1][i]) - q^(label[1][j]) ) )
  * Product([1 .. Length(label[2])], 
    i -> Product([1 .. i-1], j -> q^(label[2][i]) - q^(label[2][j]) ) )
  * Product([1 .. Length(label[1])],
    i -> Product([1 .. Length(label[2])], 
      j -> q^label[1][i] + q^label[2][j] ) )
  / (
  Product(label[1], 
    l -> Product([1 .. l], k -> q^(2*k) - 1) )
  * Product(label[2], 
    l -> Product([1 .. l], k -> q^(2*k) - 1) ) );
end;

DeltigConstructionFcts.DegreeTypeB:= function(label, q)
  return DeltigConstructionFcts.DegreeTypesBCD2D(label, q)
  * (q^(2* RankSymbol(label)) - 1)
  / (
  2^( (Length(label[1]) + Length(label[2]) - 1) / 2 )
  * q^(Sum([2 .. (Length(label[1]) + Length(label[2]) - 1) / 2],
    i -> Binomial(2*i - 1, 2) ) ) );
end;

DeltigConstructionFcts.DegreeTypeC:= function(label, q)
  return DeltigConstructionFcts.DegreeTypeB(label, q);
end;

DeltigConstructionFcts.DegreeTypeD:= function(label, q)
  local c;
  if label[1] = label[2] then 
    c:= Length(label[1]);
  else 
    c:= ( (Length(label[1]) + Length(label[2])) / 2 ) - 1;
  fi;
  return DeltigConstructionFcts.DegreeTypesBCD2D(label, q)
  * (q^RankSymbol(label) - 1)
  / ( 
  2^c
  * q^(Sum([1 .. (Length(label[1]) + Length(label[2]) - 2) / 2],
    i -> Binomial(2*i, 2) ) ) );
end;

DeltigConstructionFcts.DegreeType2D:= function(label, q)
  return DeltigConstructionFcts.DegreeTypesBCD2D(label, q)
  * (q^RankSymbol(label) + 1)
  / ( 
  2^((Length(label[1]) + Length(label[2]) - 2 ) / 2)
  * q^(Sum([1 .. (Length(label[1]) + Length(label[2]) - 2) / 2],
    i -> Binomial(2*i, 2) ) ) );
end;


DeltigConstructionFcts.Candidates:= function(tbl, record)
  local q, isoc, lst, elem, l, s, d, param, degree, chi, item;
  q:= record.q;
  l:= record.l;
  isoc:= record.isoc;
  lst:= [];
  if isoc ="A"  or isoc ="2A" then
    for elem in CharacterParameters(CharacterTable("Symmetric", l+1)) do
      Add(lst, rec(
        label:= elem[2],
        weyllabel:= elem[2],
        series:= 1
      ) );
    od;
  elif isoc = "B" or isoc = "C" then
    s:= 0;
    while s^2 + s < l do
      d:= 2*s + 1;
      param:= CharacterParameters(CharacterTable("WeylB", l-(s^2+s)));
      for elem in param do 
        Add(lst, rec(
          label:= SymbolPartitionTuple(elem[2], d),
          weyllabel:= elem[2],
          series:= s+1
        ) );
      od;
      s:= s+1;
    od;
    if s^2 + s = l then
      d:= 2*s + 1;
      param:= [ [  ], [  ] ];
      Add(lst, rec(
        label:= SymbolPartitionTuple(param, d),
        weyllabel:= param,
        series:= s+1
      ) );
    fi;
  elif isoc = "D" then
    s:= 0;
    param:= CharacterParameters(CharacterTable("WeylD", l));
    for elem in param do 
      if not IsList(elem[2][2]) then
        Add(lst, rec(
          label:= SymbolPartitionTuple([elem[2][1], elem[2][1]], 0),
          weyllabel:= elem[2],
          series:= s+1
        ) );
      else
        Add(lst, rec(
          label:= SymbolPartitionTuple(elem[2], 0),
          weyllabel:= elem[2],
          series:= s+1
        ) );
      fi;
    od;
    s:= 2;
    while s^2 < l do
      d:= 2*s;
      param:= CharacterParameters(CharacterTable("WeylB", l-s^2));
      for elem in param do 
        Add(lst, rec(
          label:= SymbolPartitionTuple(elem[2], d),
          weyllabel:= elem[2],
          series:= s/2 + 1
        ) );
      od;
      s:= s+2;
    od;
    if s^2 = l then
      d:= 2*s;
      param:= [ [  ], [  ] ];
      Add(lst, rec(
        label:= SymbolPartitionTuple(param, d),
        weyllabel:= param,
        series:= s/2 + 1
      ) );
    fi;
  elif isoc = "2D" then
    s:= 1;
    while s^2 < l do
      d:= 2*s;
      param:= CharacterParameters(CharacterTable("WeylB", l-s^2));
      for elem in param do 
        Add(lst, rec(
          label:= SymbolPartitionTuple(elem[2], d),
          weyllabel:= elem[2],
          series:= (s+1)/2
        ) );
      od;
      s:= s+2;
    od;
    if s^2 = l then
      d:= 2*s;
      param:= [ [  ], [  ] ];
      Add(lst, rec(
        label:= SymbolPartitionTuple(param, d),
        weyllabel:= param,
        series:= (s+1)/2
      ) );
    fi;
  else
    return fail;
  fi;

  degree:= DeltigConstructionFcts.(Concatenation("DegreeType", isoc));
  for elem in lst do
    if isoc in [ "B", "C", "D" ] then
      elem.familylabel:= Concatenation(elem.label[1],elem.label[2]);
      Sort(elem.familylabel);
    fi;
    elem.degree:= degree(elem.label, q);
    elem.candidates:= [  ];
    elem.unipotchar:= 1;
    elem.related:= [  ];
    if IsCharacterTable(tbl) then
      for chi in Irr(tbl) do
        if elem.degree = chi[1] then
          Add(elem.candidates, Position(Irr(tbl), chi));
        fi;
      od;
    fi;
  od;
  for item in lst do
    if item.degree = elem.degree then 
      Add(elem.related, item.label);
    fi;
  od;
  return lst;
end;


DeltigConstructionFcts.Theta:= function(lst, tbl, wtbl)
  local elem, i, theta, p;
  for elem in lst do
    if not IsRecord(elem) then
      return [fail, fail];
    elif not IsBound(elem.unipotchar) then
      elem.unipotchar:= 1;
    fi;
  od;
  if ForAll([1..Length(lst)],
    i -> IsBound(lst[i].candidates[lst[i].unipotchar]))
  then
    theta:= Sum([1 .. Length(Irr(wtbl))], 
      i -> Irr(wtbl)[i][1]
           * Irr(tbl)[lst[i].candidates[lst[i].unipotchar]]);
  else return [false];
  fi;
  if    TestPerm1(tbl, theta) = 0 
    and TestPerm2(tbl, theta) = 0
#    and TestPerm3(tbl, [theta]) = [theta] 
#    and TestPerm4(tbl, [theta]) = [theta]
  then
#    for p in Unique(Factors(Size(tbl))) do
#      if not TestPerm5(tbl, [theta], tbl mod p) = [theta] then
#        return [false, theta];
#      fi;
#    od;
    return [true, theta];
  else
    return [false, theta];
  fi;
end;


#DeltigConstructionFcts.ConstructLib:= function(names, wtbl)
#  local str, tbl, lst, tup, i;
#  for str in names do
#    Display(str);
#    tbl:= CharacterTable(str);
#    lst:= DeltigConstructionFcts.Candidates(tbl);
#    for tup in Tuples([1 .. 3], Length(lst)) do
#      for i in [ 1 .. Length(lst) ] do
#        lst[i].unipotchar:= tup[i];
#      od;
#      if DeltigConstructionFcts.Theta(tbl, wtbl, lst)[1] then
#        Display([DeltigConstructionFcts.Theta(tbl, wtbl, lst)[1],tup]);
#        LibFormat(lst, tbl);
#      else
#        Print([false, tup]);
#      fi;
#    od;
#  od;
#end;


DeltigConstructionFcts.SpecialSymbol:= function(label)
  local famlabel, specialsymbol, i;
  famlabel:= Concatenation(
    ShallowCopy(label[1]), ShallowCopy(label[2])
  ); 
  Sort(famlabel);
  specialsymbol:= [ [  ], [  ] ];
  for i in [ 1 .. Length(famlabel) ] do
    if IsOddInt(i) then
      Add(specialsymbol[1], famlabel[i]);
    else
      Add(specialsymbol[2], famlabel[i]);
    fi;
  od;
  return specialsymbol;
end;


DeltigConstructionFcts.Family:= function(tbl)
  local lst, famnr, famlabel, i, j, families;
  lst:= DeltigConstructionFcts.Candidates(tbl);
  famnr:= 1;
  for i in [ 1..Length(lst) ] do
    famlabel:= Concatenation(
      ShallowCopy(lst[i].label[1]), ShallowCopy(lst[i].label[2])
    ); 
    Sort(famlabel);
    lst[i].familylabel:= famlabel;
    if ForAll([1 .. i-1], j-> lst[i].familylabel <> lst[j].familylabel) then
      lst[i].familynr:= famnr;
      famnr:= famnr + 1;
    else
      for j in [ 1 .. i ] do
        if lst[i].familylabel = lst[j].familylabel then
          lst[i].familynr:= lst[j].familynr;
        fi;
      od;
    fi;
  od;
  families:= [ ];
  for i in [ 1..Length(lst) ] do
    if not IsBound(families[lst[i].familynr]) then
      families[lst[i].familynr]:= [ lst[i] ];
    else
      Add(families[lst[i].familynr], lst[i]);
    fi;
  od;
  return families;
end;

#DeltigConstructionFcts.SemisimpleTest:= function(tbl, families, label)
#  local famlabel, xi, family, i, lst, p;
#  famlabel:= Concatenation(
#    ShallowCopy(label[1]), ShallowCopy(label[2])
#  ); 
#  Sort(famlabel);
#  xi:= 0 * Irr(tbl)[1];
#  for family in families do
#    if family[1].familylabel = famlabel then
#      for i in [ 1 ..Length(family) ] do
#        if family[i].label = label or 
#           family[i].label = DeltigConstructionFcts.SpecialSymbol(label)
#        then
#          xi:= xi + 1/2 * Irr(tbl)[family[i].candidates[family[i].unipotchar]];
#        else
#          xi:= xi - 1/2 * Irr(tbl)[family[i].candidates[family[i].unipotchar]];
#        fi;
#      od;
#    fi;
#  od;
#  lst:= OrdersClassRepresentatives(tbl);
#  p:= Factors(DeltigGroups.Getq(Identifier(tbl)))[1];
#  for i in [1..Length(lst)] do
#    if (lst[i] mod p <> 0) and (xi[i] <> 0) then
#      return false;
#    fi;
#  od;
#  return [true, xi];
#end;


#############################################################################
##
#E

