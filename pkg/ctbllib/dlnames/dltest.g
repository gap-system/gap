#############################################################################
##
#W  dltest.g              GAP 4 package `ctbllib'      Michael Cla\3en-Houben
##
#H  @(#)$Id: dltest.g,v 1.1 2005/05/17 08:51:03 gap Exp $
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "ctbllib/dlnames/dltest_g" ) :=
    "@(#)$Id: dltest.g,v 1.1 2005/05/17 08:51:03 gap Exp $";


#############################################################################
##
#V  DeltigTestFcts
##
BindGlobal( "DeltigTestFcts", rec(
  info:= "test functions"
) 
);

DeltigTestFcts.Degree:= function(r)
  local record, degree, elem, bool, tbl;
  record:= DeltigNames.GetRecordFromLib(r);
  if record = fail then
    Display("this group is not in the library. try adjoint isogenytype.");
    return fail;
  fi;
  degree:= DeltigConstructionFcts.(Concatenation("DegreeType", r.isoc));
  tbl:= CharacterTable(DeltigGroups.Name(r));
  bool:= true;
  for elem in record.labeling do
    if not degree(elem.label, r.q) = Irr(tbl)[elem.index][1] then 
      Display(Concatenation("Error in ", DeltigGroups.String(r), " label:"));
      Display(elem.label);
      bool:= false;
    fi;
  od;
  return bool;
end;

DeltigTestFcts.PermChar:= function(r)
  local lst, tbl, wtbl, theta, elem;
    lst:= DeligneLusztigNames(r);
  if lst = fail then
    Display("this group is not in the library.");
    return fail;
  fi;
  tbl:= CharacterTable(DeltigGroups.Name(r));
  theta:=0*Irr(tbl)[1];
  if r.isoc = "A" then
    wtbl:= CharacterTable("Symmetric", r.l + 1);
    for elem in CharacterParameters(wtbl) do
      theta:= theta +
        Irr(wtbl)[Position(CharacterParameters(wtbl), elem)][1]
        * Irr(tbl)[Position(lst,elem[2])]
      ;
    od;
  elif r.isoc in [ "B", "C" ] then 
    wtbl:= CharacterTable("WeylB", r.l );
    for elem in CharacterParameters(wtbl) do
      theta:= theta +
        Irr(wtbl)[Position(CharacterParameters(wtbl), elem)][1]
        * Irr(tbl)[Position(lst,SymbolPartitionTuple(elem[2], 1))]
      ;
    od;
  fi;
  return theta;
  return TestPerm1(tbl, theta) = 0
     and TestPerm2(tbl, theta) = 0
     and TestPerm3(tbl, [theta]) = [theta]
     and TestPerm4(tbl, [theta]) = [theta]
  ;
end;

DeltigTestFcts.PermCharParabolic:= function(r)
  local lst, tbl, cox, comb, bool, elem, u, it, symb, type, l, pos, 
    symbols, theta, i;
    lst:= DeltigNames.GetRecordFromLib(r);
  if lst = fail then
    Display("this group is not in the library.");
    return fail;
  fi;
  tbl:= CharacterTable(DeltigGroups.Name(r));
  if r.isoc = "A" then
    cox:= CoxeterGroupByReflectionDatum("A", r.l);
  elif r.isoc = "B" then
    cox:= CoxeterGroupByReflectionDatum("B", r.l);
  elif r.isoc = "C" then
    cox:= CoxeterGroupByReflectionDatum("C", r.l);
  elif r.isoc = "D" then
    cox:= CoxeterGroupByReflectionDatum("D", r.l);
  elif r.isoc = "2D" then
    cox:= CoxeterGroupByReflectionDatum("C", r.l);
  fi;
  comb:= Combinations([1 .. r.l]);
  Sort(comb, function(l1,l2) return (Length(l1) > Length(l2)); end);
  Unbind(comb[Length(comb)]);
  Unbind(comb[1]);
  bool:= true;
  for elem in comb do
    u:= ReflectionSubgroupByPositions(cox, elem);
    it:= InductionTable(u, cox);
    symb:= [  ];
    for type in ReflectionType(u) do
      if type.series = "C" then 
        Add(symb,[ [ type.rank ], [  ] ]); 
      elif type.series = "A" then 
        Add(symb,[ type.rank + 1 ]);
      elif type.series = "D" then
        Add(symb,[ [ type.rank ], '+' ]);
      fi;
    od;
    pos:= Position(ClassParameters(u), symb);
    symbols:= ShallowCopy(ClassParameters(cox));
    for i in [1..Length(symbols)] do
      if IsBound(symbols[i][1][2]) and IsChar(symbols[i][1][2]) then
        symbols[i]:= [symbols[i][1][1],symbols[i][1][1]];
      else
        symbols[i]:= symbols[i][1];
      fi;
    od;
    theta:= Sum([ 1 .. Length(symbols)], i ->
      it[i][pos] * Irr(tbl)[lst.labeling[i].index]
    );
    if not (TestPerm1(tbl, theta)   = 0
       and  TestPerm2(tbl, theta)   = 0
#       and  TestPerm3(tbl, [theta]) = [theta]
#       and  TestPerm4(tbl, [theta]) = [theta]
    ) then
      Display([false,elem]);
      bool:= false;
    else
      Display([true,elem]);
    fi;
  od;
  return bool;
end;

DeltigTestFcts.AlmostChar:= ReturnFalse;


BindGlobal( "DeltigTestFunction", function(record, str)
  if not record in DeltigGroups.records then 
    Display("this group is not available");
    return fail;
  fi;
  if   str = "Degree" then 
    return DeltigTestFcts.Degree(record);
  elif str = "PermChar" then 
    return DeltigTestFcts.PermChar(record);
  elif str = "PermCharParabolic" then 
    return DeltigTestFcts.PermCharParabolic(record);
  elif str = "AlmostChar" then
    return DeltigTestFcts.AlmostChar(record);
  else
    return fail;
  fi;
end );


#############################################################################
##
#E

