LoadPackage("orb");
Read ("../bench.g");

if IsBound(MakeReadOnlyObj) then
    OnRightRO := function(x,g)
      local y;
      y := x*g;
      MakeReadOnlyObj(y);
      return y;
    end;
else
    OnRightRO := OnRight;
fi;

SequentialOrbit := function(gens,pt,op,opt)
  local ht, orbitSize, tasks, x, val, toProcess, g, t, noTasks;
  
  if not IsBound(opt.hashlen) then opt.hashlen := 100001; fi;
  if IsGroup(gens) then gens := GeneratorsOfGroup(gens); fi;
  if IsMutable(gens) then MakeImmutable(gens); fi;
  if IsMutable(pt) then pt := MakeImmutable(StructuralCopy(pt)); fi;

  orbitSize := 1;
  ht := HTCreate(pt, rec (hashlen := 2000000));
  HTAdd(ht,pt,true);
  tasks := EmptyPlist(2000000);
  noTasks := 1;
  Add(tasks, pt);
  
  while noTasks > 0 do
    toProcess := Remove(tasks);
    noTasks := noTasks - 1;
    for g in gens do
      x := op(toProcess,g);
      val := HTValue(ht,x); 
      if val = fail then
        HTAdd (ht, x, true); 
        Add(tasks,x);
        noTasks := noTasks + 1;
        orbitSize := orbitSize + 1;
      fi;
    od;
  od;
  
  return orbitSize;
      
end;

SequentialOrbit2 := function(gens,pt,op,opt)
  local g,ht,i,o,v,x;
  if not IsBound(opt.hashlen) then opt.hashlen := 100001; fi;
  if IsGroup(gens) then gens := GeneratorsOfGroup(gens); fi;
  if IsMutable(gens) then MakeImmutable(gens); fi;
  if IsMutable(pt) then pt := MakeImmutable(StructuralCopy(pt)); fi;
  ht := HTCreate(pt,rec( hashlen := opt.hashlen ));
  o := EmptyPlist(opt.hashlen);
  Add(o,pt);
  HTAdd(ht,pt,true);
  i := 1;
  while i <= Length(o) do
    for g in gens do
      x := op(o[i],g);
      v := HTValue(ht,x);
      if v = fail then
        Add(o,x);
        HTAdd(ht,x,true);
      fi;
    od;
    i := i + 1;
  od;
  return rec( orb := o, ht := ht );
end;


