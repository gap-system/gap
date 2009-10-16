#############################################################################
##
#W    tools.gi             The GenSift package                Max Neunhoeffer
##                                                             Cheryl Praeger
##                                                            Csaba Schneider
##
##    @(#)$Id: tools.gi,v 1.4 2008/05/08 13:41:51 gap Exp $
##
##  This file contains functions to help in the process of finding subset
##  chains. These are not necessary to actually sift.
##


############################################################################
# Helper functions:
############################################################################

GenSift.FindShortEl := function(arg)
  # To start call with G,f[,exc]
  # Result: [el,word,status]
  # To go on call with status
  # Result: [el,word,status]
  local g,i,l,s,wo,x;
  if Length(arg) = 1 then
      s := arg[1];
  else
      s := rec(G := arg[1],f := arg[2],isorbitrecord := true);
      if Length(arg) > 2 then
          s.exc := arg[3];
      else
          s.exc := [];
      fi;
      s.gens := GeneratorsOfGroup(s.G);
      s.orb := [[One(s.G),[]]];
      s.set := [One(s.G)];
      s.i := 1;
      s.j := 1;
      if not(One(s.G) in s.exc) and s.f(One(s.G)) then
          return [s.orb[1][1],s.orb[1][2],s];
      fi;
  fi;
  l := Length(s.gens);
  while s.i <= Length(s.orb) do
      x := s.orb[s.i][1] * s.gens[s.j];
      g := s.j;
      i := s.i;
      s.j := s.j + 1;
      if s.j > Length(s.gens) then
          s.j := 1;
          s.i := s.i + 1;
      fi;
      if not(x in s.set) then
          AddSet(s.set,x);
          wo := ShallowCopy(s.orb[i][2]);
          Add(wo,g);
          Add(s.orb,[x,wo]);
          if not(x in s.exc) and s.f(x) then
              AddSet(s.exc,x);  # for next time
              return [x,wo,s];
          fi;
      fi;
  od;
  Error("Found no element in group satisfying condition!");
end;
InstallGlobalFunction( FindShortEl, GenSift.FindShortEl );

# a nice view method:
InstallMethod( ViewObj, "for orbit records", [IsRecord],
  function( r )
    if not(IsBound(r.isorbitrecord)) or not(r.isorbitrecord) then
        TryNextMethod();
    fi;
    Print("<orbitrec |orb|=",Length(r.orb)," i=",r.i,">");
  end);

GenSift.PowerSet := function(s)
  local i,l,le,ll;
  if Length(s) = 0 then
      return [[]];
  elif Length(s) = 1 then
      return [[],[s[1]]];
  else
      l := GenSift.PowerSet(s{[1..Length(s)-1]});
      le := Length(l);
      for i in [1..le] do
          ll := ShallowCopy(l[i]);
          Add(ll,s[Length(s)]);
          Add(l,ll);
      od;
      return l;
  fi;
end;

GenSift.SLPLineFromWord := function(wo)
  local li,i,j;
  li := [];
  i := 1;
  while i <= Length(wo) do
      j := i+1;
      while j <= Length(wo) and wo[j] = wo[i] do
          j := j + 1;
      od;
      Add(li,wo[i]);
      Add(li,j-i);
      i := j;
  od;
  return li;
end;

GenSift.FindShortGeneratorsSubgroup := function(G,U)
  local su,l,subgens,r,s,ps,min,minsi,subgensalone,i,si;
  su := Size(U);
  l := GenSift.FindShortEl(G,x->x in U,[One(U)]);
  subgens := [[l[1],l[2]]];
  r := l[3];
  si := Size(Group(List(subgens,y->y[1])));
  Print("Found subgroup of size ",si,":",List(subgens,x->x[2]),"\n");
  if si = su then
      # Cyclic subgroup
      s := StraightLineProgram([GenSift.SLPLineFromWord(l[2])],
                               Length(GeneratorsOfGroup(G)));
      return [subgens,s];
  fi;
  while true do
      l := GenSift.FindShortEl(r);
      Add(subgens,[l[1],l[2]]);
      s := Size(Group(List(subgens,y->y[1])));
      if s = su then
          # OK, we have got a generating set:
          # Now try shortening generating set:
          Print("Found ",Length(subgens)," generators.\n");
          ps := GenSift.PowerSet([1..Length(subgens)]);
          min := Length(ps);
          minsi := Length(subgens);
          subgensalone := List(subgens,x->x[1]);
          for i in [2..Length(ps)-1] do
              s := Size(Group(subgensalone{ps[i]}));
              Print("s=",s,"                    \r");
              if s = su and Length(ps[i]) < minsi then
                  min := i;
                  minsi := Length(ps[i]);
                  Print("Found ",minsi," generators.\n");
              fi;
          od;
          subgens := subgens{ps[min]};
          l := List(subgens,x->GenSift.SLPLineFromWord(x[2]));
          s := StraightLineProgram([l],Length(GeneratorsOfGroup(G)));
          return [subgens,s];
      fi;
      if s=si then
          Unbind(subgens[Length(subgens)]);
      else
          si := s;
          Print("Found subgroup of size ",si,":",List(subgens,x->x[2]),"\n");
      fi;
  od;
end;

GenSift.FindStandardGens := function(g)
  local a,b,x,y,z1,z2;
  x := g.1;
  y := g.3;
  while true do
      z1 := PseudoRandom(g);
      a := x^z1;
      z2 := PseudoRandom(g);
      b := y^z2;
      if Order(a*b)=11 and
         Order((a * b) ^ 2 * (a * b * a * b ^ 2) ^ 2 * a * b ^ 2) = 7 then
          return [a,b,z1,z2];
      fi;
  od;
end;


GenSift.FindShortWords := function(G,pt,act)
  # g a permutation group
  local g,gens,i,l,orb,set,wo,x;
  gens := GeneratorsOfGroup(G);
  l := Length(gens);
  orb := [[pt,[]]];
  set := [pt];
  i := 1;
  while i <= Length(orb) do
      for g in [1..l] do
          x := act(orb[i][1],gens[g]);
          if not(x in set) then
              AddSet(set,x);
              wo := ShallowCopy(orb[i][2]);
              Add(wo,g);
              Add(orb,[x,wo]);
          fi;
      od;
      i := i + 1;
  od;
  return orb;
end;

GenSift.FindWordsLeftCosetReps := function(g,h)
  local gg,ggg,words;
  # Note that we take the bigger group generated by the inverses and
  # reverse the words in the end. This gives left coset reps.
  gg := Group(List(GeneratorsOfGroup(g),x->x^-1));
  ggg := Image(FactorCosetAction(gg,h));
  words := GenSift.FindShortWords(ggg,1,OnPoints);
  return List(words,x->GenSift.SLPLineFromWord(Reversed(x[2])));
end;

GenSift.PrintCosetReps := function(g,h)
  local l,nr,i;
  l := GenSift.FindWordsLeftCosetReps(g,h);
  nr := Length(GeneratorsOfGroup(g));
  Print("[StraightLineProgram( [ [ 1, 0 ] ], ",nr," ),\n");
  for i in [2..Length(l)] do
    Print(" StraightLineProgram( [ ",l[i]," ], ",nr," ),\n");
  od;
  Print("],\n");
end;
InstallGlobalFunction( PrintCosetReps, GenSift.PrintCosetReps );

GenSift.UpperLimitTries := function(eps,p)
  if not(IS_MACFLOAT(eps)) then
      eps := FLOAT_RAT(eps);
  fi;
  if not(IS_MACFLOAT(p)) then
      p := FLOAT_RAT(p);
  fi;
  return LOG_MACFLOAT(eps/MACFLOAT_INT(2))/LOG_MACFLOAT(1-p);
end;

GenSift.tablen := 10;  # plus number of generators
GenSift.maxlen := 100;
GenSift.FindRelativelyShortSLP := function(arg)
  # To start call with G,f[,exc]
  # Result: [el,slp,status]
  # To go on call with status
  # Result: [el,word,status]
  local s,i,r,rr;
  if Length(arg) = 1 then
      s := arg[1];
  else
      s := rec(G := arg[1],f := arg[2],isslprecord := true);
      if Length(arg) > 2 then
          s.exc := arg[3];
      else
          s.exc := [];
      fi;
      s.taborig := ShallowCopy(GeneratorsOfGroup(s.G));
      s.n := Length(s.taborig);
      s.slporig := [];
      s.i := 0;   # to start anew next!
      # Init once and for all:
      for i in [1..GenSift.tablen] do
          r := Random([1..s.n]);
          Add(s.taborig,s.taborig[r]);
          Add(s.slporig,[[r,1],i+s.n]);
      od;
  fi;
  while true do
      i := s.i;
      s.i := s.i + 1;
      if s.i > GenSift.maxlen then
          s.i := s.n+1;  # start anew next time!
      fi;
      # Some cases:
      if i = 0 then
          if not(One(s.G) in s.exc) and s.f(One(s.G)) then
              AddSet(s.exc,One(s.G));
              return [One(s.G),StraightLineProgram([[1,0]],s.n),s];
          fi;
      elif i <= s.n then
          if not(s.taborig[i] in s.exc) and s.f(s.taborig[i]) then
              AddSet(s.exc,s.taborig[i]);
              return [s.taborig[i],StraightLineProgram([[i,1]],s.n),s];
          fi;
      else
          if i = s.n+1 then    # we have to initialize:
              s.tab := ShallowCopy(s.taborig);
              s.slp := ShallowCopy(s.slporig);
              Print(".\c");
          fi;
          # Pick two different numbers from [1..s.n+GenSift.tablen]:
          r := Random([1..s.n+GenSift.tablen]);
          rr := Random([1..s.n+GenSift.tablen-1]);
          if rr >= r then rr := rr+1; fi;
          if Random([true,false]) then
              s.tab[r] := s.tab[r] * s.tab[rr];
              Add(s.slp,[[r,1,rr,1],r]);
          else
              s.tab[r] := s.tab[rr] * s.tab[r];
              Add(s.slp,[[rr,1,r,1],r]);
          fi;
          if s.tab[r] in s.exc then
              Print(":\c");
          elif s.f(s.tab[r]) then
              AddSet(s.exc,s.tab[r]);
              return [s.tab[r],StraightLineProgram(s.slp,s.n),s];
          fi;
      fi;
  od;
end;

# a nice view method:
InstallMethod( ViewObj, "for slp records", [IsRecord],
  function( r )
    if not(IsBound(r.isslprecord)) or not(r.isslprecord) then
        TryNextMethod();
    fi;
    Print("<slprec n=",r.n," i=",r.i,">");
  end);

GenSift.ElOrderStats := function(cs,ct)
  # ct a character table and cs a character table of a maximal subgroup
  # computes the proportion of "good" elements with respect to element orders
  # gives a list [ <size of ct>, <number of good els>, <size of cs>,
  #                <number of good els>/<size of ct>,
  #                <proportion of good els as float> ]
  local centralizerst,i,interesting,k,numbergoodels,orderss,orderst,sizet;
  orderst := OrdersClassRepresentatives(ct);
  orderss := OrdersClassRepresentatives(cs);
  interesting := Difference(Set(orderst),Set(orderss));
  if interesting = [] then
    return fail;
  fi;
  k := NrConjugacyClasses(ct);      # this is equal to Length(orderst)
  numbergoodels := 0;
  sizet := Size(ct);
  centralizerst := SizesCentralizers(ct);
  for i in [1..k] do
    if orderst[i] in interesting then
      numbergoodels := numbergoodels + sizet / centralizerst[i];
    fi;
  od;
  return [ sizet, numbergoodels, Size(cs), numbergoodels/sizet,
           FLOAT_RAT(numbergoodels/sizet), interesting ];
end;
InstallGlobalFunction( ElOrderStats, GenSift.ElOrderStats );

GenSift.ConjClassEmbStats := function(cs,ct)
  # ct a character table and cs a character table of a subgroup
  # Looks at the fusions, finds non-fusing classes and determines the
  # relative size to the corresponding class in the bigger group.
  # Prints a list of lines, one for each conj. class in ct.
  local cns,cnt,fus,i,j,ks,kt,li,res,sc,ss,st,sum,tabt;

  # Get some info:
  ss := SizesConjugacyClasses(cs);
  st := SizesConjugacyClasses(ct);
  ks := NrConjugacyClasses(cs);
  kt := NrConjugacyClasses(ct);
  fus := GetFusionMap(cs,ct);
  cns := ClassNames(cs);
  cnt := ClassNames(ct);
  sc := SizesCentralizers(ct);

  # First see which classes do fuse:
  # Calculate preimages:
  tabt := List([1..kt],x -> []);
  for i in [1..ks] do
      Add(tabt[fus[i]],i);
  od;
  
  # Now determine the relative sizes of conjugacy classes for the good ones:
  res := [];
  for i in [1..kt] do
      if Length(tabt[i]) > 0 then
          li := [i];
          Add(li,Concatenation(String(cnt[i],3),"<-",
                               JoinStringsWithSeparator(cns{tabt[i]},",")));
          sum := Sum(ss{tabt[i]});
          Add(li,sum/st[i]);
          Add(li,FLOAT_RAT(sum/st[i]));
          Add(li,ss{tabt[i]}/st[i]);
          Add(li,cns{tabt[i]});
          Add(res,li);
      fi;
  od;
  Sort(res,function(a,b) return a[3] > b[3]; end);
  Print("Going from ",Identifier(ct)," down to ",Identifier(cs),":\n");
  Print("#cl central. order      classes             probability\n");
  Print("------------------------------------------------------------------\n");
  for i in res do
      Print(String(i[1],-4),String(sc[i[1]],-20),
            String(i[2],-20),String(i[3]),"=",i[4],"\n");
      if Length(i[5]) > 1 then
          for j in [1..Length(i[5])] do
              Print("                             ",String(i[6][j],-17),
                    i[5][j],"\n");
          od;
      fi;
  od;
end;
InstallGlobalFunction( ConjClassEmbStats, GenSift.ConjClassEmbStats );

GenSift.MakeFus := function(cs,ct)
  # ct a character table and cs a character table of a subgroup
  # tries to find fusions, if successful and unique (up to table aut),
  # stores it.
  local fus,fus2;
  fus := PossibleClassFusions(cs,ct);
  fus2 := RepresentativesFusions(cs,fus,ct);
  if Length(fus2) = 1 then
    StoreFusion(cs,fus2[1],ct);
    return;
  fi;
  Error("Fusion not unique.");
end;

GenSift.CheckTail := function(done,todo)
  # done and todo are sets
  local allsums,i,int,j,l,steps,plan;
  todo := Difference(todo,done);
  steps := Length(todo);
  plan := [];
  repeat
    allsums := ShallowCopy(done);
    l := Length(todo);
    for i in done do
      for j in done do
        AddSet(allsums,i+j);
      od;
    od;
    int := Intersection(todo,allsums);
    done := Union(done,int);
    todo := Difference(todo,allsums);
    Append(plan,[int]);
    if Length(todo) = 0 then
      return plan;
    fi;
  until l = Length(todo);
  return false;
end;
    
GenSift.SLPOracle := function(todo)
  local additions,i,j,k,l,li,lli,n,newslp,res,slp,slpset,good,lastlli,mini,
        len,start,fl;
  
  mini := infinity;
  li := [[1]];
  l := 1;
  
  res := GenSift.CheckTail([1],todo);
  if res <> false then
    fl := Flat(res);
    return [[Length(fl),[],res,fl]];
  fi;

  good := [];
  lastlli := 0;
  while Length(good) = 0 do
    lli := Length(li);
    for i in [lastlli+1..lli] do   # try to add one to all slps of length l
      slp := li[i];
      slpset := Set(slp);
      additions := [];
      for j in [1..Length(slp)] do
        for k in [j..Length(slp)] do
          n := slp[j]+slp[k];
          if not(n in slpset) then
            AddSet(additions,n);
          fi;
        od;
      od;
      for j in additions do
        newslp := Concatenation(slp,[j]);
        res := GenSift.CheckTail(Set(newslp),todo);
        if res <> false then
          fl := Flat(res);
          len := Length(newslp)-1+Length(fl); 
          start := newslp{[2..Length(newslp)]};
          Add(good,[len,start,res,Concatenation(start,fl)]);
          if len < mini then mini := len; fi;
        fi;
        Add(li,newslp);
      od;
    od;
    lastlli := lli;
  od;
  return Filtered(good,x->x[1] = mini);
end;
InstallGlobalFunction( SLPOracle, GenSift.SLPOracle );
      
GenSift.MaximalDivisors := function(n)
  # Calculates the maximal divisors of n, not equal to 1 and not equal to n.
  local i,l,ll;
  if n = 1 then
      return [];
  fi;
  l := Collected(Factors(n));
  # Primes:
  if Length(l) = 1 and l[1][2] = 1 then
      return [];
  fi;
  ll := [];
  for i in [Length(l),Length(l)-1..1] do
      Add(ll,n/l[i][1]);
  od;
  return ll;
end;

GenSift.FindBestOrderList := function(l)
  local ll,todo,oracle,i,plan,bad,j,p,k,q,slp,res;
  # Finds a best possible SLP to calculate the orders.
  l := Set(l);
  ll := List(l,GenSift.MaximalDivisors);
  todo := Set(Flat(ll));
  todo := Union(todo,l);
  Info(InfoGenSift,1,"Orders to be calculated (including max. divisors):");
  Info(InfoGenSift,1,"   ",todo);
  # those orders have to be calculated!
  oracle := GenSift.SLPOracle(todo);
  Info(InfoGenSift,1,"Number of possible shortest SLPs: ",Length(oracle),
                     " (Length: ",oracle[1][1],")");
  for i in [1..Length(oracle)] do
      plan := oracle[i][4];
      bad := false;
      # Now check, whether all maximal divisors occur before the orders:
      for j in [1..Length(l)] do
          p := Position(plan,l[j]);
          for k in ll[j] do
              q := Position(plan,k);
              if q > p then
                  bad := true;
              fi;
          od;
      od;
      if not(bad) then
          Info(InfoGenSift,1,"Found possible shortest SLP:");
          slp := GenSift.MakeSLPFromOrderList(plan,l);
          res := ["["];
          for j in [1..Length(slp)] do
              Append(res,["[",String(slp[j][1]),",",String(slp[j][2]),",",
                              String(slp[j][3]),"],"]);
              if j mod 7 = 0 then Add(res,"\n   "); fi;
          od;
          Add(res,"]");
          return [slp,plan,Concatenation(res)];
      fi;
      Info(InfoGenSift,1,"SLP not usable!");
  od;
  return fail;
end;
InstallGlobalFunction( FindBestOrderList, GenSift.FindBestOrderList );


GenSift.MakeSLPFromOrderList := function(todo,interesting)
  # todo is a list of element orders, typically a result of SLPOracle
  # interesting is the list of orders that are interesting
  # returns an slp to do the work
  # the lines of the slp have the following form:
  # [a,b,c] means multiply result number a with result number b, 1 meaning the
  # start element and 2 meaning the first intermediate result
  # c is boolean, if c is true, the intermediate result is one of the 
  # interesting elements.
  local done,found,i,j,k,slp;
  done := [1];
  slp := [];
  for i in todo do
      found := false;
      j := 1;
      repeat
          k := 1;
          repeat
              if done[j]+done[k] = i then
                  if i in interesting then
                      Add(slp,[j,k,1]);
                  else
                      Add(slp,[j,k,0]);
                  fi;
                  Add(done,i);
                  found := true;
              fi;
              k := k + 1;
          until found or k > Length(done);
          j := j + 1;
      until found or j > Length(done);
      if not(found) then
          Error("Should not have happened!");
      fi;
  od;
  return slp;
end; 
InstallGlobalFunction( MakeSLPFromOrderList, GenSift.MakeSLPFromOrderList );

GenSift.SortSLPs := function(slps,todo,weights)
  # Find the slp in slps, which is "best" with respect to the following
  # function: \sum_{i \in [1..Length(todo)]} Position(slp,todo[i] * weight[i])
  # smaller is better
  local i,s,val,vals;
  vals := [];
  for s in slps do
      val := 0;
      for i in [1..Length(todo)] do
          val := val + Position(s,todo[i]) * weights[i];
      od;
      Add(vals,val);
  od;
  Print(vals,"\n");
  SortParallel(vals,slps);
end;

GenSift.CheckOrderElement := function(slp,el)
  local i,l,new,o;
  o := One(el);
  if el = o then
      return false;      # we cannot test for order 1!
  fi;
  l := [el];
  for i in [1..Length(slp)] do
      new := l[slp[i][1]] * l[slp[i][2]];
      Add(l,new);
      if slp[i][3]=1 and new = One(new) then
          return true;
      fi;
  od;
  return false;
end;

GenSift.PrintSiftStep := function(s,t,class)
    local es,fus,ls,lt,q,scs,slp,p,il;
    Print("PreSift.[] := rec(\n");
    Print("  # this does: ->\n");
    Print("  subgpSLP := ,\n");
    Print("  isdeterministic := false,\n");
    Print("  basicsift := BasicSiftRandom,\n");
    p := Position(ClassNames(t),class);
    fus := GetFusionMap(s,t);
    q := Filtered([1..Length(fus)],i->fus[i]=p);
    lt := SizesConjugacyClasses(t)[p];
    scs := SizesConjugacyClasses(s);
    ls := Sum(q,x->scs[x]);
    Print("  p := FLOAT_RAT( ",ls/lt," ),\n");
    Print("  ismember := rec(\n");
    Print("    isdeterministic := false,\n");
    Print("    method := IsMemberConjugates,\n");
    Print("    a := \"fromDown\",\n");
    Print("    ismember := rec(\n");
    Print("      method := IsMemberOrders,\n");
    es := GenSift.ElOrderStats(s,t);
    Print("      p0 := FLOAT_RAT( ",es[4]," ),\n");
    Print("      orders := ",es[6],",\n");
    il := InfoLevel(InfoGenSift);
    SetInfoLevel(InfoGenSift,0);
    slp := FindBestOrderList(es[6]);
    SetInfoLevel(InfoGenSift,il);
    Print("      ordersslp := ",slp[3],",\n");
    Print("    ),\n");
    Print("  ),\n");
    Print(");\n");
end;
InstallGlobalFunction( PrintSiftStep, GenSift.PrintSiftStep );

GenSift.SLPWord := function(word)
  local i,j,l,slp;
  l := Length(word);
  i := 1;
  slp := [];
  while i <= l do
      j := i+1;
      while j <= l and word[j] = word[i] do j := j + 1; od;
      Append(slp,[word[i],j-i]);
      i := j;
  od;
  return slp;
end;

GenSift.FrequentSubwords := function(word)
  local i,j,l,nr,p,s,sw;
  l := Length(word);
  sw := [];
  nr := [];
  for i in [2..Minimum(l,4)] do
      for j in [1..l-i] do
          s := word{[j..j+i-1]};
          p := Position(sw,s);
          if p = fail then
              Add(sw,s);
              Add(nr,1);
              SortParallel(sw,nr);
          else
              nr[p] := nr[p] + 1;
          fi;
      od;
  od;
  nr := List([1..Length(nr)],i->nr[i] * (Length(sw[i])-1));
  SortParallel(nr,sw,function(a,b) return a > b; end);
  return [sw{[1..Minimum(10,Length(sw))]},nr{[1..Minimum(10,Length(sw))]}];
end;

GenSift.FrequentSubSLPs := function(slp)
  local i,j,l,nr,p,s,sw;
  l := Length(slp)/2;
  sw := [];
  nr := [];
  for i in [2..Minimum(l,4)] do
      for j in [1..l-i] do
          s := slp{[2*j-1..2*(j+i-1)]};
          p := Position(sw,s);
          if p = fail then
              Add(sw,s);
              Add(nr,1);
              SortParallel(sw,nr);
          else
              nr[p] := nr[p] + 1;
          fi;
      od;
  od;
  nr := List([1..Length(nr)],i->nr[i] * (Length(sw[i])-2));
  SortParallel(nr,sw,function(a,b) return a > b; end);
  return [sw{[1..Minimum(10,Length(sw))]},nr{[1..Minimum(10,Length(sw))]}];
end;

GenSift.ReplaceSubword := function( word, sw, rep )
  local i,l,ll;
  i := 1;
  l := Length(word);
  ll := Length(sw)-1;
  while i + ll <= l do
      if word{[i..i+ll]} = sw then
          word := Concatenation(word{[1..i-1]},rep,word{[i+ll+1..l]});
          l := Length(word);
      else
          i := i + 1;
      fi;
  od;
  return word;
end;

GenSift.ReplaceSubSLP := function( slp, sw, rep )
  local i,l,ll;
  i := 1;
  l := Length(slp);
  ll := Length(sw)-1;
  while i + ll <= l do
      if slp{[i..i+ll]} = sw then
          slp := Concatenation(slp{[1..i-1]},rep,slp{[i+ll+1..l]});
          l := Length(slp);
      else
          i := i + 2;
      fi;
  od;
  return slp;
end;

GenSift.ReplaceSubSLPByNewSlot := function( slp, sw, newslot )
  local i,l,ll,k;
  i := 1;
  l := Length(slp);
  ll := Length(sw);
  while i + ll-1 <= l do
      if slp{[i..i+ll-1]} = sw then
          # Find multiplicity:
          k := 1;
          while i+(k+1)*ll-1 <= Length(slp) and 
                slp{[i+k*ll .. i+(k+1)*ll-1]} = sw do
              k := k + 1;
          od;
          slp := Concatenation(slp{[1..i-1]},[newslot,k],slp{[i+k*ll..l]});
          l := Length(slp);
      else
          i := i + 2;
      fi;
  od;
  return slp;
end;

GenSift.ProductOfSLPs := function(l)
  local i,li,le;
  i := IntegratedStraightLineProgram(l);
  li := ShallowCopy(LinesOfStraightLineProgram(i));
  le := Length(li);
  li[le] := Flat(li[le]);
  return StraightLineProgram(li,NrInputsOfStraightLineProgram(i));
end;

GenSift.ProductOfResultsOfSLP := function(i)
  local li,le;
  li := ShallowCopy(LinesOfStraightLineProgram(i));
  le := Length(li);
  li[le] := Flat(li[le]);
  return StraightLineProgram(li,NrInputsOfStraightLineProgram(i));
end;
