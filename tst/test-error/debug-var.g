x:=1;;
f:=function(a)
  local g, y, unbound_higher;
  y:=2;
  g := function(b)
     local z, unbound_local;
     z:=3;
     Error("breakpoint");
     return a+b+z;
  end;
  return g(10) + y;
end;;
f(1);

x; # access global
Unbind(x);
x:=42;
IsBound(x);
unbound_global;

y; # access higher local
Unbind(y);
y:=100;
IsBound(y);
unbound_higher;
quit;

z; # access local
Unbind(z);
z:=1000;
IsBound(z);
unbound_local;
quit;

return;
x;
y;
