##############################################################################
##  operdebug.g                                                   Frank Lübeck
##  
##  Non-documented  utilities to  write out  infos  about all  methods of  all
##  operations with  location and rank, and  to write out all  filters by name
##  and their rank. These can be useful to debug larger changes that influence
##  the ranking of filters and methods.
##  

# prints lines of format
#   name of operation;nr of args;filename:line (of method installation);rank
BIND_GLOBAL("WriteMethodOverview", function(fname)
  local name, sline, relname, f;
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
  sline := function(f)
    local n;
    n := StartlineFunc(f);
    if n=fail then
      return "\c";
    fi;
    return Concatenation(":",String(n),"\c");
  end;
  f := function()
    local nam, m, s, op, i, j;
    for op in OPERATIONS do
      nam := NameFunction(op);
      for i in [0..6] do
        m := METHODS_OPERATION(op, i);
        s := BASE_SIZE_METHODS_OPER_ENTRY + i;
        for j in [1..Length(m)/s] do
          Print(nam,";\c",i,";",
                relname(m[j*s][1]),":",m[j*s][2],";\c",
                m[j*s-2],"\n");
        od;
      od;
    od;
  end;
  PrintTo1(fname, f);
end);

# prints file with lines of format
#   filter name (with some abbreviations);rank
BIND_GLOBAL("WriteFilterRanks", function(fname)
  local f;
  f := function()
    local nams, rks, n, i;
    nams := List(FILTERS, NameFunction);
    rks := List(FILTERS, RankFilter);
    SortParallel(nams, rks);
    for i in [1..Length(nams)] do
      n := SubstitutionSublist(nams[i],"CategoryCollections","CC");
      if Length(n) > 75 then
        n := Concatenation(n{[1..30]},"...",n{[Length(n)-29..Length(n)]});
      fi;
      Print(n,";",rks[i],"\n");
    od;
  end;
  PrintTo1(fname, f);
end);

