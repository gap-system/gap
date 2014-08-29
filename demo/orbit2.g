#
# Hash orbits using tasks
#


# Basic task
# 1. Take a list of points and a matching list of  ids, act on them by all the generators
#     make a list of triples: pt, parent id, gen used and cut it into blocks of
#       some suitable size. Run task 2 on each block
       
# 2. Take a list of triples, hash the points and look up. If it is new assign an id
#    Call the record function on each (parent id, gen, new id) triple
#    Call task 1 on the new ones.
#

#
#  dict is a thread-safe data structure (blocked hash table perhaps)
#  it supports AddOrLookup(dict, obj) 
#  if obj is in dict already, it returns the id assigned when obj was added
#  if  obj is not already in dict, it returns -(a new id)
#  the IDs are small positive ints, and while they may not be contiguous they shouldn't be too huge.
#


BLOCKING := 100;

newSplitHashTableDict := function(hash1, hash2, npieces, magic)
    local  r, tables, t, i;
    r := rec(npieces := npieces, hash1 := hash1, hash2 := hash2, magic := magic, 
             tables := []);
    for i in [1..npieces] do
        r.tables[i] := rec(next := 1 + (i-1)*magic, top := i*magic, table := 
                           SparseHashTable(hash2));
        
    od;
    for t in r.tables do
        ShareObj(t);
    od;
    MakeReadOnly(r);
    return r;
end;

SHTaddOrLookup := function(dict, obj)
    local  h, t, ht;
    h := dict.hash1(obj) mod dict.npieces+1;
    t := dict.tables[h];
    atomic readwrite t do
       ht := GetHashEntry(t.table,obj);
       if ht = fail then
           ht := t.next;
           t.next := t.next+1;
           if t.next > t.top then
               t.next := t.next + (dict.npieces-1)*dict.magic;
               t.top := t.next + dict.magic -1;
           fi;
           AddHashEntry(t.table, obj, ht);
           return -ht;
       fi;
   od;
   return ht;
end;



actorTask := fail;


filerTask := function( points, parentids, gennos, gens, action, dict, addOrLookup, record, l, sem)
    local  newpts, newids, i, res;
    newpts := [];
    newids := [];
    for i in [1..Length(points)] do
        res := addOrLookup(dict, points[i]);
        record(parentids[i], gennos[i], AbsoluteValue(res));
        if res < 0 then
            Add(newpts, points[i]);
            Add(newids, -res);
        fi;
    od;
    if Length(newpts) > 0 then
        MakeImmutable(newpts);
        MakeImmutable(newids);
        ATOMIC_ADDITION(l,1,1);
        RunAsyncTask(actorTask, newpts, newids, gens, action, dict, addOrLookup, record, l, sem);
    fi;
    
   ATOMIC_ADDITION(l,1,-1);
   if l[1] = 0 then
       SignalSemaphore(sem);
   fi;
end;

        
            


actorTask := function( points, ids, gens, action, dict, addOrLookup, record, l, sem)
    local  npts, parents, gennos, emit, i, j;
    npts := [];
    parents := [];
    gennos := [];
    emit := function()
        MakeImmutable(npts);
        MakeImmutable(parents);
        MakeImmutable(gennos);
        ATOMIC_ADDITION(l,1,1);
        RunAsyncTask(filerTask, npts, parents, gennos, gens, action, dict, addOrLookup, record, l, sem);
    end;
        
        
    for i in [1..Length(points)] do
        for j in [1..Length(gens)] do
            Add(parents, ids[i]);
            Add(gennos, j);
            Add(npts, action(points[i], gens[j]));
        od;
        if Length(parents) >= BLOCKING then
            emit();
            npts := [];
            parents := [];
            gennos := [];
        fi;
    od;
    if Length(parents) >= 0 then
        emit();
    fi;
    ATOMIC_ADDITION(l,1,-1);
    if l[1] = 0 then
        SignalSemaphore(sem);
    fi;
end;

    
        


parorb := function( seeds, gens, action, dict, addOrLookup, record)
    local  l, sem, seedids;
    l := FixedAtomicList([0]);
    sem := CreateSemaphore(0);
    seeds := Immutable(seeds);
    seedids := `List(seeds, s-> AbsoluteValue(addOrLookup(dict,s)));
    ATOMIC_ADDITION(l, 1, 1);
    RunAsyncTask(actorTask, seeds, seedids, gens, action, dict, addOrLookup, record, l, sem);
    WaitSemaphore(sem);
    return;
end;


keysOfSHT := function(d)
    local  keys, i, ka, x;
    keys := [];
    for i in [1..d.npieces] do
        atomic readwrite d.tables[i] do
           ka := d.tables[i].table!.KeyArray;
           for x in ka do
               if x <> fail then
                   Add(keys, Immutable(x));
               fi;
           od;
       od;
    od;
    return keys;
end;

        
m24trial := function()
    local  d, gens, orb;
    orb := AtomicList([]);
    d := newSplitHashTableDict(x->x, x->x, 4, 100);
    gens := GeneratorsOfGroup(MathieuGroup(24));
    parorb([1], gens, OnPoints, d, SHTaddOrLookup, function(a,b,c) 
        end);
        return keysOfSHT(d);
        
end;

m24trialn := function(n)
    local  d, gens, orb;
    orb := AtomicList([]);
    d := newSplitHashTableDict(Sum, Product, 8, 100);
    gens := GeneratorsOfGroup(MathieuGroup(24));
    parorb([`[1..n]], gens, OnSets, d, SHTaddOrLookup, function(a,b,c) 
        end);
        return keysOfSHT(d);
        
end;
