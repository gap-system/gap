#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Undocumented  utilities to  write out  infos  about all  methods of  all
##  operations with  location and rank, and  to write out all  filters by name
##  and their rank. These can be useful to debug larger changes that influence
##  the ranking of filters and methods.
##

# prints lines of format
#   name of operation;nr of args;filename:line (of method installation);rank
BIND_GLOBAL("WriteMethodOverview", function(fname)
  local relname, f;
  relname := function(path)
    local ls, s;
    for s in GAPInfo.RootPaths do
      ls := Length(s);
      if Length(path) >= ls and path{[1..ls]}=s then
        return path{[ls+1..Length(path)]};
      fi;
    od;
    return path;
  end;
  f := function()
    local op, nam, i, ms, m, str;
    str := OutputTextFile(fname, false);
    for op in OPERATIONS do
      nam := NameFunction(op);
      for i in [0..6] do
        ms := MethodsOperation(op, i);
        for m in ms do
          PrintTo(str, nam,";\c",i,";",
                       relname(m.location[1]),":",m.location[2],";\c",
                       m.rank,"\n");
        od;
      od;
    od;
    CloseStream(str);
  end;
  f();
end);

# prints file with lines of format
#   filter name (with some abbreviations);rank
BIND_GLOBAL("WriteFilterRanks", function(fname)
  local nams, rks, n, i, str;
  str := OutputTextFile(fname, false);
  nams := List(FILTERS, NameFunction);
  rks := List(FILTERS, RankFilter);
  SortParallel(nams, rks);
  for i in [1..Length(nams)] do
    n := ReplacedString(nams[i],"CategoryCollections","CC");
    if Length(n) > 75 then
      n := Concatenation(n{[1..30]},"...",n{[Length(n)-29..Length(n)]});
    fi;
    PrintTo(str, n,";",rks[i],"\n");
  od;
  CloseStream(str);
end);
