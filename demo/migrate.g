ADOPT_NORECURSE([1,2,3]);

f := function()
 local ds, r;
 ds := SHARE_NORECURSE([]);
 LOCK(ds);
 ds[1] := MIGRATE_NORECURSE([1,2], ds);
 UNLOCK(ds);
 LOCK(ds);
 r := ADOPT_NORECURSE(ds[1]);
 UNLOCK(ds);
 return r;
end;

res:=f();
Print("Migration test : ", res=[1,2], "\n");
