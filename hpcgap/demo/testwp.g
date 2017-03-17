iter := 10000000/2;
n := 1000;
m := 256;

data := [];
for i in [1..n] do
  data[i] := [0];
od;

wp := [];
for i in [1..m] do
  wp[i] := WeakPointerObj( [] );
od;

for i in [1..iter] do
  t := [i];
  if i mod 100000 = 0 then
    Display(i);
  fi;
  data[Random([1..n])] := t;
  SetElmWPObj(wp[Random([1..m])], Int(i/1024)+1, t);
od;

for i in [1..m] do
  if m mod 2 = 0 then
    wp[i] := ShallowCopy(wp[i]);
  else
    wp[i] := StructuralCopy(wp[i]);
  fi;
od;

for i in [iter+1..iter*2] do
  t := [i];
  if i mod 100000 = 0 then
    Display(i);
  fi;
  data[Random([1..n])] := t;
  SetElmWPObj(wp[Random([1..m])], Int(i/1024)+1, t);
od;

min := iter;
max := 0;
bound := [];
for i in [1..m] do
  len := LengthWPObj(wp[i]);
  if len > max then
    max := len;
  fi;
  for j in [1..len] do
    if ElmWPObj(wp[i], j) <> fail then
      if not j in bound then
	Add(bound, j);
      fi;
      if j < min then
	min := j;
      fi;
    fi;
  od;
od;
Sort(bound);
Display(bound);

Print("Weak uncollected elements in range [", min, "..", max, "]\n");
