CheckSerialization := function(x)
  local err, x2;
  x2 := DeserializeNativeString(SerializeToNativeString(x));
  if DeserializeNativeString(SerializeToNativeString(x)) <> x or
     TNUM_OBJ_INT(x) <> TNUM_OBJ_INT(x2) then
    err := "Serialization error: ";
    Append(err, String(x));
  fi;
end;

CheckSerialization2 := function(x, f)
  local err;
  if not f(DeserializeNativeString(SerializeToNativeString(x))) then
    err := "Serialization error: ";
    Append(err, String(x));
  fi;
end;

for i in [-100000..100000] do
  CheckSerialization(i);
od;

CheckSerialization(true);
CheckSerialization(false);
CheckSerialization(fail);

for i in [-100..100] do
  CheckSerialization([i]);
od;

CheckSerialization([]);
CheckSerialization(`[]);
CheckSerialization(["abc", `"abc"]);
CheckSerialization(1/2);
CheckSerialization(3.14);
CheckSerialization(rec(x := 1, y := "abc"));
CheckSerialization([1,2,,3,,,4,"x","y"]);
CheckSerialization2([~], x->IsIdenticalObj(x, x[1]));
CheckSerialization2(["abc", ~[1]], x->IsIdenticalObj(x[1], x[2]));
