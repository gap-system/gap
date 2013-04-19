AdoptSingleObj([1,2,3]);

f := function()
 local ds, r, l;
 ds := ShareSingleObj([]);
 l:=LOCK(ds);
 ds[1] := MigrateSingleObj([1,2], ds);
 UNLOCK(l);
 l:=LOCK(ds);
 r := AdoptSingleObj(ds[1]);
 UNLOCK(l);
 return r;
end;

res:=f();
Print("Migration test : ", res=[1,2], "\n");

