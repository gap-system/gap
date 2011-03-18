ADOPT_NORECURSE([1,2,3]);

f := function()
 local ds, r, l;
 ds := SHARE_NORECURSE([]);
 l:=LOCK(ds);
 ds[1] := MIGRATE_NORECURSE([1,2], ds);
 UNLOCK(l);
 l:=LOCK(ds);
 r := ADOPT_NORECURSE(ds[1]);
 UNLOCK(l);
 return r;
end;

res:=f();
Print("Migration test : ", res=[1,2], "\n");

