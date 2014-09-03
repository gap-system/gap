#
# Hash orbits using tasks
#


# Basic task
# . Take a list of triples (parent, genno, point), hash the points and look up. If it is new assign an id
#    Call the record function on each (parent id, gen, new id) triple (parent and gen are fail for the seeds)
#     For the actually new points and their ids act on them by all the generators
#     make a list of triples: pt, parent id, gen used and cut it into blocks of
#       some suitable size. Run task  on each block
       
#

#
#  dict is a thread-safe data structure (blocked hash table perhaps)
#  it supports AddOrLookup(dict, obj) 
#  if obj is in dict already, it returns the id assigned when obj was added
#  if  obj is not already in dict, it returns -(a new id)
#  The IDs are small positive ints, and while they may not be contiguous they shouldn't be too huge.
#


BLOCKING := 100;
NHASHTABLES := 17;


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

#
# Two approaches to managing the hash tables. 
# optimum might well be to switch from 1 to 2
# once the rediscovery rate gets high enough.
#


SHTaddOrLookup1 := function(dict, obj)
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

SHTaddOrLookup2 := function(dict, obj)
    local  h, t, ht;
    h := dict.hash1(obj) mod dict.npieces+1;
    t := dict.tables[h];
    atomic readonly t do
        ht := GetHashEntry(t.table,obj);
    od;
    if ht = fail then
        atomic readwrite t do
           ht := GetHashEntry(t.table,obj);
           if ht = fail then 
               ht := t.next;
               t.next := t.next+1;
               if  t.next > t.top then
                   t.next := t.next + (dict.npieces-1)*dict.magic;
                   t.top := t.next + dict.magic -1;
               fi;
               AddHashEntry(t.table, obj, ht);
               return -ht;
           fi;
       od;
       
   fi;
   return ht;
end;

SHTaddOrLookup := SHTaddOrLookup1;


task := function( points, parentids, gennos, gens, action, dict, addOrLookup, record, l, sem)
    local  emit, npts, parents, ngennos, i, res, j;

    emit := function()
        MakeImmutable(npts);
        MakeImmutable(parents);
        MakeImmutable(ngennos);
        ATOMIC_ADDITION(l,1,1);
        ATOMIC_ADDITION(l,2,1);        
        RunAsyncTask(task, npts, parents, ngennos, gens, action, dict, addOrLookup, record, l, sem);
    end;
    npts := [];
    parents := [];
    ngennos := [];
    for i in [1..Length(points)] do
        res := addOrLookup(dict, points[i]);
        record(parentids[i], gennos[i], AbsoluteValue(res));
        if res < 0 then
            for j in [1..Length(gens)] do
                Add(parents, -res);
                Add(ngennos, j);
                Add(npts, action(points[i], gens[j]));
            od;
            if Length(parents) >= BLOCKING then
                emit();
                npts := [];
                parents := [];
                ngennos := [];
            fi;
        fi;
    od;
    if Length(parents) > 0 then
        emit();
    fi;   
    
   ATOMIC_ADDITION(l,1,-1);
   if l[1] = 0 then
       SignalSemaphore(sem);
   fi;
end;

SeqDict := function(hash)
    return rec( nextid := 1, table := SparseHashTable(hash));
end;


HTaddOrLookup := function(ht, obj)
    local  res, nextid;
    res := GetHashEntry(ht.table, obj);
    if res = fail then
        AddHashEntry(ht.table, obj, ht.nextid);
        res := -ht.nextid;
        ht.nextid := ht.nextid+1;
    fi;
    return res;
end;

        

seqorb := function( seeds, gens, action, dict, addOrLookup, record)
    local  queue, qids, i, ngens, pt, npt, newid,j ;
    queue := ShallowCopy(seeds);
    qids :=  List(seeds, x->fail);
    i := 1;
    ngens := Length(gens);
    while i <= Length(queue) do
        pt := queue[i];
        for j in [1..ngens] do
            npt := action(pt,gens[j]);
            newid := addOrLookup(dict, npt);
            record(qids[i], j, AbsoluteValue(newid));
            if newid < 0 then
                Add(queue, npt);
                Add(qids, newid);
            fi;
        od;
        i := i+1;
    od;
end;

      
             
        
parorb := function( seeds, gens, action, dict, addOrLookup, record)
    local  l, sem, fakes;
    l := FixedAtomicList([0,0]);
    sem := CreateSemaphore(0);
    seeds := Immutable(seeds);
    fakes := `List(seeds, s->fail);
    ATOMIC_ADDITION(l, 1, 1);
    ATOMIC_ADDITION(l,2,1);        
    RunAsyncTask(task, seeds, fakes, fakes,  gens, action, dict, addOrLookup, record, l, sem);
#    while true do Print(l[1]," ",l[2],"\n");
 #   od;
    if l[1] > 0 then
        WaitSemaphore(sem);
    fi;
    
    return l[2];
end;

hash := function(s) 
    local sp;
    sp := AsPlist(s);
    return HashKeyBag(sp, 0,0,SIZE_OBJ(sp));
end;



keysOfSHT := function(d)
    local  keys, i, ka, x;
    keys := [];
    for i in [1..d.npieces] do
        atomic readonly d.tables[i] do
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


actionViaParOrb := function(seeds, gens, action, hash)
    local  d, ngens, acts, n0, map, imap, n, a, i, realacts;
    d := newSplitHashTableDict(hash, hash, NHASHTABLES, 100);
    ngens := Length(gens);
    acts := List([1..ngens], i->MakeWriteOnceAtomic([]));
    MakeReadOnly(acts);
    Print("Task count ",parorb(seeds, gens, action, d, SHTaddOrLookup, function(parentid, genno, id)
        if parentid <> fail then
            acts[genno][parentid] := id;
        fi;
    end),"\n");
    acts := List(acts, FromAtomicList);
    n0 := Length(acts[1]);
    map := [];
    imap := [];
    n := 0;
    a := acts[1];
    for i in [1..n0] do
        if IsBound(a[i]) then
            n := n+1;
            map[i] := n;
            imap[n] := i;
        fi;
    od;
    realacts := List(acts, a->
                     List([1..n], i-> map[a[imap[i]]]));
    return realacts;
end;

    

m24trial := function()
    local  d, gens, orb;
    orb := AtomicList([]);
    d := newSplitHashTableDict(x->x, x->x, NHASHTABLES, 100);
    gens := GeneratorsOfGroup(MathieuGroup(24));
    parorb([1], gens, OnPoints, d, SHTaddOrLookup, function(a,b,c) 
        end);
        return keysOfSHT(d);
        
end;

m24trialn := function(n)
    local  d, gens;
    d := newSplitHashTableDict(hash, hash, NHASHTABLES, 100);
    gens := GeneratorsOfGroup(MathieuGroup(24));
    parorb([`[1..n]], gens, OnSets, d, SHTaddOrLookup, function(a,b,c) 
        end);
        return keysOfSHT(d);
        
end;

m24seqtrialn := function(n)
    local  d, gens, orb;
    orb := [];
    d := SeqDict(hash);    
    gens := GeneratorsOfGroup(MathieuGroup(24));
    seqorb([AsPlist([1..n])], gens, OnSets, d, HTaddOrLookup, function(a,b,c) 
    end);
    return Filtered(d.table!.KeyArray, x->x<>fail);
end;

m24act := function(n)
    local gens;
    gens := GeneratorsOfGroup(MathieuGroup(24));
    return actionViaParOrb([`AsPlist([1..n])], gens, OnSets, hash);
end;

    
    
